const freeze = (value) => {
  if (value && typeof value === "object" && !Object.isFrozen(value)) {
    for (const nested of Object.values(value)) freeze(nested);
    Object.freeze(value);
  }
  return value;
};

const template = (id, name, bodyShape, features, material, motionRead) => freeze({
  id,
  name,
  bodyShape,
  features,
  material,
  motionRead,
  implementationStatus: "visual-template",
});

// Templates encode ancestry only. Champion role, facing prop, affinities, team
// ownership, health wear, and action-state effects are composed separately.
export const ANCESTRY_VISUAL_TEMPLATES = freeze([
  template("human", "Human", "balanced", ["gear"], "woven-cloth", "neutral adaptable stride"),
  template("dwarf", "Dwarf", "broad", ["block-shoulders", "beard"], "forged-metal", "low planted drive"),
  template("gnome", "Gnome", "compact", ["high-cap"], "tooled-leather", "quick measured steps"),
  template("hobbit", "Hobbit", "low", ["bare-feet"], "woven-cloth", "quiet low-footed turn"),
  template("elf", "Elf", "tall", ["long-ears"], "woven-cloth", "deliberate long-line turn"),
  template("orc", "Orc", "broad", ["tusks"], "forged-metal", "weighted shoulder lead"),
  template("troll", "Troll", "huge", ["moss-horns"], "old-stone", "slow inward brace"),
  template("minotaur", "Minotaur", "huge", ["broad-horns", "muzzle"], "tooled-leather", "hoof-led commitment"),
  template("seakin", "Seakin", "compact", ["cheek-fins"], "tide-worn-bronze", "fluid lateral turn"),
  template("wyrmborn", "Wyrmborn", "winged", ["scaled-wings", "long-tail"], "scale", "aerial attack pitch"),
  template("stoneborn", "Stoneborn", "block", ["block-shoulders", "ember-seams"], "old-stone", "braced translation"),
  template("treefolk", "Treefolk", "rooted", ["branch-crown", "root-feet"], "living-wood", "rooted weight shift"),
  template("sylph", "Sylph", "light", ["streamer-wings"], "woven-light", "floating route turn"),
  template("undead", "Undead", "tall", ["rune-ribs"], "aged-bone", "rigid formation pivot"),
  template("goblin", "Goblin", "compact", ["large-ears"], "patched-leather", "fast tool-led scramble"),
  template("nymph", "Nymph", "light", ["petal-mantle"], "living-fiber", "blooming sidestep"),
  template("vampire", "Vampire", "balanced", ["high-collar", "fangs"], "woven-cloth", "controlled pursuit glide"),
  template("werewolf", "Werewolf", "broad", ["wolf-muzzle", "mane"], "fur", "forward-weighted lope"),
  template("angel", "Angel", "winged", ["feather-wings", "plain-halo"], "woven-light", "measured wing-set turn"),
  template("demon", "Demon", "balanced", ["swept-horns", "ember-tail"], "chthonic-cloth", "poised angular advance"),
]);

const TEMPLATE_BY_ID = new Map(ANCESTRY_VISUAL_TEMPLATES.map((entry) => [entry.id, entry]));

export function getAncestryVisualTemplate(id) {
  return TEMPLATE_BY_ID.get(id) ?? null;
}

export function composeCharacterVisualProfile({ ancestryId, ...champion }) {
  const ancestryTemplate = getAncestryVisualTemplate(ancestryId);
  if (!ancestryTemplate) throw new Error(`Unknown ancestry visual template: ${ancestryId}`);
  if (!champion.id || !champion.name || !champion.roleRead || !champion.focusProp) {
    throw new Error("Character visual profiles require id, name, roleRead, and focusProp");
  }
  return freeze({
    ...champion,
    ancestryId,
    plannedAncestry: ancestryTemplate.name,
    ancestryRead: champion.ancestryRead ?? ancestryTemplate.features.join(" + "),
    ancestryTemplate,
  });
}

export function validateAncestryVisualTemplates() {
  const errors = [];
  const ids = new Set();
  for (const entry of ANCESTRY_VISUAL_TEMPLATES) {
    if (ids.has(entry.id)) errors.push(`duplicate ancestry template: ${entry.id}`);
    ids.add(entry.id);
    if (!BODY_SHAPES[entry.bodyShape]) errors.push(`${entry.id}: unknown body shape ${entry.bodyShape}`);
    if (!entry.features.length) errors.push(`${entry.id}: ancestry cue required`);
    for (const feature of entry.features) {
      if (!FEATURE_RENDERERS[feature]) errors.push(`${entry.id}: unknown feature ${feature}`);
    }
  }
  if (ANCESTRY_VISUAL_TEMPLATES.length !== 20) errors.push("exactly twenty ancestry templates required");
  return errors;
}

export function traceAncestryBody(context, ancestryTemplate, radius) {
  const points = BODY_SHAPES[ancestryTemplate?.bodyShape];
  if (!points) return false;
  tracePolygon(context, points.map(([x, y]) => [x * radius, y * radius]));
  return true;
}

