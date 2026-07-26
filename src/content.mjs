const character = ({
  id,
  name,
  role,
  style,
  color,
  accent,
  glyph,
  silhouette,
  radius = 18,
  difficulty,
  health,
  speed,
  primary,
  special,
  defense,
  mobility,
  passive = null,
  ultimate = null,
  affinity,
  homeRaceId,
}) => {
  const tactical = { fluxCost: 34, ...special };
  return {
    id,
    name,
    role,
    style,
    color,
    accent,
    glyph,
    silhouette,
    difficulty,
    radius,
    health,
    speed,
    acceleration: speed * 6.6,
    deceleration: speed * 8,
    damageInvulnerability: 0.08,
    passive,
    primary: { fluxCost: 0, ...primary },
    tactical,
    // Wire-format v1 keeps `special`; authored content now uses the tactical contract.
    special: tactical,
    defense: { fluxCost: 18, ...defense },
    mobility: { fluxCost: 16, ...mobility },
    ultimate,
    affinity,
    homeRaceId,
  };
};

export const RACES = Object.freeze([
  { id: "human", name: "Human", trait: "Adaptable", feature: "open circlet", featureGlyph: "⌃", boon: "+4% Flux", drawback: "−2% health", health: 0.98, speed: 1, flux: 1.04, flow: 1 },
  { id: "orc", name: "Iron Orc", trait: "Committed", feature: "twin tusks", featureGlyph: "ᚢ", boon: "+7% health", drawback: "−4% speed", health: 1.07, speed: 0.96, flux: 1, flow: 1 },
  { id: "troll", name: "Moss Troll", trait: "Enduring", feature: "moss antlers", featureGlyph: "Y", boon: "+9% health", drawback: "−6% Flux", health: 1.09, speed: 0.98, flux: 0.94, flow: 1 },
  { id: "wood_elf", name: "Briar Elf", trait: "Fleet", feature: "leaf-point ears", featureGlyph: "‹›", boon: "+5% speed", drawback: "−5% health", health: 0.95, speed: 1.05, flux: 1, flow: 1 },
  { id: "night_elf", name: "Gloam Elf", trait: "Arcane", feature: "moon-point ears", featureGlyph: "◖◗", boon: "+8% Flux", drawback: "−4% FLOW", health: 0.98, speed: 1, flux: 1.08, flow: 0.96 },
  { id: "dwarf", name: "Forge Dwarf", trait: "Grounded", feature: "braided square beard", featureGlyph: "⋈", boon: "+6% health", drawback: "−3% speed", health: 1.06, speed: 0.97, flux: 1, flow: 1 },
  { id: "gnome", name: "Copper Gnome", trait: "Efficient", feature: "high copper cap", featureGlyph: "△", boon: "+7% Flux", drawback: "−4% health", health: 0.96, speed: 1.01, flux: 1.07, flow: 1 },
  { id: "undead", name: "Ash Revenant", trait: "Relentless", feature: "rune ribs", featureGlyph: "≡", boon: "+5% health", drawback: "−5% FLOW", health: 1.05, speed: 1, flux: 1, flow: 0.95 },
  { id: "sylph", name: "Cloud Sylph", trait: "Weightless", feature: "streamer wings", featureGlyph: "≋", boon: "+6% speed", drawback: "−7% health", health: 0.93, speed: 1.06, flux: 1, flow: 1.02 },
  { id: "tideborn", name: "Reefborn", trait: "Fluid", feature: "cheek fins", featureGlyph: "⋉⋊", boon: "+7% FLOW", drawback: "−3% health", health: 0.97, speed: 1, flux: 1, flow: 1.07 },
  { id: "stonekin", name: "Cairnkin", trait: "Anchored", feature: "cairn shoulders", featureGlyph: "◆◆", boon: "+8% health", drawback: "−5% speed", health: 1.08, speed: 0.95, flux: 1, flow: 1 },
  { id: "ashling", name: "Cinderling", trait: "Volatile", feature: "flame crest", featureGlyph: "♨", boon: "+5% speed / Flux", drawback: "−7% health", health: 0.93, speed: 1.05, flux: 1.05, flow: 1 },
  { id: "wyrmbound", name: "Wyrmbound", trait: "Scaled", feature: "scaled wings", featureGlyph: "〽", boon: "−14% forced movement", drawback: "−6% FLOW / −2% speed", health: 1.03, speed: 0.98, flux: 1.02, flow: 0.94, knockback: 0.86 },
]);

