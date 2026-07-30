import test from "node:test";
import assert from "node:assert/strict";

import {
  ANCESTRY_ANIMATION_SKELETONS,
  ANIMATION_DIRECTIONS,
  BASE_ANIMATION_CLIPS,
  SIZE_ANIMATION_PROFILES,
  buildCharacterAnimationSkeleton,
  createAnimationSkeleton,
  createCharacterAnimationManifest,
  normalizeAnimationState,
  resolveCharacterAnimationState,
  validateAnimationSkeletonSystem,
} from "../src/character-animation-skeletons.mjs";
import {
  OVERHAUL_CHARACTER_ANIMATION_MANIFESTS,
  getOverhaulCharacterAnimationManifest,
  validateOverhaulCharacterAnimationManifests,
} from "../src/overhaul-character-animation-manifests.mjs";

test("all twenty ancestries build animation skeletons at all five sizes", () => {
  assert.deepEqual(validateAnimationSkeletonSystem(), []);
  assert.equal(ANCESTRY_ANIMATION_SKELETONS.length, 20);
  assert.equal(Object.keys(SIZE_ANIMATION_PROFILES).length, 5);
  assert.equal(ANIMATION_DIRECTIONS.length, 8);

  for (const ancestry of ANCESTRY_ANIMATION_SKELETONS) {
    for (let size = 1; size <= 5; size += 1) {
      const skeleton = createAnimationSkeleton({ ancestryId: ancestry.id, size });
      assert.equal(skeleton.ancestryId, ancestry.id);
      assert.equal(skeleton.size, size);
      assert.equal(skeleton.directions.length, 8);
      assert.deepEqual(Object.keys(skeleton.clips), Object.keys(BASE_ANIMATION_CLIPS));
      assert.ok(skeleton.joints.includes("root"));
      assert.ok(skeleton.joints.includes("focus"));
    }
  }
});

test("atlas layout reserves every facing and clip without changing gameplay geometry", () => {
  const skeleton = createAnimationSkeleton({ ancestryId: "scaleheir", size: 5, cellWidth: 24, cellHeight: 28 });
  assert.equal(skeleton.ancestryId, "wyrmborn");
  assert.equal(skeleton.spriteCell.width, 24);
  assert.equal(skeleton.spriteCell.height, 28);
  assert.equal(skeleton.atlas.heightCells, Object.keys(BASE_ANIMATION_CLIPS).length);
  assert.equal(skeleton.atlas.rows[0].directions.length, 8);
  assert.ok(skeleton.atlas.width > 0);
  assert.ok(skeleton.atlas.height > 0);
  assert.equal("radius" in skeleton, false);
  assert.equal("damage" in skeleton, false);
});

test("movement resolver exposes the complete universal movement animation grammar", () => {
  const base = { alive: true, vx: 0, vy: 0 };
  assert.equal(resolveCharacterAnimationState(base), "idle");
  assert.equal(resolveCharacterAnimationState({ ...base, vx: 40 }), "walk");
  assert.equal(resolveCharacterAnimationState({ ...base, vx: 220 }), "run");
  assert.equal(resolveCharacterAnimationState({ ...base, vx: 220, sprinting: true }), "sprint");
  assert.equal(resolveCharacterAnimationState({ ...base, hopRemaining: 0.19, hopDuration: 0.2 }), "jump-start");
  assert.equal(resolveCharacterAnimationState({ ...base, hopRemaining: 0.12, hopDuration: 0.2 }), "jump-rise");
  assert.equal(resolveCharacterAnimationState({ ...base, hopRemaining: 0.07, hopDuration: 0.2 }), "jump-apex");
  assert.equal(resolveCharacterAnimationState({ ...base, hopRemaining: 0.02, hopDuration: 0.2 }), "fall");
  assert.equal(resolveCharacterAnimationState({ ...base, landingRemaining: 0.1 }), "land");
  assert.equal(resolveCharacterAnimationState({ ...base, slideRemaining: 0.2 }), "slide-loop");
  assert.equal(resolveCharacterAnimationState({ ...base, hopRemaining: 0.1, hopWallKick: true }), "wall-jump");
  assert.equal(resolveCharacterAnimationState({ ...base, wallContactRemaining: 0.1 }), "wall-contact");
  assert.equal(resolveCharacterAnimationState({ ...base, airDodgeRemaining: 0.1 }), "air-dodge");
  assert.equal(resolveCharacterAnimationState({ ...base, waveDashRemaining: 0.1 }), "wavedash");
  assert.equal(resolveCharacterAnimationState({ ...base, vaultRemaining: 0.1 }), "vault-cross");
  assert.equal(resolveCharacterAnimationState({ ...base, superglideRemaining: 0.1 }), "superglide");
  assert.equal(resolveCharacterAnimationState({ ...base, defenseRemaining: 0.1 }), "defend");
  assert.equal(resolveCharacterAnimationState({ ...base, hitFlash: 0.1 }), "hit");
  assert.equal(resolveCharacterAnimationState({ ...base, alive: false }), "defeated");
});

test("compatibility visual states normalize into the extended animation grammar", () => {
  assert.equal(normalizeAnimationState("move"), "run");
  assert.equal(normalizeAnimationState("commit"), "cast-special");
  assert.equal(normalizeAnimationState("sliding"), "slide-loop");
  assert.equal(normalizeAnimationState("air-dodging"), "air-dodge");
  assert.equal(normalizeAnimationState("unknown"), "idle");
});

test("the README roster has twenty-four manifests and covers every ancestry", () => {
  assert.deepEqual(validateOverhaulCharacterAnimationManifests(), []);
  assert.equal(OVERHAUL_CHARACTER_ANIMATION_MANIFESTS.length, 24);
  assert.equal(getOverhaulCharacterAnimationManifest("nix").name, "Nico Lai");
  assert.equal(getOverhaulCharacterAnimationManifest("mara").name, "Haara");
  assert.equal(getOverhaulCharacterAnimationManifest("samwise").ancestryId, "hobbit");
  assert.equal(getOverhaulCharacterAnimationManifest("aerwyn").ancestryId, "demon");
  for (const character of OVERHAUL_CHARACTER_ANIMATION_MANIFESTS) {
    const skeleton = buildCharacterAnimationSkeleton(character);
    assert.equal(skeleton.ancestryId, character.ancestryId, character.name);
    assert.equal(skeleton.size, character.size, character.name);
  }
});

test("mods can define characters by manifest and override clips without renderer copies", () => {
  const mod = createCharacterAnimationManifest({
    id: "mod-river-smith",
    name: "River Smith",
    ancestryId: "stonewrought",
    size: 2,
    affinities: ["water", "earth"],
    focusProp: "river hammer",
    clipOverrides: {
      sprint: { frames: 8, fps: 18 },
      land: { frames: 4, events: ["land-impact", "water-splash"] },
    },
    jointOverrides: {
      focus: { x: 0.7, y: -0.1 },
    },
  });
  const skeleton = buildCharacterAnimationSkeleton(mod);
  assert.equal(skeleton.ancestryId, "stoneborn");
  assert.equal(skeleton.clips.sprint.frames, 8);
  assert.equal(skeleton.clips.sprint.fps, 18);
  assert.deepEqual(skeleton.clips.land.events, ["land-impact", "water-splash"]);
  assert.ok(skeleton.joints.includes("focus"));
});