export function drawAncestryFeatures(context, profile, radius) {
  const ancestryTemplate = profile?.ancestryTemplate;
  if (!ancestryTemplate) return false;
  context.save();
  try {
    context.shadowBlur = 0;
    context.lineJoin = "bevel";
    context.lineCap = "round";
    for (const feature of ancestryTemplate.features) {
      FEATURE_RENDERERS[feature](context, profile, radius);
    }
  } finally {
    context.restore();
  }
  return true;
}

const BODY_SHAPES = freeze({
  balanced: [[1.12, 0], [0.44, 0.62], [-0.28, 0.82], [-0.84, 0.56], [-0.84, -0.56], [-0.28, -0.82], [0.44, -0.62]],
  broad: [[1.02, 0], [0.46, 0.82], [-0.66, 0.9], [-1.02, 0.48], [-1.02, -0.48], [-0.66, -0.9], [0.46, -0.82]],
  compact: [[1.02, 0], [0.36, 0.7], [-0.58, 0.66], [-0.86, 0], [-0.58, -0.66], [0.36, -0.7]],
  low: [[1.08, 0], [0.26, 0.58], [-0.72, 0.54], [-0.92, 0], [-0.72, -0.54], [0.26, -0.58]],
  tall: [[1.1, 0], [0.34, 0.68], [-0.4, 0.96], [-0.82, 0.5], [-0.82, -0.5], [-0.4, -0.96], [0.34, -0.68]],
  huge: [[1.06, 0], [0.64, 0.9], [-0.72, 0.98], [-1.12, 0.48], [-1.12, -0.48], [-0.72, -0.98], [0.64, -0.9]],
  winged: [[1.14, 0], [0.38, 0.5], [-0.22, 0.94], [-0.48, 0.58], [-1.04, 0.9], [-0.76, 0], [-1.04, -0.9], [-0.48, -0.58], [-0.22, -0.94], [0.38, -0.5]],
  block: [[1.06, -0.54], [1.12, 0.42], [0.46, 0.92], [-0.72, 0.84], [-1.02, 0.42], [-1.02, -0.62], [-0.42, -0.94], [0.48, -0.88]],
  rooted: [[1.02, 0], [0.42, 0.7], [-0.18, 0.68], [-0.72, 1], [-0.92, 0.44], [-0.76, 0], [-0.92, -0.44], [-0.72, -1], [-0.18, -0.68], [0.42, -0.7]],
  light: [[1.12, 0], [0.28, 0.54], [-0.22, 0.82], [-0.74, 0.42], [-0.74, -0.42], [-0.22, -0.82], [0.28, -0.54]],
});

const FEATURE_RENDERERS = {
  gear: (c, p, r) => diamond(c, p.mantle, p.ink, -r * 0.08, 0, r * 0.34),
  "block-shoulders": (c, p, r) => pairedTriangles(c, p.earth ?? p.body, p.ink, r, 0.78),
  beard: (c, p, r) => triangle(c, p.hair ?? p.mantle, p.ink, -r * 0.28, 0, r * 0.48, 1),
  "high-cap": (c, p, r) => triangle(c, p.mantle, p.ink, -r * 0.18, 0, r * 0.66, -1),
  "bare-feet": (c, p, r) => pairedDots(c, p.body, p.ink, -r * 0.55, r * 0.62, r * 0.16),
  "long-ears": (c, p, r) => pairedTriangles(c, p.body, p.ink, r, 1.12),
  tusks: (c, p, r) => pairedTriangles(c, "#e7dec0", p.ink, r * 0.68, 0.58),
  "moss-horns": (c, p, r) => pairedCurves(c, p.earth ?? p.body, r, 1.02),
  "broad-horns": (c, p, r) => pairedCurves(c, p.body, r, 1.25),
  muzzle: (c, p, r) => diamond(c, p.mantle, p.ink, r * 0.48, 0, r * 0.28),
  "cheek-fins": (c, p, r) => pairedTriangles(c, p.water ?? p.body, p.ink, r * 0.12, 0.9),
  "scaled-wings": (c, p, r) => pairedTriangles(c, p.mantle, p.ink, -r * 0.46, 1.22),
  "long-tail": (c, p, r) => tail(c, p.mantle, r, 1.22),
  "ember-seams": (c, p, r) => seam(c, p.fire ?? p.focus ?? "#c76632", r),
  "branch-crown": (c, p, r) => crown(c, p.earth ?? p.body, r),
  "root-feet": (c, p, r) => pairedLines(c, p.earth ?? p.body, -r * 0.52, r * 0.82, r * 0.4),
  "streamer-wings": (c, p, r) => pairedCurves(c, p.wind ?? p.body, r, 1.3),
  "rune-ribs": (c, p, r) => ribs(c, p.light ?? p.body, r),
  "large-ears": (c, p, r) => pairedTriangles(c, p.body, p.ink, -r * 0.02, 1.22),
  "petal-mantle": (c, p, r) => petals(c, p.mantle, p.ink, r),
  "high-collar": (c, p, r) => pairedTriangles(c, p.mantle, p.ink, -r * 0.34, 0.72),
  fangs: (c, p, r) => pairedDots(c, "#e7dec0", p.ink, r * 0.58, r * 0.18, r * 0.08),
  "wolf-muzzle": (c, p, r) => diamond(c, p.mantle, p.ink, r * 0.58, 0, r * 0.3),
  mane: (c, p, r) => crown(c, p.hair ?? p.mantle, r * 0.76),
  "feather-wings": (c, p, r) => pairedTriangles(c, p.light ?? p.body, p.ink, -r * 0.42, 1.34),
  "plain-halo": (c, p, r) => ring(c, p.light ?? p.body, -r * 0.42, 0, r * 0.34),
  "swept-horns": (c, p, r) => pairedCurves(c, p.light ?? p.body, r, 1.15),
  "ember-tail": (c, p, r) => tail(c, p.ember ?? p.fire ?? p.body, r, 1.2),
};

