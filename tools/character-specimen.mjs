import {
  drawOverhaulCharacterAura,
  drawOverhaulCharacterDefeat,
  drawOverhaulCharacterDetails,
  drawOverhaulPixelCharacter,
  getOverhaulCharacterVisualProfile,
  isOverhaulPixelCharacter,
  traceOverhaulCharacterBody,
} from "../src/overhaul-character-visuals.mjs";

export function renderCharacterSpecimen(characterId, { radius = 26 } = {}) {
  const profile = getOverhaulCharacterVisualProfile(characterId);
  if (!profile) throw new Error(`Unknown overhaul visual profile: ${characterId}`);
  const reducedMotion = window
    .matchMedia("(prefers-reduced-motion: reduce)")
    .matches;

  for (const [index, figure] of [
    ...document.querySelectorAll("[data-state]"),
  ].entries()) {
    const state = figure.dataset.state;
    const canvas = figure.querySelector("canvas");
    if (!canvas) continue;
    const context = canvas.getContext("2d");
    const team = index < 3 ? "alpha" : "beta";
    const teamColor = team === "alpha" ? "#77f7ce" : "#ff5d73";
    const healthRatio = state === "hit" ? 0.2 : state === "defeated" ? 0 : 1;

    drawGround(context, canvas.width, canvas.height, teamColor);
    if (isOverhaulPixelCharacter(profile)) {
      context.save();
      context.imageSmoothingEnabled = false;
      context.translate(canvas.width / 2, canvas.height * 0.68);
      context.scale(3, 3);
      drawPixelShadow(context, radius, state === "move" ? 0.25 : 0);
      drawOverhaulPixelCharacter(
        context,
        profile,
        state,
        radius,
        team,
        teamColor,
        healthRatio,
        figure.dataset.facing ?? "down",
      );
      context.restore();
      continue;
    }
    context.save();
    context.translate(canvas.width / 2, canvas.height / 2 - 4);
    context.scale(2.1, 2.1);
    if (state === "defeated") {
      drawOverhaulCharacterDefeat(context, profile, radius, teamColor);
    } else {
      drawOverhaulCharacterAura(
        context,
        profile,
        state,
        radius,
        0.7,
        reducedMotion,
      );
      context.fillStyle = state === "hit" ? "#ffffff" : profile.body;
      context.strokeStyle = teamColor;
      context.lineWidth = 2;
      traceOverhaulCharacterBody(context, profile, radius);
      context.fill();
      context.stroke();
      drawOverhaulCharacterDetails(
        context,
        profile,
        state,
        radius,
        team,
        teamColor,
        healthRatio,
      );
    }
    context.restore();
  }
}

function drawPixelShadow(context, radius, liftRatio) {
  const width = Math.round(radius * (1.05 + liftRatio * 0.38) / 4) * 4;
  context.fillStyle = "#070906b8";
  context.fillRect(-width / 2 + 4, -2, width - 8, 8);
  context.fillRect(-width / 2, 2, width, 4);
}

function drawGround(context, width, height, teamColor) {
  context.fillStyle = "#17130d";
  context.fillRect(0, 0, width, height);
  context.strokeStyle = "#493b24";
  context.lineWidth = 1;
  for (let x = 20; x < width; x += 40) {
    context.beginPath();
    context.moveTo(x, 0);
    context.lineTo(x, height);
    context.stroke();
  }
  for (let y = 20; y < height; y += 40) {
    context.beginPath();
    context.moveTo(0, y);
    context.lineTo(width, y);
    context.stroke();
  }
  context.fillStyle = teamColor;
  context.globalAlpha = 0.2;
  context.fillRect(0, height - 5, width, 5);
  context.globalAlpha = 1;
}
