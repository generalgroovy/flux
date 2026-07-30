const deepFreeze = (value) => {
  if (value && typeof value === "object" && !Object.isFrozen(value)) {
    for (const nested of Object.values(value)) deepFreeze(nested);
    Object.freeze(value);
  }
  return value;
};

const finite = (value, fallback = 0) => Number.isFinite(Number(value)) ? Number(value) : fallback;
const positive = (value) => finite(value) > 0;
const clamp = (value, minimum, maximum) => Math.max(minimum, Math.min(maximum, value));

export const ANIMATION_SKELETON_VERSION = 1;

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

export const BASE_SKELETON_JOINTS = deepFreeze([
  "root",
  "shadow",
  "pelvis",
  "torso",
  "head",
  "left-shoulder",
  "left-hand",
  "right-shoulder",
  "right-hand",
  "left-foot",
  "right-foot",
  "focus",
  "back",
  "aura",
]);

const clip = (frames, fps, loop, channel, rootMotion = "none", events = []) => deepFreeze({
  frames,
  fps,
  loop,
  channel,
  rootMotion,
  events: [...events],
});

export const BASE_ANIMATION_CLIPS = deepFreeze({
  idle: clip(2, 4, true, "locomotion"),
  walk: clip(4, 8, true, "locomotion", "velocity"),
  run: clip(6, 12, true, "locomotion", "velocity"),
  sprint: clip(6, 15, true, "locomotion", "velocity", ["footstep-left", "footstep-right"]),
  "jump-start": clip(2, 14, false, "air", "velocity", ["takeoff"]),
  "jump-rise": clip(2, 10, true, "air", "velocity"),
  "jump-apex": clip(1, 1, true, "air", "velocity"),
  fall: clip(2, 8, true, "air", "velocity"),
  land: clip(3, 14, false, "air", "none", ["land-impact"]),
  "slide-start": clip(2, 16, false, "ground-tech", "velocity"),
  "slide-loop": clip(2, 10, true, "ground-tech", "velocity", ["slide-trail"]),
  "slide-end": clip(2, 12, false, "ground-tech", "velocity"),
  "slide-jump": clip(3, 15, false, "air", "velocity", ["takeoff"]),
  "wall-contact": clip(2, 8, true, "air", "none", ["wall-contact"]),
  "wall-jump": clip(4, 16, false, "air", "velocity", ["wall-kick"]),
  "air-redirect": clip(3, 18, false, "air", "velocity", ["redirect"]),
  "air-dodge": clip(4, 20, false, "air", "velocity", ["dodge-start", "dodge-end"]),
  wavedash: clip(4, 20, false, "ground-tech", "velocity", ["land-impact"]),
  "vault-start": clip(2, 14, false, "traversal", "authored"),
  "vault-cross": clip(4, 14, false, "traversal", "authored", ["vault-crest"]),
  "vault-land": clip(2, 14, false, "traversal", "authored", ["land-impact"]),
  superglide: clip(5, 20, false, "traversal", "velocity", ["vault-crest", "takeoff"]),
  launched: clip(3, 10, true, "forced", "velocity"),
  grappled: clip(2, 8, true, "forced", "authored"),
  charging: clip(4, 12, true, "action", "velocity"),
  "cast-primary": clip(3, 18, false, "action", "none", ["release-primary"]),
  "cast-special": clip(4, 15, false, "action", "none", ["release-special"]),
  "cast-ultimate": clip(6, 12, false, "action", "none", ["release-ultimate"]),
  defend: clip(2, 8, true, "reaction"),
  hit: clip(2, 18, false, "reaction", "none", ["hit-flash"]),
  stunned: clip(2, 6, true, "reaction"),
  rooted: clip(2, 5, true, "reaction"),
  slowed: clip(4, 6, true, "locomotion", "velocity"),
  defeated: clip(4, 8, false, "reaction", "none", ["defeated"]),
});

export const ANIMATION_STATE_ALIASES = deepFreeze({
  move: "run",
  commit: "cast-special",
  sliding: "slide-loop",
  "air-dodging": "air-dodge",
  "wall-contact": "wall-contact",
  "wall-jumping": "wall-jump",
  vaulting: "vault-cross",
  airborne: "jump-apex",
  rising: "jump-rise",
  falling: "fall",
  launched: "launched",
  grappled: "grappled",
  charging: "charging",
  stunned: "stunned",
  rooted: "rooted",
  slowed: "slowed",
});

