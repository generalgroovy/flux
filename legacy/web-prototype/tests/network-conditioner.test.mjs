import test from "node:test";
import assert from "node:assert/strict";

import {
  conditionPacket,
  configurePacketConditioner,
  createPacketConditioner,
  drainPackets,
  isFreshServerTick,
  networkLabActive,
  normalizeNetworkLab,
} from "../src/network/conditioner.mjs";

test("network lab normalization is bounded and defaults to a zero-impact path", () => {
  assert.deepEqual(normalizeNetworkLab(), { latency: 0, jitter: 0, loss: 0 });
  assert.deepEqual(
    normalizeNetworkLab({ latency: 999, jitter: -3, loss: 90 }),
    { latency: 250, jitter: 0, loss: 20 },
  );
  assert.equal(networkLabActive({ latency: 0, jitter: 0, loss: 0 }), false);
  assert.equal(networkLabActive({ latency: 1 }), true);
});

test("seeded packet conditioning is reproducible, directional, and time ordered", () => {
  const config = { latency: 100, jitter: 40, loss: 12 };
  const left = createPacketConditioner(config, 73);
  const right = createPacketConditioner(config, 73);
  const leftResults = [];
  const rightResults = [];
  for (let sequence = 1; sequence <= 80; sequence += 1) {
    leftResults.push(conditionPacket(left, sequence % 2 ? "incoming" : "outgoing", { sequence }, 1_000));
    rightResults.push(conditionPacket(right, sequence % 2 ? "incoming" : "outgoing", { sequence }, 1_000));
  }
  assert.deepEqual(leftResults, rightResults);
  assert.ok(left.dropped > 0);
  assert.ok(left.queue.some((packet) => packet.dueAt < 1_100));
  assert.ok(left.queue.some((packet) => packet.dueAt > 1_100));
  assert.deepEqual(drainPackets(left, "incoming", 1_020), []);
  const delivered = drainPackets(left, "incoming", 1_200);
  assert.ok(delivered.length > 0);
  assert.ok(delivered.every((packet) => packet.sequence % 2 === 1));
  assert.ok(left.queue.every((packet) => packet.direction === "outgoing"));
});

test("reconfiguration clears queued impairment state for a clean match boundary", () => {
  const state = createPacketConditioner({ latency: 200 }, 1);
  conditionPacket(state, "outgoing", { sequence: 1 }, 0);
  assert.equal(state.queue.length, 1);
  configurePacketConditioner(state, { latency: 0, jitter: 0, loss: 0 });
  assert.equal(state.queue.length, 0);
  assert.equal(state.nextId, 1);
  assert.equal(state.enqueued, 0);
  const result = conditionPacket(state, "outgoing", { sequence: 2 }, 10);
  assert.equal(result.dropped, false);
  assert.equal(result.dueAt, 10);
  assert.deepEqual(drainPackets(state, "outgoing", 10), [{ sequence: 2 }]);
});

test("authoritative tick freshness rejects jitter-reordered snapshots", () => {
  assert.equal(isFreshServerTick(-1, 0), true);
  assert.equal(isFreshServerTick(40, 41), true);
  assert.equal(isFreshServerTick(40, 40), false);
  assert.equal(isFreshServerTick(40, 39), false);
  assert.equal(isFreshServerTick(40, Number.NaN), false);
});
