import { spawn } from "node:child_process";
import { createHash } from "node:crypto";
import { chmod, mkdir, readFile, rename, stat, writeFile } from "node:fs/promises";
import { join } from "node:path";

const releaseApi = "https://api.github.com/repos/cloudflare/cloudflared/releases/latest";
const quickTunnelPattern = /https:\/\/[a-z0-9-]+\.trycloudflare\.com/i;

export function cloudflaredAssetName(platform = process.platform, arch = process.arch) {
  const suffix = arch === "x64" ? "amd64" : arch === "arm64" ? "arm64" : null;
  if (!suffix || !["linux", "win32"].includes(platform)) {
    throw new Error(`Friend hosting is not yet packaged for ${platform}/${arch}.`);
  }
  return platform === "win32"
    ? `cloudflared-windows-${suffix}.exe`
    : `cloudflared-linux-${suffix}`;
}

export function selectVerifiedAsset(release, assetName) {
  const asset = release?.assets?.find((candidate) => candidate.name === assetName);
  const digest = asset?.digest?.match(/^sha256:([a-f0-9]{64})$/i)?.[1]?.toLowerCase();
  if (!release?.tag_name || !asset?.browser_download_url || !digest) {
    throw new Error(`The official cloudflared release lacks a verified ${assetName} asset.`);
  }
  return {
    tag: String(release.tag_name).replace(/[^A-Za-z0-9._-]/g, ""),
    url: asset.browser_download_url,
    digest,
  };
}

export async function ensureCloudflared(cacheDirectory, {
  fetchImpl = globalThis.fetch,
  platform = process.platform,
  arch = process.arch,
} = {}) {
  const assetName = cloudflaredAssetName(platform, arch);
  const response = await fetchImpl(releaseApi, {
    headers: { Accept: "application/vnd.github+json", "User-Agent": "FLUX-Arena" },
  });
  if (!response.ok) throw new Error(`Could not check cloudflared releases (${response.status}).`);
  const asset = selectVerifiedAsset(await response.json(), assetName);
  const versionDirectory = join(cacheDirectory, asset.tag);
  const binaryPath = join(versionDirectory, platform === "win32" ? "cloudflared.exe" : "cloudflared");

  if (await verifiedFile(binaryPath, asset.digest)) return binaryPath;

  const binaryResponse = await fetchImpl(asset.url, { redirect: "follow" });
  if (!binaryResponse.ok) {
    throw new Error(`Could not download cloudflared (${binaryResponse.status}).`);
  }
  const bytes = Buffer.from(await binaryResponse.arrayBuffer());
  const receivedDigest = createHash("sha256").update(bytes).digest("hex");
  if (receivedDigest !== asset.digest) {
    throw new Error("Downloaded cloudflared failed its official SHA-256 check.");
  }

  await mkdir(versionDirectory, { recursive: true });
  const temporaryPath = `${binaryPath}.${process.pid}.tmp`;
  await writeFile(temporaryPath, bytes, { mode: 0o700 });
  await rename(temporaryPath, binaryPath);
  if (platform !== "win32") await chmod(binaryPath, 0o700);
  return binaryPath;
}

export async function startQuickTunnel(binaryPath, localOrigin, { timeoutMs = 30_000 } = {}) {
  const child = spawn(binaryPath, [
    "tunnel",
    "--no-autoupdate",
    "--protocol",
    "http2",
    "--url",
    localOrigin,
  ], {
    stdio: ["ignore", "pipe", "pipe"],
    windowsHide: true,
  });

  return new Promise((resolve, reject) => {
    let settled = false;
    let output = "";
    let tunnelOrigin = null;
    const timeout = setTimeout(() => finish(new Error("Friend tunnel did not become ready in time.")), timeoutMs);
    const inspect = (chunk) => {
      output = `${output}${chunk}`.slice(-16_384);
      const url = output.match(quickTunnelPattern)?.[0];
      if (url) tunnelOrigin = new URL(url).origin;
      if (tunnelOrigin && /Registered tunnel connection/i.test(output)) {
        finish(null, { child, origin: tunnelOrigin });
      }
    };
    const finish = (error, result) => {
      if (settled) return;
      settled = true;
      clearTimeout(timeout);
      child.stdout?.off("data", inspect);
      child.stderr?.off("data", inspect);
      child.off("error", onError);
      child.off("exit", onExit);
      if (error) {
        if (child.exitCode === null) child.kill("SIGTERM");
        reject(error);
      } else {
        // Keep both pipes flowing after URL discovery; cloudflared continues
        // logging and would eventually block on a full unread pipe.
        child.stdout?.resume();
        child.stderr?.resume();
        resolve(result);
      }
    };
    const onError = (error) => finish(error);
    const onExit = (code) => finish(new Error(`Friend tunnel exited before it was ready (${code ?? "unknown"}).`));
    child.stdout?.on("data", inspect);
    child.stderr?.on("data", inspect);
    child.once("error", onError);
    child.once("exit", onExit);
  });
}

async function verifiedFile(path, expectedDigest) {
  try {
    const metadata = await stat(path);
    if (!metadata.isFile()) return false;
    const digest = createHash("sha256").update(await readFile(path)).digest("hex");
    return digest === expectedDigest;
  } catch {
    return false;
  }
}
