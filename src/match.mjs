import {
  CHARACTERS,
  MATCH_TUNING,
  getCharacter,
  getMap,
  getMode,
  getRace,
} from "./content.mjs";

const EPSILON = 1e-8;
const IDLE_COMMAND = Object.freeze({
  moveX: 0,
  moveY: 0,
  aimX: 1,
  aimY: 0,
  fire: false,
  special: false,
  defend: false,
  mobility: false,
  sprint: false,
  hop: false,
  ultimate: false,
});

export function createMatch(options = {}) {
  const mode = getMode(options.modeId);
  const map = getMap(options.mapId);
  const seed = finiteInteger(options.seed, 1);
  const playerSpecs =
    Array.isArray(options.players) && options.players.length > 0
      ? options.players
      : [
          {
            id: "p1",
            name: "PLAYER 1",
            characterId: options.characterId ?? "kite",
            team: "alpha",
            human: true,
            localSlot: 0,
          },
        ];
  const entities = [];
  for (const [index, spec] of playerSpecs.entries()) {
    entities.push(createEntity(spec, index, map));
  }

  const requestedBots = Number.isInteger(options.botCount)
    ? clamp(options.botCount, 0, 7)
    : mode.botCount;
  const humanTeams = new Set(entities.map((entity) => entity.team));
  for (let index = 0; index < requestedBots; index += 1) {
    const team =
      mode.id === "survival"
        ? "beta"
        : humanTeams.size === 1 && humanTeams.has("alpha")
          ? "beta"
          : index % 2 === 0
            ? "beta"
            : "alpha";
    entities.push(
      createEntity(
        {
          id: `bot-${index + 1}`,
          name: `SPAR ${index + 1}`,
          characterId:
            options.botCharacterIds?.[index] ??
            CHARACTERS[(index + 1) % CHARACTERS.length].id,
          team,
          bot: true,
        },
        entities.length,
        map,
      ),
    );
  }

  const neutralCount = mode.neutralCount ?? 0;
  for (let index = 0; index < neutralCount; index += 1) {
    entities.push(
      createEntity(
        {
          id: `neutral-${index + 1}`,
          name: `WARD ${index + 1}`,
          characterId: index % 2 === 0 ? "bulwark" : "rook",
          team: "neutral",
          bot: true,
          neutral: true,
        },
        entities.length,
        map,
      ),
    );
  }

  const state = {
    version: 2,
    seed,
    tick: 0,
    elapsed: 0,
    status: "playing",
    modeId: mode.id,
    mapId: map.id,
    entities,
    projectiles: [],
    mines: [],
    elementFields: [],
    decoys: [],
    shrines: (map.shrines ?? []).map((shrine) => ({
      ...shrine,
      readyIn: 0,
      insideIds: [],
    })),
    hazards: (options.hazardsEnabled === false ? [] : map.hazards).map((hazard) => ({
      ...hazard,
      phase: "cooldown",
      remaining: hazard.initial,
      hitIds: [],
    })),
    score: { alpha: 0, beta: 0 },
    rules: { hazardsEnabled: options.hazardsEnabled !== false },
    round: 1,
    roundRemaining: 0,
    winner: null,
    objective: {
      controllingTeam: null,
      contested: false,
      progress: { alpha: 0, beta: 0 },
    },
    tutorial: {
      skipped: mode.id !== "training",
      step: mode.id === "training" ? 0 : 4,
      sprinted: false,
      hopped: false,
      slid: false,
      moved: false,
      fired: false,
      mobility: false,
      defended: false,
      special: false,
    },
    overtime: false,
    survival: {
      wave: 1,
    },
    nextProjectileId: 1,
    nextMineId: 1,
    nextElementFieldId: 1,
    events: [],
  };
  state.events.push({ type: "matchStart", modeId: mode.id, mapId: map.id });
  return state;
}

function createEntity(spec, index, map) {
  const agent = getCharacter(spec.characterId);
  const race = getRace(spec.raceId);
  const maxHealth = Math.round(agent.health * race.health);
  const maxFlow = MATCH_TUNING.flow.maximum * race.flow;
  const maxFlux = MATCH_TUNING.flux.maximum * race.flux;
  const spawnIndex = finiteInteger(spec.spawnIndex, index) % map.spawns.length;
  const spawn = map.spawns[(spawnIndex + map.spawns.length) % map.spawns.length];
  const facingX = spawn.x < map.size.width / 2 ? 1 : -1;
  return {
    id: String(spec.id ?? `player-${index + 1}`),
    clientId: spec.clientId ? String(spec.clientId) : null,
    name: cleanName(spec.name ?? `PLAYER ${index + 1}`),
    characterId: agent.id,
    raceId: race.id,
    speedScale: race.speed,
    team: spec.team === "beta" || spec.team === "neutral" ? spec.team : "alpha",
    human: spec.human === true,
    bot: spec.bot === true,
    neutral: spec.neutral === true,
    localSlot: Number.isInteger(spec.localSlot) ? spec.localSlot : null,
    spawnIndex,
    x: spawn.x,
    y: spawn.y,
    lastSafeX: spawn.x,
    lastSafeY: spawn.y,
    vx: 0,
    vy: 0,
    facingX,
    facingY: 0,
    health: maxHealth,
    maxHealth,
    alive: true,
    respawnRemaining: 0,
    spawnProtection: MATCH_TUNING.spawnProtection,
    damageInvulnerability: 0,
    hitFlash: 0,
    primaryCooldown: 0,
    specialCooldown: 0,
    defenseCooldown: 0,
    defenseRemaining: 0,
    mobilityCooldown: 0,
    mobilityRemaining: 0,
    mobilityX: facingX,
    mobilityY: 0,
    passiveRemaining: 0,
    passiveActive: false,
    passiveCueCooldown: 0,
    ultimateCharge: 0,
    maxUltimate: agent.ultimate?.chargeRequired ?? 0,
    ultimateWindupRemaining: 0,
    ultimateResolvePending: false,
    ultimateAimX: facingX,
    ultimateAimY: 0,
    ultimateTargetX: spawn.x,
    ultimateTargetY: spawn.y,
    flow: maxFlow,
    maxFlow,
    flowRecoveryDelay: 0,
    sprinting: false,
    hopCooldown: 0,
    hopRemaining: 0,
    landingRemaining: 0,
    hopX: facingX,
    hopY: 0,
    hopCarryX: 0,
    hopCarryY: 0,
    hopWallKick: false,
    slideCooldown: 0,
    slideRemaining: 0,
    slideX: facingX,
    slideY: 0,
    wallContactRemaining: 0,
    wallX: 0,
    wallY: 0,
    flux: maxFlux,
    maxFlux,
    fluxRecoveryDelay: 0,
    fluxWarningCooldown: 0,
    counterStrafeCooldown: 0,
    surface: "normal",
    elementForceX: 0,
    elementForceY: 0,
    interruptRemaining: 0,
    dashHitIds: [],
    kills: 0,
    deaths: 0,
    lives: 3,
    lastAttackerId: null,
    botThinkRemaining: 0,
    botCommand: { ...IDLE_COMMAND },
  };
}

export function addMatchPlayer(state, spec = {}) {
  if (!state || state.status === "match-over") return null;
  const map = getMap(state.mapId);
  const usedIds = new Set(state.entities.map((entity) => entity.id));
  const baseId = String(spec.id ?? `player-${state.entities.length + 1}`);
  let id = baseId;
  let suffix = 2;
  while (usedIds.has(id)) {
    id = `${baseId}-${suffix}`;
    suffix += 1;
  }
  const alphaCount = state.entities.filter(
    (entity) => entity.team === "alpha" && !entity.neutral,
  ).length;
  const betaCount = state.entities.filter(
    (entity) => entity.team === "beta" && !entity.neutral,
  ).length;
  const entity = createEntity(
    {
      ...spec,
      id,
      human: true,
      bot: false,
      team: spec.team ?? (alphaCount <= betaCount ? "alpha" : "beta"),
      spawnIndex: state.entities.length,
    },
    state.entities.length,
    map,
  );
  state.entities.push(entity);
  state.events.push({ type: "playerJoined", entityId: entity.id });
  return entity;
}

export function removeMatchPlayer(state, entityId) {
  const entity = state.entities.find((candidate) => candidate.id === entityId);
  if (!entity) return false;
  state.entities = state.entities.filter((candidate) => candidate !== entity);
  state.projectiles = state.projectiles.filter(
    (projectile) => projectile.ownerId !== entityId,
  );
  state.mines = state.mines.filter((mine) => mine.ownerId !== entityId);
  state.events.push({ type: "playerLeft", entityId });
  return true;
}

export function sanitizeCommand(candidate) {
  const source = candidate && typeof candidate === "object" ? candidate : {};
  const move = normalizeDirection(source.moveX, source.moveY);
  const rawAim = normalizeDirection(source.aimX, source.aimY);
  return {
    moveX: move.x,
    moveY: move.y,
    aimX: rawAim.x,
    aimY: rawAim.y,
    fire: source.fire === true,
    special: source.special === true,
    defend: source.defend === true,
    mobility: source.mobility === true,
    sprint: source.sprint === true,
    hop: source.hop === true,
    ultimate: source.ultimate === true,
  };
}

export function stepMatch(
  state,
  commands = {},
  delta = 1 / MATCH_TUNING.tickRate,
) {
  state.events = [];
  if (
    state.status === "match-over" ||
    !Number.isFinite(delta) ||
    delta <= 0
  ) {
    return state;
  }
  const boundedDelta = Math.min(delta, MATCH_TUNING.maxFrameDelta);
  const mode = getMode(state.modeId);
  const map = getMap(state.mapId);
  state.tick += 1;

  if (state.status === "round-over") {
    state.roundRemaining = Math.max(0, state.roundRemaining - boundedDelta);
    if (state.roundRemaining === 0) resetRound(state, map, mode);
    return state;
  }

  for (const entity of state.entities) tickEntity(entity, boundedDelta);
  updateElementFields(state, boundedDelta);
  updateDecoys(state, boundedDelta);
  const activeMap = withElementGeometry(map, state.elementFields);
  for (const entity of state.entities) {
    if (!entity.alive) {
      updateRespawn(state, entity, boundedDelta, map, mode);
      continue;
    }
    const command = entity.bot
      ? updateBotCommand(state, entity, boundedDelta, map)
      : sanitizeCommand(commands[entity.id]);
    updateEntity(state, entity, command, boundedDelta, activeMap);
  }

  resolveUnitCollisions(state, activeMap);
  resolveMapCollisions(state, activeMap);
  updateShrines(state, boundedDelta);
  updateMines(state, boundedDelta, activeMap);
  updateProjectiles(state, boundedDelta, activeMap);
  updateHazards(state, boundedDelta);
  updateObjective(state, boundedDelta, mode, map);
  updateTutorial(state, commands);
  updateMatchClock(state, boundedDelta, mode);
  repairState(state, map);
  return state;
}

function updateShrines(state, delta) {
  for (const shrine of state.shrines ?? []) {
    shrine.readyIn = Math.max(0, shrine.readyIn - delta);
    const previous = new Set(shrine.insideIds);
    const inside = [];
    for (const entity of state.entities) {
      if (!entity.alive || entity.neutral) continue;
      const radius = getCharacter(entity.characterId).radius;
      const inCircle = Math.hypot(entity.x - shrine.x, entity.y - shrine.y) <= shrine.radius + radius;
      if (!inCircle) continue;
      inside.push(entity.id);
      const speed = Math.hypot(entity.vx, entity.vy);
      if (
        shrine.readyIn > 0 || previous.has(entity.id) ||
        speed < shrine.speedRequired ||
        entity.flux > entity.maxFlux - Math.min(12, shrine.fluxReward)
      ) continue;
      const restored = Math.min(shrine.fluxReward, entity.maxFlux - entity.flux);
      entity.flux += restored;
      entity.fluxRecoveryDelay = MATCH_TUNING.flux.recoveryDelay;
      shrine.readyIn = shrine.cooldown;
      state.events.push({
        type: "shrineClaim", shrineId: shrine.id, entityId: entity.id,
        team: entity.team, amount: restored, x: shrine.x, y: shrine.y,
      });
      break;
    }
    shrine.insideIds = inside;
  }
}

