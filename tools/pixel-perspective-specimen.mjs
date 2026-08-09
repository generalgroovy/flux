import {
  PIXEL_PERSPECTIVE,
  drawPixelPerspectiveSpecimen,
  preparePixelCanvas,
  validatePixelPerspective,
} from "../src/pixel-perspective.mjs";

const canvas = document.querySelector("#pixel-scene");
const context = canvas?.getContext("2d");
const grayscale = document.querySelector("#grayscale");
const highContrast = document.querySelector("#high-contrast");
const reducedMotion = document.querySelector("#reduced-motion");
const status = document.querySelector("#scene-status");

if (!canvas || !context || !grayscale || !highContrast || !reducedMotion || !status) {
  throw new Error("P0 pixel perspective specimen is incomplete");
}

const errors = validatePixelPerspective();
if (errors.length > 0) throw new Error("Invalid pixel perspective contract: " + errors.join(", "));

preparePixelCanvas(canvas, context);

function render() {
  drawPixelPerspectiveSpecimen(context, {
    width: canvas.width,
    height: canvas.height,
    grayscale: grayscale.checked,
    highContrast: highContrast.checked,
    reducedMotion: reducedMotion.checked,
  });
  status.textContent = [
    PIXEL_PERSPECTIVE.virtualWidth + "×" + PIXEL_PERSPECTIVE.virtualHeight,
    grayscale.checked ? "grayscale" : "color",
    highContrast.checked ? "high contrast" : "standard contrast",
    reducedMotion.checked ? "reduced motion" : "full state motion",
  ].join(" · ");
}

for (const control of [grayscale, highContrast, reducedMotion]) {
  control.addEventListener("change", render);
}
render();
