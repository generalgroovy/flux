import {
  drawOverhaulCharacterAura,
  drawOverhaulCharacterDefeat,
  drawOverhaulCharacterDetails,
  getOverhaulCharacterVisualProfile,
  traceOverhaulCharacterBody,
} from "../src/overhaul-character-visuals.mjs";

const profile = getOverhaulCharacterVisualProfile("aerwyn");
const radius = 26;
const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

for (const [index, figure] of [...document.querySelectorAll("[data-state]")].entries()) {
  const state = figure.dataset.state;
  const canvas = figure.querySelector("canvas");
  const context = canvas.getContext("2d");
  const team = index < 3 ? "alpha" : "beta";
  const teamColor = team === "alpha" ? "#77f7ce" : "#ff5d73";
  const healthRatio = state === "hit" ? 0.2 : state === "defeated" ? 0 : 1;

  context.clearRect(0, 0, canvas.width, canvas.height);
  drawGround(context, canvas.width, canvas.height, teamColor);
  context.save();
  context.translate(canvas.width / 2, canvas.height / 2 - 4);
  context.scale(2.1, 2.1);
  if (state === "defeated") {
    drawOverhaulCharacterDefeat(context, profile, radius, teamColor);
  } else {
    drawOverhaulCharacterAura(context, profile, state, radius, 0.7, reducedMotion);
    context.fillStyle = state === "hit" ? "#ffffff" : profile.body;
    context.strokeStyle = teamColor;
    context.lineWidth = 2;
    traceOverhaulCharacterBody(context, profile, radius);
    context.fill();
    context.stroke();
    drawOverhaulCharacterDetails(context, profile, state, radius, team, teamColor, healthRatio);
  }
  context.restore();
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
