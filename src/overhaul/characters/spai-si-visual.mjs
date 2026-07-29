import {
  composeCharacterVisualProfile,
  drawAncestryFeatures,
} from "../../ancestry-visual-templates.mjs";
import {
  drawHealthWear,
  drawTeamShape,
  openArc,
  tracePolygon,
} from "../character-visual-primitives.mjs";

export const SPAI_SI_VISUAL = Object.freeze({
  profile: composeCharacterVisualProfile({
    id: "aerwyn",
    name: "Spai Si",
    ancestryId: "demon",
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
  drawAura,
  drawDetails,
  drawDefeat,
});

function drawAura(context, profile, state, radius, time, reducedMotion) {
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
        context.quadraticCurveTo(
          -radius * 0.95,
          side * (radius * 0.65 + phase),
          -radius * 1.55,
          side * radius * 0.28,
        );
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
        context.moveTo(
          Math.cos(angle) * radius * 0.7,
          Math.sin(angle) * radius * 0.7,
        );
        context.lineTo(
          Math.cos(angle) * radius * 1.25,
          Math.sin(angle) * radius * 1.25,
        );
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

function drawDetails(context, profile, state, radius, team, teamColor, healthRatio) {
  context.save();
  try {
    context.shadowBlur = 0;
    context.lineCap = "round";
    context.lineJoin = "round";

    drawAncestryFeatures(context, profile, radius);

    context.fillStyle = profile.mantle;
    context.strokeStyle = profile.ink;
    context.lineWidth = 1.5;
    tracePolygon(context, [
      [-radius * 0.08, -radius * 0.52],
      [radius * 0.62, 0],
      [-radius * 0.08, radius * 0.52],
      [-radius * 0.5, 0],
    ]);
    context.fill();
    context.stroke();

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

function drawDefeat(context, profile, radius, teamColor) {
  context.save();
  try {
    context.globalAlpha = 0.58;
    context.strokeStyle = teamColor;
    context.fillStyle = profile.ink;
    context.lineWidth = 2;
    context.translate(0, radius * 0.28);
    context.scale(1.12, 0.48);
    tracePolygon(context, [
      [radius * 0.95, 0],
      [0, radius * 0.72],
      [-radius * 0.86, 0],
      [0, -radius * 0.72],
    ]);
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
