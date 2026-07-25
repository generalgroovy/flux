const RAW_CONFIG = {
  game: {
    title: "DIFF",
    expansion: "Dodging Instinct. Fighting Finesse.",
    characterId: "kite",
    mapId: "breakline",
  },
  simulation: {
    tickRate: 120,
    maxFrameDelta: 0.1,
  },
  arena: {
    width: 1600,
    height: 900,
    inset: 48,
  },
  character: {
    id: "kite",
    name: "KITE",
    role: "Mobility duelist",
    radius: 21,
    maxSpeed: 430,
    acceleration: 2800,
    deceleration: 3400,
    weapon: {
      damage: 30,
      cooldown: 0.18,
      projectileSpeed: 1120,
      projectileLifetime: 1.25,
      projectileRadius: 6,
      spawnOffset: 31,
    },
    dash: {
      speed: 1140,
      duration: 0.13,
      cooldown: 1.15,
    },
  },
  target: {
    radius: 31,
    health: 60,
    hitFlashDuration: 0.11,
  },
  map: {
    id: "breakline",
    name: "BREAKLINE",
    spawn: { x: 180, y: 450 },
    obstacles: [
      { x: 510, y: 150, width: 72, height: 250 },
      { x: 510, y: 500, width: 72, height: 250 },
      { x: 760, y: 382, width: 80, height: 136 },
      { x: 1018, y: 150, width: 72, height: 250 },
      { x: 1018, y: 500, width: 72, height: 250 },
    ],
    targets: [
      { id: "left", x: 400, y: 450 },
      { id: "upper", x: 800, y: 250 },
      { id: "right", x: 1280, y: 450 },
    ],
  },
  presentation: {
    background: "#070a10",
    floor: "#0d1520",
    grid: "#92b0cd12",
    cover: "#1b2b3b",
    coverEdge: "#6d8da82e",
    player: "#f4f8ff",
    playerAccent: "#77f7ce",
    target: "#ffca4f",
    targetDamage: "#ff5d73",
    projectile: "#e8fff8",
  },
};

export function validateConfig(config) {
  const errors = [];
  const positive = (value, path) => {
    if (!Number.isFinite(value) || value <= 0) errors.push(`${path} must be positive`);
  };

  positive(config?.simulation?.tickRate, "simulation.tickRate");
  positive(config?.arena?.width, "arena.width");
  positive(config?.arena?.height, "arena.height");
  positive(config?.character?.radius, "character.radius");
  positive(config?.character?.maxSpeed, "character.maxSpeed");
  positive(config?.character?.weapon?.damage, "character.weapon.damage");
  positive(config?.character?.weapon?.cooldown, "character.weapon.cooldown");
  positive(config?.character?.weapon?.projectileSpeed, "character.weapon.projectileSpeed");
  positive(config?.character?.dash?.speed, "character.dash.speed");
  positive(config?.character?.dash?.duration, "character.dash.duration");
  positive(config?.character?.dash?.cooldown, "character.dash.cooldown");
  positive(config?.target?.health, "target.health");

  if (!Array.isArray(config?.map?.targets) || config.map.targets.length === 0) {
    errors.push("map.targets must contain at least one target");
  }
  if (!Array.isArray(config?.map?.obstacles)) {
    errors.push("map.obstacles must be an array");
  }

  return errors;
}

function deepFreeze(value) {
  if (!value || typeof value !== "object" || Object.isFrozen(value)) return value;
  for (const child of Object.values(value)) deepFreeze(child);
  return Object.freeze(value);
}

const configErrors = validateConfig(RAW_CONFIG);
if (configErrors.length > 0) {
  throw new TypeError(`Invalid DIFF configuration: ${configErrors.join("; ")}`);
}

export const CONFIG = deepFreeze(RAW_CONFIG);
