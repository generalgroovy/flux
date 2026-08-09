import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

test("desktop shell keeps renderer privilege and process cleanup narrowly bounded", async () => {
  const source = await readFile(new URL("../desktop/main.mjs", import.meta.url), "utf8");
  assert.match(source, /contextIsolation:\s*true/);
  assert.match(source, /nodeIntegration:\s*false/);
  assert.match(source, /sandbox:\s*true/);
  assert.match(source, /webSecurity:\s*true/);
  assert.match(source, /fullscreen:\s*true/);
  assert.match(source, /leave-full-screen/);
  assert.match(source, /mainWindow\.setFullScreen\(true\)/);
  assert.match(source, /setInterval\(enforceFullscreen,\s*1_000\)/);
  assert.match(source, /clearInterval\(fullscreenGuard\)/);
  assert.match(source, /setWindowOpenHandler\(\(\) => \(\{ action: "deny" \}\)\)/);
  assert.match(source, /will-attach-webview/);
  assert.match(source, /permission === "clipboard-sanitized-write"/);
  assert.match(source, /stopOwnedChild\(authority/);
  assert.match(source, /gracefulMessage: \{ type: "shutdown" \}/);
  assert.doesNotMatch(source, /pkill|taskkill|systemctl|killall|shell\.openExternal/);
});

test("downloaded friend transport requires digest verification before execution", async () => {
  const source = await readFile(new URL("../desktop/tunnel.mjs", import.meta.url), "utf8");
  assert.match(source, /asset\?\.digest\?\.match\(\/\^sha256:/);
  assert.match(source, /receivedDigest !== asset\.digest/);
  assert.match(source, /mode: 0o700/);
  assert.doesNotMatch(source, /shell:\s*true/);
});

test("Windows launcher bypasses the unsigned PowerShell npm shim", async () => {
  const source = await readFile(new URL("../scripts/pull-and-run.ps1", import.meta.url), "utf8");
  assert.match(source, /Get-Command \$tool/);
  assert.match(source, /"npm\.cmd"/);
  assert.doesNotMatch(source, /& npm\s/);
});
