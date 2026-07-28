import {
  CHARACTERS,
  FREEPLAY_DEFAULTS,
  buildCharacterKit,
  MATCH_TUNING,
  getCharacter,
  getMap,
  getMode,
  getRace,
} from "./live-content.mjs";

const EPSILON = 1e-8;
const COMBAT_ELEMENT_ALIASES = Object.freeze({
  stone: "earth", earth: "earth", nature: "earth",
  ember: "fire", fire: "fire",
  tide: "water", water: "water",
  gale: "wind", wind: "wind",
  frost: "ice", ice: "ice", cold: "ice",
  volt: "charge", lightning: "charge", electricity: "charge", charge: "charge",
  prism: "light", light: "light", refraction: "light",
  veil: "dark", null: "dark", void: "dark", dark: "dark",
});

function combatElement(value) {
  return COMBAT_ELEMENT_ALIASES[String(value ?? "").toLowerCase()] ?? "earth";
}
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
  let playerSpecs =
    Array.isArray(options.players) && options.players.length > 0
      ? options.players.map((spec) => ({ ...spec }))
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
  const mirrorLoadout = mode.id === "mirror"
    ? {
        activeAbilityIds: [...(playerSpecs[0]?.activeAbilityIds ?? [])],
        ultimateAbilityId: playerSpecs[0]?.ultimateAbilityId ?? null,
      }
    : null;
  if (mirrorLoadout) {
    playerSpecs = playerSpecs.map((spec) => ({ ...spec, ...mirrorLoadout }));
  }
  const entities = [];
  for (const [index, spec] of playerSpecs.entries()) {
    entities.push(createEntity(spec, index, map, mode.id));
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
            mode.id === "mirror"
              ? playerSpecs[0].characterId
              : options.botCharacterIds?.[index] ??
                CHARACTERS[(index + 1) % CHARACTERS.length].id,
          team,
          bot: true,
          ...(mirrorLoadout ?? {}),
        },
        entities.length,
        map,
        mode.id,
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
        mode.id,
      ),
    );
  }

  const state = {
    version: 3,
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
    rules: {
      hazardsEnabled: options.hazardsEnabled !== false,
      freeplay: mode.id === "freeplay",
      freeplaySettings: normalizeFreeplaySettings(
        mode.id === "freeplay" ? options.freeplaySettings : null,
      ),
    },
    destructibles: createModeDestructibles(mode, map),
    movementTrial: mode.id === "movement"
      ? createMovementTrialState(map, entities)
      : null,
    siege: mode.id === "siege"
      ? { score: {}, brokenIds: [], targetScore: mode.scoreLimit }
      : null,
    extraction: mode.id === "extraction"
      ? createExtractionState(map)
      : null,
    battleRoyale: mode.id === "battle_royale"
      ? {
          centerX: map.size.width / 2,
          centerY: map.size.height / 2,
          radius: MATCH_TUNING.battleRoyale.startRadius,
          elapsed: 0,
          pulseRemaining: 0,
          closing: false,
        }
      : null,
    round: 1,
    roundRemaining: 0,
    winner: null,
    objective: {
      x: map.objective.x,
      y: map.objective.y,
      radius: map.objective.radius,
      controllingTeam: null,
      contested: false,
      progress: { alpha: 0, beta: 0 },
    },
    wildmarch: createWildmarchState(mode, map),
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
    nextStructuralEventId: 1,
    events: [],
  };
  state.events.push({ type: "matchStart", modeId: mode.id, mapId: map.id });
  return state;
}

function normalizeFreeplaySettings(candidate) {
  const source = candidate && typeof candidate === "object" ? candidate : {};
  const settings = { ...FREEPLAY_DEFAULTS };
  for (const key of [
    "godMode", "endlessFlux", "endlessFlow", "instantCooldowns",
    "endlessUltimate", "friendlyFire", "destructibility", "reactions",
    "freezeBots", "showHitboxes", "showVelocity", "showMovementState",
    "showElementData",
  ]) {
    if (Object.prototype.hasOwnProperty.call(source, key)) settings[key] = source[key] === true;
  }
  for (const [key, min, max] of [
    ["damageMultiplier", 0, 5], ["speedMultiplier", 0.25, 3],
    ["gravityMultiplier", 0.25, 3], ["airControlMultiplier", 0.25, 3],
    ["timeScale", 0.05, 2],
  ]) settings[key] = clamp(finite(source[key], settings[key]), min, max);
  settings.networkProfile = typeof source.networkProfile === "string"
    ? source.networkProfile.slice(0, 32) : settings.networkProfile;
  return settings;
}

export function setFreeplaySettings(state, candidate = {}) {
  if (!state?.rules?.freeplay) return false;
  state.rules.freeplaySettings = normalizeFreeplaySettings({
    ...state.rules.freeplaySettings, ...candidate,
  });
  state.events.push({ type: "freeplaySettings", settings: { ...state.rules.freeplaySettings } });
  return true;
}

export function applyFreeplayAction(state, action, options = {}) {
  if (!state?.rules?.freeplay) return false;
  const map = getMap(state.mapId);
  if (action === "clear-projectiles") state.projectiles = [];
  else if (action === "clear-fields") { state.elementFields = []; state.mines = []; state.decoys = []; }
  else if (action === "rebuild") {
    state.destructibles = (map.destructibles ?? []).map((piece) => ({
      ...piece, maxHealth: piece.health, health: piece.health, destroyed: false, damageStage: 0,
    }));
  } else if (action === "reset-player") {
    const entity = state.entities.find((entry) => entry.id === options.entityId) ??
      state.entities.find((entry) => entry.human);
    if (!entity) return false;
    respawnEntity(entity, map);
  } else if (action === "reset-all") {
    state.projectiles = []; state.mines = []; state.elementFields = []; state.decoys = [];
    for (const entity of state.entities) respawnEntity(entity, map);
    applyFreeplayAction(state, "rebuild");
  } else if (["spawn-dummy", "spawn-moving-dummy", "spawn-hostile-bot", "spawn-allied-bot"].includes(action)) {
    const human = state.entities.find((entry) => entry.human) ?? state.entities[0];
    const hostile = action === "spawn-hostile-bot" || action.includes("dummy");
    const entity = createEntity({
      id: `freeplay-${state.tick}-${state.entities.length}`,
      name: action.includes("dummy") ? "DUMMY" : "SPAR",
      characterId: options.characterId ?? CHARACTERS[(state.entities.length + 3) % CHARACTERS.length].id,
      raceId: options.raceId,
      team: hostile ? oppositeTeam(human?.team ?? "alpha") : human?.team ?? "alpha",
      bot: action !== "spawn-dummy",
      neutral: action === "spawn-dummy",
    }, state.entities.length, map, state.modeId);
    entity.bot = action !== "spawn-dummy";
    entity.freeplayDummy = action.includes("dummy");
    entity.freezeInPlace = action === "spawn-dummy";
    state.entities.push(entity);
  } else return false;
  state.events.push({ type: "freeplayAction", action });
  return true;
}

function applyFreeplayEntityRules(state, entity) {
  const settings = state.rules?.freeplaySettings;
  if (!state.rules?.freeplay || !settings) return;
  if (settings.endlessFlux) entity.flux = entity.maxFlux;
  if (settings.endlessFlow) entity.flow = entity.maxFlow;
  if (settings.endlessUltimate) entity.ultimateCharge = entity.maxUltimate;
  if (settings.instantCooldowns) {
    entity.primaryCooldown = 0; entity.specialCooldown = 0;
    entity.defenseCooldown = 0; entity.mobilityCooldown = 0;
  }
  if (settings.freezeBots && entity.bot) { entity.vx = 0; entity.vy = 0; }
}

function updateBattleRoyale(state, delta, map) {
  const zone = state.battleRoyale;
  if (!zone || state.status !== "playing") return;
  zone.elapsed += delta;
  const tuning = MATCH_TUNING.battleRoyale;
  if (zone.elapsed > tuning.delay) {
    zone.closing = true;
    const progress = clamp((zone.elapsed - tuning.delay) / tuning.duration, 0, 1);
    zone.radius = tuning.startRadius + (tuning.endRadius - tuning.startRadius) * progress;
  }
  if (!zone.closing) return;
  zone.pulseRemaining = Math.max(0, finite(zone.pulseRemaining) - delta);
  if (zone.pulseRemaining === 0) {
    zone.pulseRemaining = 0.5;
    for (const entity of state.entities) {
      if (!entity.alive || entity.neutral) continue;
      const distance = Math.hypot(entity.x - zone.centerX, entity.y - zone.centerY);
      if (distance <= zone.radius) continue;
      damageEntity(state, entity, tuning.damagePerSecond * 0.5, null, { source: "storm" });
    }
  }
  zone.centerX = clamp(zone.centerX, map.size.inset, map.size.width - map.size.inset);
  zone.centerY = clamp(zone.centerY, map.size.inset, map.size.height - map.size.inset);
}

function updateLastTeamStanding(state, mode) {
  if (!mode.noRespawn || state.status !== "playing") return;
  const livingTeams = new Set(state.entities
    .filter((entity) => entity.alive && !entity.neutral)
    .map((entity) => entity.team));
  if (livingTeams.size === 1 && state.entities.some((entity) => !entity.neutral && !entity.alive)) {
    finishMatch(state, [...livingTeams][0]);
  } else if (livingTeams.size === 0) finishMatch(state, null);
}

function createModeDestructibles(mode, map) {
  const source = (map.destructibles ?? []).map((piece) => ({ ...piece }));
  if (mode.id === "siege" && source.length < 6) {
    const width = 92;
    const height = 34;
    const radiusX = Math.min(300, map.size.width * 0.22);
    const radiusY = Math.min(210, map.size.height * 0.22);
    const additions = [
      [-radiusX, -radiusY], [0, -radiusY], [radiusX, -radiusY],
      [-radiusX, radiusY], [0, radiusY], [radiusX, radiusY],
    ].slice(source.length);
    additions.forEach(([dx, dy], index) => source.push({
      id: `siege-${source.length + index + 1}`,
      x: map.objective.x + dx - width / 2,
      y: map.objective.y + dy - height / 2,
      width, height,
      material: index % 2 === 0 ? "stone" : "wood",
      level: index % 3 === 0 ? "upper" : "ground",
      health: index % 2 === 0 ? 120 : 80,
    }));
  }
  return source.map((piece, index) => ({
    ...piece,
    ownerTeam: mode.id === "siege" ? (index % 2 === 0 ? "alpha" : "beta") : piece.ownerTeam ?? null,
    maxHealth: piece.health,
    health: piece.health,
    destroyed: false,
    damageStage: 0,
  }));
}

