import {
  CHARACTERS as LEGACY_CHARACTERS,
  MAPS as LEGACY_MAPS,
  MODES as LEGACY_MODES,
  RACES as LEGACY_RACES,
  MATCH_TUNING as LEGACY_TUNING,
  validateContent as validateLegacyContent,
} from "./content.mjs";
import {
  ABILITY_CATALOG,
  CHARACTER_ROSTER,
  DESTRUCTION_RULES,
  ELEMENTS,
  FREEPLAY_DEFAULTS,
  MODE_LOADOUT_RULES,
  RACE_ARCHETYPES,
  SIZE_RULES,
  canonicalElement,
  effectiveAbilityPoints,
  getRaceArchetype,
  validateLoadout,
  validateOverhaulContent,
} from "./overhaul-content.mjs";

const freeze = (value) => Object.freeze(value);
const abilityById = new Map(ABILITY_CATALOG.map((entry) => [entry.id, entry]));
const elementById = new Map(ELEMENTS.map((entry) => [entry.id, entry]));

const ELEMENT_COLORS = freeze({
  earth: ["#d7c58a", "#7f6a3d"],
  fire: ["#ffd0a0", "#d34d2c"],
  water: ["#bcecff", "#397fba"],
  wind: ["#e7fff4", "#66c9a5"],
  ice: ["#e8fbff", "#75b8d4"],
  charge: ["#fff4a8", "#c89c28"],
  light: ["#fffbd7", "#e0b95c"],
  dark: ["#d7c9f4", "#72598f"],
});

const LEGACY_ELEMENT_IDS = freeze({
  earth: "earth",
  fire: "fire",
  water: "water",
  wind: "wind",
  ice: "ice",
  charge: "lightning",
  light: "prism",
  dark: "veil",
});

const ACTIVE_SLOT_LABELS = freeze(["special", "defense", "mobility"]);

function titleCase(value) {
  return String(value ?? "")
    .replace(/[-_]+/g, " ")
    .replace(/\b\w/g, (letter) => letter.toUpperCase());
}

