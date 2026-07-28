import { createServer } from "node:http";
import { randomUUID } from "node:crypto";
import { mkdir, readFile, unlink, writeFile } from "node:fs/promises";
import { extname, join, resolve, sep } from "node:path";
import { networkInterfaces, tmpdir } from "node:os";
import { fileURLToPath } from "node:url";
import { WebSocketServer } from "ws";

import { MATCH_TUNING } from "../src/content.mjs";
import { LobbyService } from "../src/network/lobbies.mjs";

const root = resolve(fileURLToPath(new URL("../", import.meta.url)));
const serverVersion = "0.34.3";
const protocolVersion = 2;
const requestedPort =
  argumentValue("--port") ?? process.env.PORT ?? process.env.FLUX_PORT ?? process.env.DIFF_PORT ?? "8000";
const port = Number.parseInt(requestedPort, 10);
const host =
  argumentValue("--host") ??
  process.env.HOST ??
  process.env.FLUX_HOST ??
  process.env.DIFF_HOST ??
  "127.0.0.1";
const healthPath = "/__flux_health";
const legacyHealthPath = "/__diff_health";
const shutdownPath = "/__flux_shutdown";
const lobbyPath = "/api/lobbies";
const instanceId = randomUUID();
const shutdownToken = randomUUID();
const desktopToken = process.env.FLUX_DESKTOP_TOKEN ?? null;
const registryDirectory = join(tmpdir(), "flux-arena-servers");
const registryPath = join(registryDirectory, `${sanitizeRegistryPart(host)}-${port}.json`);
const publicFiles = new Set([
  "/index.html",
  "/styles.css",
  "/src/content.mjs",
  "/src/game.mjs",
  "/src/match.mjs",
  "/src/network/conditioner.mjs",
  "/src/network/invite.mjs",
  "/src/network/quality.mjs",
]);
const contentTypes = new Map([
  [".css", "text/css; charset=utf-8"],
  [".html", "text/html; charset=utf-8"],
  [".js", "text/javascript; charset=utf-8"],
  [".mjs", "text/javascript; charset=utf-8"],
  [".svg", "image/svg+xml"],
]);
const securityHeaders = Object.freeze({
  "Content-Security-Policy":
    "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; connect-src 'self' http: https: ws: wss:; img-src 'self' data:; object-src 'none'; base-uri 'none'; frame-ancestors 'none'",
  "Cross-Origin-Opener-Policy": "same-origin",
  "Referrer-Policy": "no-referrer",
  "X-Content-Type-Options": "nosniff",
  "X-Frame-Options": "DENY",
});
let shuttingDown = false;

if (!Number.isInteger(port) || port < 1 || port > 65535) {
  throw new RangeError(`PORT must be an integer from 1 to 65535; received ${port}`);
}
if (
  typeof host !== "string" ||
  host.length === 0 ||
  host.length > 255 ||
  /\s/.test(host)
) {
  throw new RangeError(`HOST must be a valid hostname or address; received ${host}`);
}

const server = createServer(async (request, response) => {
  try {
    const url = new URL(request.url ?? "/", "http://localhost");
    const pathname = decodeURIComponent(url.pathname);

    if (pathname === healthPath || pathname === legacyHealthPath) {
      response.writeHead(200, {
        ...securityHeaders,
        "Cache-Control": "no-store",
        "Content-Type": "application/json; charset=utf-8",
      });
      response.end(
        JSON.stringify({
          product: pathname === legacyHealthPath ? "DIFF" : "FLUX",
          status: "ready",
          version: serverVersion,
          protocol: protocolVersion,
          instance: instanceId,
          ...(desktopToken ? { desktopToken } : {}),
        }),
      );
      return;
    }

    if (pathname === shutdownPath) {
      const suppliedToken = request.headers["x-flux-shutdown-token"];
      if (
        request.method !== "POST" ||
        !isLoopbackAddress(request.socket.remoteAddress) ||
        suppliedToken !== shutdownToken
      ) {
        respond(response, 403, "Forbidden");
        return;
      }
      response.writeHead(202, {
        ...securityHeaders,
        "Cache-Control": "no-store",
        "Content-Type": "application/json; charset=utf-8",
      });
      response.end(JSON.stringify({ status: "stopping" }));
      setImmediate(shutdown);
      return;
    }

    if (pathname === lobbyPath && request.method === "GET") {
      response.writeHead(200, {
        ...securityHeaders,
        "Access-Control-Allow-Origin": "*",
        "Cache-Control": "no-store",
        "Content-Type": "application/json; charset=utf-8",
      });
      response.end(JSON.stringify({ lobbies: lobbyService.list() }));
      return;
    }

    const requestedPath = pathname === "/" ? "/index.html" : pathname;
    if (!publicFiles.has(requestedPath)) {
      respond(response, 404, "Not found");
      return;
    }
    const filePath = resolve(root, `.${requestedPath}`);
    const insideRoot = filePath === root || filePath.startsWith(`${root}${sep}`);

    if (!insideRoot) {
      respond(response, 403, "Forbidden");
      return;
    }

    const content = await readFile(filePath);
    response.writeHead(200, {
      ...securityHeaders,
      "Cache-Control": "no-store",
      "Content-Type": contentTypes.get(extname(filePath)) ?? "application/octet-stream",
    });
    response.end(content);
  } catch (error) {
    if (error instanceof URIError) {
      respond(response, 400, "Bad request");
      return;
    }
    if (error?.code === "ENOENT" || error?.code === "EISDIR") {
      respond(response, 404, "Not found");
      return;
    }

    console.error("Static server request failed:", error);
    respond(response, 500, "Internal server error");
  }
});

