import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

import {
  PIXEL_PERSPECTIVE,
  PERSPECTIVE_SPECIMEN_FEATURES,
  drawPixelPerspectiveSpecimen,
  snapVirtualPixel,
  validatePixelPerspective,
} from "../src/pixel-perspective.mjs";
import { SANCTUM_PRACTICE_MAP } from "../src/content.mjs";
import {
  SANCTUM_PIXEL_STYLE,
  drawPixelSanctumForeground,
  drawPixelSanctumGround,
  drawPixelSanctumObstacle,
  drawPixelSanctumStation,
  validateSanctumPixelStyle,
} from "../src/pixel-sanctum-renderer.mjs";

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

test("P0 pixel perspective foundation is bounded, responsive, and source-only", async () => {
  const [specimen, specimenStyles, runner, server, packageJson, game] = await Promise.all([
    read("tools/pixel-perspective-specimen.html"),
    read("tools/pixel-perspective-specimen.css"),
    read("tools/pixel-perspective-specimen.mjs"),
    read("scripts/serve.mjs"),
    read("package.json"),
    read("src/game.mjs"),
  ]);

  assert.deepEqual(validatePixelPerspective(), []);
  assert.equal(PIXEL_PERSPECTIVE.virtualWidth, 384);
  assert.equal(PIXEL_PERSPECTIVE.virtualHeight, 216);
  assert.equal(PIXEL_PERSPECTIVE.projection, "orthographic-three-quarter");
  assert.equal(PIXEL_PERSPECTIVE.groundAnchor, "feet");
  assert.equal(new Set(PIXEL_PERSPECTIVE.layers).size, PIXEL_PERSPECTIVE.layers.length);
  assert.ok(PIXEL_PERSPECTIVE.layers.indexOf("ground") < PIXEL_PERSPECTIVE.layers.indexOf("champion"));
  assert.ok(PIXEL_PERSPECTIVE.layers.indexOf("ground-shadow") < PIXEL_PERSPECTIVE.layers.indexOf("champion"));
  assert.ok(PIXEL_PERSPECTIVE.layers.indexOf("champion") < PIXEL_PERSPECTIVE.layers.indexOf("element"));
  for (const feature of [
    "walkable-ground", "worn-path", "shallow-water", "cliff-top", "cliff-front",
    "stairs", "stone-blocker", "foliage", "station-landmark",
    "nico-scale-champion", "ground-anchor-shadow", "charge-motif", "light-motif",
  ]) {
    assert.ok(PERSPECTIVE_SPECIMEN_FEATURES.includes(feature), feature);
  }
  for (const ramp of Object.values(PIXEL_PERSPECTIVE.materials)) assert.equal(ramp.length, 4);
  assert.equal(snapVirtualPixel(7.4, 2), 8);
  assert.equal(snapVirtualPixel(Number.NaN, 0), 0);

  const operations = [];
  let smoothing = true;
  const context = {
    save() {},
    restore() {},
    fillRect(...values) { operations.push(["fill", ...values]); },
    strokeRect(...values) { operations.push(["stroke", ...values]); },
    set fillStyle(value) {},
    set strokeStyle(value) {},
    set lineWidth(value) {},
    set imageSmoothingEnabled(value) { smoothing = value; },
  };
  drawPixelPerspectiveSpecimen(context, { grayscale: true, highContrast: true });
  assert.equal(smoothing, false);
  assert.ok(operations.length > 100, "specimen draws a complete proof scene");

  assert.match(specimen, /P0[^<]*NON-SHIPPING PERSPECTIVE FOUNDATION/);
  assert.match(specimen, /canvas id="pixel-scene" width="384" height="216"/);
  for (const id of ["grayscale", "high-contrast", "reduced-motion"]) {
    assert.match(specimen, new RegExp(`id="${id}"`));
  }
  assert.match(specimenStyles, /image-rendering:\s*pixelated/);
  assert.match(specimenStyles, /@media \(max-width:\s*30rem\)/);
  assert.match(specimenStyles, /prefers-reduced-motion:\s*reduce/);
  assert.match(runner, /from "\.\.\/src\/pixel-perspective\.mjs"/);
  for (const path of [
    "/src/pixel-perspective.mjs",
    "/tools/pixel-perspective-specimen.html",
    "/tools/pixel-perspective-specimen.css",
    "/tools/pixel-perspective-specimen.mjs",
  ]) {
    assert.match(server, new RegExp(path.replaceAll("/", "\\/").replaceAll(".", "\\.")));
  }
  assert.doesNotMatch(game, /pixel-perspective/);
  assert.equal(JSON.parse(packageJson).build.files.some((entry) => entry.startsWith("tools/")), false);
});

