import { fork } from "node:child_process";
import { randomBytes } from "node:crypto";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

import { app, BrowserWindow, dialog, Menu, session } from "electron";
import updater from "electron-updater";

import {
  desktopGameUrl,
  isTrustedGameUrl,
  parseDesktopInvite,
  reserveLoopbackPort,
  waitForFlux,
} from "./runtime.mjs";
import { ensureCloudflared, startQuickTunnel } from "./tunnel.mjs";

const { autoUpdater } = updater;
const desktopRoot = fileURLToPath(new URL("../", import.meta.url));
const friendsMode = process.argv.includes("--friends");
let authority = null;
let mainWindow = null;
let gameOrigin = null;
let quitting = false;
let tunnel = null;
let pendingInvite = parseDesktopInvite(process.argv);
let cleanupStarted = false;
let allowExit = false;
let fullscreenGuard = null;

app.enableSandbox();
app.setName("FLUX Arena");
if (app.isPackaged) app.setAsDefaultProtocolClient("flux");

if (!app.requestSingleInstanceLock()) {
  app.quit();
} else {
  app.on("second-instance", (_event, commandLine) => {
    const invite = parseDesktopInvite(commandLine);
    if (invite && gameOrigin && mainWindow) {
      void mainWindow.loadURL(desktopGameUrl(gameOrigin, { invite }));
    } else if (invite) {
      pendingInvite = invite;
    }
    if (!mainWindow) return;
    if (mainWindow.isMinimized()) mainWindow.restore();
    mainWindow.focus();
  });
  app.whenReady().then(startDesktop).catch(failStartup);
}

async function startDesktop() {
  app.setAppUserModelId("io.fluxarena.game");
  Menu.setApplicationMenu(null);
  denyRendererPermissions();

  const port = await reserveLoopbackPort();
  const desktopToken = randomBytes(32).toString("hex");
  gameOrigin = `http://127.0.0.1:${port}`;
  authority = startAuthority(port, desktopToken);
  await waitForFlux(gameOrigin, { desktopToken });
  let publicOrigin = null;
  if (friendsMode) {
    const binaryPath = await ensureCloudflared(
      join(app.getPath("userData"), "tools", "cloudflared"),
    );
    tunnel = await startReachableFriendTunnel(binaryPath, gameOrigin);
    tunnel.child.once("exit", (code, signal) => {
      if (quitting) return;
      failStartup(new Error(`FLUX friend tunnel stopped (${signal ?? code ?? "unknown"}).`));
    });
    publicOrigin = tunnel.origin;
    console.log(`FLUX friend link ready: ${publicOrigin}`);
  }
  createGameWindow(desktopGameUrl(gameOrigin, {
    friends: friendsMode,
    publicOrigin,
    invite: pendingInvite,
  }));
  pendingInvite = null;
  checkForUpdates();
}

async function startReachableFriendTunnel(binaryPath, localOrigin) {
  let lastError = null;
  for (let attempt = 1; attempt <= 3; attempt += 1) {
    const candidate = await startQuickTunnel(binaryPath, localOrigin);
    try {
      await waitForFlux(candidate.origin, { attempts: 150, delayMs: 100 });
      return candidate;
    } catch (error) {
      lastError = error;
      await stopOwnedChild(candidate.child);
      console.error(`Friend tunnel attempt ${attempt} was not reachable; retrying.`);
    }
  }
  throw lastError ?? new Error("Could not create a reachable FLUX friend tunnel.");
}

function startAuthority(port, desktopToken) {
  const appRoot = app.isPackaged ? app.getAppPath() : desktopRoot;
  const serverPath = join(appRoot, "scripts", "serve.mjs");
  const child = fork(serverPath, ["--host=127.0.0.1", `--port=${port}`], {
    env: {
      ...process.env,
      ELECTRON_RUN_AS_NODE: "1",
      FLUX_DESKTOP_TOKEN: desktopToken,
    },
    execPath: process.execPath,
    silent: true,
  });
  child.stdout?.on("data", (chunk) => process.stdout.write(chunk));
  child.stderr?.on("data", (chunk) => process.stderr.write(chunk));
  child.once("exit", (code, signal) => {
    if (quitting) return;
    failStartup(new Error(`FLUX authority stopped unexpectedly (${signal ?? code ?? "unknown"}).`));
  });
  return child;
}

