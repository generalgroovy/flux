import test from "node:test";
import assert from "node:assert/strict";

import {
  ABILITY_CATALOG,
  CHARACTER_ROSTER,
  DESTRUCTION_RULES,
  ELEMENTS,
  FREEPLAY_DEFAULTS,
  MATERIAL_TAGS,
  MODE_LOADOUT_RULES,
  MOVEMENT_GRAMMAR,
  RACE_ARCHETYPES,
  REACTION_RULES,
  SIZE_RULES,
  calculateCharacterBudget,
  canonicalElement,
  effectiveAbilityPoints,
  validateLoadout,
  validateOverhaulContent,
} from "../src/overhaul-content.mjs";

test("overhaul content is internally valid and covers one playable character per race", () => {
  assert.deepEqual(validateOverhaulContent(), []);
  assert.equal(ELEMENTS.length, 8);
  assert.equal(RACE_ARCHETYPES.length, 16);
  assert.equal(CHARACTER_ROSTER.length, 16);
  assert.equal(new Set(CHARACTER_ROSTER.map((entry) => entry.raceId)).size, 16);
  assert.ok(ABILITY_CATALOG.length >= 48);
});

test("legacy element names resolve to the simplified eight-family vocabulary", () => {
  assert.equal(canonicalElement("stone"), "earth");
  assert.equal(canonicalElement("nature"), "earth");
  assert.equal(canonicalElement("ember"), "fire");
  assert.equal(canonicalElement("tide"), "water");
  assert.equal(canonicalElement("gale"), "wind");
  assert.equal(canonicalElement("frost"), "ice");
  assert.equal(canonicalElement("volt"), "charge");
  assert.equal(canonicalElement("prism"), "light");
  assert.equal(canonicalElement("null"), "dark");
  assert.equal(canonicalElement("veil"), "dark");
});

test("race size ranges and modifiers remain bounded", () => {
  for (const race of RACE_ARCHETYPES) {
    assert.ok(race.sizes.length > 0);
    assert.ok(race.sizes.every((size) => SIZE_RULES[size]));
    assert.ok(race.affinities.length > 0);
    assert.ok(race.affinities.every((entry) => entry.strength >= 1 && entry.strength <= 3));
    for (const [key, value] of Object.entries(race.modifiers)) {
      assert.ok(value >= 0.8 && value <= 1.1, `${race.id}.${key}`);
    }
  }
});

test("size changes body tradeoffs without directly scaling spell damage", () => {
  assert.ok(SIZE_RULES[1].speed > SIZE_RULES[5].speed);
  assert.ok(SIZE_RULES[1].radius < SIZE_RULES[5].radius);
  assert.ok(SIZE_RULES[1].health < SIZE_RULES[5].health);
  assert.ok(SIZE_RULES[1].knockback > SIZE_RULES[5].knockback);
  for (const rule of Object.values(SIZE_RULES)) assert.equal("damage" in rule, false);
});

test("every character stays inside the validated power budget", () => {
  for (const character of CHARACTER_ROSTER) {
    const budget = calculateCharacterBudget(character);
    assert.ok(Number.isFinite(budget));
    assert.ok(budget <= 100, `${character.name}: ${budget}`);
    assert.ok(character.affinities.length >= 1 && character.affinities.length <= 5);
    assert.equal(character.activeAbilityIds.length, 3);
  }
});

test("signature loadouts are universal catalog entries and fit standard duel budgets", () => {
  for (const character of CHARACTER_ROSTER) {
    const errors = validateLoadout({
      characterId: character.id,
      modeId: "duel",
      activeAbilityIds: character.activeAbilityIds,
      ultimateAbilityId: character.ultimateAbilityId,
    });
    assert.deepEqual(errors, [], `${character.name}: ${errors.join(", ")}`);
    const activeCost = character.activeAbilityIds
      .map((id) => ABILITY_CATALOG.find((entry) => entry.id === id))
      .reduce((sum, entry) => sum + effectiveAbilityPoints(character, entry), 0);
    assert.ok(activeCost <= 13);
  }
});

test("invalid loadouts reject duplicate skills, disallowed elements, and overspending", () => {
  assert.ok(validateLoadout({
    characterId: "mara",
    modeId: "duel",
    activeAbilityIds: ["ray", "ray", "ray"],
    ultimateAbilityId: "sun-grid",
  }).includes("active abilities must be unique"));
  assert.ok(validateLoadout({
    characterId: "mara",
    modeId: "movement",
    activeAbilityIds: ["fire-fan", "spark-keg", "campfire-feint"],
    ultimateAbilityId: "sun-grid",
  }).some((error) => error.includes("element is not allowed")));
  assert.ok(validateLoadout({
    characterId: "mara",
    modeId: "movement",
    activeAbilityIds: ["root-rampart", "mirror-bulwark", "stone-break"],
    ultimateAbilityId: "earthwake",
  }).some((error) => error.includes("skill point budget exceeded") || error === "ultimates are disabled"));
});

test("reaction processing contracts are deterministic and bounded", () => {
  assert.deepEqual([...REACTION_RULES].map((entry) => entry.priority), [...REACTION_RULES].map((entry) => entry.priority).sort((a, b) => a - b));
  assert.equal(new Set(REACTION_RULES.map((entry) => entry.id)).size, REACTION_RULES.length);
  assert.ok(REACTION_RULES.every((entry) => entry.inputs.length === 2));
  assert.ok(REACTION_RULES.every((entry) => entry.duration >= 0 && entry.cue && entry.counterplay));
});

test("movement grammar is expressive but explicitly bounded", () => {
  const actions = MOVEMENT_GRAMMAR.actions;
  for (const name of ["sprint", "jump", "doubleJump", "slide", "slideJump", "airDodge", "wavedash", "wallJump", "redirect", "vault", "superglide"]) {
    assert.ok(actions[name], name);
  }
  assert.ok(MOVEMENT_GRAMMAR.limits.maximumSpeed > 0);
  assert.ok(MOVEMENT_GRAMMAR.limits.collisionSubsteps >= 8);
  assert.ok(actions.airDodge.flowCost > actions.jump.flowCost);
  assert.ok(actions.wallJump.lockout > 0);
  assert.ok(actions.superglide.window <= 0.1);
});

test("freeplay modifiers default to competitive-safe values", () => {
  assert.equal(FREEPLAY_DEFAULTS.godMode, false);
  assert.equal(FREEPLAY_DEFAULTS.endlessFlux, false);
  assert.equal(FREEPLAY_DEFAULTS.instantCooldowns, false);
  assert.equal(FREEPLAY_DEFAULTS.damageMultiplier, 1);
  assert.equal(FREEPLAY_DEFAULTS.timeScale, 1);
  assert.equal(FREEPLAY_DEFAULTS.reactions, true);
  assert.ok(MODE_LOADOUT_RULES.some((mode) => mode.id === "freeplay"));
  assert.ok(MODE_LOADOUT_RULES.some((mode) => mode.id === "battle_royale"));
});

test("destruction model is authored, layered, and work-bounded", () => {
  assert.ok(DESTRUCTION_RULES.gridSize >= 16);
  assert.ok(DESTRUCTION_RULES.maxActiveRegions <= 128);
  assert.ok(DESTRUCTION_RULES.maxReactionsPerTick <= 128);
  assert.deepEqual(DESTRUCTION_RULES.levels, ["lower", "ground", "upper", "roof"]);
  for (const material of Object.values(DESTRUCTION_RULES.materials)) {
    assert.ok(material.health > material.fracture);
    assert.ok(material.tags.every((tag) => MATERIAL_TAGS.includes(tag)));
  }
});