function tickEntity(entity, delta) {
  const wasHopping = entity.hopRemaining > 0;
  const wasWindingUltimate = entity.ultimateWindupRemaining > 0;
  for (const key of [
    "primaryCooldown",
    "specialCooldown",
    "defenseCooldown",
    "defenseRemaining",
    "mobilityCooldown",
    "mobilityRemaining",
    "damageInvulnerability",
    "spawnProtection",
    "hitFlash",
    "flowRecoveryDelay",
    "hopCooldown",
    "hopRemaining",
    "landingRemaining",
    "slideCooldown",
    "slideRemaining",
    "wallContactRemaining",
    "interruptRemaining",
    "fluxRecoveryDelay",
    "fluxWarningCooldown",
    "counterStrafeCooldown",
    "passiveRemaining",
    "passiveCueCooldown",
    "ultimateWindupRemaining",
  ]) {
    entity[key] = Math.max(0, finite(entity[key]) - delta);
  }
  if (wasHopping && entity.hopRemaining === 0) {
    entity.landingRemaining = MATCH_TUNING.flow.landingWindow;
  }
  if (wasWindingUltimate && entity.ultimateWindupRemaining === 0) {
    entity.ultimateResolvePending = true;
  }
  entity.flow = clamp(entity.flow, 0, entity.maxFlow);
  entity.flux = clamp(entity.flux, 0, entity.maxFlux);
  if (entity.fluxRecoveryDelay === 0) {
    entity.flux = Math.min(
      entity.maxFlux,
      entity.flux + MATCH_TUNING.flux.recoveryPerSecond * delta,
    );
  }
}

function updateEntity(state, entity, command, delta, map) {
  const agent = getCharacter(entity.characterId);
  if (entity.interruptRemaining > 0) {
    if (entity.ultimateWindupRemaining > 0 || entity.ultimateResolvePending) {
      entity.ultimateWindupRemaining = 0;
      entity.ultimateResolvePending = false;
      state.events.push({
        type: "ultimateInterrupted",
        entityId: entity.id,
        name: agent.ultimate?.name ?? "ULTIMATE",
        x: entity.x,
        y: entity.y,
      });
    }
    moveEntity(state, entity, IDLE_COMMAND, agent, delta, map);
    return;
  }
  if (entity.ultimateResolvePending) {
    resolveUltimate(state, entity, agent, map);
    entity.ultimateResolvePending = false;
    moveEntity(state, entity, IDLE_COMMAND, agent, delta, map);
    return;
  }
  if (entity.ultimateWindupRemaining > 0) {
    moveEntity(
      state,
      entity,
      { ...command, sprint: false, hop: false },
      agent,
      delta,
      map,
    );
    return;
  }
  if (command.aimX !== 0 || command.aimY !== 0) {
    entity.facingX = command.aimX;
    entity.facingY = command.aimY;
  }
  if (entity.human && (command.moveX !== 0 || command.moveY !== 0)) {
    state.tutorial.moved = true;
  }
  if (tryStartUltimate(state, entity, command, agent, map)) {
    moveEntity(
      state,
      entity,
      { ...command, sprint: false, hop: false },
      agent,
      delta,
      map,
    );
    return;
  }

  if (
    command.mobility &&
    entity.mobilityCooldown === 0 &&
    spendFlux(state, entity, agent.mobility)
  ) {
    startMobility(state, entity, command, agent, map);
  }
  if (!command.mobility && !trySlide(state, entity, command)) {
    tryHop(state, entity, command);
  }
  moveEntity(state, entity, command, agent, delta, map);
  if (
    command.defend &&
    entity.defenseCooldown === 0 &&
    spendFlux(state, entity, agent.defense)
  ) {
    entity.defenseRemaining = agent.defense.duration;
    entity.defenseCooldown = agent.defense.cooldown;
    if (entity.human) state.tutorial.defended = true;
    state.events.push({
      type: "defense",
      entityId: entity.id,
      kind: agent.defense.kind,
      x: entity.x,
      y: entity.y,
    });
  }
  if (
    command.special &&
    entity.specialCooldown === 0 &&
    spendFlux(state, entity, agent.special)
  ) {
    useSpecial(state, entity, agent, map);
    if (entity.human) state.tutorial.special = true;
  }
  if (command.fire && entity.primaryCooldown === 0) {
    let primary = agent.primary;
    if (agent.passive?.kind === "movement-prime" && entity.passiveRemaining > 0) {
      primary = {
        ...primary,
        speed: primary.speed * agent.passive.speedMultiplier,
        spread: primary.spread * agent.passive.spreadMultiplier,
      };
      entity.passiveRemaining = 0;
      state.events.push({
        type: "passiveSpent",
        entityId: entity.id,
        name: agent.passive.name,
        x: entity.x,
        y: entity.y,
      });
    } else if (agent.passive?.kind === "reflect-guide" && entity.passiveRemaining > 0) {
      primary = {
        ...primary,
        speed: primary.speed * agent.passive.speedMultiplier,
        guidedBy: entity.id,
        guidedRemaining: agent.passive.guideDuration,
        turnRate: agent.passive.turnRate,
      };
      entity.passiveRemaining = 0;
      state.events.push({
        type: "passiveGuided",
        entityId: entity.id,
        name: agent.passive.name,
        x: entity.x,
        y: entity.y,
      });
    } else if (agent.passive?.kind === "field-temper" && entity.passiveActive) {
      primary = {
        ...primary,
        speed: primary.speed * agent.passive.speedMultiplier,
        radius: primary.radius * agent.passive.radiusMultiplier,
        knockback: primary.knockback * agent.passive.knockbackMultiplier,
        heavy: true,
      };
      if (entity.passiveCueCooldown === 0) {
        entity.passiveCueCooldown = 0.7;
        state.events.push({
          type: "passiveConverted",
          entityId: entity.id,
          name: agent.passive.name,
          x: entity.x,
          y: entity.y,
        });
      }
    }
    firePattern(state, entity, primary, "primary");
    entity.primaryCooldown = agent.primary.cooldown;
    if (entity.human) state.tutorial.fired = true;
  }
}

function trySlide(state, entity, command) {
  const wantsSlide = command.sprint && command.hop &&
    (command.moveX !== 0 || command.moveY !== 0);
  if (!wantsSlide) return false;
  if (
    entity.slideCooldown > 0 || entity.slideRemaining > 0 ||
    entity.hopRemaining > 0 || entity.mobilityRemaining > 0 ||
    entity.flow < MATCH_TUNING.flow.slideCost ||
    Math.hypot(entity.vx, entity.vy) < MATCH_TUNING.flow.slideEntrySpeed
  ) return true;
  const direction = normalizeDirection(command.moveX, command.moveY);
  entity.flow -= MATCH_TUNING.flow.slideCost;
  entity.flowRecoveryDelay = MATCH_TUNING.flow.recoveryDelay;
  entity.slideCooldown = MATCH_TUNING.flow.slideCooldown;
  entity.slideRemaining = MATCH_TUNING.flow.slideDuration;
  entity.slideX = direction.x;
  entity.slideY = direction.y;
  entity.sprinting = false;
  state.tutorial.sprinted ||= entity.human;
  state.tutorial.slid ||= entity.human;
  state.events.push({
    type: "slide", entityId: entity.id,
    x: entity.x, y: entity.y, dx: direction.x, dy: direction.y,
  });
  return true;
}

function spendFlux(state, entity, ability) {
  const cost = ability.fluxCost ?? 0;
  if (entity.flux < cost) {
    if (entity.fluxWarningCooldown === 0) {
      entity.fluxWarningCooldown = MATCH_TUNING.flux.dryCueCooldown;
      state.events.push({
        type: "fluxDry",
        entityId: entity.id,
        required: cost,
        available: entity.flux,
        x: entity.x,
        y: entity.y,
      });
    }
    return false;
  }
  entity.flux -= cost;
  entity.fluxRecoveryDelay = MATCH_TUNING.flux.recoveryDelay;
  state.events.push({
    type: "fluxSpend",
    entityId: entity.id,
    amount: cost,
    x: entity.x,
    y: entity.y,
  });
  return true;
}

function startMobility(state, entity, command, agent, map) {
  const mobility = agent.mobility;
  let direction =
    command.moveX !== 0 || command.moveY !== 0
      ? { x: command.moveX, y: command.moveY }
      : { x: entity.facingX, y: entity.facingY };
  if (mobility.kind === "recoil") {
    direction = { x: -entity.facingX, y: -entity.facingY };
  }
  direction = normalizeDirection(direction.x, direction.y);
  if (direction.x === 0 && direction.y === 0) direction = { x: 1, y: 0 };
  entity.mobilityCooldown = mobility.cooldown;
  entity.mobilityX = direction.x;
  entity.mobilityY = direction.y;
  entity.dashHitIds = [];
  if (entity.human) state.tutorial.mobility = true;

  if (mobility.kind === "blink") {
    const result = moveCircleSwept(
      entity,
      direction.x * mobility.distance,
      direction.y * mobility.distance,
      agent.radius,
      map,
    );
    entity.vx = 0;
    entity.vy = 0;
    state.events.push({
      type: result.hitWall ? "blinkBlocked" : "blink",
      entityId: entity.id,
      x: entity.x,
      y: entity.y,
    });
    return;
  }

  entity.mobilityRemaining = mobility.duration;
  state.events.push({
    type: "mobility",
    entityId: entity.id,
    kind: mobility.kind,
    x: entity.x,
    y: entity.y,
  });
}

function tryHop(state, entity, command) {
  const flow = MATCH_TUNING.flow;
  if (
    !command.hop ||
    entity.hopCooldown > 0 ||
    entity.hopRemaining > 0 ||
    entity.slideRemaining > 0 ||
    entity.mobilityRemaining > 0 ||
    entity.flow < flow.hopCost
  ) {
    return;
  }
  let direction =
    command.moveX !== 0 || command.moveY !== 0
      ? { x: command.moveX, y: command.moveY }
      : { x: entity.facingX, y: entity.facingY };
  const wallKick = entity.wallContactRemaining > 0;
  if (wallKick) {
    const wallDot = direction.x * entity.wallX + direction.y * entity.wallY;
    const tangentX = direction.x - entity.wallX * wallDot;
    const tangentY = direction.y - entity.wallY * wallDot;
    direction = normalizeDirection(
      entity.wallX + tangentX * 0.72,
      entity.wallY + tangentY * 0.72,
    );
  }
  direction = normalizeDirection(direction.x, direction.y);
  if (direction.x === 0 && direction.y === 0) direction = { x: entity.facingX, y: entity.facingY };
  entity.flow -= flow.hopCost;
  entity.flowRecoveryDelay = flow.recoveryDelay;
  entity.hopCooldown = flow.hopCooldown;
  entity.hopRemaining = flow.hopDuration;
  entity.hopX = direction.x;
  entity.hopY = direction.y;
  const along = entity.vx * direction.x + entity.vy * direction.y;
  const lateralX = entity.vx - direction.x * along;
  const lateralY = entity.vy - direction.y * along;
  const lateralSpeed = Math.hypot(lateralX, lateralY);
  const carryScale = lateralSpeed > EPSILON
    ? Math.min(
        MATCH_TUNING.flow.hopMomentumCarry,
        MATCH_TUNING.flow.hopCarryLimit / lateralSpeed,
      )
    : 0;
  entity.hopCarryX = lateralX * carryScale;
  entity.hopCarryY = lateralY * carryScale;
  entity.hopWallKick = wallKick;
  entity.wallContactRemaining = 0;
  entity.sprinting = false;
  state.tutorial.hopped ||= entity.human;
  state.events.push({
    type: wallKick ? "wallKick" : "hop",
    entityId: entity.id,
    x: entity.x,
    y: entity.y,
    dx: direction.x,
    dy: direction.y,
  });
  if (wallKick) {
    primeMovementPassive(
      state,
      entity,
      getCharacter(entity.characterId),
      "WALL KICK",
    );
  }
}

