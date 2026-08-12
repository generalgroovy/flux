const freeze = (value) => Object.freeze(value);

export const PIXEL_PERSPECTIVE = freeze({
  virtualWidth: 384,
  virtualHeight: 216,
  tile: 16,
  outline: 2,
  projection: "orthographic-three-quarter",
  groundAnchor: "feet",
  scaling: "integer-nearest-neighbour",
  layers: freeze([
    "ground", "ground-detail", "elevation-front", "elevation-top", "blocker",
    "landmark", "ground-shadow", "champion", "element", "interface",
  ]),
  values: freeze(["#11140f", "#20241a", "#353a27", "#59603a", "#8d9660", "#c8c79a", "#f4ecc9"]),
  materials: freeze({
    grass: freeze(["#182419", "#263a21", "#3f5c2d", "#718144"]),
    path: freeze(["#35251a", "#5a3b24", "#8b6035", "#bd8a50"]),
    stone: freeze(["#24251f", "#3b3d33", "#5d5f4b", "#8d8e6b"]),
    wood: freeze(["#2a1a13", "#4a2c1c", "#75472a", "#a56d3d"]),
    water: freeze(["#102a2d", "#19474b", "#257077", "#61a3a0"]),
    foliage: freeze(["#142316", "#264023", "#3d6833", "#72a34e"]),
    charge: freeze(["#172a2d", "#28646c", "#43b4c0", "#c6fbef"]),
    light: freeze(["#463714", "#8d7426", "#d5b94c", "#fff1a6"]),
  }),
});

export const PERSPECTIVE_SPECIMEN_FEATURES = freeze([
  "walkable-ground", "worn-path", "shallow-water", "cliff-top", "cliff-front",
  "stairs", "stone-blocker", "foliage", "station-landmark",
  "nico-scale-champion", "ground-anchor-shadow", "charge-motif", "light-motif",
]);

export function snapVirtualPixel(value, step = 1) {
  const safeStep = Number.isFinite(step) && step > 0 ? step : 1;
  return Math.round((Number.isFinite(value) ? value : 0) / safeStep) * safeStep;
}

export function preparePixelCanvas(canvas, context, { width, height } = {}) {
  const virtualWidth = positiveInteger(width, PIXEL_PERSPECTIVE.virtualWidth);
  const virtualHeight = positiveInteger(height, PIXEL_PERSPECTIVE.virtualHeight);
  canvas.width = virtualWidth;
  canvas.height = virtualHeight;
  context.imageSmoothingEnabled = false;
  return freeze({ width: virtualWidth, height: virtualHeight });
}

