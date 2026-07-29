import {
  composeCharacterVisualProfile,
  drawAncestryFeatures,
} from "../../ancestry-visual-templates.mjs";
import {
  drawDiamond,
  drawHealthWear,
  drawSplitRing,
  drawTeamShape,
  tracePolygon,
} from "../character-visual-primitives.mjs";

export const S_WAYNE_VISUAL = Object.freeze({
  profile: composeCharacterVisualProfile({
    id: "samwise",
    name: "S. Wayne",
    ancestryId: "hobbit",
    ancestryRead: "bare feet and low split mantle",
    roleRead: "quiet eclipse-boundary tactician",
    affinityRead: "Dark inward crescents, Light waystone and hard boundary",
    focusProp: "eclipse waystone",
    body: "#b9825f",
    hair: "#2b211b",
    mantle: "#342942",
    ink: "#17130d",
    dark: "#8469ad",
    light: "#e1c462",
  }),
  drawAura,
  drawDetails,
  drawDefeat,
});

function drawAura(context, profile, state, radius, time, reducedMotion) {
  const pulse = reducedMotion ? 0 : Math.sin(time * 4.4) * radius * 0.05;
  context.save();
  try {
    context.shadowBlur = 0;
    context.lineCap = "round";
    context.lineJoin = "round";
    if (state === "idle") {
      context.globalAlpha = 0.48;
      context.lineWidth = 2;
      context.strokeStyle = profile.dark;
      context.beginPath();
      context.arc(-radius * 0.08, 0, radius * 1.08, -1.08, 1.08);
      context.stroke();
      context.strokeStyle = profile.light;
      context.beginPath();
      context.arc(-radius * 0.08, 0, radius * 1.08, Math.PI - 1.08, Math.PI + 1.08);
      context.stroke();
    } else if (state === "move") {
      context.globalAlpha = 0.58;
      context.lineWidth = 2.2;
      context.strokeStyle = profile.dark;
      context.beginPath();
      context.moveTo(-radius * 0.45, -radius * 0.34);
      context.quadraticCurveTo(
        -radius * 1.12 - pulse,
        -radius * 0.52,
        -radius * 1.5,
        -radius * 0.18,
      );
      context.stroke();
      context.strokeStyle = profile.light;
      context.beginPath();
      context.moveTo(-radius * 0.45, radius * 0.34);
      context.quadraticCurveTo(
        -radius * 1.12 + pulse,
        radius * 0.52,
        -radius * 1.5,
        radius * 0.18,
      );
      context.stroke();
    } else if (state === "commit") {
      context.globalAlpha = 0.82;
      context.lineWidth = 2.4;
      context.strokeStyle = profile.light;
      context.beginPath();
      context.moveTo(radius * 1.08, -radius * 0.92);
      context.lineTo(radius * 1.08, radius * 0.92);
      context.stroke();
      context.fillStyle = profile.dark;
      context.beginPath();
      context.arc(radius * 1.08, -radius * 0.48, radius * 0.1, 0, Math.PI * 2);
      context.fill();
      context.fillStyle = profile.light;
      context.beginPath();
      context.arc(radius * 1.08, radius * 0.48, radius * 0.1, 0, Math.PI * 2);
      context.fill();
    } else if (state === "hit") {
      context.globalAlpha = 0.9;
      context.lineWidth = 2;
      for (const [color, side] of [[profile.dark, -1], [profile.light, 1]]) {
        context.strokeStyle = color;
        context.beginPath();
        context.moveTo(-radius * 0.15, side * radius * 0.54);
        context.lineTo(radius * 0.2, side * radius * 1.12);
        context.moveTo(radius * 0.18, side * radius * 0.48);
        context.lineTo(radius * 0.7, side * radius * 0.98);
        context.stroke();
      }
    } else if (state === "defend") {
      context.globalAlpha = 0.88;
      context.lineWidth = 3;
      context.strokeStyle = profile.dark;
      context.beginPath();
      context.arc(radius * 0.22, 0, radius * 1.05, -1.2, 0);
      context.stroke();
      context.strokeStyle = profile.light;
      context.beginPath();
      context.arc(radius * 0.22, 0, radius * 1.05, 0, 1.2);
      context.stroke();
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
    context.lineJoin = "round";

    drawAncestryFeatures(context, profile, radius);

    context.strokeStyle = profile.ink;
    context.lineWidth = 1.5;
    context.fillStyle = profile.dark;
    tracePolygon(context, [
      [-radius * 0.46, -radius * 0.48],
      [radius * 0.5, -radius * 0.42],
      [radius * 0.62, 0],
      [-radius * 0.42, 0],
    ]);
    context.fill();
    context.stroke();
    context.fillStyle = profile.light;
    tracePolygon(context, [
      [-radius * 0.42, 0],
      [radius * 0.62, 0],
      [radius * 0.5, radius * 0.42],
      [-radius * 0.46, radius * 0.48],
    ]);
    context.fill();
    context.stroke();

    context.fillStyle = profile.hair;
    context.beginPath();
    context.arc(-radius * 0.3, 0, radius * 0.38, 0, Math.PI * 2);
    context.fill();
    context.stroke();

    context.fillStyle = profile.ink;
    context.strokeStyle = profile.light;
    context.lineWidth = 1.8;
    drawDiamond(context, radius * 0.45, 0, radius * 0.24, radius * 0.3);
    context.fill();
    context.stroke();
    context.strokeStyle = profile.dark;
    drawSplitRing(context, radius * 0.45, 0, radius * 0.13, 0.45);

    drawTeamShape(context, team, teamColor, radius);
    drawHealthWear(context, profile.ink, radius, healthRatio);
    if (state === "commit") {
      context.strokeStyle = profile.light;
      context.lineWidth = 2;
      context.beginPath();
      context.moveTo(radius * 0.74, -radius * 0.34);
      context.lineTo(radius * 1.02, 0);
      context.lineTo(radius * 0.74, radius * 0.34);
      context.stroke();
      context.strokeStyle = profile.dark;
      context.beginPath();
      context.moveTo(radius * 0.62, -radius * 0.2);
      context.lineTo(radius * 0.88, 0);
      context.lineTo(radius * 0.62, radius * 0.2);
      context.stroke();
    }
  } finally {
    context.restore();
  }
}

function drawDefeat(context, profile, radius, teamColor) {
  context.save();
  try {
    context.globalAlpha = 0.62;
    context.lineWidth = 2;
    context.translate(0, radius * 0.32);
    context.scale(1.2, 0.48);
    context.fillStyle = profile.dark;
    context.strokeStyle = teamColor;
    tracePolygon(context, [
      [-radius * 0.92, 0],
      [-radius * 0.2, -radius * 0.64],
      [radius * 0.88, 0],
      [-radius * 0.2, 0],
    ]);
    context.fill();
    context.stroke();
    context.fillStyle = profile.light;
    tracePolygon(context, [
      [-radius * 0.92, 0],
      [-radius * 0.2, radius * 0.64],
      [radius * 0.88, 0],
      [-radius * 0.2, 0],
    ]);
    context.fill();
    context.stroke();
    context.strokeStyle = profile.ink;
    context.beginPath();
    context.moveTo(-radius * 0.34, -radius * 0.52);
    context.lineTo(radius * 0.34, radius * 0.52);
    context.stroke();
  } finally {
    context.restore();
  }
  return true;
}
