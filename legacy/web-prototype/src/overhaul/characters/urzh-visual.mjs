import {
  composeCharacterVisualProfile,
  drawAncestryFeatures,
} from "../../ancestry-visual-templates.mjs";
import {
  drawHealthWear,
  drawTeamShape,
  tracePolygon,
} from "../character-visual-primitives.mjs";

export const URZH_VISUAL = Object.freeze({
  profile: composeCharacterVisualProfile({
    id: "urzh",
    name: "Urzh",
    ancestryId: "stoneborn",
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
  drawAura,
  drawDetails,
  drawDefeat,
});

function drawAura(context, profile, state, radius, time, reducedMotion) {
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

function drawDetails(context, profile, state, radius, team, teamColor, healthRatio) {
  context.save();
  try {
    context.shadowBlur = 0;
    context.lineJoin = "bevel";

    drawAncestryFeatures(context, profile, radius);

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

function drawDefeat(context, profile, radius, teamColor) {
  context.save();
  try {
    context.globalAlpha = 0.62;
    context.fillStyle = profile.mantle;
    context.strokeStyle = teamColor;
    context.lineWidth = 2;
    context.translate(0, radius * 0.36);
    tracePolygon(context, [
      [-radius * 1.02, radius * 0.28],
      [-radius * 0.68, -radius * 0.3],
      [-radius * 0.08, -radius * 0.12],
      [radius * 0.28, -radius * 0.42],
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
