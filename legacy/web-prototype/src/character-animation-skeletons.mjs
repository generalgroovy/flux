import { ANCESTRY_VISUAL_TEMPLATES } from "./ancestry-visual-templates.mjs";

const deepFreeze = (value) => {
  if (value && typeof value === "object" && !Object.isFrozen(value)) {
    for (const nested of Object.values(value)) deepFreeze(nested);
    Object.freeze(value);
  }
  return value;
};

const point = (x, y) => ({ x, y });
const clonePoint = (entry) => point(entry.x, entry.y);
const addPoint = (entry, dx = 0, dy = 0) => point(entry.x + dx, entry.y + dy);
const clamp = (value, min, max) => Math.max(min, Math.min(max, value));
const finite = (value, fallback = 0) => Number.isFinite(Number(value)) ? Number(value) : fallback;
const normalizedPhase = (value) => ((finite(value) % 1) + 1) % 1;

export const ANIMATION_DIRECTIONS = deepFreeze([
  { id: "south", x: 0, y: 1 },
  { id: "southeast", x: 1, y: 1 },
  { id: "east", x: 1, y: 0 },
  { id: "northeast", x: 1, y: -1 },
  { id: "north", x: 0, y: -1 },
  { id: "northwest", x: -1, y: -1 },
  { id: "west", x: -1, y: 0 },
  { id: "southwest", x: -1, y: 1 },
]);

const DIRECTION_BY_ID = new Map(ANIMATION_DIRECTIONS.map((entry) => [entry.id, entry]));

export const CHARACTER_ANIMATION_STATE_DEFINITIONS = deepFreeze({
  idle: { frames: 2, frameMs: 260, loop: true },
  move: { frames: 4, frameMs: 95, loop: true },
  sprint: { frames: 4, frameMs: 76, loop: true },
  jump: { frames: 3, frameMs: 90, loop: false },
  fall: { frames: 2, frameMs: 110, loop: true },
  slide: { frames: 3, frameMs: 82, loop: false },
  dodge: { frames: 4, frameMs: 68, loop: false },
  commit: { frames: 3, frameMs: 92, loop: false },
  defend: { frames: 2, frameMs: 120, loop: true },
  hit: { frames: 2, frameMs: 72, loop: false },
  defeated: { frames: 4, frameMs: 130, loop: false },
});

export const CHARACTER_ANIMATION_STATES = deepFreeze(
  Object.keys(CHARACTER_ANIMATION_STATE_DEFINITIONS),
);

export const CHARACTER_SKELETON_SIZES = deepFreeze({
  1: { label: "Tiny", bodyHeight: 13, shoulderWidth: 5.8, headRadius: 4.1, outline: 1, shadowWidth: 7.5, shadowHeight: 2.5 },
  2: { label: "Small", bodyHeight: 16, shoulderWidth: 7.2, headRadius: 4.6, outline: 1, shadowWidth: 9.5, shadowHeight: 3 },
  3: { label: "Medium", bodyHeight: 19, shoulderWidth: 8.8, headRadius: 5.1, outline: 1, shadowWidth: 11.5, shadowHeight: 3.5 },
  4: { label: "Large", bodyHeight: 22, shoulderWidth: 10.7, headRadius: 5.7, outline: 1.25, shadowWidth: 14, shadowHeight: 4 },
  5: { label: "Huge", bodyHeight: 24, shoulderWidth: 12.2, headRadius: 6.2, outline: 1.25, shadowWidth: 17, shadowHeight: 4.5 },
});

export const ANCESTRY_ANIMATION_ALIASES = deepFreeze({
  scaleheir: "wyrmborn",
  wyrm: "wyrmborn",
  stonewrought: "stoneborn",
  rootwarden: "treefolk",
  ent: "treefolk",
});