const lobbyService = new LobbyService();
const webSockets = new WebSocketServer({
  noServer: true,
  maxPayload: 16 * 1024,
  perMessageDeflate: false,
});

server.on("upgrade", (request, socket, head) => {
  let pathname;
  try {
    pathname = new URL(request.url ?? "/", "http://localhost").pathname;
  } catch {
    socket.destroy();
    return;
  }
  if (pathname !== "/ws") {
    socket.destroy();
    return;
  }
  webSockets.handleUpgrade(request, socket, head, (webSocket) => {
    webSockets.emit("connection", webSocket, request);
  });
});

webSockets.on("connection", (webSocket) => {
  const clientId = randomUUID();
  let messagesInWindow = 0;
  let windowStarted = Date.now();
  const send = (message) => {
    if (webSocket.readyState === webSocket.OPEN) {
      webSocket.send(JSON.stringify(message));
    }
  };
  send({
    type: "hello",
    clientId,
    protocol: protocolVersion,
    version: serverVersion,
    tickRate: MATCH_TUNING.tickRate,
  });

  webSocket.on("message", (raw, binary) => {
    const now = Date.now();
    if (now - windowStarted >= 1_000) {
      messagesInWindow = 0;
      windowStarted = now;
    }
    messagesInWindow += 1;
    if (messagesInWindow > 220 || binary) {
      webSocket.close(1008, "Rate or payload violation");
      return;
    }
    let message;
    try {
      message = JSON.parse(raw.toString());
    } catch {
      send({ type: "error", code: "invalid-json", message: "Message must be JSON." });
      return;
    }
    const requestId =
      typeof message.requestId === "string" ? message.requestId.slice(0, 40) : null;
    const result = handleClientMessage(lobbyService, clientId, message, send);
    if (result && requestId) {
      send({ type: "result", requestId, action: message.type, ...result });
    } else if (result && !result.ok) {
      send({ type: "error", code: result.code, message: result.message });
    }
  });

  webSocket.on("close", () => lobbyService.disconnect(clientId));
  webSocket.on("error", () => lobbyService.disconnect(clientId));
});

const tickInterval = setInterval(
  () => lobbyService.tick(1 / MATCH_TUNING.tickRate),
  1_000 / MATCH_TUNING.tickRate,
);
tickInterval.unref();

server.once("error", (error) => {
  clearInterval(tickInterval);
  const address = `http://${displayHost(host)}:${port}`;
  if (error?.code === "EADDRINUSE") {
    console.error(`Cannot start FLUX at ${address}: that port is already in use.`);
  } else {
    console.error(`Cannot start FLUX at ${address}: ${error?.message ?? error}`);
  }
  process.exitCode = 1;
});

server.listen(port, host, async () => {
  await registerServer();
  console.log(`FLUX is running at http://${displayHost(host)}:${port}`);
  if (host === "0.0.0.0" || host === "::") {
    console.log("Remote lobbies enabled on all network interfaces.");
    for (const address of localNetworkAddresses()) {
      console.log(`LAN lobby address: http://${address}:${port}`);
    }
  }
});

server.on("close", () => {
  clearInterval(tickInterval);
  void removeServerRegistration();
});
process.once("SIGINT", shutdown);
process.once("SIGTERM", shutdown);
process.once("disconnect", shutdown);
process.on("message", (message) => {
  if (message?.type === "shutdown") shutdown();
});