export const CHARACTERS = Object.freeze([
  character({
    id: "kite",
    homeRaceId: "wood_elf",
    affinity: { kind: "element", id: "wind", name: "GALE", edge: "Directional force channels" },
    name: "AERWYN",
    role: "Briar gale duelist",
    style: "A Briar Elf wind-reader who threads cover, turns hostile magic, and commits on a stolen angle.",
    color: "#f4f8ff",
    accent: "#77f7ce",
    glyph: "◇",
    silhouette: "kite",
    radius: 17.5,
    difficulty: 2,
    health: 100,
    speed: 430,
    passive: {
      name: "THREAD THE TURN",
      detail: "A successful spell turn guides one slightly slower Wind Needle through your aim.",
      kind: "reflect-guide",
      duration: 1.4,
      guideDuration: 0.58,
      turnRate: 3.4,
      speedMultiplier: 0.92,
    },
    primary: {
      name: "WIND NEEDLE",
      detail: "A fast, exact thorn of air.",
      damage: 22,
      cooldown: 0.17,
      speed: 1120,
      lifetime: 1.25,
      radius: 5,
      count: 1,
      spread: 0,
      knockback: 35,
    },
    special: {
      name: "SHEARWIND",
      detail: "Carve a lasting gale channel.",
      kind: "cone",
      damage: 38,
      cooldown: 0.72,
      range: 118,
      halfAngle: 0.78,
      knockback: 270,
    },
    defense: {
      name: "TURNING LEAF",
      detail: "Turn hostile spells with a brief read.",
      kind: "reflect",
      duration: 0.18,
      cooldown: 1.25,
      radius: 34,
    },
    mobility: {
      name: "GALE STEP",
      detail: "Precise wind-driven dash.",
      kind: "dash",
      speed: 1120,
      duration: 0.13,
      cooldown: 1.05,
    },
    ultimate: {
      name: "THE TURNING SKY",
      detail: "Mark a shared vortex that bends spells, fighters, and Ember around its rim.",
      kind: "wind-vortex",
      chargeRequired: 100,
      chargePerDamage: 0.82,
      windup: 0.64,
      moveScale: 0.44,
      targetRange: 310,
      fieldCount: 1,
      fieldRadius: 165,
      fieldDuration: 3.1,
      spin: 1,
    },
  }),
  character({
    id: "bulwark",
    homeRaceId: "orc",
    affinity: { kind: "element", id: "earth", name: "STONE", edge: "Temporary collision cover" },
    name: "GORUM",
    role: "Iron Orc runewarden",
    style: "An old clan sentinel who raises Stone, anchors a lane, and punishes careless entry.",
    color: "#fff4db",
    accent: "#ffb86b",
    glyph: "▣",
    silhouette: "block",
    radius: 19.5,
    difficulty: 1,
    health: 145,
    speed: 340,
    primary: {
      name: "SLINGSTONE",
      detail: "Heavy rune-cut impact.",
      damage: 34,
      cooldown: 0.34,
      speed: 780,
      lifetime: 1.55,
      radius: 8,
      count: 1,
      spread: 0,
      knockback: 150,
      heavy: true,
    },
    special: {
      name: "FAULTLINE",
      detail: "Raise cover behind a wide stone sweep.",
      kind: "cone",
      damage: 28,
      cooldown: 1,
      range: 145,
      halfAngle: 1.08,
      knockback: 430,
    },
    defense: {
      name: "IRONROOT",
      detail: "Face the spell and hold sacred ground.",
      kind: "guard",
      duration: 0.62,
      cooldown: 1.45,
      reduction: 0.72,
      frontalDot: -0.1,
    },
    mobility: {
      name: "WAR TUSK",
      detail: "Short armored clan charge.",
      kind: "charge",
      speed: 830,
      duration: 0.18,
      cooldown: 1.45,
      contactDamage: 24,
      knockback: 390,
    },
  }),
  character({
    id: "echo",
    homeRaceId: "night_elf",
    affinity: { kind: "element", id: "veil", name: "VEIL", edge: "Decoys, concealed intent, and position swaps" },
    name: "VELLYN",
    role: "Gloam Elf veilweaver",
    style: "A moon-court deceiver who divides intent, leaves a wraith, and swaps the expected punish.",
    color: "#f7efff",
    accent: "#c38cff",
    glyph: "◐",
    silhouette: "split",
    radius: 17,
    difficulty: 3,
    health: 84,
    speed: 465,
    primary: {
      name: "MOON SHARDS",
      detail: "Three pale shards in a fan.",
      damage: 12,
      cooldown: 0.28,
      speed: 990,
      lifetime: 1.1,
      radius: 4,
      count: 3,
      spread: 0.14,
      knockback: 18,
    },
    special: {
      name: "MIRROR WRAITH",
      detail: "Pulse, leave a decoy, recast to swap.",
      kind: "blast",
      damage: 24,
      cooldown: 1.05,
      range: 135,
      knockback: 360,
    },
    defense: {
      name: "DUSK MANTLE",
      detail: "Briefly pass between hostile spells.",
      kind: "phase",
      duration: 0.21,
      cooldown: 1.6,
    },
    mobility: {
      name: "SHADOW STEP",
      detail: "Instant safe-path passage.",
      kind: "blink",
      distance: 152,
      cooldown: 1.25,
    },
  }),
  character({
    id: "volt",
    homeRaceId: "gnome",
    affinity: { kind: "element", id: "lightning", name: "VOLT", edge: "Charge sequencing and interruption" },
    name: "NIM COPPERSPARK",
    role: "Gnome storm-scribe",
    style: "A Copper Gnome arcanist who sequences charge, pierces lines, and steals a beat with interruption.",
    color: "#effcff",
    accent: "#45d9ff",
    glyph: "ϟ",
    silhouette: "bolt",
    radius: 17.5,
    difficulty: 3,
    health: 94,
    speed: 445,
    primary: {
      name: "QUICK ARC",
      detail: "Rapid inscribed lightning bolt.",
      damage: 15,
      cooldown: 0.115,
      speed: 1240,
      lifetime: 0.92,
      radius: 4,
      count: 1,
      spread: 0,
      knockback: 24,
    },
    special: {
      name: "CHAIN RUNE",
      detail: "Instant line spell that conducts through Tide.",
      kind: "rail",
      damage: 37,
      cooldown: 1.15,
      range: 620,
      width: 14,
      knockback: 180,
    },
    defense: {
      name: "GROUNDING SIGIL",
      detail: "Absorb one spell into recovery.",
      kind: "absorb",
      duration: 0.3,
      cooldown: 1.7,
      radius: 38,
      heal: 10,
      refund: 0.28,
    },
    mobility: {
      name: "STORM HOP",
      detail: "Long, fragile current dash.",
      kind: "dash",
      speed: 1280,
      duration: 0.15,
      cooldown: 1.38,
    },
  }),
  character({
    id: "cinder",
    homeRaceId: "ashling",
    affinity: { kind: "element", id: "fire", name: "EMBER", edge: "Pressure, ignition, and delayed detonation" },
    name: "SEREK ASHBORN",
    role: "Cinderling ember-seer",
    style: "A hearthless wanderer who kindles routes, baits pursuit, and detonates committed ground.",
    color: "#fff1ef",
    accent: "#ff6e5f",
    glyph: "✦",
    silhouette: "flare",
    radius: 18,
    difficulty: 2,
    health: 102,
    speed: 380,
    primary: {
      name: "COAL STAR",
      detail: "Slow, high-pressure ember.",
      damage: 27,
      cooldown: 0.25,
      speed: 770,
      lifetime: 1.8,
      radius: 7,
      count: 1,
      spread: 0,
      knockback: 72,
    },
    special: {
      name: "HEARTH TRAP",
      detail: "Plant a delayed ignition rune.",
      kind: "mine",
      damage: 34,
      cooldown: 1.35,
      armTime: 0.36,
      duration: 7,
      triggerRadius: 86,
      blastRadius: 125,
      knockback: 310,
    },
    defense: {
      name: "ASHEN WARD",
      detail: "Temper incoming spell damage.",
      kind: "guard",
      duration: 0.46,
      cooldown: 1.4,
      reduction: 0.52,
      frontalDot: -1,
    },
    mobility: {
      name: "BACKBLAST",
      detail: "Ride recoil opposite your aim.",
      kind: "recoil",
      speed: 980,
      duration: 0.11,
      cooldown: 1.1,
    },
  }),
  character({
    id: "orbit",
    homeRaceId: "undead",
    affinity: { kind: "element", id: "null", name: "NULL", edge: "Punishable construct cancellation" },
    name: "MORCANT",
    role: "Revenant null cantor",
    style: "An Ash Revenant ascetic who denies conjured ground and drags rivals into disciplined fundamentals.",
    color: "#eef5ff",
    accent: "#7aa8ff",
    glyph: "◎",
    silhouette: "ring",
    radius: 18.5,
    difficulty: 3,
    health: 108,
    speed: 390,
    primary: {
      name: "GRAVE ORB",
      detail: "Slow remnant with crushing force.",
      damage: 25,
      cooldown: 0.31,
      speed: 650,
      lifetime: 2.05,
      radius: 10,
      count: 1,
      spread: 0,
      knockback: 230,
      heavy: true,
    },
    special: {
      name: "SILENCE WELL",
      detail: "Pull rivals and erase nearby constructs.",
      kind: "pull",
      damage: 16,
      cooldown: 1.3,
      range: 215,
      pull: 430,
    },
    defense: {
      name: "SPELLTURN",
      detail: "Return nearby shaped magic.",
      kind: "reflect",
      duration: 0.24,
      cooldown: 1.55,
      radius: 72,
    },
    mobility: {
      name: "GRAVE STEP",
      detail: "Measured passage through the veil.",
      kind: "blink",
      distance: 125,
      cooldown: 1.15,
    },
  }),
  character({
    id: "mend",
    homeRaceId: "tideborn",
    affinity: { kind: "element", id: "water", name: "TIDE", edge: "Fire cleansing and FLOW recovery" },
    name: "NERIS PEARLDIVE",
    role: "Reefborn tidecaller",
    style: "A keeper of living currents who redirects Ember, restores Flux rhythm, and protects a narrow advantage.",
    color: "#effff3",
    accent: "#75e891",
    glyph: "+",
    silhouette: "cross",
    radius: 18,
    difficulty: 1,
    health: 112,
    speed: 405,
    primary: {
      name: "DEW LANCE",
      detail: "Reliable needle of pressurized Tide.",
      damage: 20,
      cooldown: 0.2,
      speed: 1020,
      lifetime: 1.35,
      radius: 5,
      count: 1,
      spread: 0,
      knockback: 46,
    },
    special: {
      name: "WELLSPRING",
      detail: "Trade tempo for health and flowing terrain.",
      kind: "heal",
      amount: 26,
      cooldown: 3.2,
    },
    defense: {
      name: "TIDESHIELD",
      detail: "Absorb one spell and recover.",
      kind: "absorb",
      duration: 0.38,
      cooldown: 1.85,
      radius: 44,
      heal: 16,
      refund: 0,
    },
    mobility: {
      name: "CURRENT STEP",
      detail: "Fast controlled water slide.",
      kind: "dash",
      speed: 1030,
      duration: 0.14,
      cooldown: 1.18,
    },
  }),
  character({
    id: "rook",
    homeRaceId: "dwarf",
    affinity: { kind: "element", id: "prism", name: "PRISM", edge: "Splitting, piercing ranged pressure" },
    name: "BRANNA RUNESIGHT",
    role: "Forge Dwarf prism sage",
    style: "A hall-forged lenswright who splits spells, controls sightlines, and punishes predictable exits.",
    color: "#f5f7eb",
    accent: "#d3e56b",
    glyph: "♜",
    silhouette: "rook",
    radius: 18.5,
    difficulty: 2,
    health: 96,
    speed: 365,
    primary: {
      name: "RUNE RAY",
      detail: "Fast long-range beam shard.",
      damage: 31,
      cooldown: 0.39,
      speed: 1450,
      lifetime: 1.05,
      radius: 4,
      count: 1,
      spread: 0,
      knockback: 95,
      pierce: 1,
    },
    special: {
      name: "SUNSPLIT",
      detail: "Refract one cast into a five-ray fan.",
      kind: "volley",
      damage: 13,
      cooldown: 1.1,
      speed: 930,
      lifetime: 1.25,
      radius: 5,
      count: 5,
      spread: 0.18,
      knockback: 42,
    },
    defense: {
      name: "FACET PARRY",
      detail: "Tight prism parry and counter-ray.",
      kind: "counter",
      duration: 0.13,
      cooldown: 1.2,
      radius: 36,
      counterDamage: 32,
      counterSpeed: 1050,
    },
    mobility: {
      name: "RUNESTEP",
      detail: "Short lateral glyph-step.",
      kind: "dash",
      speed: 890,
      duration: 0.105,
      cooldown: 0.88,
    },
  }),
  character({
    id: "rimewing",
    homeRaceId: "wyrmbound",
    affinity: { kind: "element", id: "ice", name: "TIDE", edge: "Friction control and brittle ground" },
    name: "YRSA RIMEWING",
    role: "Wyrmbound frost outrider",
    style: "A high-aerie hunter who commits through pressure, freezes the exit, and counters the panicked answer.",
    color: "#f4efe0",
    accent: "#9fd8de",
    glyph: "ᚱ",
    silhouette: "wing",
    radius: 19,
    difficulty: 2,
    health: 118,
    speed: 385,
    passive: {
      name: "RIDGELINE HUNT",
      detail: "A wall kick or landing cut primes one faster, tighter Rime Fangs cast.",
      kind: "movement-prime",
      duration: 1.2,
      speedMultiplier: 1.18,
      spreadMultiplier: 0.45,
    },
    primary: {
      name: "RIME FANGS",
      detail: "Paired shards reward range judgment.",
      damage: 16,
      cooldown: 0.27,
      speed: 920,
      lifetime: 1.35,
      radius: 6,
      count: 2,
      spread: 0.075,
      knockback: 58,
    },
    special: {
      name: "WHITE BREATH",
      detail: "Short cone leaves a readable frost route.",
      kind: "cone",
      damage: 19,
      cooldown: 1.2,
      range: 155,
      halfAngle: 0.72,
      knockback: 145,
    },
    defense: {
      name: "SCALE TURN",
      detail: "Tight read answers with a rime shard.",
      kind: "counter",
      duration: 0.14,
      cooldown: 1.35,
      radius: 38,
      counterDamage: 29,
      counterSpeed: 980,
    },
    mobility: {
      name: "WYRMBOUND",
      detail: "Armored forward leap with body risk.",
      kind: "charge",
      speed: 900,
      duration: 0.16,
      cooldown: 1.32,
      contactDamage: 19,
      knockback: 280,
    },
    ultimate: {
      name: "THE WHITE HUNT",
      detail: "Mark a fixed lane, then loose a rime fan and freeze its route.",
      kind: "line-volley",
      chargeRequired: 100,
      chargePerDamage: 0.8,
      windup: 0.58,
      moveScale: 0.38,
      range: 430,
      fieldCount: 3,
      fieldRadius: 92,
      fieldDuration: 3.8,
      damage: 18,
      speed: 940,
      lifetime: 0.78,
      radius: 7,
      count: 5,
      spread: 0.13,
      knockback: 95,
    },
  }),
  character({
    id: "ashmaw",
    homeRaceId: "wyrmbound",
    affinity: { kind: "element", id: "fire", name: "EMBER", edge: "Douseable route pressure and clash conversion" },
    name: "VARKA ASHMAW",
    role: "Wyrmbound pyre exile",
    style: "Yrsa's oath-broken counterpart authors dangerous ground, trades projectile speed for clash weight, and crowns an escape route instead of chasing it.",
    color: "#f2dfca",
    accent: "#e87b52",
    glyph: "ᚴ",
    silhouette: "maw",
    radius: 19.5,
    difficulty: 3,
    health: 110,
    speed: 405,
    passive: {
      name: "PYRE-FORGED",
      detail: "From allied fire, Cinder Tooth becomes slower, wider, and heavy without gaining damage.",
      kind: "field-temper",
      speedMultiplier: 0.68,
      radiusMultiplier: 1.5,
      knockbackMultiplier: 2.1,
    },
    primary: {
      name: "CINDER TOOTH",
      detail: "Exact ember that can be tempered through owned ground.",
      damage: 23,
      cooldown: 0.22,
      speed: 920,
      lifetime: 1.3,
      radius: 6,
      count: 1,
      spread: 0,
      knockback: 65,
    },
    special: {
      name: "PYRE FURROW",
      detail: "Inscribe a narrow, douseable fire route.",
      kind: "trail",
      cooldown: 1.45,
      range: 280,
      fieldCount: 3,
      fieldRadius: 58,
      fieldDuration: 2.2,
    },
    defense: {
      name: "SMOKE SHED",
      detail: "Briefly shed form and let the committed spell pass.",
      kind: "phase",
      duration: 0.17,
      cooldown: 1.5,
    },
    mobility: {
      name: "TALON VAULT",
      detail: "Recoil from the aimed threat without turning away.",
      kind: "recoil",
      speed: 1020,
      duration: 0.12,
      cooldown: 1.15,
    },
    ultimate: {
      name: "THE ASHEN CROWN",
      detail: "Mark a distant ring, then kindle six sigils with readable escape seams.",
      kind: "field-crown",
      chargeRequired: 100,
      chargePerDamage: 0.78,
      windup: 0.72,
      moveScale: 0.5,
      targetRange: 340,
      crownRadius: 180,
      fieldCount: 6,
      fieldRadius: 52,
      fieldDuration: 3.2,
    },
  }),
]);