export const ANCESTRY_SKELETON_OVERRIDES = deepFreeze({
  human: { posture: "balanced", heightScale: 1, widthScale: 1, headScale: 1, legScale: 1, armScale: 1, lean: 0, attachments: ["gear"] },
  dwarf: { posture: "planted", heightScale: 0.86, widthScale: 1.2, headScale: 1.02, legScale: 0.82, armScale: 0.92, lean: 0.1, attachments: ["block-shoulders", "beard"] },
  gnome: { posture: "measured", heightScale: 0.82, widthScale: 0.88, headScale: 1.12, legScale: 0.82, armScale: 0.9, lean: 0, attachments: ["high-cap"] },
  hobbit: { posture: "low", heightScale: 0.78, widthScale: 0.94, headScale: 1.08, legScale: 0.76, armScale: 0.88, lean: 0.08, attachments: ["bare-feet"] },
  elf: { posture: "tall", heightScale: 1.12, widthScale: 0.88, headScale: 0.96, legScale: 1.12, armScale: 1.08, lean: 0, attachments: ["long-ears"] },
  orc: { posture: "weighted", heightScale: 1.02, widthScale: 1.18, headScale: 1.02, legScale: 0.98, armScale: 1.08, lean: 0.35, attachments: ["tusks"] },
  troll: { posture: "inward-brace", heightScale: 1.08, widthScale: 1.22, headScale: 1.04, legScale: 0.94, armScale: 1.1, lean: 0.22, attachments: ["moss-horns"] },
  minotaur: { posture: "hoof-led", heightScale: 1.08, widthScale: 1.24, headScale: 1.08, legScale: 0.94, armScale: 1.08, lean: 0.52, attachments: ["broad-horns", "muzzle"] },
  seakin: { posture: "fluid", heightScale: 0.92, widthScale: 0.96, headScale: 1.06, legScale: 0.92, armScale: 0.98, lean: 0.04, attachments: ["cheek-fins"] },
  wyrmborn: { posture: "aerial", heightScale: 1.04, widthScale: 1.02, headScale: 1, legScale: 0.98, armScale: 1, lean: 0.2, attachments: ["scaled-wings", "long-tail"] },
  stoneborn: { posture: "braced", heightScale: 0.96, widthScale: 1.2, headScale: 1.02, legScale: 0.86, armScale: 0.92, lean: 0.06, attachments: ["block-shoulders", "ember-seams"] },
  treefolk: { posture: "rooted", heightScale: 1.12, widthScale: 1.18, headScale: 1.02, legScale: 0.9, armScale: 1.06, lean: 0, attachments: ["branch-crown", "root-feet"] },
  sylph: { posture: "floating", heightScale: 0.9, widthScale: 0.82, headScale: 1, legScale: 0.98, armScale: 1.08, lean: -0.08, attachments: ["streamer-wings"] },
  undead: { posture: "rigid", heightScale: 1.1, widthScale: 0.86, headScale: 0.94, legScale: 1.08, armScale: 1.02, lean: 0, attachments: ["rune-ribs"] },
  goblin: { posture: "scramble", heightScale: 0.78, widthScale: 0.94, headScale: 1.14, legScale: 0.8, armScale: 0.92, lean: 0.26, attachments: ["large-ears"] },
  nymph: { posture: "bloom", heightScale: 0.88, widthScale: 0.86, headScale: 1.04, legScale: 0.92, armScale: 1.04, lean: -0.04, attachments: ["petal-mantle"] },
  vampire: { posture: "pursuit", heightScale: 1.02, widthScale: 0.9, headScale: 0.98, legScale: 1.02, armScale: 1.02, lean: 0.08, attachments: ["high-collar", "fangs"] },
  werewolf: { posture: "forward", heightScale: 1.02, widthScale: 1.16, headScale: 1.08, legScale: 0.96, armScale: 1.08, lean: 0.74, attachments: ["wolf-muzzle", "mane"] },
  angel: { posture: "measured-wing", heightScale: 1.04, widthScale: 0.92, headScale: 0.98, legScale: 1.02, armScale: 1.04, lean: -0.04, attachments: ["feather-wings", "plain-halo"] },
  demon: { posture: "angular", heightScale: 1, widthScale: 0.96, headScale: 1, legScale: 1, armScale: 1.04, lean: 0.18, attachments: ["swept-horns", "ember-tail"] },
});

const TEMPLATE_BY_ID = new Map(
  ANCESTRY_VISUAL_TEMPLATES.map((entry) => [entry.id, entry]),
);

export function canonicalAnimationAncestry(id) {
  const normalized = String(id ?? "").trim().toLowerCase();
  const resolved = ANCESTRY_ANIMATION_ALIASES[normalized] ?? normalized;
  return TEMPLATE_BY_ID.has(resolved) ? resolved : null;
}

