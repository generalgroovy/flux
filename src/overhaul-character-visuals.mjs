const freeze = (value) => Object.freeze(value);

// Presentation-only migration ledger. Legacy IDs remain live until their
// successors pass the visual and gameplay promotion gates.
export const LEGACY_CONCEPT_TRANSFERS = freeze([
  transfer("kite", "Aerwyn", "aerwyn", "Spai Si", "redirect timing, forward duelist posture, and readable wind-angle guides", "name, Briar Elf ancestry, and complete legacy kit"),
  transfer("bulwark", "Gorum", "urzh", "Urzh", "brace discipline, lane anchoring, and squared stone mass", "name, Iron Orc ancestry, and rune-warden fiction"),
  transfer("echo", "Vellyn", "samwise", "S. Wayne", "intent division, decoy spacing, and visible swap boundaries", "name, Gloam Elf ancestry, and moon-wraith fiction"),
  transfer("volt", "Nim Copperspark", "nix", "Nico Lai", "charge sequencing, interrupt windows, and calibrated device language", "name and storm-scribe fiction"),
  transfer("cinder", "Serek Ashborn", "steezo", "Steezo", "route traps, bounded detonation chains, and backblast recovery", "name and Cinderling ancestry"),
  transfer("orbit", "Morcant", "djonah-thaan", "Djonah Thaan", "ground denial, pursuit pressure, and a return-to-fundamentals silence cue", "name, Revenant ancestry, and grave-cantor fiction"),
  transfer("mend", "Neris Pearldive", "grace-reava", "Grace Reava", "living-current redirection, narrow protection windows, and Tide rhythm", "name and Reefborn ancestry"),
  transfer("rook", "Branna Runesight", "biggy-bob", "Biggy Bob", "sightline control, a readable focus tool, and forge-prism geometry", "name and rune-sage fiction"),
  transfer("rimewing", "Yrsa Rimewing", "yrsa", "Ha Rekt", "aerial cold-line hunting, marked escapes, and committed landings", "name and exact ability package"),
  transfer("ashmaw", "Varka Ashmaw", "treevor", "Treevor the Mason", "terrain shaping, Fire liability, and a crown-state climax", "name, Wyrmbound ancestry, and pyre-exile fiction"),
]);

export const OVERHAUL_CHARACTER_VISUAL_PROFILES = freeze({
  aerwyn: freeze({
    id: "aerwyn",
    name: "Spai Si",
    plannedAncestry: "Demon",
    ancestryRead: "swept horns and ember tail",
    roleRead: "forward-poised redirect duelist",
    affinityRead: "open Wind arcs, Light spindle, Earth-weighted mantle",
    focusProp: "woven angle spindle",
    body: "#b97750",
    mantle: "#51462f",
    ink: "#17130d",
    wind: "#86bda7",
    light: "#d4b84e",
    ember: "#c76632",
  }),
  urzh: freeze({
    id: "urzh",
    name: "Urzh",
    plannedAncestry: "Stoneborn",
    ancestryRead: "squared stone frame with ember seams",
    roleRead: "braced conductive kiln bulwark",
    affinityRead: "Earth plates, Fire seams, Charge forks",
    focusProp: "kiln buckler",
    body: "#8d8068",
    mantle: "#463d31",
    ink: "#17130d",
    earth: "#a79771",
    fire: "#c76632",
    charge: "#d4b84e",
  }),
});

export const OVERHAUL_CHARACTER_VISUAL_STATES = freeze([
  "idle", "move", "commit", "hit", "defend", "defeated",
]);

export function getOverhaulCharacterVisualProfile(characterId) {
  return OVERHAUL_CHARACTER_VISUAL_PROFILES[characterId] ?? null;
}