export const MAPS = Object.freeze([
  {
    id: "breakline",
    regionId: "fracture",
    region: "The Fracture",
    scale: "duel",
    atlas: { x: 22, y: 54, regionX: 49, regionY: 55 },
    name: "THE SUNDERED ROAD",
    terrain: "Broken imperial causeway",
    identity: "Twin rotations around a cursed central scar.",
    lore: "The king-road split when the first Flux oath failed. Caravans now race its two surviving arms while the scar wakes beneath them.",
    heraldry: "THE FRACTURED SUN",
    visual: { floor: "#302718", void: "#100d09", grid: "#514326", accent: "#d0a94f" },
    size: { width: 1600, height: 900, inset: 44 },
    spawns: [
      { x: 175, y: 450 },
      { x: 1425, y: 450 },
      { x: 800, y: 115 },
      { x: 800, y: 785 },
    ],
    obstacles: [
      { x: 490, y: 140, width: 78, height: 260 },
      { x: 490, y: 500, width: 78, height: 260 },
      { x: 760, y: 374, width: 80, height: 152 },
      { x: 1032, y: 140, width: 78, height: 260 },
      { x: 1032, y: 500, width: 78, height: 260 },
    ],
    hazards: [
      {
        id: "seam",
        x: 586,
        y: 421,
        width: 428,
        height: 58,
        warning: 0.75,
        active: 0.38,
        cooldown: 2.35,
        initial: 2.2,
        damage: 22,
      },
    ],
    landmarks: [
      { type: "road", x: 110, y: 418, width: 1380, height: 64, label: "KING-ROAD" },
      { type: "rune", x: 800, y: 450, radius: 76, label: "OATHSCAR" },
    ],
    objective: { x: 800, y: 450, radius: 118 },
    wildmarch: {
      routes: [
        { id: "north-road", name: "NORTH ROAD", x: 800, y: 245, radius: 58 },
        { id: "south-road", name: "SOUTH ROAD", x: 800, y: 655, radius: 58 },
      ],
    },
  },
  {
    id: "ashen_ford",
    regionId: "fracture",
    region: "The Fracture",
    scale: "small",
    atlas: { x: 22, y: 54, regionX: 24, regionY: 68 },
    name: "ASHEN FORD",
    terrain: "Shallow cinder ford",
    identity: "A fast three-route crossing with exposed stepping stones.",
    lore: "Pilgrims once washed oath-ash from their hands here. The ford now kindles at dusk, forcing travelers to choose water, bridge, or broken bank.",
    heraldry: "THE BLACK HERON",
    visual: { floor: "#30251a", void: "#100b08", grid: "#55402c", accent: "#c47d48" },
    size: { width: 1600, height: 900, inset: 44 },
    spawns: [
      { x: 170, y: 450 }, { x: 1430, y: 450 }, { x: 310, y: 150 }, { x: 1290, y: 750 },
    ],
    obstacles: [
      { x: 420, y: 250, width: 170, height: 80 },
      { x: 420, y: 570, width: 170, height: 80 },
      { x: 720, y: 370, width: 160, height: 160 },
      { x: 1010, y: 250, width: 170, height: 80 },
      { x: 1010, y: 570, width: 170, height: 80 },
    ],
    hazards: [{
      id: "ford-kindle", x: 630, y: 420, width: 340, height: 60,
      warning: 0.9, active: 0.42, cooldown: 3.1, initial: 1.6, damage: 18,
    }],
    landmarks: [
      { type: "water", x: 120, y: 390, width: 1360, height: 120, label: "ASHEN FORD" },
      { type: "rune", x: 800, y: 450, radius: 92, label: "HERON STONES" },
    ],
    objective: { x: 800, y: 450, radius: 126 },
    wildmarch: {
      routes: [
        { id: "heron-bank", name: "HERON BANK", x: 800, y: 235, radius: 58 },
        { id: "cinder-bank", name: "CINDER BANK", x: 800, y: 665, radius: 58 },
      ],
    },
  },
  {
    id: "pilgrim_steps",
    regionId: "fracture",
    region: "The Fracture",
    scale: "medium",
    atlas: { x: 22, y: 54, regionX: 71, regionY: 30 },
    name: "PILGRIM STEPS",
    terrain: "Terraced oath-road",
    identity: "Offset terraces reward height-line control and rapid flanks.",
    lore: "Seven terraces climb toward a shrine that no longer exists. Stone pilgrims point along false paths, turning every ascent into a contest of reads.",
    heraldry: "THE SEVEN KEYS",
    visual: { floor: "#342b1d", void: "#110e09", grid: "#5d4c31", accent: "#c2a466" },
    size: { width: 1600, height: 900, inset: 44 },
    spawns: [
      { x: 170, y: 170 }, { x: 1430, y: 730 }, { x: 170, y: 730 }, { x: 1430, y: 170 },
    ],
    obstacles: [
      { x: 330, y: 210, width: 300, height: 70 },
      { x: 330, y: 620, width: 300, height: 70 },
      { x: 720, y: 300, width: 160, height: 70 },
      { x: 720, y: 530, width: 160, height: 70 },
      { x: 970, y: 210, width: 300, height: 70 },
      { x: 970, y: 620, width: 300, height: 70 },
    ],
    hazards: [],
    landmarks: [
      { type: "road", x: 210, y: 110, width: 1180, height: 680, label: "SEVEN TERRACES" },
      { type: "rune", x: 800, y: 450, radius: 130, label: "KEYLESS SHRINE" },
    ],
    objective: { x: 800, y: 450, radius: 138 },
    wildmarch: {
      routes: [
        { id: "high-step", name: "HIGH STEP", x: 800, y: 185, radius: 58 },
        { id: "low-step", name: "LOW STEP", x: 800, y: 715, radius: 58 },
      ],
    },
  },
  {
    id: "oathscar_vale",
    regionId: "fracture",
    region: "The Fracture",
    scale: "large",
    atlas: { x: 22, y: 54, regionX: 55, regionY: 82 },
    name: "OATHSCAR VALE",
    terrain: "Ruined valley crossroads",
    identity: "Four rotations converge through a dangerous open covenant ring.",
    lore: "The whole valley bears the failed oath like a wound. Watchtowers guard long rotations while the central covenant tempts the bold into open ground.",
    heraldry: "THE BROKEN COVENANT",
    visual: { floor: "#2d281d", void: "#0e0c09", grid: "#514a36", accent: "#b89b58" },
    size: { width: 1600, height: 900, inset: 44 },
    spawns: [
      { x: 145, y: 450 }, { x: 1455, y: 450 }, { x: 800, y: 115 }, { x: 800, y: 785 },
    ],
    obstacles: [
      { x: 280, y: 180, width: 210, height: 90 }, { x: 280, y: 630, width: 210, height: 90 },
      { x: 1110, y: 180, width: 210, height: 90 }, { x: 1110, y: 630, width: 210, height: 90 },
      { x: 570, y: 330, width: 120, height: 80 }, { x: 910, y: 490, width: 120, height: 80 },
      { x: 570, y: 490, width: 120, height: 80 }, { x: 910, y: 330, width: 120, height: 80 },
    ],
    hazards: [{
      id: "covenant-pulse", x: 735, y: 385, width: 130, height: 130,
      warning: 1.05, active: 0.36, cooldown: 3.4, initial: 2.3, damage: 24,
    }],
    landmarks: [
      { type: "road", x: 105, y: 410, width: 1390, height: 80, label: "VALE CROSSING" },
      { type: "rune", x: 800, y: 450, radius: 190, label: "COVENANT RING" },
    ],
    shrines: [{
      id: "covenant-shrine", x: 800, y: 450, radius: 74,
      speedRequired: 610, fluxReward: 24, cooldown: 7,
      name: "BROKEN COVENANT",
    }],
    objective: { x: 800, y: 450, radius: 155 },
    wildmarch: {
      routes: [
        { id: "watcher-rise", name: "WATCHER RISE", x: 800, y: 205, radius: 58 },
        { id: "pilgrim-fall", name: "PILGRIM FALL", x: 800, y: 695, radius: 58 },
      ],
    },
  },
  {
    id: "crosswind",
    regionId: "gale_reach",
    region: "Gale Reach",
    scale: "medium",
    atlas: { x: 48, y: 27 },
    name: "WINDGLASS MOOR",
    terrain: "Heather moor and wind-cut glass",
    identity: "Long sightlines broken by ancient standing stones.",
    lore: "Gale-singers once tuned these violet stones by moonlight. Their broken chorus still bends dust across the exposed highland.",
    heraldry: "THE SILVER LARK",
    visual: { floor: "#29251e", void: "#0e0c0a", grid: "#494133", accent: "#aa9ac9" },
    size: { width: 1600, height: 900, inset: 44 },
    spawns: [
      { x: 170, y: 170 },
      { x: 1430, y: 730 },
      { x: 170, y: 730 },
      { x: 1430, y: 170 },
    ],
    obstacles: [
      { x: 355, y: 265, width: 250, height: 70 },
      { x: 995, y: 565, width: 250, height: 70 },
      { x: 720, y: 125, width: 70, height: 235 },
      { x: 810, y: 540, width: 70, height: 235 },
      { x: 710, y: 410, width: 180, height: 80 },
    ],
    hazards: [],
    landmarks: [
      { type: "moor", x: 190, y: 100, width: 1220, height: 700, label: "SINGING HEATH" },
      { type: "rune", x: 800, y: 450, radius: 108, label: "LARK RING" },
    ],
    objective: { x: 800, y: 450, radius: 112 },
    wildmarch: {
      routes: [
        { id: "lark-rise", name: "LARK RISE", x: 615, y: 170, radius: 58 },
        { id: "glass-fall", name: "GLASS FALL", x: 985, y: 730, radius: 58 },
      ],
    },
  },
  {
    id: "crown",
    regionId: "cairn_crown",
    region: "Cairn Crown",
    scale: "small",
    atlas: { x: 72, y: 48 },
    name: "THE OLD CROWN",
    terrain: "Cairn fortress court",
    identity: "A ruined throne court with four readable entry gates.",
    lore: "No ruler has sat the Cairn Throne for three centuries. Every clan still claims the four gate-stones remember its true heir.",
    heraldry: "THE HOLLOW CROWN",
    visual: { floor: "#332b18", void: "#100d07", grid: "#5c4d27", accent: "#d7b65c" },
    size: { width: 1600, height: 900, inset: 44 },
    spawns: [
      { x: 180, y: 450 },
      { x: 1420, y: 450 },
      { x: 800, y: 135 },
      { x: 800, y: 765 },
    ],
    obstacles: [
      { x: 570, y: 220, width: 92, height: 120 },
      { x: 938, y: 220, width: 92, height: 120 },
      { x: 570, y: 560, width: 92, height: 120 },
      { x: 938, y: 560, width: 92, height: 120 },
      { x: 748, y: 398, width: 104, height: 104 },
    ],
    hazards: [],
    landmarks: [
      { type: "court", x: 505, y: 155, width: 590, height: 590, label: "THRONE COURT" },
      { type: "rune", x: 800, y: 450, radius: 214, label: "FOUR GATES" },
    ],
    objective: { x: 800, y: 450, radius: 174 },
    wildmarch: {
      routes: [
        { id: "north-gate", name: "NORTH GATE", x: 800, y: 185, radius: 58 },
        { id: "south-gate", name: "SOUTH GATE", x: 800, y: 715, radius: 58 },
      ],
    },
  },
  {
    id: "undercurrent",
    regionId: "tide_hollows",
    region: "Tide Hollows",
    scale: "large",
    atlas: { x: 54, y: 76 },
    name: "DROWNED HALLS",
    terrain: "Flooded Reefborn undercroft",
    identity: "Three drowned aisles whose side currents pulse out of phase.",
    lore: "The Reefborn archive sank intact. Tide-script still circles its pillars, carrying fragments of forgotten names between the aisles.",
    heraldry: "THE PEARL SERPENT",
    visual: { floor: "#172b26", void: "#08100e", grid: "#315349", accent: "#73bca8" },
    size: { width: 1600, height: 900, inset: 44 },
    spawns: [
      { x: 165, y: 450 },
      { x: 1435, y: 450 },
      { x: 250, y: 145 },
      { x: 1350, y: 755 },
    ],
    obstacles: [
      { x: 400, y: 350, width: 230, height: 72 },
      { x: 400, y: 478, width: 230, height: 72 },
      { x: 970, y: 350, width: 230, height: 72 },
      { x: 970, y: 478, width: 230, height: 72 },
    ],
    hazards: [
      {
        id: "north-current",
        x: 675,
        y: 130,
        width: 250,
        height: 70,
        warning: 0.62,
        active: 0.34,
        cooldown: 2.7,
        initial: 1.2,
        damage: 18,
      },
      {
        id: "south-current",
        x: 675,
        y: 700,
        width: 250,
        height: 70,
        warning: 0.62,
        active: 0.34,
        cooldown: 2.7,
        initial: 2.55,
        damage: 18,
      },
    ],
    landmarks: [
      { type: "water", x: 80, y: 92, width: 1440, height: 716, label: "SUNKEN ARCHIVE" },
      { type: "rune", x: 800, y: 450, radius: 86, label: "PEARL SEAL" },
    ],
    objective: { x: 800, y: 450, radius: 105 },
    wildmarch: {
      routes: [
        { id: "north-aisle", name: "NORTH AISLE", x: 800, y: 275, radius: 58 },
        { id: "south-aisle", name: "SOUTH AISLE", x: 800, y: 625, radius: 58 },
      ],
    },
  },
  {
    id: "wyrmfall",
    regionId: "emberpeak",
    region: "Emberpeak",
    scale: "medium",
    atlas: { x: 84, y: 22 },
    name: "WYRMFALL AERIE",
    terrain: "Cliff monastery and rime vents",
    identity: "Two high rotations contest a narrow frost-bitten nave.",
    lore: "The last sky-wyrm fell across this monastery and sealed its furnaces. Wyrmbound outriders now read the warm vents beneath its rime-covered bones.",
    heraldry: "THE PALE WYRM",
    visual: { floor: "#302c28", void: "#0e0d0c", grid: "#514b45", accent: "#9fcbd0" },
    size: { width: 1600, height: 900, inset: 44 },
    spawns: [
      { x: 165, y: 450 }, { x: 1435, y: 450 }, { x: 300, y: 145 }, { x: 1300, y: 755 },
    ],
    obstacles: [
      { x: 360, y: 180, width: 95, height: 250 },
      { x: 360, y: 520, width: 95, height: 200 },
      { x: 635, y: 345, width: 130, height: 80 },
      { x: 835, y: 475, width: 130, height: 80 },
      { x: 1145, y: 180, width: 95, height: 200 },
      { x: 1145, y: 470, width: 95, height: 250 },
    ],
    hazards: [{
      id: "rime-vent", x: 745, y: 405, width: 110, height: 90,
      warning: 0.92, active: 0.4, cooldown: 3.2, initial: 1.9, damage: 20,
    }],
    landmarks: [
      { type: "court", x: 250, y: 100, width: 1100, height: 700, label: "AERIE NAVE" },
      { type: "rune", x: 800, y: 450, radius: 148, label: "WYRMFALL" },
    ],
    objective: { x: 800, y: 450, radius: 132 },
    wildmarch: {
      routes: [
        { id: "rime-choir", name: "RIME CHOIR", x: 800, y: 205, radius: 58 },
        { id: "ember-choir", name: "EMBER CHOIR", x: 800, y: 695, radius: 58 },
      ],
    },
  },
]);

