import { CONFIG } from "./config.mjs";

const EPSILON = 1e-8;

export function createInitialState(config = CONFIG) {
  return {
    player: {
      x: config.map.spawn.x,
      y: config.map.spawn.y,
      vx: 0,
      vy: 0,
      facingX: 1,
      facingY: 0,
      fireCooldown: 0,
      dashCooldown: 0,
      dashRemaining: 0,
      dashX: 1,
      dashY: 0,
    },
    projectiles: [],
    targets: config.map.targets.map((target) => ({
      ...target,
      health: config.target.health,
      hitFlash: 0,
      destroyed: false,
    })),
    tutorial: {
      moved: false,
      fired: false,
      hit: false,
      dashed: false,
    },
    elapsed: 0,
    status: "playing",
    started: false,
    nextProjectileId: 1,
    events: [],
  };
}

export function normalizeDirection(x, y) {
  const magnitude = Math.hypot(x, y);
  if (magnitude <= EPSILON) return { x: 0, y: 0 };
  return { x: x / magnitude, y: y / magnitude };
}

export function stepSimulation(state, input, delta, config = CONFIG) {
  state.events = [];
  if (state.status !== "playing" || delta <= 0) return state;

  tickCooldowns(state, delta);
  const movement = normalizeDirection(input.moveX ?? input.x ?? 0, input.moveY ?? input.y ?? 0);
  const aim = normalizeDirection(input.aimX ?? 0, input.aimY ?? 0);
  const moving = movement.x !== 0 || movement.y !== 0;

  if (aim.x !== 0 || aim.y !== 0) {
    state.player.facingX = aim.x;
    state.player.facingY = aim.y;
  }

  if (moving) {
    state.tutorial.moved = true;
    state.started = true;
  }

  tryDash(state, input, movement, config);
  movePlayer(state, movement, delta, config);
  tryFire(state, input, config);
  updateProjectiles(state, delta, config);
  updateTargets(state, delta);
  updateCompletion(state);

  if (state.started) state.elapsed += delta;
  return state;
}

function tickCooldowns(state, delta) {
  state.player.fireCooldown = Math.max(0, state.player.fireCooldown - delta);
  state.player.dashCooldown = Math.max(0, state.player.dashCooldown - delta);
}

function tryDash(state, input, movement, config) {
  if (!input.dash || state.player.dashCooldown > 0 || state.player.dashRemaining > 0) {
    return;
  }

  const direction =
    movement.x !== 0 || movement.y !== 0
      ? movement
      : { x: state.player.facingX, y: state.player.facingY };
  state.player.dashX = direction.x;
  state.player.dashY = direction.y;
  state.player.dashRemaining = config.character.dash.duration;
  state.player.dashCooldown = config.character.dash.cooldown;
  state.tutorial.dashed = true;
  state.started = true;
  state.events.push({ type: "dash", x: state.player.x, y: state.player.y });
}

