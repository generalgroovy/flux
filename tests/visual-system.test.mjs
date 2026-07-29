import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const read = (path) => readFile(new URL(`../${path}`, import.meta.url), "utf8");

const channel = (value) => {
  const normalized = value / 255;
  return normalized <= 0.03928 ? normalized / 12.92 : ((normalized + 0.055) / 1.055) ** 2.4;
};

const luminance = (hex) => {
  const color = hex.replace("#", "");
  const [red, green, blue] = [0, 2, 4].map((offset) => channel(Number.parseInt(color.slice(offset, offset + 2), 16)));
  return (0.2126 * red) + (0.7152 * green) + (0.0722 * blue);
};

const contrast = (left, right) => {
  const values = [luminance(left), luminance(right)].sort((a, b) => b - a);
  return (values[0] + 0.05) / (values[1] + 0.05);
};

test("V0 visual tokens and the non-shipping specimen stay complete and bounded", async () => {
  const [styles, specimen, specimenStyles, server, packageJson] = await Promise.all([
    read("styles.css"),
    read("tools/visual-specimen.html"),
    read("tools/visual-specimen.css"),
    read("scripts/serve.mjs"),
    read("package.json"),
  ]);

  for (let step = 0; step <= 6; step += 1) {
    assert.match(styles, new RegExp(`--flux-value-${step}:`));
  }
  for (const token of [
    "parchment", "mineral", "forest", "tide", "ember", "volt", "veil",
    "danger", "outline-hairline", "outline-body", "outline-focus",
    "motion-immediate", "motion-response", "motion-panel", "motion-ceremony",
    "material-parchment", "material-stone", "material-woven", "material-root",
    "material-water",
  ]) {
    assert.match(styles, new RegExp(`--flux-${token}:`), token);
  }

  const tokenColor = (name) => styles.match(new RegExp(`--flux-${name}:\\s*(#[0-9a-f]{6})`, "i"))?.[1];
  const coreContrastPairs = [
    ["parchment", "value-0"],
    ["parchment-muted", "value-1"],
    ["volt", "value-0"],
    ["danger", "value-0"],
  ];
  for (const [foreground, background] of coreContrastPairs) {
    const foregroundColor = tokenColor(foreground);
    const backgroundColor = tokenColor(background);
    assert.ok(foregroundColor && backgroundColor, `${foreground}/${background} colors exist`);
    assert.ok(contrast(foregroundColor, backgroundColor) >= 4.5, `${foreground}/${background} contrast`);
  }

  for (const section of [
    "Palette roles", "Value ladder", "Material language", "Gameplay read",
    "Magic geometry", "Scale · edge · motion",
  ]) {
    assert.match(specimen, new RegExp(section));
  }
  assert.match(specimen, /NON-SHIPPING REFERENCE/);
  assert.match(specimenStyles, /prefers-reduced-motion:\s*reduce/);
  assert.match(specimenStyles, /var\(--flux-motion|var\(--flux-material/);
  assert.match(server, /"\/tools\/visual-specimen\.html"/);
  assert.match(server, /"\/tools\/visual-specimen\.css"/);

  const buildFiles = JSON.parse(packageJson).build.files;
  assert.equal(buildFiles.some((entry) => entry.startsWith("tools/")), false);
});