export function resolveOverhaulCharacterVisualState(entity, cooldowns = {}) {
  if (!entity?.alive) return "defeated";
  if (positive(entity.hitFlash)) return "hit";
  if (positive(entity.defenseRemaining)) return "defend";
  if (
    positive(entity.ultimateWindupRemaining) ||
    insideOpeningWindow(entity.primaryCooldown, cooldowns.primary, 0.075) ||
    insideOpeningWindow(entity.specialCooldown, cooldowns.special, 0.16)
  ) return "commit";
  if (
    Math.hypot(finite(entity.vx), finite(entity.vy)) > 70 ||
    positive(entity.mobilityRemaining) || positive(entity.slideRemaining) || positive(entity.hopRemaining)
  ) return "move";
  return "idle";
}

export function drawOverhaulCharacterAura(context, profile, state, radius, time, reducedMotion) {
  if (!profile || state === "defeated") return;
  if (profile.id === "urzh") {
    drawUrzhAura(context, profile, state, radius, time, reducedMotion);
    return;
  }
  const phase = reducedMotion ? 0 : Math.sin(time * 5) * radius * 0.06;
  context.save();
  try {
    context.shadowBlur = 0;
    context.strokeStyle = profile.wind;
    context.lineCap = "round";
    context.lineJoin = "round";
    if (state === "idle") {
      context.globalAlpha = 0.3;
      context.lineWidth = 1.5;
      openArc(context, -radius * 0.1, -radius * 0.02, radius * 1.12, -0.75, 0.75);
      openArc(context, -radius * 0.2, 0, radius * 1.34, -0.5, 0.5);
    } else if (state === "move") {
      context.globalAlpha = 0.5;
      context.lineWidth = 2;
      for (const side of [-1, 1]) {
        context.beginPath();
        context.moveTo(-radius * 0.3, side * radius * 0.45);
        context.quadraticCurveTo(-radius * 0.95, side * (radius * 0.65 + phase), -radius * 1.55, side * radius * 0.28);
        context.stroke();
      }
    } else if (state === "commit") {
      context.globalAlpha = 0.75;
      context.lineWidth = 2.5;
      for (const side of [-1, 0, 1]) {
        context.beginPath();
        context.moveTo(radius * 0.45, side * radius * 0.34);
        context.lineTo(radius * 1.38, side * radius * 0.62);
        context.stroke();
      }
    } else if (state === "hit") {
      context.globalAlpha = 0.9;
      context.lineWidth = 2;
      for (let index = 0; index < 4; index += 1) {
        const angle = Math.PI / 4 + (index * Math.PI) / 2;
        context.beginPath();
        context.moveTo(Math.cos(angle) * radius * 0.7, Math.sin(angle) * radius * 0.7);
        context.lineTo(Math.cos(angle) * radius * 1.25, Math.sin(angle) * radius * 1.25);
        context.stroke();
      }
    } else if (state === "defend") {
      context.globalAlpha = 0.84;
      context.lineWidth = 3;
      context.beginPath();
      context.moveTo(radius * 0.4, -radius * 0.9);
      context.quadraticCurveTo(radius * 1.45, 0, radius * 0.4, radius * 0.9);
      context.stroke();
      context.beginPath();
      context.moveTo(radius * 0.62, 0);
      context.lineTo(radius * 1.12, -radius * 0.22);
      context.moveTo(radius * 0.62, 0);
      context.lineTo(radius * 1.12, radius * 0.22);
      context.stroke();
    }
  } finally {
    context.restore();
  }
}

export function traceOverhaulCharacterBody(context, profile, radius) {
  if (!profile) return false;
  if (profile.id === "urzh") {
    tracePolygon(context, [
      [radius * 0.92, -radius * 0.56], [radius * 1.12, 0], [radius * 0.92, radius * 0.56],
      [radius * 0.34, radius * 0.92], [-radius * 0.7, radius * 0.78],
      [-radius * 0.96, radius * 0.42], [-radius * 0.96, -radius * 0.42],
      [-radius * 0.7, -radius * 0.78], [radius * 0.34, -radius * 0.92],
    ]);
    return true;
  }
  if (profile.id !== "aerwyn") return false;
  tracePolygon(context, [
    [radius * 1.2, 0], [radius * 0.42, radius * 0.52], [radius * 0.06, radius * 0.88],
    [-radius * 0.28, radius * 0.62], [-radius * 0.92, radius * 0.78], [-radius * 0.68, 0],
    [-radius * 0.92, -radius * 0.78], [-radius * 0.28, -radius * 0.62],
    [radius * 0.06, -radius * 0.88], [radius * 0.42, -radius * 0.52],
  ]);
  return true;
}

