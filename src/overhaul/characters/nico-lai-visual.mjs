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
});

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