function bounded(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function raceBoon(modifiers) {
  const entries = Object.entries(modifiers)
    .filter(([key, value]) => key !== "knockback" && value > 1.005)
    .map(([key, value]) => `+${Math.round((value - 1) * 100)}% ${key.toUpperCase()}`);
  if ((modifiers.knockback ?? 1) < 0.995) {
    entries.push(`−${Math.round((1 - modifiers.knockback) * 100)}% forced movement`);
  }
  return entries.join(" / ") || "Flexible";
}

function raceDrawback(modifiers) {
  const entries = Object.entries(modifiers)
    .filter(([key, value]) => key !== "knockback" && value < 0.995)
    .map(([key, value]) => `−${Math.round((1 - value) * 100)}% ${key.toUpperCase()}`);
  if ((modifiers.knockback ?? 1) > 1.005) {
    entries.push(`+${Math.round((modifiers.knockback - 1) * 100)}% forced movement`);
  }
  return entries.join(" / ") || "No extreme edge";
}

const OVERHAUL_RACES = RACE_ARCHETYPES.map((entry) => freeze({
  id: entry.id,
  name: entry.name,
  trait: entry.trait.name,
  traitId: entry.trait.id,
  traitRule: entry.trait.rule,
  feature: entry.feature,
  featureGlyph: entry.glyph,
  boon: raceBoon(entry.modifiers),
  drawback: raceDrawback(entry.modifiers),
  health: entry.modifiers.health,
  speed: entry.modifiers.speed,
  flux: entry.modifiers.flux,
  flow: entry.modifiers.flow,
  knockback: entry.modifiers.knockback,
  sizes: entry.sizes,
  affinities: entry.affinities,
}));

const canonicalRaceIds = new Set(OVERHAUL_RACES.map((entry) => entry.id));
const legacyRaceAliases = LEGACY_RACES.filter((entry) => !canonicalRaceIds.has(entry.id));

export const RACES = freeze([...OVERHAUL_RACES, ...legacyRaceAliases]);

function getAbility(id) {
  return abilityById.get(id) ?? null;
}

function getRosterCharacter(id) {
  return CHARACTER_ROSTER.find((entry) => entry.id === id) ?? null;
}

function runtimeFluxCost(characterEntry, ability) {
  if (!ability) return 0;
  const affinity = characterEntry?.affinities.find((entry) => entry.id === ability.element)?.strength ?? 0;
  const signature = characterEntry?.activeAbilityIds.includes(ability.id) ? 0.86 : 1;
  const affinityScale = 1 - Math.min(0.18, affinity * 0.06);
  return Math.max(8, Math.round(ability.fluxCost * signature * affinityScale));
}

function withRuntimeCost(characterEntry, ability) {
  return ability ? { ...ability, fluxCost: runtimeFluxCost(characterEntry, ability) } : ability;
}

function selectSlots(rosterEntry, requestedIds = rosterEntry.activeAbilityIds) {
  const abilities = requestedIds.map(getAbility).filter((entry) => entry?.type === "active");
  const mobility = abilities.find((entry) => entry.roles.includes("mobility")) ?? abilities[2];
  const defense = abilities.find(
    (entry) => entry !== mobility &&
      (entry.roles.includes("defense") || entry.roles.includes("support") || entry.roles.includes("construct")),
  ) ?? abilities.find((entry) => entry !== mobility) ?? abilities[1];
  const special = abilities.find((entry) => entry !== mobility && entry !== defense) ?? abilities[0];
  return {
    special: withRuntimeCost(rosterEntry, special),
    defense: withRuntimeCost(rosterEntry, defense),
    mobility: withRuntimeCost(rosterEntry, mobility),
  };
}

function runtimeAbilityMetadata(ability) {
  return ability ? {
    abilityId: ability.id,
    catalogKind: ability.kind,
    tier: ability.tier ?? 1,
    points: ability.points ?? 0,
    startup: ability.startup ?? 0,
    recovery: ability.recovery ?? 0,
    roles: [...(ability.roles ?? [])],
    tags: [...(ability.tags ?? [])],
    counterplay: [...(ability.counterplay ?? [])],
  } : {
    abilityId: null,
    catalogKind: null,
    tier: 1,
    points: 0,
    startup: 0,
    recovery: 0,
    roles: [],
    tags: [],
    counterplay: [],
  };
}

function specialKind(ability) {
  if (!ability) return "blast";
  const exact = {
    wall: "wall",
    "convert-field": "convert-field",
    orbit: "orbit",
    chain: "chain",
    "delayed-bursts": "delayed-bursts",
    "refract-line": "tripwire",
    "charged-construct": "charged-construct",
    "reactive-seed": "reactive-seed",
    "turn-mine": "turn-mine",
    "jump-pad": "jump-pad",
  }[ability.kind];
  if (exact) return exact;
  if (["mine", "multi-construct", "gadget-ring"].includes(ability.kind)) return "mine";
  if (["beam", "projectile", "beam-grid"].includes(ability.kind)) return "rail";
  if (["pull-field", "construct-decay", "decoy-swap", "blink-decoy"].includes(ability.kind)) return "pull";
  if (["support-field", "support-basin", "support-growth"].includes(ability.kind)) return "heal";
  if (["dash-trail", "moving-field", "route-dash", "storm-front"].includes(ability.kind)) return "trail";
  if (["fan", "wide-cone", "short-cone", "shockwave", "wave", "ring", "landing-fan", "heavy-charge", "collapse-line", "growth-wave"].includes(ability.kind)) return "cone";
  return "blast";
}

function adaptSpecial(ability) {
  const element = canonicalElement(ability?.element) ?? "earth";
  const kind = specialKind(ability);
  const metadata = runtimeAbilityMetadata(ability);
  const base = {
    ...metadata,
    name: ability?.name ?? "SPELL",
    detail: ability ? `${titleCase(ability.kind)} · ${ability.points} SP` : "Elemental spell.",
    element,
    kind,
    fluxCost: bounded(ability?.fluxCost ?? 30, 10, 55),
    cooldown: bounded(ability?.cooldown ?? 1.5, 0.45, 6),
    damage: 22 + (ability?.tier ?? 1) * 8,
    knockback: 130 + (ability?.tier ?? 1) * 55,
    range: 130 + (ability?.tier ?? 1) * 40,
  };
  if (kind === "cone") return { ...base, halfAngle: 0.72 };
  if (kind === "rail") return { ...base, width: 7, range: 720, damage: 25 + (ability?.tier ?? 1) * 9 };
  if (["mine", "turn-mine", "reactive-seed", "charged-construct", "jump-pad", "tripwire"].includes(kind)) {
    return {
      ...base,
      armTime: kind === "delayed-bursts" ? 0.7 : 0.45,
      duration: kind === "tripwire" ? 7 : 6,
      triggerRadius: kind === "tripwire" ? 54 : 72,
      blastRadius: kind === "charged-construct" ? 132 : 118,
      damage: 30 + (ability?.tier ?? 1) * 8,
    };
  }
  if (kind === "delayed-bursts") return { ...base, count: 3, spacing: 92, armTime: 0.72, duration: 3.2, triggerRadius: 46, blastRadius: 82 };
  if (kind === "chain") return { ...base, width: 6, range: 620, chainRange: 180, chainCount: 3, damage: 29 };
  if (kind === "wall") return { ...base, range: 125, length: 175, thickness: 28, duration: 4.2, damage: 0, knockback: 0 };
  if (kind === "convert-field") return { ...base, range: 240, radius: 135, duration: 4, damage: 0, knockback: 0 };
  if (kind === "orbit") return { ...base, range: 95, radius: 94, duration: 1.6, damage: 18, knockback: 220 };
  if (kind === "trail") return { ...base, range: 280, fieldCount: 5, fieldRadius: 48, fieldDuration: 2.8 };
  if (kind === "pull") return { ...base, range: 175, pull: 275, damage: 18 };
  if (kind === "heal") return { ...base, amount: 34, range: 130, damage: 0, knockback: 0 };
  return { ...base, range: 145, damage: 26, knockback: 180 };
}

function adaptDefense(ability, characterEntry) {
  const element = canonicalElement(ability?.element) ?? characterEntry.affinities[0].id;
  const defensive = ability?.roles.includes("defense");
  const kind = defensive
    ? element === "dark" ? "phase"
      : element === "light" || element === "wind" ? "reflect"
        : element === "water" ? "absorb"
          : element === "charge" ? "counter"
            : "guard"
    : element === "dark" ? "phase" : "guard";
  return {
    ...runtimeAbilityMetadata(ability),
    name: ability?.name ?? "GUARD",
    detail: defensive ? `${titleCase(ability.kind)} defense.` : "Commit this spell as a defensive read.",
    element,
    kind,
    fluxCost: bounded(ability?.fluxCost ?? 28, 12, 48),
    duration: kind === "phase" ? 0.22 : kind === "reflect" ? 0.2 : 0.28,
    cooldown: bounded((ability?.cooldown ?? 2.2) * 0.72, 0.9, 4.5),
    radius: ability?.kind === "orbit" ? 58 : 42,
    reduction: 0.58,
    frontalDot: 0.12,
    returnDamage: 12,
    amount: 24,
  };
}

function adaptMobility(ability, characterEntry) {
  const element = canonicalElement(ability?.element) ?? characterEntry.affinities[0].id;
  const kind = element === "dark" || ability?.kind.includes("blink")
    ? "blink"
    : ability?.kind.includes("recoil") || element === "water"
      ? "recoil"
      : ability?.kind.includes("charge") || element === "earth" || element === "fire"
        ? "charge"
        : "dash";
  return {
    ...runtimeAbilityMetadata(ability),
    name: ability?.name ?? "STEP",
    detail: ability?.roles.includes("mobility") ? `${titleCase(ability.kind)} movement.` : "Convert this spell into a committed movement route.",
    element,
    kind,
    fluxCost: bounded(ability?.fluxCost ?? 26, 10, 44),
    speed: kind === "charge" ? 890 : 1040,
    duration: 0.16,
    distance: 185,
    cooldown: bounded((ability?.cooldown ?? 2.4) * 0.65, 0.85, 3.8),
    damage: kind === "charge" ? 24 : 0,
    knockback: kind === "charge" ? 190 : 0,
  };
}

function adaptUltimate(ability, characterEntry) {
  const element = canonicalElement(ability?.element) ?? characterEntry.affinities[0].id;
  const catalogKind = ability?.kind;
  const supportedKinds = new Set([
    "beam-grid", "armor-structure", "gadget-ring", "route-dash", "orbit-lens",
    "storm-front", "growth-wave", "maze", "basin", "grapple-web", "collapse-line",
    "living-structure", "formation", "multi-construct", "support-growth",
  ]);
  const kind = supportedKinds.has(catalogKind)
    ? catalogKind
    : ["wind", "dark", "light"].includes(element)
      ? "wind-vortex"
      : ["ice", "charge"].includes(element)
        ? "line-volley"
        : "field-crown";
  const base = {
    ...runtimeAbilityMetadata(ability),
    name: ability?.name ?? "ULTIMATE",
    detail: ability ? `${titleCase(ability.kind)} ultimate.` : "Signature ultimate.",
    element,
    kind,
    chargeRequired: 100,
    chargePerDamage: 0.82,
    windup: bounded(ability?.startup ?? 0.75, 0.45, 0.95),
    moveScale: 0.42,
    fieldCount: ["field-crown", "maze", "living-structure", "formation"].includes(kind) ? 7 : 5,
    fieldRadius: kind === "wind-vortex" || kind === "orbit-lens" || kind === "grapple-web" ? 168 : 58,
    fieldDuration: 3.4,
    targetRange: 330,
    crownRadius: 118,
    spin: 1,
    range: 780,
    damage: 31,
    cooldown: 0.13,
    speed: 980,
    lifetime: 1,
    radius: 7,
    count: 5,
    spread: 0.2,
    knockback: 100,
    pierce: 1,
  };
  return base;
}

function adaptPassive(passive, characterEntry) {
  const first = characterEntry.affinities[0]?.id;
  const movementNames = new Set(["SMALL TARGET, BIG EXIT", "STORMWEIGHT", "RIME DIVE", "THIN AIR"]);
  if (movementNames.has(passive.name)) {
    return { ...passive, detail: passive.rule, kind: "movement-prime", duration: 1.3, speedMultiplier: 1.12, spreadMultiplier: 0.82 };
  }
  if (passive.name === "THREAD THE TURN") {
    return { ...passive, detail: passive.rule, kind: "reflect-guide", duration: 1.4, guideDuration: 0.58, turnRate: 3.4, speedMultiplier: 0.92 };
  }
  if (["COLD ASHES", "DEEP ROOTS", "QUESTIONABLE ENGINEERING"].includes(passive.name) || first === "fire") {
    return { ...passive, detail: passive.rule, kind: "field-temper", speedMultiplier: 0.86, radiusMultiplier: 1.18, knockbackMultiplier: 1.2 };
  }
  return { ...passive, detail: passive.rule, kind: "utility" };
}

function adaptCharacter(entry, index) {
  const race = getRaceArchetype(entry.raceId);
  const size = SIZE_RULES[entry.size];
  const slots = selectSlots(entry);
  const element = entry.affinities[0].id;
  const [color, accent] = ELEMENT_COLORS[element] ?? ELEMENT_COLORS.earth;
  const healthBonus = Number(entry.statBonuses.health ?? 0);
  const speedBonus = Number(entry.statBonuses.speed ?? 0);
  const baseHealth = 112 + healthBonus * 3;
  const baseSpeed = 392 + speedBonus * 7;
  const radius = bounded(17 * size.radius, 12.5, 22.5);
  const primaryElement = elementById.get(element);
  return freeze({
    id: entry.id,
    name: entry.name,
    role: entry.identity,
    style: `${race.name} · Size ${entry.size} · ${entry.affinities.map((affinity) => `${titleCase(affinity.id)} ${affinity.strength}`).join(" / ")}`,
    color,
    accent,
    glyph: primaryElement?.glyph ?? "◇",
    silhouette: `overhaul-${entry.raceId}-${entry.size}-${index}`,
    difficulty: bounded(entry.affinities.length, 1, 3),
    radius,
    size: entry.size,
    health: Math.round(baseHealth * size.health),
    speed: Math.round(baseSpeed * size.speed),
    acceleration: Math.round(baseSpeed * size.speed * 6.4 * size.acceleration),
    deceleration: Math.round(baseSpeed * size.speed * 7.8),
    damageInvulnerability: 0.08,
    passive: adaptPassive(entry.passive, entry),
    primary: {
      name: `${titleCase(element)} Bolt`,
      detail: "Reliable zero-Flux attack.",
      element,
      fluxCost: 0,
      damage: 20 + entry.size,
      cooldown: bounded(0.22 + entry.size * 0.018, 0.2, 0.32),
      speed: 1000 - entry.size * 24,
      lifetime: 1.25,
      radius: bounded(4.8 + entry.size * 0.65, 5, 8),
      count: 1,
      spread: 0,
      knockback: 45 + entry.size * 16,
      pierce: 0,
    },
    tactical: adaptSpecial(slots.special),
    special: adaptSpecial(slots.special),
    defense: adaptDefense(slots.defense, entry),
    mobility: adaptMobility(slots.mobility, entry),
    ultimate: adaptUltimate(getAbility(entry.ultimateAbilityId), entry),
    affinity: {
      kind: "element",
      id: LEGACY_ELEMENT_IDS[element] ?? element,
      canonicalId: element,
      name: titleCase(element).toUpperCase(),
      edge: elementById.get(element)?.identity ?? "elemental control",
    },
    affinities: entry.affinities,
    activeAbilityIds: entry.activeAbilityIds,
    ultimateAbilityId: entry.ultimateAbilityId,
    homeRaceId: entry.raceId,
  });
}

export const OVERHAUL_CHARACTERS = freeze(CHARACTER_ROSTER.map(adaptCharacter));
export const CHARACTERS = freeze([...LEGACY_CHARACTERS, ...OVERHAUL_CHARACTERS]);

const SANCTUM = freeze({
  id: "sanctum",
  regionId: "home",
  region: "Home",
  scale: "large",
  atlas: { x: 50, y: 50 },
  name: "SANCTUM",
  terrain: "Garden court, spell range, movement ring, and lobby gates",
  identity: "A calm playable home where every game system can be tested or configured.",
  lore: "The Sanctum is a lived-in arena rather than a blocking menu. Its courts, gardens, gates, and workshops expose only the controls relevant to the place the player is standing.",
  heraldry: "FLUX",
  visual: { floor: "#9dbb82", void: "#24352d", grid: "#78966d", accent: "#f2d889" },
  size: { width: 2200, height: 1400, inset: 42 },
  spawns: [
    { x: 1100, y: 700 }, { x: 1020, y: 700 }, { x: 1180, y: 700 },
    { x: 1100, y: 620 }, { x: 1100, y: 780 }, { x: 320, y: 280 },
    { x: 1880, y: 280 }, { x: 1880, y: 1120 }, { x: 320, y: 1120 },
  ],
  obstacles: [
    { x: 1010, y: 210, width: 180, height: 46 },
    { x: 1010, y: 1144, width: 180, height: 46 },
    { x: 280, y: 610, width: 46, height: 180 },
    { x: 1874, y: 610, width: 46, height: 180 },
    { x: 585, y: 410, width: 110, height: 40 },
    { x: 1505, y: 410, width: 110, height: 40 },
    { x: 585, y: 950, width: 110, height: 40 },
    { x: 1505, y: 950, width: 110, height: 40 },
  ],
  hazards: [],
  shrines: [
    { id: "west-flow", x: 430, y: 700, radius: 65, speedRequired: 280, fluxReward: 35, cooldown: 3.5 },
    { id: "east-flow", x: 1770, y: 700, radius: 65, speedRequired: 280, fluxReward: 35, cooldown: 3.5 },
  ],
  landmarks: [
    { type: "court", x: 790, y: 470, width: 620, height: 460, label: "COURT" },
    { type: "rune", x: 1100, y: 700, radius: 90, label: "HOME" },
    { type: "rune", x: 340, y: 250, radius: 74, label: "MOVE" },
    { type: "rune", x: 1860, y: 250, radius: 74, label: "SPELLS" },
    { type: "rune", x: 1860, y: 1150, radius: 74, label: "HOST" },
    { type: "rune", x: 340, y: 1150, radius: 74, label: "BUILD" },
    { type: "water", x: 830, y: 1040, width: 540, height: 150, label: "POND" },
  ],
  stations: [
    { id: "play", kind: "play", x: 1100, y: 700, radius: 95, label: "PLAY" },
    { id: "movement", kind: "movement", x: 340, y: 250, radius: 90, label: "MOVE" },
    { id: "spells", kind: "loadout", x: 1860, y: 250, radius: 90, label: "SPELLS" },
    { id: "online", kind: "online", x: 1860, y: 1150, radius: 90, label: "HOST" },
    { id: "settings", kind: "settings", x: 340, y: 1150, radius: 90, label: "SETTINGS" },
  ],
  destructibles: [
    { id: "yard-wall-a", x: 600, y: 1080, width: 90, height: 26, material: "wood", level: "ground", health: 60 },
    { id: "yard-wall-b", x: 710, y: 1080, width: 90, height: 26, material: "glass", level: "ground", health: 35 },
    { id: "yard-pillar", x: 810, y: 1060, width: 35, height: 70, material: "stone", level: "ground", health: 130 },
  ],
  objective: { x: 1100, y: 700, radius: 95 },
  wildmarch: { routes: [
    { id: "north-gate", name: "NORTH", x: 1100, y: 300, radius: 58 },
    { id: "south-gate", name: "SOUTH", x: 1100, y: 1100, radius: 58 },
  ] },
});

const RIFT = freeze({
  ...SANCTUM,
  id: "rift",
  regionId: "rift",
  region: "Rift",
  name: "RIFT",
  terrain: "Four-region destructible battleground",
  identity: "A broad last-team-standing map with layered routes and a closing storm.",
  lore: "Four old districts meet around a fractured central keep. Bridges, doors, glass halls, and root-grown repairs create new paths as the safe region contracts.",
  heraldry: "LAST LIGHT",
  visual: { floor: "#546b55", void: "#151c20", grid: "#405246", accent: "#e5c66f" },
  size: { width: 2600, height: 1800, inset: 55 },
  spawns: [
    { x: 220, y: 220 }, { x: 2380, y: 220 }, { x: 2380, y: 1580 }, { x: 220, y: 1580 },
    { x: 1300, y: 170 }, { x: 2430, y: 900 }, { x: 1300, y: 1630 }, { x: 170, y: 900 },
    { x: 650, y: 450 }, { x: 1950, y: 450 }, { x: 1950, y: 1350 }, { x: 650, y: 1350 },
  ],
  obstacles: [
    { x: 1080, y: 650, width: 440, height: 55 }, { x: 1080, y: 1095, width: 440, height: 55 },
    { x: 1025, y: 705, width: 55, height: 390 }, { x: 1520, y: 705, width: 55, height: 390 },
    { x: 460, y: 360, width: 260, height: 55 }, { x: 1880, y: 360, width: 260, height: 55 },
    { x: 460, y: 1385, width: 260, height: 55 }, { x: 1880, y: 1385, width: 260, height: 55 },
  ],
  stations: [],
  shrines: [],
  landmarks: [
    { type: "court", x: 1025, y: 650, width: 550, height: 500, label: "KEEP" },
    { type: "rune", x: 1300, y: 900, radius: 120, label: "RIFT" },
    { type: "water", x: 100, y: 760, width: 440, height: 280, label: "LOW WATER" },
  ],
  destructibles: [
    { id: "north-bridge", x: 1180, y: 570, width: 240, height: 34, material: "wood", level: "upper", health: 90 },
    { id: "south-bridge", x: 1180, y: 1196, width: 240, height: 34, material: "wood", level: "upper", health: 90 },
    { id: "west-glass", x: 940, y: 800, width: 34, height: 200, material: "glass", level: "ground", health: 45 },
    { id: "east-glass", x: 1626, y: 800, width: 34, height: 200, material: "glass", level: "ground", health: 45 },
  ],
  objective: { x: 1300, y: 900, radius: 130 },
  wildmarch: { routes: [
    { id: "west", name: "WEST", x: 540, y: 900, radius: 64 },
    { id: "east", name: "EAST", x: 2060, y: 900, radius: 64 },
  ] },
});

export const MAPS = freeze([...LEGACY_MAPS, SANCTUM, RIFT]);

const EXTRA_MODES = freeze([
  freeze({ id: "freeplay", name: "FREEPLAY", category: "Home", description: "Practice, configure, host, join, and launch matches from the playable Sanctum.", scoreLimit: Number.POSITIVE_INFINITY, timeLimit: Number.POSITIVE_INFINITY, botCount: 0, allowLocal: true, freeplay: true }),
  freeze({ id: "team", name: "TEAM", category: "PvP", description: "Team elimination with clean respawns.", scoreLimit: 60, timeLimit: 240, botCount: 3, allowLocal: true }),
  freeze({ id: "movement", name: "MOVEMENT", category: "Trial", description: "Race through authored movement gates.", scoreLimit: 1, timeLimit: 180, botCount: 0, allowLocal: true }),
  freeze({ id: "draft", name: "DRAFT", category: "PvP", description: "Build a spell set under a shared skill-point budget.", scoreLimit: 60, timeLimit: 240, botCount: 2, allowLocal: true }),
  freeze({ id: "mirror", name: "MIRROR", category: "PvP", description: "All players use the same loadout.", scoreLimit: 60, timeLimit: 240, botCount: 2, allowLocal: true }),
  freeze({ id: "siege", name: "SIEGE", category: "Objective", description: "Break or repair bounded structures while holding routes.", scoreLimit: 120, timeLimit: 300, botCount: 4, allowLocal: true }),
  freeze({ id: "extraction", name: "EXTRACT", category: "PvPvE", description: "Carry earned Flux to an exit before rivals intercept it.", scoreLimit: 1, timeLimit: 360, botCount: 4, neutralCount: 2, allowLocal: true }),
  freeze({ id: "battle_royale", name: "BATTLE ROYALE", category: "Last team", description: "Solo, duo, or trio survival on the closing Rift.", scoreLimit: 1, timeLimit: 720, botCount: 7, allowLocal: true, noRespawn: true, closingZone: true }),
]);

export const MODES = freeze([...LEGACY_MODES, ...EXTRA_MODES]);

export const MATCH_TUNING = freeze({
  ...LEGACY_TUNING,
  flux: freeze({
    ...LEGACY_TUNING.flux,
    maximum: 180,
    recoveryPerSecond: 28,
    recoveryDelay: 0.85,
  }),
  freeplay: freeze({ ...FREEPLAY_DEFAULTS }),
  destruction: DESTRUCTION_RULES,
  elements: freeze({
    ...LEGACY_TUNING.elements,
    chargeDuration: 2.2,
    chargeRadius: 112,
    chargePulse: 0.55,
    chargeDamage: 4,
    lightDuration: 2.6,
    lightRadius: 128,
    lightRevealDuration: 0.7,
    darkDuration: 2.8,
    darkRadius: 126,
    darkPull: 82,
    mudDuration: 3.1,
    mudRadius: 105,
    mudSpeed: 0.72,
    shadowEdgeDuration: 1.5,
    shadowEdgeRadius: 88,
  }),
  movement: freeze({
    airborneWindow: 0.62,
    doubleJumpCost: 32,
    doubleJumpSpeed: 710,
    airSteering: 0.1,
    airDodgeCost: 30,
    airDodgeSpeed: 880,
    airDodgeDuration: 0.16,
    airDodgeCooldown: 0.78,
    wavedashSpeed: 760,
    wavedashDuration: 0.2,
    vaultMemory: 0.18,
    superglideCost: 34,
    superglideSpeed: 900,
    superglideDuration: 0.2,
    superglideCooldown: 1.05,
  }),
  battleRoyale: freeze({ startRadius: 1220, endRadius: 180, delay: 35, duration: 420, damagePerSecond: 10 }),
});

export function buildCharacterKit({ characterId, modeId = "freeplay", activeAbilityIds, ultimateAbilityId } = {}) {
  const characterEntry = getRosterCharacter(characterId);
  const base = CHARACTERS.find((entry) => entry.id === characterId) ?? CHARACTERS[0];
  if (!characterEntry) {
    return freeze({
      activeAbilityIds: [...(base.activeAbilityIds ?? [])],
      ultimateAbilityId: base.ultimateAbilityId ?? null,
      special: base.special,
      defense: base.defense,
      mobility: base.mobility,
      ultimate: base.ultimate,
      skillPoints: 0,
      errors: freeze([]),
    });
  }
  const requestedActives = Array.isArray(activeAbilityIds) && activeAbilityIds.length === 3
    ? [...activeAbilityIds]
    : [...characterEntry.activeAbilityIds];
  const requestedUltimate = ultimateAbilityId ?? characterEntry.ultimateAbilityId;
  const errors = validateLoadout({
    characterId,
    modeId,
    activeAbilityIds: requestedActives,
    ultimateAbilityId: requestedUltimate,
  });
  const safeActives = errors.length === 0 ? requestedActives : [...characterEntry.activeAbilityIds];
  const safeUltimateId = errors.length === 0 ? requestedUltimate : characterEntry.ultimateAbilityId;
  const slots = selectSlots(characterEntry, safeActives);
  const ultimateDefinition = getAbility(safeUltimateId);
  const skillPoints = safeActives.reduce(
    (sum, id) => sum + effectiveAbilityPoints(characterEntry, getAbility(id)),
    0,
  );
  return freeze({
    activeAbilityIds: freeze(safeActives),
    ultimateAbilityId: safeUltimateId,
    special: freeze(adaptSpecial(slots.special)),
    defense: freeze(adaptDefense(slots.defense, characterEntry)),
    mobility: freeze(adaptMobility(slots.mobility, characterEntry)),
    ultimate: freeze(adaptUltimate(ultimateDefinition, characterEntry)),
    skillPoints,
    errors: freeze([...errors]),
  });
}

export function getCharacter(id) {
  return CHARACTERS.find((entry) => entry.id === id) ?? CHARACTERS[0];
}

export function getRace(id) {
  return RACES.find((entry) => entry.id === id) ?? RACES[0];
}

export function getMap(id) {
  return MAPS.find((entry) => entry.id === id) ?? (id === "freeplay" ? SANCTUM : MAPS[0]);
}

export function getMode(id) {
  return MODES.find((entry) => entry.id === id) ?? MODES.find((entry) => entry.id === "freeplay") ?? MODES[0];
}

export function getAbilityDefinition(id) {
  return getAbility(id);
}

export function getLoadoutRule(id) {
  return MODE_LOADOUT_RULES.find((entry) => entry.id === id) ?? MODE_LOADOUT_RULES[0];
}

export { ELEMENTS, ABILITY_CATALOG, CHARACTER_ROSTER, FREEPLAY_DEFAULTS, MODE_LOADOUT_RULES, SIZE_RULES, DESTRUCTION_RULES, canonicalElement, validateLoadout };

export function validateLiveContent() {
  const errors = [...validateLegacyContent(), ...validateOverhaulContent()];
  const unique = (items, label) => {
    const ids = items.map((entry) => entry.id);
    if (new Set(ids).size !== ids.length) errors.push(`${label} ids must be unique`);
  };
  unique(CHARACTERS, "live character");
  unique(RACES, "live race");
  unique(MAPS, "live map");
  unique(MODES, "live mode");
  for (const character of OVERHAUL_CHARACTERS) {
    if (!RACES.some((race) => race.id === character.homeRaceId)) errors.push(`${character.id} has unknown live race`);
    for (const slot of ACTIVE_SLOT_LABELS) if (!character[slot]?.name) errors.push(`${character.id}.${slot} is missing`);
    if (!character.ultimate?.name) errors.push(`${character.id}.ultimate is missing`);
  }
  if (!MAPS.some((entry) => entry.id === "sanctum")) errors.push("Sanctum map missing");
  if (!MODES.some((entry) => entry.id === "freeplay")) errors.push("Freeplay mode missing");
  if (!MODES.some((entry) => entry.id === "battle_royale")) errors.push("Battle royale mode missing");
  return errors;
}