export function drawOverhaulCharacterDetails(context, profile, state, radius, team, teamColor, healthRatio) {
  if (!profile) return;
  if (profile.id === "urzh") {
    drawUrzhDetails(context, profile, state, radius, team, teamColor, healthRatio);
    return;
  }
  if (profile.id !== "aerwyn") return;
  context.save();
  try {
    context.shadowBlur = 0;
    context.lineCap = "round";
    context.lineJoin = "round";

    // Swept horns and a hooked tail communicate Demon before color or text.
    context.fillStyle = profile.ink;
    context.strokeStyle = profile.light;
    context.lineWidth = 1.4;
    for (const side of [-1, 1]) {
      context.beginPath();
      context.moveTo(-radius * 0.18, side * radius * 0.48);
      context.quadraticCurveTo(-radius * 0.68, side * radius * 0.9, -radius * 0.3, side * radius * 1.15);
      context.lineTo(radius * 0.18, side * radius * 0.62);
      context.closePath();
      context.fill();
      context.stroke();
    }
    context.strokeStyle = profile.ember;
    context.lineWidth = 2.4;
    context.beginPath();
    context.moveTo(-radius * 0.55, radius * 0.18);
    context.quadraticCurveTo(-radius * 1.22, radius * 0.72, -radius * 0.78, radius * 1.2);
    context.lineTo(-radius * 0.55, radius * 0.98);
    context.stroke();

    // Earth-weighted mantle keeps the center readable beneath the Wind aura.
    context.fillStyle = profile.mantle;
    context.strokeStyle = profile.ink;
    context.lineWidth = 1.5;
    tracePolygon(context, [[-radius * 0.08, -radius * 0.52], [radius * 0.62, 0], [-radius * 0.08, radius * 0.52], [-radius * 0.5, 0]]);
    context.fill();
    context.stroke();

    // A single Light focus prop supplies aim direction without becoming a tell.
    context.fillStyle = profile.light;
    context.beginPath();
    context.moveTo(radius * 0.48, 0);
    context.lineTo(radius * 0.18, radius * 0.24);
    context.lineTo(-radius * 0.08, 0);
    context.lineTo(radius * 0.18, -radius * 0.24);
    context.closePath();
    context.fill();
    context.stroke();

    drawTeamShape(context, team, teamColor, radius);
    drawHealthWear(context, profile.ink, radius, healthRatio);
    if (state === "commit") {
      context.strokeStyle = profile.light;
      context.lineWidth = 2;
      context.beginPath();
      context.moveTo(radius * 0.82, -radius * 0.28);
      context.lineTo(radius * 1.16, 0);
      context.lineTo(radius * 0.82, radius * 0.28);
      context.stroke();
    }
  } finally {
    context.restore();
  }
}

export function drawOverhaulCharacterDefeat(context, profile, radius, teamColor) {
  if (!profile) return false;
  if (profile.id === "urzh") return drawUrzhDefeat(context, profile, radius, teamColor);
  if (profile.id !== "aerwyn") return false;
  context.save();
  try {
    context.globalAlpha = 0.58;
    context.strokeStyle = teamColor;
    context.fillStyle = profile.ink;
    context.lineWidth = 2;
    context.translate(0, radius * 0.28);
    context.scale(1.12, 0.48);
    tracePolygon(context, [[radius * 0.95, 0], [0, radius * 0.72], [-radius * 0.86, 0], [0, -radius * 0.72]]);
    context.fill();
    context.stroke();
    context.strokeStyle = profile.wind;
    context.beginPath();
    context.moveTo(-radius * 0.48, -radius * 0.5);
    context.lineTo(radius * 0.46, radius * 0.5);
    context.stroke();
  } finally {
    context.restore();
  }
  return true;
}

