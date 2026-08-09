import {
  ABILITY_CATALOG,
  CHARACTER_ROSTER,
  validateOverhaulContent,
} from "./overhaul-content.mjs";

const freeze = Object.freeze;

export const OVERHAUL_PREVIEW_PROFILE = "overhaul-preview";

const ray = freeze({
  abilityId: "ray",
  name: "RAY",
  detail: "A narrow Light line with low impact and a clear travel path.",
  damage: 18,
  cooldown: 0.26,
  speed: 1080,
  lifetime: 1.1,
  radius: 4,
  count: 1,
  spread: 0,
  knockback: 25,
});

const stoneShot = freeze({
  abilityId: "stone-shot",
  name: "STONE SHOT",
  detail: "A slower heavy projectile with stronger impact and miss recovery.",
  damage: 30,
  cooldown: 0.48,
  speed: 720,
  lifetime: 1.45,
  radius: 8,
  count: 1,
  spread: 0,
  knockback: 135,
  heavy: true,
});

const gustRing = freeze({
  abilityId: "gust-ring",
  name: "GUST RING",
  detail: "Push nearby enemies away from a small safe center.",
  kind: "blast",
  damage: 8,
  cooldown: 1.8,
  range: 112,
  safeRadius: 28,
  knockback: 310,
  fluxCost: 24,
});

const hara = (() => {
  const tactical = gustRing;
  return freeze({
    id: "mara",
    sourceCharacterId: "mara",
    name: "HARA",
    role: "Light/Wind adaptive planner",
    style: "Swap projectile commitment at a sanctuary, then control the preferred range.",
    color: "#fff4cf",
    accent: "#9be5cc",
    glyph: "◇",
    silhouette: "kite",
    radius: 16.5,
    difficulty: 2,
    health: 92,
    speed: 425,
    acceleration: 2805,
    deceleration: 3400,
    damageInvulnerability: 0.08,
    affinity: freeze({ kind: "element", id: "light", name: "LIGHT", edge: "Readable lines and planned redirection" }),
    homeRaceId: "gnome",
    primary: ray,
    alternatePrimary: stoneShot,
    tactical,
    special: tactical,
    defense: freeze({
      name: "PRISM WARD",
      detail: "A short frontal guard while the chosen projectile is committed.",
      kind: "guard",
      duration: 0.34,
      cooldown: 1.35,
      reduction: 0.62,
      frontalDot: 0,
      fluxCost: 18,
    }),
    mobility: freeze({
      name: "WIND STEP",
      detail: "A brief, readable reposition with no damage.",
      kind: "dash",
      speed: 930,
      duration: 0.14,
      cooldown: 1.15,
      fluxCost: 16,
    }),
    passive: freeze({
      name: "SECOND PLAN",
      detail: "Once per round at a sanctuary, swap Ray and Stone Shot.",
      kind: "sanctuary-swap",
      usesPerRound: 1,
    }),
    ultimate: freeze({
      abilityId: "sun-grid",
      name: "SUN GRID",
      detail: "Telegraph three parallel Light lanes, then resolve each target at most once.",
      kind: "beam-grid",
      chargeRequired: 100,
      chargePerDamage: 0.82,
      windup: 0.72,
      moveScale: 0.42,
      range: 520,
      fieldCount: 3,
      fieldRadius: 10,
      fieldDuration: 0.55,
      laneSpacing: 52,
      damage: 42,
      knockback: 190,
    }),
    availability: "preview-only",
    implementationStatus: "prototype-local",
    implementedAbilityIds: freeze(["ray", "gust-ring", "stone-shot", "sun-grid"]),
    promotionGatesPassed: freeze(["mechanic-prototype", "deterministic-local-tests", "bot-use"]),
  });
})();

export const OVERHAUL_RUNTIME_CHARACTERS = freeze([hara]);

export function getOverhaulRuntimeCharacter(id) {
  return OVERHAUL_RUNTIME_CHARACTERS.find((entry) => entry.id === id) ?? null;
}

export function validateOverhaulRuntime() {
  const errors = [...validateOverhaulContent()];
  const catalogIds = new Set(ABILITY_CATALOG.map((entry) => entry.id));
  const rosterIds = new Set(CHARACTER_ROSTER.map((entry) => entry.id));
  const ids = new Set();
  for (const character of OVERHAUL_RUNTIME_CHARACTERS) {
    if (ids.has(character.id)) errors.push(`duplicate overhaul runtime character ${character.id}`);
    ids.add(character.id);
    if (!rosterIds.has(character.sourceCharacterId)) errors.push(`${character.id} has no future-roster source`);
    if ("lore" in character) errors.push(`${character.id} runtime data must not expose draft lore`);
    if (character.availability !== "preview-only") errors.push(`${character.id} must remain preview-only`);
    if (character.implementationStatus !== "prototype-local") errors.push(`${character.id} must remain a local prototype`);
    if (character.tactical !== character.special) errors.push(`${character.id} must preserve the tactical wire alias`);
    if (character.passive?.kind !== "sanctuary-swap" || character.passive.usesPerRound !== 1) {
      errors.push(`${character.id} needs one bounded sanctuary swap per round`);
    }
    for (const abilityId of character.implementedAbilityIds) {
      if (!catalogIds.has(abilityId)) errors.push(`${character.id} implements unknown ability ${abilityId}`);
    }
    for (const weapon of [character.primary, character.alternatePrimary]) {
      if (!character.implementedAbilityIds.includes(weapon.abilityId)) {
        errors.push(`${character.id}.${weapon.name} is outside its implemented ability set`);
      }
      if (!Number.isFinite(weapon.damage) || weapon.damage <= 0 || !Number.isFinite(weapon.cooldown) || weapon.cooldown <= 0) {
        errors.push(`${character.id}.${weapon.name} must have positive damage and cooldown`);
      }
    }
    if (character.ultimate?.kind !== "beam-grid" || character.ultimate.fieldCount !== 3) {
      errors.push(`${character.id} Sun Grid must use exactly three readable lanes`);
    }
    if (
      !Number.isFinite(character.special.safeRadius) ||
      character.special.safeRadius <= 0 ||
      character.special.safeRadius >= character.special.range
    ) {
      errors.push(`${character.id} Gust Ring must preserve a bounded safe center`);
    }
  }
  return errors;
}