export function createAnimationSkeleton({
  ancestryId,
  size,
  skeletonOverrides = {},
} = {}) {
  const resolvedAncestryId = canonicalAnimationAncestry(ancestryId);
  if (!resolvedAncestryId) throw new Error(`Unknown animation ancestry: ${ancestryId}`);
  const sizeRule = CHARACTER_SKELETON_SIZES[size];
  if (!sizeRule) throw new Error(`Unknown character animation size: ${size}`);

  const ancestry = ANCESTRY_SKELETON_OVERRIDES[resolvedAncestryId];
  const proportions = {
    ...ancestry,
    ...(skeletonOverrides.proportions ?? {}),
  };
  const groundY = 28 + finite(skeletonOverrides.groundOffsetY);
  const bodyHeight = clamp(sizeRule.bodyHeight * finite(proportions.heightScale, 1), 9, 27);
  const shoulderWidth = clamp(sizeRule.shoulderWidth * finite(proportions.widthScale, 1), 4, 14);
  const headRadius = clamp(sizeRule.headRadius * finite(proportions.headScale, 1), 3.4, 6.8);
  const legScale = clamp(finite(proportions.legScale, 1), 0.65, 1.25);
  const armScale = clamp(finite(proportions.armScale, 1), 0.65, 1.25);
  const lean = clamp(finite(proportions.lean), -1.5, 1.5);
  const centerX = 16;
  const headY = groundY - bodyHeight + headRadius;
  const neckY = headY + headRadius * 0.78;
  const chestY = groundY - bodyHeight * 0.5;
  const hipY = groundY - bodyHeight * 0.25 * legScale;
  const shoulderY = chestY - bodyHeight * 0.07;
  const handY = chestY + bodyHeight * 0.2 * armScale;
  const footSpread = shoulderWidth * 0.22;

  const bones = {
    root: point(centerX, groundY),
    hip: point(centerX - lean * 0.12, hipY),
    chest: point(centerX + lean * 0.38, chestY),
    neck: point(centerX + lean * 0.6, neckY),
    head: point(centerX + lean, headY),
    leftShoulder: point(centerX + lean * 0.36 - shoulderWidth / 2, shoulderY),
    rightShoulder: point(centerX + lean * 0.36 + shoulderWidth / 2, shoulderY),
    leftElbow: point(centerX - shoulderWidth * 0.58, chestY + bodyHeight * 0.08),
    rightElbow: point(centerX + shoulderWidth * 0.58, chestY + bodyHeight * 0.08),
    leftHand: point(centerX - shoulderWidth * 0.66, handY),
    rightHand: point(centerX + shoulderWidth * 0.66, handY),
    leftKnee: point(centerX - footSpread * 0.76, (hipY + groundY) / 2),
    rightKnee: point(centerX + footSpread * 0.76, (hipY + groundY) / 2),
    leftFoot: point(centerX - footSpread, groundY),
    rightFoot: point(centerX + footSpread, groundY),
  };

  for (const [boneId, offset] of Object.entries(skeletonOverrides.boneOffsets ?? {})) {
    if (!bones[boneId]) throw new Error(`Unknown character skeleton bone: ${boneId}`);
    bones[boneId] = addPoint(bones[boneId], finite(offset?.x), finite(offset?.y));
  }

  const draft = {
    bones,
    metrics: {
      bodyHeight,
      shoulderWidth,
      headRadius,
      outline: sizeRule.outline,
      shadowWidth: sizeRule.shadowWidth,
      shadowHeight: sizeRule.shadowHeight,
    },
  };
  const attachmentFeatures = [
    ...new Set([
      ...ancestry.attachments,
      ...(skeletonOverrides.extraAttachmentFeatures ?? []),
    ]),
  ];
  const attachments = attachmentFeatures.map((feature) => createAttachment(feature, draft));
  for (const extra of skeletonOverrides.extraAttachments ?? []) {
    if (!extra?.id || !Array.isArray(extra.anchors) || extra.anchors.length === 0) {
      throw new Error("Custom skeleton attachments require id and anchors");
    }
    attachments.push({
      id: String(extra.id),
      anchors: extra.anchors.map((anchor) => point(finite(anchor.x), finite(anchor.y))),
    });
  }

  const allPoints = [
    ...Object.values(bones),
    ...attachments.flatMap((entry) => entry.anchors),
  ];
  const bounds = boundsFor(allPoints, 1.5);
  const ancestryTemplate = TEMPLATE_BY_ID.get(resolvedAncestryId);

  return deepFreeze({
    version: 1,
    cell: { width: 32, height: 32 },
    groundAnchor: point(centerX, groundY),
    size: Number(size),
    sizeLabel: sizeRule.label,
    ancestryId: resolvedAncestryId,
    ancestryTemplateId: ancestryTemplate.id,
    posture: ancestry.posture,
    motionRead: ancestryTemplate.motionRead,
    bones,
    attachments,
    bounds,
    metrics: draft.metrics,
    shadow: {
      center: point(centerX, groundY + 0.5),
      width: sizeRule.shadowWidth,
      height: sizeRule.shadowHeight,
    },
    layers: ["shadow", "rear-attachments", "body", "front-attachments", "focus", "aura"],
  });
}