export const SIZE_ANIMATION_PROFILES = deepFreeze({
  1: { label: "Tiny", scale: 0.78, stride: 0.84, cadence: 1.16, airLift: 1.12, landingSquash: 0.82, shadowScale: 0.76, framePadding: 2 },
  2: { label: "Small", scale: 0.9, stride: 0.92, cadence: 1.08, airLift: 1.06, landingSquash: 0.88, shadowScale: 0.88, framePadding: 3 },
  3: { label: "Medium", scale: 1, stride: 1, cadence: 1, airLift: 1, landingSquash: 0.94, shadowScale: 1, framePadding: 4 },
  4: { label: "Large", scale: 1.13, stride: 1.08, cadence: 0.92, airLift: 0.92, landingSquash: 1.02, shadowScale: 1.14, framePadding: 5 },
  5: { label: "Huge", scale: 1.28, stride: 1.16, cadence: 0.84, airLift: 0.84, landingSquash: 1.12, shadowScale: 1.3, framePadding: 6 },
});

const ancestry = (id, name, posture, gait, anatomyHooks = [], joints = []) => deepFreeze({
  id,
  name,
  posture,
  gait,
  anatomyHooks: [...anatomyHooks],
  joints: [...joints],
});

export const ANCESTRY_ANIMATION_SKELETONS = deepFreeze([
  ancestry("human", "Human", "balanced", "adaptive stride", ["gear"]),
  ancestry("dwarf", "Dwarf", "low-broad", "planted drive", ["beard", "block-shoulders"]),
  ancestry("gnome", "Gnome", "compact", "quick measured steps", ["high-cap", "device-mount"]),
  ancestry("hobbit", "Hobbit", "low", "quiet short stride", ["bare-feet"]),
  ancestry("elf", "Elf", "tall", "long precise stride", ["long-ears"]),
  ancestry("orc", "Orc", "broad", "shoulder-led commitment", ["tusks"]),
  ancestry("troll", "Troll", "huge", "slow inward brace", ["moss-horns"]),
  ancestry("minotaur", "Minotaur", "huge-forward", "hoof-led charge", ["broad-horns", "muzzle"]),
  ancestry("seakin", "Seakin", "compact-fluid", "lateral current step", ["cheek-fins", "webbed-feet"]),
  ancestry("wyrmborn", "Wyrmborn", "winged", "aerial pitch", ["scaled-wings", "long-tail"], ["left-wing", "right-wing", "tail"]),
  ancestry("stoneborn", "Stoneborn", "block", "braced translation", ["block-shoulders", "ember-seams"]),
  ancestry("treefolk", "Treefolk", "rooted", "root-weight shift", ["branch-crown", "root-feet"], ["crown", "left-root", "right-root"]),
  ancestry("sylph", "Sylph", "light", "floating route turn", ["streamer-wings"], ["left-wing", "right-wing"]),
  ancestry("undead", "Undead", "tall-rigid", "formation pivot", ["rune-ribs"]),
  ancestry("goblin", "Goblin", "compact-forward", "tool-led scramble", ["large-ears", "tool-belt"]),
  ancestry("nymph", "Nymph", "light", "blooming sidestep", ["petal-mantle"]),
  ancestry("vampire", "Vampire", "balanced-upright", "controlled pursuit glide", ["high-collar", "fangs"]),
  ancestry("werewolf", "Werewolf", "broad-forward", "forward-weighted lope", ["wolf-muzzle", "mane"]),
  ancestry("angel", "Angel", "winged-upright", "measured wing-set turn", ["feather-wings", "plain-halo"], ["left-wing", "right-wing", "halo"]),
  ancestry("demon", "Demon", "balanced-angular", "poised angular advance", ["swept-horns", "ember-tail"], ["left-horn", "right-horn", "tail"]),
]);

export const ANCESTRY_ANIMATION_ALIASES = deepFreeze({
  scaleheir: "wyrmborn",
  stonewrought: "stoneborn",
  rootwarden: "treefolk",
});

const ancestryById = new Map(ANCESTRY_ANIMATION_SKELETONS.map((entry) => [entry.id, entry]));

export function canonicalAnimationAncestryId(id) {
  const normalized = String(id ?? "").trim().toLowerCase();
  return ANCESTRY_ANIMATION_ALIASES[normalized] ?? normalized;
}

export function getAncestryAnimationSkeleton(id) {
  return ancestryById.get(canonicalAnimationAncestryId(id)) ?? null;
}

