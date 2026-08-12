import {
  composeCharacterVisualProfile,
  drawAncestryFeatures,
} from "../../ancestry-visual-templates.mjs";
import {
  drawDiamond,
  drawHealthWear,
  drawTeamShape,
  tracePolygon,
} from "../character-visual-primitives.mjs";
import { PIXEL_PERSPECTIVE } from "../../pixel-perspective.mjs";

export const NICO_LAI_VISUAL = Object.freeze({
  profile: composeCharacterVisualProfile({
    id: "nico",
    runtimeCharacterId: "volt",
    contentCompatibilityId: "nix",
    name: "Nico Lai",
    ancestryId: "gnome",
    ancestryRead: "high cap and tiny measured tool frame",
    roleRead: "precision shared-device engineer",
    affinityRead: "Charge forks and Light calibration diamonds",
    focusProp: "calibrated coil pack",
    deviceRead: "detached breakable coil with an explicit team tether",
    renderer: "pixel-cardinal",
    body: "#a97954",
    mantle: "#55452d",
    leather: "#765a35",
    copper: "#b66f3e",
    ink: "#17130d",
    charge: "#d4b84e",
    light: "#eadcaa",
  }),
  drawAura,
  drawDetails,
  drawDefeat,
  drawPixel: drawNicoPixelSprite,
});

function drawNicoPixelSprite(context, profile, state, radius, team, teamColor, healthRatio, facing) {
  const unit = Math.max(1, Math.round(radius / 18));
  const direction = ["up", "down", "left", "right"].includes(facing) ? facing : "down";
  context.save();
  try {
    context.imageSmoothingEnabled = false;
    context.shadowBlur = 0;
    if (state === "defeated") {
      drawPixelDefeat(context, profile, unit, teamColor);
      drawPixelTeamMark(context, team, teamColor, unit);
      return true;
    }
    if (direction === "left") {
      context.scale(-1, 1);
      drawSideSprite(context, profile, state, unit, teamColor, healthRatio);
    } else if (direction === "right") {
      drawSideSprite(context, profile, state, unit, teamColor, healthRatio);
    } else {
      drawFrontBackSprite(context, profile, state, unit, teamColor, healthRatio, direction === "up");
    }
    drawPixelTeamMark(context, team, teamColor, unit);
  } finally {
    context.restore();
  }
  return true;
}

function drawPixelDefeat(context, profile, unit, teamColor) {
  const ink = PIXEL_PERSPECTIVE.values[0];
  pixel(context, ink, -14, -6, 24, 7, unit);
  pixel(context, profile.leather, -12, -5, 14, 5, unit);
  pixel(context, profile.mantle, -9, -8, 9, 4, unit);
  pixel(context, profile.body, -2, -7, 8, 5, unit);
  pixel(context, profile.copper, 8, -5, 3, 3, unit);
  pixel(context, profile.copper, 12, -2, 3, 3, unit);
  pixel(context, profile.light, 13, -3, 1, 1, unit);
  if (teamColor) pixel(context, teamColor, -10, 0, 18, 1, unit);
}

function drawFrontBackSprite(context, profile, state, unit, teamColor, healthRatio, back) {
  const ink = PIXEL_PERSPECTIVE.values[0];
  pixel(context, ink, -5, -17, 10, 16, unit);
  pixel(context, profile.leather, -4, -16, 8, 12, unit);
  pixel(context, profile.mantle, -5, -12, 10, 5, unit);
  pixel(context, ink, -5, -4, 4, 3, unit);
  pixel(context, ink, 1, -4, 4, 3, unit);
  if (state === "move") {
    pixel(context, profile.copper, -5, -4, 3, 3, unit);
    pixel(context, ink, 2, -3, 4, 2, unit);
  }

  pixel(context, ink, -6, -28, 12, 12, unit);
  pixel(context, profile.body, -5, -27, 10, 10, unit);
  pixel(context, profile.mantle, -7, -31, 14, 6, unit);
  pixel(context, profile.copper, -4, -33, 8, 3, unit);
  pixel(context, ink, -6, -25, 12, 2, unit);
  if (back) {
    pixel(context, profile.copper, -3, -22, 6, 6, unit);
    pixel(context, profile.charge, -1, -21, 2, 4, unit);
  } else {
    pixel(context, ink, -3, -23, 2, 2, unit);
    pixel(context, ink, 2, -23, 2, 2, unit);
    pixel(context, profile.light, -1, -19, 2, 1, unit);
  }
  drawPixelDevice(context, profile, state, unit, 7, -13);
  drawPixelStateRead(context, profile, state, unit, back ? -1 : 1);
  drawPixelWear(context, profile, unit, healthRatio);
  if (state === "hit") pixel(context, PIXEL_PERSPECTIVE.values[6], -1, -26, 3, 3, unit);
  if (teamColor) pixel(context, teamColor, -4, -7, 8, 1, unit);
}

