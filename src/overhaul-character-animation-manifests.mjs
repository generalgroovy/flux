import { createCharacterAnimationManifest } from "./character-animation-skeletons.mjs";

const manifest = (definition) => createCharacterAnimationManifest({
  implementationStatus: "animation-skeleton",
  ...definition,
});

// Canonical visual roster from README.md. These entries are presentation-only:
// they do not make a champion selectable or authoritative in live matches.
export const OVERHAUL_CHARACTER_ANIMATION_MANIFESTS = Object.freeze([
  manifest({ id: "oh-tipi", name: "Oh Tipi", ancestryId: "seakin", size: 2, affinities: ["water", "ice", "charge"], focusProp: "current fins" }),
  manifest({ id: "samwise", name: "S. Wayne", ancestryId: "hobbit", size: 2, affinities: ["dark", "light"], focusProp: "eclipse waystone" }),
  manifest({ id: "rote-baron", name: "The Red Baron", ancestryId: "undead", size: 3, affinities: ["dark", "fire", "ice"], focusProp: "formation standard" }),
  manifest({ id: "steezo", name: "Steezo", ancestryId: "goblin", size: 1, affinities: ["fire", "charge", "light"], focusProp: "spark keg" }),
  manifest({ id: "treevor", name: "Treevor the Mason", ancestryId: "treefolk", size: 5, affinities: ["earth", "wind", "fire"], focusProp: "mason branch" }),
  manifest({ id: "olli", name: "Oll' I", ancestryId: "werewolf", size: 4, affinities: ["earth", "fire", "light"], focusProp: "breaker claws" }),
  manifest({ id: "fluup", name: "Fluup", ancestryId: "orc", size: 4, affinities: ["charge", "wind", "ice"], focusProp: "storm bracers" }),
  manifest({ id: "wa-bidi", name: "Wa Bidi", ancestryId: "goblin", size: 2, affinities: ["charge", "wind", "fire"], focusProp: "battlecry horn" }),
  manifest({ id: "grace-reava", name: "Grace Reava", ancestryId: "sylph", size: 2, affinities: ["wind", "water", "light"], focusProp: "current streamers" }),
  manifest({ id: "nico", name: "Nico Lai", ancestryId: "gnome", size: 1, affinities: ["charge", "light"], focusProp: "calibrated coil pack", compatibilityIds: ["nix", "volt"] }),
  manifest({ id: "aerwyn", name: "Spai Si", ancestryId: "demon", size: 3, affinities: ["wind", "light", "earth"], focusProp: "redirect blades" }),
  manifest({ id: "leaf-hidden", name: "Leaf the Hidden", ancestryId: "treefolk", size: 4, affinities: ["water", "earth", "light"], focusProp: "concealed grove" }),
  manifest({ id: "yrsa", name: "Ha Rekt", ancestryId: "wyrmborn", size: 4, affinities: ["ice", "wind", "fire"], focusProp: "rime wings" }),
  manifest({ id: "dr-apex", name: "Dr. Apex", ancestryId: "stoneborn", size: 4, affinities: ["earth", "light", "water"], focusProp: "field ward" }),
  manifest({ id: "haara", name: "Haara", ancestryId: "nymph", size: 2, affinities: ["light", "wind", "spirit"], focusProp: "bloom mantle", compatibilityIds: ["mara"] }),
  manifest({ id: "hesus-christo", name: "Hesus Christo", ancestryId: "elf", size: 3, affinities: ["earth", "water"], focusProp: "renewal staff" }),
  manifest({ id: "grimm-bow", name: "Grimm Bow", ancestryId: "troll", size: 4, affinities: ["dark", "earth", "water"], focusProp: "terrain bow", compatibilityIds: ["brum"] }),
  manifest({ id: "biggy-bob", name: "Biggy Bob", ancestryId: "dwarf", size: 3, affinities: ["earth", "fire", "light"], focusProp: "forge prism" }),
  manifest({ id: "jan-wicked", name: "Jan Wicked", ancestryId: "human", size: 3, affinities: ["ice", "dark", "charge"], focusProp: "black-ice circuit" }),
  manifest({ id: "ba-djoh", name: "Ba Djoh", ancestryId: "minotaur", size: 5, affinities: ["earth", "fire", "water"], focusProp: "three-current horns" }),
  manifest({ id: "urzh", name: "Urzh", ancestryId: "stoneborn", size: 4, affinities: ["earth", "fire", "charge"], focusProp: "conductive kiln" }),
  manifest({ id: "donnok", name: "Donnok", ancestryId: "dwarf", size: 3, affinities: ["earth", "fire", "water"], focusProp: "forge hammer" }),
  manifest({ id: "djonah-thaan", name: "Djonah Thaan", ancestryId: "vampire", size: 3, affinities: ["dark", "charge", "fire"], focusProp: "grave-current sigil" }),
  manifest({ id: "unnamed-angel", name: "Unnamed Angel", ancestryId: "angel", size: 3, affinities: ["wind", "light", "spirit"], focusProp: "placeholder wing seal" }),
]);

const manifestById = new Map();
for (const entry of OVERHAUL_CHARACTER_ANIMATION_MANIFESTS) {
  manifestById.set(entry.id, entry);
  for (const compatibilityId of entry.compatibilityIds) manifestById.set(compatibilityId, entry);
}

export function getOverhaulCharacterAnimationManifest(id) {
  return manifestById.get(String(id ?? "")) ?? null;
}

export function validateOverhaulCharacterAnimationManifests() {
  const errors = [];
  const ids = OVERHAUL_CHARACTER_ANIMATION_MANIFESTS.map((entry) => entry.id);
  if (OVERHAUL_CHARACTER_ANIMATION_MANIFESTS.length !== 24) errors.push("exactly twenty-four overhaul animation manifests required");
  if (new Set(ids).size !== ids.length) errors.push("overhaul animation manifest ids must be unique");
  const ancestryIds = new Set(OVERHAUL_CHARACTER_ANIMATION_MANIFESTS.map((entry) => entry.ancestryId));
  for (const required of [
    "human", "dwarf", "gnome", "hobbit", "elf", "orc", "troll", "minotaur", "seakin", "wyrmborn",
    "stoneborn", "treefolk", "sylph", "undead", "goblin", "nymph", "vampire", "werewolf", "angel", "demon",
  ]) {
    if (!ancestryIds.has(required)) errors.push(`roster lacks ancestry animation coverage: ${required}`);
  }
  return errors;
}
