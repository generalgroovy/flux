import { PIXEL_PERSPECTIVE, snapVirtualPixel } from "./pixel-perspective.mjs";

const freeze = (value) => Object.freeze(value);

export const SANCTUM_PIXEL_STYLE = freeze({
  worldPixel: 4,
  routeWidth: 56,
  curbDepth: 12,
  stationSize: 76,
  materials: PIXEL_PERSPECTIVE.materials,
  layers: freeze(["water", "boundary", "ground", "detail", "route", "terrace", "ward", "landmark"]),
});

export function validateSanctumPixelStyle() {
  const errors = [];
  if (SANCTUM_PIXEL_STYLE.worldPixel < 2 || SANCTUM_PIXEL_STYLE.worldPixel > 8) errors.push("worldPixel");
  if (SANCTUM_PIXEL_STYLE.routeWidth % SANCTUM_PIXEL_STYLE.worldPixel !== 0) errors.push("routeWidth");
  if (SANCTUM_PIXEL_STYLE.materials !== PIXEL_PERSPECTIVE.materials) errors.push("materials");
  if (new Set(SANCTUM_PIXEL_STYLE.layers).size !== SANCTUM_PIXEL_STYLE.layers.length) errors.push("layers");
  return errors;
}

export function drawPixelSanctumGround(context, map, options = {}) {
  if (map?.id !== "living_sanctum") return false;
  const highContrast = options.highContrast === true;
  const { width, height, inset } = map.size;
  const materials = SANCTUM_PIXEL_STYLE.materials;

  context.save();
  context.imageSmoothingEnabled = false;
  context.fillStyle = PIXEL_PERSPECTIVE.values[0];
  context.fillRect(0, 0, width, height);
  drawBoundaryWater(context, width, height, inset, materials, highContrast);
  drawWalkableGround(context, width, height, inset, materials);
  drawGroundClusters(context, width, height, inset, materials);

  const road = map.landmarks?.find((landmark) => landmark.type === "road");
  if (road) drawWornRoute(context, road.x, road.y, road.width, road.height, materials, highContrast);
  drawStationRoutes(context, map, road, materials);

  for (const landmark of map.landmarks ?? []) {
    if (landmark.type === "court") drawCourtTerrace(context, landmark, materials, highContrast);
    if (landmark.type === "rune") drawMirrorWard(context, landmark, materials, highContrast);
  }
  drawBoundaryCorners(context, width, height, inset, materials, highContrast);
  context.restore();
  return true;
}

export function drawPixelSanctumObstacle(context, obstacle, options = {}) {
  const highContrast = options.highContrast === true;
  const materials = SANCTUM_PIXEL_STYLE.materials;
  const pixel = SANCTUM_PIXEL_STYLE.worldPixel;
  const x = snapVirtualPixel(obstacle.x, pixel);
  const y = snapVirtualPixel(obstacle.y, pixel);
  const width = snapVirtualPixel(obstacle.width, pixel);
  const height = snapVirtualPixel(obstacle.height, pixel);
  const depth = Math.min(16, Math.max(8, snapVirtualPixel(height * 0.12, pixel)));

  context.save();
  context.imageSmoothingEnabled = false;
  context.fillStyle = PIXEL_PERSPECTIVE.values[0];
  context.fillRect(x - pixel, y + pixel, width + pixel * 2, height);
  context.fillStyle = materials.stone[0];
  context.fillRect(x, y, width, height);
  context.fillStyle = materials.stone[1];
  context.fillRect(x + pixel, y + pixel, width - pixel * 2, height - pixel * 2);
  context.fillStyle = materials.stone[0];
  context.fillRect(x, y + height - depth, width, depth);
  context.fillStyle = materials.stone[2];
  context.fillRect(x + pixel, y + height - depth, width - pixel * 2, pixel);
  context.fillStyle = obstacle.vaultable ? materials.wood[2] : materials.stone[3];
  context.fillRect(x + pixel, y + pixel, width - pixel * 2, pixel * 2);
  if (obstacle.vaultable) {
    context.fillStyle = materials.wood[0];
    for (let offset = pixel * 3; offset < height - depth; offset += pixel * 4) {
      context.fillRect(x + pixel, y + offset, width - pixel * 2, pixel);
    }
  }
  if (highContrast) {
    context.strokeStyle = PIXEL_PERSPECTIVE.values[6];
    context.lineWidth = pixel;
    context.strokeRect(x + pixel / 2, y + pixel / 2, width - pixel, height - pixel);
  }
  context.restore();
}