export function createAnimationManifest(definition = {}) {
  const id = String(definition.id ?? "").trim();
  const name = String(definition.name ?? "").trim();
  if (!id || !name) throw new Error("Character animation manifests require id and name");

  const skeleton = createAnimationSkeleton({
    ancestryId: definition.ancestryId,
    size: definition.size,
    skeletonOverrides: definition.skeletonOverrides,
  });
  const directions = [...(definition.directions ?? ANIMATION_DIRECTIONS.map((entry) => entry.id))];
  for (const directionId of directions) {
    if (!DIRECTION_BY_ID.has(directionId)) throw new Error(`Unknown animation direction: ${directionId}`);
  }
  if (new Set(directions).size !== directions.length) {
    throw new Error(`Duplicate animation direction in ${id}`);
  }

  const requestedStates = definition.states ?? CHARACTER_ANIMATION_STATE_DEFINITIONS;
  const stateEntries = Array.isArray(requestedStates)
    ? requestedStates.map((stateId) => [stateId, CHARACTER_ANIMATION_STATE_DEFINITIONS[stateId]])
    : Object.entries(requestedStates);
  const clips = {};
  for (const [stateId, stateDefinition] of stateEntries) {
    const base = CHARACTER_ANIMATION_STATE_DEFINITIONS[stateId];
    if (!base) throw new Error(`Unknown character animation state: ${stateId}`);
    const merged = { ...base, ...(stateDefinition ?? {}) };
    if (!Number.isInteger(merged.frames) || merged.frames < 1) {
      throw new Error(`${id}.${stateId} requires a positive frame count`);
    }
    if (!Number.isFinite(merged.frameMs) || merged.frameMs <= 0) {
      throw new Error(`${id}.${stateId} requires a positive frame duration`);
    }
    clips[stateId] = {
      id: stateId,
      frames: merged.frames,
      frameMs: merged.frameMs,
      loop: Boolean(merged.loop),
      rows: directions.length,
      columns: merged.frames,
    };
  }

  const assetRoot = String(definition.assetRoot ?? `assets/characters/${id}`);
  return deepFreeze({
    ...definition,
    version: 1,
    id,
    name,
    ancestryId: skeleton.ancestryId,
    size: skeleton.size,
    status: definition.status ?? "skeleton-only",
    skeleton,
    directions,
    states: Object.keys(clips),
    clips,
    spriteSheet: {
      mode: "state-strips",
      assetRoot,
      pathTemplate: `${assetRoot}/{state}.png`,
      cellWidth: skeleton.cell.width,
      cellHeight: skeleton.cell.height,
      directionRows: directions,
      frameColumnsByState: Object.fromEntries(
        Object.entries(clips).map(([stateId, clip]) => [stateId, clip.frames]),
      ),
    },
    modSlots: [
      "palette",
      "focusProp",
      "skeletonOverrides",
      "stateTiming",
      "attachments",
      "spriteSheets",
    ],
  });
}

