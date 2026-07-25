import { CONFIG } from "./config.mjs";

const EPSILON = 1e-8;

export function createInitialState(config = CONFIG) {
  return {
    player: {
      x: config.arena.inset + 90,
      y: config.arena.height / 2,
      vx: 0,
      vy: 0,
    },
    checkpointIndex: 0,
    elapsed: 0,
    status: "playing",
    movementStarted: false,
  };
}

export function normalizeDirection(x, y) {
  const magnitude = Math.hypot(x, y);
  if (magnitude <= EPSILON) return { x: 0, y: 0 };
  return { x: x / magnitude, y: y / magnitude };
}

export function stepSimulation(state, input, delta, config = CONFIG) {
  if (state.status !== "playing" || delta <= 0) return state;

  const direction = normalizeDirection(input.x, input.y);
  const moving = direction.x !== 0 || direction.y !== 0;
  const rate = moving ? config.player.acceleration : config.player.deceleration;
  const targetVx = direction.x * config.player.maxSpeed;
  const targetVy = direction.y * config.player.maxSpeed;
  approachVelocity(state.player, targetVx, targetVy, rate * delta);

  state.player.x += state.player.vx * delta;
  state.player.y += state.player.vy * delta;
  constrainPlayer(state.player, config);

  state.movementStarted ||= moving;
  if (state.movementStarted) state.elapsed += delta;
  collectCheckpoint(state, config);
  return state;
}

function approachVelocity(player, targetVx, targetVy, maxDelta) {
  const deltaVx = targetVx - player.vx;
  const deltaVy = targetVy - player.vy;
  const distance = Math.hypot(deltaVx, deltaVy);
  if (distance <= maxDelta || distance <= EPSILON) {
    player.vx = targetVx;
    player.vy = targetVy;
    return;
  }

  player.vx += (deltaVx / distance) * maxDelta;
  player.vy += (deltaVy / distance) * maxDelta;
}

export function constrainPlayer(player, config = CONFIG) {
  const minX = config.arena.inset + config.player.radius;
  const maxX = config.arena.width - config.arena.inset - config.player.radius;
  const minY = config.arena.inset + config.player.radius;
  const maxY = config.arena.height - config.arena.inset - config.player.radius;

  if (player.x < minX || player.x > maxX) {
    player.x = Math.max(minX, Math.min(maxX, player.x));
    player.vx = 0;
  }
  if (player.y < minY || player.y > maxY) {
    player.y = Math.max(minY, Math.min(maxY, player.y));
    player.vy = 0;
  }
}

export function collectCheckpoint(state, config = CONFIG) {
  const checkpoint = config.checkpoints.positions[state.checkpointIndex];
  if (!checkpoint) return false;

  const collectDistance = config.player.radius + config.checkpoints.radius;
  if (
    Math.hypot(state.player.x - checkpoint.x, state.player.y - checkpoint.y) >
    collectDistance
  ) {
    return false;
  }

  state.checkpointIndex += 1;
  if (state.checkpointIndex === config.checkpoints.positions.length) {
    state.status = "complete";
    state.player.vx = 0;
    state.player.vy = 0;
  }
  return true;
}

export function formatTime(seconds) {
  const safeSeconds = Math.max(0, Number.isFinite(seconds) ? seconds : 0);
  return safeSeconds.toFixed(2).padStart(5, "0");
}
