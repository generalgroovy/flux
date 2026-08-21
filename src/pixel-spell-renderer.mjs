import { PIXEL_PERSPECTIVE } from "./pixel-perspective.mjs";

const NICO_RUNTIME_ID = "volt";
const PIXEL_STEP = 2;

export const NICO_SPELL_VISUALS = Object.freeze({
  coilDart: Object.freeze({
    element: "charge",
    anticipation: "paired-contact",
    travel: "forked-dart",
    impact: "split-calibration",
    expiry: "short-tail",
  }),
  arcChain: Object.freeze({
    element: "charge",
    anticipation: "open-prongs",
    travel: "stepped-line",
    impact: "interrupt-bracket",
    expiry: "broken-segments",
  }),
  prismGround: Object.freeze({
    element: "light",
    anticipation: "four-corners",
    travel: "fixed-plane",
    impact: "inward-diamond",
    expiry: "receding-corners",
  }),
  coilHop: Object.freeze({
    element: "charge",
    anticipation: "coil-compress",
    travel: "segmented-charge",
    impact: "feet-calibration",
    expiry: "device-spark",
  }),
});

export function validateNicoSpellVisuals() {
  const errors = [];
  const reads = new Set();
  for (const [name, phases] of Object.entries(NICO_SPELL_VISUALS)) {
    if (!["charge", "light"].includes(phases.element)) errors.push(`${name}:element`);
    for (const phase of ["anticipation", "travel", "impact", "expiry"]) {
      if (!phases[phase]) errors.push(`${name}:${phase}`);
      else if (reads.has(phases[phase])) errors.push(`${name}:${phase}:duplicate`);
      else reads.add(phases[phase]);
    }
  }
  return errors;
}

export function createNicoSpellCue(event, actor, teamColor) {
  if (!event || actor?.characterId !== NICO_RUNTIME_ID) return null;
  const base = {
    entityId: actor.id ?? null,
    x: finite(event.x, actor.x),
    y: finite(event.y, actor.y),
    dx: finite(actor.facingX, 1),
    dy: finite(actor.facingY, 0),
    endX: finite(event.endX, event.x),
    endY: finite(event.endY, event.y),
    teamColor: validColor(teamColor) ? teamColor : PIXEL_PERSPECTIVE.values[6],
  };

  if (event.type === "shot" && event.source === "primary") {
    return cue(base, "coilDart", "anticipation", 0.11);
  }
  if (event.type === "rail") {
    return cue(base, "arcChain", "sequence", 0.24);
  }
  if (event.type === "defense" && event.kind === "absorb") {
    return cue(base, "prismGround", "anticipation", 0.18);
  }
  if (event.type === "mobility" && event.kind === "dash") {
    return cue(base, "coilHop", "anticipation", 0.28);
  }
  if (event.type === "hit" && event.source === "primary") {
    return cue(base, "coilDart", "impact", 0.16);
  }
  if (event.type === "hit" && event.source === "rail") {
    return cue(base, "arcChain", "impact", 0.18);
  }
  if (event.type === "absorb") {
    return cue(base, "prismGround", "impact", 0.22);
  }
  if (event.type === "dashImpact") {
    return cue(base, "coilHop", "impact", 0.18);
  }
  return null;
}

export function drawNicoCoilDart(context, projectile, teamColor, options = {}) {
  if (!projectile || projectile.ownerCharacterId !== NICO_RUNTIME_ID) return false;
  const direction = normalized(projectile.vx, projectile.vy);
  const sideX = -direction.y;
  const sideY = direction.x;
  const maximumLifetime = Math.max(0.001, finite(projectile.maximumLifetime, projectile.lifetime));
  const lifeRatio = clamp(finite(projectile.lifetime, maximumLifetime) / maximumLifetime, 0, 1);
  const tailRatio = lifeRatio < 0.22 ? lifeRatio / 0.22 : 1;
  const length = (projectile.heavy ? 20 : 16) * tailRatio;
  const charge = PIXEL_PERSPECTIVE.materials.charge;
  const ownerColor = validColor(teamColor) ? teamColor : PIXEL_PERSPECTIVE.values[6];

  context.save();
  context.imageSmoothingEnabled = false;
  context.globalAlpha = options.highContrast ? 1 : 0.96;
  context.fillStyle = PIXEL_PERSPECTIVE.values[0];
  pixelAt(context, -direction.x * 2 - sideX * 5, -direction.y * 2 - sideY * 5, 8, 8);
  context.fillStyle = charge[2];
  pixelAt(context, -direction.x * 3, -direction.y * 3, 6, 6);
  context.fillStyle = options.highContrast ? PIXEL_PERSPECTIVE.values[6] : charge[3];
  pixelAt(context, direction.x * 2, direction.y * 2, 4, 4);
  context.fillStyle = ownerColor;
  for (const side of [-1, 1]) {
    pixelAt(context, -direction.x * 7 + sideX * side * 4, -direction.y * 7 + sideY * side * 4, 4, 4);
    pixelAt(context, -direction.x * length + sideX * side * 6, -direction.y * length + sideY * side * 6, 6, 3);
  }
  context.restore();
  return true;
}