function moveEntity(state, entity, command, agent, delta, map) {
  let moveX = command.moveX;
  let moveY = command.moveY;
  if (entity.mobilityRemaining > 0) {
    entity.vx = entity.mobilityX * agent.mobility.speed;
    entity.vy = entity.mobilityY * agent.mobility.speed;
    entity.sprinting = false;
  } else if (entity.slideRemaining > 0) {
    if (moveX !== 0 || moveY !== 0) {
      const steering = MATCH_TUNING.flow.slideSteering;
      const direction = normalizeDirection(
        entity.slideX * (1 - steering) + moveX * steering,
        entity.slideY * (1 - steering) + moveY * steering,
      );
      entity.slideX = direction.x;
      entity.slideY = direction.y;
    }
    entity.vx = entity.slideX * MATCH_TUNING.flow.slideSpeed;
    entity.vy = entity.slideY * MATCH_TUNING.flow.slideSpeed;
    entity.sprinting = false;
  } else if (entity.hopRemaining > 0) {
    const speed = entity.hopWallKick
      ? MATCH_TUNING.flow.wallKickSpeed
      : MATCH_TUNING.flow.hopSpeed;
    entity.vx = entity.hopX * speed + entity.hopCarryX;
    entity.vy = entity.hopY * speed + entity.hopCarryY;
    entity.sprinting = false;
  } else {
    const moving = moveX !== 0 || moveY !== 0;
    const sprinting = command.sprint && moving && entity.flow > 0;
    const speed =
      agent.speed * entity.speedScale *
      (sprinting ? MATCH_TUNING.flow.sprintMultiplier : 1) *
      (entity.ultimateWindupRemaining > 0 ? agent.ultimate.moveScale : 1);
    const desiredX = moveX * speed + entity.elementForceX;
    const desiredY = moveY * speed + entity.elementForceY;
    const currentSpeed = Math.hypot(entity.vx, entity.vy);
    const opposing = moving && currentSpeed > EPSILON
      ? (entity.vx * moveX + entity.vy * moveY) / currentSpeed < -0.55
      : false;
    const rate =
      (moving ? agent.acceleration : agent.deceleration) *
      (entity.surface === "ice" ? MATCH_TUNING.elements.iceControl : 1) *
      (opposing ? MATCH_TUNING.flow.counterStrafeMultiplier : 1) *
      (opposing && entity.landingRemaining > 0
        ? MATCH_TUNING.flow.landingCutMultiplier
        : 1);
    const landingCut = opposing && entity.landingRemaining > 0;
    if (landingCut) {
      entity.landingRemaining = 0;
      state.events.push({ type: "landingCut", entityId: entity.id, x: entity.x, y: entity.y });
      primeMovementPassive(state, entity, agent, "LANDING CUT");
    }
    if (
      opposing && currentSpeed >= MATCH_TUNING.flow.counterStrafeCueSpeed &&
      entity.counterStrafeCooldown === 0
    ) {
      entity.counterStrafeCooldown = MATCH_TUNING.flow.counterStrafeCueCooldown;
      state.events.push({ type: "counterStrafe", entityId: entity.id, x: entity.x, y: entity.y });
    }
    approachVelocity(entity, desiredX, desiredY, rate * delta);
    entity.sprinting = sprinting;
    if (sprinting) {
      entity.flow = Math.max(0, entity.flow - MATCH_TUNING.flow.sprintDrainPerSecond * delta);
      entity.flowRecoveryDelay = MATCH_TUNING.flow.recoveryDelay;
      state.tutorial.sprinted ||= entity.human;
    } else if (entity.flowRecoveryDelay === 0) {
      entity.flow = Math.min(
        entity.maxFlow,
        entity.flow + MATCH_TUNING.flow.recoveryPerSecond * delta,
      );
    }
  }

  const result = moveCircleSwept(
    entity,
    entity.vx * delta,
    entity.vy * delta,
    agent.radius,
    map,
  );
  if (result.hitWall) {
    entity.wallContactRemaining = MATCH_TUNING.flow.wallMemory;
    entity.wallX = result.wallX;
    entity.wallY = result.wallY;
  }
  if (result.hitWall && entity.mobilityRemaining > 0) {
    entity.mobilityRemaining = 0;
    entity.vx = 0;
    entity.vy = 0;
    state.events.push({
      type: "dashImpact",
      entityId: entity.id,
      x: entity.x,
      y: entity.y,
    });
  } else if (result.hitWall && entity.slideRemaining > 0) {
    entity.slideRemaining = 0;
    entity.vx = 0;
    entity.vy = 0;
    state.events.push({ type: "slideImpact", entityId: entity.id, x: entity.x, y: entity.y });
  }
}

export function moveCircleSwept(circle, dx, dy, radius, map) {
  const safeDx = finite(dx);
  const safeDy = finite(dy);
  const distance = Math.hypot(safeDx, safeDy);
  const steps = clamp(
    Math.ceil(distance / Math.max(radius * 0.42, 1)),
    1,
    MATCH_TUNING.maxMoveSubsteps,
  );
  const stepX = safeDx / steps;
  const stepY = safeDy / steps;
  let hitWall = false;
  let wallX = 0;
  let wallY = 0;

  for (let step = 0; step < steps; step += 1) {
    const beforeX = circle.x;
    const beforeY = circle.y;
    circle.x += stepX;
    circle.y += stepY;
    constrainCircle(circle, radius, map.size);
    if (circle.x !== beforeX + stepX || circle.y !== beforeY + stepY) {
      const correction = normalizeDirection(
        circle.x - (beforeX + stepX),
        circle.y - (beforeY + stepY),
      );
      wallX = correction.x;
      wallY = correction.y;
      hitWall = true;
    }
    for (let pass = 0; pass < 3; pass += 1) {
      let collided = false;
      for (const obstacle of map.obstacles) {
        collided = resolveCircleRectangle(circle, radius, obstacle) || collided;
      }
      if (!collided) break;
      hitWall = true;
      const correction = normalizeDirection(
        circle.x - (beforeX + stepX),
        circle.y - (beforeY + stepY),
      );
      if (correction.x !== 0 || correction.y !== 0) {
        wallX = correction.x;
        wallY = correction.y;
      }
    }
    constrainCircle(circle, radius, map.size);
    if (!Number.isFinite(circle.x) || !Number.isFinite(circle.y)) {
      circle.x = Number.isFinite(beforeX) ? beforeX : map.spawns[0].x;
      circle.y = Number.isFinite(beforeY) ? beforeY : map.spawns[0].y;
      hitWall = true;
      break;
    }
  }
  return { hitWall, wallX, wallY };
}

function createElementField(state, owner, element, spec, announce = true) {
  const field = {
    id: `element-${state.nextElementFieldId}`,
    ownerId: owner.id,
    team: owner.team,
    element,
    pulseRemaining: 0,
    ...spec,
  };
  state.nextElementFieldId += 1;
  state.elementFields.push(field);
  if (announce) {
    state.events.push({
      type: "elementField",
      fieldId: field.id,
      element,
      x: spec.x,
      y: spec.y,
    });
  }
}

function primeMovementPassive(state, entity, agent, trigger) {
  if (agent.passive?.kind !== "movement-prime") return;
  entity.passiveRemaining = agent.passive.duration;
  state.events.push({
    type: "passivePrimed",
    entityId: entity.id,
    name: agent.passive.name,
    trigger,
    x: entity.x,
    y: entity.y,
  });
}

function primeReflectPassive(state, entity) {
  const passive = getCharacter(entity.characterId).passive;
  if (passive?.kind !== "reflect-guide") return;
  entity.passiveRemaining = passive.duration;
  state.events.push({
    type: "passivePrimed",
    entityId: entity.id,
    name: passive.name,
    trigger: "SPELL TURN",
    x: entity.x,
    y: entity.y,
  });
}

function tryStartUltimate(state, entity, command, agent, map) {
  const ultimate = agent.ultimate;
  if (
    !command.ultimate || !ultimate ||
    entity.ultimateCharge < ultimate.chargeRequired ||
    entity.ultimateWindupRemaining > 0 || entity.ultimateResolvePending ||
    entity.mobilityRemaining > 0 || entity.slideRemaining > 0 ||
    entity.hopRemaining > 0 || entity.defenseRemaining > 0
  ) {
    return false;
  }
  entity.ultimateCharge = 0;
  entity.ultimateWindupRemaining = ultimate.windup;
  entity.ultimateAimX = entity.facingX;
  entity.ultimateAimY = entity.facingY;
  if (["field-crown", "wind-vortex"].includes(ultimate.kind)) {
    const target = clippedRayEnd(entity, ultimate.targetRange, map);
    entity.ultimateTargetX = target.x;
    entity.ultimateTargetY = target.y;
  } else {
    entity.ultimateTargetX = entity.x;
    entity.ultimateTargetY = entity.y;
  }
  entity.sprinting = false;
  state.events.push({
    type: "ultimateTell",
    entityId: entity.id,
    name: ultimate.name,
    duration: ultimate.windup,
    x: entity.x,
    y: entity.y,
    dx: entity.ultimateAimX,
    dy: entity.ultimateAimY,
    targetX: entity.ultimateTargetX,
    targetY: entity.ultimateTargetY,
    kind: ultimate.kind,
  });
  return true;
}

function resolveUltimate(state, entity, agent, map) {
  const ultimate = agent.ultimate;
  if (!ultimate) return;
  entity.facingX = entity.ultimateAimX;
  entity.facingY = entity.ultimateAimY;
  let end = { x: entity.ultimateTargetX, y: entity.ultimateTargetY };
  if (ultimate.kind === "line-volley") {
    end = clippedRayEnd(entity, ultimate.range, map);
    for (let index = 0; index < ultimate.fieldCount; index += 1) {
      const fraction = (index + 1) / ultimate.fieldCount;
      createElementField(
        state,
        entity,
        "ice",
        {
          x: entity.x + (end.x - entity.x) * fraction,
          y: entity.y + (end.y - entity.y) * fraction,
          radius: ultimate.fieldRadius,
          duration: ultimate.fieldDuration,
          directionX: entity.ultimateAimX,
          directionY: entity.ultimateAimY,
          source: "ultimate",
        },
        false,
      );
    }
    firePattern(state, entity, ultimate, "ultimate");
  } else if (ultimate.kind === "field-crown") {
    for (let index = 0; index < ultimate.fieldCount; index += 1) {
      const angle = (index / ultimate.fieldCount) * Math.PI * 2;
      createElementField(
        state,
        entity,
        "fire",
        {
          x: end.x + Math.cos(angle) * ultimate.crownRadius,
          y: end.y + Math.sin(angle) * ultimate.crownRadius,
          radius: ultimate.fieldRadius,
          duration: ultimate.fieldDuration,
          source: "ultimate",
        },
        false,
      );
    }
  } else if (ultimate.kind === "wind-vortex") {
    createElementField(
      state,
      entity,
      "wind",
      {
        x: end.x,
        y: end.y,
        radius: ultimate.fieldRadius,
        duration: ultimate.fieldDuration,
        shape: "vortex",
        spin: ultimate.spin,
        directionX: 0,
        directionY: 0,
        source: "ultimate",
      },
      false,
    );
  }
  state.events.push({
    type: "ultimateCast",
    entityId: entity.id,
    name: ultimate.name,
    x: entity.x,
    y: entity.y,
    endX: end.x,
    endY: end.y,
    kind: ultimate.kind,
    element: agent.affinity.id,
  });
}