export function resolveAnimationPose(manifestOrSkeleton, stateId, directionId, phase = 0) {
  const skeleton = manifestOrSkeleton?.skeleton ?? manifestOrSkeleton;
  if (!skeleton?.bones) throw new Error("Animation pose resolution requires a skeleton or manifest");
  const direction = DIRECTION_BY_ID.get(directionId);
  if (!direction) throw new Error(`Unknown animation direction: ${directionId}`);
  const definition = CHARACTER_ANIMATION_STATE_DEFINITIONS[stateId];
  if (!definition) throw new Error(`Unknown character animation state: ${stateId}`);

  const progress = definition.loop ? normalizedPhase(phase) : clamp(finite(phase), 0, 0.999999);
  const wave = Math.sin(progress * Math.PI * 2);
  const arch = Math.sin(progress * Math.PI);
  const bones = Object.fromEntries(
    Object.entries(skeleton.bones).map(([id, entry]) => [id, clonePoint(entry)]),
  );
  const attachments = skeleton.attachments.map((entry) => ({
    id: entry.id,
    anchors: entry.anchors.map(clonePoint),
  }));
  const bodyOffset = point(0, 0);
  const bodyScale = point(1, 1);
  let rotation = 0;

  if (stateId === "idle") {
    bodyOffset.y = -wave * 0.22;
  } else if (stateId === "move") {
    bodyOffset.y = -Math.abs(wave) * 0.55;
    swingLimbs(bones, wave, 1.15);
  } else if (stateId === "sprint") {
    bodyOffset.x = direction.x * 0.35;
    bodyOffset.y = -Math.abs(wave) * 0.75;
    rotation = direction.x * 0.07;
    swingLimbs(bones, wave, 1.65);
  } else if (stateId === "jump") {
    bodyOffset.x = direction.x * arch * 0.6;
    bodyOffset.y = -arch * (3.2 + skeleton.size * 0.35);
  } else if (stateId === "fall") {
    bodyOffset.x = direction.x * 0.3;
    bodyOffset.y = -(1 - progress) * (1.6 + skeleton.size * 0.15);
  } else if (stateId === "slide") {
    bodyOffset.x = direction.x * arch * 1.1;
    bodyOffset.y = 2.2;
    bodyScale.y = 0.7;
    rotation = direction.x * 0.11;
  } else if (stateId === "dodge") {
    bodyOffset.x = direction.x * arch * 2.6;
    bodyOffset.y = direction.y * arch * 0.7 - arch * 0.45;
    rotation = direction.x * 0.16;
  } else if (stateId === "commit") {
    bones.rightHand = addPoint(bones.rightHand, direction.x * 1.8, direction.y * 1.1);
    bones.leftHand = addPoint(bones.leftHand, direction.x * 0.65, direction.y * 0.35);
    rotation = direction.x * 0.035;
  } else if (stateId === "defend") {
    bones.rightHand = addPoint(bones.rightHand, direction.x * 1.1, direction.y * 0.8 - 0.4);
    bones.leftHand = addPoint(bones.leftHand, direction.x * 1.1, direction.y * 0.8 - 0.4);
    bodyScale.x = 1.04;
  } else if (stateId === "hit") {
    bodyOffset.x = -direction.x * arch * 1.35;
    bodyOffset.y = -direction.y * arch * 0.45;
    rotation = -direction.x * 0.12;
  } else if (stateId === "defeated") {
    bodyOffset.x = direction.x * progress * 0.8;
    bodyOffset.y = 4.1;
    bodyScale.y = 0.42;
    rotation = direction.x * 0.28;
  }

  shiftPosePoints(bones, attachments, bodyOffset.x, bodyOffset.y);
  const frameIndex = Math.min(
    definition.frames - 1,
    Math.floor(progress * definition.frames),
  );
  return deepFreeze({
    state: stateId,
    direction: directionId,
    phase: progress,
    frameIndex,
    bodyOffset,
    bodyScale,
    rotation,
    bones,
    attachments,
    groundAnchor: skeleton.groundAnchor,
    shadow: skeleton.shadow,
  });
}

export function createCharacterAnimationRegistry(initialEntries = []) {
  const byId = new Map();
  const registry = {
    register(definition, { replace = false } = {}) {
      const manifest = definition?.skeleton
        ? definition
        : createAnimationManifest(definition);
      const errors = validateAnimationManifest(manifest);
      if (errors.length > 0) throw new Error(errors.join("; "));
      if (byId.has(manifest.id) && !replace) {
        throw new Error(`Character animation manifest already registered: ${manifest.id}`);
      }
      byId.set(manifest.id, manifest);
      return manifest;
    },
    unregister(id) {
      return byId.delete(id);
    },
    get(id) {
      return byId.get(id) ?? null;
    },
    has(id) {
      return byId.has(id);
    },
    list() {
      return deepFreeze([...byId.values()]);
    },
    ids() {
      return deepFreeze([...byId.keys()]);
    },
  };
  for (const entry of initialEntries) registry.register(entry);
  return Object.freeze(registry);
}

