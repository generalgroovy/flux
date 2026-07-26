import test from "node:test";
import assert from "node:assert/strict";

import {
  CHARACTERS,
  MAPS,
  MODES,
  RACES,
  MATCH_TUNING,
  getCharacter,
  validateContent,
} from "../src/content.mjs";
import {
  addMatchPlayer,
  createMatch,
  matchInvariantErrors,
  moveCircleSwept,
  normalizeDirection,
  removeMatchPlayer,
  sanitizeCommand,
  stepMatch,
} from "../src/match.mjs";

const FIXED_DELTA = 1 / MATCH_TUNING.tickRate;
const idle = Object.freeze({
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

function duel({
  leftCharacter = "kite",
  rightCharacter = "bulwark",
  mapId = "crosswind",
  leftRace = "human",
  rightRace = "human",
} = {}) {
  const state = createMatch({
    modeId: "duel",
    mapId,
    botCount: 0,
    players: [
      {
        id: "left",
        characterId: leftCharacter,
        raceId: leftRace,
        team: "alpha",
        human: true,
      },
      {
        id: "right",
        characterId: rightCharacter,
        raceId: rightRace,
        team: "beta",
        human: true,
      },
    ],
  });
  const [left, right] = state.entities;
  left.x = 350;
  left.y = 450;
  left.lastSafeX = left.x;
  left.lastSafeY = left.y;
  left.facingX = 1;
  left.facingY = 0;
  left.spawnProtection = 0;
  right.x = 540;
  right.y = 450;
  right.lastSafeX = right.x;
  right.lastSafeY = right.y;
  right.facingX = -1;
  right.facingY = 0;
  right.spawnProtection = 0;
  return state;
}

test("content ships ten playable champions, thirteen races, eight maps, and all five mode gates", () => {
  assert.deepEqual(validateContent(), []);
  assert.equal(CHARACTERS.length, 10);
  assert.equal(RACES.length, 13);
  assert.ok(MAPS.length >= 8);
  assert.deepEqual(
    new Set(MODES.map((mode) => mode.id)),
    new Set(["training", "duel", "control", "convergence", "survival"]),
  );
  assert.equal(
    new Set(CHARACTERS.map((agent) => agent.silhouette)).size,
    CHARACTERS.length,
  );
  assert.ok(
    validateContent({
      tuning: {
        ...MATCH_TUNING,
        flow: { ...MATCH_TUNING.flow, hopCost: 101 },
      },
    }).includes("flow.hopCost must not exceed flow.maximum"),
  );
  for (const agent of CHARACTERS) {
    assert.ok(agent.radius < 21);
    assert.ok(agent.glyph);
    assert.ok(agent.primary.name);
    assert.ok(agent.special.name);
    assert.equal(agent.tactical, agent.special);
    assert.ok(agent.defense.name);
    assert.ok(agent.mobility.name);
    assert.ok(agent.affinity.id);
    assert.equal(agent.affinity.kind, "element");
  }
  const yrsa = getCharacter("rimewing");
  assert.equal(yrsa.passive.kind, "movement-prime");
  assert.equal(yrsa.ultimate.kind, "line-volley");
  assert.equal(yrsa.ultimate.chargeRequired, MATCH_TUNING.ultimate.maximum);
  const varka = getCharacter("ashmaw");
  assert.equal(varka.passive.kind, "field-temper");
  assert.equal(varka.ultimate.kind, "field-crown");
});

test("every arena is an authored old-world place rather than a bare combat grid", () => {
  for (const map of MAPS) {
    assert.ok(map.region);
    assert.ok(map.terrain);
    assert.ok(map.lore.length >= 80);
    assert.ok(map.heraldry);
    assert.ok(map.landmarks.length >= 2);
    assert.ok(map.landmarks.some((landmark) => landmark.type === "rune"));
  }
});

test("The Fracture ships a complete nested scale ladder", () => {
  const fractureMaps = MAPS.filter((map) => map.regionId === "fracture");
  assert.deepEqual(
    new Set(fractureMaps.map((map) => map.scale)),
    new Set(["duel", "small", "medium", "large"]),
  );
  assert.equal(new Set(fractureMaps.map((map) => map.id)).size, 4);
  assert.ok(fractureMaps.every((map) => Number.isFinite(map.atlas.regionX)));
  assert.ok(fractureMaps.every((map) => Number.isFinite(map.atlas.regionY)));
});

test("the covenant shrine rewards committed movement without passive damage", () => {
  const state = duel({ mapId: "oathscar_vale", hazardsEnabled: false });
  const runner = state.entities[0];
  runner.x = 680;
  runner.y = 450;
  runner.lastSafeX = runner.x;
  runner.lastSafeY = runner.y;
  runner.flux = 40;
  let claim = null;
  for (let tick = 0; tick < 40 && !claim; tick += 1) {
    stepMatch(state, {
      [runner.id]: {
        moveX: 1, moveY: 0, aimX: 1, aimY: 0,
        mobility: tick === 0,
      },
    });
    claim = state.events.find((event) => event.type === "shrineClaim") ?? null;
  }
  assert.ok(claim);
  assert.equal(claim.entityId, runner.id);
  assert.ok(runner.flux > 40);
  assert.equal(state.shrines[0].readyIn > 6, true);
  assert.equal(state.entities[1].health, state.entities[1].maxHealth);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("race tradeoffs alter bounded resources without replacing character kits", () => {
  const state = duel({ leftRace: "sylph", rightRace: "stonekin" });
  const [sylph, stonekin] = state.entities;
  assert.ok(sylph.speedScale > stonekin.speedScale);
  assert.ok(sylph.maxHealth < stonekin.maxHealth);
  assert.equal(sylph.characterId, "kite");
  assert.equal(stonekin.characterId, "bulwark");
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("Wyrmbound trade FLOW for readable forced-movement resistance", () => {
  const human = duel({ leftCharacter: "bulwark", rightRace: "human" });
  const scaled = duel({ leftCharacter: "bulwark", rightRace: "wyrmbound" });
  for (const state of [human, scaled]) {
    state.entities[1].x = 440;
    state.entities[1].y = 450;
    state.entities[1].lastSafeX = 440;
    state.entities[1].lastSafeY = 450;
    stepMatch(state, { left: { ...idle, special: true } }, FIXED_DELTA);
  }
  assert.ok(Math.abs(scaled.entities[1].vx) < Math.abs(human.entities[1].vx));
  assert.ok(scaled.entities[1].maxFlow < human.entities[1].maxFlow);
  assert.equal(
    human.entities[1].maxHealth - human.entities[1].health,
    scaled.entities[1].maxHealth - scaled.entities[1].health,
  );
  assert.deepEqual(matchInvariantErrors(scaled), []);
});

test("Yrsa converts mastered universal movement into one precise non-damage prime", () => {
  const state = duel({ leftCharacter: "rimewing" });
  const yrsa = state.entities[0];
  const kit = getCharacter("rimewing");
  yrsa.wallContactRemaining = MATCH_TUNING.flow.wallMemory;
  yrsa.wallX = -1;
  yrsa.wallY = 0;
  stepMatch(
    state,
    { left: { ...idle, moveY: 1, hop: true } },
    FIXED_DELTA,
  );
  assert.equal(
    state.events.some(
      (event) => event.type === "passivePrimed" && event.trigger === "WALL KICK",
    ),
    true,
  );
  assert.ok(yrsa.passiveRemaining > 1);

  stepMatch(state, { left: { ...idle, fire: true } }, FIXED_DELTA);
  const fangs = state.projectiles.filter(
    (projectile) => projectile.ownerId === yrsa.id && projectile.source === "primary",
  );
  assert.equal(fangs.length, 2);
  assert.ok(Math.hypot(fangs[0].vx, fangs[0].vy) > kit.primary.speed);
  const angleGap = Math.abs(
    Math.atan2(fangs[1].vy, fangs[1].vx) -
      Math.atan2(fangs[0].vy, fangs[0].vx),
  );
  assert.ok(angleGap < kit.primary.spread);
  assert.ok(fangs.every((projectile) => projectile.damage === kit.primary.damage));
  assert.equal(yrsa.passiveRemaining, 0);
  assert.equal(state.events.some((event) => event.type === "passiveSpent"), true);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("The White Hunt earns charge through damage and resolves a counterable marked lane", () => {
  const state = duel({ leftCharacter: "rimewing" });
  const [yrsa, target] = state.entities;
  const ultimate = getCharacter("rimewing").ultimate;
  target.x = 450;
  target.y = yrsa.y;
  target.lastSafeX = target.x;
  target.lastSafeY = target.y;
  yrsa.ultimateCharge = 90;
  stepMatch(state, { left: { ...idle, special: true } }, FIXED_DELTA);
  assert.equal(yrsa.ultimateCharge, ultimate.chargeRequired);
  assert.equal(state.events.some((event) => event.type === "ultimateReady"), true);

  yrsa.specialCooldown = 0;
  stepMatch(state, { left: { ...idle, ultimate: true } }, FIXED_DELTA);
  assert.equal(yrsa.ultimateCharge, 0);
  assert.ok(yrsa.ultimateWindupRemaining > 0);
  assert.equal(state.elementFields.length, 1);
  assert.equal(state.events.some((event) => event.type === "ultimateTell"), true);
  assert.equal(
    state.projectiles.some((projectile) => projectile.source === "ultimate"),
    false,
  );
  target.y += 280;
  target.lastSafeY = target.y;

  let cast = false;
  for (let tick = 0; tick < Math.ceil(ultimate.windup / FIXED_DELTA) + 3; tick += 1) {
    stepMatch(
      state,
      { left: { ...idle, aimX: 0, aimY: 1, fire: true } },
      FIXED_DELTA,
    );
    cast ||= state.events.some((event) => event.type === "ultimateCast");
  }
  assert.equal(cast, true);
  assert.equal(
    state.projectiles.filter((projectile) => projectile.source === "ultimate").length,
    ultimate.count,
  );
  assert.equal(
    state.elementFields.filter(
      (field) => field.element === "ice" && field.source === "ultimate",
    ).length,
    ultimate.fieldCount,
  );
  assert.ok(state.projectiles.every((projectile) => projectile.damage <= ultimate.damage));
  target.x = yrsa.x + 82;
  target.y = yrsa.y;
  target.lastSafeX = target.x;
  target.lastSafeY = target.y;
  target.damageInvulnerability = 0;
  const beforeUltimateHit = target.health;
  for (let tick = 0; tick < 8 && target.health === beforeUltimateHit; tick += 1) {
    stepMatch(state, { left: idle }, FIXED_DELTA);
  }
  assert.ok(target.health < beforeUltimateHit);
  assert.equal(yrsa.ultimateCharge, 0);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("Volt interruption cancels The White Hunt during its visible commitment", () => {
  const state = duel({ leftCharacter: "rimewing", rightCharacter: "volt" });
  const yrsa = state.entities[0];
  yrsa.ultimateCharge = yrsa.maxUltimate;
  stepMatch(state, { left: { ...idle, ultimate: true } }, FIXED_DELTA);
  yrsa.interruptRemaining = MATCH_TUNING.elements.lightningInterrupt;
  stepMatch(state, { left: idle }, FIXED_DELTA);
  assert.equal(yrsa.ultimateWindupRemaining, 0);
  assert.equal(yrsa.ultimateResolvePending, false);
  assert.equal(state.events.some((event) => event.type === "ultimateInterrupted"), true);
  assert.equal(
    state.projectiles.some((projectile) => projectile.source === "ultimate"),
    false,
  );
  for (let tick = 0; tick < MATCH_TUNING.tickRate; tick += 1) {
    stepMatch(state, { left: idle }, FIXED_DELTA);
  }
  assert.equal(
    state.projectiles.some((projectile) => projectile.source === "ultimate"),
    false,
  );
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("Varka trades projectile speed for weight only while owning Ember terrain", () => {
  const state = duel({ leftCharacter: "ashmaw", rightCharacter: "mend" });
  const [varka, tide] = state.entities;
  const kit = getCharacter("ashmaw");
  stepMatch(state, { left: { ...idle, fire: true } }, FIXED_DELTA);
  const ordinary = state.projectiles.find(
    (projectile) => projectile.ownerId === varka.id,
  );
  assert.equal(ordinary.heavy, false);
  state.projectiles = [];

  varka.primaryCooldown = 0;
  stepMatch(state, { left: { ...idle, special: true } }, FIXED_DELTA);
  const furrow = state.elementFields.filter(
    (field) => field.ownerId === varka.id && field.source === "tactical",
  );
  assert.equal(furrow.length, kit.tactical.fieldCount);
  varka.x = furrow[0].x;
  varka.y = furrow[0].y;
  varka.lastSafeX = varka.x;
  varka.lastSafeY = varka.y;
  const healthBefore = varka.health;
  stepMatch(state, { left: idle }, FIXED_DELTA);
  assert.equal(varka.passiveActive, true);
  assert.equal(varka.health, healthBefore);

  varka.primaryCooldown = 0;
  stepMatch(state, { left: { ...idle, fire: true } }, FIXED_DELTA);
  const tempered = state.projectiles.find(
    (projectile) => projectile.ownerId === varka.id,
  );
  assert.equal(tempered.heavy, true);
  assert.equal(tempered.damage, ordinary.damage);
  assert.ok(Math.hypot(tempered.vx, tempered.vy) < Math.hypot(ordinary.vx, ordinary.vy));
  assert.ok(tempered.radius > ordinary.radius);
  assert.ok(tempered.knockback > ordinary.knockback);
  assert.equal(state.events.some((event) => event.type === "passiveConverted"), true);

  tide.x = furrow[0].x;
  tide.y = furrow[0].y;
  tide.lastSafeX = tide.x;
  tide.lastSafeY = tide.y;
  stepMatch(state, { right: { ...idle, special: true } }, FIXED_DELTA);
  stepMatch(state, {}, FIXED_DELTA);
  assert.ok(
    state.elementFields.filter(
      (field) => field.ownerId === varka.id && field.source === "tactical",
    ).length < furrow.length,
  );
  assert.equal(
    state.events.some(
      (event) => ["douse", "redirect"].includes(event.reaction),
    ),
    true,
  );
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("The Ashen Crown telegraphs open seams, cannot self-charge, and yields to Null", () => {
  const state = duel({ leftCharacter: "ashmaw", rightCharacter: "orbit" });
  const [varka, nullCantor] = state.entities;
  const ultimate = getCharacter("ashmaw").ultimate;
  varka.ultimateCharge = varka.maxUltimate;
  stepMatch(state, { left: { ...idle, ultimate: true } }, FIXED_DELTA);
  assert.equal(varka.ultimateCharge, 0);
  assert.ok(varka.ultimateTargetX > varka.x);
  assert.equal(state.events.some((event) => event.type === "ultimateTell"), true);
  nullCantor.x = varka.ultimateTargetX + ultimate.crownRadius;
  nullCantor.y = varka.ultimateTargetY;
  nullCantor.lastSafeX = nullCantor.x;
  nullCantor.lastSafeY = nullCantor.y;
  const healthBefore = nullCantor.health;

  let cast = false;
  for (let tick = 0; tick < Math.ceil(ultimate.windup / FIXED_DELTA) + 3; tick += 1) {
    stepMatch(state, {}, FIXED_DELTA);
    cast ||= state.events.some((event) => event.type === "ultimateCast");
  }
  assert.equal(cast, true);
  const crown = state.elementFields.filter(
    (field) => field.ownerId === varka.id && field.source === "ultimate",
  );
  assert.equal(crown.length, ultimate.fieldCount);
  assert.ok(
    crown.every(
      (field) =>
        Math.abs(
          Math.hypot(
            field.x - varka.ultimateTargetX,
            field.y - varka.ultimateTargetY,
          ) - ultimate.crownRadius,
        ) < 0.001,
    ),
  );
  assert.ok(
    ultimate.fieldRadius * 2 * ultimate.fieldCount <
      Math.PI * 2 * ultimate.crownRadius * 0.72,
  );
  assert.ok(nullCantor.health < healthBefore);
  assert.equal(varka.ultimateCharge, 0);

  nullCantor.x = varka.ultimateTargetX;
  nullCantor.y = varka.ultimateTargetY;
  nullCantor.lastSafeX = nullCantor.x;
  nullCantor.lastSafeY = nullCantor.y;
  nullCantor.specialCooldown = 0;
  stepMatch(state, { right: { ...idle, special: true } }, FIXED_DELTA);
  assert.equal(
    state.elementFields.some(
      (field) => field.ownerId === varka.id && field.source === "ultimate",
    ),
    false,
  );
  assert.equal(
    state.events.some(
      (event) => event.type === "elementReaction" && event.reaction === "nullify",
    ),
    true,
  );
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("bots commit authored crown ultimates through the shared command path", () => {
  const state = createMatch({
    modeId: "duel",
    mapId: "crosswind",
    botCount: 1,
    botCharacterIds: ["ashmaw"],
    players: [
      {
        id: "human",
        characterId: "kite",
        raceId: "human",
        team: "alpha",
        human: true,
      },
    ],
  });
  const human = state.entities.find((entity) => entity.human);
  const varka = state.entities.find((entity) => entity.bot);
  human.x = 350;
  human.y = 450;
  human.lastSafeX = human.x;
  human.lastSafeY = human.y;
  varka.x = 600;
  varka.y = 450;
  varka.lastSafeX = varka.x;
  varka.lastSafeY = varka.y;
  varka.ultimateCharge = varka.maxUltimate;
  varka.botThinkRemaining = 0;
  stepMatch(state, { human: idle }, FIXED_DELTA);
  assert.equal(varka.ultimateCharge, 0);
  assert.ok(varka.ultimateWindupRemaining > 0);
  assert.equal(
    state.events.some(
      (event) => event.type === "ultimateTell" && event.entityId === varka.id,
    ),
    true,
  );
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("elemental specials author persistent, counterable arena state", () => {
  const wind = duel({ leftCharacter: "kite", rightCharacter: "rook" });
  stepMatch(wind, { left: { ...idle, special: true } }, FIXED_DELTA);
  assert.equal(wind.elementFields.some((field) => field.element === "wind"), true);
  stepMatch(wind, {}, FIXED_DELTA);
  assert.ok(wind.entities[0].elementForceX > 0);

  const earth = duel({ leftCharacter: "bulwark", rightCharacter: "rook" });
  earth.entities[0].y = 700;
  earth.entities[1].y = 700;
  stepMatch(earth, { left: { ...idle, special: true } }, FIXED_DELTA);
  assert.equal(earth.elementFields.some((field) => field.element === "earth"), true);

  const ice = duel({ leftCharacter: "rimewing", rightCharacter: "rook" });
  stepMatch(ice, { left: { ...idle, special: true } }, FIXED_DELTA);
  assert.equal(ice.elementFields.some((field) => field.element === "ice"), true);

  const veil = duel({ leftCharacter: "echo", rightCharacter: "rook" });
  stepMatch(veil, { left: { ...idle, special: true } }, FIXED_DELTA);
  assert.equal(veil.decoys.length, 1);
  const originX = veil.entities[0].x;
  veil.entities[0].x += 90;
  veil.entities[0].specialCooldown = 0;
  stepMatch(veil, { left: { ...idle, special: true } }, FIXED_DELTA);
  assert.equal(veil.entities[0].x, originX);
  assert.equal(veil.decoys.length, 0);

  const lightning = duel({ leftCharacter: "volt", rightCharacter: "rook" });
  stepMatch(lightning, { left: { ...idle, special: true } }, FIXED_DELTA);
  assert.ok(lightning.entities[1].interruptRemaining > 0);
  assert.equal(
    lightning.events.some((event) => event.type === "elementInterrupt"),
    true,
  );
});

test("water douses fire and rewards allied FLOW positioning", () => {
  const state = duel({ leftCharacter: "mend", rightCharacter: "cinder" });
  const mend = state.entities[0];
  mend.flow = 20;
  state.elementFields.push({
    id: "test-fire",
    ownerId: state.entities[1].id,
    team: "beta",
    element: "fire",
    x: mend.x,
    y: mend.y,
    radius: 80,
    duration: 2,
    pulseRemaining: 0,
  });
  stepMatch(state, { left: { ...idle, special: true } }, FIXED_DELTA);
  stepMatch(state, {}, FIXED_DELTA);
  assert.equal(state.elementFields.some((field) => field.element === "fire"), false);
  assert.ok(mend.flow > 20);
  assert.equal(
    state.events.some(
      (event) => event.type === "elementReaction" && event.reaction === "douse",
    ),
    true,
  );
});

test("element fields resolve physical reactions deterministically", () => {
  const state = duel();
  const base = {
    ownerId: state.entities[0].id,
    team: "alpha",
    x: 800,
    y: 700,
    radius: 80,
    duration: 2,
    pulseRemaining: 0,
  };
  state.elementFields = [
    { ...base, id: "fire", element: "fire" },
    { ...base, id: "ice", element: "ice" },
  ];
  stepMatch(state, {}, FIXED_DELTA);
  assert.equal(state.elementFields.length, 0);
  assert.equal(
    state.events.some(
      (event) => event.type === "elementReaction" && event.reaction === "melt",
    ),
    true,
  );

  state.elementFields = [
    { ...base, id: "water", element: "water" },
    { ...base, id: "ice-2", element: "ice" },
  ];
  stepMatch(state, {}, FIXED_DELTA);
  assert.deepEqual(state.elementFields.map((field) => field.element), ["ice"]);
  assert.equal(
    state.events.some((event) => event.reaction === "freeze"),
    true,
  );

  state.elementFields = [
    {
      ...base,
      id: "wind",
      element: "wind",
      directionX: 1,
      directionY: 0,
    },
    { ...base, id: "carried-fire", element: "fire" },
  ];
  stepMatch(state, {}, FIXED_DELTA);
  const carriedFire = state.elementFields.find((field) => field.element === "fire");
  assert.ok(carriedFire.x > base.x);

  state.elementFields = [
    {
      ...base,
      id: "cross-gale",
      element: "wind",
      directionX: 0,
      directionY: 1,
    },
  ];
  state.projectiles = [
    {
      id: 900,
      ownerId: state.entities[0].id,
      team: "alpha",
      source: "test",
      x: base.x,
      y: base.y,
      previousX: base.x,
      previousY: base.y,
      vx: 600,
      vy: 0,
      radius: 4,
      damage: 1,
      lifetime: 1,
      knockback: 0,
      pierce: 0,
      heavy: false,
      reflected: false,
      fieldIds: [],
    },
  ];
  stepMatch(state, {}, FIXED_DELTA);
  assert.ok(state.projectiles[0].vy > 0);
  assert.equal(state.events.some((event) => event.reaction === "deflect"), true);
});

test("Null erases nearby constructs only on its paid commitment", () => {
  const state = duel({ leftCharacter: "orbit", rightCharacter: "rook" });
  const orbit = state.entities[0];
  state.elementFields = [
    {
      id: "movable-fire",
      ownerId: state.entities[1].id,
      team: "beta",
      element: "fire",
      x: orbit.x + 120,
      y: orbit.y,
      radius: 40,
      duration: 2,
      pulseRemaining: 1,
    },
    {
      id: "fixed-stone",
      ownerId: orbit.id,
      team: "alpha",
      element: "earth",
      x: orbit.x - 100,
      y: orbit.y + 80,
      width: 24,
      height: 100,
      duration: 2,
      pulseRemaining: 0,
    },
  ];
  stepMatch(state, { left: { ...idle, special: true } }, FIXED_DELTA);
  assert.equal(state.elementFields.length, 0);
  assert.equal(state.events.some((event) => event.reaction === "nullify"), true);
});

test("commands reject non-finite movement and aim without poisoning state", () => {
  assert.deepEqual(
    sanitizeCommand({
      moveX: Number.NaN,
      moveY: Number.POSITIVE_INFINITY,
      aimX: Number.NEGATIVE_INFINITY,
      aimY: "not a number",
      fire: 1,
    }),
    { ...idle, aimX: 0 },
  );
  assert.deepEqual(normalizeDirection(0, -10), { x: 0, y: -1 });
});

test("Flux creates payable commitments, dry tells, and delayed recovery", () => {
  const state = duel();
  const player = state.entities[0];
  const specialCost = getCharacter(player.characterId).special.fluxCost;
  stepMatch(state, { left: { ...idle, special: true } }, FIXED_DELTA);
  assert.equal(player.flux, player.maxFlux - specialCost);
  assert.ok(player.fluxRecoveryDelay > 0);

  player.specialCooldown = 0;
  player.flux = specialCost - 1;
  stepMatch(state, { left: { ...idle, special: true } }, FIXED_DELTA);
  assert.equal(player.specialCooldown, 0);
  assert.equal(state.events.some((event) => event.type === "fluxDry"), true);

  const dryFlux = player.flux;
  for (let tick = 0; tick < MATCH_TUNING.tickRate; tick += 1) {
    stepMatch(state, { left: idle }, FIXED_DELTA);
  }
  assert.ok(player.flux > dryFlux);
  assert.ok(player.flux <= player.maxFlux);
});

test("dashing repeatedly into walls and corners never hides or corrupts an agent", () => {
  const state = duel({ mapId: "breakline" });
  const player = state.entities[0];
  player.x = 460;
  player.y = 185;
  player.lastSafeX = player.x;
  player.lastSafeY = player.y;
  player.facingX = 1;
  player.facingY = 1;

  for (let tick = 0; tick < MATCH_TUNING.tickRate * 20; tick += 1) {
    const mobilityReady = player.mobilityCooldown === 0;
    stepMatch(
      state,
      {
        left: {
          ...idle,
          moveX: 1,
          moveY: tick % 240 < 120 ? 1 : -1,
          aimX: 1,
          aimY: tick % 240 < 120 ? 1 : -1,
          mobility: mobilityReady,
        },
      },
      FIXED_DELTA,
    );
    assert.equal(player.alive, true);
    assert.deepEqual(matchInvariantErrors(state), []);
  }
  assert.ok(
    state.events.every((event) => event.type !== "stateRepair"),
    "normal collision stress must not need emergency repair",
  );
});

test("swept movement stops a blink at cover instead of tunneling or disappearing", () => {
  const state = duel({ leftCharacter: "echo", mapId: "breakline" });
  const player = state.entities[0];
  player.x = 450;
  player.y = 250;
  player.lastSafeX = player.x;
  player.lastSafeY = player.y;
  stepMatch(
    state,
    { left: { ...idle, aimX: 1, mobility: true } },
    FIXED_DELTA,
  );

  assert.ok(player.x < 490 - getCharacter("echo").radius + 0.1);
  assert.equal(Number.isFinite(player.x), true);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("coincident units separate deterministically without non-finite velocity", () => {
  const state = duel();
  const [left, right] = state.entities;
  right.x = left.x;
  right.y = left.y;
  right.lastSafeX = right.x;
  right.lastSafeY = right.y;

  stepMatch(state, {}, FIXED_DELTA);
  assert.ok(Math.hypot(right.x - left.x, right.y - left.y) > 0);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("opposing projectiles clash under shared simulation ownership", () => {
  const state = duel({ leftCharacter: "kite", rightCharacter: "kite" });
  const commands = {
    left: { ...idle, fire: true },
    right: { ...idle, aimX: -1, fire: true },
  };
  stepMatch(state, commands, FIXED_DELTA);
  let clashed = false;
  for (let tick = 0; tick < 60; tick += 1) {
    stepMatch(state, {}, FIXED_DELTA);
    clashed ||= state.events.some((event) => event.type === "projectileClash");
  }
  assert.equal(clashed, true);
  assert.equal(state.entities[0].health, state.entities[0].maxHealth);
  assert.equal(state.entities[1].health, state.entities[1].maxHealth);
});

test("reflect, guard, phase, absorb, and counter defenses have distinct outcomes", () => {
  const cases = [
    { id: "kite", event: "reflect", health: "full" },
    { id: "bulwark", event: "guarded", health: "reduced" },
    { id: "echo", event: null, health: "full" },
    { id: "mend", event: "absorb", health: "full" },
    { id: "rook", event: "counter", health: "full" },
  ];
  for (const defenseCase of cases) {
    const state = duel({
      leftCharacter: "bulwark",
      rightCharacter: defenseCase.id,
    });
    const target = state.entities[1];
    target.x = 480;
    target.lastSafeX = target.x;
    target.health =
      defenseCase.id === "mend" ? target.maxHealth - 10 : target.maxHealth;
    stepMatch(
      state,
      {
        left: { ...idle, fire: true },
        right: { ...idle, aimX: -1, defend: true },
      },
      FIXED_DELTA,
    );
    const events = [];
    for (let tick = 0; tick < 100; tick += 1) {
      stepMatch(
        state,
        { right: { ...idle, aimX: -1 } },
        FIXED_DELTA,
      );
      events.push(...state.events.map((event) => event.type));
    }
    if (defenseCase.event) assert.ok(events.includes(defenseCase.event));
    if (defenseCase.health === "full") {
      assert.equal(target.health, target.maxHealth);
    } else {
      assert.ok(target.health < target.maxHealth);
      assert.ok(target.health > target.maxHealth - getCharacter("bulwark").primary.damage);
    }
    assert.deepEqual(matchInvariantErrors(state), []);
  }
});

test("every agent can use all four actions and remain valid", () => {
  for (const agent of CHARACTERS) {
    const state = duel({ leftCharacter: agent.id, rightCharacter: "bulwark" });
    const player = state.entities[0];
    stepMatch(
      state,
      {
        left: {
          ...idle,
          moveX: 1,
          aimX: 1,
          fire: true,
          special: true,
          defend: true,
          mobility: true,
        },
      },
      FIXED_DELTA,
    );
    const eventTypes = new Set(state.events.map((event) => event.type));
    assert.ok(eventTypes.has("shot"), `${agent.id} primary`);
    assert.ok(eventTypes.has("special"), `${agent.id} special`);
    assert.ok(eventTypes.has("defense"), `${agent.id} defense`);
    assert.ok(
      eventTypes.has("mobility") ||
        eventTypes.has("blink") ||
        eventTypes.has("blinkBlocked"),
      `${agent.id} mobility`,
    );
    assert.ok(player.primaryCooldown > 0);
    assert.ok(player.specialCooldown > 0);
    assert.ok(player.defenseCooldown > 0);
    assert.ok(player.mobilityCooldown > 0);
    assert.deepEqual(matchInvariantErrors(state), []);
  }
});

test("Cinder mines arm, detect hostile proximity, and apply one stable blast", () => {
  const state = duel({ leftCharacter: "cinder", rightCharacter: "kite" });
  const [left, right] = state.entities;
  right.x = left.x + 70;
  right.y = left.y;
  right.lastSafeX = right.x;
  right.lastSafeY = right.y;
  stepMatch(state, { left: { ...idle, special: true } }, FIXED_DELTA);
  let blasted = false;
  for (let tick = 0; tick < 80; tick += 1) {
    stepMatch(state, {}, FIXED_DELTA);
    blasted ||= state.events.some((event) => event.type === "mineBlast");
  }
  assert.equal(blasted, true);
  assert.ok(right.health < right.maxHealth);
  assert.equal(state.mines.length, 0);
  assert.equal(state.elementFields.some((field) => field.element === "fire"), true);
});

test("death creates a bounded duel round break and clean reset", () => {
  const state = duel({ leftCharacter: "volt", rightCharacter: "echo" });
  const target = state.entities[1];
  target.health = 1;
  stepMatch(state, { left: { ...idle, special: true } }, FIXED_DELTA);
  assert.equal(state.status, "round-over");
  assert.equal(state.score.alpha, 1);

  for (let tick = 0; tick < MATCH_TUNING.tickRate * 2; tick += 1) {
    stepMatch(state, {}, FIXED_DELTA);
  }
  assert.equal(state.status, "playing");
  assert.equal(state.round, 2);
  assert.ok(state.entities.every((entity) => entity.alive));
  assert.ok(
    state.entities.every((entity) => entity.health === entity.maxHealth),
  );
  assert.deepEqual(state.projectiles, []);
  assert.deepEqual(state.mines, []);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("training opponent stays non-lethal until movement and defense are taught", () => {
  const state = createMatch({
    modeId: "training",
    mapId: "crosswind",
    characterId: "kite",
    botCount: 1,
  });
  for (let tick = 0; tick < MATCH_TUNING.tickRate * 4; tick += 1) {
    stepMatch(state, {}, FIXED_DELTA);
  }
  assert.equal(state.tutorial.step, 0);
  assert.equal(state.projectiles.length, 0);
  assert.equal(state.entities[0].health, state.entities[0].maxHealth);
});

test("counter-strafing cuts committed momentum with a readable skill cue", () => {
  const state = duel();
  const runner = state.entities[0];
  for (let tick = 0; tick < 24; tick += 1) {
    stepMatch(state, { [runner.id]: { ...idle, moveX: 1 } });
  }
  const forwardVelocity = runner.vx;
  stepMatch(state, { [runner.id]: { ...idle, moveX: -1 } });
  assert.ok(forwardVelocity >= MATCH_TUNING.flow.counterStrafeCueSpeed);
  assert.ok(runner.vx < forwardVelocity);
  assert.ok(state.events.some((event) => event.type === "counterStrafe"));
  assert.ok(runner.counterStrafeCooldown > 0);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("hops preserve bounded lateral momentum without speed stacking", () => {
  const state = duel();
  const runner = state.entities[0];
  for (let tick = 0; tick < 28; tick += 1) {
    stepMatch(state, { [runner.id]: { ...idle, moveY: 1, sprint: true } });
  }
  stepMatch(state, { [runner.id]: { ...idle, moveX: 1, hop: true } });
  assert.ok(runner.hopRemaining > 0);
  assert.ok(runner.vy > 0);
  assert.ok(Math.abs(runner.hopCarryY) <= MATCH_TUNING.flow.hopCarryLimit + 0.01);
  assert.ok(
    Math.hypot(runner.vx, runner.vy) <=
      MATCH_TUNING.flow.hopSpeed + MATCH_TUNING.flow.hopCarryLimit + 0.01,
  );
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("one post-hop counter-strafe consumes a bounded landing cancel", () => {
  const state = duel();
  const runner = state.entities[0];
  runner.vx = MATCH_TUNING.flow.hopSpeed;
  runner.hopX = 1;
  runner.hopY = 0;
  runner.hopRemaining = FIXED_DELTA / 2;
  stepMatch(state, { [runner.id]: { ...idle, moveX: -1 } }, FIXED_DELTA);
  assert.equal(runner.hopRemaining, 0);
  assert.equal(runner.landingRemaining, 0);
  assert.ok(state.events.some((event) => event.type === "landingCut"));
  stepMatch(state, { [runner.id]: { ...idle, moveX: 1 } }, FIXED_DELTA);
  stepMatch(state, { [runner.id]: { ...idle, moveX: -1 } }, FIXED_DELTA);
  assert.equal(state.events.some((event) => event.type === "landingCut"), false);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("sprint slides spend FLOW, steer with commitment, and break on cover", () => {
  const state = duel();
  const runner = state.entities[0];
  for (let tick = 0; tick < 16; tick += 1) {
    stepMatch(state, { [runner.id]: { ...idle, moveX: 1, sprint: true } });
  }
  const flowBefore = runner.flow;
  stepMatch(state, { [runner.id]: { ...idle, moveX: 1, sprint: true, hop: true } });
  assert.ok(runner.slideRemaining > 0);
  assert.equal(runner.hopRemaining, 0);
  assert.ok(runner.flow <= flowBefore - MATCH_TUNING.flow.slideCost + 0.01);
  assert.ok(Math.hypot(runner.vx, runner.vy) >= MATCH_TUNING.flow.slideSpeed - 0.01);
  stepMatch(state, { [runner.id]: { ...idle, moveX: -1, sprint: true, hop: true } });
  assert.ok(runner.vx > 0, "one frame cannot reverse a committed slide");

  runner.x = 680;
  runner.y = 450;
  runner.lastSafeX = runner.x;
  runner.lastSafeY = runner.y;
  runner.slideX = 1;
  runner.slideY = 0;
  runner.slideRemaining = MATCH_TUNING.flow.slideDuration;
  for (let tick = 0; tick < 30 && runner.slideRemaining > 0; tick += 1) {
    stepMatch(state, { [runner.id]: { ...idle, moveX: 1 } });
  }
  assert.equal(runner.slideRemaining, 0);
  assert.ok(state.events.some((event) => event.type === "slideImpact"));
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("movement chains respect commitment boundaries and remain speed-bounded", () => {
  const state = duel({ mapId: "oathscar_vale" });
  const runner = state.entities[0];
  let peakSpeed = 0;
  for (let tick = 0; tick < 24; tick += 1) {
    stepMatch(state, { [runner.id]: { ...idle, moveX: 1, sprint: true } });
  }
  stepMatch(state, {
    [runner.id]: { ...idle, moveX: 1, sprint: true, hop: true },
  });
  assert.ok(runner.slideRemaining > 0);
  stepMatch(state, { [runner.id]: { ...idle, moveY: 1, hop: true } });
  assert.equal(runner.hopRemaining, 0, "a slide cannot be silently hop-cancelled");
  while (runner.slideRemaining > 0) {
    stepMatch(state, { [runner.id]: { ...idle, moveX: 1 } });
    peakSpeed = Math.max(peakSpeed, Math.hypot(runner.vx, runner.vy));
  }
  runner.hopCooldown = 0;
  stepMatch(state, { [runner.id]: { ...idle, moveY: 1, hop: true } });
  assert.ok(runner.hopRemaining > 0, "a completed slide can route into a hop");

  runner.mobilityRemaining = 0.1;
  runner.mobilityX = 1;
  runner.mobilityY = 0;
  runner.hopRemaining = 0;
  runner.hopCooldown = 0;
  runner.slideCooldown = 0;
  stepMatch(state, {
    [runner.id]: { ...idle, moveX: 1, sprint: true, hop: true },
  });
  assert.equal(runner.slideRemaining, 0);
  assert.equal(runner.hopRemaining, 0, "universal movement cannot overlap character mobility");
  runner.mobilityRemaining = 0;
  runner.vx = 0;
  runner.vy = 0;

  for (let tick = 0; tick < 600; tick += 1) {
    const phase = tick % 120;
    stepMatch(state, {
      [runner.id]: {
        ...idle,
        moveX: phase < 60 ? 1 : -1,
        moveY: phase >= 30 && phase < 90 ? 1 : 0,
        sprint: phase < 36,
        hop: phase === 28 || phase === 88,
      },
    });
    peakSpeed = Math.max(peakSpeed, Math.hypot(runner.vx, runner.vy));
    assert.deepEqual(matchInvariantErrors(state), []);
  }
  assert.ok(peakSpeed <= MATCH_TUNING.flow.wallKickSpeed + MATCH_TUNING.flow.hopCarryLimit + 0.01);
});

test("flow sprint, hop, and wall kick are bounded universal movement", () => {
  const state = duel({ mapId: "crosswind" });
  const player = state.entities[0];
  const baseSpeed = getCharacter(player.characterId).speed;

  for (let tick = 0; tick < 30; tick += 1) {
    stepMatch(
      state,
      { left: { ...idle, moveX: 1, sprint: true } },
      FIXED_DELTA,
    );
  }
  assert.ok(player.vx > baseSpeed);
  assert.ok(player.flow < MATCH_TUNING.flow.maximum);

  const flowBeforeHop = player.flow;
  stepMatch(state, { left: { ...idle, moveY: 1, hop: true } }, FIXED_DELTA);
  assert.equal(player.hopRemaining > 0, true);
  assert.equal(player.flow, flowBeforeHop - MATCH_TUNING.flow.hopCost);
  assert.equal(state.events.some((event) => event.type === "hop"), true);

  player.hopRemaining = 0;
  player.hopCooldown = 0;
  player.x = getCharacter(player.characterId).radius;
  stepMatch(state, { left: { ...idle, moveX: -1 } }, FIXED_DELTA);
  assert.equal(player.wallContactRemaining > 0, true);
  stepMatch(state, { left: { ...idle, moveY: 1, hop: true } }, FIXED_DELTA);
  assert.equal(player.vx > 0, true);
  assert.equal(state.events.some((event) => event.type === "wallKick"), true);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("flow recovers only after its explicit commitment window", () => {
  const state = duel();
  const player = state.entities[0];
  stepMatch(
    state,
    { left: { ...idle, moveX: 1, sprint: true } },
    FIXED_DELTA,
  );
  const spentFlow = player.flow;
  stepMatch(state, { left: idle }, FIXED_DELTA);
  assert.equal(player.flow, spentFlow);
  for (let tick = 0; tick < MATCH_TUNING.tickRate; tick += 1) {
    stepMatch(state, { left: idle }, FIXED_DELTA);
  }
  assert.ok(player.flow > spentFlow);
  assert.ok(player.flow <= MATCH_TUNING.flow.maximum);
});

test("first contact teaches flow before the complete combat language", () => {
  const state = createMatch({
    modeId: "training",
    mapId: "breakline",
    characterId: "kite",
    botCount: 1,
  });
  for (let tick = 0; tick < 16; tick += 1) {
    stepMatch(state, { p1: { ...idle, moveX: 1, sprint: true } }, FIXED_DELTA);
  }
  assert.equal(state.tutorial.step, 0);
  stepMatch(
    state,
    { p1: { ...idle, moveX: 1, sprint: true, hop: true } },
    FIXED_DELTA,
  );
  assert.equal(state.tutorial.step, 0);
  assert.equal(state.tutorial.slid, true);
  for (let tick = 0; tick < 40; tick += 1) {
    stepMatch(state, { p1: idle }, FIXED_DELTA);
  }
  stepMatch(state, { p1: { ...idle, moveX: 1, hop: true } }, FIXED_DELTA);
  assert.equal(state.tutorial.step, 1);
  assert.equal(state.tutorial.sprinted, true);
  assert.equal(state.tutorial.hopped, true);

  stepMatch(state, { p1: { ...idle, moveX: 1, fire: true } }, FIXED_DELTA);
  assert.equal(state.tutorial.step, 2);
  assert.equal(state.tutorial.moved, true);
  assert.equal(state.tutorial.fired, true);

  stepMatch(
    state,
    { p1: { ...idle, moveY: 1, mobility: true, defend: true } },
    FIXED_DELTA,
  );
  assert.equal(state.tutorial.step, 3);
  assert.equal(state.tutorial.mobility, true);
  assert.equal(state.tutorial.defended, true);

  stepMatch(state, { p1: { ...idle, special: true } }, FIXED_DELTA);
  assert.equal(state.tutorial.step, 4);
  assert.equal(state.tutorial.special, true);
  assert.equal(
    state.events.some((event) => event.type === "tutorialComplete"),
    true,
  );
});

test("bot actions cannot complete a human first-contact read", () => {
  const state = createMatch({ modeId: "training", botCount: 1 });
  const player = state.entities.find((entity) => entity.human);
  const bot = state.entities.find((entity) => entity.bot);
  state.tutorial.step = 3;
  bot.x = player.x + 40;
  bot.y = player.y;
  bot.botThinkRemaining = 0;
  bot.specialCooldown = 0;
  stepMatch(state, {}, FIXED_DELTA);
  assert.ok(bot.specialCooldown > 0);
  assert.equal(state.tutorial.special, false);
  assert.equal(state.tutorial.step, 3);
});

test("duel overtime ends on the next elimination instead of starting another round", () => {
  const state = duel({ leftCharacter: "volt", rightCharacter: "echo" });
  state.elapsed = getModeById("duel").timeLimit - FIXED_DELTA;
  stepMatch(state, {}, FIXED_DELTA);
  assert.equal(state.overtime, true);
  state.entities[1].health = 1;
  stepMatch(state, { left: { ...idle, special: true } }, FIXED_DELTA);
  assert.equal(state.status, "match-over");
  assert.equal(state.winner, "alpha");
});

test("survival clears bounded waves, escalates opposition, and remains resettable", () => {
  const state = createMatch({
    modeId: "survival",
    mapId: "crosswind",
    botCount: 2,
    players: [
      {
        id: "survivor",
        characterId: "echo",
        team: "alpha",
        human: true,
        localSlot: 0,
      },
    ],
  });
  const player = state.entities[0];
  player.x = 400;
  player.y = 450;
  player.lastSafeX = player.x;
  player.lastSafeY = player.y;
  player.facingX = 1;
  for (const [index, enemy] of state.entities
    .filter((entity) => entity.team === "beta")
    .entries()) {
    enemy.x = 455 + index * 20;
    enemy.y = 450;
    enemy.lastSafeX = enemy.x;
    enemy.lastSafeY = enemy.y;
    enemy.health = 1;
    enemy.spawnProtection = 0;
  }
  stepMatch(
    state,
    { survivor: { ...idle, special: true } },
    FIXED_DELTA,
  );
  assert.equal(state.status, "round-over");
  assert.equal(state.score.alpha, 1);
  const initialEnemies = state.entities.filter(
    (entity) => entity.team === "beta",
  ).length;
  for (let tick = 0; tick < MATCH_TUNING.tickRate * 2; tick += 1) {
    stepMatch(state, {}, FIXED_DELTA);
  }
  assert.equal(state.status, "playing");
  assert.equal(state.survival.wave, 2);
  assert.ok(
    state.entities.filter((entity) => entity.team === "beta").length >
      initialEnemies,
  );
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("control scores only one uncontested team and convergence neutrals cannot capture", () => {
  const state = createMatch({
    modeId: "convergence",
    mapId: "crown",
    botCount: 0,
    players: [
      { id: "alpha", characterId: "kite", team: "alpha", human: true },
      { id: "beta", characterId: "kite", team: "beta", human: true },
    ],
  });
  const [alpha, beta, neutral] = state.entities;
  alpha.x = 800;
  alpha.y = 450;
  beta.x = 1200;
  beta.y = 700;
  neutral.x = 805;
  neutral.y = 450;
  for (const entity of state.entities) {
    entity.lastSafeX = entity.x;
    entity.lastSafeY = entity.y;
  }
  stepMatch(state, {}, 1);
  assert.ok(state.score.alpha > 0);
  assert.equal(state.score.beta, 0);
  assert.equal(state.objective.controllingTeam, "alpha");

  beta.x = 790;
  beta.y = 450;
  const score = state.score.alpha;
  stepMatch(state, {}, 1);
  assert.equal(state.objective.contested, true);
  assert.equal(state.score.alpha, score);
});

test("join-in-progress and disconnect preserve the running match", () => {
  const state = createMatch({ modeId: "control", mapId: "crown" });
  for (let tick = 0; tick < 100; tick += 1) {
    stepMatch(state, {}, FIXED_DELTA);
  }
  const elapsed = state.elapsed;
  const joined = addMatchPlayer(state, {
    id: "remote",
    clientId: "socket-2",
    name: "Late Pilot",
    characterId: "orbit",
  });
  assert.ok(joined);
  assert.equal(joined.spawnProtection > 0, true);
  assert.equal(state.elapsed, elapsed);
  assert.deepEqual(matchInvariantErrors(state), []);
  assert.equal(removeMatchPlayer(state, joined.id), true);
  assert.equal(state.status, "playing");
  assert.equal(state.entities.some((entity) => entity.id === joined.id), false);
});

test("all agent, map, and mode combinations survive deterministic interaction stress", () => {
  for (const mode of MODES) {
    for (const map of MAPS) {
      for (const agent of CHARACTERS) {
        const state = createMatch({
          modeId: mode.id,
          mapId: map.id,
          characterId: agent.id,
          botCount: Math.min(mode.botCount, 2),
          seed: 73,
        });
        for (let tick = 0; tick < MATCH_TUNING.tickRate * 2; tick += 1) {
          const angle = tick * 0.047;
          stepMatch(
            state,
            {
              p1: {
                moveX: Math.cos(angle * 0.7),
                moveY: Math.sin(angle * 0.9),
                aimX: Math.cos(angle),
                aimY: Math.sin(angle),
                fire: tick % 3 === 0,
                special: tick % 89 === 0,
                defend: tick % 113 === 0,
                mobility: tick % 127 === 0,
              },
            },
            FIXED_DELTA,
          );
          const errors = matchInvariantErrors(state);
          assert.deepEqual(
            errors,
            [],
            `${agent.id}/${map.id}/${mode.id} tick ${tick}: ${errors.join(", ")}`,
          );
        }
      }
    }
  }
});

test("eight-agent two-minute combat soak remains finite and memory-bounded", () => {
  const state = createMatch({
    modeId: "duel",
    mapId: "undercurrent",
    characterId: "kite",
    botCount: 7,
    seed: 919,
  });
  for (const entity of state.entities) entity.spawnProtection = 10_000;
  for (let tick = 0; tick < MATCH_TUNING.tickRate * 120; tick += 1) {
    const angle = tick * 0.031;
    stepMatch(
      state,
      {
        p1: {
          moveX: Math.cos(angle * 0.73),
          moveY: Math.sin(angle * 0.91),
          aimX: Math.cos(angle),
          aimY: Math.sin(angle),
          fire: true,
          special: tick % 83 === 0,
          defend: tick % 107 === 0,
          mobility: tick % 131 === 0,
        },
      },
      FIXED_DELTA,
    );
    if (tick % MATCH_TUNING.tickRate === 0) {
      assert.deepEqual(matchInvariantErrors(state), []);
      assert.ok(state.projectiles.length < 300);
      assert.ok(state.mines.length < 30);
    }
  }
  assert.equal(state.tick, MATCH_TUNING.tickRate * 120);
  assert.ok(JSON.stringify(state).length < 300_000);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("direct swept movement with invalid displacement safely remains finite", () => {
  const state = duel();
  const player = state.entities[0];
  moveCircleSwept(
    player,
    Number.NaN,
    Number.POSITIVE_INFINITY,
    getCharacter(player.characterId).radius,
    MAPS[1],
  );
  assert.equal(Number.isFinite(player.x), true);
  assert.equal(Number.isFinite(player.y), true);
});

function getModeById(id) {
  return MODES.find((mode) => mode.id === id);
}