function withElementGeometry(map, fields) {
  const earth = fields
    .filter((field) => field.element === "earth")
    .map((field) => ({
      x: field.x,
      y: field.y,
      width: field.width,
      height: field.height,
    }));
  if (earth.length === 0) return map;
  return { ...map, obstacles: [...map.obstacles, ...earth] };
}

function windDirectionAt(field, x, y) {
  if (field.shape !== "vortex") {
    return normalizeDirection(field.directionX, field.directionY);
  }
  let radial = normalizeDirection(x - field.x, y - field.y);
  if (radial.x === 0 && radial.y === 0) radial = { x: 1, y: 0 };
  const spin = field.spin === -1 ? -1 : 1;
  return { x: -radial.y * spin, y: radial.x * spin };
}

function updateElementFields(state, delta) {
  for (const entity of state.entities) {
    entity.surface = "normal";
    entity.elementForceX = 0;
    entity.elementForceY = 0;
    entity.passiveActive = false;
  }
  for (const field of state.elementFields) {
    field.duration -= delta;
    field.pulseRemaining = Math.max(0, field.pulseRemaining - delta);
  }
  const waterFields = state.elementFields.filter(
    (field) => field.element === "water" && field.duration > 0,
  );
  const removed = new Set();
  const overlaps = (left, right) =>
    Math.hypot(left.x - right.x, left.y - right.y) <=
    (left.radius ?? 0) + (right.radius ?? 0);
  for (const wind of state.elementFields.filter((field) => field.element === "wind")) {
    for (const fire of state.elementFields.filter((field) => field.element === "fire")) {
      if (!overlaps(wind, fire)) continue;
      const direction = windDirectionAt(wind, fire.x, fire.y);
      const speed = wind.shape === "vortex"
        ? MATCH_TUNING.elements.vortexFireSpeed
        : MATCH_TUNING.elements.windForce * 0.32;
      fire.x += direction.x * speed * delta;
      fire.y += direction.y * speed * delta;
    }
  }
  for (const fire of state.elementFields.filter((field) => field.element === "fire")) {
    for (const ice of state.elementFields.filter((field) => field.element === "ice")) {
      if (removed.has(fire.id) || removed.has(ice.id) || !overlaps(fire, ice)) continue;
      removed.add(fire.id);
      removed.add(ice.id);
      state.events.push({ type: "elementReaction", reaction: "melt", x: ice.x, y: ice.y });
    }
  }
  for (const water of waterFields) {
    for (const ice of state.elementFields.filter((field) => field.element === "ice")) {
      if (removed.has(water.id) || removed.has(ice.id) || !overlaps(water, ice)) continue;
      removed.add(water.id);
      ice.duration = Math.min(
        MATCH_TUNING.elements.iceDuration * 1.35,
        ice.duration + water.duration * 0.5,
      );
      state.events.push({ type: "elementReaction", reaction: "freeze", x: water.x, y: water.y });
    }
  }
  state.elementFields = state.elementFields.filter((field) => {
    if (removed.has(field.id)) return false;
    if (field.duration <= 0) {
      state.events.push({ type: "elementClear", fieldId: field.id, element: field.element });
      return false;
    }
    if (
      field.element === "fire" &&
      waterFields.some((water) => {
        const distance = Math.hypot(water.x - field.x, water.y - field.y);
        if (distance > water.radius + field.radius) return false;
        if (
          Number.isFinite(water.directionX) &&
          Number.isFinite(water.directionY) &&
          (water.directionX !== 0 || water.directionY !== 0) &&
          distance > field.radius * 0.25
        ) {
          field.x += water.directionX * water.radius * 0.72;
          field.y += water.directionY * water.radius * 0.72;
          field.duration *= 0.58;
          state.events.push({
            type: "elementReaction",
            reaction: "redirect",
            x: field.x,
            y: field.y,
          });
          return false;
        }
        return true;
      })
    ) {
      state.events.push({
        type: "elementReaction",
        reaction: "douse",
        x: field.x,
        y: field.y,
      });
      return false;
    }
    return true;
  });
  for (const field of state.elementFields) {
    if (field.element === "earth") continue;
    for (const entity of state.entities) {
      if (
        !entity.alive ||
        Math.hypot(entity.x - field.x, entity.y - field.y) >
          field.radius + getCharacter(entity.characterId).radius
      ) {
        continue;
      }
      if (field.element === "ice") entity.surface = "ice";
      if (
        field.element === "fire" && field.team === entity.team &&
        getCharacter(entity.characterId).passive?.kind === "field-temper"
      ) {
        entity.passiveActive = true;
      }
      if (field.element === "wind") {
        const direction = windDirectionAt(field, entity.x, entity.y);
        const force = field.shape === "vortex"
          ? MATCH_TUNING.elements.vortexMoveForce
          : MATCH_TUNING.elements.windForce;
        entity.elementForceX += direction.x * force;
        entity.elementForceY += direction.y * force;
      }
      if (field.element === "water" && entity.team === field.team) {
        entity.flow = Math.min(
          entity.maxFlow,
          entity.flow + MATCH_TUNING.elements.waterFlowPerSecond * delta,
        );
        entity.interruptRemaining = 0;
      }
      if (
        field.element === "fire" &&
        hostileTeams(field.team, entity.team) &&
        field.pulseRemaining === 0
      ) {
        const owner = state.entities.find((candidate) => candidate.id === field.ownerId);
        damageEntity(state, entity, MATCH_TUNING.elements.fireDamage, owner, {
          source: field.source === "ultimate" ? "ultimate" : "fire",
        });
      }
    }
    if (field.element === "fire" && field.pulseRemaining === 0) {
      field.pulseRemaining = MATCH_TUNING.elements.firePulse;
    }
  }
}

function updateDecoys(state, delta) {
  for (const decoy of state.decoys) decoy.duration -= delta;
  state.decoys = state.decoys.filter((decoy) => decoy.duration > 0);
}

function useSpecial(state, entity, agent, map) {
  const special = agent.special;
  entity.specialCooldown = special.cooldown;
  state.events.push({
    type: "special",
    entityId: entity.id,
    kind: special.kind,
    x: entity.x,
    y: entity.y,
  });
  if (special.kind === "trail") {
    const end = clippedRayEnd(entity, special.range, map);
    for (let index = 0; index < special.fieldCount; index += 1) {
      const fraction = (index + 1) / special.fieldCount;
      createElementField(
        state,
        entity,
        "fire",
        {
          x: entity.x + (end.x - entity.x) * fraction,
          y: entity.y + (end.y - entity.y) * fraction,
          radius: special.fieldRadius,
          duration: special.fieldDuration,
          directionX: entity.facingX,
          directionY: entity.facingY,
          source: "tactical",
        },
        index === 0,
      );
    }
  } else if (special.kind === "cone") {
    for (const target of opponentsOf(state, entity)) {
      const offsetX = target.x - entity.x;
      const offsetY = target.y - entity.y;
      const distance = Math.hypot(offsetX, offsetY);
      const direction = normalizeDirection(offsetX, offsetY);
      const dot =
        direction.x * entity.facingX + direction.y * entity.facingY;
      if (
        distance <= special.range + getCharacter(target.characterId).radius &&
        dot >= Math.cos(special.halfAngle)
      ) {
        damageEntity(state, target, special.damage, entity, {
          source: "special",
          knockback: special.knockback,
          direction,
        });
      }
    }
    if (agent.affinity.id === "wind") {
      createElementField(state, entity, "wind", {
        x: entity.x + entity.facingX * special.range * 0.72,
        y: entity.y + entity.facingY * special.range * 0.72,
        radius: MATCH_TUNING.elements.windRadius,
        duration: MATCH_TUNING.elements.windDuration,
        directionX: entity.facingX,
        directionY: entity.facingY,
      });
    } else if (agent.affinity.id === "earth") {
      const length = MATCH_TUNING.elements.earthLength;
      const thickness = MATCH_TUNING.elements.earthThickness;
      const centerX = entity.x + entity.facingX * (special.range + thickness) * 0.58;
      const centerY = entity.y + entity.facingY * (special.range + thickness) * 0.58;
      const wall = {
        x: centerX - Math.abs(entity.facingY) * length / 2 - Math.abs(entity.facingX) * thickness / 2,
        y: centerY - Math.abs(entity.facingX) * length / 2 - Math.abs(entity.facingY) * thickness / 2,
        width: Math.abs(entity.facingY) * length + Math.abs(entity.facingX) * thickness,
        height: Math.abs(entity.facingX) * length + Math.abs(entity.facingY) * thickness,
        duration: MATCH_TUNING.elements.earthDuration,
      };
      const blocked = map.obstacles.some((obstacle) =>
        rectanglesOverlap(wall, obstacle, 42),
      ) || state.entities.some((candidate) =>
        candidate.alive &&
        circleRectangleOverlap(
          candidate,
          getCharacter(candidate.characterId).radius + 4,
          wall,
        ),
      );
      if (!blocked) createElementField(state, entity, "earth", wall);
    } else if (agent.affinity.id === "ice") {
      createElementField(state, entity, "ice", {
        x: entity.x + entity.facingX * special.range * 0.68,
        y: entity.y + entity.facingY * special.range * 0.68,
        radius: MATCH_TUNING.elements.iceRadius,
        duration: MATCH_TUNING.elements.iceDuration,
        directionX: entity.facingX,
        directionY: entity.facingY,
      });
    }
  } else if (special.kind === "blast") {
    damageRadius(state, entity, special.range, special.damage, special.knockback);
    if (agent.affinity.id === "veil") {
      const existing = state.decoys.find((decoy) => decoy.ownerId === entity.id);
      if (existing) {
        const beforeX = entity.x;
        const beforeY = entity.y;
        entity.x = existing.x;
        entity.y = existing.y;
        existing.x = beforeX;
        existing.y = beforeY;
        state.decoys = state.decoys.filter((decoy) => decoy !== existing);
        state.events.push({ type: "veilSwap", entityId: entity.id, x: entity.x, y: entity.y });
      } else {
        state.decoys.push({
          id: `decoy-${entity.id}`,
          ownerId: entity.id,
          team: entity.team,
          characterId: entity.characterId,
          x: entity.x,
          y: entity.y,
          facingX: entity.facingX,
          facingY: entity.facingY,
          duration: 3,
        });
        state.events.push({ type: "veilDecoy", entityId: entity.id, x: entity.x, y: entity.y });
      }
    }
  } else if (special.kind === "rail") {
    const end = clippedRayEnd(entity, special.range, map);
    for (const target of opponentsOf(state, entity)) {
      if (
        segmentCircleHit(
          entity.x,
          entity.y,
          end.x,
          end.y,
          target.x,
          target.y,
          getCharacter(target.characterId).radius + special.width,
        )
      ) {
        damageEntity(state, target, special.damage, entity, {
          source: "rail",
          knockback: special.knockback,
          direction: { x: entity.facingX, y: entity.facingY },
        });
        if (agent.affinity.id === "lightning") {
          target.interruptRemaining = Math.max(
            target.interruptRemaining,
            MATCH_TUNING.elements.lightningInterrupt,
          );
          state.events.push({
            type: "elementInterrupt",
            element: "lightning",
            entityId: target.id,
            x: target.x,
            y: target.y,
          });
          const conductingWater = state.elementFields.find(
            (field) =>
              field.element === "water" &&
              Math.hypot(target.x - field.x, target.y - field.y) <= field.radius,
          );
          if (conductingWater) {
            for (const conducted of opponentsOf(state, entity)) {
              if (
                Math.hypot(conducted.x - conductingWater.x, conducted.y - conductingWater.y) <=
                conductingWater.radius + getCharacter(conducted.characterId).radius
              ) {
                conducted.interruptRemaining = Math.max(
                  conducted.interruptRemaining,
                  MATCH_TUNING.elements.lightningInterrupt,
                );
              }
            }
            state.events.push({
              type: "elementReaction",
              reaction: "conduct",
              x: conductingWater.x,
              y: conductingWater.y,
            });
          }
        }
      }
    }
    state.events.push({
      type: "rail",
      entityId: entity.id,
      x: entity.x,
      y: entity.y,
      endX: end.x,
      endY: end.y,
    });
  } else if (special.kind === "mine") {
    state.mines = state.mines.filter(
      (mine) => mine.ownerId !== entity.id || mine.remaining > special.duration / 2,
    );
    state.mines.push({
      id: state.nextMineId,
      ownerId: entity.id,
      team: entity.team,
      x: entity.x,
      y: entity.y,
      armedIn: special.armTime,
      remaining: special.duration,
      triggerRadius: special.triggerRadius,
      blastRadius: special.blastRadius,
      damage: special.damage,
      knockback: special.knockback,
    });
    state.nextMineId += 1;
  } else if (special.kind === "pull") {
    for (const target of opponentsOf(state, entity)) {
      const distance = Math.hypot(entity.x - target.x, entity.y - target.y);
      if (distance > special.range) continue;
      const direction = normalizeDirection(entity.x - target.x, entity.y - target.y);
      damageEntity(state, target, special.damage, entity, {
        source: "pull",
        knockback: -special.pull,
        direction: { x: -direction.x, y: -direction.y },
      });
    }
    const fieldsBefore = state.elementFields.length;
    state.elementFields = state.elementFields.filter((field) => {
      const centerX = field.element === "earth" ? field.x + field.width / 2 : field.x;
      const centerY = field.element === "earth" ? field.y + field.height / 2 : field.y;
      return Math.hypot(centerX - entity.x, centerY - entity.y) > special.range;
    });
    if (state.elementFields.length < fieldsBefore) {
      state.events.push({
        type: "elementReaction",
        reaction: "nullify",
        x: entity.x,
        y: entity.y,
      });
    }
  } else if (special.kind === "heal") {
    const before = entity.health;
    entity.health = Math.min(entity.maxHealth, entity.health + special.amount);
    state.events.push({
      type: "heal",
      entityId: entity.id,
      amount: entity.health - before,
      x: entity.x,
      y: entity.y,
    });
    if (agent.affinity.id === "water") {
      createElementField(state, entity, "water", {
        x: entity.x,
        y: entity.y,
        radius: MATCH_TUNING.elements.waterRadius,
        duration: MATCH_TUNING.elements.waterDuration,
        directionX: entity.facingX,
        directionY: entity.facingY,
      });
    }
  } else if (special.kind === "volley") {
    firePattern(state, entity, special, "special");
  }
}