function drawSideSprite(context, profile, state, unit, teamColor, healthRatio) {
  const ink = PIXEL_PERSPECTIVE.values[0];
  pixel(context, ink, -5, -17, 10, 16, unit);
  pixel(context, profile.leather, -4, -16, 8, 12, unit);
  pixel(context, profile.mantle, -4, -12, 9, 5, unit);
  pixel(context, ink, -4, -4, 3, 3, unit);
  pixel(context, ink, 2, state === "move" ? -3 : -4, 4, state === "move" ? 2 : 3, unit);
  pixel(context, ink, -6, -28, 12, 12, unit);
  pixel(context, profile.body, -5, -27, 10, 10, unit);
  pixel(context, profile.mantle, -7, -31, 14, 6, unit);
  pixel(context, profile.copper, -4, -33, 8, 3, unit);
  pixel(context, ink, 3, -24, 2, 2, unit);
  pixel(context, profile.light, 5, -21, 1, 2, unit);
  pixel(context, profile.copper, -6, -15, 3, 8, unit);
  pixel(context, profile.charge, -5, -13, 1, 4, unit);
  drawPixelDevice(context, profile, state, unit, state === "commit" ? 10 : 7, -13);
  drawPixelStateRead(context, profile, state, unit, 1);
  drawPixelWear(context, profile, unit, healthRatio);
  if (state === "hit") pixel(context, PIXEL_PERSPECTIVE.values[6], 2, -25, 3, 3, unit);
  if (teamColor) pixel(context, teamColor, -4, -7, 8, 1, unit);
}

function drawPixelDevice(context, profile, state, unit, x, y) {
  const ink = PIXEL_PERSPECTIVE.values[0];
  if (state === "hit") {
    pixel(context, ink, x, y, 3, 3, unit);
    pixel(context, profile.copper, x + 1, y, 2, 2, unit);
    pixel(context, ink, x + 4, y + 3, 3, 3, unit);
    pixel(context, profile.light, x + 4, y + 4, 2, 1, unit);
    return;
  }
  pixel(context, ink, x, y, 6, 7, unit);
  pixel(context, profile.copper, x + 1, y + 1, 4, 5, unit);
  pixel(context, profile.charge, x + 2, y + 2, 2, 3, unit);
  pixel(context, profile.light, x + 2, y, 2, 1, unit);
  if (state === "commit") {
    pixel(context, profile.charge, x + 6, y + 1, 4, 1, unit);
    pixel(context, profile.charge, x + 8, y - 1, 1, 5, unit);
    pixel(context, profile.light, x + 10, y, 2, 2, unit);
  }
}

function drawPixelStateRead(context, profile, state, unit, forward) {
  if (state === "idle") {
    pixel(context, profile.light, -1, -36, 2, 2, unit);
  } else if (state === "move") {
    pixel(context, profile.charge, -9 * forward, -8, 4 * forward, 1, unit);
    pixel(context, profile.charge, -11 * forward, -5, 3 * forward, 1, unit);
  } else if (state === "defend") {
    const x = 8 * forward;
    pixel(context, profile.light, x, -22, 2 * forward, 14, unit);
    pixel(context, profile.light, x, -22, 5 * forward, 2, unit);
    pixel(context, profile.light, x, -10, 5 * forward, 2, unit);
  }
}

function drawPixelWear(context, profile, unit, healthRatio) {
  if (healthRatio >= 0.58) return;
  pixel(context, profile.ink, -3, -14, 3, 1, unit);
  if (healthRatio < 0.3) {
    pixel(context, profile.ink, 1, -10, 3, 1, unit);
    pixel(context, profile.ink, -2, -26, 1, 3, unit);
  }
}

function drawPixelTeamMark(context, team, teamColor, unit) {
  if (!teamColor) return;
  if (team === "alpha") {
    pixel(context, teamColor, -3, 1, 6, 1, unit);
    pixel(context, teamColor, -1, 0, 2, 1, unit);
  } else {
    pixel(context, teamColor, -3, 0, 6, 1, unit);
    pixel(context, teamColor, -1, 1, 2, 1, unit);
  }
}