export const MODES = Object.freeze([
  {
    id: "training",
    name: "THE FIRST RITE",
    category: "Fundamentals",
    description: "A four-read, skippable rite against one restrained shade.",
    scoreLimit: 1,
    timeLimit: 180,
    botCount: 1,
    allowLocal: false,
  },
  {
    id: "duel",
    name: "OATH DUEL",
    category: "PvP",
    description: "First to five. Clean resets, protected spawns, no pickups.",
    scoreLimit: 5,
    timeLimit: 150,
    botCount: 1,
    allowLocal: true,
  },
  {
    id: "control",
    name: "RUNEHOLD",
    category: "Objective",
    description: "Hold the center uncontested. Position is worth more than damage.",
    scoreLimit: 100,
    timeLimit: 180,
    botCount: 2,
    allowLocal: true,
  },
  {
    id: "convergence",
    name: "WILDMARCH",
    category: "PvPvE",
    description: "Take a warden's Wayseal and choose which outer route becomes the scoring rune.",
    scoreLimit: 120,
    timeLimit: 210,
    botCount: 2,
    neutralCount: 2,
    allowLocal: true,
  },
  {
    id: "survival",
    name: "NIGHT SIEGE",
    category: "PvE",
    description: "Survive escalating enemy waves with three recoverable lives.",
    scoreLimit: 5,
    timeLimit: 240,
    botCount: 2,
    lives: 3,
    allowLocal: true,
  },
]);

