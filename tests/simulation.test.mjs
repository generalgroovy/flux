import test from "node:test";
import assert from "node:assert/strict";

import { CONFIG, validateConfig } from "../src/config.mjs";
import {
  circleIntersectsRectangle,
  createInitialState,
  formatTime,
  normalizeDirection,
  resolveCircleRectangle,
  segmentCircleHit,
  segmentIntersectsRectangle,
  stepSimulation,
} from "../src/simulation.mjs";

const idle = Object.freeze({
  moveX: 0,
  moveY: 0,
  aimX: 1,
  aimY: 0,
  fire: false,
  dash: false,
});

test("the shipped configuration is valid and deeply frozen", () => {
  assert.deepEqual(validateConfig(CONFIG), []);
  assert.equal(Object.isFrozen(CONFIG), true);
  assert.equal(Object.isFrozen(CONFIG.map.targets), true);

  const invalid = structuredClone(CONFIG);
  invalid.character.dash.cooldown = 0;
  assert.match(validateConfig(invalid).join(" "), /dash\.cooldown/);
});

test("diagonal movement is normalized to the configured maximum speed", () => {
  const state = createInitialState();
  for (let tick = 0; tick < 240; tick += 1) {
    stepSimulation(
      state,
      { ...idle, moveX: 1, moveY: 1 },
      1 / CONFIG.simulation.tickRate,
    );
  }

  assert.ok(
    Math.hypot(state.player.vx, state.player.vy) <=
      CONFIG.character.maxSpeed + 1e-6,
  );
  assert.deepEqual(normalizeDirection(0, 0), { x: 0, y: 0 });
});

test("movement decelerates to a stable stop without reversing", () => {
  const state = createInitialState();
  stepSimulation(state, { ...idle, moveX: 1 }, 0.1);
  for (let tick = 0; tick < 20; tick += 1) stepSimulation(state, idle, 0.1);

  assert.equal(state.player.vx, 0);
  assert.equal(state.player.vy, 0);
});

test("arena bounds contain the player and cancel outward velocity", () => {
  const state = createInitialState();
  state.player.x = CONFIG.arena.width;
  state.player.vx = 100;
  stepSimulation(state, { ...idle, moveX: 1 }, 1 / 60);

  assert.equal(
    state.player.x,
    CONFIG.arena.width - CONFIG.arena.inset - CONFIG.character.radius,
  );
  assert.equal(state.player.vx, 0);
});

test("cover resolves player overlap and blocks projectile-sized circles", () => {
  const rectangle = { x: 100, y: 100, width: 60, height: 100 };
  const player = { x: 95, y: 150, vx: 80, vy: 0 };
  assert.equal(resolveCircleRectangle(player, 20, rectangle), true);
  assert.equal(player.x, 80);
  assert.equal(player.vx, 0);
  assert.equal(
    circleIntersectsRectangle({ x: 105, y: 125 }, 4, rectangle),
    true,
  );
});

test("segment collision catches fast projectiles crossing a target", () => {
  assert.equal(segmentCircleHit(0, 0, 200, 0, 100, 0, 10), true);
  assert.equal(segmentCircleHit(0, 30, 200, 30, 100, 0, 10), false);
});

test("line segments identify cover between a sentry and its lock point", () => {
  const cover = { x: 90, y: 40, width: 20, height: 40 };
  assert.equal(segmentIntersectsRectangle(0, 50, 200, 50, cover), true);
  assert.equal(segmentIntersectsRectangle(0, 10, 200, 10, cover), false);
});

test("primary fire uses facing, emits a shot, and respects cooldown", () => {
  const state = createInitialState();
  const fire = { ...idle, aimX: 0, aimY: -1, fire: true };
  stepSimulation(state, fire, 1 / 120);

  assert.equal(state.projectiles.length, 1);
  assert.equal(state.projectiles[0].vx, 0);
  assert.ok(state.projectiles[0].vy < 0);
  assert.equal(state.events.some((event) => event.type === "shot"), true);

  stepSimulation(state, fire, 1 / 120);
  assert.equal(state.projectiles.length, 1);
});

test("a projectile damages and then destroys a configured target", () => {
  const config = structuredClone(CONFIG);
  config.map.obstacles = [];
  config.map.targets = [{ id: "test", x: 300, y: config.map.spawn.y }];
  const state = createInitialState(config);
  const fire = { ...idle, fire: true };

  for (let tick = 0; tick < 30; tick += 1) {
    stepSimulation(state, tick === 0 ? fire : idle, 1 / 120, config);
  }
  assert.equal(state.targets[0].health, CONFIG.target.health - CONFIG.character.weapon.damage);
  assert.equal(state.tutorial.hit, true);

  for (let tick = 0; tick < 60; tick += 1) {
    stepSimulation(state, tick === 0 ? fire : idle, 1 / 120, config);
  }
  assert.equal(state.targets[0].destroyed, true);
});

