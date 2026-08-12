import test from "node:test";
import assert from "node:assert/strict";

import { ANCESTRY_VISUAL_TEMPLATES } from "../src/ancestry-visual-templates.mjs";
import {
  ANIMATION_DIRECTIONS,
  ANCESTRY_SKELETON_OVERRIDES,
  CHARACTER_ANIMATION_STATES,
  CHARACTER_SKELETON_SIZES,
  createAnimationManifest,
  createAnimationSkeleton,
  createCharacterAnimationRegistry,
  resolveAnimationPose,
  validateCharacterAnimationSystem,
} from "../src/character-animation-skeletons.mjs";
import {
  OVERHAUL_CHARACTER_ANIMATION_MANIFESTS,
  createOverhaulCharacterAnimationRegistry,
  getOverhaulCharacterAnimationManifest,
  validateOverhaulCharacterAnimationManifests,
} from "../src/overhaul-character-animation-manifests.mjs";

test("animation skeletons cover every ancestry at all five body sizes", () => {
  assert.deepEqual(validateCharacterAnimationSystem(), []);
  assert.equal(Object.keys(CHARACTER_SKELETON_SIZES).length, 5);
  assert.equal(Object.keys(ANCESTRY_SKELETON_OVERRIDES).length, 20);
  assert.deepEqual(
    Object.keys(ANCESTRY_SKELETON_OVERRIDES).sort(),
    ANCESTRY_VISUAL_TEMPLATES.map((entry) => entry.id).sort(),
  );

  let combinations = 0;
  for (const ancestry of ANCESTRY_VISUAL_TEMPLATES) {
    for (const size of [1, 2, 3, 4, 5]) {
      const skeleton = createAnimationSkeleton({ ancestryId: ancestry.id, size });
      combinations += 1;
      assert.equal(skeleton.cell.width, 32, `${ancestry.id}/${size}`);
      assert.equal(skeleton.cell.height, 32, `${ancestry.id}/${size}`);
      assert.equal(skeleton.groundAnchor.x, 16, `${ancestry.id}/${size}`);
      assert.equal(skeleton.groundAnchor.y, 28, `${ancestry.id}/${size}`);
      assert.equal(skeleton.ancestryId, ancestry.id);
      assert.equal(skeleton.size, size);
      assert.ok(Object.keys(skeleton.bones).length >= 12);
      assert.ok(skeleton.attachments.length >= 1);
      for (const point of Object.values(skeleton.bones)) {
        assert.equal(Number.isFinite(point.x), true);
        assert.equal(Number.isFinite(point.y), true);
      }
    }
  }
  assert.equal(combinations, 100);
});

test("runtime aliases resolve to the visual ancestry skeleton without changing the request contract", () => {
  assert.equal(createAnimationSkeleton({ ancestryId: "scaleheir", size: 3 }).ancestryId, "wyrmborn");
  assert.equal(createAnimationSkeleton({ ancestryId: "stonewrought", size: 4 }).ancestryId, "stoneborn");
  assert.equal(createAnimationSkeleton({ ancestryId: "rootwarden", size: 5 }).ancestryId, "treefolk");
  assert.throws(
    () => createAnimationSkeleton({ ancestryId: "unknown", size: 3 }),
    /Unknown animation ancestry/,
  );
  assert.throws(
    () => createAnimationSkeleton({ ancestryId: "human", size: 6 }),
    /Unknown character animation size/,
  );
});

test("basic pose resolution is deterministic for every state and direction", () => {
  const manifest = createAnimationManifest({
    id: "pose-proof",
    name: "Pose Proof",
    ancestryId: "minotaur",
    size: 5,
    focusProp: "test horn",
  });

  assert.deepEqual(manifest.directions, ANIMATION_DIRECTIONS.map((entry) => entry.id));
  assert.deepEqual(manifest.states, CHARACTER_ANIMATION_STATES);
  for (const stateId of CHARACTER_ANIMATION_STATES) {
    for (const direction of ANIMATION_DIRECTIONS) {
      const first = resolveAnimationPose(manifest, stateId, direction.id, 0.375);
      const second = resolveAnimationPose(manifest, stateId, direction.id, 0.375);
      assert.deepEqual(first, second, `${stateId}/${direction.id}`);
      assert.ok(first.frameIndex >= 0);
      assert.ok(first.frameIndex < manifest.clips[stateId].frames);
      for (const point of Object.values(first.bones)) {
        assert.equal(Number.isFinite(point.x), true, `${stateId}/${direction.id}`);
        assert.equal(Number.isFinite(point.y), true, `${stateId}/${direction.id}`);
      }
    }
  }
});

test("the registry supports additive mods and explicit replacements", () => {
  const registry = createCharacterAnimationRegistry();
  const first = registry.register({
    id: "mod-example",
    name: "Mod Example",
    ancestryId: "human",
    size: 3,
    focusProp: "mod focus",
  });
  assert.equal(registry.get("mod-example"), first);
  assert.deepEqual(registry.ids(), ["mod-example"]);
  assert.throws(
    () => registry.register({
      id: "mod-example",
      name: "Duplicate",
      ancestryId: "elf",
      size: 3,
    }),
    /already registered/,
  );

  const replacement = registry.register({
    id: "mod-example",
    name: "Replacement",
    ancestryId: "elf",
    size: 2,
    skeletonOverrides: {
      boneOffsets: { rightHand: { x: 1, y: -1 } },
      extraAttachments: [{ id: "mod-charm", anchors: [{ x: 18, y: 14 }] }],
    },
  }, { replace: true });
  assert.equal(registry.get("mod-example"), replacement);
  assert.equal(registry.get("mod-example").name, "Replacement");
  assert.ok(registry.get("mod-example").skeleton.attachments.some((entry) => entry.id === "mod-charm"));
  assert.equal(registry.unregister("mod-example"), true);
  assert.equal(registry.get("mod-example"), null);
});

test("all twenty-four overhaul slots have eight-direction basic animation manifests", () => {
  assert.deepEqual(validateOverhaulCharacterAnimationManifests(), []);
  assert.equal(OVERHAUL_CHARACTER_ANIMATION_MANIFESTS.length, 24);
  assert.deepEqual(
    [...new Set(OVERHAUL_CHARACTER_ANIMATION_MANIFESTS.map((entry) => entry.ancestryId))].sort(),
    ANCESTRY_VISUAL_TEMPLATES.map((entry) => entry.id).sort(),
  );
  assert.deepEqual(
    [...new Set(OVERHAUL_CHARACTER_ANIMATION_MANIFESTS.map((entry) => entry.size))].sort(),
    [1, 2, 3, 4, 5],
  );

  for (const entry of OVERHAUL_CHARACTER_ANIMATION_MANIFESTS) {
    assert.equal(entry.directions.length, 8, entry.id);
    assert.deepEqual(entry.states, CHARACTER_ANIMATION_STATES, entry.id);
    assert.equal(entry.spriteSheet.mode, "state-strips", entry.id);
    assert.match(entry.spriteSheet.pathTemplate, /\{state\}\.png$/);
  }

  assert.equal(getOverhaulCharacterAnimationManifest("nico").status, "promoted");
  assert.equal(getOverhaulCharacterAnimationManifest("samwise").status, "reviewed-source");
  assert.equal(getOverhaulCharacterAnimationManifest("angel-placeholder").status, "placeholder");
  assert.equal(getOverhaulCharacterAnimationManifest("not-present"), null);

  const registry = createOverhaulCharacterAnimationRegistry();
  assert.equal(registry.list().length, 24);
  assert.equal(registry.get("oh-tipi").name, "Oh Tipi");
});
