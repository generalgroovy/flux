# Character animation skeleton contract

This document defines the presentation-only skeleton used to author and mod FLUX champions before full sprites are promoted into the live renderer.

The system deliberately does not own collision, hitboxes, damage, cooldowns, movement authority, or networking. It translates authoritative entity state into reusable animation clip names.

## Coverage

- 20 ancestry skeletons from the canonical README roster.
- All five body sizes: Tiny, Small, Medium, Large, and Huge.
- Eight directional facings: south, southeast, east, northeast, north, northwest, west, southwest.
- A complete 24-slot character animation manifest, including the temporary Angel slot.
- Compatibility aliases for current mechanical ancestry IDs and promoted runtime character IDs.

Every ancestry can be generated at every size for visual prototyping. Gameplay race-size restrictions remain separate balance data and may reject combinations that the presentation system can still preview.

## Required movement clips

The base clip set contains:

- `idle`, `walk`, `run`, `sprint`
- `jump-start`, `jump-rise`, `jump-apex`, `fall`, `land`
- `slide-start`, `slide-loop`, `slide-end`, `slide-jump`
- `wall-contact`, `wall-jump`, `air-redirect`, `air-dodge`, `wavedash`
- `vault-start`, `vault-cross`, `vault-land`, `superglide`
- `launched`, `grappled`, `charging`
- `cast-primary`, `cast-special`, `cast-ultimate`
- `defend`, `hit`, `stunned`, `rooted`, `slowed`, `defeated`

Each clip defines frame count, playback rate, looping behavior, channel, root-motion policy, and named events. Character mods can replace only the clips they need.

## Atlas layout

`createAnimationAtlasLayout()` uses one row per clip. Each row contains eight direction blocks in canonical direction order. Every direction block reserves the maximum frame count used by the clip set, making rows deterministic and easy to replace without rewriting atlas metadata.

The default virtual cell is `32 x 32`; mods may request another cell size. Runtime scaling remains nearest-neighbour pixel scaling.

## Adding a character

```js
import {
  buildCharacterAnimationSkeleton,
  createCharacterAnimationManifest,
} from "../src/character-animation-skeletons.mjs";

const manifest = createCharacterAnimationManifest({
  id: "mod-river-smith",
  name: "River Smith",
  ancestryId: "stoneborn",
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

const skeleton = buildCharacterAnimationSkeleton(manifest);
```

A mod should provide:

1. A unique stable `id` and display `name`.
2. One supported `ancestryId`.
3. A size from 1 through 5.
4. A focus prop and optional affinity labels.
5. Only the clip and joint overrides that differ from the ancestry defaults.
6. Sprite pixels following the generated atlas coordinates.

Do not copy a renderer for each champion. Add ancestry anatomy once, compose a character manifest, and override only visible exceptions.

## State resolution

`resolveCharacterAnimationState(entity, cooldowns)` maps authoritative match fields to the extended animation grammar. Reaction states take precedence over actions, and committed traversal takes precedence over ordinary locomotion. Current compatibility states remain supported through aliases:

- `move` -> `run`
- `commit` -> `cast-special`
- `sliding` -> `slide-loop`
- `air-dodging` -> `air-dodge`
- `vaulting` -> `vault-cross`

Explicit `entity.animationState` values are accepted for specimens and tools, but live gameplay should derive animation from authoritative state rather than client-owned requests.

## Promotion order

1. Validate the manifest and generated skeleton.
2. Produce the eight-direction idle sheet.
3. Produce universal locomotion and traversal clips.
4. Add reaction and cast clips.
5. Add character-specific props, aura, wear, and accessibility cues.
6. Test nearest-neighbour scaling and dense-fight readability.
7. Integrate without changing simulation geometry.
8. Pass local, network, reconnect, spectator, Windows, Linux, and packaged-smoke gates before selection is enabled.
