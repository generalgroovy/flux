import fs from "node:fs/promises";
import path from "node:path";
import sharp from "sharp";

export async function makeContactSheet(inputs, output, cell = 320) {
  const columns = Math.min(3, inputs.length);
  const rows = Math.ceil(inputs.length / columns);
  const composites = [];
  for (let i = 0; i < inputs.length; i++) {
    const image = await sharp(inputs[i]).resize(cell - 24, cell - 24, {
      fit: "contain", kernel: "nearest", withoutEnlargement: false,
    }).png().toBuffer();
    composites.push({ input: image, left: (i % columns) * cell + 12, top: Math.floor(i / columns) * cell + 12 });
  }
  await fs.mkdir(path.dirname(output), { recursive: true });
  await sharp({
    create: { width: columns * cell, height: rows * cell, channels: 4, background: "#251f2fff" }
  }).composite(composites).png().toFile(output);
}

export async function splitGrid(sheetPath, outputDir, columns, rows, target = 96) {
  const meta = await sharp(sheetPath).metadata();
  const cellW = Math.floor(meta.width / columns);
  const cellH = Math.floor(meta.height / rows);
  await fs.mkdir(outputDir, { recursive: true });
  const outputs = [];
  for (let row = 0; row < rows; row++) for (let col = 0; col < columns; col++) {
    const index = row * columns + col;
    const out = path.join(outputDir, `frame_${String(index).padStart(2,"0")}.png`);
    await sharp(sheetPath)
      .extract({ left: col * cellW, top: row * cellH, width: cellW, height: cellH })
      .trim({ background: "#00ff00", threshold: 18 })
      .resize(target - 8, target - 8, { fit: "contain", kernel: "nearest" })
      .extend({ top:4,bottom:4,left:4,right:4, background:{r:0,g:0,b:0,alpha:0} })
      .png().toFile(out);
    outputs.push(out);
  }
  return outputs;
}