export function createCharacterAnimationManifest(definition = {}) {
  const ancestryId = canonicalAnimationAncestryId(definition.ancestryId);
  const ancestryEntry = getAncestryAnimationSkeleton(ancestryId);
  const size = Number(definition.size);
  if (!definition.id || !definition.name) throw new Error("Animation manifests require id and name");
  if (!ancestryEntry) throw new Error(`Unknown animation ancestry: ${definition.ancestryId}`);
  if (!SIZE_ANIMATION_PROFILES[size]) throw new Error(`Unknown animation size: ${definition.size}`);
  return deepFreeze({
    id: String(definition.id),
    name: String(definition.name),
    ancestryId,
    size,
    affinities: [...(definition.affinities ?? [])],
    focusProp: definition.focusProp ?? "none",
    compatibilityIds: [...(definition.compatibilityIds ?? [])],
    clipOverrides: { ...(definition.clipOverrides ?? {}) },
    jointOverrides: { ...(definition.jointOverrides ?? {}) },
    implementationStatus: definition.implementationStatus ?? "animation-skeleton",
  });
}

export function createAnimationSkeleton({
  ancestryId,
  size = 3,
  clipOverrides = {},
  jointOverrides = {},
  cellWidth = 32,
  cellHeight = 32,
} = {}) {
  const ancestryEntry = getAncestryAnimationSkeleton(ancestryId);
  const sizeEntry = SIZE_ANIMATION_PROFILES[size];
  if (!ancestryEntry) throw new Error(`Unknown animation ancestry: ${ancestryId}`);
  if (!sizeEntry) throw new Error(`Unknown animation size: ${size}`);
  const clips = Object.fromEntries(Object.entries(BASE_ANIMATION_CLIPS).map(([id, base]) => [
    id,
    deepFreeze({ ...base, ...(clipOverrides[id] ?? {}), events: [...(clipOverrides[id]?.events ?? base.events)] }),
  ]));
  const joints = [...new Set([...BASE_SKELETON_JOINTS, ...ancestryEntry.joints, ...Object.keys(jointOverrides)])];
  const skeleton = {
    version: ANIMATION_SKELETON_VERSION,
    ancestryId: ancestryEntry.id,
    ancestry: ancestryEntry,
    size: Number(size),
    sizeProfile: sizeEntry,
    directions: ANIMATION_DIRECTIONS,
    joints,
    jointOverrides: { ...jointOverrides },
    clips,
    spriteCell: { width: finite(cellWidth, 32), height: finite(cellHeight, 32) },
  };
  skeleton.atlas = createAnimationAtlasLayout(skeleton);
  return deepFreeze(skeleton);
}

export function buildCharacterAnimationSkeleton(manifest, options = {}) {
  const normalized = createCharacterAnimationManifest(manifest);
  return createAnimationSkeleton({
    ancestryId: normalized.ancestryId,
    size: normalized.size,
    clipOverrides: { ...normalized.clipOverrides, ...(options.clipOverrides ?? {}) },
    jointOverrides: { ...normalized.jointOverrides, ...(options.jointOverrides ?? {}) },
    cellWidth: options.cellWidth,
    cellHeight: options.cellHeight,
  });
}

export function createAnimationAtlasLayout(skeleton) {
  const clipEntries = Object.entries(skeleton.clips);
  const maximumFrames = Math.max(...clipEntries.map(([, definition]) => definition.frames));
  const rows = clipEntries.map(([clipId, definition], row) => deepFreeze({
    clipId,
    row,
    frames: definition.frames,
    directions: ANIMATION_DIRECTIONS.map((direction, directionIndex) => deepFreeze({
      direction: direction.id,
      column: directionIndex * maximumFrames,
      frames: definition.frames,
    })),
  }));
  return deepFreeze({
    layout: "clip-rows-direction-blocks",
    cellWidth: skeleton.spriteCell.width,
    cellHeight: skeleton.spriteCell.height,
    maximumFrames,
    widthCells: ANIMATION_DIRECTIONS.length * maximumFrames,
    heightCells: rows.length,
    width: ANIMATION_DIRECTIONS.length * maximumFrames * skeleton.spriteCell.width,
    height: rows.length * skeleton.spriteCell.height,
    rows,
  });
}

export function normalizeAnimationState(state) {
  const id = String(state ?? "idle");
  const normalized = ANIMATION_STATE_ALIASES[id] ?? id;
  return BASE_ANIMATION_CLIPS[normalized] ? normalized : "idle";
}