function createMovementTrialState(map, entities) {
  const inset = map.size.inset ?? 44;
  const gates = [
    { id: "start", x: inset + 150, y: map.size.height / 2, radius: 58 },
    { id: "north", x: map.size.width * 0.38, y: inset + 150, radius: 58 },
    { id: "south", x: map.size.width * 0.62, y: map.size.height - inset - 150, radius: 58 },
    { id: "wall", x: map.size.width - inset - 150, y: map.size.height * 0.34, radius: 58 },
    { id: "finish", x: map.size.width / 2, y: map.size.height / 2, radius: 70 },
  ];
  return {
    gates,
    progress: Object.fromEntries(entities.filter((entity) => !entity.neutral).map((entity) => [entity.id, 0])),
    completedBy: null,
  };
}

function updateMovementTrial(state, mode) {
  const trial = state.movementTrial;
  if (!trial || mode.id !== "movement" || state.status !== "playing") return;
  for (const entity of state.entities) {
    if (!entity.alive || entity.neutral) continue;
    const index = trial.progress[entity.id] ?? 0;
    const gate = trial.gates[index];
    if (!gate) continue;
    const radius = getCharacter(entity.characterId).radius;
    if (Math.hypot(entity.x - gate.x, entity.y - gate.y) > gate.radius + radius) continue;
    const next = index + 1;
    trial.progress[entity.id] = next;
    state.events.push({
      type: "movementGate", entityId: entity.id, gateId: gate.id, index,
      x: gate.x, y: gate.y,
    });
    if (next >= trial.gates.length) {
      trial.completedBy = entity.id;
      state.score[entity.team] = 1;
      finishMatch(state, entity.team);
      return;
    }
  }
}

function createExtractionState(map) {
  return {
    required: 2,
    exit: {
      x: map.size.width - (map.size.inset ?? 44) - 125,
      y: map.size.height / 2,
      radius: 82,
    },
    drops: [],
    extractedBy: null,
  };
}

function updateExtraction(state, mode) {
  const extraction = state.extraction;
  if (!extraction || mode.id !== "extraction" || state.status !== "playing") return;
  for (const entity of state.entities) {
    if (!entity.alive || entity.neutral) continue;
    for (const drop of [...extraction.drops]) {
      if (Math.hypot(entity.x - drop.x, entity.y - drop.y) > 34 + getCharacter(entity.characterId).radius) continue;
      const available = Math.max(0, extraction.required - entity.cargo);
      const taken = Math.min(available, drop.amount);
      if (taken <= 0) continue;
      entity.cargo += taken;
      drop.amount -= taken;
      state.events.push({ type: "cargoPicked", entityId: entity.id, amount: taken, cargo: entity.cargo, x: drop.x, y: drop.y });
      if (drop.amount <= 0) extraction.drops = extraction.drops.filter((candidate) => candidate !== drop);
    }
    if (entity.cargo < extraction.required) continue;
    if (Math.hypot(entity.x - extraction.exit.x, entity.y - extraction.exit.y) > extraction.exit.radius + getCharacter(entity.characterId).radius) continue;
    extraction.extractedBy = entity.id;
    state.score[entity.team] = 1;
    state.events.push({ type: "extracted", entityId: entity.id, team: entity.team, cargo: entity.cargo, x: extraction.exit.x, y: extraction.exit.y });
    finishMatch(state, entity.team);
    return;
  }
}

function scoreSiegeBreak(state, piece, ownerId) {
  if (!state.siege || state.status !== "playing") return;
  if (state.siege.brokenIds.includes(piece.id)) return;
  state.siege.brokenIds.push(piece.id);
  const attacker = state.entities.find((entity) => entity.id === ownerId);
  if (!attacker || attacker.neutral || attacker.team === piece.ownerTeam) return;
  const points = Math.max(20, Math.round(piece.maxHealth * 0.5));
  state.siege.score[attacker.team] = (state.siege.score[attacker.team] ?? 0) + points;
  state.score[attacker.team] = (state.score[attacker.team] ?? 0) + points;
  state.events.push({ type: "siegeScore", entityId: attacker.id, team: attacker.team, points, structuralId: piece.id });
  const enemyStructuresRemain = state.destructibles.some((candidate) => !candidate.destroyed && candidate.ownerTeam !== attacker.team);
  if (state.siege.score[attacker.team] >= state.siege.targetScore || !enemyStructuresRemain) {
    finishMatch(state, attacker.team);
  }
}

function createEntity(spec, index, map, modeId = "freeplay") {
  const agent = getCharacter(spec.characterId);
  const race = getRace(spec.raceId ?? agent.homeRaceId);
  const kit = buildCharacterKit({
    characterId: agent.id,
    modeId,
    activeAbilityIds: spec.activeAbilityIds,
    ultimateAbilityId: spec.ultimateAbilityId,
  });
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
    size: agent.size ?? 3,
    activeAbilityIds: [...kit.activeAbilityIds],
    ultimateAbilityId: kit.ultimateAbilityId,
    kit: {
      special: { ...kit.special },
      defense: { ...kit.defense },
      mobility: { ...kit.mobility },
      ultimate: kit.ultimate ? { ...kit.ultimate } : null,
      skillPoints: kit.skillPoints,
    },
    loadoutErrors: [...kit.errors],
    speedScale: race.speed,
    team: normalizeEntityTeam(spec.team, modeId),
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
    maxUltimate: kit.ultimate?.chargeRequired ?? 0,
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
    airborneRemaining: 0,
    airJumpsRemaining: race.id === "scaleheir" ? 2 : 1,
    airDodgeCooldown: 0,
    airDodgeRemaining: 0,
    airDodgeX: facingX,
    airDodgeY: 0,
    vaultWindow: 0,
    superglideCooldown: 0,
    movementState: "grounded",
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
    grazeCooldown: 0,
    surface: "normal",
    elementForceX: 0,
    elementForceY: 0,
    interruptRemaining: 0,
    dashHitIds: [],
    kills: 0,
    deaths: 0,
    cargo: 0,
    mendDelay: 0,
    reactionCharge: 0,
    raceArmor: 0,
    inFire: false,
    inOwnWater: false,
    onOwnEarth: false,
    lives: 3,
    lastAttackerId: null,
    botThinkRemaining: 0,
    botCommand: { ...IDLE_COMMAND },
  };
}

function runtimeCharacter(entity) {
  const base = getCharacter(entity.characterId);
  if (!entity.kit) return base;
  return {
    ...base,
    special: entity.kit.special ?? base.special,
    tactical: entity.kit.special ?? base.tactical,
    defense: entity.kit.defense ?? base.defense,
    mobility: entity.kit.mobility ?? base.mobility,
    ultimate: entity.kit.ultimate ?? base.ultimate,
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
    state.modeId,
  );
  state.entities.push(entity);
  state.events.push({ type: "playerJoined", entityId: entity.id });
  return entity;
}

export function configureMatchPlayer(state, entityId, candidate = {}) {
  const entity = state?.entities?.find((entry) => entry.id === entityId);
  if (!entity) return { ok: false, errors: ["player not found"] };
  const character = getCharacter(candidate.characterId ?? entity.characterId);
  const race = getRace(candidate.raceId ?? entity.raceId ?? character.homeRaceId);
  const kit = buildCharacterKit({
    characterId: character.id,
    modeId: state.modeId,
    activeAbilityIds: candidate.activeAbilityIds ?? entity.activeAbilityIds,
    ultimateAbilityId: candidate.ultimateAbilityId ?? entity.ultimateAbilityId,
  });
  if (kit.errors.length > 0) return { ok: false, errors: [...kit.errors] };

  entity.characterId = character.id;
  entity.raceId = race.id;
  entity.size = character.size ?? 3;
  entity.activeAbilityIds = [...kit.activeAbilityIds];
  entity.ultimateAbilityId = kit.ultimateAbilityId;
  entity.kit = {
    special: { ...kit.special },
    defense: { ...kit.defense },
    mobility: { ...kit.mobility },
    ultimate: kit.ultimate ? { ...kit.ultimate } : null,
    skillPoints: kit.skillPoints,
  };
  entity.loadoutErrors = [];
  entity.speedScale = race.speed;
  entity.maxHealth = Math.round(character.health * race.health);
  entity.maxFlow = MATCH_TUNING.flow.maximum * race.flow;
  entity.maxFlux = MATCH_TUNING.flux.maximum * race.flux;
  entity.maxUltimate = kit.ultimate?.chargeRequired ?? 0;
  if (candidate.restore === true) {
    entity.health = entity.maxHealth;
    entity.flow = entity.maxFlow;
    entity.flux = entity.maxFlux;
    entity.ultimateCharge = entity.maxUltimate;
  } else {
    entity.health = clamp(entity.health, 1, entity.maxHealth);
    entity.flow = clamp(entity.flow, 0, entity.maxFlow);
    entity.flux = clamp(entity.flux, 0, entity.maxFlux);
    entity.ultimateCharge = clamp(entity.ultimateCharge, 0, entity.maxUltimate);
  }
  state.events.push({
    type: "playerConfigured", entityId: entity.id,
    characterId: character.id, raceId: race.id,
    activeAbilityIds: [...entity.activeAbilityIds],
    ultimateAbilityId: entity.ultimateAbilityId,
  });
  return {
    ok: true, characterId: character.id, raceId: race.id,
    activeAbilityIds: [...entity.activeAbilityIds],
    ultimateAbilityId: entity.ultimateAbilityId,
    skillPoints: kit.skillPoints,
  };
}

export function removeMatchPlayer(state, entityId) {
  const entity = state.entities.find((candidate) => candidate.id === entityId);
  if (!entity) return false;
  releaseMatchPlayerObjectives(state, entityId, "leave");
  state.entities = state.entities.filter((candidate) => candidate !== entity);
  state.projectiles = state.projectiles.filter(
    (projectile) => projectile.ownerId !== entityId,
  );
  state.mines = state.mines.filter((mine) => mine.ownerId !== entityId);
  state.events.push({ type: "playerLeft", entityId });
  return true;
}

