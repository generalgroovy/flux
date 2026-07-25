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
}) => ({
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
  primary,
  special,
  defense,
  mobility,
});

export const CHARACTERS = Object.freeze([
  character({
    id: "kite",
    name: "KITE",
    role: "Mobility duelist",
    style: "Thread angles, return fire, finish up close.",
    color: "#f4f8ff",
    accent: "#77f7ce",
    glyph: "◇",
    silhouette: "kite",
    radius: 17.5,
    difficulty: 2,
    health: 100,
    speed: 430,
    primary: {
      name: "NEEDLE",
      detail: "Fast, exact pressure.",
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
      name: "SHEAR",
      detail: "Directional close strike.",
      kind: "cone",
      damage: 38,
      cooldown: 0.72,
      range: 118,
      halfAngle: 0.78,
      knockback: 270,
    },
    defense: {
      name: "SLIP",
      detail: "Return hostile shots.",
      kind: "reflect",
      duration: 0.18,
      cooldown: 1.25,
      radius: 34,
    },
    mobility: {
      name: "VECTOR",
      detail: "Precise directional dash.",
      kind: "dash",
      speed: 1120,
      duration: 0.13,
      cooldown: 1.05,
    },
  }),
  character({
    id: "bulwark",
    name: "BULWARK",
    role: "Space anchor",
    style: "Own a lane, absorb pressure, punish entry.",
    color: "#fff4db",
    accent: "#ffb86b",
    glyph: "▣",
    silhouette: "block",
    radius: 19.5,
    difficulty: 1,
    health: 145,
    speed: 340,
    primary: {
      name: "RIVET",
      detail: "Heavy, deliberate impact.",
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
      name: "BREACH",
      detail: "Wide knockback sweep.",
      kind: "cone",
      damage: 28,
      cooldown: 1,
      range: 145,
      halfAngle: 1.08,
      knockback: 430,
    },
    defense: {
      name: "BRACE",
      detail: "Face damage and hold ground.",
      kind: "guard",
      duration: 0.62,
      cooldown: 1.45,
      reduction: 0.72,
      frontalDot: -0.1,
    },
    mobility: {
      name: "RAM",
      detail: "Short armored body check.",
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
    name: "ECHO",
    role: "Feint skirmisher",
    style: "Overload reads with spread and discontinuous movement.",
    color: "#f7efff",
    accent: "#c38cff",
    glyph: "◐",
    silhouette: "split",
    radius: 17,
    difficulty: 3,
    health: 84,
    speed: 465,
    primary: {
      name: "TRIPLET",
      detail: "Three-shot fan.",
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
      name: "AFTERIMAGE",
      detail: "Radial pulse that creates space.",
      kind: "blast",
      damage: 24,
      cooldown: 1.05,
      range: 135,
      knockback: 360,
    },
    defense: {
      name: "NULL",
      detail: "Briefly phase through damage.",
      kind: "phase",
      duration: 0.21,
      cooldown: 1.6,
    },
    mobility: {
      name: "SKIP",
      detail: "Instant safe-path blink.",
      kind: "blink",
      distance: 152,
      cooldown: 1.25,
    },
  }),
  character({
    id: "volt",
    name: "VOLT",
    role: "Tempo striker",
    style: "Build rhythm, pierce lines, steal momentum.",
    color: "#effcff",
    accent: "#45d9ff",
    glyph: "ϟ",
    silhouette: "bolt",
    radius: 17.5,
    difficulty: 3,
    health: 94,
    speed: 445,
    primary: {
      name: "SPARK",
      detail: "Rapid tempo bolt.",
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
      name: "LINEBREAK",
      detail: "Instant piercing rail.",
      kind: "rail",
      damage: 37,
      cooldown: 1.15,
      range: 620,
      width: 14,
      knockback: 180,
    },
    defense: {
      name: "GROUND",
      detail: "Absorb one shot into recovery.",
      kind: "absorb",
      duration: 0.3,
      cooldown: 1.7,
      radius: 38,
      heal: 10,
      refund: 0.28,
    },
    mobility: {
      name: "SURGE",
      detail: "Long, fragile dash.",
      kind: "dash",
      speed: 1280,
      duration: 0.15,
      cooldown: 1.38,
    },
  }),
  character({
    id: "cinder",
    name: "CINDER",
    role: "Trap zoner",
    style: "Shape routes, bait pursuit, detonate commitment.",
    color: "#fff1ef",
    accent: "#ff6e5f",
    glyph: "✦",
    silhouette: "flare",
    radius: 18,
    difficulty: 2,
    health: 102,
    speed: 380,
    primary: {
      name: "EMBER",
      detail: "Slow, high-pressure shot.",
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
      name: "KINDLE",
      detail: "Plant a proximity charge.",
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
      name: "TEMPER",
      detail: "Reduce incoming damage.",
      kind: "guard",
      duration: 0.46,
      cooldown: 1.4,
      reduction: 0.52,
      frontalDot: -1,
    },
    mobility: {
      name: "BACKDRAFT",
      detail: "Recoil opposite your aim.",
      kind: "recoil",
      speed: 980,
      duration: 0.11,
      cooldown: 1.1,
    },
  }),
  character({
    id: "orbit",
    name: "ORBIT",
    role: "Field controller",
    style: "Displace enemies and bend projectile lanes.",
    color: "#eef5ff",
    accent: "#7aa8ff",
    glyph: "◎",
    silhouette: "ring",
    radius: 18.5,
    difficulty: 3,
    health: 108,
    speed: 390,
    primary: {
      name: "GRAVITY",
      detail: "Slow orb with force.",
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
      name: "WELL",
      detail: "Pull nearby rivals inward.",
      kind: "pull",
      damage: 16,
      cooldown: 1.3,
      range: 215,
      pull: 430,
    },
    defense: {
      name: "SLING",
      detail: "Reflect nearby projectiles.",
      kind: "reflect",
      duration: 0.24,
      cooldown: 1.55,
      radius: 72,
    },
    mobility: {
      name: "APOGEE",
      detail: "Measured safe-path blink.",
      kind: "blink",
      distance: 125,
      cooldown: 1.15,
    },
  }),
  character({
    id: "mend",
    name: "MEND",
    role: "Sustain tactician",
    style: "Recover between reads and protect a narrow advantage.",
    color: "#effff3",
    accent: "#75e891",
    glyph: "+",
    silhouette: "cross",
    radius: 18,
    difficulty: 1,
    health: 112,
    speed: 405,
    primary: {
      name: "SUTURE",
      detail: "Reliable precision dart.",
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
      name: "SECOND WIND",
      detail: "Trade tempo for health.",
      kind: "heal",
      amount: 26,
      cooldown: 3.2,
    },
    defense: {
      name: "TRIAGE",
      detail: "Absorb one shot and recover.",
      kind: "absorb",
      duration: 0.38,
      cooldown: 1.85,
      radius: 44,
      heal: 16,
      refund: 0,
    },
    mobility: {
      name: "TRANSFER",
      detail: "Fast controlled slide.",
      kind: "dash",
      speed: 1030,
      duration: 0.14,
      cooldown: 1.18,
    },
  }),
  character({
    id: "rook",
    name: "ROOK",
    role: "Range sentinel",
    style: "Control long sightlines and punish predictable exits.",
    color: "#f5f7eb",
    accent: "#d3e56b",
    glyph: "♜",
    silhouette: "rook",
    radius: 18.5,
    difficulty: 2,
    health: 96,
    speed: 365,
    primary: {
      name: "MARK",
      detail: "Fast long-range round.",
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
      name: "CROSSCUT",
      detail: "Five-shot denial fan.",
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
      name: "CHECK",
      detail: "Tight parry and countershot.",
      kind: "counter",
      duration: 0.13,
      cooldown: 1.2,
      radius: 36,
      counterDamage: 32,
      counterSpeed: 1050,
    },
    mobility: {
      name: "CASTLE",
      detail: "Short lateral reposition.",
      kind: "dash",
      speed: 890,
      duration: 0.105,
      cooldown: 0.88,
    },
  }),
]);

export const MAPS = Object.freeze([
  {
    id: "breakline",
    name: "BREAKLINE",
    identity: "Twin rotations around a lethal central seam.",
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
    objective: { x: 800, y: 450, radius: 118 },
  },
  {
    id: "crosswind",
    name: "CROSSWIND",
    identity: "Long sightlines broken by offset pockets.",
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
    objective: { x: 800, y: 450, radius: 112 },
  },
  {
    id: "crown",
    name: "CROWN",
    identity: "A contested center with four readable entry gates.",
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
    objective: { x: 800, y: 450, radius: 174 },
  },
  {
    id: "undercurrent",
    name: "UNDERCURRENT",
    identity: "Three lanes whose side currents pulse out of phase.",
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
    objective: { x: 800, y: 450, radius: 105 },
  },
]);

export const MODES = Object.freeze([
  {
    id: "training",
    name: "FIRST CONTACT",
    category: "Fundamentals",
    description: "A three-beat, skippable introduction against one restrained bot.",
    scoreLimit: 1,
    timeLimit: 180,
    botCount: 1,
    allowLocal: false,
  },
  {
    id: "duel",
    name: "DIFFERENCE",
    category: "PvP",
    description: "First to five. Clean resets, protected spawns, no pickups.",
    scoreLimit: 5,
    timeLimit: 150,
    botCount: 1,
    allowLocal: true,
  },
  {
    id: "control",
    name: "FAULTLINE",
    category: "Objective",
    description: "Hold the center uncontested. Position is worth more than damage.",
    scoreLimit: 100,
    timeLimit: 180,
    botCount: 2,
    allowLocal: true,
  },
  {
    id: "convergence",
    name: "CONVERGENCE",
    category: "PvPvE",
    description: "Fight for control while neutral sentinels punish careless routes.",
    scoreLimit: 120,
    timeLimit: 210,
    botCount: 2,
    neutralCount: 2,
    allowLocal: true,
  },
  {
    id: "survival",
    name: "PRESSURE TEST",
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

export function getMap(id) {
  return MAPS.find((entry) => entry.id === id) ?? MAPS[0];
}

export function getMode(id) {
  return MODES.find((entry) => entry.id === id) ?? MODES[0];
}

export function validateContent({
  characters = CHARACTERS,
  maps = MAPS,
  modes = MODES,
} = {}) {
  const errors = [];
  const unique = (items, label) => {
    const ids = items.map((item) => item.id);
    if (new Set(ids).size !== ids.length) errors.push(`${label} ids must be unique`);
  };
  unique(characters, "character");
  unique(maps, "map");
  unique(modes, "mode");
  if (characters.length < 8) errors.push("at least eight characters are required");
  if (maps.length < 3) errors.push("at least three maps are required");
  const requiredModes = ["training", "duel", "control", "convergence", "survival"];
  for (const modeId of requiredModes) {
    if (!modes.some((mode) => mode.id === modeId)) {
      errors.push(`missing mode ${modeId}`);
    }
  }

  for (const agent of characters) {
    if (
      !["kite", "block", "split", "bolt", "flare", "ring", "cross", "rook"].includes(
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
  }

  for (const map of maps) {
    if (!Array.isArray(map.spawns) || map.spawns.length < 2) {
      errors.push(`${map.id} needs at least two spawns`);
    }
    if (!Array.isArray(map.obstacles) || !Array.isArray(map.hazards)) {
      errors.push(`${map.id} geometry must use arrays`);
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