export const MATCH_TUNING = Object.freeze({
  tickRate: 120,
  maxFrameDelta: 0.1,
  roundResetDelay: 1.15,
  spawnProtection: 1,
  hitFlash: 0.13,
  unitCollisionIterations: 3,
  maxMoveSubsteps: 12,
  projectileClashes: true,
  flow: {
    maximum: 100,
    sprintMultiplier: 1.28,
    counterStrafeMultiplier: 1.7,
    counterStrafeCueSpeed: 220,
    counterStrafeCueCooldown: 0.7,
    sprintDrainPerSecond: 34,
    recoveryPerSecond: 27,
    recoveryDelay: 0.38,
    hopCost: 28,
    hopSpeed: 650,
    hopMomentumCarry: 0.35,
    hopCarryLimit: 180,
    wallKickSpeed: 780,
    hopDuration: 0.16,
    hopCooldown: 0.5,
    landingWindow: 0.11,
    landingCutMultiplier: 1.18,
    wallMemory: 0.16,
    slideCost: 22,
    slideEntrySpeed: 250,
    slideSpeed: 720,
    slideDuration: 0.3,
    slideCooldown: 0.78,
    slideSteering: 0.32,
    grazeMargin: 16,
    grazeMinimumSpeed: 260,
    grazeReward: 9,
    grazeCooldown: 0.22,
  },
  elements: {
    windDuration: 1.8,
    windRadius: 118,
    windForce: 185,
    vortexMoveForce: 140,
    vortexProjectileForce: 440,
    vortexFireSpeed: 92,
    iceDuration: 3.2,
    iceRadius: 148,
    iceControl: 0.34,
    fireDuration: 3,
    fireRadius: 112,
    firePulse: 0.5,
    fireDamage: 5,
    waterDuration: 2.4,
    waterRadius: 105,
    waterFlowPerSecond: 24,
    earthDuration: 2.6,
    earthLength: 150,
    earthThickness: 24,
    lightningInterrupt: 0.14,
  },
  flux: {
    maximum: 100,
    recoveryPerSecond: 19,
    recoveryDelay: 0.46,
    dryCueCooldown: 0.7,
  },
  ultimate: {
    maximum: 100,
    minimumWindup: 0.35,
    maximumWindup: 0.9,
  },
  training: {
    pressureDamage: 6,
    pressureCooldown: 1.1,
  },
  wildmarch: {
    sealRadius: 13,
    pickupRadius: 28,
    returnDuration: 16,
    routeDuration: 14,
  },
  controlScorePerSecond: 12,
  controlOvertimeGrace: 2.5,
  bot: {
    thinkInterval: 0.12,
    preferredDistance: 330,
    aimError: 0.055,
    retreatHealthRatio: 0.28,
  },
});