export function releaseMatchPlayerObjectives(
  state,
  entityId,
  reason = "disconnect",
) {
  const entity = state.entities.find((candidate) => candidate.id === entityId);
  if (!entity) return false;
  const carried =
    state.wildmarch?.seal.status === "carried" &&
    state.wildmarch.seal.carrierId === entityId;
  dropCarriedWayseal(state, entity, reason);
  return carried;
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
  let boundedDelta = Math.min(delta, MATCH_TUNING.maxFrameDelta);
  if (state.rules?.freeplay) {
    boundedDelta *= state.rules.freeplaySettings?.timeScale ?? 1;
  }
  const mode = getMode(state.modeId);
  const map = getMap(state.mapId);
  state.tick += 1;

  if (state.status === "round-over") {
    state.roundRemaining = Math.max(0, state.roundRemaining - boundedDelta);
    if (state.roundRemaining === 0) resetRound(state, map, mode);
    return state;
  }

  for (const entity of state.entities) {
    tickEntity(entity, boundedDelta);
    applyFreeplayEntityRules(state, entity);
  }
  updateElementFields(state, boundedDelta);
  updateRaceTraits(state, boundedDelta);
  updateDecoys(state, boundedDelta);
  updateBattleRoyale(state, boundedDelta, map);
  const activeMap = withDynamicGeometry(map, state);
  for (const entity of state.entities) {
    if (!entity.alive) {
      updateRespawn(state, entity, boundedDelta, map, mode);
      continue;
    }
    const command = entity.bot
      ? state.rules?.freeplaySettings?.freezeBots
        ? IDLE_COMMAND
        : updateBotCommand(state, entity, boundedDelta, map)
      : sanitizeCommand(commands[entity.id]);
    updateEntity(state, entity, command, boundedDelta, activeMap);
  }

  resolveUnitCollisions(state, activeMap);
  resolveMapCollisions(state, activeMap);
  updateShrines(state, boundedDelta);
  updateMines(state, boundedDelta, activeMap);
  updateProjectiles(state, boundedDelta, activeMap);
  updateHazards(state, boundedDelta);
  updateWildmarch(state, boundedDelta, map);
  updateMovementTrial(state, mode);
  updateExtraction(state, mode);
  updateObjective(state, boundedDelta, mode, map);
  updateLastTeamStanding(state, mode);
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

function createWildmarchState(mode, map) {
  if (mode.id !== "convergence") return null;
  return {
    routes: map.wildmarch.routes.map((route) => ({ ...route })),
    activeRouteId: null,
    routeRemaining: 0,
    seal: {
      status: "dormant",
      x: map.objective.x,
      y: map.objective.y,
      carrierId: null,
      returnRemaining: 0,
    },
  };
}

function updateWildmarch(state, delta, map) {
  const wildmarch = state.wildmarch;
  if (!wildmarch) return;
  if (wildmarch.routeRemaining > 0) {
    wildmarch.routeRemaining = Math.max(0, wildmarch.routeRemaining - delta);
    if (wildmarch.routeRemaining === 0) {
      const previousRouteId = wildmarch.activeRouteId;
      wildmarch.activeRouteId = null;
      wildmarch.seal.status = "dormant";
      wildmarch.seal.carrierId = null;
      wildmarch.seal.returnRemaining = 0;
      wildmarch.seal.x = map.objective.x;
      wildmarch.seal.y = map.objective.y;
      setObjectivePosition(state, map.objective);
      state.events.push({
        type: "waysealReturned",
        routeId: previousRouteId,
        x: map.objective.x,
        y: map.objective.y,
      });
    }
    return;
  }

  const seal = wildmarch.seal;
  if (seal.status === "dormant") return;
  seal.returnRemaining = Math.max(0, seal.returnRemaining - delta);
  if (seal.returnRemaining === 0) {
    seal.status = "dormant";
    seal.carrierId = null;
    seal.x = map.objective.x;
    seal.y = map.objective.y;
    state.events.push({
      type: "waysealReturned",
      routeId: null,
      x: seal.x,
      y: seal.y,
    });
    return;
  }

  if (seal.status === "carried") {
    const carrier = state.entities.find(
      (entity) =>
        entity.id === seal.carrierId && entity.alive && !entity.neutral,
    );
    if (!carrier) {
      seal.status = "grounded";
      seal.carrierId = null;
      return;
    }
    seal.x = carrier.x;
    seal.y = carrier.y;
    const route = wildmarch.routes.find(
      (candidate) =>
        Math.hypot(carrier.x - candidate.x, carrier.y - candidate.y) <=
          candidate.radius + getCharacter(carrier.characterId).radius,
    );
    if (route) activateWildmarchRoute(state, carrier, route);
    return;
  }

  const claimant = state.entities
    .filter(
      (entity) =>
        entity.alive && !entity.neutral && entity.spawnProtection === 0 &&
        Math.hypot(entity.x - seal.x, entity.y - seal.y) <=
          MATCH_TUNING.wildmarch.pickupRadius +
            getCharacter(entity.characterId).radius,
    )
    .sort((left, right) => {
      const distanceDifference =
        squaredDistance(left, seal) - squaredDistance(right, seal);
      return distanceDifference || left.id.localeCompare(right.id);
    })[0];
  if (!claimant) return;
  seal.status = "carried";
  seal.carrierId = claimant.id;
  seal.x = claimant.x;
  seal.y = claimant.y;
  state.events.push({
    type: "waysealClaimed",
    entityId: claimant.id,
    team: claimant.team,
    x: claimant.x,
    y: claimant.y,
  });
}

function releaseWayseal(state, warden) {
  const wildmarch = state.wildmarch;
  if (
    !wildmarch || wildmarch.routeRemaining > 0 ||
    wildmarch.seal.status !== "dormant"
  ) return;
  wildmarch.seal.status = "grounded";
  wildmarch.seal.x = warden.x;
  wildmarch.seal.y = warden.y;
  wildmarch.seal.carrierId = null;
  wildmarch.seal.returnRemaining = MATCH_TUNING.wildmarch.returnDuration;
  state.events.push({
    type: "waysealReleased",
    entityId: warden.id,
    x: warden.x,
    y: warden.y,
  });
}

function dropCarriedWayseal(state, carrier, reason) {
  const seal = state.wildmarch?.seal;
  if (!seal || seal.status !== "carried" || seal.carrierId !== carrier.id) {
    return;
  }
  seal.status = "grounded";
  seal.carrierId = null;
  seal.x = carrier.x;
  seal.y = carrier.y;
  state.events.push({
    type: "waysealDropped",
    entityId: carrier.id,
    reason,
    x: carrier.x,
    y: carrier.y,
  });
}

function activateWildmarchRoute(state, carrier, route) {
  const wildmarch = state.wildmarch;
  wildmarch.activeRouteId = route.id;
  wildmarch.routeRemaining = MATCH_TUNING.wildmarch.routeDuration;
  wildmarch.seal.status = "routed";
  wildmarch.seal.carrierId = null;
  wildmarch.seal.returnRemaining = 0;
  wildmarch.seal.x = route.x;
  wildmarch.seal.y = route.y;
  setObjectivePosition(state, route);
  state.events.push({
    type: "waysealRouted",
    entityId: carrier.id,
    team: carrier.team,
    routeId: route.id,
    routeName: route.name,
    duration: wildmarch.routeRemaining,
    x: route.x,
    y: route.y,
  });
}

function setObjectivePosition(state, source) {
  state.objective.x = source.x;
  state.objective.y = source.y;
  state.objective.radius = source.radius;
  state.objective.controllingTeam = null;
  state.objective.contested = false;
}

function tickEntity(entity, delta) {
  const wasHopping = entity.hopRemaining > 0;
  const wasAirborne = entity.airborneRemaining > 0;
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
    "airborneRemaining",
    "airDodgeCooldown",
    "airDodgeRemaining",
    "vaultWindow",
    "superglideCooldown",
    "slideCooldown",
    "slideRemaining",
    "wallContactRemaining",
    "interruptRemaining",
    "fluxRecoveryDelay",
    "fluxWarningCooldown",
    "counterStrafeCooldown",
    "grazeCooldown",
    "passiveRemaining",
    "passiveCueCooldown",
    "mendDelay",
    "ultimateWindupRemaining",
  ]) {
    entity[key] = Math.max(0, finite(entity[key]) - delta);
  }
  if (wasHopping && entity.hopRemaining === 0) {
    entity.landingRemaining = MATCH_TUNING.flow.landingWindow;
  }
  if (wasAirborne && entity.airborneRemaining === 0) {
    entity.airJumpsRemaining = entity.raceId === "scaleheir" ? 2 : 1;
    entity.movementState = "grounded";
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
  const agent = runtimeCharacter(entity);
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

  const usedAirDodge = tryAirDodge(state, entity, command);
  const usedSuperglide = !usedAirDodge && trySuperglide(state, entity, command);
  if (
    !usedAirDodge && !usedSuperglide && command.mobility &&
    entity.mobilityCooldown === 0 &&
    spendFlux(state, entity, agent.mobility)
  ) {
    startMobility(state, entity, command, agent, map);
  }
  if (!usedAirDodge && !usedSuperglide && !command.mobility && !trySlide(state, entity, command)) {
    tryHop(state, entity, command);
  }
  moveEntity(state, entity, command, agent, delta, map);
  if (
    !usedAirDodge && command.defend &&
    entity.defenseCooldown === 0 &&
    spendFlux(state, entity, agent.defense)
  ) {
    entity.defenseRemaining = agent.defense.duration;
    entity.defenseCooldown = agent.defense.cooldown;
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
    entity.primaryCooldown =
      state.modeId === "training" && entity.bot && state.tutorial.step === 2
        ? MATCH_TUNING.training.pressureCooldown
        : agent.primary.cooldown;
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
  if (!state.rules?.freeplaySettings?.endlessFlux) entity.flux -= cost;
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
  entity.hopRemaining = 0;
  entity.slideRemaining = 0;
  entity.airDodgeRemaining = 0;
  entity.vaultWindow = 0;
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

function tryAirDodge(state, entity, command) {
  const movement = MATCH_TUNING.movement;
  if (
    !command.hop || !command.defend || entity.airborneRemaining <= 0 ||
    entity.mobilityRemaining > 0 || entity.slideRemaining > 0 ||
    entity.airDodgeCooldown > 0 || entity.airDodgeRemaining > 0 ||
    entity.flow < movement.airDodgeCost
  ) return false;
  let direction = command.moveX !== 0 || command.moveY !== 0
    ? normalizeDirection(command.moveX, command.moveY)
    : normalizeDirection(entity.facingX, entity.facingY);
  if (direction.x === 0 && direction.y === 0) direction = { x: 1, y: 0 };
  entity.flow -= movement.airDodgeCost;
  entity.flowRecoveryDelay = MATCH_TUNING.flow.recoveryDelay;
  entity.airDodgeCooldown = movement.airDodgeCooldown;
  entity.airDodgeRemaining = movement.airDodgeDuration;
  entity.airDodgeX = direction.x;
  entity.airDodgeY = direction.y;
  entity.airJumpsRemaining = 0;
  const wavedash = entity.landingRemaining > 0;
  if (wavedash) {
    entity.airDodgeRemaining = 0;
    entity.slideRemaining = movement.wavedashDuration;
    entity.slideCooldown = Math.max(entity.slideCooldown, movement.airDodgeCooldown);
    entity.slideX = direction.x;
    entity.slideY = direction.y;
    entity.vx = direction.x * movement.wavedashSpeed;
    entity.vy = direction.y * movement.wavedashSpeed;
    entity.landingRemaining = 0;
    entity.movementState = "wavedash";
  } else entity.movementState = "air-dodge";
  state.events.push({
    type: wavedash ? "wavedash" : "airDodge", entityId: entity.id,
    x: entity.x, y: entity.y, dx: direction.x, dy: direction.y,
  });
  primeMovementPassive(state, entity, getCharacter(entity.characterId), wavedash ? "WAVEDASH" : "AIR DODGE");
  return true;
}

function trySuperglide(state, entity, command) {
  const movement = MATCH_TUNING.movement;
  if (
    !command.hop || !command.sprint || entity.vaultWindow <= 0 ||
    entity.mobilityRemaining > 0 || entity.slideRemaining > 0 ||
    entity.airDodgeRemaining > 0 || entity.superglideCooldown > 0 ||
    entity.flow < movement.superglideCost
  ) return false;
  let direction = command.moveX !== 0 || command.moveY !== 0
    ? normalizeDirection(command.moveX, command.moveY)
    : normalizeDirection(entity.facingX, entity.facingY);
  if (direction.x === 0 && direction.y === 0) direction = { x: 1, y: 0 };
  entity.flow -= movement.superglideCost;
  entity.flowRecoveryDelay = MATCH_TUNING.flow.recoveryDelay;
  entity.hopRemaining = movement.superglideDuration;
  entity.hopCooldown = MATCH_TUNING.flow.hopCooldown;
  entity.airborneRemaining = movement.airborneWindow /
    (state.rules?.freeplaySettings?.gravityMultiplier ?? 1);
  entity.hopX = direction.x; entity.hopY = direction.y;
  entity.hopCarryX = 0; entity.hopCarryY = 0;
  entity.vaultWindow = 0;
  entity.superglideCooldown = movement.superglideCooldown;
  entity.movementState = "superglide";
  state.events.push({ type: "superglide", entityId: entity.id, x: entity.x, y: entity.y, dx: direction.x, dy: direction.y });
  primeMovementPassive(state, entity, getCharacter(entity.characterId), "SUPERGLIDE");
  return true;
}

function tryHop(state, entity, command) {
  const flow = MATCH_TUNING.flow;
  if (
    !command.hop ||
    entity.hopCooldown > 0 ||
    entity.hopRemaining > 0 ||
    entity.airDodgeRemaining > 0 ||
    entity.slideRemaining > 0 ||
    entity.mobilityRemaining > 0
  ) {
    return;
  }
  const doubleJump = entity.airborneRemaining > 0;
  const cost = doubleJump ? MATCH_TUNING.movement.doubleJumpCost : flow.hopCost;
  if (doubleJump && entity.airJumpsRemaining <= 0) return;
  if (entity.flow < cost) return;
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
  entity.flow -= cost;
  entity.flowRecoveryDelay = flow.recoveryDelay;
  entity.hopCooldown = flow.hopCooldown;
  entity.hopRemaining = flow.hopDuration;
  entity.airborneRemaining = MATCH_TUNING.movement.airborneWindow /
    (state.rules?.freeplaySettings?.gravityMultiplier ?? 1);
  if (doubleJump) entity.airJumpsRemaining -= 1;
  entity.movementState = doubleJump ? "double-jump" : "airborne";
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
    type: wallKick ? "wallKick" : doubleJump ? "doubleJump" : "hop",
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
  if (entity.airDodgeRemaining > 0) {
    entity.vx = entity.airDodgeX * MATCH_TUNING.movement.airDodgeSpeed;
    entity.vy = entity.airDodgeY * MATCH_TUNING.movement.airDodgeSpeed;
    entity.sprinting = false;
    entity.movementState = "air-dodge";
  } else if (entity.mobilityRemaining > 0) {
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
    if (moveX !== 0 || moveY !== 0) {
      const raceSteering = entity.raceId === "sylph"
        ? 1.45
        : entity.raceId === "elf"
          ? 1.22
          : entity.inOwnWater && entity.raceId === "seakin"
            ? 1.3
            : 1;
      const steering = MATCH_TUNING.movement.airSteering * raceSteering *
        (state.rules?.freeplaySettings?.airControlMultiplier ?? 1);
      const redirected = normalizeDirection(
        entity.hopX * (1 - steering) + moveX * steering,
        entity.hopY * (1 - steering) + moveY * steering,
      );
      entity.hopX = redirected.x;
      entity.hopY = redirected.y;
    }
    const speed = entity.hopWallKick
      ? MATCH_TUNING.flow.wallKickSpeed
      : entity.movementState === "double-jump"
        ? MATCH_TUNING.movement.doubleJumpSpeed
        : entity.movementState === "superglide"
          ? MATCH_TUNING.movement.superglideSpeed
          : MATCH_TUNING.flow.hopSpeed;
    entity.vx = entity.hopX * speed + entity.hopCarryX;
    entity.vy = entity.hopY * speed + entity.hopCarryY;
    entity.sprinting = false;
  } else {
    const moving = moveX !== 0 || moveY !== 0;
    const sprinting = command.sprint && moving && entity.flow > 0;
    const speed =
      agent.speed * entity.speedScale *
      (state.rules?.freeplaySettings?.speedMultiplier ?? 1) *
      (sprinting ? MATCH_TUNING.flow.sprintMultiplier : 1) *
      (entity.surface === "magma" ? MATCH_TUNING.elements.magmaSpeed : 1) *
      (entity.surface === "mud" ? MATCH_TUNING.elements.mudSpeed : 1) *
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
    entity.vaultWindow = MATCH_TUNING.movement.vaultMemory;
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
  if (field.source === "tactical") {
    markTutorialTacticalProof(state, owner, `${element}-terrain`);
  }
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

function withDynamicGeometry(map, state) {
  const earth = state.elementFields
    .filter((field) => field.element === "earth")
    .map((field) => ({
      x: field.x,
      y: field.y,
      width: field.width,
      height: field.height,
      source: "element",
    }));
  const structures = (state.destructibles ?? [])
    .filter((piece) => !piece.destroyed)
    .map((piece) => ({
      x: piece.x, y: piece.y, width: piece.width, height: piece.height,
      source: "destructible", structuralId: piece.id,
    }));
  if (earth.length === 0 && structures.length === 0) return map;
  return { ...map, obstacles: [...map.obstacles, ...structures, ...earth] };
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
    entity.wet = false;
    entity.chilled = false;
    entity.revealed = false;
    entity.shadowed = false;
    entity.inFire = false;
    entity.inOwnWater = false;
    entity.onOwnEarth = false;
    entity.raceArmor = 0;
  }
  for (const field of state.elementFields) {
    field.duration -= delta;
    field.pulseRemaining = Math.max(0, finite(field.pulseRemaining) - delta);
  }

  const activeFields = state.elementFields.filter((field) => field.duration > 0);
  const removed = new Set();
  const spawned = [];
  const reactionsEnabled = !state.rules?.freeplay ||
    state.rules.freeplaySettings?.reactions !== false;
  const fields = (element) => activeFields.filter(
    (field) => field.element === element && !removed.has(field.id),
  );
  const centerOf = (field) => field.element === "earth"
    ? { x: field.x + field.width / 2, y: field.y + field.height / 2 }
    : { x: field.x, y: field.y };
  const overlap = (left, right) => {
    if (left.element === "earth") {
      const center = centerOf(right);
      return circleRectangleOverlap(center, right.radius ?? 0, left);
    }
    if (right.element === "earth") {
      const center = centerOf(left);
      return circleRectangleOverlap(center, left.radius ?? 0, right);
    }
    return Math.hypot(left.x - right.x, left.y - right.y) <=
      (left.radius ?? 0) + (right.radius ?? 0);
  };
  const reactionOwner = (...candidates) => {
    for (const field of candidates) {
      const owner = state.entities.find((entity) => entity.id === field?.ownerId);
      if (owner) return owner;
    }
    return state.entities[0];
  };
  const spawnReaction = (owner, element, spec) => {
    if (!owner) return;
    const before = state.elementFields.length;
    createElementField(state, owner, element, {
      ownerId: null,
      team: "neutral",
      source: "reaction",
      ...spec,
    }, false);
    spawned.push(state.elementFields[before]);
  };
  const emitReaction = (reaction, left, right, extra = {}) => {
    const a = centerOf(left);
    const b = centerOf(right);
    for (const field of [left, right]) {
      const owner = state.entities.find((entity) => entity.id === field?.ownerId);
      if (owner?.raceId === "nymph") owner.reactionCharge = 1;
    }
    state.events.push({
      type: "elementReaction",
      reaction,
      x: (a.x + b.x) / 2,
      y: (a.y + b.y) / 2,
      ...extra,
    });
  };

  // Wind changes geometry without consuming either field.
  if (reactionsEnabled) {
    for (const wind of fields("wind")) {
      for (const fire of fields("fire")) {
        if (!overlap(wind, fire)) continue;
        const direction = windDirectionAt(wind, fire.x, fire.y);
        const speed = wind.shape === "vortex"
          ? MATCH_TUNING.elements.vortexFireSpeed
          : MATCH_TUNING.elements.windForce * 0.32;
        fire.x += direction.x * speed * delta;
        fire.y += direction.y * speed * delta;
      }
    }

    // Heat and cold consume each other and leave bounded meltwater/steam.
    for (const fire of fields("fire")) {
      for (const ice of fields("ice")) {
        if (removed.has(fire.id) || removed.has(ice.id) || !overlap(fire, ice)) continue;
        removed.add(fire.id);
        removed.add(ice.id);
        const a = centerOf(fire);
        const b = centerOf(ice);
        const owner = reactionOwner(fire, ice);
        spawnReaction(owner, "water", {
          x: (a.x + b.x) / 2,
          y: (a.y + b.y) / 2,
          radius: Math.min(MATCH_TUNING.elements.waterRadius, (fire.radius + ice.radius) * 0.42),
          duration: MATCH_TUNING.elements.waterDuration * 0.55,
          directionX: 0,
          directionY: 0,
        });
        spawnReaction(owner, "vapor", {
          x: (a.x + b.x) / 2,
          y: (a.y + b.y) / 2,
          radius: MATCH_TUNING.elements.vaporRadius * 0.72,
          duration: MATCH_TUNING.elements.vaporDuration * 0.6,
        });
        emitReaction("melt", fire, ice);
      }
    }

    // Water reinforces an overlapping ice field and is consumed.
    for (const water of fields("water")) {
      for (const ice of fields("ice")) {
        if (removed.has(water.id) || removed.has(ice.id) || !overlap(water, ice)) continue;
        removed.add(water.id);
        ice.duration = Math.min(
          MATCH_TUNING.elements.iceDuration * 1.35,
          ice.duration + water.duration * 0.5,
        );
        emitReaction("freeze", water, ice);
      }
    }

    // Water can redirect a directed flame or quench it into vapor.
    for (const fire of fields("fire")) {
      for (const water of fields("water")) {
        if (removed.has(fire.id) || removed.has(water.id) || !overlap(fire, water)) continue;
        const distance = Math.hypot(water.x - fire.x, water.y - fire.y);
        const directed = Number.isFinite(water.directionX) && Number.isFinite(water.directionY) &&
          (water.directionX !== 0 || water.directionY !== 0) &&
          distance > fire.radius * 0.25;
        if (directed) {
          fire.x += water.directionX * water.radius * 0.72;
          fire.y += water.directionY * water.radius * 0.72;
          fire.duration *= 0.58;
          emitReaction("redirect", fire, water);
          continue;
        }
        removed.add(fire.id);
        removed.add(water.id);
        const owner = reactionOwner(fire, water);
        spawnReaction(owner, "vapor", {
          x: (fire.x + water.x) / 2,
          y: (fire.y + water.y) / 2,
          radius: MATCH_TUNING.elements.vaporRadius,
          duration: MATCH_TUNING.elements.vaporDuration,
        });
        emitReaction("vapor", fire, water);
      }
    }

    // Water erodes solid earth into a slower, non-damaging mud field.
    for (const earth of fields("earth")) {
      for (const water of fields("water")) {
        if (removed.has(earth.id) || removed.has(water.id) || !overlap(earth, water)) continue;
        removed.add(earth.id);
        removed.add(water.id);
        const c = centerOf(earth);
        spawnReaction(reactionOwner(earth, water), "mud", {
          x: c.x,
          y: c.y,
          radius: MATCH_TUNING.elements.mudRadius,
          duration: MATCH_TUNING.elements.mudDuration,
        });
        emitReaction("mud", earth, water);
      }
    }

    // Fire consumes authored earth cover into a neutral magma slow.
    for (const fire of fields("fire")) {
      for (const earth of fields("earth")) {
        if (removed.has(fire.id) || removed.has(earth.id) || !overlap(fire, earth)) continue;
        removed.add(fire.id);
        removed.add(earth.id);
        spawnReaction(reactionOwner(fire, earth), "magma", {
          x: fire.x,
          y: fire.y,
          radius: MATCH_TUNING.elements.magmaRadius,
          duration: MATCH_TUNING.elements.magmaDuration,
        });
        emitReaction("magma", fire, earth);
      }
    }

    // Charge is consumed into a conducted pulse while water remains wet.
    for (const charge of fields("charge")) {
      for (const water of fields("water")) {
        if (removed.has(charge.id) || removed.has(water.id) || !overlap(charge, water)) continue;
        removed.add(charge.id);
        spawnReaction(reactionOwner(charge, water), "charge", {
          x: water.x,
          y: water.y,
          radius: Math.max(water.radius, MATCH_TUNING.elements.chargeRadius),
          duration: MATCH_TUNING.elements.chargeDuration * 0.72,
          pulseRemaining: 0,
          shape: "conducted",
        });
        emitReaction("conduct", charge, water);
      }
    }

    // Light refracts once through water or ice and widens its readable ray field.
    for (const light of fields("light")) {
      const medium = [...fields("water"), ...fields("ice")].find(
        (candidate) => !removed.has(candidate.id) && overlap(light, candidate),
      );
      if (!medium || removed.has(light.id)) continue;
      removed.add(light.id);
      const c = centerOf(medium);
      spawnReaction(reactionOwner(light, medium), "light", {
        x: c.x,
        y: c.y,
        radius: Math.max(light.radius, medium.radius ?? 0) * 1.2,
        duration: MATCH_TUNING.elements.lightDuration * 0.7,
        directionX: -(light.directionY ?? 0),
        directionY: light.directionX ?? 1,
        shape: "refracted",
      });
      emitReaction("refract", light, medium, { medium: medium.element });
    }

    // Light and dark cancel their centers but leave a short visible boundary.
    for (const light of fields("light")) {
      for (const dark of fields("dark")) {
        if (removed.has(light.id) || removed.has(dark.id) || !overlap(light, dark)) continue;
        removed.add(light.id);
        removed.add(dark.id);
        const a = centerOf(light);
        const b = centerOf(dark);
        spawnReaction(reactionOwner(light, dark), "shadow-edge", {
          x: (a.x + b.x) / 2,
          y: (a.y + b.y) / 2,
          radius: MATCH_TUNING.elements.shadowEdgeRadius,
          duration: MATCH_TUNING.elements.shadowEdgeDuration,
        });
        emitReaction("attenuate", light, dark);
      }
    }

    // Dark decay is costly and consumes the dark field while weakening earth.
    for (const dark of fields("dark")) {
      for (const earth of fields("earth")) {
        if (removed.has(dark.id) || removed.has(earth.id) || !overlap(dark, earth)) continue;
        removed.add(dark.id);
        earth.duration *= 0.35;
        emitReaction("decay", dark, earth);
      }
    }
  }

  const coldAshes = [];
  state.elementFields = state.elementFields.filter((field) => {
    if (removed.has(field.id)) return false;
    if (field.duration <= 0) {
      const owner = state.entities.find((entity) => entity.id === field.ownerId);
      if (field.element === "fire" && owner && getCharacter(owner.characterId).passive?.name === "COLD ASHES") {
        coldAshes.push({ owner, field });
      }
      state.events.push({ type: "elementClear", fieldId: field.id, element: field.element });
      return false;
    }
    return true;
  });
  for (const { owner, field } of coldAshes) {
    createElementField(state, owner, "ice", {
      x: field.x, y: field.y, radius: Math.max(32, (field.radius ?? 60) * 0.68),
      duration: 1.1, source: "cold-ashes", harmless: true,
    }, false);
    state.events.push({ type: "coldAshes", entityId: owner.id, x: field.x, y: field.y });
  }

  for (const field of state.elementFields) {
    if (field.element === "earth") {
      for (const entity of state.entities) {
        if (!entity.alive || !circleRectangleOverlap(entity, getCharacter(entity.characterId).radius, field)) continue;
        if (field.team === entity.team) entity.onOwnEarth = true;
      }
      continue;
    }
    for (const entity of state.entities) {
      if (!entity.alive || Math.hypot(entity.x - field.x, entity.y - field.y) >
        (field.radius ?? 0) + getCharacter(entity.characterId).radius) continue;

      if (field.element === "ice") { entity.surface = "ice"; entity.chilled = true; }
      if (field.element === "magma") entity.surface = "magma";
      if (field.element === "mud") entity.surface = "mud";
      if (field.element === "water") {
        entity.wet = true;
        if (field.team === entity.team) entity.inOwnWater = true;
      }
      if (field.element === "fire") entity.inFire = true;
      if (field.element === "light") { entity.revealed = true; entity.shadowed = false; }
      if (field.element === "dark") entity.shadowed = true;
      if (field.element === "shadow-edge") entity.revealed = true;

      if (field.element === "fire" && field.team === entity.team &&
        getCharacter(entity.characterId).passive?.kind === "field-temper") {
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
      if (field.element === "dark") {
        const direction = normalizeDirection(field.x - entity.x, field.y - entity.y);
        entity.elementForceX += direction.x * MATCH_TUNING.elements.darkPull;
        entity.elementForceY += direction.y * MATCH_TUNING.elements.darkPull;
      }
      if (field.element === "water" && field.team === entity.team) {
        entity.flow = Math.min(
          entity.maxFlow,
          entity.flow + MATCH_TUNING.elements.waterFlowPerSecond * delta,
        );
        entity.interruptRemaining = 0;
      }
      if (field.element === "fire" &&
        hostileTeams(field.team, entity.team, state) && field.pulseRemaining === 0) {
        const owner = state.entities.find((candidate) => candidate.id === field.ownerId);
        damageEntity(state, entity, MATCH_TUNING.elements.fireDamage, owner, {
          source: field.source === "ultimate" ? "ultimate" : "fire",
        });
      }
      if (field.element === "charge" &&
        hostileTeams(field.team, entity.team, state) && field.pulseRemaining === 0) {
        const owner = state.entities.find((candidate) => candidate.id === field.ownerId);
        damageEntity(state, entity, MATCH_TUNING.elements.chargeDamage, owner, {
          source: "charge-field",
        });
        const committedOrc = entity.raceId === "orc" &&
          (entity.mobilityRemaining > 0 || entity.ultimateWindupRemaining > 0 || entity.specialCooldown > 0);
        entity.interruptRemaining = Math.max(
          entity.interruptRemaining,
          MATCH_TUNING.elements.lightningInterrupt * (committedOrc ? 0.6 : 1),
        );
      }
      if (field.element === "vapor" && field.pulseRemaining === 0) {
        damageEntity(state, entity, MATCH_TUNING.elements.vaporDamage, null, {
          source: "vapor",
        });
      }
    }
    if (field.element === "fire" && field.pulseRemaining === 0) {
      field.pulseRemaining = MATCH_TUNING.elements.firePulse;
    }
    if (field.element === "charge" && field.pulseRemaining === 0) {
      field.pulseRemaining = MATCH_TUNING.elements.chargePulse;
    }
    if (field.element === "vapor" && field.pulseRemaining === 0) {
      field.pulseRemaining = MATCH_TUNING.elements.vaporPulse;
    }
  }
}

function updateRaceTraits(state, delta) {
  for (const entity of state.entities) {
    if (!entity.alive || entity.neutral) continue;
    if (entity.raceId === "stonewrought" && entity.onOwnEarth) entity.raceArmor = 0.12;
    if (entity.raceId === "rootwarden" && entity.onOwnEarth) {
      entity.raceArmor = Math.max(entity.raceArmor, 0.06);
      entity.flow = Math.min(entity.maxFlow, entity.flow + 5 * delta);
      if (entity.mendDelay === 0 && !entity.inFire) {
        entity.health = Math.min(entity.maxHealth, entity.health + 1.2 * delta);
      }
    }
    if (entity.raceId === "troll" && entity.mendDelay === 0 && !entity.inFire) {
      entity.health = Math.min(entity.maxHealth, entity.health + 3 * delta);
    }
    if (entity.raceId === "seakin" && entity.inOwnWater) {
      entity.flow = Math.min(entity.maxFlow, entity.flow + 4 * delta);
    }
    if (entity.raceId === "undead" && entity.shadowed && entity.mendDelay === 0) {
      entity.health = Math.min(entity.maxHealth, entity.health + 0.8 * delta);
    }
  }
}

function updateDecoys(state, delta) {
  for (const decoy of state.decoys) decoy.duration -= delta;
  state.decoys = state.decoys.filter((decoy) => decoy.duration > 0);
}

function useSpecial(state, entity, agent, map) {
  const special = agent.special;
  const element = combatElement(special.element ?? agent.affinity?.canonicalId ?? agent.affinity?.id);
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
        element,
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
    if (element === "wind") {
      createElementField(state, entity, "wind", {
        x: entity.x + entity.facingX * special.range * 0.72,
        y: entity.y + entity.facingY * special.range * 0.72,
        radius: MATCH_TUNING.elements.windRadius,
        duration: MATCH_TUNING.elements.windDuration,
        directionX: entity.facingX,
        directionY: entity.facingY,
        source: "tactical",
      });
    } else if (element === "earth") {
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
        source: "tactical",
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
    } else if (element === "ice") {
      createElementField(state, entity, "ice", {
        x: entity.x + entity.facingX * special.range * 0.68,
        y: entity.y + entity.facingY * special.range * 0.68,
        radius: MATCH_TUNING.elements.iceRadius,
        duration: MATCH_TUNING.elements.iceDuration,
        directionX: entity.facingX,
        directionY: entity.facingY,
        source: "tactical",
      });
    } else if (["fire", "water", "charge", "light", "dark"].includes(element)) {
      createElementField(state, entity, element, {
        x: entity.x + entity.facingX * special.range * 0.68,
        y: entity.y + entity.facingY * special.range * 0.68,
        radius: MATCH_TUNING.elements[`${element}Radius`] ?? 110,
        duration: MATCH_TUNING.elements[`${element}Duration`] ?? 2.4,
        directionX: entity.facingX,
        directionY: entity.facingY,
        source: "tactical",
      });
    }
  } else if (special.kind === "blast") {
    damageRadius(state, entity, special.range, special.damage, special.knockback);
    if (element === "dark") {
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
        markTutorialTacticalProof(state, entity, "veil-decoy");
        state.events.push({ type: "veilDecoy", entityId: entity.id, x: entity.x, y: entity.y });
      }
    }
    if (["fire", "water", "wind", "ice", "charge", "light", "dark"].includes(element)) {
      createElementField(state, entity, element, {
        x: entity.x + entity.facingX * special.range * 0.45,
        y: entity.y + entity.facingY * special.range * 0.45,
        radius: MATCH_TUNING.elements[`${element}Radius`] ?? 105,
        duration: MATCH_TUNING.elements[`${element}Duration`] ?? 2.2,
        directionX: entity.facingX,
        directionY: entity.facingY,
        source: "tactical",
      }, false);
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
        if (element === "charge") {
          target.interruptRemaining = Math.max(
            target.interruptRemaining,
            MATCH_TUNING.elements.lightningInterrupt,
          );
          state.events.push({
            type: "elementInterrupt",
            element: "charge",
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
    if (element === "light") {
      createElementField(state, entity, "light", {
        x: (entity.x + end.x) / 2,
        y: (entity.y + end.y) / 2,
        radius: MATCH_TUNING.elements.lightRadius,
        duration: MATCH_TUNING.elements.lightDuration,
        directionX: entity.facingX,
        directionY: entity.facingY,
        source: "tactical",
      }, false);
    }
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
      armedIn: special.armTime * (entity.raceId === "gnome" ? 0.78 : 1),
      remaining: special.duration,
      triggerRadius: special.triggerRadius,
      blastRadius: special.blastRadius,
      damage: special.damage,
      knockback: special.knockback,
      element,
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
      markTutorialTacticalProof(state, entity, "nullify");
      state.events.push({
        type: "elementReaction",
        reaction: "nullify",
        x: entity.x,
        y: entity.y,
      });
    }
  } else if (special.kind === "heal") {
    const before = entity.health;
    const undeadScale = entity.raceId === "undead" ? 0.7 : 1;
    const reactionScale = entity.raceId === "nymph" && entity.reactionCharge > 0 ? 1.35 : 1;
    entity.health = Math.min(entity.maxHealth, entity.health + special.amount * undeadScale * reactionScale);
    if (reactionScale > 1) entity.reactionCharge = 0;
    state.events.push({
      type: "heal",
      entityId: entity.id,
      amount: entity.health - before,
      x: entity.x,
      y: entity.y,
    });
    if (element === "water") {
      createElementField(state, entity, "water", {
        x: entity.x,
        y: entity.y,
        radius: MATCH_TUNING.elements.waterRadius,
        duration: MATCH_TUNING.elements.waterDuration,
        directionX: entity.facingX,
        directionY: entity.facingY,
        source: "tactical",
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
  const trainingPressure =
    state.modeId === "training" && entity.bot && state.tutorial.step === 2;
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
      source: trainingPressure ? "training" : source,
      x: entity.x + direction.x * spawnOffset,
      y: entity.y + direction.y * spawnOffset,
      previousX: entity.x,
      previousY: entity.y,
      vx: direction.x * weapon.speed,
      vy: direction.y * weapon.speed,
      radius: weapon.radius,
      damage: trainingPressure
        ? Math.min(weapon.damage, MATCH_TUNING.training.pressureDamage)
        : weapon.damage,
      lifetime: weapon.lifetime,
      knockback: trainingPressure ? 0 : weapon.knockback ?? 0,
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
    type: trainingPressure ? "trainingPressure" : "shot",
    entityId: entity.id,
    source,
    x: entity.x,
    y: entity.y,
  });
}

function updateMines(state, delta) {
  const survivors = [];
  for (const mine of state.mines) {
    const wasArmed = mine.armedIn === 0;
    mine.armedIn = Math.max(0, mine.armedIn - delta);
    mine.remaining -= delta;
    if (mine.remaining <= 0) continue;
    const owner = state.entities.find((entity) => entity.id === mine.ownerId);
    if (!wasArmed && mine.armedIn === 0 && owner) {
      markTutorialTacticalProof(state, owner, "armed-trap");
      state.events.push({
        type: "mineArmed",
        entityId: owner.id,
        mineId: mine.id,
        x: mine.x,
        y: mine.y,
      });
    }
    const target = state.entities.find(
      (entity) =>
        entity.alive &&
        hostileTeams(mine.team, entity.team, state) &&
        Math.hypot(entity.x - mine.x, entity.y - mine.y) <= mine.triggerRadius,
    );
    if (mine.armedIn === 0 && target) {
      for (const entity of state.entities) {
        if (!entity.alive || !hostileTeams(mine.team, entity.team, state)) continue;
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
      if (owner?.raceId === "goblin") {
        const refund = Math.min(12, owner.maxFlux - owner.flux);
        owner.flux += refund;
        if (refund > 0) state.events.push({ type: "salvage", entityId: owner.id, amount: refund, x: mine.x, y: mine.y });
      }
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
      const mineElement = combatElement(
        mine.element ?? getCharacter(owner?.characterId).affinity?.id,
      );
      if (owner && ["fire", "water", "wind", "ice", "charge", "light", "dark"].includes(mineElement)) {
        createElementField(state, owner, mineElement, {
          x: mine.x,
          y: mine.y,
          radius: MATCH_TUNING.elements[`${mineElement}Radius`] ?? mine.blastRadius * 0.72,
          duration: MATCH_TUNING.elements[`${mineElement}Duration`] ?? 2.2,
          directionX: 0,
          directionY: 0,
          source: "mine",
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
          !hostileTeams(a.team, b.team, state) ||
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
    const structuralHit = (state.destructibles ?? []).find((piece) =>
      !piece.destroyed && segmentRectangleHit(
        projectile.previousX, projectile.previousY, projectile.x, projectile.y,
        piece, projectile.radius,
      ),
    );
    if (structuralHit) {
      damageDestructible(
        state, structuralHit, projectile.damage * (projectile.heavy ? 1.6 : 1),
        projectile.ownerId, projectile.source,
      );
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
        hostileTeams(projectile.team, entity.team, state) &&
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
    resolveProjectileGrazes(state, projectile, target?.id ?? null);
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

function resolveProjectileGrazes(state, projectile, hitEntityId) {
  if (projectile.source === "training") return;
  projectile.grazedIds ??= [];
  for (const entity of state.entities) {
    if (
      !entity.alive || entity.id === hitEntityId ||
      !hostileTeams(projectile.team, entity.team, state) ||
      entity.spawnProtection > 0 || entity.grazeCooldown > 0 ||
      projectile.grazedIds.includes(entity.id) ||
      Math.hypot(entity.vx, entity.vy) < MATCH_TUNING.flow.grazeMinimumSpeed ||
      entity.flow >= entity.maxFlow
    ) continue;
    const hitRadius = getCharacter(entity.characterId).radius + projectile.radius;
    if (
      segmentCircleHit(
        projectile.previousX,
        projectile.previousY,
        projectile.x,
        projectile.y,
        entity.x,
        entity.y,
        hitRadius,
      ) ||
      !segmentCircleHit(
        projectile.previousX,
        projectile.previousY,
        projectile.x,
        projectile.y,
        entity.x,
        entity.y,
        hitRadius + MATCH_TUNING.flow.grazeMargin,
      )
    ) continue;
    const raceScale = entity.raceId === "hobbit" ? 1.35 : 1;
    const amount = Math.min(
      MATCH_TUNING.flow.grazeReward * raceScale,
      entity.maxFlow - entity.flow,
    );
    entity.flow += amount;
    entity.flowRecoveryDelay = MATCH_TUNING.flow.recoveryDelay;
    entity.grazeCooldown = MATCH_TUNING.flow.grazeCooldown;
    projectile.grazedIds.push(entity.id);
    state.events.push({
      type: "spellGraze",
      entityId: entity.id,
      projectileId: projectile.id,
      amount,
      x: entity.x,
      y: entity.y,
    });
  }
}

function defendAgainstProjectile(state, target, projectile) {
  if (target.spawnProtection > 0) return "consume";
  if (target.defenseRemaining <= 0) return "hit";
  const defense = runtimeCharacter(target).defense;
  if (defense.kind === "phase") {
    markTutorialDefenseRead(state, target, defense.kind);
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
    markTutorialDefenseRead(state, target, defense.kind);
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
    markTutorialDefenseRead(state, target, defense.kind);
    return "consume";
  }
  if (defense.kind === "counter") {
    const owner = state.entities.find((entity) => entity.id === projectile.ownerId);
    const direction = owner
      ? normalizeDirection(owner.x - target.x, owner.y - target.y)
      : { x: target.facingX, y: target.facingY };
    fireCounter(state, target, defense, direction);
    markTutorialDefenseRead(state, target, defense.kind);
    return "consume";
  }
  return "hit";
}

function markTutorialDefenseRead(state, target, kind) {
  if (
    state.modeId !== "training" || state.tutorial.skipped ||
    state.tutorial.step !== 2 || !target.human
  ) return;
  state.tutorial.defended = true;
  state.events.push({
    type: "defenseRead",
    entityId: target.id,
    kind,
    x: target.x,
    y: target.y,
  });
}

function markTutorialTacticalProof(state, entity, kind) {
  if (
    state.modeId !== "training" || state.tutorial.skipped ||
    state.tutorial.step !== 3 || !entity?.human || state.tutorial.special
  ) return;
  state.tutorial.special = true;
  state.events.push({
    type: "tacticalProof",
    entityId: entity.id,
    kind,
    x: entity.x,
    y: entity.y,
  });
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

function damageDestructible(state, piece, rawDamage, ownerId = null, source = "unknown") {
  if (!piece || piece.destroyed || state.rules?.freeplaySettings?.destructibility === false) return false;
  const owner = state.entities.find((entity) => entity.id === ownerId);
  const momentumScale = owner?.raceId === "minotaur"
    ? 1 + Math.min(0.35, Math.hypot(owner.vx, owner.vy) / 1800)
    : 1;
  const damage = Math.max(1, Math.round(finite(rawDamage) * momentumScale));
  piece.health = Math.max(0, piece.health - damage);
  piece.damageStage = piece.health === 0 ? 3
    : piece.health <= piece.maxHealth * 0.33 ? 2
      : piece.health <= piece.maxHealth * 0.66 ? 1 : 0;
  state.events.push({
    type: "structureHit", structuralId: piece.id, ownerId, source, damage,
    health: piece.health, x: piece.x + piece.width / 2, y: piece.y + piece.height / 2,
  });
  if (piece.health === 0) {
    piece.destroyed = true;
    state.events.push({
      type: "structureBroken", structuralId: piece.id, ownerId, source,
      material: piece.material, level: piece.level,
      x: piece.x + piece.width / 2, y: piece.y + piece.height / 2,
    });
    scoreSiegeBreak(state, piece, ownerId);
  }
  return true;
}

export function damageStructure(state, structuralId, rawDamage, ownerId = null, source = "script") {
  const piece = state.destructibles?.find((candidate) => candidate.id === structuralId);
  return damageDestructible(state, piece, rawDamage, ownerId, source);
}

function damageEntity(state, target, rawDamage, attacker, options = {}) {
  if (
    !target?.alive ||
    target.spawnProtection > 0 ||
    target.damageInvulnerability > 0
  ) {
    return false;
  }
  if (state.rules?.freeplaySettings?.godMode && target.human) return false;
  const agent = runtimeCharacter(target);
  let damage = Math.max(0, finite(rawDamage)) *
    (state.rules?.freeplaySettings?.damageMultiplier ?? 1);
  if (target.raceId === "rootwarden" && ["fire", "ultimate"].includes(options.source)) damage *= 1.14;
  if (target.raceArmor > 0) damage *= 1 - target.raceArmor;
  if (target.defenseRemaining > 0 && agent.defense.kind === "guard") {
    const sourceDirection = options.direction ?? { x: 0, y: 0 };
    const incomingDot =
      -sourceDirection.x * target.facingX - sourceDirection.y * target.facingY;
    if (incomingDot >= agent.defense.frontalDot) {
      damage *= 1 - agent.defense.reduction;
      state.events.push({ type: "guarded", entityId: target.id });
      markTutorialDefenseRead(state, target, agent.defense.kind);
    }
  }
  damage = Math.max(1, Math.round(damage));
  const healthFloor = options.source === "training" ? 1 : 0;
  target.health = Math.max(healthFloor, target.health - damage);
  target.hitFlash = MATCH_TUNING.hitFlash;
  target.damageInvulnerability = agent.damageInvulnerability;
  target.lastAttackerId = attacker?.id ?? null;
  target.mendDelay = 3;
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
  if (["special", "rail", "pull", "mine"].includes(options.source)) {
    markTutorialTacticalProof(state, attacker, `${options.source}-impact`);
  }
  if (
    attacker && attacker !== target &&
    !["ultimate", "training"].includes(options.source)
  ) {
    gainUltimateCharge(state, attacker, damage);
  }
  if (target.health === 0) eliminateEntity(state, target, attacker);
  return true;
}

function gainUltimateCharge(state, entity, damage) {
  const ultimate = runtimeCharacter(entity).ultimate;
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
  if (state.extraction) {
    if (target.neutral && attacker && !attacker.neutral) {
      attacker.cargo = Math.min(state.extraction.required, attacker.cargo + 1);
      state.events.push({
        type: "cargoClaimed", entityId: attacker.id, amount: 1, cargo: attacker.cargo,
        x: target.x, y: target.y,
      });
    } else if (!target.neutral && target.cargo > 0) {
      state.extraction.drops.push({
        id: `cargo-${state.tick}-${target.id}`, x: target.x, y: target.y, amount: target.cargo,
      });
      state.events.push({ type: "cargoDropped", entityId: target.id, amount: target.cargo, x: target.x, y: target.y });
      target.cargo = 0;
    }
  }
  if (target.neutral) releaseWayseal(state, target);
  else dropCarriedWayseal(state, target, "elimination");
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
  } else if (["team", "draft", "mirror"].includes(mode.id)) {
    const scoringTeam = attacker?.team;
    if (scoringTeam && scoringTeam !== "neutral" && scoringTeam !== target.team) {
      state.score[scoringTeam] = (state.score[scoringTeam] ?? 0) + 1;
      if (state.score[scoringTeam] >= mode.scoreLimit) finishMatch(state, scoringTeam);
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
  if (mode.id === "duel" || mode.id === "training" || mode.noRespawn) return;
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
  const agent = runtimeCharacter(entity);
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
  entity.airborneRemaining = 0;
  entity.airJumpsRemaining = entity.raceId === "scaleheir" ? 2 : 1;
  entity.airDodgeCooldown = 0;
  entity.airDodgeRemaining = 0;
  entity.airDodgeX = entity.facingX;
  entity.airDodgeY = entity.facingY;
  entity.vaultWindow = 0;
  entity.superglideCooldown = 0;
  entity.movementState = "grounded";
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
  entity.grazeCooldown = 0;
  entity.mendDelay = 0;
  entity.reactionCharge = 0;
  entity.raceArmor = 0;
  entity.inFire = false;
  entity.inOwnWater = false;
  entity.onOwnEarth = false;
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
  state.destructibles = createModeDestructibles(mode, map);
  state.movementTrial = mode.id === "movement"
    ? createMovementTrialState(map, state.entities)
    : null;
  state.siege = mode.id === "siege"
    ? { score: {}, brokenIds: [], targetScore: mode.scoreLimit }
    : null;
  state.extraction = mode.id === "extraction" ? createExtractionState(map) : null;
  state.shrines = (map.shrines ?? []).map((shrine) => ({
    ...shrine,
    readyIn: 0,
    insideIds: [],
  }));
  setObjectivePosition(state, map.objective);
  state.wildmarch = createWildmarchState(mode, map);
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
          state.modeId,
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
  const objective = state.objective ?? map.objective;
  const occupants = new Set(
    state.entities
      .filter(
        (entity) =>
          entity.alive &&
          entity.team !== "neutral" &&
          Math.hypot(
            entity.x - objective.x,
            entity.y - objective.y,
          ) <=
            objective.radius + getCharacter(entity.characterId).radius,
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
  if (mode.id === "freeplay") return;
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

  if (state.movementTrial) {
    const gate = state.movementTrial.gates[state.movementTrial.progress[entity.id] ?? 0];
    if (!gate) {
      entity.botCommand = { ...IDLE_COMMAND };
      return entity.botCommand;
    }
    const direction = normalizeDirection(gate.x - entity.x, gate.y - entity.y);
    entity.botCommand = {
      ...IDLE_COMMAND,
      moveX: direction.x, moveY: direction.y,
      aimX: direction.x, aimY: direction.y,
      sprint: entity.flow > entity.maxFlow * 0.35,
      hop: entity.hopCooldown === 0 && entity.flow >= MATCH_TUNING.flow.hopCost && hashSign(entity.id, state.tick) > 0,
      mobility: entity.mobilityCooldown === 0 && Math.hypot(gate.x - entity.x, gate.y - entity.y) > 260,
    };
    return entity.botCommand;
  }

  const targets = opponentsOf(state, entity);
  let modeTarget = null;
  if (state.extraction) {
    if (entity.cargo >= state.extraction.required) {
      modeTarget = state.extraction.exit;
    } else {
      const candidates = [
        ...state.entities.filter((candidate) => candidate.alive && candidate.neutral),
        ...state.extraction.drops,
      ];
      modeTarget = candidates.sort((left, right) => squaredDistance(entity, left) - squaredDistance(entity, right))[0] ?? null;
    }
  } else if (state.siege) {
    const pieces = state.destructibles.filter((piece) => !piece.destroyed && piece.ownerTeam !== entity.team);
    const piece = pieces.sort((left, right) => {
      const leftCenter = { x: left.x + left.width / 2, y: left.y + left.height / 2 };
      const rightCenter = { x: right.x + right.width / 2, y: right.y + right.height / 2 };
      return squaredDistance(entity, leftCenter) - squaredDistance(entity, rightCenter);
    })[0];
    if (piece) modeTarget = { x: piece.x + piece.width / 2, y: piece.y + piece.height / 2, structuralId: piece.id };
  }
  if (targets.length === 0 && !modeTarget) {
    entity.botCommand = { ...IDLE_COMMAND };
    return entity.botCommand;
  }
  const hostileCarrier = state.wildmarch?.seal.status === "carried"
    ? state.entities.find(
        (candidate) =>
          candidate.id === state.wildmarch.seal.carrierId &&
          hostileTeams(entity.team, candidate.team, state),
      )
    : null;
  const combatTarget = targets.length > 0
    ? targets.reduce((nearest, candidate) =>
        squaredDistance(entity, candidate) < squaredDistance(entity, nearest)
          ? candidate
          : nearest,
      )
    : null;
  const target = hostileCarrier ?? modeTarget ?? combatTarget;
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
    let destination = state.objective;
    if (state.wildmarch?.seal.status === "grounded") {
      destination = state.wildmarch.seal;
    } else if (
      state.wildmarch?.seal.status === "carried" &&
      state.wildmarch.seal.carrierId === entity.id
    ) {
      destination = state.wildmarch.routes.reduce((nearest, route) =>
        squaredDistance(entity, route) < squaredDistance(entity, nearest)
          ? route
          : nearest,
      );
    }
    const objectiveDistance = Math.hypot(
      destination.x - entity.x,
      destination.y - entity.y,
    );
    if (objectiveDistance > (destination.radius ?? map.objective.radius) * 0.75) {
      const objectiveDirection = normalizeDirection(
        destination.x - entity.x,
        destination.y - entity.y,
      );
      moveX = moveX * 0.45 + objectiveDirection.x * 0.85;
      moveY = moveY * 0.45 + objectiveDirection.y * 0.85;
    }
  }
  const move = normalizeDirection(moveX, moveY);
  const closeProjectile = state.projectiles.some(
    (projectile) =>
      hostileTeams(entity.team, projectile.team, state) &&
      Math.hypot(projectile.x - entity.x, projectile.y - entity.y) < 125,
  );
  const agent = runtimeCharacter(entity);
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
      Boolean(combatTarget) &&
      entity.ultimateCharge >= (agent.ultimate?.chargeRequired ?? Infinity) &&
      distance >= 150 &&
      distance <= (agent.ultimate?.range ?? agent.ultimate?.targetRange ?? 0) * 0.92,
  };
  if (
    state.modeId === "training" &&
    !state.tutorial.skipped &&
    state.tutorial.step < 4
  ) {
    entity.botCommand.fire = state.tutorial.step === 2 && entity.botCommand.fire;
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
    !hostileTeams(attacker.team, target.team, state)
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
      hostileTeams(entity.team, candidate.team, state),
  );
}

function hostileTeams(left, right, state = null) {
  if (left === "neutral" || right === "neutral") return left !== right;
  if (left !== right) return true;
  return state?.rules?.freeplay === true &&
    state.rules.freeplaySettings?.friendlyFire === true;
}

function repairState(state, map) {
  for (const entity of state.entities) {
    const agent = runtimeCharacter(entity);
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
  state.objective.x = finite(state.objective.x, map.objective.x);
  state.objective.y = finite(state.objective.y, map.objective.y);
  state.objective.radius = clamp(
    finite(state.objective.radius, map.objective.radius),
    1,
    Math.max(map.size.width, map.size.height),
  );
  if (state.wildmarch) {
    const wildmarch = state.wildmarch;
    wildmarch.routeRemaining = clamp(
      finite(wildmarch.routeRemaining),
      0,
      MATCH_TUNING.wildmarch.routeDuration,
    );
    wildmarch.activeRouteId = wildmarch.routes.some(
      (route) => route.id === wildmarch.activeRouteId,
    )
      ? wildmarch.activeRouteId
      : null;
    const seal = wildmarch.seal;
    seal.x = finite(seal.x, map.objective.x);
    seal.y = finite(seal.y, map.objective.y);
    seal.returnRemaining = clamp(
      finite(seal.returnRemaining),
      0,
      MATCH_TUNING.wildmarch.returnDuration,
    );
    if (!["dormant", "grounded", "carried", "routed"].includes(seal.status)) {
      seal.status = "dormant";
      seal.carrierId = null;
      seal.returnRemaining = 0;
    }
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
  if (state.version !== 3) errors.push("match state version must be 3");
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
      "airborneRemaining",
      "airJumpsRemaining",
      "airDodgeCooldown",
      "airDodgeRemaining",
      "airDodgeX",
      "airDodgeY",
      "vaultWindow",
      "superglideCooldown",
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
      "grazeCooldown",
      "passiveRemaining",
      "passiveCueCooldown",
      "ultimateCharge",
      "maxUltimate",
      "ultimateWindupRemaining",
      "ultimateAimX",
      "ultimateAimY",
      "ultimateTargetX",
      "ultimateTargetY",
      "cargo",
      "mendDelay",
      "reactionCharge",
      "raceArmor",
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
    for (const obstacle of withDynamicGeometry(map, state).obstacles) {
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
  for (const key of ["x", "y", "radius"]) {
    if (!Number.isFinite(state.objective?.[key])) {
      errors.push(`objective.${key} is not finite`);
    }
  }
  if (state.wildmarch) {
    const wildmarch = state.wildmarch;
    if (
      !Number.isFinite(wildmarch.routeRemaining) ||
      wildmarch.routeRemaining < 0 ||
      wildmarch.routeRemaining > MATCH_TUNING.wildmarch.routeDuration
    ) {
      errors.push("wildmarch.routeRemaining is outside its duration");
    }
    if (
      wildmarch.activeRouteId !== null &&
      !wildmarch.routes.some((route) => route.id === wildmarch.activeRouteId)
    ) {
      errors.push("wildmarch.activeRouteId is unknown");
    }
    for (const key of ["x", "y", "returnRemaining"]) {
      if (!Number.isFinite(wildmarch.seal?.[key])) {
        errors.push(`wildmarch.seal.${key} is not finite`);
      }
    }
    if (
      !["dormant", "grounded", "carried", "routed"].includes(
        wildmarch.seal?.status,
      )
    ) {
      errors.push("wildmarch.seal.status is invalid");
    }
    if (
      wildmarch.seal?.status === "carried" &&
      !state.entities.some(
        (entity) =>
          entity.id === wildmarch.seal.carrierId &&
          entity.alive && !entity.neutral,
      )
    ) {
      errors.push("wildmarch Wayseal has no living carrier");
    }
  } else if (state.modeId === "convergence") {
    errors.push("convergence needs authoritative WILDMARCH state");
  }
  for (const piece of state.destructibles ?? []) {
    for (const key of ["x", "y", "width", "height", "health", "maxHealth"]) {
      if (!Number.isFinite(piece[key])) errors.push(`${piece.id}.${key} is not finite`);
    }
    if (piece.health < 0 || piece.health > piece.maxHealth) errors.push(`${piece.id}.health is invalid`);
    if (piece.destroyed !== (piece.health === 0)) errors.push(`${piece.id}.destroyed disagrees with health`);
  }
  if (state.movementTrial) {
    for (const gate of state.movementTrial.gates ?? []) {
      for (const key of ["x", "y", "radius"]) {
        if (!Number.isFinite(gate[key])) errors.push(`movementTrial.${gate.id}.${key} is not finite`);
      }
    }
    for (const [entityId, progress] of Object.entries(state.movementTrial.progress ?? {})) {
      if (!Number.isInteger(progress) || progress < 0 || progress > state.movementTrial.gates.length) {
        errors.push(`movementTrial.progress.${entityId} is invalid`);
      }
    }
  } else if (state.modeId === "movement") errors.push("movement mode needs trial state");
  if (state.siege) {
    for (const [team, score] of Object.entries(state.siege.score ?? {})) {
      if (!Number.isFinite(score) || score < 0) errors.push(`siege.score.${team} is invalid`);
    }
  } else if (state.modeId === "siege") errors.push("siege mode needs siege state");
  if (state.extraction) {
    for (const key of ["x", "y", "radius"]) {
      if (!Number.isFinite(state.extraction.exit?.[key])) errors.push(`extraction.exit.${key} is not finite`);
    }
    if (!Number.isInteger(state.extraction.required) || state.extraction.required <= 0) {
      errors.push("extraction.required is invalid");
    }
    for (const drop of state.extraction.drops ?? []) {
      for (const key of ["x", "y", "amount"]) {
        if (!Number.isFinite(drop[key])) errors.push(`${drop.id}.${key} is not finite`);
      }
    }
  } else if (state.modeId === "extraction") errors.push("extraction mode needs extraction state");
  if (state.battleRoyale && (!Number.isFinite(state.battleRoyale.radius) || state.battleRoyale.radius <= 0)) {
    errors.push("battleRoyale.radius is invalid");
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

function normalizeEntityTeam(candidate, modeId) {
  const value = String(candidate ?? "");
  if (value === "neutral") return "neutral";
  if (modeId === "battle_royale" && /^squad-[1-9][0-9]?$/.test(value)) return value;
  return value === "beta" ? "beta" : "alpha";
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