function drawUrzhAura(context, profile, state, radius, time, reducedMotion) {
  const pulse = reducedMotion ? 0 : Math.sin(time * 5) * radius * 0.08;
  context.save();
  try {
    context.shadowBlur = 0;
    context.lineCap = "square";
    if (state === "idle") {
      context.strokeStyle = profile.earth;
      context.globalAlpha = 0.34;
      context.lineWidth = 3;
      for (const side of [-1, 1]) {
        context.beginPath();
        context.moveTo(-radius * 0.8, side * radius * 0.9);
        context.lineTo(radius * 0.55, side * radius * 0.9);
        context.stroke();
      }
    } else if (state === "move") {
      context.strokeStyle = profile.fire;
      context.globalAlpha = 0.54;
      context.lineWidth = 2.5;
      for (const side of [-1, 1]) {
        context.beginPath();
        context.moveTo(-radius * 0.72, side * radius * 0.48);
        context.lineTo(-radius * 1.32 - pulse, side * radius * 0.62);
        context.lineTo(-radius * 1.08, side * radius * 0.3);
        context.stroke();
      }
    } else if (state === "commit") {
      context.strokeStyle = profile.charge;
      context.globalAlpha = 0.82;
      context.lineWidth = 2.4;
      for (const side of [-1, 1]) {
        context.beginPath();
        context.moveTo(radius * 0.54, side * radius * 0.5);
        context.lineTo(radius * 0.92, side * radius * 0.28);
        context.lineTo(radius * 0.74, side * radius * 0.05);
        context.lineTo(radius * 1.38, 0);
        context.stroke();
      }
    } else if (state === "hit") {
      context.strokeStyle = profile.fire;
      context.globalAlpha = 0.9;
      context.lineWidth = 2;
      for (const side of [-1, 1]) {
        context.beginPath();
        context.moveTo(-radius * 0.1, side * radius * 0.66);
        context.lineTo(radius * 0.18, side * radius * 1.26);
        context.stroke();
      }
    } else if (state === "defend") {
      context.strokeStyle = profile.earth;
      context.globalAlpha = 0.88;
      context.lineWidth = 4;
      context.beginPath();
      context.moveTo(radius * 0.68, -radius * 1.05);
      context.lineTo(radius * 1.24, -radius * 0.66);
      context.lineTo(radius * 1.24, radius * 0.66);
      context.lineTo(radius * 0.68, radius * 1.05);
      context.stroke();
    }
  } finally {
    context.restore();
  }
}

function drawUrzhDetails(context, profile, state, radius, team, teamColor, healthRatio) {
  context.save();
  try {
    context.shadowBlur = 0;
    context.lineJoin = "bevel";

    // Two block shoulders make Stoneborn ancestry readable without scale changes.
    context.fillStyle = profile.earth;
    context.strokeStyle = profile.ink;
    context.lineWidth = 1.5;
    for (const side of [-1, 1]) {
      tracePolygon(context, [
        [-radius * 0.55, side * radius * 0.28], [-radius * 0.42, side * radius * 0.76],
        [radius * 0.18, side * radius * 0.82], [radius * 0.34, side * radius * 0.38],
      ]);
      context.fill();
      context.stroke();
    }

    // The kiln seam is body wear, never an ability telegraph.
    context.strokeStyle = profile.fire;
    context.lineWidth = 2.3;
    context.beginPath();
    context.moveTo(-radius * 0.52, 0);
    context.lineTo(-radius * 0.12, -radius * 0.18);
    context.lineTo(radius * 0.12, radius * 0.16);
    context.lineTo(radius * 0.48, 0);
    context.stroke();

    // A square buckler gives a single role/facing prop at combat zoom.
    context.fillStyle = profile.mantle;
    context.strokeStyle = profile.charge;
    context.lineWidth = 1.8;
    context.beginPath();
    context.rect(radius * 0.34, -radius * 0.34, radius * 0.54, radius * 0.68);
    context.fill();
    context.stroke();
    context.beginPath();
    context.moveTo(radius * 0.46, 0);
    context.lineTo(radius * 0.76, 0);
    context.stroke();

    drawTeamShape(context, team, teamColor, radius);
    drawHealthWear(context, profile.ink, radius, healthRatio);
    if (state === "commit") {
      context.fillStyle = profile.charge;
      context.fillRect(radius * 0.56, -radius * 0.09, radius * 0.28, radius * 0.18);
    }
  } finally {
    context.restore();
  }
}