test("P1 Living Sanctum renderer changes presentation without owning game rules", async () => {
  const [renderer, game, server] = await Promise.all([
    read("src/pixel-sanctum-renderer.mjs"),
    read("src/game.mjs"),
    read("scripts/serve.mjs"),
  ]);
  assert.deepEqual(validateSanctumPixelStyle(), []);
  assert.equal(SANCTUM_PIXEL_STYLE.materials, PIXEL_PERSPECTIVE.materials);
  assert.equal(SANCTUM_PIXEL_STYLE.worldPixel, 4);

  const operations = [];
  const context = {
    save() {},
    restore() {},
    fillRect(...values) { operations.push(["fill", ...values]); },
    strokeRect(...values) { operations.push(["stroke", ...values]); },
    fillText(...values) { operations.push(["text", ...values]); },
    set fillStyle(value) {},
    set strokeStyle(value) {},
    set lineWidth(value) {},
    set font(value) {},
    set textAlign(value) {},
    set textBaseline(value) {},
    set imageSmoothingEnabled(value) {},
  };
  assert.equal(drawPixelSanctumGround(context, { id: "not-sanctum" }), false);
  assert.equal(drawPixelSanctumGround(context, SANCTUM_PRACTICE_MAP, { highContrast: true }), true);
  for (const obstacle of SANCTUM_PRACTICE_MAP.obstacles) {
    drawPixelSanctumObstacle(context, obstacle, { highContrast: true });
  }
  for (const station of SANCTUM_PRACTICE_MAP.stations) {
    drawPixelSanctumStation(context, station, { active: station.id === "training", highContrast: true });
  }
  assert.equal(drawPixelSanctumForeground(context, SANCTUM_PRACTICE_MAP, { highContrast: true }), true);
  assert.ok(operations.length > 250, "renderer produces a complete terrain and landmark pass");
  assert.ok(operations.every((operation) => operation.slice(1).every((value) => typeof value !== "number" || Number.isFinite(value))));

  assert.match(renderer, /from "\.\/pixel-perspective\.mjs"/);
  assert.doesNotMatch(renderer, /from "\.\/content|from "\.\/match|Math\.random/);
  assert.match(game, /drawPixelSanctumGround\(context, map/);
  assert.match(game, /drawPixelSanctumForeground\(context, map/);
  assert.match(game, /function drawArena\(map, time\) \{\s+if \(drawPixelSanctumGround\(context, map/);
  assert.ok(game.indexOf("drawEntities(time)") < game.indexOf("drawPixelSanctumForeground(context, map"));
  assert.match(server, /"\/src\/pixel-sanctum-renderer\.mjs"/);
});

test("V1 character specimens share one responsive non-shipping harness", async () => {
  const [
    sharedStyles,
    sharedRunner,
    spai,
    urzh,
    wayne,
    nico,
    game,
    server,
    packageJson,
  ] = await Promise.all([
    read("tools/character-specimen.css"),
    read("tools/character-specimen.mjs"),
    read("tools/spai-si-specimen.html"),
    read("tools/urzh-specimen.html"),
    read("tools/s-wayne-specimen.html"),
    read("tools/nico-lai-specimen.html"),
    read("src/game.mjs"),
    read("scripts/serve.mjs"),
    read("package.json"),
  ]);

  assert.match(sharedStyles, /prefers-reduced-motion:\s*reduce/);
  assert.match(sharedStyles, /@media \(max-width:\s*30rem\)/);
  assert.match(sharedRunner, /renderCharacterSpecimen/);
  for (const [name, html] of [
    ["Spai Si", spai],
    ["Urzh", urzh],
    ["S. Wayne", wayne],
    ["Nico Lai", nico],
  ]) {
    assert.match(html, /character-specimen\.css/, name);
    assert.equal((html.match(/data-state=/g) ?? []).length, 6, name);
    assert.match(html, /NON-SHIPPING REFERENCE/, name);
  }
  assert.equal((nico.match(/data-facing=/g) ?? []).length, 6);
  for (const facing of ["up", "down", "left", "right"]) {
    assert.match(nico, new RegExp(`data-facing="${facing}"`));
  }
  assert.match(sharedStyles, /image-rendering:\s*pixelated/);
  assert.match(sharedRunner, /drawOverhaulPixelCharacter/);
  for (const path of [
    "/tools/character-specimen.css",
    "/tools/character-specimen.mjs",
    "/tools/s-wayne-specimen.html",
    "/tools/s-wayne-specimen.mjs",
    "/src/overhaul/characters/s-wayne-visual.mjs",
    "/tools/nico-lai-specimen.html",
    "/tools/nico-lai-specimen.mjs",
    "/src/overhaul/characters/nico-lai-visual.mjs",
    "/src/overhaul-content.mjs",
    "/src/overhaul-runtime.mjs",
  ]) {
    assert.match(server, new RegExp(path.replaceAll("/", "\\/").replace(".", "\\.")));
  }
  assert.match(game, /from "\.\/overhaul-character-visuals\.mjs"/);
  assert.doesNotMatch(game, /nico-lai-visual/);
  assert.equal(
    JSON.parse(packageJson).build.files.some((entry) => entry.startsWith("tools/")),
    false,
  );
});