function rectanglesOverlap(left, right, padding = 0) {
  return (
    left.x < right.x + right.width + padding &&
    left.x + left.width + padding > right.x &&
    left.y < right.y + right.height + padding &&
    left.y + left.height + padding > right.y
  );
}

function firePattern(state, entity, weapon, source) {
  const count = Math.max(1, finiteInteger(weapon.count, 1));
  for (let shot = 0; shot < count; shot += 1) {
    const offset = count === 1 ? 0 : shot - (count - 1) / 2;
    const angle = Math.atan2(entity.facingY, entity.facingX) + offset * weapon.spread;
    const direction = { x: Math.cos(angle), y: Math.sin(angle) };
    const spawnOffset = getCharacter(entity.characterId).radius + weapon.radius + 4;
    state.projectiles.push({
      id: state.nextProjectileId,
      ownerId: entity.id,
      team: entity.team,
      source,
      x: entity.x + direction.x * spawnOffset,
      y: entity.y + direction.y * spawnOffset,
      previousX: entity.x,
      previousY: entity.y,
      vx: direction.x * weapon.speed,
      vy: direction.y * weapon.speed,
      radius: weapon.radius,
      damage: weapon.damage,
      lifetime: weapon.lifetime,
      knockback: weapon.knockback ?? 0,
      pierce: weapon.pierce ?? 0,
      heavy: weapon.heavy === true,
      reflected: false,
      fieldIds: [],
      guidedBy: weapon.guidedBy ?? null,
      guidedRemaining: weapon.guidedRemaining ?? 0,
      turnRate: weapon.turnRate ?? 0,
    });
    state.nextProjectileId += 1;
  }
  state.events.push({
    type: "shot",
    entityId: entity.id,
    source,
    x: entity.x,
    y: entity.y,
  });
}

function updateMines(state, delta) {
  const survivors = [];
  for (const mine of state.mines) {
    mine.armedIn = Math.max(0, mine.armedIn - delta);
    mine.remaining -= delta;
    if (mine.remaining <= 0) continue;
    const owner = state.entities.find((entity) => entity.id === mine.ownerId);
    const target = state.entities.find(
      (entity) =>
        entity.alive &&
        hostileTeams(mine.team, entity.team) &&
        Math.hypot(entity.x - mine.x, entity.y - mine.y) <= mine.triggerRadius,
    );
    if (mine.armedIn === 0 && target) {
      for (const entity of state.entities) {
        if (!entity.alive || !hostileTeams(mine.team, entity.team)) continue;
        const distance = Math.hypot(entity.x - mine.x, entity.y - mine.y);
        if (distance > mine.blastRadius) continue;
        const direction = normalizeDirection(entity.x - mine.x, entity.y - mine.y);
        damageEntity(state, entity, mine.damage, owner, {
          source: "mine",
          knockback: mine.knockback,
          direction,
        });
      }
      state.events.push({ type: "mineBlast", x: mine.x, y: mine.y });
      const earthBefore = state.elementFields.length;
      state.elementFields = state.elementFields.filter(
        (field) =>
          field.element !== "earth" ||
          Math.hypot(
            mine.x - (field.x + field.width / 2),
            mine.y - (field.y + field.height / 2),
          ) > mine.blastRadius + Math.max(field.width, field.height) / 2,
      );
      if (state.elementFields.length < earthBefore) {
        state.events.push({
          type: "elementReaction",
          reaction: "shatter",
          x: mine.x,
          y: mine.y,
        });
      }
      if (owner && getCharacter(owner.characterId).affinity.id === "fire") {
        createElementField(state, owner, "fire", {
          x: mine.x,
          y: mine.y,
          radius: MATCH_TUNING.elements.fireRadius,
          duration: MATCH_TUNING.elements.fireDuration,
        });
      }
      continue;
    }
    survivors.push(mine);
  }
  state.mines = survivors;
}

function updateProjectiles(state, delta, map) {
  for (const projectile of state.projectiles) {
    projectile.guidedRemaining = Math.max(0, finite(projectile.guidedRemaining));
    projectile.turnRate = clamp(finite(projectile.turnRate), 0, 6);
    projectile.guidedBy = typeof projectile.guidedBy === "string"
      ? projectile.guidedBy
      : null;
    if (projectile.guidedRemaining > 0 && projectile.guidedBy) {
      const guide = state.entities.find(
        (entity) => entity.id === projectile.guidedBy && entity.alive,
      );
      if (guide) {
        const speed = Math.hypot(projectile.vx, projectile.vy);
        const current = Math.atan2(projectile.vy, projectile.vx);
        const target = Math.atan2(guide.facingY, guide.facingX);
        const difference = Math.atan2(Math.sin(target - current), Math.cos(target - current));
        const angle = current + clamp(
          difference,
          -projectile.turnRate * delta,
          projectile.turnRate * delta,
        );
        projectile.vx = Math.cos(angle) * speed;
        projectile.vy = Math.sin(angle) * speed;
      }
      projectile.guidedRemaining = Math.max(0, projectile.guidedRemaining - delta);
    }
    projectile.previousX = projectile.x;
    projectile.previousY = projectile.y;
    projectile.x += finite(projectile.vx) * delta;
    projectile.y += finite(projectile.vy) * delta;
    projectile.lifetime -= delta;
    projectile.fieldIds ??= [];
    for (const field of state.elementFields) {
      if (
        field.element !== "wind" ||
        projectile.fieldIds.includes(field.id) ||
        Math.hypot(projectile.x - field.x, projectile.y - field.y) > field.radius
      ) {
        continue;
      }
      const speed = Math.hypot(projectile.vx, projectile.vy);
      const direction = windDirectionAt(field, projectile.x, projectile.y);
      const force = field.shape === "vortex"
        ? MATCH_TUNING.elements.vortexProjectileForce
        : 260;
      const bent = normalizeDirection(
        projectile.vx + direction.x * force,
        projectile.vy + direction.y * force,
      );
      projectile.vx = bent.x * speed;
      projectile.vy = bent.y * speed;
      projectile.fieldIds.push(field.id);
      state.events.push({
        type: "elementReaction",
        reaction: "deflect",
        x: projectile.x,
        y: projectile.y,
      });
    }
  }

  const removed = new Set();
  if (MATCH_TUNING.projectileClashes) {
    for (let left = 0; left < state.projectiles.length; left += 1) {
      const a = state.projectiles[left];
      if (removed.has(a.id)) continue;
      for (let right = left + 1; right < state.projectiles.length; right += 1) {
        const b = state.projectiles[right];
        if (
          removed.has(b.id) ||
          !hostileTeams(a.team, b.team) ||
          !projectilesCross(a, b)
        ) {
          continue;
        }
        if (a.heavy && !b.heavy) removed.add(b.id);
        else if (b.heavy && !a.heavy) removed.add(a.id);
        else {
          removed.add(a.id);
          removed.add(b.id);
        }
        state.events.push({
          type: "projectileClash",
          x: (a.x + b.x) / 2,
          y: (a.y + b.y) / 2,
        });
      }
    }
  }

  const survivors = [];
  for (const projectile of state.projectiles) {
    if (
      removed.has(projectile.id) ||
      projectile.lifetime <= 0 ||
      !insideArena(projectile, map.size)
    ) {
      continue;
    }
    if (
      map.obstacles.some((obstacle) =>
        segmentRectangleHit(
          projectile.previousX,
          projectile.previousY,
          projectile.x,
          projectile.y,
          obstacle,
          projectile.radius,
        ),
      )
    ) {
      state.events.push({
        type: "projectileBlocked",
        x: projectile.x,
        y: projectile.y,
      });
      continue;
    }

    const target = state.entities.find(
      (entity) =>
        entity.alive &&
        entity.id !== projectile.ownerId &&
        hostileTeams(projectile.team, entity.team) &&
        segmentCircleHit(
          projectile.previousX,
          projectile.previousY,
          projectile.x,
          projectile.y,
          entity.x,
          entity.y,
          getCharacter(entity.characterId).radius + projectile.radius,
        ),
    );
    if (!target) {
      survivors.push(projectile);
      continue;
    }
    const interaction = defendAgainstProjectile(state, target, projectile);
    if (interaction === "pass") {
      survivors.push(projectile);
      continue;
    }
    if (interaction === "reflect") {
      survivors.push(projectile);
      continue;
    }
    if (interaction === "consume") continue;

    const direction = normalizeDirection(projectile.vx, projectile.vy);
    damageEntity(
      state,
      target,
      projectile.damage,
      state.entities.find((entity) => entity.id === projectile.ownerId),
      {
        source: projectile.source,
        knockback: projectile.knockback,
        direction,
      },
    );
    if (projectile.pierce > 0) {
      projectile.pierce -= 1;
      projectile.ownerId = `${projectile.ownerId}:spent:${target.id}`;
      survivors.push(projectile);
    }
  }
  state.projectiles = survivors;
}

