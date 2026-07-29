import { PIXEL_PERSPECTIVE } from "./pixel-perspective.mjs";

export const NICO_SPELL_VISUALS = Object.freeze({
  coilDart: Object.freeze({ anticipation: "paired-contact", travel: "forked-dart", impact: "split-calibration", expiry: "short-tail" }),
  arcChain: Object.freeze({ anticipation: "open-prongs", travel: "stepped-line", impact: "interrupt-bracket", expiry: "broken-segments" }),
  prismGround: Object.freeze({ anticipation: "four-corners", travel: "fixed-plane", impact: "inward-diamond", expiry: "receding-corners" }),
  coilHop: Object.freeze({ anticipation: "coil-compress", travel: "segmented-charge", impact: "feet-calibration", expiry: "device-spark" }),
});

export function validateNicoSpellVisuals() {
  const errors = [];
  for (const [name, phases] of Object.entries(NICO_SPELL_VISUALS)) {
    for (const phase of ["anticipation", "travel", "impact", "expiry"]) {
      if (!phases[phase]) errors.push(`${name}:${phase}`);
    }
  }
  return errors;
}

export function drawNicoCoilDart(context, projectile, teamColor) {
  if (!projectile || projectile.ownerCharacterId !== "volt") return false;
  const length = projectile.heavy ? 20 : 16;
  const magnitude = Math.hypot(projectile.vx, projectile.vy) || 1;
  const dx = projectile.vx / magnitude;
  const dy = projectile.vy / magnitude;
  const sideX = -dy;
  const sideY = dx;
  const charge = PIXEL_PERSPECTIVE.materials.charge;
  context.save();
  context.imageSmoothingEnabled = false;
  context.fillStyle = PIXEL_PERSPECTIVE.values[0];
  pixelAt(context, -dx * 2 - sideX * 5, -dy * 2 - sideY * 5, 8, 8);
  context.fillStyle = charge[2];
  pixelAt(context, -dx * 3, -dy * 3, 6, 6);
  context.fillStyle = charge[3];
  pixelAt(context, dx * 2, dy * 2, 4, 4);
  context.fillStyle = teamColor;
  for (const side of [-1, 1]) {
    pixelAt(context, -dx * 7 + sideX * side * 4, -dy * 7 + sideY * side * 4, 4, 4);
    pixelAt(context, -dx * length + sideX * side * 6, -dy * length + sideY * side * 6, 6, 3);
  }
  context.restore();
  return true;
}

function pixelAt(context, x, y, width, height) {
  const step = 2;
  const left = Math.round((x - width / 2) / step) * step;
  const top = Math.round((y - height / 2) / step) * step;
  context.fillRect(left, top, Math.max(step, Math.round(width / step) * step), Math.max(step, Math.round(height / step) * step));
}
