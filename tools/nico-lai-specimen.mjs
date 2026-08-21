import { renderCharacterSpecimen } from "./character-specimen.mjs";
import {
  drawNicoCoilDart,
  drawNicoSpellCue,
  drawNicoSpellState,
} from "../src/pixel-spell-renderer.mjs";

const TEAM_COLOR = "#77f7ce";
const CHARGE = "#52d8ff";
const LIGHT = "#ffe37d";

renderCharacterSpecimen("nico", { radius: 23 });
renderSpellSpecimen();

function renderSpellSpecimen() {
  for (const figure of document.querySelectorAll("[data-spell]")) {
    const canvas = figure.querySelector("canvas");
    const context = canvas?.getContext("2d");
    if (!canvas || !context) continue;
    drawSpellGround(context, canvas.width, canvas.height, figure.dataset.spell);
    if (figure.dataset.spell === "coilDart") drawCoilDartTimeline(context);
    if (figure.dataset.spell === "arcChain") drawArcChainTimeline(context);
    if (figure.dataset.spell === "prismGround") drawPrismGroundTimeline(context);
    if (figure.dataset.spell === "coilHop") drawCoilHopTimeline(context);
  }
}

function drawCoilDartTimeline(context) {
  drawCue(context, cue("coilDart", "anticipation", 82, 120, 0.72));
  context.save();
  context.translate(270, 120);
  drawNicoCoilDart(context, {
    ownerCharacterId: "volt", vx: 1, vy: 0, lifetime: 0.72,
    maximumLifetime: 0.92, heavy: false,
  }, TEAM_COLOR, { highContrast: true });
  context.restore();
  drawCue(context, cue("coilDart", "impact", 458, 120, 0.6));
  context.save();
  context.translate(620, 120);
  drawNicoCoilDart(context, {
    ownerCharacterId: "volt", vx: 1, vy: 0, lifetime: 0.08,
    maximumLifetime: 0.92, heavy: false,
  }, TEAM_COLOR, { highContrast: true });
  context.restore();
}

function drawArcChainTimeline(context) {
  drawCue(context, {
    ...cue("arcChain", "sequence", 70, 120, 0.48),
    endX: 520,
    endY: 120,
  });
  drawCue(context, cue("arcChain", "impact", 520, 120, 0.62));
  drawBrokenSegments(context, 590, 120);
}

function drawPrismGroundTimeline(context) {
  for (const [x, progress, phase] of [
    [90, 0.22, "anticipation"], [270, 0.5, "anticipation"],
    [450, 0.38, "impact"], [625, 0.82, "impact"],
  ]) drawCue(context, cue("prismGround", phase, x, 120, progress));
}

function drawCoilHopTimeline(context) {
  drawCue(context, cue("coilHop", "anticipation", 90, 120, 0.25));
  context.save();
  context.translate(300, 120);
  drawNicoSpellState(context, {
    characterId: "volt", defenseRemaining: 0, mobilityRemaining: 0.09,
    mobilityX: 1, mobilityY: 0,
  }, TEAM_COLOR, { mobilityDuration: 0.15, highContrast: true, reducedMotion: false });
  context.restore();
  drawCue(context, cue("coilHop", "impact", 500, 120, 0.42));
  drawDeviceSpark(context, 640, 120);
}

function cue(kind, phase, x, y, progress) {
  const maximumLife = 1;
  return {
    kind, phase, x, y, endX: x, endY: y, dx: 1, dy: 0,
    teamColor: TEAM_COLOR, maximumLife, life: maximumLife * (1 - progress),
  };
}

function drawCue(context, visual) {
  drawNicoSpellCue(context, visual, { highContrast: true, reducedMotion: false });
}

function drawBrokenSegments(context, x, y) {
  context.fillStyle = CHARGE;
  for (const [dx, dy] of [[-28, -5], [-12, 4], [8, -3], [25, 5]]) {
    context.fillRect(x + dx, y + dy, 9, 3);
  }
}

function drawDeviceSpark(context, x, y) {
  context.fillStyle = CHARGE;
  context.fillRect(x - 14, y - 2, 8, 4);
  context.fillStyle = LIGHT;
  context.fillRect(x - 2, y - 12, 4, 8);
  context.fillRect(x + 6, y + 5, 6, 4);
  context.fillStyle = TEAM_COLOR;
  context.fillRect(x - 2, y - 2, 5, 5);
}

function drawSpellGround(context, width, height, spell) {
  context.fillStyle = "#17130d";
  context.fillRect(0, 0, width, height);
  context.strokeStyle = "#493b24";
  context.lineWidth = 1;
  for (let x = 0; x < width; x += 45) {
    context.beginPath();
    context.moveTo(x, 0);
    context.lineTo(x, height);
    context.stroke();
  }
  context.strokeStyle = spell === "prismGround" ? LIGHT : CHARGE;
  context.globalAlpha = 0.28;
  context.beginPath();
  context.moveTo(28, height - 28);
  context.lineTo(width - 28, height - 28);
  context.stroke();
  context.globalAlpha = 1;
}