function pixel(context, color, x, y, width, height, unit) {
  const left = Math.min(x, x + width) * unit;
  const top = Math.min(y, y + height) * unit;
  context.fillStyle = color;
  context.fillRect(left, top, Math.abs(width) * unit, Math.abs(height) * unit);
}

function drawAura(context, profile, state, radius, time, reducedMotion) {
  const pulse = reducedMotion ? 0 : Math.sin(time * 5.6) * radius * 0.05;
  context.save();
  try {
    context.shadowBlur = 0;
    context.lineCap = "square";
    context.lineJoin = "bevel";
    if (state === "idle") {
      context.globalAlpha = 0.46;
      context.strokeStyle = profile.charge;
      context.lineWidth = 1.8;
      drawFork(context, -radius * 0.42, -radius * 0.58, radius * 0.54, -1);
      drawFork(context, -radius * 0.42, radius * 0.58, radius * 0.54, 1);
      context.strokeStyle = profile.light;
      context.lineWidth = 1.4;
      drawCalibrationDiamond(context, radius * 1.14, 0, radius * 0.18);
    } else if (state === "move") {
      context.globalAlpha = 0.58;
      context.lineWidth = 2;
      for (const side of [-1, 1]) {
        context.strokeStyle = profile.charge;
        context.beginPath();
        context.moveTo(-radius * 0.72, side * radius * 0.34);
        context.lineTo(-radius * 1.02 - pulse, side * radius * 0.34);
        context.moveTo(-radius * 1.18 - pulse, side * radius * 0.34);
        context.lineTo(-radius * 1.52, side * radius * 0.34);
        context.stroke();
      }
      context.strokeStyle = profile.light;
      context.lineWidth = 1.4;
      context.beginPath();
      context.moveTo(-radius * 0.68, 0);
      context.lineTo(-radius * 1.42, 0);
      context.stroke();
    } else if (state === "commit") {
      context.globalAlpha = 0.84;
      context.strokeStyle = profile.charge;
      context.lineWidth = 2.3;
      drawFork(context, radius * 0.66, -radius * 0.34, radius * 0.82, -1);
      drawFork(context, radius * 0.66, radius * 0.34, radius * 0.82, 1);
      context.strokeStyle = profile.light;
      context.lineWidth = 2;
      drawCalibrationDiamond(context, radius * 1.46, 0, radius * 0.42);
    } else if (state === "hit") {
      context.globalAlpha = 0.92;
      context.strokeStyle = profile.charge;
      context.lineWidth = 2;
      for (const side of [-1, 1]) {
        context.beginPath();
        context.moveTo(radius * 0.46, side * radius * 0.16);
        context.lineTo(radius * 0.9, side * radius * 0.72);
        context.moveTo(radius * 0.72, side * radius * 0.08);
        context.lineTo(radius * 1.18, side * radius * 0.46);
        context.stroke();
      }
    } else if (state === "defend") {
      context.globalAlpha = 0.88;
      context.strokeStyle = profile.light;
      context.lineWidth = 3;
      context.beginPath();
      context.moveTo(radius * 0.62, -radius * 0.96);
      context.lineTo(radius * 1.28, -radius * 0.58);
      context.lineTo(radius * 1.28, radius * 0.58);
      context.lineTo(radius * 0.62, radius * 0.96);
      context.stroke();
      context.strokeStyle = profile.charge;
      context.lineWidth = 1.8;
      drawFork(context, radius * 0.66, 0, radius * 0.54, 1);
    }
  } finally {
    context.restore();
  }
}

function drawDetails(context, profile, state, radius, team, teamColor, healthRatio) {
  context.save();
  try {
    context.shadowBlur = 0;
    context.lineCap = "round";
    context.lineJoin = "bevel";

    drawAncestryFeatures(context, profile, radius);

    context.fillStyle = profile.leather;
    context.strokeStyle = profile.ink;
    context.lineWidth = 1.5;
    tracePolygon(context, [
      [-radius * 0.5, -radius * 0.44],
      [radius * 0.42, -radius * 0.5],
      [radius * 0.62, 0],
      [radius * 0.42, radius * 0.5],
      [-radius * 0.5, radius * 0.44],
    ]);
    context.fill();
    context.stroke();

    drawCoilPack(context, profile, radius);
    drawSharedDevice(context, profile, state, radius, teamColor);
    drawTeamShape(context, team, teamColor, radius);
    drawHealthWear(context, profile.ink, radius, healthRatio);
  } finally {
    context.restore();
  }
}

