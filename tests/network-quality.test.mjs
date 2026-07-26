import test from "node:test";
import assert from "node:assert/strict";

import {
  NETWORK_PROBE_TIMEOUT_MS,
  beginNetworkProbe,
  createNetworkDiagnostics,
  expireNetworkProbes,
  receiveNetworkProbe,
  summarizeNetworkDiagnostics,
} from "../src/network-quality.mjs";

test("network diagnostics report measured RTT and stable quality", () => {
  const state = createNetworkDiagnostics();
  for (let index = 0; index < 4; index += 1) {
    const sentAt = index * 1_000;
    const sequence = beginNetworkProbe(state, sentAt);
    assert.equal(receiveNetworkProbe(state, sequence, sentAt + 32 + index * 2), true);
  }
  const summary = summarizeNetworkDiagnostics(state);
  assert.equal(summary.quality, "good");
  assert.equal(Math.round(summary.rtt), 35);
  assert.equal(Math.round(summary.jitter), 2);
  assert.equal(summary.loss, 0);
});

test("expired probes become bounded recent loss and degrade quality", () => {
  const state = createNetworkDiagnostics();
  const first = beginNetworkProbe(state, 0);
  receiveNetworkProbe(state, first, 60);
  beginNetworkProbe(state, 1_000);
  expireNetworkProbes(state, 1_000 + NETWORK_PROBE_TIMEOUT_MS);
  const summary = summarizeNetworkDiagnostics(state);
  assert.equal(summary.loss, 50);
  assert.equal(summary.quality, "poor");
  assert.equal(receiveNetworkProbe(state, 2, 4_000), false);
});