export function validateCharacterAnimationSystem(manifests = []) {
  const errors = [];
  if (ANIMATION_DIRECTIONS.length !== 8) errors.push("exactly eight animation directions required");
  if (Object.keys(CHARACTER_SKELETON_SIZES).length !== 5) errors.push("exactly five character sizes required");
  if (Object.keys(ANCESTRY_SKELETON_OVERRIDES).length !== 20) errors.push("exactly twenty ancestry skeleton overrides required");

  const templateIds = ANCESTRY_VISUAL_TEMPLATES.map((entry) => entry.id).sort();
  const overrideIds = Object.keys(ANCESTRY_SKELETON_OVERRIDES).sort();
  if (JSON.stringify(templateIds) !== JSON.stringify(overrideIds)) {
    errors.push("ancestry animation skeletons must cover every ancestry visual template");
  }

  for (const ancestryId of templateIds) {
    for (const size of Object.keys(CHARACTER_SKELETON_SIZES).map(Number)) {
      let skeleton;
      try {
        skeleton = createAnimationSkeleton({ ancestryId, size });
      } catch (error) {
        errors.push(`${ancestryId}/${size}: ${error.message}`);
        continue;
      }
      for (const [boneId, entry] of Object.entries(skeleton.bones)) {
        if (!finitePoint(entry)) errors.push(`${ancestryId}/${size}: invalid bone ${boneId}`);
        if (!insideCell(entry, skeleton.cell, 3)) errors.push(`${ancestryId}/${size}: bone outside cell ${boneId}`);
      }
      for (const attachment of skeleton.attachments) {
        if (!attachment.anchors.every((entry) => finitePoint(entry))) {
          errors.push(`${ancestryId}/${size}: invalid attachment ${attachment.id}`);
        }
      }
    }
  }

  const ids = new Set();
  for (const manifest of manifests) {
    if (ids.has(manifest.id)) errors.push(`duplicate character animation manifest: ${manifest.id}`);
    ids.add(manifest.id);
    errors.push(...validateAnimationManifest(manifest));
  }
  return errors;
}

function validateAnimationManifest(manifest) {
  const errors = [];
  if (!manifest?.id || !manifest?.name) errors.push("character animation manifest requires id and name");
  if (!manifest?.skeleton?.bones) errors.push(`${manifest?.id ?? "unknown"}: skeleton required`);
  if (!Array.isArray(manifest?.directions) || manifest.directions.length === 0) errors.push(`${manifest?.id ?? "unknown"}: directions required`);
  if (!Array.isArray(manifest?.states) || manifest.states.length === 0) errors.push(`${manifest?.id ?? "unknown"}: states required`);
  for (const directionId of manifest?.directions ?? []) {
    if (!DIRECTION_BY_ID.has(directionId)) errors.push(`${manifest.id}: unknown direction ${directionId}`);
  }
  for (const stateId of manifest?.states ?? []) {
    if (!manifest.clips?.[stateId]) errors.push(`${manifest.id}: missing clip ${stateId}`);
  }
  return errors;
}

