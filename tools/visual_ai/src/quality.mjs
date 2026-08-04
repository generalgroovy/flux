import sharp from "sharp";

function clamp01(value) { return Math.max(0, Math.min(1, value)); }

export async function inspectImage(filePath) {
  const image = sharp(filePath).ensureAlpha();
  const { data, info } = await image.raw().toBuffer({ resolveWithObject: true });
  const { width, height, channels } = info;
  let visible = 0, edge = 0, minX = width, minY = height, maxX = -1, maxY = -1;
  const colors = new Set();
  for (let y = 0; y < height; y++) for (let x = 0; x < width; x++) {
    const i = (y * width + x) * channels;
    const a = data[i + 3];
    if (a <= 16) continue;
    visible++;
    minX = Math.min(minX, x); minY = Math.min(minY, y);
    maxX = Math.max(maxX, x); maxY = Math.max(maxY, y);
    if (x < 2 || y < 2 || x >= width - 2 || y >= height - 2) edge++;
    colors.add(`${data[i] >> 3},${data[i+1] >> 3},${data[i+2] >> 3}`);
  }
  const pixels = width * height;
  const occupancy = visible / pixels;
  const edgeRatio = visible ? edge / visible : 1;
  const bbox = maxX >= 0 ? [minX, minY, maxX + 1, maxY + 1] : [0,0,0,0];
  const paletteBins = colors.size;
  const occupancyScore = 1 - Math.min(1, Math.abs(occupancy - 0.46) / 0.36);
  const edgeScore = 1 - Math.min(1, edgeRatio / 0.025);
  const paletteScore = clamp01((paletteBins - 18) / 70);
  const score = 0.42 * occupancyScore + 0.38 * edgeScore + 0.20 * paletteScore;
  return { width, height, occupancy, edgeRatio, paletteBins, bbox, structuralScore: score };
}

export function acceptedStructurally(metrics, threshold = 0.82) {
  return metrics.structuralScore >= threshold && metrics.edgeRatio < 0.02 &&
    metrics.occupancy > 0.18 && metrics.occupancy < 0.82 && metrics.paletteBins >= 24;
}