export function drawNicoSpellState(context, entity, teamColor, options = {}) {
  if (!entity || entity.characterId !== NICO_RUNTIME_ID) return false;
  let drawn = false;
  if (entity.defenseRemaining > 0) {
    const duration = Math.max(0.001, finite(options.defenseDuration, entity.defenseRemaining));
    const progress = 1 - clamp(entity.defenseRemaining / duration, 0, 1);
    drawPrismPlane(context, 0, 0, finite(options.defenseRadius, 38), progress, teamColor, options);
    drawn = true;
  }
  if (entity.mobilityRemaining > 0) {
    const duration = Math.max(0.001, finite(options.mobilityDuration, entity.mobilityRemaining));
    const progress = 1 - clamp(entity.mobilityRemaining / duration, 0, 1);
    drawCoilHopTrail(
      context,
      normalized(entity.mobilityX, entity.mobilityY),
      progress,
      teamColor,
      options,
    );
    drawn = true;
  }
  return drawn;
}

export function drawNicoSpellCue(context, visual, options = {}) {
  if (!visual || !NICO_SPELL_VISUALS[visual.kind]) return false;
  const progress = 1 - clamp(visual.life / Math.max(0.001, visual.maximumLife), 0, 1);
  const actor = options.actor;
  const x = visual.kind === "coilHop" && actor ? finite(actor.x, visual.x) : visual.x;
  const y = visual.kind === "coilHop" && actor ? finite(actor.y, visual.y) : visual.y;
  const direction = normalized(visual.dx, visual.dy);

  context.save();
  context.imageSmoothingEnabled = false;
  context.translate(x, y);
  if (visual.kind === "coilDart") {
    drawCoilDartCue(context, direction, progress, visual.phase, visual.teamColor, options);
  } else if (visual.kind === "arcChain") {
    drawArcChainCue(context, visual, progress, options);
  } else if (visual.kind === "prismGround") {
    drawPrismPlane(context, 0, 0, 38, progress, visual.teamColor, options, visual.phase === "impact");
  } else if (visual.kind === "coilHop") {
    drawCoilHopCue(context, direction, progress, visual.phase, visual.teamColor, options);
  }
  context.restore();
  return true;
}

function drawCoilDartCue(context, direction, progress, phase, teamColor, options) {
  const charge = PIXEL_PERSPECTIVE.materials.charge;
  const extent = phase === "impact" ? 11 - progress * 5 : 5 + progress * 7;
  context.globalAlpha = 1 - progress * 0.7;
  context.fillStyle = options.highContrast ? PIXEL_PERSPECTIVE.values[6] : charge[3];
  for (const side of [-1, 1]) {
    const sideX = -direction.y * side;
    const sideY = direction.x * side;
    pixelAt(context, direction.x * 5 + sideX * extent, direction.y * 5 + sideY * extent, 5, 3);
    pixelAt(context, direction.x * 9 + sideX * (extent - 4), direction.y * 9 + sideY * (extent - 4), 3, 5);
  }
  context.fillStyle = teamColor;
  pixelAt(context, 0, 0, phase === "impact" ? 8 : 4, phase === "impact" ? 8 : 4);
}

function drawArcChainCue(context, visual, progress, options) {
  const charge = PIXEL_PERSPECTIVE.materials.charge;
  const endX = visual.endX - visual.x;
  const endY = visual.endY - visual.y;
  const distance = Math.max(1, Math.hypot(endX, endY));
  const direction = normalized(endX, endY);
  const sideX = -direction.y;
  const sideY = direction.x;
  const reveal = visual.phase === "impact" ? 1 : clamp(progress / 0.42, 0.12, 1);
  const visibleDistance = distance * reveal;
  const expiry = visual.phase === "impact" ? 0 : clamp((progress - 0.58) / 0.42, 0, 1);
  context.globalAlpha = visual.phase === "impact" ? 1 - progress * 0.72 : 1 - expiry * 0.7;
  context.fillStyle = options.highContrast ? PIXEL_PERSPECTIVE.values[6] : charge[3];

  for (let offset = 12; offset < visibleDistance; offset += 12) {
    const segment = Math.floor(offset / 12);
    if (expiry > 0 && (segment % 4) / 4 < expiry) continue;
    const alternating = segment % 2 === 0 ? 1 : -1;
    pixelAt(
      context,
      direction.x * offset + sideX * alternating * 3,
      direction.y * offset + sideY * alternating * 3,
      9,
      3,
    );
  }
  context.fillStyle = visual.teamColor;
  pixelAt(context, sideX * 7, sideY * 7, 7, 3);
  pixelAt(context, -sideX * 7, -sideY * 7, 7, 3);

  if (reveal > 0.82 || visual.phase === "impact") {
    const bracketX = direction.x * distance;
    const bracketY = direction.y * distance;
    context.fillStyle = options.highContrast ? PIXEL_PERSPECTIVE.values[6] : charge[2];
    for (const side of [-1, 1]) {
      pixelAt(context, bracketX + sideX * side * 9, bracketY + sideY * side * 9, 4, 12);
      pixelAt(context, bracketX + sideX * side * 5 - direction.x * 5, bracketY + sideY * side * 5 - direction.y * 5, 8, 3);
    }
  }
}