export function resolveCharacterAnimationState(entity = {}, cooldowns = {}) {
  if (entity.animationState) return normalizeAnimationState(entity.animationState);
  if (entity.alive === false) return "defeated";
  if (positive(entity.hitFlash)) return "hit";
  if (positive(entity.interruptRemaining) || positive(entity.stunRemaining)) return "stunned";
  if (positive(entity.rootedRemaining)) return "rooted";
  if (positive(entity.defenseRemaining)) return "defend";
  if (positive(entity.ultimateWindupRemaining)) return "cast-ultimate";
  if (positive(entity.specialWindupRemaining) || insideOpeningWindow(entity.specialCooldown, cooldowns.special, 0.16)) return "cast-special";
  if (positive(entity.primaryWindupRemaining) || insideOpeningWindow(entity.primaryCooldown, cooldowns.primary, 0.075)) return "cast-primary";
  if (positive(entity.grappledRemaining)) return "grappled";
  if (positive(entity.launchedRemaining)) return "launched";
  if (positive(entity.chargingRemaining)) return "charging";
  if (positive(entity.superglideRemaining)) return "superglide";
  if (positive(entity.vaultRemaining)) return entity.vaultPhase === "start" ? "vault-start" : entity.vaultPhase === "land" ? "vault-land" : "vault-cross";
  if (positive(entity.waveDashRemaining)) return "wavedash";
  if (positive(entity.airDodgeRemaining)) return "air-dodge";
  if (positive(entity.redirectRemaining) || positive(entity.airRedirectRemaining)) return "air-redirect";
  if (positive(entity.hopRemaining) && entity.hopWallKick) return "wall-jump";
  if (positive(entity.wallContactRemaining)) return "wall-contact";
  if (positive(entity.slideJumpRemaining) || (positive(entity.hopRemaining) && entity.hopFromSlide)) return "slide-jump";
  if (positive(entity.slideRemaining)) return entity.slidePhase === "start" ? "slide-start" : entity.slidePhase === "end" ? "slide-end" : "slide-loop";
  if (positive(entity.landingRemaining)) return "land";
  if (positive(entity.hopRemaining)) return resolveHopAnimationPhase(entity);
  if (positive(entity.slowRemaining) || entity.surface === "slow" || entity.surface === "mud") return "slowed";
  const speed = Math.hypot(finite(entity.vx), finite(entity.vy));
  if (entity.sprinting && speed > 8) return "sprint";
  if (speed > 180 || positive(entity.mobilityRemaining)) return "run";
  if (speed > 8) return "walk";
  return "idle";
}

export function resolveHopAnimationPhase(entity = {}) {
  const remaining = Math.max(0, finite(entity.hopRemaining));
  const duration = Math.max(0.001, finite(entity.hopDuration, remaining || 1));
  const ratio = clamp(remaining / duration, 0, 1);
  if (ratio >= 0.78) return "jump-start";
  if (ratio >= 0.5) return "jump-rise";
  if (ratio >= 0.28) return "jump-apex";
  return "fall";
}

export function validateAnimationSkeletonSystem() {
  const errors = [];
  if (ANCESTRY_ANIMATION_SKELETONS.length !== 20) errors.push("exactly twenty ancestry animation skeletons required");
  if (Object.keys(SIZE_ANIMATION_PROFILES).length !== 5) errors.push("exactly five animation size profiles required");
  if (ANIMATION_DIRECTIONS.length !== 8) errors.push("exactly eight animation directions required");
  const ancestryIds = ANCESTRY_ANIMATION_SKELETONS.map((entry) => entry.id);
  if (new Set(ancestryIds).size !== ancestryIds.length) errors.push("ancestry animation skeleton ids must be unique");
  for (const entry of ANCESTRY_ANIMATION_SKELETONS) {
    for (const size of Object.keys(SIZE_ANIMATION_PROFILES).map(Number)) {
      try {
        const skeleton = createAnimationSkeleton({ ancestryId: entry.id, size });
        if (skeleton.atlas.rows.length !== Object.keys(BASE_ANIMATION_CLIPS).length) errors.push(`${entry.id}:${size}: incomplete atlas`);
      } catch (error) {
        errors.push(`${entry.id}:${size}: ${error.message}`);
      }
    }
  }
  return errors;
}

function insideOpeningWindow(current, configured, window) {
  const currentValue = finite(current);
  const configuredValue = finite(configured);
  return currentValue > 0 && configuredValue > 0 && currentValue >= configuredValue - window;
}
