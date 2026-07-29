import {
  ANCESTRY_VISUAL_TEMPLATES,
  composeCharacterVisualProfile,
  drawAncestryFeatures,
  traceAncestryBody,
} from "../src/ancestry-visual-templates.mjs";

const grid = document.querySelector("#template-grid");
const cardTemplate = document.querySelector("#template-card");
const palette = {
  body: "#8d8068", mantle: "#51462f", ink: "#17130d", earth: "#a79771",
  fire: "#c76632", water: "#6ba7b6", wind: "#86bda7", light: "#d4b84e",
  ember: "#c76632", hair: "#6b4930",
};

for (const ancestry of ANCESTRY_VISUAL_TEMPLATES) {
  const card = cardTemplate.content.firstElementChild.cloneNode(true);
  card.querySelector("h2").textContent = ancestry.name;
  card.querySelector(".shape").textContent = ancestry.bodyShape;
  card.querySelector(".features").textContent = ancestry.features.join(" · ");
  card.querySelector("small").textContent = `${ancestry.material} · ${ancestry.motionRead}`;
  const canvas = card.querySelector("canvas");
  const context = canvas.getContext("2d");
  const profile = composeCharacterVisualProfile({
    ...palette,
    id: `template-${ancestry.id}`,
    name: ancestry.name,
    ancestryId: ancestry.id,
    roleRead: "unassigned role",
    focusProp: "unassigned prop",
  });
  drawGrid(context, canvas.width, canvas.height);
  context.save();
  context.translate(canvas.width / 2, canvas.height / 2);
  context.scale(1.65, 1.65);
  context.fillStyle = profile.body;
  context.strokeStyle = "#77f7ce";
  context.lineWidth = 2;
  traceAncestryBody(context, ancestry, 25);
  context.fill();
  context.stroke();
  drawAncestryFeatures(context, profile, 25);
  context.restore();
  grid.append(card);
}

function drawGrid(context, width, height) {
  context.fillStyle = "#17130d";
  context.fillRect(0, 0, width, height);
  context.strokeStyle = "#332a1c";
  context.lineWidth = 1;
  for (let x = 20; x < width; x += 40) {
    context.beginPath(); context.moveTo(x, 0); context.lineTo(x, height); context.stroke();
  }
  for (let y = 20; y < height; y += 40) {
    context.beginPath(); context.moveTo(0, y); context.lineTo(width, y); context.stroke();
  }
}