export function getCharacter(id) {
  return CHARACTERS.find((entry) => entry.id === id) ?? CHARACTERS[0];
}

export function getRace(id) {
  return RACES.find((entry) => entry.id === id) ?? RACES[0];
}

export function getMap(id) {
  return MAPS.find((entry) => entry.id === id) ?? MAPS[0];
}

export function getMode(id) {
  return MODES.find((entry) => entry.id === id) ?? MODES[0];
}

export function validateContent({
  characters = CHARACTERS,
  races = RACES,
  maps = MAPS,
  modes = MODES,
  tuning = MATCH_TUNING,
} = {}) {
  const errors = [];
  const unique = (items, label) => {
    const ids = items.map((item) => item.id);
    if (new Set(ids).size !== ids.length) errors.push(`${label} ids must be unique`);
  };
  unique(characters, "character");
  unique(races, "race");
  unique(maps, "map");
  unique(modes, "mode");
  if (characters.length < 8) errors.push("at least eight characters are required");
  if (races.length < 12) errors.push("at least twelve races are required");
  for (const race of races) {
    for (const key of ["health", "speed", "flux", "flow"]) {
      if (!Number.isFinite(race[key]) || race[key] < 0.9 || race[key] > 1.1) {
        errors.push(`${race.id}.${key} must stay within the balanced 0.9–1.1 range`);
      }
    }
    if (
      race.knockback !== undefined &&
      (!Number.isFinite(race.knockback) || race.knockback < 0.8 || race.knockback > 1)
    ) {
      errors.push(`${race.id}.knockback must stay within the balanced 0.8–1 range`);
    }
  }
  if (maps.length < 3) errors.push("at least three maps are required");
  const requiredModes = ["training", "duel", "control", "convergence", "survival"];
  for (const modeId of requiredModes) {
    if (!modes.some((mode) => mode.id === modeId)) {
      errors.push(`missing mode ${modeId}`);
    }
  }

  const flow = tuning.flow ?? {};
  for (const key of [
    "maximum",
    "sprintMultiplier",
    "counterStrafeMultiplier",
    "counterStrafeCueSpeed",
    "counterStrafeCueCooldown",
    "sprintDrainPerSecond",
    "recoveryPerSecond",
    "recoveryDelay",
    "hopCost",
    "hopSpeed",
    "hopMomentumCarry",
    "hopCarryLimit",
    "wallKickSpeed",
    "hopDuration",
    "hopCooldown",
    "landingWindow",
    "landingCutMultiplier",
    "wallMemory",
    "slideCost",
    "slideEntrySpeed",
    "slideSpeed",
    "slideDuration",
    "slideCooldown",
    "slideSteering",
    "grazeMargin",
    "grazeMinimumSpeed",
    "grazeReward",
    "grazeCooldown",
  ]) {
    if (!Number.isFinite(flow[key]) || flow[key] <= 0) {
      errors.push(`flow.${key} must be positive`);
    }
  }
  if (flow.hopCost > flow.maximum) {
    errors.push("flow.hopCost must not exceed flow.maximum");
  }
  if (
    flow.slideCost > flow.maximum || flow.slideSpeed <= flow.hopSpeed ||
    flow.slideEntrySpeed >= flow.slideSpeed
  ) {
    errors.push("flow slide must be payable and faster than a hop");
  }
  if (flow.slideSteering > 0.5) {
    errors.push("flow.slideSteering must preserve slide commitment");
  }
  if (
    flow.grazeMargin > 24 || flow.grazeReward > flow.maximum * 0.12 ||
    flow.grazeMinimumSpeed < flow.slideEntrySpeed || flow.grazeCooldown < 0.12
  ) {
    errors.push("flow graze must require committed movement and stay bounded");
  }
  if (flow.sprintMultiplier < 1 || flow.sprintMultiplier > 2) {
    errors.push("flow.sprintMultiplier must stay within 1–2");
  }
  if (flow.counterStrafeMultiplier < 1 || flow.counterStrafeMultiplier > 2.5) {
    errors.push("flow.counterStrafeMultiplier must stay within 1–2.5");
  }
  if (flow.wallKickSpeed < flow.hopSpeed) {
    errors.push("flow.wallKickSpeed must reward wall commitment");
  }
  if (flow.hopMomentumCarry > 0.6 || flow.hopCarryLimit > flow.hopSpeed / 2) {
    errors.push("flow hop momentum carry must remain bounded");
  }
  if (flow.landingWindow > 0.16 || flow.landingCutMultiplier > 1.35) {
    errors.push("flow landing cancel must preserve hop commitment");
  }
  for (const [key, value] of Object.entries(tuning.elements ?? {})) {
    if (!Number.isFinite(value) || value <= 0) {
      errors.push(`elements.${key} must be positive`);
    }
  }
  for (const [key, value] of Object.entries(tuning.flux ?? {})) {
    if (!Number.isFinite(value) || value <= 0) {
      errors.push(`flux.${key} must be positive`);
    }
  }
  for (const [key, value] of Object.entries(tuning.ultimate ?? {})) {
    if (!Number.isFinite(value) || value <= 0) {
      errors.push(`ultimate.${key} must be positive`);
    }
  }
  for (const [key, value] of Object.entries(tuning.training ?? {})) {
    if (!Number.isFinite(value) || value <= 0) {
      errors.push(`training.${key} must be positive`);
    }
  }
  const wildmarch = tuning.wildmarch ?? {};
  for (const key of [
    "sealRadius",
    "pickupRadius",
    "returnDuration",
    "routeDuration",
  ]) {
    if (!Number.isFinite(wildmarch[key]) || wildmarch[key] <= 0) {
      errors.push(`wildmarch.${key} must be positive`);
    }
  }
  if (
    wildmarch.sealRadius > 18 || wildmarch.pickupRadius > 40 ||
    wildmarch.pickupRadius <= wildmarch.sealRadius ||
    wildmarch.returnDuration < 8 || wildmarch.returnDuration > 24 ||
    wildmarch.routeDuration < 8 || wildmarch.routeDuration > 24
  ) {
    errors.push("wildmarch Wayseal timing and pickup geometry must stay bounded");
  }

  for (const agent of characters) {
    if (!races.some((race) => race.id === agent.homeRaceId)) {
      errors.push(`${agent.id}.homeRaceId must reference a shipped race`);
    }
    if (!agent.affinity?.id || !agent.affinity?.name || agent.affinity?.kind !== "element") {
      errors.push(`${agent.id}.affinity must declare a named element`);
    }
    if (agent.tactical !== agent.special) {
      errors.push(`${agent.id}.tactical must retain the stable special wire alias`);
    }
    if (
      !["kite", "block", "split", "bolt", "flare", "ring", "cross", "rook", "wing", "maw"].includes(
        agent.silhouette,
      )
    ) {
      errors.push(`${agent.id}.silhouette is unsupported`);
    }
    if (!Number.isFinite(agent.radius) || agent.radius < 15 || agent.radius > 20) {
      errors.push(`${agent.id}.radius must stay within the readable 15–20 range`);
    }
    for (const path of [
      ["health", agent.health],
      ["speed", agent.speed],
      ["primary.damage", agent.primary?.damage],
      ["primary.cooldown", agent.primary?.cooldown],
      ["special.cooldown", agent.special?.cooldown],
      ["defense.cooldown", agent.defense?.cooldown],
      ["mobility.cooldown", agent.mobility?.cooldown],
    ]) {
      if (!Number.isFinite(path[1]) || path[1] <= 0) {
        errors.push(`${agent.id}.${path[0]} must be positive`);
      }
    }
    for (const ability of [agent.special, agent.defense, agent.mobility]) {
      if (
        !Number.isFinite(ability.fluxCost) ||
        ability.fluxCost <= 0 ||
        ability.fluxCost > tuning.flux.maximum
      ) {
        errors.push(`${agent.id}.${ability.name}.fluxCost must be payable`);
      }
    }
    if (
      agent.tactical.kind === "trail" &&
      (!Number.isFinite(agent.tactical.range) || agent.tactical.range <= 0 ||
        !Number.isInteger(agent.tactical.fieldCount) ||
        agent.tactical.fieldCount < 2 || agent.tactical.fieldCount > 4 ||
        !Number.isFinite(agent.tactical.fieldRadius) ||
        agent.tactical.fieldRadius <= 0 ||
        !Number.isFinite(agent.tactical.fieldDuration) ||
        agent.tactical.fieldDuration <= 0)
    ) {
      errors.push(`${agent.id}.trail tactical must author a bounded route`);
    }
    if (agent.passive) {
      const passive = agent.passive;
      if (!passive.name || !passive.detail) {
        errors.push(`${agent.id}.passive needs a name and readable detail`);
      } else if (
        passive.kind === "movement-prime" &&
        (!Number.isFinite(passive.duration) || passive.duration <= 0 ||
          !Number.isFinite(passive.speedMultiplier) ||
          passive.speedMultiplier <= 1 || passive.speedMultiplier > 1.3 ||
          !Number.isFinite(passive.spreadMultiplier) ||
          passive.spreadMultiplier <= 0 || passive.spreadMultiplier >= 1)
      ) {
        errors.push(`${agent.id}.passive movement prime must remain bounded`);
      } else if (
        passive.kind === "field-temper" &&
        (!Number.isFinite(passive.speedMultiplier) ||
          passive.speedMultiplier < 0.5 || passive.speedMultiplier >= 1 ||
          !Number.isFinite(passive.radiusMultiplier) ||
          passive.radiusMultiplier <= 1 || passive.radiusMultiplier > 1.75 ||
          !Number.isFinite(passive.knockbackMultiplier) ||
          passive.knockbackMultiplier <= 1 || passive.knockbackMultiplier > 2.5)
      ) {
        errors.push(`${agent.id}.passive field temper must trade speed for bounded weight`);
      } else if (
        passive.kind === "reflect-guide" &&
        (!Number.isFinite(passive.duration) || passive.duration <= 0 || passive.duration > 2 ||
          !Number.isFinite(passive.guideDuration) || passive.guideDuration <= 0 ||
          passive.guideDuration > 1 ||
          !Number.isFinite(passive.turnRate) || passive.turnRate <= 0 || passive.turnRate > 6 ||
          !Number.isFinite(passive.speedMultiplier) ||
          passive.speedMultiplier < 0.75 || passive.speedMultiplier >= 1)
      ) {
        errors.push(`${agent.id}.passive reflect guide must trade speed for bounded steering`);
      } else if (!["movement-prime", "field-temper", "reflect-guide"].includes(passive.kind)) {
        errors.push(`${agent.id}.passive kind is unsupported`);
      }
    }
    if (agent.ultimate) {
      const ultimate = agent.ultimate;
      if (
        !ultimate.name || !ultimate.detail ||
        ultimate.chargeRequired !== tuning.ultimate.maximum ||
        !Number.isFinite(ultimate.chargePerDamage) || ultimate.chargePerDamage <= 0 ||
        ultimate.windup < tuning.ultimate.minimumWindup ||
        ultimate.windup > tuning.ultimate.maximumWindup ||
        !Number.isFinite(ultimate.moveScale) || ultimate.moveScale <= 0 ||
        ultimate.moveScale > 0.5 || !Number.isInteger(ultimate.fieldCount) ||
        ultimate.fieldCount < 1 || ultimate.fieldCount > 8 ||
        !Number.isFinite(ultimate.fieldRadius) || ultimate.fieldRadius <= 0 ||
        !Number.isFinite(ultimate.fieldDuration) || ultimate.fieldDuration <= 0
      ) {
        errors.push(`${agent.id}.ultimate needs bounded charge, tell, movement, and fields`);
      } else if (
        ultimate.kind === "line-volley" &&
        (!Number.isFinite(ultimate.range) || ultimate.range <= 0 ||
          !Number.isFinite(ultimate.damage) || ultimate.damage <= 0 ||
          !Number.isInteger(ultimate.count) || ultimate.count < 1 || ultimate.count > 7)
      ) {
        errors.push(`${agent.id}.line-volley ultimate must remain bounded`);
      } else if (
        ultimate.kind === "field-crown" &&
        (!Number.isFinite(ultimate.targetRange) || ultimate.targetRange <= 0 ||
          !Number.isFinite(ultimate.crownRadius) || ultimate.crownRadius <= 0 ||
          ultimate.fieldRadius * 2 * ultimate.fieldCount >=
            Math.PI * 2 * ultimate.crownRadius * 0.72)
      ) {
        errors.push(`${agent.id}.field-crown ultimate must preserve readable escape seams`);
      } else if (
        ultimate.kind === "wind-vortex" &&
        (!Number.isFinite(ultimate.targetRange) || ultimate.targetRange <= 0 ||
          ultimate.fieldCount !== 1 ||
          ![-1, 1].includes(ultimate.spin))
      ) {
        errors.push(`${agent.id}.wind-vortex ultimate must remain singular and directional`);
      } else if (!["line-volley", "field-crown", "wind-vortex"].includes(ultimate.kind)) {
        errors.push(`${agent.id}.ultimate kind is unsupported`);
      }
    }
  }

  const raceFeatures = new Set();
  for (const race of races) {
    if (!race.feature || !race.featureGlyph) {
      errors.push(`${race.id} must declare a readable silhouette feature and glyph`);
    } else if (raceFeatures.has(race.feature)) {
      errors.push(`${race.id}.feature must be distinct`);
    } else {
      raceFeatures.add(race.feature);
    }
  }

  for (const map of maps) {
    if (
      !map.regionId ||
      !map.region ||
      !["duel", "small", "medium", "large", "world"].includes(map.scale) ||
      !Number.isFinite(map.atlas?.x) ||
      !Number.isFinite(map.atlas?.y) ||
      (map.regionId === "fracture" &&
        (!Number.isFinite(map.atlas?.regionX) || !Number.isFinite(map.atlas?.regionY)))
    ) {
      errors.push(`${map.id} needs valid region, scale, and atlas coordinates`);
    }
    for (const key of ["floor", "void", "grid", "accent"]) {
      if (!/^#[0-9a-f]{6}$/i.test(map.visual?.[key] ?? "")) {
        errors.push(`${map.id}.visual.${key} must be a six-digit hex color`);
      }
    }
    if (!Array.isArray(map.spawns) || map.spawns.length < 2) {
      errors.push(`${map.id} needs at least two spawns`);
    }
    if (!Array.isArray(map.obstacles) || !Array.isArray(map.hazards)) {
      errors.push(`${map.id} geometry must use arrays`);
    }
    if (!map.terrain || !map.lore || !map.heraldry || !Array.isArray(map.landmarks)) {
      errors.push(`${map.id} needs terrain, lore, heraldry, and landmark data`);
    }
    for (const landmark of map.landmarks ?? []) {
      if (
        !["road", "moor", "court", "water", "rune"].includes(landmark.type) ||
        !landmark.label ||
        !Number.isFinite(landmark.x) ||
        !Number.isFinite(landmark.y)
      ) {
        errors.push(`${map.id} has an invalid landmark`);
      }
    }
    for (const shrine of map.shrines ?? []) {
      if (
        !shrine.id || !shrine.name || !Number.isFinite(shrine.x) ||
        !Number.isFinite(shrine.y) || !Number.isFinite(shrine.radius) ||
        shrine.radius < 40 || !Number.isFinite(shrine.speedRequired) ||
        shrine.speedRequired < tuning.flow.sprintMultiplier * 300 ||
        !Number.isFinite(shrine.fluxReward) || shrine.fluxReward <= 0 ||
        shrine.fluxReward > tuning.flux.maximum / 2 ||
        !Number.isFinite(shrine.cooldown) || shrine.cooldown < 3
      ) {
        errors.push(`${map.id} has an invalid movement shrine`);
      }
    }
    const routes = map.wildmarch?.routes;
    if (
      !Array.isArray(routes) || routes.length !== 2 ||
      new Set(routes.map((route) => route.id)).size !== 2
    ) {
      errors.push(`${map.id} needs two distinct WILDMARCH routes`);
    } else {
      for (const route of routes) {
        const radius = route.radius;
        const inside =
          Number.isFinite(route.x) && Number.isFinite(route.y) &&
          Number.isFinite(radius) && radius >= 44 && radius <= 72 &&
          route.x - radius >= map.size.inset &&
          route.x + radius <= map.size.width - map.size.inset &&
          route.y - radius >= map.size.inset &&
          route.y + radius <= map.size.height - map.size.inset;
        const clearOfCover = inside && !map.obstacles.some((obstacle) =>
          circleRectangleOverlap(route, radius, obstacle)
        );
        if (!route.id || !route.name || !inside || !clearOfCover) {
          errors.push(`${map.id} has an invalid WILDMARCH route`);
        }
      }
      if (
        routes.some((route) =>
          Math.hypot(route.x - map.objective.x, route.y - map.objective.y) <=
            route.radius + map.objective.radius
        ) ||
        Math.hypot(routes[0].x - routes[1].x, routes[0].y - routes[1].y) <=
          routes[0].radius + routes[1].radius
      ) {
        errors.push(`${map.id} WILDMARCH routes must create distinct rotations`);
      }
    }
    for (const spawn of map.spawns ?? []) {
      if (
        map.obstacles?.some((obstacle) =>
          circleRectangleOverlap(spawn, 54, obstacle),
        )
      ) {
        errors.push(`${map.id} spawn overlaps cover`);
      }
      if (
        map.hazards?.some((hazard) =>
          circleRectangleOverlap(spawn, 100, hazard),
        )
      ) {
        errors.push(`${map.id} spawn safety overlaps hazard`);
      }
    }
  }
  return errors;
}

function circleRectangleOverlap(circle, radius, rectangle) {
  const closestX = Math.max(
    rectangle.x,
    Math.min(circle.x, rectangle.x + rectangle.width),
  );
  const closestY = Math.max(
    rectangle.y,
    Math.min(circle.y, rectangle.y + rectangle.height),
  );
  return Math.hypot(circle.x - closestX, circle.y - closestY) < radius;
}

const contentErrors = validateContent();
if (contentErrors.length > 0) {
  throw new TypeError(`Invalid DIFF content: ${contentErrors.join("; ")}`);
}