export function validatePixelPerspective() {
  const errors = [];
  if (PIXEL_PERSPECTIVE.projection !== "orthographic-three-quarter") errors.push("projection");
  if (PIXEL_PERSPECTIVE.groundAnchor !== "feet") errors.push("groundAnchor");
  if (PIXEL_PERSPECTIVE.tile < 8 || PIXEL_PERSPECTIVE.tile > 32) errors.push("tile");
  if (new Set(PIXEL_PERSPECTIVE.layers).size !== PIXEL_PERSPECTIVE.layers.length) errors.push("layers");
  if (PIXEL_PERSPECTIVE.values.length !== 7) errors.push("values");
  for (const [name, ramp] of Object.entries(PIXEL_PERSPECTIVE.materials)) {
    if (ramp.length !== 4 || ramp.some((color) => !/^#[0-9a-f]{6}$/i.test(color))) {
      errors.push("material:" + name);
    }
  }
  return errors;
}

export function drawPixelPerspectiveSpecimen(context, options = {}) {
  const width = options.width ?? PIXEL_PERSPECTIVE.virtualWidth;
  const height = options.height ?? PIXEL_PERSPECTIVE.virtualHeight;
  const highContrast = options.highContrast === true;
  const ramps = options.grayscale === true ? grayscaleRamps() : PIXEL_PERSPECTIVE.materials;

  context.save();
  context.imageSmoothingEnabled = false;
  context.fillStyle = highContrast ? "#080a08" : PIXEL_PERSPECTIVE.values[0];
  context.fillRect(0, 0, width, height);
  drawGround(context, ramps, highContrast);
  drawWater(context, ramps);
  drawPath(context, ramps);
  drawCliff(context, ramps, highContrast);
  drawStairs(context, ramps, highContrast);
  drawBlocker(context, ramps, highContrast);
  drawFoliage(context, ramps);
  drawStation(context, ramps, highContrast);
  drawChampionProof(context, ramps, highContrast);
  drawElementProofs(context, ramps, highContrast);
  context.restore();
}

function drawGround(context, ramps, highContrast) {
  context.fillStyle = ramps.grass[0];
  context.fillRect(10, 8, 364, 200);
  context.fillStyle = ramps.grass[2];
  context.fillRect(12, 10, 360, 196);
  context.fillStyle = ramps.grass[1];
  for (const [x, y] of [[24, 24], [88, 18], [336, 30], [22, 174], [314, 184], [350, 154], [101, 188]]) {
    context.fillRect(x, y, 5, 2);
    context.fillRect(x + 2, y - 2, 2, 2);
  }
  if (highContrast) {
    context.strokeStyle = "#e8e4bf";
    context.lineWidth = 1;
    context.strokeRect(10.5, 8.5, 363, 199);
  }
}

function drawWater(context, ramps) {
  context.fillStyle = ramps.water[0];
  context.fillRect(14, 12, 62, 192);
  context.fillStyle = ramps.water[1];
  context.fillRect(17, 12, 56, 192);
  context.fillStyle = ramps.water[2];
  for (let y = 20; y < 202; y += 12) {
    context.fillRect(20 + ((y / 12) % 2) * 7, y, 18, 2);
    context.fillRect(47 - ((y / 12) % 2) * 5, y + 4, 19, 2);
  }
  context.fillStyle = ramps.water[3];
  for (let y = 26; y < 198; y += 24) context.fillRect(24, y, 9, 1);
}

function drawPath(context, ramps) {
  context.fillStyle = ramps.path[1];
  context.fillRect(76, 156, 296, 34);
  context.fillRect(274, 88, 50, 72);
  context.fillStyle = ramps.path[2];
  for (let x = 84; x < 366; x += 16) {
    context.fillRect(x, 162 + (x % 3), 10, 3);
    context.fillRect(x + 5, 177 - (x % 5), 7, 2);
  }
  for (let y = 96; y < 154; y += 13) context.fillRect(282 + (y % 4), y, 31, 3);
}

function drawCliff(context, ramps, highContrast) {
  context.fillStyle = ramps.stone[0];
  context.fillRect(106, 48, 176, 84);
  context.fillStyle = ramps.path[0];
  context.fillRect(110, 84, 168, 54);
  context.fillStyle = ramps.path[1];
  context.fillRect(114, 88, 160, 46);
  for (let y = 94; y < 132; y += 10) {
    context.fillStyle = ramps.path[0];
    context.fillRect(118, y, 151, 3);
    context.fillStyle = ramps.path[2];
    context.fillRect(128 + (y % 7) * 3, y + 3, 35, 2);
    context.fillRect(202 - (y % 5) * 4, y + 5, 46, 2);
  }
  context.fillStyle = ramps.grass[0];
  context.fillRect(104, 42, 180, 48);
  context.fillStyle = ramps.grass[3];
  context.fillRect(108, 46, 172, 40);
  context.fillStyle = ramps.grass[1];
  context.fillRect(108, 82, 172, 4);
  context.fillStyle = highContrast ? "#f4ecc9" : ramps.stone[3];
  context.fillRect(104, 42, 180, 2);
  context.fillRect(104, 42, 2, 46);
  context.fillRect(282, 42, 2, 46);
}

function drawStairs(context, ramps, highContrast) {
  context.fillStyle = ramps.stone[0];
  context.fillRect(174, 78, 38, 62);
  context.fillStyle = ramps.stone[2];
  context.fillRect(178, 80, 30, 58);
  context.fillStyle = highContrast ? "#f4ecc9" : ramps.stone[3];
  for (let y = 84; y < 137; y += 7) context.fillRect(179, y, 28, 2);
}

function drawBlocker(context, ramps, highContrast) {
  context.fillStyle = ramps.stone[0];
  context.fillRect(326, 104, 34, 40);
  context.fillStyle = ramps.stone[1];
  context.fillRect(330, 98, 26, 42);
  context.fillStyle = ramps.stone[3];
  context.fillRect(334, 101, 18, 5);
  context.fillRect(330, 112, 26, 3);
  context.fillStyle = highContrast ? "#f4ecc9" : ramps.stone[2];
  context.fillRect(330, 98, 26, 2);
}

function drawFoliage(context, ramps) {
  for (const [x, y] of [[88, 31], [300, 45], [339, 62], [91, 126], [348, 176]]) {
    context.fillStyle = ramps.foliage[0];
    context.fillRect(x, y + 6, 18, 12);
    context.fillStyle = ramps.foliage[2];
    context.fillRect(x + 3, y + 2, 12, 14);
    context.fillStyle = ramps.foliage[3];
    context.fillRect(x + 6, y, 5, 5);
  }
}

function drawStation(context, ramps, highContrast) {
  context.fillStyle = ramps.wood[0];
  context.fillRect(231, 56, 26, 26);
  context.fillStyle = ramps.wood[2];
  context.fillRect(234, 52, 20, 26);
  context.fillStyle = highContrast ? "#ffffff" : ramps.light[3];
  context.fillRect(242, 57, 4, 14);
  context.fillRect(237, 62, 14, 4);
  context.fillStyle = ramps.light[1];
  context.fillRect(240, 60, 8, 8);
}

function drawChampionProof(context, ramps, highContrast) {
  const x = 286;
  const groundY = 151;
  context.fillStyle = highContrast ? "#000000" : "#14130f";
  drawSteppedShadow(context, x, groundY, 18, 6);
  context.fillStyle = ramps.charge[0];
  context.fillRect(x - 11, groundY - 29, 22, 22);
  context.fillStyle = ramps.stone[3];
  context.fillRect(x - 8, groundY - 37, 16, 13);
  context.fillStyle = ramps.light[2];
  context.fillRect(x - 7, groundY - 39, 14, 4);
  context.fillStyle = ramps.stone[0];
  context.fillRect(x - 6, groundY - 32, 4, 4);
  context.fillRect(x + 2, groundY - 32, 4, 4);
  context.fillStyle = highContrast ? "#ffffff" : ramps.charge[3];
  context.fillRect(x - 6, groundY - 20, 12, 5);
  context.fillStyle = ramps.light[3];
  context.fillRect(x - 2, groundY - 18, 4, 4);
  context.fillStyle = ramps.stone[0];
  context.fillRect(x - 10, groundY - 7, 7, 4);
  context.fillRect(x + 3, groundY - 7, 7, 4);
  context.fillStyle = ramps.charge[2];
  context.fillRect(x + 11, groundY - 26, 7, 17);
  context.fillStyle = ramps.charge[3];
  context.fillRect(x + 13, groundY - 23, 3, 8);
}

function drawElementProofs(context, ramps, highContrast) {
  context.fillStyle = highContrast ? "#ffffff" : ramps.charge[3];
  for (const [x, y] of [[270, 112], [306, 121]]) {
    context.fillRect(x, y, 8, 3);
    context.fillRect(x + 5, y + 3, 3, 5);
    context.fillRect(x + 2, y + 8, 7, 3);
  }
  context.fillStyle = highContrast ? "#ffffff" : ramps.light[3];
  for (const [x, y] of [[265, 137], [315, 139]]) {
    context.fillRect(x + 3, y, 3, 3);
    context.fillRect(x, y + 3, 9, 3);
    context.fillRect(x + 3, y + 6, 3, 3);
  }
}

function drawSteppedShadow(context, x, y, width, height) {
  context.fillRect(x - width / 2 + 4, y - height / 2, width - 8, height);
  context.fillRect(x - width / 2, y - height / 2 + 2, width, height - 4);
}

function grayscaleRamps() {
  return freeze(Object.fromEntries(
    Object.keys(PIXEL_PERSPECTIVE.materials).map((name, index) => {
      const start = 28 + (index % 3) * 5;
      const ramp = [start, start + 22, start + 48, start + 78].map((value) => {
        const hex = Math.min(238, value).toString(16).padStart(2, "0");
        return "#" + hex + hex + hex;
      });
      return [name, freeze(ramp)];
    }),
  ));
}

function positiveInteger(value, fallback) {
  return Number.isInteger(value) && value > 0 ? value : fallback;
}