export function drawPixelSanctumStation(context, station, options = {}) {
  const materials = SANCTUM_PIXEL_STYLE.materials;
  const pixel = SANCTUM_PIXEL_STYLE.worldPixel;
  const active = options.active === true;
  const highContrast = options.highContrast === true;
  const pulse = snapVirtualPixel(options.pulse ?? 0, pixel);
  const size = SANCTUM_PIXEL_STYLE.stationSize + pulse;
  const half = snapVirtualPixel(size / 2, pixel);
  const x = snapVirtualPixel(station.x, pixel);
  const y = snapVirtualPixel(station.y, pixel);
  const edge = active || highContrast ? PIXEL_PERSPECTIVE.values[6] : materials.stone[3];

  context.save();
  context.imageSmoothingEnabled = false;
  context.fillStyle = PIXEL_PERSPECTIVE.values[0];
  context.fillRect(x - half - pixel, y - half + pixel, half * 2 + pixel * 2, half * 2);
  context.fillStyle = materials.stone[0];
  context.fillRect(x - half, y - half, half * 2, half * 2);
  context.fillStyle = active ? materials.light[1] : materials.stone[1];
  context.fillRect(x - half + pixel, y - half + pixel, half * 2 - pixel * 2, half * 2 - pixel * 2);
  context.fillStyle = edge;
  context.fillRect(x - half + pixel * 2, y - half, half * 2 - pixel * 4, pixel);
  context.fillRect(x - half + pixel * 2, y + half - pixel, half * 2 - pixel * 4, pixel);
  context.fillRect(x - half, y - half + pixel * 2, pixel, half * 2 - pixel * 4);
  context.fillRect(x + half - pixel, y - half + pixel * 2, pixel, half * 2 - pixel * 4);
  context.fillStyle = active ? materials.light[3] : materials.light[2];
  context.fillRect(x - pixel * 2, y - pixel * 2, pixel * 4, pixel * 4);
  if (station.id === "rites") {
    context.fillStyle = materials.stone[0];
    context.fillRect(x - half - pixel * 2, y - half - pixel * 5, pixel * 4, half * 2 + pixel * 5);
    context.fillRect(x + half - pixel * 2, y - half - pixel * 5, pixel * 4, half * 2 + pixel * 5);
    context.fillRect(x - half - pixel * 2, y - half - pixel * 5, half * 2 + pixel * 4, pixel * 5);
    context.fillStyle = edge;
    context.fillRect(x - half, y - half - pixel * 2, half * 2, pixel * 2);
    context.fillStyle = PIXEL_PERSPECTIVE.values[0];
    context.fillRect(x - pixel * 4, y - half - pixel, pixel * 8, half + pixel * 2);
    context.fillStyle = active ? materials.light[3] : materials.light[2];
    context.fillRect(x - pixel, y - half - pixel * 4, pixel * 2, pixel * 2);
  }
  context.restore();
}

export function drawPixelSanctumForeground(context, map, options = {}) {
  if (map?.id !== "living_sanctum") return false;
  const { width, height, inset } = map.size;
  const materials = SANCTUM_PIXEL_STYLE.materials;
  const pixel = SANCTUM_PIXEL_STYLE.worldPixel;
  const highContrast = options.highContrast === true;

  context.save();
  context.imageSmoothingEnabled = false;
  context.fillStyle = materials.stone[0];
  context.fillRect(inset, height - inset, width - inset * 2, pixel * 3);
  context.fillStyle = highContrast ? PIXEL_PERSPECTIVE.values[6] : materials.stone[2];
  for (let x = inset + pixel; x < width - inset - pixel; x += pixel * 6) {
    context.fillRect(x, height - inset + pixel, pixel * 3, pixel);
  }
  context.restore();
  return true;
}

function drawBoundaryWater(context, width, height, inset, materials, highContrast) {
  context.fillStyle = materials.water[0];
  context.fillRect(0, 0, width, height);
  context.fillStyle = materials.water[1];
  context.fillRect(4, 4, width - 8, height - 8);
  context.fillStyle = highContrast ? PIXEL_PERSPECTIVE.values[5] : materials.water[2];
  for (let x = 12; x < width - 12; x += 36) {
    context.fillRect(x, 14 + (x % 24), 20, 4);
    context.fillRect(x, height - 22 - (x % 16), 16, 4);
  }
  for (let y = 20; y < height - 20; y += 40) {
    context.fillRect(12 + (y % 20), y, 4, 20);
    context.fillRect(width - 20 - (y % 16), y, 4, 16);
  }
  context.fillStyle = materials.stone[0];
  context.fillRect(inset - 8, inset - 8, width - inset * 2 + 16, height - inset * 2 + 16);
}

function drawWalkableGround(context, width, height, inset, materials) {
  context.fillStyle = materials.grass[0];
  context.fillRect(inset, inset, width - inset * 2, height - inset * 2);
  context.fillStyle = materials.grass[2];
  context.fillRect(inset + 4, inset + 4, width - inset * 2 - 8, height - inset * 2 - 8);
  context.fillStyle = materials.grass[1];
  context.fillRect(inset + 8, inset + 8, width - inset * 2 - 16, 8);
}

