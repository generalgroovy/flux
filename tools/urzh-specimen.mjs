import {
  drawOverhaulCharacterAura,
  drawOverhaulCharacterDefeat,
  drawOverhaulCharacterDetails,
  getOverhaulCharacterVisualProfile,
  traceOverhaulCharacterBody,
} from "../src/overhaul-character-visuals.mjs";

const profile = getOverhaulCharacterVisualProfile("urzh");
const radius = 28;
const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

for (const [index, figure] of [...document.querySelectorAll("[data-state]")].entries()) {
  const state = figure.dataset.state;
  const canvas = figure.querySelector("canvas");
  const context = canvas.getContext("2d");
  const team = index < 3 ? "alpha" : "beta";
  const teamColor = team === "alpha" ? "#77f7ce" : "#ff5d73";
  const healthRatio = state === "hit" ? 0.2 : state === "defeated" ? 0 : 1;
  context.fillStyle = "#17130d";
  context.fillRect(0, 0, canvas.width, canvas.height);
  context.strokeStyle = "#493b24";
  for (let x = 20; x < canvas.width; x += 40) {
    context.beginPath(); context.moveTo(x, 0); context.lineTo(x, canvas.height); context.stroke();
  }
  for (let y = 20; y < canvas.height; y += 40) {
    context.beginPath(); context.moveTo(0, y); context.lineTo(canvas.width, y); context.stroke();
  }
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
    context.fill(); context.stroke();
    drawOverhaulCharacterDetails(context, profile, state, radius, team, teamColor, healthRatio);
  }
  context.restore();
}