function respond(response, status, message) {
  response.writeHead(status, {
    ...securityHeaders,
    "Content-Type": "text/plain; charset=utf-8",
  });
  response.end(message);
}

function handleClientMessage(service, clientId, message, send) {
  if (!message || typeof message !== "object") {
    return { ok: false, code: "invalid-message", message: "Object required." };
  }
  if (message.type === "list") {
    return { ok: true, lobbies: service.list() };
  }
  if (message.type === "probe") {
    if (!Number.isInteger(message.sequence) || message.sequence < 1 || message.sequence > 1_000_000_000) {
      return { ok: false, code: "invalid-probe", message: "Probe sequence must be a positive integer." };
    }
    send({ type: "probe", sequence: message.sequence });
    return null;
  }
  if (message.type === "host") {
    return service.host(clientId, message.options, send);
  }
  if (message.type === "join") {
    return service.join(clientId, message.code, message.options, send);
  }
  if (message.type === "spectate") {
    return service.spectate(clientId, message.code, message.options, send);
  }
  if (message.type === "reconnect") {
    return service.reconnect(clientId, message.token, send);
  }
  if (message.type === "leave") {
    return { ok: service.leave(clientId) };
  }
  if (message.type === "input") {
    return service.input(clientId, message.sequence, message.command);
  }
  if (message.type === "agent") {
    return service.changeAgent(clientId, message.characterId);
  }
  if (message.type === "rematch") {
    return service.rematch(clientId);
  }
  return {
    ok: false,
    code: "unknown-action",
    message: `Unknown message type: ${String(message.type).slice(0, 24)}`,
  };
}

function displayHost(value) {
  return value === "0.0.0.0" || value === "::" ? "127.0.0.1" : value;
}

function argumentValue(name) {
  const exactIndex = process.argv.indexOf(name);
  if (exactIndex >= 0) return process.argv[exactIndex + 1];
  const prefix = `${name}=`;
  const match = process.argv.find((argument) => argument.startsWith(prefix));
  return match?.slice(prefix.length);
}

async function registerServer() {
  await mkdir(registryDirectory, { recursive: true });
  await writeFile(
    registryPath,
    JSON.stringify({
      product: "FLUX",
      pid: process.pid,
      root,
      host,
      port,
      version: serverVersion,
      startedAt: new Date().toISOString(),
      instance: instanceId,
      shutdownToken,
    }),
    { encoding: "utf8", mode: 0o600 },
  );
}

async function removeServerRegistration() {
  try {
    await unlink(registryPath);
  } catch (error) {
    if (error?.code !== "ENOENT") console.error("Could not remove FLUX server record:", error);
  }
}

function shutdown() {
  if (shuttingDown) return;
  shuttingDown = true;
  const notice = JSON.stringify({
    type: "server-shutdown",
    code: "host-shutdown",
    message: "The authoritative host shut down. This match has ended.",
  });
  for (const client of webSockets.clients) {
    if (client.readyState !== client.OPEN) continue;
    client.send(notice, () => client.close(1012, "Authoritative host shut down"));
  }
  const forceClose = setTimeout(() => {
    for (const client of webSockets.clients) client.terminate();
  }, 500);
  forceClose.unref();
  let httpClosed = false;
  let socketsClosed = webSockets.clients.size === 0;
  const finish = () => {
    if (!httpClosed || !socketsClosed) return;
    clearTimeout(forceClose);
    void removeServerRegistration().finally(() => process.exit(0));
  };
  webSockets.close(() => {
    socketsClosed = true;
    finish();
  });
  server.close(() => {
    httpClosed = true;
    finish();
  });
}

function sanitizeRegistryPart(value) {
  return String(value).replace(/[^a-z0-9.-]+/gi, "_");
}

function localNetworkAddresses() {
  const addresses = [];
  try {
    for (const entries of Object.values(networkInterfaces())) {
      for (const entry of entries ?? []) {
        if (entry.family === "IPv4" && !entry.internal) {
          addresses.push(entry.address);
        }
      }
    }
  } catch (error) {
    console.warn(`LAN address discovery unavailable: ${error.code ?? error.message}`);
  }
  return [...new Set(addresses)];
}

function isLoopbackAddress(address) {
  return address === "127.0.0.1" || address === "::1" || address === "::ffff:127.0.0.1";
}