function movePlayer(state, movement, delta, config) {
  const player = state.player;
  if (player.dashRemaining > 0) {
    player.vx = player.dashX * config.character.dash.speed;
    player.vy = player.dashY * config.character.dash.speed;
    player.dashRemaining = Math.max(0, player.dashRemaining - delta);
  } else {
    const rate = movement.x !== 0 || movement.y !== 0
      ? config.character.acceleration
      : config.character.deceleration;
    approachVelocity(
      player,
      movement.x * config.character.maxSpeed,
      movement.y * config.character.maxSpeed,
      rate * delta,
    );
  }

  player.x += player.vx * delta;
  player.y += player.vy * delta;
  constrainPlayer(player, config);
  for (const obstacle of config.map.obstacles) {
    resolveCircleRectangle(player, config.character.radius, obstacle);
  }
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

function tryFire(state, input, config) {
  if (!input.fire || state.player.fireCooldown > 0) return;

  const player = state.player;
  const weapon = config.character.weapon;
  const projectile = {
    id: state.nextProjectileId,
    x: player.x + player.facingX * weapon.spawnOffset,
    y: player.y + player.facingY * weapon.spawnOffset,
    previousX: player.x,
    previousY: player.y,
    vx: player.facingX * weapon.projectileSpeed,
    vy: player.facingY * weapon.projectileSpeed,
    lifetime: weapon.projectileLifetime,
    radius: weapon.projectileRadius,
  };
  state.nextProjectileId += 1;
  state.projectiles.push(projectile);
  player.fireCooldown = weapon.cooldown;
  state.tutorial.fired = true;
  state.started = true;
  state.events.push({
    type: "shot",
    x: projectile.x,
    y: projectile.y,
    dx: player.facingX,
    dy: player.facingY,
  });
}

function updateProjectiles(state, delta, config) {
  const survivors = [];

  for (const projectile of state.projectiles) {
    projectile.previousX = projectile.x;
    projectile.previousY = projectile.y;
    projectile.x += projectile.vx * delta;
    projectile.y += projectile.vy * delta;
    projectile.lifetime -= delta;

    if (
      projectile.lifetime <= 0 ||
      projectile.x < config.arena.inset ||
      projectile.x > config.arena.width - config.arena.inset ||
      projectile.y < config.arena.inset ||
      projectile.y > config.arena.height - config.arena.inset
    ) {
      continue;
    }

    const blocked = config.map.obstacles.some((obstacle) =>
      circleIntersectsRectangle(projectile, projectile.radius, obstacle),
    );
    if (blocked) {
      state.events.push({ type: "blocked", x: projectile.x, y: projectile.y });
      continue;
    }

    const target = state.targets.find(
      (candidate) =>
        !candidate.destroyed &&
        segmentCircleHit(
          projectile.previousX,
          projectile.previousY,
          projectile.x,
          projectile.y,
          candidate.x,
          candidate.y,
          config.target.radius + projectile.radius,
        ),
    );
    if (target) {
      target.health = Math.max(0, target.health - config.character.weapon.damage);
      target.hitFlash = config.target.hitFlashDuration;
      state.tutorial.hit = true;
      state.events.push({
        type: "hit",
        x: target.x,
        y: target.y,
        targetId: target.id,
        damage: config.character.weapon.damage,
      });
      if (target.health === 0) {
        target.destroyed = true;
        state.events.push({
          type: "destroyed",
          x: target.x,
          y: target.y,
          targetId: target.id,
        });
      }
      continue;
    }

    survivors.push(projectile);
  }

  state.projectiles = survivors;
}

function updateTargets(state, delta) {
  for (const target of state.targets) {
    target.hitFlash = Math.max(0, target.hitFlash - delta);
  }
}

function updateCompletion(state) {
  if (state.targets.every((target) => target.destroyed) && state.tutorial.dashed) {
    state.status = "complete";
    state.player.vx = 0;
    state.player.vy = 0;
    state.events.push({ type: "complete" });
  }
}

export function constrainPlayer(player, config = CONFIG) {
  const radius = config.character.radius;
  const minX = config.arena.inset + radius;
  const maxX = config.arena.width - config.arena.inset - radius;
  const minY = config.arena.inset + radius;
  const maxY = config.arena.height - config.arena.inset - radius;

  if (player.x < minX || player.x > maxX) {
    player.x = Math.max(minX, Math.min(maxX, player.x));
    player.vx = 0;
  }
  if (player.y < minY || player.y > maxY) {
    player.y = Math.max(minY, Math.min(maxY, player.y));
    player.vy = 0;
  }
}

export function resolveCircleRectangle(circle, radius, rectangle) {
  const closestX = Math.max(rectangle.x, Math.min(circle.x, rectangle.x + rectangle.width));
  const closestY = Math.max(rectangle.y, Math.min(circle.y, rectangle.y + rectangle.height));
  const dx = circle.x - closestX;
  const dy = circle.y - closestY;
  const distance = Math.hypot(dx, dy);

  if (distance >= radius) return false;
  if (distance > EPSILON) {
    const overlap = radius - distance;
    const nx = dx / distance;
    const ny = dy / distance;
    circle.x += nx * overlap;
    circle.y += ny * overlap;
    const intoSurface = circle.vx * nx + circle.vy * ny;
    if (intoSurface < 0) {
      circle.vx -= intoSurface * nx;
      circle.vy -= intoSurface * ny;
    }
    return true;
  }

  const exits = [
    { distance: Math.abs(circle.x - rectangle.x), x: rectangle.x - radius, axis: "x" },
    {
      distance: Math.abs(rectangle.x + rectangle.width - circle.x),
      x: rectangle.x + rectangle.width + radius,
      axis: "x",
    },
    { distance: Math.abs(circle.y - rectangle.y), y: rectangle.y - radius, axis: "y" },
    {
      distance: Math.abs(rectangle.y + rectangle.height - circle.y),
      y: rectangle.y + rectangle.height + radius,
      axis: "y",
    },
  ];
  const nearest = exits.reduce((best, exit) => (exit.distance < best.distance ? exit : best));
  if (nearest.axis === "x") {
    circle.x = nearest.x;
    circle.vx = 0;
  } else {
    circle.y = nearest.y;
    circle.vy = 0;
  }
  return true;
}

export function circleIntersectsRectangle(circle, radius, rectangle) {
  const closestX = Math.max(rectangle.x, Math.min(circle.x, rectangle.x + rectangle.width));
  const closestY = Math.max(rectangle.y, Math.min(circle.y, rectangle.y + rectangle.height));
  return Math.hypot(circle.x - closestX, circle.y - closestY) <= radius;
}

export function segmentCircleHit(x1, y1, x2, y2, cx, cy, radius) {
  const dx = x2 - x1;
  const dy = y2 - y1;
  const lengthSquared = dx * dx + dy * dy;
  if (lengthSquared <= EPSILON) return Math.hypot(x1 - cx, y1 - cy) <= radius;
  const projection = Math.max(
    0,
    Math.min(1, ((cx - x1) * dx + (cy - y1) * dy) / lengthSquared),
  );
  const closestX = x1 + dx * projection;
  const closestY = y1 + dy * projection;
  return Math.hypot(closestX - cx, closestY - cy) <= radius;
}

export function formatTime(seconds) {
  const safeSeconds = Math.max(0, Number.isFinite(seconds) ? seconds : 0);
  return safeSeconds.toFixed(2).padStart(5, "0");
}
