import test from "node:test";
import assert from "node:assert/strict";

import { MAPS, MATCH_TUNING, MODES } from "../src/content.mjs";
import {
  OVERHAUL_PREVIEW_PROFILE,
  OVERHAUL_RUNTIME_CHARACTERS,
  getOverhaulRuntimeCharacter,
  validateOverhaulRuntime,
} from "../src/overhaul-runtime.mjs";
import {
  addMatchPlayer,
  createMatch,
  matchInvariantErrors,
  sanitizeCommand,
  stepMatch,
} from "../src/match.mjs";

const DELTA = 1 / MATCH_TUNING.tickRate;
const command = (overrides = {}) => ({
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
  swap: false,
  ...overrides,
});

function previewDuel(mapId = "oathscar_vale") {
  const state = createMatch({
    contentProfile: OVERHAUL_PREVIEW_PROFILE,
    modeId: "duel",
    mapId,
    botCount: 0,
    players: [
      { id: "hara", characterId: "mara", raceId: "gnome", team: "alpha", human: true },
      { id: "target", characterId: "bulwark", raceId: "orc", team: "beta", human: true },
    ],
  });
  const hara = state.entities[0];
  const target = state.entities[1];
  for (const entity of state.entities) entity.spawnProtection = 0;
  return { state, hara, target };
}

test("overhaul runtime contains one lore-free, catalog-backed preview prototype", () => {
  assert.deepEqual(validateOverhaulRuntime(), []);
  assert.equal(OVERHAUL_RUNTIME_CHARACTERS.length, 1);
  const hara = getOverhaulRuntimeCharacter("mara");
  assert.equal(hara.name, "HARA");
  assert.equal(hara.availability, "preview-only");
  assert.equal(hara.implementationStatus, "prototype-local");
  assert.equal("lore" in hara, false);
  assert.deepEqual(hara.implementedAbilityIds, ["ray", "gust-ring", "stone-shot", "sun-grid"]);
  assert.deepEqual(hara.promotionGatesPassed, [
    "mechanic-prototype",
    "deterministic-local-tests",
    "bot-use",
  ]);
  assert.equal(hara.tactical, hara.special);
});

test("preview characters fail closed outside the explicit overhaul content profile", () => {
  const live = createMatch({ characterId: "mara", botCount: 0 });
  assert.equal(live.contentProfile, "live");
  assert.equal(live.entities[0].characterId, "kite");
  assert.equal(addMatchPlayer(live, { id: "late", characterId: "mara" }).characterId, "kite");

  const preview = createMatch({
    contentProfile: OVERHAUL_PREVIEW_PROFILE,
    characterId: "mara",
    botCount: 0,
  });
  assert.equal(preview.contentProfile, OVERHAUL_PREVIEW_PROFILE);
  assert.equal(preview.entities[0].characterId, "mara");
  assert.deepEqual(matchInvariantErrors(preview), []);
});