function createAttachment(feature, skeleton) {
  const { bones, metrics } = skeleton;
  const head = bones.head;
  const chest = bones.chest;
  const hip = bones.hip;
  const shoulderSpread = metrics.shoulderWidth / 2;
  const headRadius = metrics.headRadius;
  const resolvers = {
    gear: () => [clonePoint(chest)],
    "block-shoulders": () => [clonePoint(bones.leftShoulder), clonePoint(bones.rightShoulder)],
    beard: () => [addPoint(head, 0, headRadius * 0.72)],
    "high-cap": () => [addPoint(head, 0, -headRadius * 0.82)],
    "bare-feet": () => [clonePoint(bones.leftFoot), clonePoint(bones.rightFoot)],
    "long-ears": () => [addPoint(head, -headRadius * 0.92, -0.2), addPoint(head, headRadius * 0.92, -0.2)],
    tusks: () => [addPoint(head, -headRadius * 0.5, headRadius * 0.48), addPoint(head, headRadius * 0.5, headRadius * 0.48)],
    "moss-horns": () => [addPoint(head, -headRadius * 0.76, -headRadius * 0.62), addPoint(head, headRadius * 0.76, -headRadius * 0.62)],
    "broad-horns": () => [addPoint(head, -headRadius * 1.05, -headRadius * 0.35), addPoint(head, headRadius * 1.05, -headRadius * 0.35)],
    muzzle: () => [addPoint(head, 0, headRadius * 0.45)],
    "cheek-fins": () => [addPoint(head, -headRadius * 0.95, headRadius * 0.08), addPoint(head, headRadius * 0.95, headRadius * 0.08)],
    "scaled-wings": () => [addPoint(chest, -shoulderSpread * 1.25, 0.8), addPoint(chest, shoulderSpread * 1.25, 0.8)],
    "long-tail": () => [addPoint(hip, -metrics.shoulderWidth * 0.72, 2.8)],
    "ember-seams": () => [clonePoint(chest), clonePoint(hip)],
    "branch-crown": () => [addPoint(head, 0, -headRadius * 0.96)],
    "root-feet": () => [addPoint(bones.leftFoot, -0.8, 0), addPoint(bones.rightFoot, 0.8, 0)],
    "streamer-wings": () => [addPoint(chest, -shoulderSpread * 1.18, 0.5), addPoint(chest, shoulderSpread * 1.18, 0.5)],
    "rune-ribs": () => [addPoint(chest, 0, 0.8)],
    "large-ears": () => [addPoint(head, -headRadius * 1.08, 0), addPoint(head, headRadius * 1.08, 0)],
    "petal-mantle": () => [clonePoint(bones.leftShoulder), clonePoint(bones.rightShoulder), addPoint(chest, 0, 0.6)],
    "high-collar": () => [addPoint(bones.neck, -headRadius * 0.58, 0.3), addPoint(bones.neck, headRadius * 0.58, 0.3)],
    fangs: () => [addPoint(head, -headRadius * 0.25, headRadius * 0.56), addPoint(head, headRadius * 0.25, headRadius * 0.56)],
    "wolf-muzzle": () => [addPoint(head, 0, headRadius * 0.5)],
    mane: () => [addPoint(head, 0, -headRadius * 0.2), clonePoint(bones.neck)],
    "feather-wings": () => [addPoint(chest, -shoulderSpread * 1.3, 0.8), addPoint(chest, shoulderSpread * 1.3, 0.8)],
    "plain-halo": () => [addPoint(head, 0, -headRadius * 1.08)],
    "swept-horns": () => [addPoint(head, -headRadius * 0.78, -headRadius * 0.58), addPoint(head, headRadius * 0.78, -headRadius * 0.58)],
    "ember-tail": () => [addPoint(hip, -metrics.shoulderWidth * 0.68, 2.5)],
  };
  const resolver = resolvers[feature];
  if (!resolver) throw new Error(`Unknown ancestry animation attachment: ${feature}`);
  return { id: feature, anchors: resolver() };
}

function boundsFor(points, padding) {
  const xs = points.map((entry) => entry.x);
  const ys = points.map((entry) => entry.y);
  return {
    left: Math.min(...xs) - padding,
    right: Math.max(...xs) + padding,
    top: Math.min(...ys) - padding,
    bottom: Math.max(...ys) + padding,
  };
}

function swingLimbs(bones, wave, amplitude) {
  bones.leftHand = addPoint(bones.leftHand, 0, wave * amplitude);
  bones.rightHand = addPoint(bones.rightHand, 0, -wave * amplitude);
  bones.leftFoot = addPoint(bones.leftFoot, 0, -wave * amplitude * 0.45);
  bones.rightFoot = addPoint(bones.rightFoot, 0, wave * amplitude * 0.45);
}

function shiftPosePoints(bones, attachments, dx, dy) {
  for (const [id, entry] of Object.entries(bones)) bones[id] = addPoint(entry, dx, dy);
  for (const attachment of attachments) {
    attachment.anchors = attachment.anchors.map((entry) => addPoint(entry, dx, dy));
  }
}

function finitePoint(entry) {
  return Number.isFinite(entry?.x) && Number.isFinite(entry?.y);
}

function insideCell(entry, cell, margin = 0) {
  return entry.x >= -margin && entry.x <= cell.width + margin && entry.y >= -margin && entry.y <= cell.height + margin;
}
