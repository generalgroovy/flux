import test from "node:test";
import assert from "node:assert/strict";

import { CONFIG } from "../src/config.mjs";
import {
  collectCheckpoint,
  createInitialState,
  formatTime,
  normalizeDirection,
  stepSimulation,
} from "../src/simulation.mjs";

test("diagonal movement is normalized to the configured maximum speed", () => {
  const state = createInitialState();
  for (let tick = 0; tick < 240; tick += 1) {
    stepSimulation(state, { x: 1, y: 1 }, 1 / CONFIG.simulation.tickRate);
  }

  assert.ok(
    Math.hypot(state.player.vx, state.player.vy) <=
      CONFIG.player.maxSpeed + 1e-6,
  );
  assert.deepEqual(normalizeDirection(0, 0), { x: 0, y: 0 });
});

test("cardinal and diagonal movement accelerate at the same rate", () => {
  const cardinal = createInitialState();
  const diagonal = createInitialState();
  stepSimulation(cardinal, { x: 1, y: 0 }, 1 / 60);
  stepSimulation(diagonal, { x: 1, y: 1 }, 1 / 60);

  assert.ok(
    Math.abs(
      Math.hypot(cardinal.player.vx, cardinal.player.vy) -
        Math.hypot(diagonal.player.vx, diagonal.player.vy),
    ) < 1e-6,
  );
});

test("movement decelerates to a stable stop without reversing", () => {
  const state = createInitialState();
  stepSimulation(state, { x: 1, y: 0 }, 0.1);
  for (let tick = 0; tick < 20; tick += 1) {
    stepSimulation(state, { x: 0, y: 0 }, 0.1);
  }

  assert.equal(state.player.vx, 0);
  assert.equal(state.player.vy, 0);
});

test("arena bounds contain the player and cancel outward velocity", () => {
  const state = createInitialState();
  state.player.x = CONFIG.arena.width;
  state.player.vx = 100;
  stepSimulation(state, { x: 1, y: 0 }, 1 / 60);

  assert.equal(
    state.player.x,
    CONFIG.arena.width - CONFIG.arena.inset - CONFIG.player.radius,
  );
  assert.equal(state.player.vx, 0);
});

test("checkpoints must be collected in order and complete the trial", () => {
  const state = createInitialState();

  for (const checkpoint of CONFIG.checkpoints.positions) {
    state.player.x = checkpoint.x;
    state.player.y = checkpoint.y;
    assert.equal(collectCheckpoint(state), true);
  }

  assert.equal(state.checkpointIndex, CONFIG.checkpoints.positions.length);
  assert.equal(state.status, "complete");
});

test("timer formatting is stable for the HUD", () => {
  assert.equal(formatTime(0), "00.00");
  assert.equal(formatTime(8.456), "08.46");
  assert.equal(formatTime(Number.NaN), "00.00");
});

test("the run timer waits for the first movement input", () => {
  const state = createInitialState();
  stepSimulation(state, { x: 0, y: 0 }, 1);
  assert.equal(state.elapsed, 0);

  stepSimulation(state, { x: 1, y: 0 }, 0.25);
  assert.equal(state.elapsed, 0.25);
});
