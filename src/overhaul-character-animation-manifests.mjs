import { ANCESTRY_VISUAL_TEMPLATES } from "./ancestry-visual-templates.mjs";
import {
  ANIMATION_DIRECTIONS,
  CHARACTER_ANIMATION_STATES,
  createAnimationManifest,
  createCharacterAnimationRegistry,
  validateCharacterAnimationSystem,
} from "./character-animation-skeletons.mjs";

const freeze = (value) => Object.freeze(value);

const manifest = (definition) => createAnimationManifest({
  status: "skeleton-only",
  source: "overhaul-roster",
  ...definition,
  affinities: freeze([...(definition.affinities ?? [])]),
  palette: freeze({ ...(definition.palette ?? {}) }),
});

export const OVERHAUL_CHARACTER_ANIMATION_MANIFESTS = freeze([
  manifest({
    id: "oh-tipi",
    name: "Oh Tipi",
    contentCompatibilityId: "oh-tipi",
    ancestryId: "seakin",
    size: 2,
    affinities: ["water", "ice", "charge"],
    focusProp: "tide trident",
    roleRead: "compact conductive-current skirmisher",
    palette: { body: "tide-cyan", mantle: "ice-white", focus: "charge-gold" },
  }),
  manifest({
    id: "samwise",
    name: "S. Wayne",
    contentCompatibilityId: "samwise",
    ancestryId: "hobbit",
    size: 1,
    affinities: ["dark", "light"],
    focusProp: "eclipse waystone",
    roleRead: "low boundary tactician with split mantle",
    status: "reviewed-source",
    palette: { body: "deep-umber", mantle: "eclipse-violet", focus: "parchment-light" },
  }),
  manifest({
    id: "rote-baron",
    name: "The Red Baron",
    contentCompatibilityId: "rote-baron",
    ancestryId: "undead",
    size: 3,
    affinities: ["dark", "fire", "ice"],
    focusProp: "officer formation baton",
    roleRead: "rigid airborne formation controller",
    palette: { body: "aged-bone", mantle: "officer-crimson", focus: "cold-ember" },
  }),
  manifest({
    id: "steezo",
    name: "Steezo",
    contentCompatibilityId: "steezo",
    ancestryId: "goblin",
    size: 1,
    affinities: ["fire", "charge", "light"],
    focusProp: "sparking tool rig",
    roleRead: "small volatile construct engineer",
    palette: { body: "warm-red", mantle: "soot-black", focus: "spark-gold" },
  }),
  manifest({
    id: "treevor",
    name: "Treevor the Mason",
    contentCompatibilityId: "treevor",
    ancestryId: "treefolk",
    size: 5,
    affinities: ["earth", "wind", "fire"],
    focusProp: "masonry root mallet",
    roleRead: "huge terrain mason with mud-block mass",
    palette: { body: "living-bark", mantle: "moss-clay", focus: "ember-rune" },
  }),
  manifest({
    id: "olli",
    name: "Oll' I",
    contentCompatibilityId: "olli",
    ancestryId: "werewolf",
    size: 5,
    affinities: ["earth", "fire", "light"],
    focusProp: "breaker bracers",
    roleRead: "forward-weighted structural breaker",
    palette: { body: "ashen-fur", mantle: "forge-hide", focus: "sun-iron" },
  }),
  manifest({
    id: "fluup",
    name: "Fluup",
    contentCompatibilityId: "fluup",
    ancestryId: "orc",
    size: 4,
    affinities: ["charge", "wind", "ice"],
    focusProp: "storm landing maul",
    roleRead: "heavy storm bruiser with weighted landing stance",
    palette: { body: "storm-olive", mantle: "mineral-navy", focus: "charge-ice" },
  }),
  manifest({
    id: "vey",
    name: "Wa Bidi",
    contentCompatibilityId: "vey",
    ancestryId: "goblin",
    size: 1,
    affinities: ["charge", "wind", "fire"],
    focusProp: "battlecry horn pack",
    roleRead: "fast route specialist with wind-swept gear",
    palette: { body: "copper-green", mantle: "storm-cloth", focus: "hot-charge" },
  }),
  manifest({
    id: "grace-reava",
    name: "Grace Reava",
    ancestryId: "sylph",
    size: 2,
    affinities: ["wind", "water", "light"],
    focusProp: "luminous current ribbons",
    roleRead: "streamer-wing aerial duelist",
    palette: { body: "mist-blue", mantle: "travel-woven", focus: "luminous-tide" },
  }),
  manifest({
    id: "nico",
    name: "Nico Lai",
    runtimeCharacterId: "volt",
    contentCompatibilityId: "nix",
    ancestryId: "gnome",
    size: 1,
    affinities: ["charge", "light"],
    focusProp: "calibrated coil pack",
    roleRead: "tiny precision shared-device engineer",
    status: "promoted",
    palette: { body: "warm-copper", mantle: "tool-leather", focus: "calibration-gold" },
  }),
  manifest({
    id: "aerwyn",
    name: "Spai Si",
    contentCompatibilityId: "aerwyn",
    ancestryId: "demon",
    size: 3,
    affinities: ["wind", "light", "earth"],
    focusProp: "redirect blade",
    roleRead: "narrow angular redirect duelist",
    status: "reviewed-source",
    palette: { body: "deep-umber", mantle: "chthonic-black", focus: "wind-ivory" },
  }),
  manifest({
    id: "leaf-hidden",
    name: "Leaf the Hidden",
    contentCompatibilityId: "luma",
    ancestryId: "treefolk",
    size: 4,
    affinities: ["water", "earth", "light"],
    focusProp: "concealed growth rings",
    roleRead: "large concealed grove support",
    palette: { body: "shadow-bark", mantle: "layered-leaf", focus: "spring-light" },
  }),
  manifest({
    id: "yrsa",
    name: "Ha Rekt",
    contentCompatibilityId: "yrsa",
    ancestryId: "wyrmborn",
    size: 4,
    affinities: ["ice", "wind", "fire"],
    focusProp: "rime hunting spear",
    roleRead: "anthropomorphic aerial cold-line hunter",
    palette: { body: "rime-scale", mantle: "wind-hide", focus: "cold-ember" },
  }),
  manifest({
    id: "dr-apex",
    name: "Dr. Apex",
    contentCompatibilityId: "gorum",
    ancestryId: "stoneborn",
    size: 4,
    affinities: ["earth", "light", "water"],
    focusProp: "triage prism",
    roleRead: "large armored combat medic",
    palette: { body: "hewn-stone", mantle: "medic-woven", focus: "spring-prism" },
  }),
  manifest({
    id: "haara",
    name: "Haara",
    contentCompatibilityId: "mara",
    ancestryId: "nymph",
    size: 2,
    affinities: ["light", "wind", "spirit"],
    focusProp: "bloom spindle",
    roleRead: "small bloom planner with restrained motes",
    palette: { body: "warm-petal", mantle: "living-fiber", focus: "spirit-light" },
  }),
  manifest({
    id: "hesus-christo",
    name: "Hesus Christo",
    contentCompatibilityId: "mog",
    ancestryId: "elf",
    size: 3,
    affinities: ["earth", "water"],
    focusProp: "renewal staff",
    roleRead: "tall renewal vanguard with deliberate posture",
    palette: { body: "warm-olive", mantle: "grounded-woven", focus: "renewal-water" },
  }),
  manifest({
    id: "grimm-bow",
    name: "Grimm Bow",
    contentCompatibilityId: "brum",
    ancestryId: "troll",
    size: 4,
    affinities: ["dark", "earth", "water"],
    focusProp: "inward-drawn terrain bow",
    roleRead: "large terrain archer with moss horns",
    palette: { body: "moss-stone", mantle: "deep-water", focus: "void-string" },
  }),
  manifest({
    id: "biggy-bob",
    name: "Biggy Bob",
    ancestryId: "dwarf",
    size: 3,
    affinities: ["earth", "fire", "light"],
    focusProp: "masonry hammer",
    roleRead: "broad forge-line breacher",
    palette: { body: "forge-brown", mantle: "masonry-iron", focus: "fire-prism" },
  }),
  manifest({
    id: "jan-wicked",
    name: "Jan Wicked",
    ancestryId: "human",
    size: 3,
    affinities: ["ice", "dark", "charge"],
    focusProp: "black-ice circuit blade",
    roleRead: "medium gear-led circuit hunter",
    palette: { body: "warm-human", mantle: "black-ice", focus: "charge-blue" },
  }),
  manifest({
    id: "ba-djoh",
    name: "Ba Djoh",
    ancestryId: "minotaur",
    size: 5,
    affinities: ["earth", "fire", "water"],
    focusProp: "three-current horn guards",
    roleRead: "huge momentum charge breaker",
    palette: { body: "sun-brown", mantle: "river-hide", focus: "heated-earth" },
  }),
  manifest({
    id: "urzh",
    name: "Urzh",
    ancestryId: "stoneborn",
    size: 4,
    affinities: ["earth", "fire", "charge"],
    focusProp: "kiln bulwark",
    roleRead: "large lane anchor with ember seams",
    status: "reviewed-source",
    palette: { body: "kiln-stone", mantle: "iron-black", focus: "conductive-ember" },
  }),
  manifest({
    id: "donnok",
    name: "Donnok",
    ancestryId: "dwarf",
    size: 2,
    affinities: ["earth", "fire", "water"],
    focusProp: "steam forge chisel",
    roleRead: "compact forge-rhythm terrain shaper",
    palette: { body: "steam-brown", mantle: "forge-wrap", focus: "meltwater-copper" },
  }),
  manifest({
    id: "djonah-thaan",
    name: "Djonah Thaan",
    ancestryId: "vampire",
    size: 3,
    affinities: ["dark", "charge", "fire"],
    focusProp: "grave-current lantern",
    roleRead: "controlled pursuit controller",
    palette: { body: "pale-umber", mantle: "grave-crimson", focus: "charged-blood" },
  }),
  manifest({
    id: "angel-placeholder",
    name: "Unnamed Angel",
    ancestryId: "angel",
    size: 3,
    affinities: ["wind", "light", "spirit"],
    focusProp: "unapproved plain halo",
    roleRead: "temporary feather-wing coverage slot",
    status: "placeholder",
    approvalStatus: "unapproved-placeholder",
    palette: { body: "plain-parchment", mantle: "cloud-woven", focus: "neutral-light" },
  }),
]);