function drawUrzhDefeat(context, profile, radius, teamColor) {
  context.save();
  try {
    context.globalAlpha = 0.62;
    context.fillStyle = profile.mantle;
    context.strokeStyle = teamColor;
    context.lineWidth = 2;
    context.translate(0, radius * 0.36);
    tracePolygon(context, [
      [-radius * 1.02, radius * 0.28], [-radius * 0.68, -radius * 0.3],
      [-radius * 0.08, -radius * 0.12], [radius * 0.28, -radius * 0.42],
      [radius * 1.04, radius * 0.22],
    ]);
    context.fill();
    context.stroke();
    context.strokeStyle = profile.fire;
    context.beginPath();
    context.moveTo(-radius * 0.34, 0);
    context.lineTo(radius * 0.34, radius * 0.12);
    context.stroke();
  } finally {
    context.restore();
  }
  return true;
}

function transfer(legacyId, legacyName, overhaulId, overhaulName, retained, retired) {
  return freeze({ legacyId, legacyName, overhaulId, overhaulName, retained, retired, status: "compatibility-only" });
}

function drawTeamShape(context, team, teamColor, radius) {
  context.strokeStyle = teamColor;
  context.lineWidth = 2;
  if (team === "alpha") {
    context.beginPath();
    context.moveTo(-radius * 0.72, -radius * 0.28);
    context.lineTo(-radius * 1.02, 0);
    context.lineTo(-radius * 0.72, radius * 0.28);
    context.stroke();
  } else if (team === "beta") {
    for (const offset of [-0.16, 0.16]) {
      context.beginPath();
      context.moveTo(-radius * 0.96, radius * offset - radius * 0.18);
      context.lineTo(-radius * 0.72, radius * offset + radius * 0.18);
      context.stroke();
    }
  }
}

function drawHealthWear(context, ink, radius, healthRatio) {
  if (healthRatio > 0.5) return;
  context.strokeStyle = ink;
  context.lineWidth = 1.5;
  context.beginPath();
  context.moveTo(-radius * 0.4, -radius * 0.36);
  context.lineTo(-radius * 0.12, -radius * 0.1);
  context.stroke();
  if (healthRatio > 0.25) return;
  context.beginPath();
  context.moveTo(-radius * 0.42, radius * 0.38);
  context.lineTo(-radius * 0.08, radius * 0.12);
  context.stroke();
}

function openArc(context, x, y, radius, start, end) {
  context.beginPath();
  context.arc(x, y, radius, start, end);
  context.stroke();
}

function tracePolygon(context, points) {
  context.beginPath();
  for (const [index, [x, y]] of points.entries()) index === 0 ? context.moveTo(x, y) : context.lineTo(x, y);
  context.closePath();
}

function positive(value) { return Number.isFinite(value) && value > 0; }
function finite(value) { return Number.isFinite(value) ? value : 0; }
function insideOpeningWindow(remaining, cooldown, window) {
  return Number.isFinite(remaining) && Number.isFinite(cooldown) && cooldown > 0 && remaining > Math.max(0, cooldown - window);
}
