import { readdir, readFile, unlink } from "node:fs/promises";
import { resolve, join } from "node:path";
import { tmpdir } from "node:os";
import { fileURLToPath } from "node:url";

const root = resolve(fileURLToPath(new URL("../", import.meta.url)));
const registryDirectory = join(tmpdir(), "flux-arena-servers");
const requestedPort = argumentValue("--port");
const portFilter = requestedPort === undefined ? null : Number.parseInt(requestedPort, 10);

if (requestedPort !== undefined && (!Number.isInteger(portFilter) || portFilter < 1 || portFilter > 65535)) {
  throw new RangeError(`--port must be an integer from 1 to 65535; received ${requestedPort}`);
}

let entries = [];
try {
  entries = await readdir(registryDirectory);
} catch (error) {
  if (error?.code !== "ENOENT") throw error;
}

let stopped = 0;
let stale = 0;
for (const entry of entries.filter((name) => name.endsWith(".json"))) {
  const path = join(registryDirectory, entry);
  let record;
  try {
    record = JSON.parse(await readFile(path, "utf8"));
  } catch {
    await remove(path);
    stale += 1;
    continue;
  }
  if (record.product !== "FLUX" || resolve(String(record.root ?? "")) !== root) continue;
  if (portFilter !== null && record.port !== portFilter) continue;
  if (!Number.isInteger(record.pid) || !Number.isInteger(record.port)) {
    await remove(path);
    stale += 1;
    continue;
  }
  if (!(await isVerifiedFlux(record))) {
    await remove(path);
    stale += 1;
    continue;
  }
  try {
    process.kill(record.pid, "SIGTERM");
    await waitForStop(record);
    stopped += 1;
    console.log(`Stopped FLUX ${record.version ?? "unknown"} on port ${record.port} (PID ${record.pid}).`);
  } catch (error) {
    console.error(`Could not stop FLUX PID ${record.pid}: ${error.message}`);
    process.exitCode = 1;
  }
}

if (stopped === 0) console.log("No registered FLUX servers are running for this checkout.");
if (stale > 0) console.log(`Removed ${stale} stale FLUX server record${stale === 1 ? "" : "s"}.`);

async function isVerifiedFlux(record) {
  try {
    process.kill(record.pid, 0);
    const host = record.host === "0.0.0.0" || record.host === "::" ? "127.0.0.1" : record.host;
    const response = await fetch(`http://${host}:${record.port}/__flux_health`, {
      signal: AbortSignal.timeout(1_000),
    });
    const body = await response.json();
    return response.ok && body.product === "FLUX" && body.instance === record.instance;
  } catch {
    return false;
  }
}

async function waitForStop(record) {
  for (let attempt = 0; attempt < 40; attempt += 1) {
    await new Promise((resolveDelay) => setTimeout(resolveDelay, 50));
    if (!(await isVerifiedFlux(record))) return;
  }
  throw new Error("process did not exit within two seconds");
}

async function remove(path) {
  try {
    await unlink(path);
  } catch (error) {
    if (error?.code !== "ENOENT") throw error;
  }
}

function argumentValue(name) {
  const exactIndex = process.argv.indexOf(name);
  if (exactIndex >= 0) return process.argv[exactIndex + 1];
  const prefix = `${name}=`;
  const match = process.argv.find((argument) => argument.startsWith(prefix));
  return match?.slice(prefix.length);
}