const MANIFEST_BY_ID = new Map(
  OVERHAUL_CHARACTER_ANIMATION_MANIFESTS.map((entry) => [entry.id, entry]),
);

export const OVERHAUL_CHARACTER_ANIMATION_MANIFESTS_BY_ID = freeze(
  Object.fromEntries(MANIFEST_BY_ID),
);

export function getOverhaulCharacterAnimationManifest(id) {
  return MANIFEST_BY_ID.get(id) ?? null;
}

export function createOverhaulCharacterAnimationRegistry() {
  return createCharacterAnimationRegistry(OVERHAUL_CHARACTER_ANIMATION_MANIFESTS);
}

export function validateOverhaulCharacterAnimationManifests() {
  const errors = [...validateCharacterAnimationSystem(OVERHAUL_CHARACTER_ANIMATION_MANIFESTS)];
  if (OVERHAUL_CHARACTER_ANIMATION_MANIFESTS.length !== 24) {
    errors.push("exactly twenty-four overhaul animation manifests required");
  }

  const names = new Set(OVERHAUL_CHARACTER_ANIMATION_MANIFESTS.map((entry) => entry.name));
  for (const requiredName of REQUIRED_ROSTER_NAMES) {
    if (!names.has(requiredName)) errors.push(`missing animation manifest for ${requiredName}`);
  }

  const representedAncestries = new Set(
    OVERHAUL_CHARACTER_ANIMATION_MANIFESTS.map((entry) => entry.ancestryId),
  );
  for (const ancestry of ANCESTRY_VISUAL_TEMPLATES) {
    if (!representedAncestries.has(ancestry.id)) {
      errors.push(`no roster animation manifest represents ${ancestry.id}`);
    }
  }

  const representedSizes = new Set(
    OVERHAUL_CHARACTER_ANIMATION_MANIFESTS.map((entry) => entry.size),
  );
  for (const size of [1, 2, 3, 4, 5]) {
    if (!representedSizes.has(size)) errors.push(`no roster animation manifest represents size ${size}`);
  }

  for (const entry of OVERHAUL_CHARACTER_ANIMATION_MANIFESTS) {
    if (entry.directions.length !== ANIMATION_DIRECTIONS.length) {
      errors.push(`${entry.id}: all eight directional rows required`);
    }
    for (const stateId of CHARACTER_ANIMATION_STATES) {
      if (!entry.clips[stateId]) errors.push(`${entry.id}: missing basic animation state ${stateId}`);
    }
  }

  const angel = MANIFEST_BY_ID.get("angel-placeholder");
  if (angel?.status !== "placeholder" || angel?.approvalStatus !== "unapproved-placeholder") {
    errors.push("Angel coverage must remain an explicitly unapproved placeholder");
  }
  if (angel?.runtimeCharacterId || angel?.contentCompatibilityId) {
    errors.push("Angel placeholder must not claim a gameplay identifier");
  }
  return errors;
}

const REQUIRED_ROSTER_NAMES = freeze([
  "Oh Tipi",
  "S. Wayne",
  "The Red Baron",
  "Steezo",
  "Treevor the Mason",
  "Oll' I",
  "Fluup",
  "Wa Bidi",
  "Grace Reava",
  "Nico Lai",
  "Spai Si",
  "Leaf the Hidden",
  "Ha Rekt",
  "Dr. Apex",
  "Haara",
  "Hesus Christo",
  "Grimm Bow",
  "Biggy Bob",
  "Jan Wicked",
  "Ba Djoh",
  "Urzh",
  "Donnok",
  "Djonah Thaan",
  "Unnamed Angel",
]);