function defendAgainstProjectile(state, target, projectile) {
  if (target.spawnProtection > 0) return "consume";
  if (target.defenseRemaining <= 0) return "hit";
  const defense = getCharacter(target.characterId).defense;
  if (defense.kind === "phase") {
    return "pass";
  }
  if (defense.kind === "reflect") {
    projectile.ownerId = target.id;
    projectile.team = target.team;
    projectile.vx *= -1;
    projectile.vy *= -1;
    projectile.previousX = target.x;
    projectile.previousY = target.y;
    projectile.x =
      target.x + normalizeDirection(projectile.vx, projectile.vy).x * 38;
    projectile.y =
      target.y + normalizeDirection(projectile.vx, projectile.vy).y * 38;
    projectile.reflected = true;
    projectile.guidedBy = null;
    projectile.guidedRemaining = 0;
    projectile.turnRate = 0;
    primeReflectPassive(state, target);
    state.events.push({
      type: "reflect",
      entityId: target.id,
      x: target.x,
      y: target.y,
    });
    return "reflect";
  }
  if (defense.kind === "absorb") {
    target.health = Math.min(target.maxHealth, target.health + defense.heal);
    target.specialCooldown = Math.max(0, target.specialCooldown - defense.refund);
    state.events.push({
      type: "absorb",
      entityId: target.id,
      x: target.x,
      y: target.y,
    });
    return "consume";
  }
  if (defense.kind === "counter") {
    const owner = state.entities.find((entity) => entity.id === projectile.ownerId);
    const direction = owner
      ? normalizeDirection(owner.x - target.x, owner.y - target.y)
      : { x: target.facingX, y: target.facingY };
    fireCounter(state, target, defense, direction);
    return "consume";
  }
  return "hit";
}

function fireCounter(state, entity, defense, direction) {
  state.projectiles.push({
    id: state.nextProjectileId,
    ownerId: entity.id,
    team: entity.team,
    source: "counter",
    x: entity.x + direction.x * 30,
    y: entity.y + direction.y * 30,
    previousX: entity.x,
    previousY: entity.y,
    vx: direction.x * defense.counterSpeed,
    vy: direction.y * defense.counterSpeed,
    radius: 5,
    damage: defense.counterDamage,
    lifetime: 1.4,
    knockback: 110,
    pierce: 0,
    heavy: false,
    reflected: false,
  });
  state.nextProjectileId += 1;
  state.events.push({ type: "counter", entityId: entity.id, x: entity.x, y: entity.y });
}

function updateHazards(state, delta) {
  for (const hazard of state.hazards) {
    hazard.remaining -= delta;
    if (hazard.remaining <= 0) {
      if (hazard.phase === "cooldown") {
        hazard.phase = "warning";
        hazard.remaining = hazard.warning;
        hazard.hitIds = [];
        state.events.push({ type: "hazardWarning", hazardId: hazard.id });
      } else if (hazard.phase === "warning") {
        hazard.phase = "active";
        hazard.remaining = hazard.active;
        state.events.push({ type: "hazardActive", hazardId: hazard.id });
      } else {
        hazard.phase = "cooldown";
        hazard.remaining = hazard.cooldown;
        state.events.push({ type: "hazardClear", hazardId: hazard.id });
      }
    }
    if (hazard.phase !== "active") continue;
    for (const entity of state.entities) {
      if (
        !entity.alive ||
        hazard.hitIds.includes(entity.id) ||
        !circleRectangleOverlap(
          entity,
          getCharacter(entity.characterId).radius,
          hazard,
        )
      ) {
        continue;
      }
      hazard.hitIds.push(entity.id);
      damageEntity(state, entity, hazard.damage, null, { source: "hazard" });
    }
  }
}

function damageEntity(state, target, rawDamage, attacker, options = {}) {
  if (
    !target?.alive ||
    target.spawnProtection > 0 ||
    target.damageInvulnerability > 0
  ) {
    return false;
  }
  const agent = getCharacter(target.characterId);
  let damage = Math.max(0, finite(rawDamage));
  if (target.defenseRemaining > 0 && agent.defense.kind === "guard") {
    const sourceDirection = options.direction ?? { x: 0, y: 0 };
    const incomingDot =
      -sourceDirection.x * target.facingX - sourceDirection.y * target.facingY;
    if (incomingDot >= agent.defense.frontalDot) {
      damage *= 1 - agent.defense.reduction;
      state.events.push({ type: "guarded", entityId: target.id });
    }
  }
  damage = Math.max(1, Math.round(damage));
  target.health = Math.max(0, target.health - damage);
  target.hitFlash = MATCH_TUNING.hitFlash;
  target.damageInvulnerability = agent.damageInvulnerability;
  target.lastAttackerId = attacker?.id ?? null;
  if (options.knockback && options.direction) {
    const resistance = getRace(target.raceId).knockback ?? 1;
    target.vx += options.direction.x * options.knockback * resistance;
    target.vy += options.direction.y * options.knockback * resistance;
  }
  state.events.push({
    type: "hit",
    entityId: target.id,
    attackerId: attacker?.id ?? null,
    damage,
    source: options.source ?? "unknown",
    x: target.x,
    y: target.y,
  });
  if (attacker && attacker !== target && options.source !== "ultimate") {
    gainUltimateCharge(state, attacker, damage);
  }
  if (target.health === 0) eliminateEntity(state, target, attacker);
  return true;
}

function gainUltimateCharge(state, entity, damage) {
  const ultimate = getCharacter(entity.characterId).ultimate;
  if (!ultimate || entity.ultimateCharge >= ultimate.chargeRequired) return;
  const before = entity.ultimateCharge;
  entity.ultimateCharge = Math.min(
    ultimate.chargeRequired,
    entity.ultimateCharge + damage * ultimate.chargePerDamage,
  );
  if (
    before < ultimate.chargeRequired &&
    entity.ultimateCharge === ultimate.chargeRequired
  ) {
    state.events.push({
      type: "ultimateReady",
      entityId: entity.id,
      name: ultimate.name,
      x: entity.x,
      y: entity.y,
    });
  }
}

function eliminateEntity(state, target, attacker) {
  target.alive = false;
  target.deaths += 1;
  target.respawnRemaining = 1.55;
  target.vx = 0;
  target.vy = 0;
  target.mobilityRemaining = 0;
  target.passiveRemaining = 0;
  target.passiveActive = false;
  target.ultimateWindupRemaining = 0;
  target.ultimateResolvePending = false;
  if (attacker && attacker !== target) attacker.kills += 1;
  state.events.push({
    type: "elimination",
    entityId: target.id,
    attackerId: attacker?.id ?? null,
    team: attacker?.team ?? null,
  });
  const mode = getMode(state.modeId);
  if (mode.id === "duel" || mode.id === "training") {
    const scoringTeam = attacker?.team;
    if (scoringTeam === "alpha" || scoringTeam === "beta") {
      state.score[scoringTeam] += 1;
    }
    if (
      mode.id === "training" ||
      state.overtime ||
      state.score[scoringTeam] >= mode.scoreLimit
    ) {
      finishMatch(state, scoringTeam ?? oppositeTeam(target.team));
    } else {
      state.status = "round-over";
      state.roundRemaining = MATCH_TUNING.roundResetDelay;
      state.winner = scoringTeam ?? null;
      state.events.push({ type: "roundOver", winner: state.winner });
    }
  } else if (mode.id === "survival") {
    if (target.team === "alpha") {
      target.lives -= 1;
      if (target.lives <= 0) {
        const livingHumans = state.entities.some(
          (entity) =>
            entity.team === "alpha" && entity.human && entity.lives > 0,
        );
        if (!livingHumans) finishMatch(state, "beta");
      }
    } else if (
      target.team === "beta" &&
      !state.entities.some(
        (entity) => entity.team === "beta" && entity.alive,
      )
    ) {
      state.score.alpha = state.survival.wave;
      if (state.survival.wave >= mode.scoreLimit) {
        finishMatch(state, "alpha");
      } else {
        state.status = "round-over";
        state.roundRemaining = 1.6;
        state.winner = "alpha";
        state.events.push({
          type: "waveClear",
          wave: state.survival.wave,
        });
      }
    }
  } else if (attacker?.team === "alpha" || attacker?.team === "beta") {
    state.score[attacker.team] += target.neutral ? 3 : 6;
    if (state.score[attacker.team] >= mode.scoreLimit) {
      state.score[attacker.team] = mode.scoreLimit;
      finishMatch(state, attacker.team);
    }
  }
}

function updateRespawn(state, entity, delta, map, mode) {
  if (state.status !== "playing") return;
  if (mode.id === "duel" || mode.id === "training") return;
  if (mode.id === "survival" && entity.team === "beta") return;
  if (mode.id === "survival" && entity.team === "alpha" && entity.lives <= 0) {
    return;
  }
  entity.respawnRemaining = Math.max(0, entity.respawnRemaining - delta);
  if (entity.respawnRemaining > 0) return;
  respawnEntity(entity, map);
  state.events.push({ type: "respawn", entityId: entity.id });
}

function respawnEntity(entity, map) {
  const spawn = map.spawns[entity.spawnIndex % map.spawns.length];
  const agent = getCharacter(entity.characterId);
  const race = getRace(entity.raceId);
  entity.x = spawn.x;
  entity.y = spawn.y;
  entity.lastSafeX = spawn.x;
  entity.lastSafeY = spawn.y;
  entity.vx = 0;
  entity.vy = 0;
  entity.maxHealth = Math.round(agent.health * race.health);
  entity.health = entity.maxHealth;
  entity.alive = true;
  entity.spawnProtection = MATCH_TUNING.spawnProtection;
  entity.damageInvulnerability = 0;
  entity.defenseRemaining = 0;
  entity.mobilityRemaining = 0;
  entity.passiveRemaining = 0;
  entity.passiveActive = false;
  entity.passiveCueCooldown = 0;
  entity.maxUltimate = agent.ultimate?.chargeRequired ?? 0;
  entity.ultimateCharge = clamp(entity.ultimateCharge, 0, entity.maxUltimate);
  entity.ultimateWindupRemaining = 0;
  entity.ultimateResolvePending = false;
  entity.ultimateAimX = entity.facingX;
  entity.ultimateAimY = entity.facingY;
  entity.ultimateTargetX = entity.x;
  entity.ultimateTargetY = entity.y;
  entity.maxFlow = MATCH_TUNING.flow.maximum * race.flow;
  entity.flow = entity.maxFlow;
  entity.flowRecoveryDelay = 0;
  entity.sprinting = false;
  entity.hopCooldown = 0;
  entity.hopRemaining = 0;
  entity.landingRemaining = 0;
  entity.hopWallKick = false;
  entity.slideCooldown = 0;
  entity.slideRemaining = 0;
  entity.slideX = entity.facingX;
  entity.slideY = entity.facingY;
  entity.hopCarryX = 0;
  entity.hopCarryY = 0;
  entity.wallContactRemaining = 0;
  entity.wallX = 0;
  entity.wallY = 0;
  entity.maxFlux = MATCH_TUNING.flux.maximum * race.flux;
  entity.flux = entity.maxFlux;
  entity.fluxRecoveryDelay = 0;
  entity.fluxWarningCooldown = 0;
  entity.counterStrafeCooldown = 0;
  entity.surface = "normal";
  entity.elementForceX = 0;
  entity.elementForceY = 0;
  entity.interruptRemaining = 0;
  entity.primaryCooldown = 0;
  entity.specialCooldown = 0;
  entity.defenseCooldown = 0;
  entity.mobilityCooldown = 0;
}

