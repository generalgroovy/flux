import test from "node:test";
import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { createServer } from "node:net";

const WINDOWS_FORCED_TERMINATION_EXIT = 1;

test("server cleanup stops only a registered FLUX server", { timeout: 8_000 }, async (t) => {
  const port = await freePort();
  const child = spawn(process.execPath, ["scripts/serve.mjs", `--port=${port}`], {
    cwd: new URL("../", import.meta.url),
    stdio: ["ignore", "pipe", "pipe"],
  });
  t.after(() => {
    if (child.exitCode === null) child.kill("SIGTERM");
  });
  await waitForHealth(port);
  const cleanup = spawn(process.execPath, ["scripts/stop-servers.mjs", `--port=${port}`], {
    cwd: new URL("../", import.meta.url),
    stdio: ["ignore", "pipe", "pipe"],
  });
  let output = "";
  cleanup.stdout.on("data", (chunk) => { output += chunk; });
  cleanup.stderr.on("data", (chunk) => { output += chunk; });
  const cleanupCode = await new Promise((resolve) => cleanup.once("exit", resolve));
  assert.equal(cleanupCode, 0, output);
  assert.match(output, new RegExp(`Stopped FLUX .* port ${port}`));
  const childCode = child.exitCode ?? await new Promise((resolve) => child.once("exit", resolve));
  const expectedChildCode = process.platform === "win32"
    ? WINDOWS_FORCED_TERMINATION_EXIT
    : 0;
  assert.equal(childCode, expectedChildCode);
  await assert.rejects(fetch(`http://127.0.0.1:${port}/__flux_health`));
});

async function freePort() {
  const server = createServer();
  await new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", resolve);
  });
  const { port } = server.address();
  await new Promise((resolve) => server.close(resolve));
  return port;
}

async function waitForHealth(port) {
  for (let attempt = 0; attempt < 80; attempt += 1) {
    try {
      const response = await fetch(`http://127.0.0.1:${port}/__flux_health`);
      if (response.ok) return;
    } catch {
      // Bounded startup race.
    }
    await new Promise((resolve) => setTimeout(resolve, 25));
  }
  throw new Error("FLUX server did not become ready");
}