function drawGroundClusters(context, width, height, inset, materials) {
  context.fillStyle = materials.grass[3];
  for (let x = inset + 28; x < width - inset - 20; x += 92) {
    for (let y = inset + 30; y < height - inset - 20; y += 76) {
      if (((x / 4) + (y / 4)) % 5 < 2) continue;
      context.fillRect(x, y, 12, 4);
      context.fillRect(x + 4, y - 4, 4, 4);
    }
  }
  context.fillStyle = materials.foliage[1];
  for (const [x, y] of [[116, 92], [1480, 102], [118, 786], [1460, 770], [512, 390], [1060, 506]]) {
    context.fillRect(x, y + 8, 28, 16);
    context.fillRect(x + 4, y + 4, 20, 20);
    context.fillStyle = materials.foliage[3];
    context.fillRect(x + 8, y, 8, 8);
    context.fillStyle = materials.foliage[1];
  }
}

function drawWornRoute(context, x, y, width, height, materials, highContrast) {
  context.fillStyle = materials.path[0];
  context.fillRect(x - 4, y - 4, width + 8, height + 8);
  context.fillStyle = materials.path[1];
  context.fillRect(x, y, width, height);
  context.fillStyle = materials.path[2];
  for (let offset = 12; offset < width - 12; offset += 44) {
    context.fillRect(x + offset, y + 20 + (offset % 16), 24, 4);
    context.fillRect(x + offset + 8, y + height - 30 - (offset % 12), 16, 4);
  }
  if (highContrast) {
    context.strokeStyle = PIXEL_PERSPECTIVE.values[6];
    context.lineWidth = 4;
    context.strokeRect(x + 2, y + 2, width - 4, height - 4);
  }
}

function drawStationRoutes(context, map, road, materials) {
  if (!road) return;
  const roadTop = road.y;
  const roadBottom = road.y + road.height;
  const routeWidth = SANCTUM_PIXEL_STYLE.routeWidth;
  context.fillStyle = materials.path[0];
  for (const station of map.stations ?? []) {
    if (station.y >= roadTop && station.y <= roadBottom) continue;
    const top = station.y < roadTop ? station.y : roadBottom;
    const bottom = station.y < roadTop ? roadTop : station.y;
    context.fillRect(station.x - routeWidth / 2 - 4, top, routeWidth + 8, bottom - top);
    context.fillStyle = materials.path[2];
    context.fillRect(station.x - routeWidth / 2, top, routeWidth, bottom - top);
    context.fillStyle = materials.path[0];
  }
}

function drawCourtTerrace(context, landmark, materials, highContrast) {
  const depth = SANCTUM_PIXEL_STYLE.curbDepth;
  context.fillStyle = materials.stone[0];
  context.fillRect(landmark.x - 8, landmark.y - 8, landmark.width + 16, landmark.height + depth + 8);
  context.fillStyle = materials.stone[1];
  context.fillRect(landmark.x - 4, landmark.y - 4, landmark.width + 8, landmark.height + 4);
  context.fillStyle = materials.grass[1];
  context.fillRect(landmark.x, landmark.y, landmark.width, landmark.height - depth);
  context.fillStyle = materials.stone[2];
  context.fillRect(landmark.x, landmark.y + landmark.height - depth, landmark.width, depth);
  context.fillStyle = materials.stone[3];
  context.fillRect(landmark.x + 4, landmark.y + 4, landmark.width - 8, 4);
  const stairWidth = 88;
  context.fillStyle = materials.path[2];
  context.fillRect(landmark.x + landmark.width / 2 - stairWidth / 2, landmark.y + landmark.height - depth, stairWidth, depth + 8);
  context.fillStyle = highContrast ? PIXEL_PERSPECTIVE.values[6] : materials.stone[3];
  for (let x = 8; x < stairWidth - 4; x += 16) {
    context.fillRect(landmark.x + landmark.width / 2 - stairWidth / 2 + x, landmark.y + landmark.height - 8, 8, 4);
  }
}

function drawMirrorWard(context, landmark, materials, highContrast) {
  const pixel = SANCTUM_PIXEL_STYLE.worldPixel;
  const radius = snapVirtualPixel(landmark.radius, pixel);
  for (let inset = 0; inset < 4; inset += 1) {
    const step = radius - inset * pixel * 5;
    context.fillStyle = inset % 2 === 0 ? materials.stone[0] : materials.light[1];
    context.fillRect(landmark.x - step, landmark.y - pixel * 2, step * 2, pixel * 4);
    context.fillRect(landmark.x - pixel * 2, landmark.y - step, pixel * 4, step * 2);
  }
  context.fillStyle = highContrast ? PIXEL_PERSPECTIVE.values[6] : materials.light[3];
  context.fillRect(landmark.x - pixel * 2, landmark.y - pixel * 2, pixel * 4, pixel * 4);
}

function drawBoundaryCorners(context, width, height, inset, materials, highContrast) {
  const color = highContrast ? PIXEL_PERSPECTIVE.values[6] : materials.stone[3];
  context.fillStyle = color;
  for (const [x, y, sx, sy] of [
    [inset, inset, 1, 1], [width - inset, inset, -1, 1],
    [inset, height - inset, 1, -1], [width - inset, height - inset, -1, -1],
  ]) {
    context.fillRect(x, y, sx * 48, sy * 8);
    context.fillRect(x, y, sx * 8, sy * 48);
  }
}