function createGameWindow(url) {
  mainWindow = new BrowserWindow({
    width: 1440,
    height: 900,
    minWidth: 960,
    minHeight: 640,
    fullscreen: true,
    show: false,
    backgroundColor: "#17120d",
    title: "FLUX Arena",
    autoHideMenuBar: true,
    webPreferences: {
      backgroundThrottling: false,
      contextIsolation: true,
      devTools: !app.isPackaged,
      navigateOnDragDrop: false,
      nodeIntegration: false,
      sandbox: true,
      webSecurity: true,
    },
  });

  mainWindow.webContents.setWindowOpenHandler(() => ({ action: "deny" }));
  mainWindow.webContents.on("will-navigate", (event, candidate) => {
    if (!isTrustedGameUrl(candidate, gameOrigin)) event.preventDefault();
  });
  mainWindow.webContents.on("will-attach-webview", (event) => event.preventDefault());
  if (!app.isPackaged) {
    mainWindow.webContents.on("console-message", (_event, details) => {
      const level = details?.level ?? "log";
      const message = details?.message ?? "Unknown renderer message";
      const source = details?.sourceId
        ? ` (${details.sourceId}:${details.lineNumber ?? 0})`
        : "";
      const write = level === "error" ? console.error : level === "warning" ? console.warn : console.log;
      write(`[FLUX renderer] ${message}${source}`);
    });
  }
  mainWindow.once("ready-to-show", () => {
    if (!mainWindow) return;
    enforceFullscreen();
    mainWindow.show();
    mainWindow.focus();
  });
  mainWindow.on("leave-full-screen", enforceFullscreen);
  fullscreenGuard = setInterval(enforceFullscreen, 1_000);
  fullscreenGuard.unref();
  mainWindow.on("closed", () => {
    clearInterval(fullscreenGuard);
    fullscreenGuard = null;
    mainWindow = null;
  });
  void mainWindow.loadURL(url);
}

function enforceFullscreen() {
  if (quitting || !mainWindow || mainWindow.isDestroyed()) return;
  if (!mainWindow.isFullScreen()) mainWindow.setFullScreen(true);
}

function denyRendererPermissions() {
  session.defaultSession.setPermissionCheckHandler((contents, permission, requestingOrigin) => {
    return permission === "clipboard-sanitized-write" &&
      contents === mainWindow?.webContents &&
      isTrustedGameUrl(requestingOrigin, gameOrigin);
  });
  session.defaultSession.setPermissionRequestHandler((contents, permission, callback) => {
    callback(
      permission === "clipboard-sanitized-write" &&
      contents === mainWindow?.webContents &&
      isTrustedGameUrl(contents.getURL(), gameOrigin),
    );
  });
}

function checkForUpdates() {
  if (!app.isPackaged || process.env.FLUX_DISABLE_UPDATES === "1") return;
  autoUpdater.autoDownload = true;
  autoUpdater.autoInstallOnAppQuit = true;
  autoUpdater.on("error", (error) => {
    console.error(`FLUX update check failed: ${error.message}`);
  });
  void autoUpdater.checkForUpdatesAndNotify().catch(() => {
    // The error event above owns reporting; update failure never strands play.
  });
}

function failStartup(error) {
  const message = error instanceof Error ? error.message : String(error);
  console.error(message);
  if (app.isReady()) dialog.showErrorBox("FLUX could not start", message);
  app.quit();
}

app.on("before-quit", (event) => {
  if (allowExit) return;
  event.preventDefault();
  if (cleanupStarted) return;
  cleanupStarted = true;
  quitting = true;
  void Promise.all([
    stopOwnedChild(tunnel?.child),
    stopOwnedChild(authority, { gracefulMessage: { type: "shutdown" } }),
  ]).finally(() => {
    allowExit = true;
    app.quit();
  });
});

app.on("window-all-closed", () => app.quit());

function stopOwnedChild(child, { gracefulMessage = null, graceMs = 1_500 } = {}) {
  if (!child || child.exitCode !== null || child.signalCode !== null) return Promise.resolve();
  return new Promise((resolve) => {
    let complete = false;
    let forceTimer;
    let finalTimer;
    const finish = () => {
      if (complete) return;
      complete = true;
      clearTimeout(forceTimer);
      clearTimeout(finalTimer);
      child.off("exit", finish);
      resolve();
    };
    child.once("exit", finish);
    if (gracefulMessage && child.connected) child.send(gracefulMessage);
    else child.kill("SIGTERM");
    forceTimer = setTimeout(() => {
      if (child.exitCode === null && child.signalCode === null) child.kill("SIGKILL");
    }, graceMs);
    finalTimer = setTimeout(finish, graceMs * 2);
  });
}