test("cover consumes projectiles before they reach a target", () => {
  const config = structuredClone(CONFIG);
  config.map.obstacles = [{ x: 240, y: 400, width: 40, height: 100 }];
  config.map.targets = [{ id: "safe", x: 330, y: config.map.spawn.y }];
  const state = createInitialState(config);
  stepSimulation(state, { ...idle, fire: true }, 1 / 120, config);
  for (let tick = 0; tick < 30; tick += 1) {
    stepSimulation(state, idle, 1 / 120, config);
  }

  assert.equal(state.projectiles.length, 0);
  assert.equal(state.targets[0].health, config.target.health);
});

test("dash moves immediately, emits feedback, and starts its cooldown", () => {
  const state = createInitialState();
  const startX = state.player.x;
  stepSimulation(state, { ...idle, moveX: 1, dash: true }, 1 / 120);

  assert.ok(state.player.x > startX);
  assert.equal(state.tutorial.dashed, true);
  assert.ok(state.player.dashCooldown > 0);
  assert.equal(state.events.some((event) => event.type === "dash"), true);
});

test("dash cannot retrigger while cooling down", () => {
  const state = createInitialState();
  stepSimulation(state, { ...idle, dash: true }, 1 / 120);
  const cooldown = state.player.dashCooldown;
  stepSimulation(state, { ...idle, dash: true }, 1 / 120);

  assert.ok(state.player.dashCooldown < cooldown);
  assert.equal(state.events.some((event) => event.type === "dash"), false);
});

test("clearing targets requires the taught dash before completing", () => {
  const state = createInitialState();
  for (const target of state.targets) {
    target.health = 0;
    target.destroyed = true;
  }
  stepSimulation(state, idle, 1 / 120);
  assert.equal(state.status, "playing");

  stepSimulation(state, { ...idle, dash: true }, 1 / 120);
  assert.equal(state.status, "complete");
  assert.equal(state.events.some((event) => event.type === "complete"), true);
});

test("the sentry telegraphs a locked position before dealing damage", () => {
  const config = structuredClone(CONFIG);
  config.map.obstacles = [];
  config.map.sentry = { x: 500, y: 450 };
  config.sentry.initialDelay = 0.1;
  config.sentry.telegraphDuration = 0.2;
  const state = createInitialState(config);
  state.started = true;

  stepSimulation(state, idle, 0.1, config);
  assert.equal(state.events.some((event) => event.type === "sentryWarning"), true);
  assert.equal(state.player.health, config.character.maxHealth);

  stepSimulation(state, idle, 0.2, config);
  assert.equal(state.events.some((event) => event.type === "sentryShot"), true);
  assert.equal(state.events.some((event) => event.type === "playerHit"), true);
  assert.equal(state.player.health, config.character.maxHealth - config.sentry.damage);
});

test("moving away from the locked point or using cover avoids sentry damage", () => {
  const config = structuredClone(CONFIG);
  config.map.sentry = { x: 500, y: 450 };
  config.sentry.initialDelay = 0.1;
  config.sentry.telegraphDuration = 0.2;
  const state = createInitialState(config);
  state.started = true;
  stepSimulation(state, idle, 0.1, config);
  state.player.y += 100;
  stepSimulation(state, idle, 0.2, config);
  assert.equal(state.player.health, config.character.maxHealth);

  const coveredConfig = structuredClone(config);
  coveredConfig.map.obstacles = [{ x: 300, y: 400, width: 40, height: 100 }];
  const covered = createInitialState(coveredConfig);
  covered.started = true;
  stepSimulation(covered, idle, 0.1, coveredConfig);
  stepSimulation(covered, idle, 0.2, coveredConfig);
  assert.equal(covered.player.health, coveredConfig.character.maxHealth);
  assert.equal(covered.events.find((event) => event.type === "sentryShot")?.blocked, true);
});

test("repeated readable sentry hits end the run and freeze simulation", () => {
  const config = structuredClone(CONFIG);
  config.map.obstacles = [];
  config.map.sentry = { x: 500, y: 450 };
  config.sentry.initialDelay = 0.01;
  config.sentry.telegraphDuration = 0.01;
  config.sentry.cooldown = 0.01;
  config.character.hitInvulnerability = 0.01;
  const state = createInitialState(config);
  state.started = true;
  for (let tick = 0; tick < 30 && state.status === "playing"; tick += 1) {
    stepSimulation(state, idle, 0.01, config);
  }

  assert.equal(state.status, "defeated");
  assert.equal(state.player.health, 0);
  const elapsed = state.elapsed;
  stepSimulation(state, { ...idle, moveX: 1, fire: true }, 1, config);
  assert.equal(state.elapsed, elapsed);
  assert.equal(state.projectiles.length, 0);
});

test("the timer waits for action and formatting is HUD-stable", () => {
  const state = createInitialState();
  stepSimulation(state, idle, 1);
  assert.equal(state.elapsed, 0);

  stepSimulation(state, { ...idle, fire: true }, 0.25);
  assert.equal(state.elapsed, 0.25);
  assert.equal(formatTime(8.456), "08.46");
  assert.equal(formatTime(Number.NaN), "00.00");
});
