import test from "node:test";
import assert from "node:assert/strict";

import {
  ABILITY_CATALOG,
  CHARACTER_ROSTER,
  CHARACTERS,
  ELEMENTS,
  MAPS,
  MATCH_TUNING,
  MODES,
  OVERHAUL_CHARACTERS,
  RACES,
  buildCharacterKit,
  getCharacter,
  getMap,
  getMode,
  validateLiveContent,
} from "../src/live-content.mjs";
import {
  applyFreeplayAction,
  createMatch,
  damageStructure,
  matchInvariantErrors,
  setFreeplaySettings,
  stepMatch,
} from "../src/match.mjs";

test("live content keeps compatibility while shipping the full race roster", () => {
  assert.deepEqual(validateLiveContent(), []);
  assert.equal(ELEMENTS.length, 8);
  assert.equal(CHARACTER_ROSTER.length, 16);
  assert.equal(OVERHAUL_CHARACTERS.length, 16);
  assert.ok(CHARACTERS.length >= 26);
  assert.ok(RACES.some((race) => race.id === "hobbit"));
  assert.ok(RACES.some((race) => race.id === "rootwarden"));
  assert.ok(MAPS.some((map) => map.id === "sanctum"));
  assert.ok(MODES.some((mode) => mode.id === "battle_royale"));
  assert.ok(ABILITY_CATALOG.length >= 40);
  assert.equal(getCharacter("rote-baron").ultimate.name, "THE DEAD SKY");
  assert.equal(getCharacter("treevor").passive.name, "DEEP ROOTS");
  assert.equal(getCharacter("samwise").name, "Samwise DeWayne");
});