function pairedTriangles(c, fill, stroke, r, spread) {
  for (const side of [-1, 1]) triangle(c, fill, stroke, -r * 0.12, side * r * 0.46, r * 0.52, side * spread);
}
function triangle(c, fill, stroke, x, y, size, direction) {
  c.fillStyle = fill; c.strokeStyle = stroke; c.lineWidth = 1.4;
  c.beginPath(); c.moveTo(x, y); c.lineTo(x - size * 0.72, y + size * direction); c.lineTo(x + size * 0.42, y + size * direction * 0.5); c.closePath(); c.fill(); c.stroke();
}
function pairedCurves(c, stroke, r, spread) {
  c.strokeStyle = stroke; c.lineWidth = 2;
  for (const side of [-1, 1]) { c.beginPath(); c.moveTo(-r * 0.12, side * r * 0.42); c.quadraticCurveTo(-r * 0.72, side * r * spread, -r * 0.28, side * r * 1.12); c.stroke(); }
}
function tail(c, stroke, r, drop) { c.strokeStyle = stroke; c.lineWidth = 2.3; c.beginPath(); c.moveTo(-r * 0.58, r * 0.14); c.quadraticCurveTo(-r * 1.24, r * 0.72, -r * 0.72, r * drop); c.stroke(); }
function seam(c, stroke, r) { c.strokeStyle = stroke; c.lineWidth = 2.2; c.beginPath(); c.moveTo(-r * 0.5, 0); c.lineTo(-r * 0.12, -r * 0.18); c.lineTo(r * 0.12, r * 0.16); c.lineTo(r * 0.48, 0); c.stroke(); }
function diamond(c, fill, stroke, x, y, size) { c.fillStyle = fill; c.strokeStyle = stroke; c.beginPath(); c.moveTo(x + size, y); c.lineTo(x, y + size * 0.7); c.lineTo(x - size, y); c.lineTo(x, y - size * 0.7); c.closePath(); c.fill(); c.stroke(); }
function pairedDots(c, fill, stroke, x, spread, size) { c.fillStyle = fill; c.strokeStyle = stroke; for (const side of [-1, 1]) { c.beginPath(); c.arc(x, side * spread, size, 0, Math.PI * 2); c.fill(); c.stroke(); } }
function pairedLines(c, stroke, x, spread, length) { c.strokeStyle = stroke; c.lineWidth = 2; for (const side of [-1, 1]) { c.beginPath(); c.moveTo(x, side * spread); c.lineTo(x - length, side * (spread + length * 0.3)); c.stroke(); } }
function crown(c, stroke, r) { c.strokeStyle = stroke; c.lineWidth = 2; for (const side of [-1, 0, 1]) { c.beginPath(); c.moveTo(-r * 0.28, side * r * 0.42); c.lineTo(-r * 0.72, side * r * 0.72); c.stroke(); } }
function ribs(c, stroke, r) { c.strokeStyle = stroke; c.lineWidth = 1.5; for (const side of [-1, 1]) for (const offset of [-0.28, 0, 0.28]) { c.beginPath(); c.moveTo(-r * 0.28, side * r * offset); c.lineTo(r * 0.26, side * r * (offset + 0.14)); c.stroke(); } }
function petals(c, fill, stroke, r) { for (let i = 0; i < 4; i += 1) { const a = i * Math.PI / 2; diamond(c, fill, stroke, Math.cos(a) * r * 0.42, Math.sin(a) * r * 0.42, r * 0.22); } }
function ring(c, stroke, x, y, radius) { c.strokeStyle = stroke; c.lineWidth = 1.8; c.beginPath(); c.arc(x, y, radius, 0, Math.PI * 2); c.stroke(); }
function tracePolygon(context, points) { context.beginPath(); for (const [index, [x, y]] of points.entries()) index === 0 ? context.moveTo(x, y) : context.lineTo(x, y); context.closePath(); }
