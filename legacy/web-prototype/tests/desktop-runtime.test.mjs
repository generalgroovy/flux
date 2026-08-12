import test from "node:test";
import assert from "node:assert/strict";

import {
  desktopGameUrl,
  isTrustedGameUrl,
  parseDesktopInvite,
  reserveLoopbackPort,
  waitForFlux,
} from "../desktop/runtime.mjs";

test("desktop runtime reserves a valid loopback port", async () => {
  const port = await reserveLoopbackPort();
  assert.ok(Number.isInteger(port));
  assert.ok(port > 0 && port <= 65_535);
});

test("desktop invite parsing accepts only HTTPS servers and bounded lobby codes", () => {
  assert.deepEqual(parseDesktopInvite([
    "--flag",
    "flux://join?server=https%3A%2F%2Fbright-rune.trycloudflare.com&code=abc234",
  ]), {
    server: "https://bright-rune.trycloudflare.com",
    code: "ABC234",
  });
  assert.equal(parseDesktopInvite([
    "flux://join?server=http%3A%2F%2Fattacker.example&code=ABC234",
  ]), null);
  assert.equal(parseDesktopInvite([
    "flux://join?server=https%3A%2F%2Fexample.com&code=TOO-LONG",
  ]), null);
});

test("desktop navigation remains inside its exact local authority origin", () => {
  const origin = "http://127.0.0.1:8123";
  assert.equal(isTrustedGameUrl(`${origin}/?desktop=1`, origin), true);
  assert.equal(isTrustedGameUrl("http://127.0.0.1:8124/", origin), false);
  assert.equal(isTrustedGameUrl("https://example.com/", origin), false);
  assert.equal(isTrustedGameUrl("javascript:alert(1)", origin), false);
  assert.equal(isTrustedGameUrl("not a URL", origin), false);
});

test("desktop launch URL exposes only bounded launch intent", () => {
  assert.equal(
    desktopGameUrl("http://127.0.0.1:8123"),
    "http://127.0.0.1:8123/?desktop=1",
  );
  assert.equal(
    desktopGameUrl("http://127.0.0.1:8123", {
      friends: true,
      publicOrigin: "https://bright-rune.trycloudflare.com/path",
    }),
    "http://127.0.0.1:8123/?desktop=1&friends=1&server=https%3A%2F%2Fbright-rune.trycloudflare.com",
  );
});

test("desktop readiness accepts only the FLUX protocol contract", async () => {
  let calls = 0;
  const health = await waitForFlux("http://127.0.0.1:8123", {
    attempts: 2,
    delayMs: 0,
    fetchImpl: async () => {
      calls += 1;
      return {
        ok: true,
        json: async () => calls === 1
          ? { product: "OTHER", status: "ready", protocol: 2 }
          : { product: "FLUX", status: "ready", protocol: 2, version: "0.34.3" },
      };
    },
  });
  assert.equal(calls, 2);
  assert.equal(health.product, "FLUX");
});

test("desktop readiness rejects a spoofed loopback authority token", async () => {
  await assert.rejects(
    waitForFlux("http://127.0.0.1:8123", {
      attempts: 1,
      delayMs: 0,
      desktopToken: "expected",
      fetchImpl: async () => ({
        ok: true,
        json: async () => ({
          product: "FLUX",
          status: "ready",
          protocol: 2,
          desktopToken: "spoofed",
        }),
      }),
    }),
    /did not become ready/,
  );
});