test("SECOND PLAN performs one deterministic sanctuary swap and resets next round", () => {
  const { state, hara } = previewDuel();
  const sanctuary = state.overhaul.sanctuaries.find((entry) =>
    entry.ownerSpawnIndex === hara.spawnIndex
  );
  hara.x = sanctuary.x;
  hara.y = sanctuary.y;
  hara.lastSafeX = hara.x;
  hara.lastSafeY = hara.y;

  stepMatch(state, { hara: command({ swap: true }) }, DELTA);
  assert.equal(hara.activePrimaryId, "stone-shot");
  assert.equal(hara.passiveUsesRemaining, 0);
  assert.ok(state.events.some((event) =>
    event.type === "activeSwapped" &&
    event.fromAbilityId === "ray" &&
    event.toAbilityId === "stone-shot"
  ));

  hara.primaryCooldown = 0;
  stepMatch(state, { hara: command({ fire: true, swap: true }) }, DELTA);
  const stone = state.projectiles.find((projectile) => projectile.ownerId === hara.id);
  assert.equal(stone.abilityId, "stone-shot");
  assert.equal(stone.heavy, true);
  assert.equal(hara.activePrimaryId, "stone-shot");

  state.status = "round-over";
  state.roundRemaining = 0;
  stepMatch(state, {}, DELTA);
  assert.equal(hara.activePrimaryId, "ray");
  assert.equal(hara.passiveUsesRemaining, 1);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("Hara's preview abilities preserve distinct range and commitment decisions", () => {
  const { state, hara, target } = previewDuel();
  hara.x = 350;
  hara.y = 450;
  target.x = 365;
  target.y = 450;
  for (const entity of [hara, target]) {
    entity.lastSafeX = entity.x;
    entity.lastSafeY = entity.y;
  }
  const healthBefore = target.health;
  stepMatch(state, { hara: command({ special: true }) }, DELTA);
  assert.equal(target.health, healthBefore);
  assert.equal(target.vx, 0);

  target.x = 430;
  target.lastSafeX = target.x;
  hara.specialCooldown = 0;
  hara.flux = hara.maxFlux;
  stepMatch(state, { hara: command({ special: true }) }, DELTA);
  assert.equal(target.health, healthBefore - 8);
  assert.ok(target.vx > 0);
  assert.ok(state.events.some((event) => event.type === "special" && event.kind === "blast"));

  hara.primaryCooldown = 0;
  stepMatch(state, { hara: command({ fire: true }) }, DELTA);
  const ray = state.projectiles.find((projectile) => projectile.abilityId === "ray");
  assert.ok(ray);
  assert.equal(ray.heavy, false);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("SUN GRID telegraphs and resolves three lanes without multi-hitting one target", () => {
  const { state, hara, target } = previewDuel("crosswind");
  hara.x = 300;
  hara.y = 450;
  target.x = 600;
  target.y = 450;
  for (const entity of [hara, target]) {
    entity.lastSafeX = entity.x;
    entity.lastSafeY = entity.y;
  }
  hara.ultimateCharge = hara.maxUltimate;
  const healthBefore = target.health;
  stepMatch(state, { hara: command({ ultimate: true }) }, DELTA);
  assert.ok(state.events.some((event) => event.type === "ultimateTell" && event.kind === "beam-grid"));

  let cast = false;
  for (let tick = 0; tick < MATCH_TUNING.tickRate; tick += 1) {
    stepMatch(state, { hara: command() }, DELTA);
    cast ||= state.events.some((event) => event.type === "ultimateCast");
    if (cast) break;
  }
  assert.equal(cast, true);
  assert.equal(target.health, healthBefore - 42);
  assert.equal(state.elementFields.filter((field) =>
    field.element === "light" && field.shape === "line"
  ).length, 3);
  assert.deepEqual(matchInvariantErrors(state), []);
});

test("preview bots resolve Hara and use the same deterministic command contract", () => {
  const build = () => createMatch({
    contentProfile: OVERHAUL_PREVIEW_PROFILE,
    modeId: "duel",
    mapId: "oathscar_vale",
    characterId: "bulwark",
    botCount: 1,
    botCharacterIds: ["mara"],
    seed: 417,
  });
  const left = build();
  const right = build();
  for (const state of [left, right]) {
    const player = state.entities.find((entity) => entity.human);
    const bot = state.entities.find((entity) => entity.bot);
    const sanctuary = state.overhaul.sanctuaries.find((entry) =>
      entry.ownerSpawnIndex === bot.spawnIndex
    );
    player.x = 1350;
    player.y = sanctuary.y;
    bot.x = sanctuary.x;
    bot.y = sanctuary.y;
    for (const entity of [player, bot]) {
      entity.lastSafeX = entity.x;
      entity.lastSafeY = entity.y;
      entity.spawnProtection = 100;
    }
  }
  stepMatch(left, {}, DELTA);
  stepMatch(right, {}, DELTA);
  const leftBot = left.entities.find((entity) => entity.bot);
  assert.equal(leftBot.characterId, "mara");
  assert.equal(leftBot.botCommand.swap, true);
  assert.equal(leftBot.activePrimaryId, "stone-shot");
  assert.deepEqual(left, right);
  assert.deepEqual(matchInvariantErrors(left), []);
});

test("Hara's preview contract remains finite across every shipped map and mode", () => {
  for (const mode of MODES) {
    for (const map of MAPS) {
      const state = createMatch({
        contentProfile: OVERHAUL_PREVIEW_PROFILE,
        modeId: mode.id,
        mapId: map.id,
        characterId: "mara",
        botCount: Math.min(mode.botCount, 1),
        seed: 811,
      });
      assert.equal(state.overhaul.sanctuaries.length, map.spawns.length);
      for (let tick = 0; tick < MATCH_TUNING.tickRate / 2; tick += 1) {
        const angle = tick * 0.071;
        stepMatch(state, {
          p1: command({
            moveX: Math.cos(angle),
            moveY: Math.sin(angle),
            aimX: Math.cos(angle * 1.3),
            aimY: Math.sin(angle * 1.3),
            fire: tick % 4 === 0,
            special: tick % 37 === 0,
            defend: tick % 43 === 0,
            mobility: tick % 47 === 0,
            swap: tick === 0,
          }),
        }, DELTA);
        assert.deepEqual(
          matchInvariantErrors(state),
          [],
          `${mode.id}/${map.id} tick ${tick}`,
        );
      }
    }
  }
});

test("the optional swap command remains false for existing clients", () => {
  assert.equal(sanitizeCommand({ fire: true }).swap, false);
  assert.equal(sanitizeCommand({ swap: true }).swap, true);
  assert.equal(sanitizeCommand({ swap: 1 }).swap, false);
});
