import test from "node:test";
import assert from "node:assert/strict";

import { createLobbyInvite, remoteServerFromHint } from "../src/network/invite.mjs";

test("desktop invites retain only HTTPS origin and bounded lobby identity", () => {
  assert.equal(
    createLobbyInvite("https://bright-rune.trycloudflare.com/path", "abc234", { desktop: true }),
    "flux://join?server=https%3A%2F%2Fbright-rune.trycloudflare.com&code=ABC234",
  );
  assert.equal(
    remoteServerFromHint("https://bright-rune.trycloudflare.com/path?ignored=1"),
    "https://bright-rune.trycloudflare.com",
  );
  assert.equal(remoteServerFromHint("http://remote.example"), null);
  assert.equal(remoteServerFromHint("javascript:alert(1)"), null);
  assert.throws(() => createLobbyInvite("https://example.com", "BAD-01", { desktop: true }));
});

test("legacy local hosting retains a browser-compatible invite", () => {
  assert.equal(
    createLobbyInvite("http://127.0.0.1:8000", "ABC234", { desktop: true }),
    "http://127.0.0.1:8000/?join=ABC234",
  );
});