function resetRound(state, map, mode) {
  state.round += 1;
  state.status = "playing";
  state.winner = null;
  state.roundRemaining = 0;
  state.projectiles = [];
  state.mines = [];
  state.elementFields = [];
  state.decoys = [];
  state.shrines = (map.shrines ?? []).map((shrine) => ({
    ...shrine,
    readyIn: 0,
    insideIds: [],
  }));
  if (mode.id === "survival") {
    state.survival.wave += 1;
    const enemyCount = state.entities.filter(
      (entity) => entity.team === "beta",
    ).length;
    if (enemyCount < Math.min(7, state.survival.wave + 1)) {
      state.entities.push(
        createEntity(
          {
            id: `wave-${state.survival.wave}-${enemyCount + 1}`,
            name: `PRESSURE ${enemyCount + 1}`,
            characterId:
              CHARACTERS[(state.survival.wave + enemyCount) % CHARACTERS.length]
                .id,
            team: "beta",
            bot: true,
          },
          state.entities.length,
          map,
        ),
      );
    }
  }
  for (const entity of state.entities) respawnEntity(entity, map);
  for (const hazard of state.hazards) {
    hazard.phase = "cooldown";
    hazard.remaining = hazard.initial;
    hazard.hitIds = [];
  }
  state.events.push({ type: "roundStart", round: state.round });
  if (mode.id === "survival") {
    state.events.push({ type: "waveStart", wave: state.survival.wave });
  }
}

function updateObjective(state, delta, mode, map) {
  if (mode.id !== "control" && mode.id !== "convergence") return;
  const occupants = new Set(
    state.entities
      .filter(
        (entity) =>
          entity.alive &&
          entity.team !== "neutral" &&
          Math.hypot(
            entity.x - map.objective.x,
            entity.y - map.objective.y,
          ) <=
            map.objective.radius + getCharacter(entity.characterId).radius,
      )
      .map((entity) => entity.team),
  );
  state.objective.contested = occupants.size > 1;
  state.objective.controllingTeam =
    occupants.size === 1 ? [...occupants][0] : null;
  if (!state.objective.controllingTeam) return;
  const team = state.objective.controllingTeam;
  const gain = MATCH_TUNING.controlScorePerSecond * delta;
  state.score[team] = Math.min(mode.scoreLimit, state.score[team] + gain);
  state.objective.progress[team] = state.score[team] / mode.scoreLimit;
  if (state.score[team] >= mode.scoreLimit) finishMatch(state, team);
}

function updateMatchClock(state, delta, mode) {
  state.elapsed += delta;
  if (state.elapsed < mode.timeLimit || state.status !== "playing") return;
  if (mode.id === "survival") {
    finishMatch(state, "beta");
    return;
  }
  if (state.score.alpha === state.score.beta) {
    if (!state.overtime) {
      state.overtime = true;
      state.events.push({ type: "overtime" });
    }
    return;
  }
  finishMatch(state, state.score.alpha > state.score.beta ? "alpha" : "beta");
}

function finishMatch(state, team) {
  state.status = "match-over";
  state.winner = team ?? null;
  state.projectiles = [];
  state.events.push({ type: "matchOver", winner: state.winner });
}

function updateTutorial(state) {
  if (state.tutorial.skipped || state.modeId !== "training") return;
  if (
    state.tutorial.step === 0 && state.tutorial.sprinted &&
    state.tutorial.hopped && state.tutorial.slid
  ) {
    state.tutorial.step = 1;
    state.events.push({ type: "tutorialStep", step: 1 });
  } else if (
    state.tutorial.step === 1 &&
    state.tutorial.moved &&
    state.tutorial.fired
  ) {
    state.tutorial.step = 2;
    state.events.push({ type: "tutorialStep", step: 2 });
  } else if (
    state.tutorial.step === 2 &&
    state.tutorial.mobility &&
    state.tutorial.defended
  ) {
    state.tutorial.step = 3;
    state.events.push({ type: "tutorialStep", step: 3 });
  } else if (state.tutorial.step === 3 && state.tutorial.special) {
    state.tutorial.step = 4;
    state.events.push({ type: "tutorialComplete" });
  }
}

export function skipTutorial(state) {
  state.tutorial.skipped = true;
  state.tutorial.step = 4;
  state.events.push({ type: "tutorialSkipped" });
}

function updateBotCommand(state, entity, delta, map) {
  entity.botThinkRemaining -= delta;
  if (entity.botThinkRemaining > 0) return entity.botCommand;
  entity.botThinkRemaining = MATCH_TUNING.bot.thinkInterval;
  const targets = opponentsOf(state, entity);
  if (targets.length === 0) {
    entity.botCommand = { ...IDLE_COMMAND };
    return entity.botCommand;
  }
  const target = targets.reduce((nearest, candidate) =>
    squaredDistance(entity, candidate) < squaredDistance(entity, nearest)
      ? candidate
      : nearest,
  );
  const dx = target.x - entity.x;
  const dy = target.y - entity.y;
  const distance = Math.hypot(dx, dy);
  const aim = normalizeDirection(dx, dy);
  const strafeSign = hashSign(entity.id, state.tick);
  let moveX = aim.x;
  let moveY = aim.y;
  if (distance < MATCH_TUNING.bot.preferredDistance * 0.7) {
    moveX = -aim.x + -aim.y * strafeSign * 0.55;
    moveY = -aim.y + aim.x * strafeSign * 0.55;
  } else if (distance < MATCH_TUNING.bot.preferredDistance * 1.25) {
    moveX = -aim.y * strafeSign;
    moveY = aim.x * strafeSign;
  }
  if (state.modeId === "control" || state.modeId === "convergence") {
    const objectiveDistance = Math.hypot(
      map.objective.x - entity.x,
      map.objective.y - entity.y,
    );
    if (objectiveDistance > map.objective.radius * 0.75) {
      const objectiveDirection = normalizeDirection(
        map.objective.x - entity.x,
        map.objective.y - entity.y,
      );
      moveX = moveX * 0.45 + objectiveDirection.x * 0.85;
      moveY = moveY * 0.45 + objectiveDirection.y * 0.85;
    }
  }
  const move = normalizeDirection(moveX, moveY);
  const closeProjectile = state.projectiles.some(
    (projectile) =>
      hostileTeams(entity.team, projectile.team) &&
      Math.hypot(projectile.x - entity.x, projectile.y - entity.y) < 125,
  );
  const agent = getCharacter(entity.characterId);
  entity.botCommand = {
    moveX: move.x,
    moveY: move.y,
    aimX: aim.x,
    aimY: aim.y,
    fire: distance < agent.primary.speed * agent.primary.lifetime * 0.82,
    special:
      entity.specialCooldown === 0 &&
      (distance < (agent.special.range ?? 180) || agent.special.kind === "mine"),
    defend: closeProjectile && entity.defenseCooldown === 0,
    mobility:
      entity.mobilityCooldown === 0 &&
      (distance > MATCH_TUNING.bot.preferredDistance * 1.65 ||
        entity.health / entity.maxHealth < MATCH_TUNING.bot.retreatHealthRatio),
    sprint:
      entity.flow > entity.maxFlow * 0.6 &&
      distance > MATCH_TUNING.bot.preferredDistance * 1.2,
    hop:
      closeProjectile &&
      entity.hopCooldown === 0 &&
      entity.flow >= MATCH_TUNING.flow.hopCost,
    ultimate:
      Boolean(agent.ultimate) &&
      entity.ultimateCharge >= (agent.ultimate?.chargeRequired ?? Infinity) &&
      distance >= 150 &&
      distance <= (agent.ultimate?.range ?? agent.ultimate?.targetRange ?? 0) * 0.92,
  };
  if (
    state.modeId === "training" &&
    !state.tutorial.skipped &&
    state.tutorial.step < 3
  ) {
    entity.botCommand.fire = false;
    entity.botCommand.special = false;
    entity.botCommand.defend = false;
    entity.botCommand.mobility = false;
    entity.botCommand.sprint = false;
    entity.botCommand.hop = false;
    entity.botCommand.ultimate = false;
  }
  return entity.botCommand;
}

function resolveUnitCollisions(state, map) {
  const alive = state.entities.filter((entity) => entity.alive);
  for (let pass = 0; pass < MATCH_TUNING.unitCollisionIterations; pass += 1) {
    for (let left = 0; left < alive.length; left += 1) {
      for (let right = left + 1; right < alive.length; right += 1) {
        const a = alive[left];
        const b = alive[right];
        const aRadius = getCharacter(a.characterId).radius;
        const bRadius = getCharacter(b.characterId).radius;
        let dx = b.x - a.x;
        let dy = b.y - a.y;
        let distance = Math.hypot(dx, dy);
        const required = aRadius + bRadius;
        if (distance >= required) continue;
        if (distance <= EPSILON) {
          dx = a.id.localeCompare(b.id) <= 0 ? 1 : -1;
          dy = 0;
          distance = 1;
        }
        const overlap = required - distance;
        const nx = dx / distance;
        const ny = dy / distance;
        a.x -= nx * overlap * 0.5;
        a.y -= ny * overlap * 0.5;
        b.x += nx * overlap * 0.5;
        b.y += ny * overlap * 0.5;
        moveCircleSwept(a, 0, 0, aRadius, map);
        moveCircleSwept(b, 0, 0, bRadius, map);
        resolveDashContact(state, a, b, nx, ny);
        resolveDashContact(state, b, a, -nx, -ny);
      }
    }
  }
}

function resolveMapCollisions(state, map) {
  for (const entity of state.entities) {
    if (!entity.alive) continue;
    moveCircleSwept(
      entity,
      0,
      0,
      getCharacter(entity.characterId).radius,
      map,
    );
  }
}

function resolveDashContact(state, attacker, target, nx, ny) {
  if (
    attacker.mobilityRemaining <= 0 ||
    attacker.dashHitIds.includes(target.id) ||
    !hostileTeams(attacker.team, target.team)
  ) {
    return;
  }
  const mobility = getCharacter(attacker.characterId).mobility;
  if (!mobility.contactDamage) return;
  attacker.dashHitIds.push(target.id);
  damageEntity(state, target, mobility.contactDamage, attacker, {
    source: "charge",
    knockback: mobility.knockback,
    direction: { x: nx, y: ny },
  });
}

function damageRadius(state, source, range, damage, knockback) {
  for (const target of opponentsOf(state, source)) {
    const distance = Math.hypot(target.x - source.x, target.y - source.y);
    if (distance > range) continue;
    const direction = normalizeDirection(target.x - source.x, target.y - source.y);
    damageEntity(state, target, damage, source, {
      source: "blast",
      knockback,
      direction,
    });
  }
}

function opponentsOf(state, entity) {
  return state.entities.filter(
    (candidate) =>
      candidate.alive &&
      candidate !== entity &&
      hostileTeams(entity.team, candidate.team),
  );
}

function hostileTeams(left, right) {
  return left !== right && (left === "neutral" || right === "neutral" || left !== right);
}