test("universal loadouts drive authoritative action slots with signature discounts", () => {
  const custom = buildCharacterKit({
    characterId: "mara",
    modeId: "freeplay",
    activeAbilityIds: ["night-flak", "mirror-bulwark", "eel-step"],
    ultimateAbilityId: "the-dead-sky",
  });
  assert.deepEqual(custom.errors, []);
  assert.equal(custom.special.name, "NIGHT FLAK");
  assert.equal(custom.defense.name, "MIRROR BULWARK");
  assert.equal(custom.mobility.name, "EEL STEP");
  assert.equal(custom.ultimate.name, "THE DEAD SKY");

  const signature = buildCharacterKit({
    characterId: "rote-baron",
    modeId: "freeplay",
    activeAbilityIds: ["night-flak", "mirror-bulwark", "eel-step"],
    ultimateAbilityId: "the-dead-sky",
  });
  assert.ok(signature.special.fluxCost < custom.special.fluxCost);

  const state = createMatch({
    modeId: "freeplay",
    mapId: "sanctum",
    botCount: 0,
    players: [{
      id: "builder",
      characterId: "mara",
      raceId: "human",
      team: "alpha",
      human: true,
      activeAbilityIds: ["night-flak", "mirror-bulwark", "eel-step"],
      ultimateAbilityId: "the-dead-sky",
    }],
  });
  const entity = state.entities[0];
  assert.equal(entity.kit.special.name, "NIGHT FLAK");
  assert.equal(entity.kit.defense.name, "MIRROR BULWARK");
  assert.equal(entity.kit.mobility.name, "EEL STEP");
  entity.spawnProtection = 0;
  stepMatch(state, {
    builder: { aimX: 1, aimY: 0, special: true, defend: true, mobility: true },
  });
  assert.ok(state.events.some((event) => event.type === "special"));
  assert.ok(state.events.some((event) => event.type === "defense"));
  assert.ok(state.events.some((event) => event.type === "mobility"));
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("each new race has one live, fully actionable character", () => {
  const raceIds = new Set(CHARACTER_ROSTER.map((entry) => entry.raceId));
  assert.equal(raceIds.size, 16);
  for (const character of OVERHAUL_CHARACTERS) {
    assert.ok(character.primary.name);
    assert.ok(character.special.name);
    assert.ok(character.defense.name);
    assert.ok(character.mobility.name);
    assert.ok(character.ultimate.name);
    assert.ok(character.radius >= 12 && character.radius <= 23);
    const state = createMatch({
      modeId: "duel",
      mapId: "crosswind",
      botCount: 0,
      players: [
        { id: "new", characterId: character.id, raceId: character.homeRaceId, team: "alpha", human: true },
        { id: "old", characterId: "kite", raceId: "human", team: "beta", human: true },
      ],
    });
    state.entities[0].spawnProtection = 0;
    state.entities[1].spawnProtection = 0;
    state.entities[0].ultimateCharge = state.entities[0].maxUltimate;
    stepMatch(state, {
      new: { moveX: 1, moveY: 0, aimX: 1, aimY: 0, fire: true, special: true, defend: true, mobility: true },
    });
    assert.deepEqual(matchInvariantErrors(state), [], character.id);
  }
});

test("freeplay boots as a non-ending practice state with isolated modifiers", () => {
  const state = createMatch({
    modeId: "freeplay",
    mapId: "sanctum",
    botCount: 0,
    characterId: "steezo",
  });
  assert.equal(state.rules.freeplay, true);
  assert.equal(state.status, "playing");
  assert.equal(getMap(state.mapId).id, "sanctum");
  assert.equal(getMode(state.modeId).id, "freeplay");
  assert.ok(state.destructibles.length >= 3);
  assert.equal(setFreeplaySettings(state, {
    godMode: true,
    endlessFlux: true,
    endlessFlow: true,
    instantCooldowns: true,
    endlessUltimate: true,
  }), true);
  const player = state.entities[0];
  player.flux = 0;
  player.flow = 0;
  player.ultimateCharge = 0;
  stepMatch(state, { [player.id]: { special: true, mobility: true, aimX: 1 } }, 1 / 120);
  assert.equal(player.flux, player.maxFlux);
  assert.equal(player.flow, player.maxFlow);
  assert.equal(player.ultimateCharge, player.maxUltimate);
  assert.equal(state.status, "playing");
  assert.equal(applyFreeplayAction(state, "spawn-hostile-bot"), true);
  assert.equal(state.entities.length, 2);
  assert.equal(applyFreeplayAction(state, "clear-fields"), true);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("Flux feels abundant but repeated casting delays recovery", () => {
  assert.equal(MATCH_TUNING.flux.maximum, 180);
  assert.ok(MATCH_TUNING.flux.recoveryPerSecond >= 26);
  assert.ok(MATCH_TUNING.flux.recoveryDelay >= 0.8);
  const state = createMatch({
    modeId: "duel", mapId: "crosswind", botCount: 0,
    players: [
      { id: "caster", characterId: "rote-baron", raceId: "undead", team: "alpha", human: true },
      { id: "target", characterId: "treevor", raceId: "rootwarden", team: "beta", human: true },
    ],
  });
  const caster = state.entities[0];
  const start = caster.flux;
  stepMatch(state, { caster: { special: true, aimX: 1 } });
  assert.ok(caster.flux < start);
  const spent = caster.flux;
  for (let i = 0; i < 20; i += 1) stepMatch(state, {});
  assert.equal(caster.flux, spent);
  for (let i = 0; i < 140; i += 1) stepMatch(state, {});
  assert.ok(caster.flux > spent);
});

test("authored structures take bounded damage and can be rebuilt", () => {
  const state = createMatch({ modeId: "freeplay", mapId: "sanctum", botCount: 0, characterId: "gorum" });
  const player = state.entities[0];
  const piece = state.destructibles[0];
  player.x = piece.x - 80;
  player.y = piece.y + piece.height / 2;
  player.facingX = 1;
  player.facingY = 0;
  player.spawnProtection = 0;
  for (let i = 0; i < 80 && !piece.destroyed; i += 1) {
    stepMatch(state, { [player.id]: { fire: true, aimX: 1, aimY: 0 } }, 1 / 120);
  }
  assert.equal(piece.destroyed, true);
  assert.equal(piece.health, 0);
  assert.equal(applyFreeplayAction(state, "rebuild"), true);
  assert.equal(state.destructibles[0].destroyed, false);
  assert.equal(state.destructibles[0].health, state.destructibles[0].maxHealth);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("small battle royale is last-team-standing with a closing authoritative zone", () => {
  const state = createMatch({
    modeId: "battle_royale",
    mapId: "rift",
    botCount: 0,
    players: [
      { id: "alpha", characterId: "fluup", raceId: "orc", team: "alpha", human: true },
      { id: "beta", characterId: "oh-tipi", raceId: "seakin", team: "beta", human: true },
    ],
  });
  assert.ok(state.battleRoyale);
  const initialRadius = state.battleRoyale.radius;
  for (let i = 0; i < (MATCH_TUNING.battleRoyale.delay + 1) * 10; i += 1) {
    stepMatch(state, {}, 0.1);
  }
  assert.ok(state.battleRoyale.radius < initialRadius);
  const beta = state.entities.find((entry) => entry.id === "beta");
  beta.spawnProtection = 0;
  beta.health = 1;
  beta.x = state.battleRoyale.centerX + state.battleRoyale.radius + 100;
  for (let i = 0; i < 80 && state.status === "playing"; i += 1) stepMatch(state, {}, 1 / 120);
  assert.equal(beta.alive, false);
  assert.equal(state.status, "match-over");
  assert.equal(state.winner, "alpha");
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("movement state machine supports bounded double jump and air dodge", () => {
  const state = createMatch({ modeId: "freeplay", mapId: "sanctum", botCount: 0, characterId: "vey" });
  const player = state.entities[0];
  const idle = { moveX: 0, moveY: 0, aimX: 1, aimY: 0 };
  stepMatch(state, { [player.id]: { ...idle, moveX: 1, hop: true } });
  assert.equal(state.events.some((event) => event.type === "hop"), true);
  for (let i = 0; i < 61; i += 1) stepMatch(state, { [player.id]: idle });
  stepMatch(state, { [player.id]: { ...idle, moveY: -1, hop: true } });
  assert.equal(state.events.some((event) => event.type === "doubleJump"), true);
  assert.equal(player.airJumpsRemaining, 0);
  assert.ok(Math.hypot(player.vx, player.vy) <= MATCH_TUNING.movement.doubleJumpSpeed + 200);

  const dodge = createMatch({ modeId: "freeplay", mapId: "sanctum", botCount: 0, characterId: "samwise" });
  const dodger = dodge.entities[0];
  stepMatch(dodge, { [dodger.id]: { ...idle, moveX: 1, hop: true } });
  stepMatch(dodge, { [dodger.id]: { ...idle, moveY: 1, hop: true, defend: true } });
  assert.equal(dodge.events.some((event) => event.type === "airDodge"), true);
  assert.equal(dodger.movementState, "air-dodge");
  assert.deepEqual(matchInvariantErrors(dodge), []);
});

test("landing air dodge becomes a readable wavedash and vault memory enables superglide", () => {
  const state = createMatch({ modeId: "freeplay", mapId: "sanctum", botCount: 0, characterId: "aerwyn" });
  const player = state.entities[0];
  const idle = { moveX: 0, moveY: 0, aimX: 1, aimY: 0 };
  stepMatch(state, { [player.id]: { ...idle, moveX: 1, hop: true } });
  for (let i = 0; i < 20; i += 1) stepMatch(state, { [player.id]: idle });
  assert.ok(player.landingRemaining > 0);
  stepMatch(state, { [player.id]: { ...idle, moveX: 1, hop: true, defend: true } });
  assert.equal(state.events.some((event) => event.type === "wavedash"), true);
  assert.equal(player.movementState, "wavedash");

  const glide = createMatch({ modeId: "freeplay", mapId: "sanctum", botCount: 0, characterId: "fluup" });
  const glider = glide.entities[0];
  glider.vaultWindow = MATCH_TUNING.movement.vaultMemory;
  stepMatch(glide, { [glider.id]: { ...idle, moveX: 1, sprint: true, hop: true } });
  assert.equal(glide.events.some((event) => event.type === "superglide"), true);
  assert.equal(glider.movementState, "superglide");
  assert.deepEqual(matchInvariantErrors(glide), []);
});

test("all eight element families resolve bounded deterministic reactions", () => {
  const state = createMatch({
    modeId: "freeplay", mapId: "sanctum", botCount: 0,
    players: [
      { id: "alpha", characterId: "mara", raceId: "human", team: "alpha", human: true },
      { id: "beta", characterId: "gorum", raceId: "orc", team: "beta", human: true },
    ],
  });
  const base = {
    ownerId: "alpha", team: "alpha", x: 900, y: 700,
    radius: 70, duration: 2, pulseRemaining: 0,
  };
  const resolvePair = (left, right) => {
    state.events = [];
    state.elementFields = [
      { ...base, id: `left-${left.element}`, ...left },
      { ...base, id: `right-${right.element}`, ownerId: "beta", team: "beta", ...right },
    ];
    stepMatch(state, {}, 1 / 120);
    return state.events.filter((event) => event.type === "elementReaction");
  };

  assert.ok(resolvePair(
    { element: "earth", x: 850, y: 650, width: 100, height: 100, radius: undefined },
    { element: "water" },
  ).some((event) => event.reaction === "mud"));
  assert.equal(state.elementFields.some((field) => field.element === "mud"), true);

  assert.ok(resolvePair(
    { element: "water" },
    { element: "charge" },
  ).some((event) => event.reaction === "conduct"));
  assert.equal(state.elementFields.some((field) => field.element === "charge"), true);

  assert.ok(resolvePair(
    { element: "light", directionX: 1, directionY: 0 },
    { element: "ice" },
  ).some((event) => event.reaction === "refract"));
  assert.equal(
    state.elementFields.some((field) => field.element === "light" && field.shape === "refracted"),
    true,
  );

  assert.ok(resolvePair(
    { element: "light" },
    { element: "dark" },
  ).some((event) => event.reaction === "attenuate"));
  assert.equal(state.elementFields.some((field) => field.element === "shadow-edge"), true);

  assert.ok(resolvePair(
    { element: "dark" },
    { element: "earth", x: 850, y: 650, width: 100, height: 100, radius: undefined },
  ).some((event) => event.reaction === "decay"));
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("freeplay can disable reactions without disabling individual field behavior", () => {
  const state = createMatch({ modeId: "freeplay", mapId: "sanctum", botCount: 0 });
  setFreeplaySettings(state, { reactions: false });
  const player = state.entities[0];
  state.elementFields = [
    {
      id: "fire-off", ownerId: player.id, team: player.team, element: "fire",
      x: player.x, y: player.y, radius: 70, duration: 2, pulseRemaining: 0,
    },
    {
      id: "water-off", ownerId: player.id, team: player.team, element: "water",
      x: player.x, y: player.y, radius: 70, duration: 2, pulseRemaining: 0,
    },
  ];
  stepMatch(state, {}, 1 / 120);
  assert.equal(state.elementFields.some((field) => field.element === "fire"), true);
  assert.equal(state.elementFields.some((field) => field.element === "water"), true);
  assert.equal(state.events.some((event) => event.type === "elementReaction"), false);
  assert.equal(player.wet, true);
});

test("freeplay friendly fire is explicit and isolated", () => {
  const state = createMatch({
    modeId: "freeplay", mapId: "sanctum", botCount: 0,
    players: [
      { id: "one", characterId: "mara", raceId: "human", team: "alpha", human: true },
      { id: "two", characterId: "nix", raceId: "gnome", team: "alpha", human: true },
    ],
  });
  const target = state.entities[1];
  target.spawnProtection = 0;
  state.elementFields = [{
    id: "ally-fire", ownerId: "one", team: "alpha", element: "fire",
    x: target.x, y: target.y, radius: 80, duration: 2, pulseRemaining: 0,
  }];
  const before = target.health;
  stepMatch(state, {}, 1 / 120);
  assert.equal(target.health, before);
  setFreeplaySettings(state, { friendlyFire: true });
  state.elementFields[0].pulseRemaining = 0;
  stepMatch(state, {}, 1 / 120);
  assert.ok(target.health < before);
});


test("mirror mode applies one authoritative universal loadout to every player and bot", () => {
  const shared = ["night-flak", "mirror-bulwark", "eel-step"];
  const state = createMatch({
    modeId: "mirror",
    mapId: "crosswind",
    botCount: 1,
    players: [
      {
        id: "leader", characterId: "mara", raceId: "human", team: "alpha", human: true,
        activeAbilityIds: shared, ultimateAbilityId: "the-dead-sky",
      },
      {
        id: "rival", characterId: "nix", raceId: "gnome", team: "beta", human: true,
        activeAbilityIds: ["stone-shot", "gust-ring", "rime-wing"], ultimateAbilityId: "sun-grid",
      },
    ],
  });
  for (const entity of state.entities) {
    assert.deepEqual(entity.activeAbilityIds, shared);
    assert.equal(entity.ultimateAbilityId, "the-dead-sky");
  }
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("movement trial advances authored gates and ends for the first finisher", () => {
  const state = createMatch({
    modeId: "movement", mapId: "crosswind", botCount: 0,
    players: [{ id: "runner", characterId: "aerwyn", raceId: "elf", team: "alpha", human: true }],
  });
  const runner = state.entities[0];
  assert.equal(state.movementTrial.gates.length, 5);
  for (const [index, gate] of state.movementTrial.gates.entries()) {
    runner.x = gate.x;
    runner.y = gate.y;
    runner.lastSafeX = gate.x;
    runner.lastSafeY = gate.y;
    stepMatch(state, {}, 1 / 120);
    assert.equal(state.movementTrial.progress[runner.id], index + 1);
  }
  assert.equal(state.status, "match-over");
  assert.equal(state.winner, "alpha");
  assert.equal(state.movementTrial.completedBy, runner.id);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("siege awards only enemy structure breaks and ends at the bounded target", () => {
  const state = createMatch({
    modeId: "siege", mapId: "sanctum", botCount: 0,
    players: [
      { id: "breaker", characterId: "olli", raceId: "minotaur", team: "alpha", human: true },
      { id: "guard", characterId: "gorum", raceId: "orc", team: "beta", human: true },
    ],
  });
  const targets = state.destructibles.filter((piece) => piece.ownerTeam === "beta");
  assert.ok(targets.length >= 3);
  for (const piece of targets) {
    damageStructure(state, piece.id, piece.maxHealth, "breaker", "test");
  }
  assert.ok(state.score.alpha >= state.siege.targetScore);
  assert.equal(state.status, "match-over");
  assert.equal(state.winner, "alpha");
  assert.equal(state.events.some((event) => event.type === "siegeScore"), true);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("extraction requires earned cargo at the authored exit and dropped cargo is recoverable", () => {
  const state = createMatch({
    modeId: "extraction", mapId: "crosswind", botCount: 0,
    players: [
      { id: "carrier", characterId: "oh-tipi", raceId: "seakin", team: "alpha", human: true },
      { id: "hunter", characterId: "fluup", raceId: "orc", team: "beta", human: true },
    ],
  });
  const carrier = state.entities.find((entity) => entity.id === "carrier");
  state.extraction.drops.push({ id: "drop", x: carrier.x, y: carrier.y, amount: state.extraction.required });
  stepMatch(state, {}, 1 / 120);
  assert.equal(carrier.cargo, state.extraction.required);
  assert.equal(state.status, "playing");
  carrier.x = state.extraction.exit.x;
  carrier.y = state.extraction.exit.y;
  carrier.lastSafeX = carrier.x;
  carrier.lastSafeY = carrier.y;
  stepMatch(state, {}, 1 / 120);
  assert.equal(state.status, "match-over");
  assert.equal(state.winner, "alpha");
  assert.equal(state.extraction.extractedBy, carrier.id);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("race traits create bounded distinct playstyles in the authoritative simulation", () => {
  const trollState = createMatch({
    modeId: "freeplay", mapId: "sanctum", botCount: 0,
    players: [{ id: "troll", characterId: "mog", raceId: "troll", team: "alpha", human: true }],
  });
  const troll = trollState.entities[0];
  troll.health -= 20;
  troll.mendDelay = 0;
  stepMatch(trollState, {}, 1);
  assert.ok(troll.health > troll.maxHealth - 20);

  const scaleState = createMatch({
    modeId: "freeplay", mapId: "sanctum", botCount: 0,
    players: [{ id: "scale", characterId: "yrsa", raceId: "scaleheir", team: "alpha", human: true }],
  });
  assert.equal(scaleState.entities[0].airJumpsRemaining, 2);

  const siege = createMatch({
    modeId: "siege", mapId: "sanctum", botCount: 0,
    players: [
      { id: "minotaur", characterId: "olli", raceId: "minotaur", team: "alpha", human: true },
      { id: "target", characterId: "gorum", raceId: "stonewrought", team: "beta", human: true },
    ],
  });
  const minotaur = siege.entities[0];
  const enemyPiece = siege.destructibles.find((piece) => piece.ownerTeam === "beta");
  minotaur.vx = 900;
  const before = enemyPiece.health;
  damageStructure(siege, enemyPiece.id, 20, minotaur.id, "momentum-test");
  assert.ok(before - enemyPiece.health > 20);

  const baronState = createMatch({
    modeId: "freeplay", mapId: "sanctum", botCount: 0,
    players: [{ id: "baron", characterId: "rote-baron", raceId: "undead", team: "alpha", human: true }],
  });
  const baron = baronState.entities[0];
  baronState.elementFields.push({
    id: "expiring-fire", ownerId: baron.id, team: baron.team, element: "fire",
    x: baron.x + 100, y: baron.y, radius: 60, duration: 0.001, pulseRemaining: 1,
  });
  stepMatch(baronState, {}, 0.01);
  assert.equal(baronState.events.some((event) => event.type === "coldAshes"), true);
  assert.equal(baronState.elementFields.some((field) => field.source === "cold-ashes"), true);
  assert.deepEqual(matchInvariantErrors(baronState), []);
});