function drawPrismPlane(context, x, y, radius, progress, teamColor, options, impact = false) {
  const light = PIXEL_PERSPECTIVE.materials.light;
  const ownerColor = validColor(teamColor) ? teamColor : PIXEL_PERSPECTIVE.values[6];
  const reducedProgress = options.reducedMotion ? 0.5 : progress;
  const extent = impact
    ? radius * (0.85 - reducedProgress * 0.42)
    : radius * (0.72 + Math.min(reducedProgress, 0.5) * 0.34);
  context.save();
  context.translate(x, y);
  context.globalAlpha = impact ? 1 - progress * 0.68 : 0.84;
  context.fillStyle = options.highContrast ? PIXEL_PERSPECTIVE.values[6] : light[3];
  for (const [sx, sy] of [[-1, -1], [1, -1], [1, 1], [-1, 1]]) {
    pixelAt(context, sx * extent, sy * extent * 0.55, 8, 3);
    pixelAt(context, sx * extent, sy * extent * 0.55, 3, 8);
  }
  context.fillStyle = light[1];
  pixelAt(context, 0, -extent * 0.55, 5, 5);
  pixelAt(context, extent, 0, 5, 5);
  pixelAt(context, 0, extent * 0.55, 5, 5);
  pixelAt(context, -extent, 0, 5, 5);
  context.fillStyle = ownerColor;
  pixelAt(context, 0, extent * 0.72, 12, 3);
  context.restore();
}

function drawCoilHopTrail(context, direction, progress, teamColor, options) {
  const charge = PIXEL_PERSPECTIVE.materials.charge;
  const sideX = -direction.y;
  const sideY = direction.x;
  const cadence = options.reducedMotion ? 0 : Math.floor(progress * 4) % 2;
  context.globalAlpha = 0.78;
  for (let index = 1; index <= 4; index += 1) {
    const offset = 7 + index * 7;
    const side = (index + cadence) % 2 === 0 ? 1 : -1;
    context.fillStyle = index === 4 ? teamColor : charge[Math.min(3, 1 + index % 3)];
    pixelAt(context, -direction.x * offset + sideX * side * 4, -direction.y * offset + sideY * side * 4, 7, 3);
  }
}

function drawCoilHopCue(context, direction, progress, phase, teamColor, options) {
  if (phase !== "impact" && progress < 0.55) {
    drawCoilHopTrail(context, direction, progress, teamColor, options);
    context.fillStyle = PIXEL_PERSPECTIVE.materials.charge[3];
    pixelAt(context, -direction.x * 5, -direction.y * 5, 9 - progress * 5, 7 - progress * 3);
    return;
  }
  const charge = PIXEL_PERSPECTIVE.materials.charge;
  context.globalAlpha = 1 - Math.max(0, progress - 0.35) * 1.35;
  for (let index = 0; index < 6; index += 1) {
    const angle = (index / 6) * Math.PI * 2;
    const distance = 5 + progress * 16;
    context.fillStyle = index % 2 === 0 ? charge[3] : teamColor;
    pixelAt(context, Math.cos(angle) * distance, Math.sin(angle) * distance * 0.58, 4, 4);
  }
}

function cue(base, kind, phase, maximumLife) {
  return { ...base, kind, phase, life: maximumLife, maximumLife };
}

function pixelAt(context, x, y, width, height) {
  const left = Math.round((finite(x) - finite(width) / 2) / PIXEL_STEP) * PIXEL_STEP;
  const top = Math.round((finite(y) - finite(height) / 2) / PIXEL_STEP) * PIXEL_STEP;
  context.fillRect(
    left,
    top,
    Math.max(PIXEL_STEP, Math.round(Math.max(0, finite(width)) / PIXEL_STEP) * PIXEL_STEP),
    Math.max(PIXEL_STEP, Math.round(Math.max(0, finite(height)) / PIXEL_STEP) * PIXEL_STEP),
  );
}

function normalized(x, y) {
  const safeX = finite(x);
  const safeY = finite(y);
  const magnitude = Math.hypot(safeX, safeY);
  return magnitude > 0.0001 ? { x: safeX / magnitude, y: safeY / magnitude } : { x: 1, y: 0 };
}

function finite(value, fallback = 0) {
  return Number.isFinite(value) ? value : Number.isFinite(fallback) ? fallback : 0;
}

function clamp(value, minimum, maximum) {
  return Math.max(minimum, Math.min(maximum, finite(value, minimum)));
}

function validColor(value) {
  return typeof value === "string" && /^#[0-9a-f]{3,8}$/i.test(value);
}