function repairState(state, map) {
  for (const entity of state.entities) {
    const agent = getCharacter(entity.characterId);
    if (Number.isFinite(entity.x) && Number.isFinite(entity.y)) {
      entity.lastSafeX = entity.x;
      entity.lastSafeY = entity.y;
    } else {
      entity.x = Number.isFinite(entity.lastSafeX)
        ? entity.lastSafeX
        : map.spawns[entity.spawnIndex % map.spawns.length].x;
      entity.y = Number.isFinite(entity.lastSafeY)
        ? entity.lastSafeY
        : map.spawns[entity.spawnIndex % map.spawns.length].y;
      entity.vx = 0;
      entity.vy = 0;
      entity.mobilityRemaining = 0;
      state.events.push({ type: "stateRepair", entityId: entity.id });
    }
    entity.facingX = finite(entity.facingX, 1);
    entity.facingY = finite(entity.facingY);
    const facing = normalizeDirection(entity.facingX, entity.facingY);
    if (facing.x === 0 && facing.y === 0) {
      entity.facingX = 1;
      entity.facingY = 0;
    } else {
      entity.facingX = facing.x;
      entity.facingY = facing.y;
    }
    entity.passiveRemaining = clamp(
      finite(entity.passiveRemaining),
      0,
      agent.passive?.duration ?? 0,
    );
    entity.passiveActive = entity.passiveActive === true;
    entity.passiveCueCooldown = clamp(finite(entity.passiveCueCooldown), 0, 1);
    entity.maxUltimate = agent.ultimate?.chargeRequired ?? 0;
    entity.ultimateCharge = clamp(
      finite(entity.ultimateCharge),
      0,
      entity.maxUltimate,
    );
    entity.ultimateWindupRemaining = clamp(
      finite(entity.ultimateWindupRemaining),
      0,
      agent.ultimate?.windup ?? 0,
    );
    entity.ultimateAimX = finite(entity.ultimateAimX, entity.facingX);
    entity.ultimateAimY = finite(entity.ultimateAimY, entity.facingY);
    entity.ultimateTargetX = finite(entity.ultimateTargetX, entity.x);
    entity.ultimateTargetY = finite(entity.ultimateTargetY, entity.y);
    constrainCircle(entity, agent.radius, map.size);
  }
  state.projectiles = state.projectiles.filter(
    (projectile) =>
      Number.isFinite(projectile.x) &&
      Number.isFinite(projectile.y) &&
      Number.isFinite(projectile.vx) &&
      Number.isFinite(projectile.vy),
  );
}

export function matchInvariantErrors(state) {
  const errors = [];
  const map = getMap(state.mapId);
  const ids = state.entities.map((entity) => entity.id);
  if (new Set(ids).size !== ids.length) errors.push("entity ids must be unique");
  for (const entity of state.entities) {
    const radius = getCharacter(entity.characterId).radius;
    for (const key of [
      "x",
      "y",
      "vx",
      "vy",
      "facingX",
      "facingY",
      "health",
      "primaryCooldown",
      "specialCooldown",
      "defenseCooldown",
      "mobilityCooldown",
      "flow",
      "maxFlow",
      "flowRecoveryDelay",
      "hopCooldown",
      "hopRemaining",
      "landingRemaining",
      "slideCooldown",
      "slideRemaining",
      "slideX",
      "slideY",
      "hopCarryX",
      "hopCarryY",
      "wallContactRemaining",
      "elementForceX",
      "elementForceY",
      "interruptRemaining",
      "flux",
      "maxFlux",
      "speedScale",
      "fluxRecoveryDelay",
      "fluxWarningCooldown",
      "counterStrafeCooldown",
      "passiveRemaining",
      "passiveCueCooldown",
      "ultimateCharge",
      "maxUltimate",
      "ultimateWindupRemaining",
      "ultimateAimX",
      "ultimateAimY",
      "ultimateTargetX",
      "ultimateTargetY",
    ]) {
      if (!Number.isFinite(entity[key])) errors.push(`${entity.id}.${key} is not finite`);
    }
    if (
      entity.x < map.size.inset + radius - 0.01 ||
      entity.x > map.size.width - map.size.inset - radius + 0.01 ||
      entity.y < map.size.inset + radius - 0.01 ||
      entity.y > map.size.height - map.size.inset - radius + 0.01
    ) {
      errors.push(`${entity.id} left arena bounds`);
    }
    for (const obstacle of withElementGeometry(map, state.elementFields).obstacles) {
      if (circleRectangleOverlap(entity, radius - 0.01, obstacle)) {
        errors.push(`${entity.id} overlaps cover`);
      }
    }
  }
  for (const field of state.elementFields) {
    for (const key of ["x", "y", "duration"]) {
      if (!Number.isFinite(field[key])) errors.push(`${field.id}.${key} is not finite`);
    }
  }
  for (const shrine of state.shrines ?? []) {
    for (const key of ["x", "y", "radius", "readyIn"]) {
      if (!Number.isFinite(shrine[key])) errors.push(`${shrine.id}.${key} is not finite`);
    }
    if (shrine.readyIn < 0 || shrine.readyIn > shrine.cooldown) {
      errors.push(`${shrine.id}.readyIn is outside its cooldown`);
    }
  }
  return errors;
}

export function normalizeDirection(x, y) {
  const safeX = finite(x);
  const safeY = finite(y);
  const magnitude = Math.hypot(safeX, safeY);
  if (magnitude <= EPSILON) return { x: 0, y: 0 };
  return { x: safeX / magnitude, y: safeY / magnitude };
}

export function resolveCircleRectangle(circle, radius, rectangle) {
  const closestX = clamp(circle.x, rectangle.x, rectangle.x + rectangle.width);
  const closestY = clamp(circle.y, rectangle.y, rectangle.y + rectangle.height);
  let dx = circle.x - closestX;
  let dy = circle.y - closestY;
  let distance = Math.hypot(dx, dy);
  if (distance >= radius) return false;

  if (distance <= EPSILON) {
    const candidates = [
      { gap: Math.abs(circle.x - rectangle.x), x: rectangle.x - radius, y: circle.y, axis: "x" },
      {
        gap: Math.abs(rectangle.x + rectangle.width - circle.x),
        x: rectangle.x + rectangle.width + radius,
        y: circle.y,
        axis: "x",
      },
      { gap: Math.abs(circle.y - rectangle.y), x: circle.x, y: rectangle.y - radius, axis: "y" },
      {
        gap: Math.abs(rectangle.y + rectangle.height - circle.y),
        x: circle.x,
        y: rectangle.y + rectangle.height + radius,
        axis: "y",
      },
    ].sort((a, b) => a.gap - b.gap);
    circle.x = candidates[0].x;
    circle.y = candidates[0].y;
    if (candidates[0].axis === "x") circle.vx = 0;
    else circle.vy = 0;
    return true;
  }

  dx /= distance;
  dy /= distance;
  const correction = radius - distance;
  circle.x += dx * correction;
  circle.y += dy * correction;
  const velocityIntoSurface = finite(circle.vx) * dx + finite(circle.vy) * dy;
  if (velocityIntoSurface < 0) {
    circle.vx -= velocityIntoSurface * dx;
    circle.vy -= velocityIntoSurface * dy;
  }
  return true;
}

export function segmentCircleHit(x1, y1, x2, y2, cx, cy, radius) {
  const dx = x2 - x1;
  const dy = y2 - y1;
  const lengthSquared = dx * dx + dy * dy;
  if (lengthSquared <= EPSILON) return Math.hypot(cx - x1, cy - y1) <= radius;
  const t = clamp(((cx - x1) * dx + (cy - y1) * dy) / lengthSquared, 0, 1);
  return Math.hypot(x1 + dx * t - cx, y1 + dy * t - cy) <= radius;
}

function segmentRectangleHit(x1, y1, x2, y2, rectangle, padding = 0) {
  const expanded = {
    x: rectangle.x - padding,
    y: rectangle.y - padding,
    width: rectangle.width + padding * 2,
    height: rectangle.height + padding * 2,
  };
  if (
    x1 >= expanded.x &&
    x1 <= expanded.x + expanded.width &&
    y1 >= expanded.y &&
    y1 <= expanded.y + expanded.height
  ) {
    return true;
  }
  const edges = [
    [expanded.x, expanded.y, expanded.x + expanded.width, expanded.y],
    [
      expanded.x + expanded.width,
      expanded.y,
      expanded.x + expanded.width,
      expanded.y + expanded.height,
    ],
    [
      expanded.x + expanded.width,
      expanded.y + expanded.height,
      expanded.x,
      expanded.y + expanded.height,
    ],
    [expanded.x, expanded.y + expanded.height, expanded.x, expanded.y],
  ];
  return edges.some((edge) => segmentsIntersect(x1, y1, x2, y2, ...edge));
}

function segmentsIntersect(ax, ay, bx, by, cx, cy, dx, dy) {
  const denominator = (bx - ax) * (dy - cy) - (by - ay) * (dx - cx);
  if (Math.abs(denominator) <= EPSILON) return false;
  const t = ((cx - ax) * (dy - cy) - (cy - ay) * (dx - cx)) / denominator;
  const u = ((cx - ax) * (by - ay) - (cy - ay) * (bx - ax)) / denominator;
  return t >= 0 && t <= 1 && u >= 0 && u <= 1;
}

function projectilesCross(a, b) {
  return (
    segmentCircleHit(
      a.previousX,
      a.previousY,
      a.x,
      a.y,
      b.x,
      b.y,
      a.radius + b.radius,
    ) ||
    segmentCircleHit(
      b.previousX,
      b.previousY,
      b.x,
      b.y,
      a.x,
      a.y,
      a.radius + b.radius,
    )
  );
}

function clippedRayEnd(entity, range, map) {
  const steps = Math.ceil(range / 8);
  let end = { x: entity.x, y: entity.y };
  for (let step = 1; step <= steps; step += 1) {
    const distance = Math.min(range, step * 8);
    const point = {
      x: entity.x + entity.facingX * distance,
      y: entity.y + entity.facingY * distance,
    };
    if (
      !insideArena(point, map.size) ||
      map.obstacles.some((obstacle) =>
        circleRectangleOverlap(point, 1, obstacle),
      )
    ) {
      break;
    }
    end = point;
  }
  return end;
}

function circleRectangleOverlap(circle, radius, rectangle) {
  const closestX = clamp(circle.x, rectangle.x, rectangle.x + rectangle.width);
  const closestY = clamp(circle.y, rectangle.y, rectangle.y + rectangle.height);
  return Math.hypot(circle.x - closestX, circle.y - closestY) < radius;
}

function constrainCircle(circle, radius, size) {
  const minimumX = size.inset + radius;
  const maximumX = size.width - size.inset - radius;
  const minimumY = size.inset + radius;
  const maximumY = size.height - size.inset - radius;
  const previousX = circle.x;
  const previousY = circle.y;
  circle.x = clamp(finite(circle.x, minimumX), minimumX, maximumX);
  circle.y = clamp(finite(circle.y, minimumY), minimumY, maximumY);
  if (circle.x !== previousX) circle.vx = 0;
  if (circle.y !== previousY) circle.vy = 0;
}

function insideArena(point, size) {
  return (
    point.x >= size.inset &&
    point.x <= size.width - size.inset &&
    point.y >= size.inset &&
    point.y <= size.height - size.inset
  );
}

function approachVelocity(entity, targetX, targetY, maximumDelta) {
  const dx = targetX - finite(entity.vx);
  const dy = targetY - finite(entity.vy);
  const distance = Math.hypot(dx, dy);
  if (distance <= maximumDelta || distance <= EPSILON) {
    entity.vx = targetX;
    entity.vy = targetY;
    return;
  }
  entity.vx += (dx / distance) * maximumDelta;
  entity.vy += (dy / distance) * maximumDelta;
}

function squaredDistance(left, right) {
  const dx = left.x - right.x;
  const dy = left.y - right.y;
  return dx * dx + dy * dy;
}

function hashSign(id, tick) {
  let hash = tick >> 5;
  for (const character of id) hash = (hash * 31 + character.charCodeAt(0)) | 0;
  return hash % 2 === 0 ? 1 : -1;
}

function oppositeTeam(team) {
  return team === "alpha" ? "beta" : "alpha";
}

function cleanName(name) {
  return String(name)
    .replace(/[^\p{L}\p{N} ._-]/gu, "")
    .trim()
    .slice(0, 20) || "PLAYER";
}

function finite(value, fallback = 0) {
  return Number.isFinite(value) ? value : fallback;
}

function finiteInteger(value, fallback) {
  return Number.isInteger(value) ? value : fallback;
}

function clamp(value, minimum, maximum) {
  return Math.max(minimum, Math.min(maximum, value));
}