function drawCoilPack(context, profile, radius) {
  context.fillStyle = profile.mantle;
  context.strokeStyle = profile.copper;
  context.lineWidth = 1.7;
  context.beginPath();
  context.rect(
    -radius * 0.56,
    -radius * 0.36,
    radius * 0.38,
    radius * 0.72,
  );
  context.fill();
  context.stroke();
  context.strokeStyle = profile.charge;
  context.beginPath();
  context.arc(-radius * 0.36, 0, radius * 0.13, 0, Math.PI * 2);
  context.stroke();
  context.beginPath();
  context.moveTo(-radius * 0.49, 0);
  context.lineTo(-radius * 0.23, 0);
  context.stroke();
}

function drawSharedDevice(context, profile, state, radius, teamColor) {
  const deviceX = state === "commit" ? radius * 1.04 : radius * 0.78;
  const deviceRadius = radius * 0.21;

  context.strokeStyle = teamColor;
  context.lineWidth = 1.6;
  if (state !== "hit") {
    context.beginPath();
    context.moveTo(radius * 0.32, 0);
    context.lineTo(deviceX - deviceRadius, 0);
    context.stroke();
  } else {
    context.beginPath();
    context.moveTo(radius * 0.32, 0);
    context.lineTo(radius * 0.52, 0);
    context.moveTo(radius * 0.7, 0);
    context.lineTo(deviceX - deviceRadius, 0);
    context.stroke();
  }

  context.fillStyle = profile.copper;
  context.strokeStyle = profile.light;
  context.lineWidth = 1.7;
  if (state === "hit") {
    drawDeviceHalf(
      context,
      deviceX - deviceRadius * 0.28,
      -deviceRadius * 0.45,
      deviceRadius,
      -1,
    );
    drawDeviceHalf(
      context,
      deviceX + deviceRadius * 0.28,
      deviceRadius * 0.45,
      deviceRadius,
      1,
    );
  } else {
    drawDiamond(context, deviceX, 0, deviceRadius, deviceRadius);
    context.fill();
    context.stroke();
    context.strokeStyle = profile.charge;
    context.beginPath();
    context.arc(deviceX, 0, deviceRadius * 0.45, 0, Math.PI * 2);
    context.stroke();
  }

  if (state === "commit") {
    context.strokeStyle = profile.light;
    context.lineWidth = 1.6;
    drawCalibrationDiamond(
      context,
      deviceX + radius * 0.34,
      0,
      radius * 0.18,
    );
  }
}

function drawDefeat(context, profile, radius, teamColor) {
  context.save();
  try {
    context.globalAlpha = 0.62;
    context.translate(0, radius * 0.34);
    context.scale(1.16, 0.48);
    context.fillStyle = profile.leather;
    context.strokeStyle = teamColor;
    context.lineWidth = 2;
    tracePolygon(context, [
      [-radius * 0.92, radius * 0.12],
      [-radius * 0.58, -radius * 0.54],
      [radius * 0.42, -radius * 0.38],
      [radius * 0.92, radius * 0.16],
      [radius * 0.14, radius * 0.48],
    ]);
    context.fill();
    context.stroke();
    context.fillStyle = profile.mantle;
    context.strokeStyle = profile.ink;
    tracePolygon(context, [
      [-radius * 0.52, -radius * 0.12],
      [-radius * 0.2, -radius * 0.78],
      [radius * 0.16, -radius * 0.2],
    ]);
    context.fill();
    context.stroke();
    context.strokeStyle = profile.light;
    drawDeviceHalf(context, radius * 0.72, -radius * 0.34, radius * 0.24, -1);
    drawDeviceHalf(context, radius * 1.02, radius * 0.28, radius * 0.24, 1);
  } finally {
    context.restore();
  }
  return true;
}

function drawFork(context, x, y, length, side) {
  context.beginPath();
  context.moveTo(x, y);
  context.lineTo(x + length * 0.42, y + length * 0.1 * side);
  context.lineTo(x + length * 0.68, y - length * 0.14 * side);
  context.lineTo(x + length, y);
  context.moveTo(x + length * 0.42, y + length * 0.1 * side);
  context.lineTo(x + length * 0.72, y + length * 0.34 * side);
  context.stroke();
}

function drawCalibrationDiamond(context, x, y, size) {
  context.beginPath();
  context.moveTo(x + size, y);
  context.lineTo(x, y + size);
  context.lineTo(x - size, y);
  context.lineTo(x, y - size);
  context.closePath();
  context.stroke();
}

function drawDeviceHalf(context, x, y, size, side) {
  context.beginPath();
  context.moveTo(x, y - size);
  context.lineTo(x + size * side, y);
  context.lineTo(x, y + size);
  context.closePath();
  context.fill();
  context.stroke();
}
