# Skeleton animation pipeline v1

This slice replaces unreadable presentation boards with a deterministic,
importable three-body animation foundation. It is presentation-only: simulation, collision,
movement authority, and combat outcomes remain under `src/sim/`.

The only runtime body IDs are `small`, `middle`, and `large`. Historical
`size_1_tiny`, `size_3_medium`, and `size_5_huge` folders remain compatibility
storage and map to those IDs; no new content may author them.

## Runtime assets

Each body type has two 960×1280 transparent PNG atlases:

- `skeleton_atlas.png` — clean mannequin frames for runtime composition;
- `skeleton_overlay_debug_atlas.png` — the same frames with a cyan silhouette
  envelope, centerline, red shared pivot, and feet baseline.

Every frame uses a **32×32 virtual-pixel cell** and the exact pivot **(16, 28)**.
The body grows from the small envelope through the large envelope without moving
the pivot. This is the contract future ancestry and champion layers must inherit.

The runtime direction order is:

```text
south, south_east, east, north_east,
north, north_west, west, south_west
```

The acceptance direction order is the four cardinal subset:

```text
south (front), east (profile), north (back), west (profile/mirror)
```

Every animation state must have a valid frame region for all four cardinals in
each of `small`, `middle`, and `large`. Diagonals may be authored or derived
from the nearest cardinal, but a missing cardinal frame fails validation. This
keeps readable facing and action feedback intact while the simulation continues
to aim on a continuous world-space vector.

The 25 animation states cover the currently planned foundation:

```text
idle, walk, sprint, hop, double_jump, rise, fall, land,
wall_contact, wall_kick, air_dodge, wavedash, slide, slide_jump,
vault, superglide, attack_primary, cast, defend, hit, stunned,
rooted, defeated, interact, taunt
```

Frame counts, timing, looping, tags, event frames, atlas blocks, size metrics, and
paths live in `content/animations/skeleton_animation_manifest_v1.json`.

## Singular animation PNGs

The runtime uses five atlases to minimize imports and texture switches. For art
review or modding, export one transparent PNG per size and animation:

```bash
python tools/sprites/export_skeleton_animation_pngs.py \
  --output /tmp/flux2-skeleton-pngs
```

A ready-made archive is committed as
`assets/sprites/skeletons/skeleton_animation_pngs_v1.zip`.

Each exported PNG has one row per direction and one column per frame. No title,
background, margin card, or decorative board is included.

## Character overlay rule

A character assigned to a size must use the same:

- 32×32 cell;
- bottom-center pivot `(16, 28)`;
- animation block, direction, and frame index;
- foot baseline and event frame;
- atlas region returned by `SkeletonAnimationLibrary`.

The current champion foundation atlas is stricter: its pixels contain body and
clothing only. Hair, horns, fins, wings, shadows, auras, spells, projectiles,
equipment and effects are independent layers; they may not change the pivot or
silently shift the feet. Oversized features need an explicit attachment anchor
and an authored clipping/occlusion test.

The active Oh Tipi/S. Wayne candidate uses two 4×4 source sheets per champion:
direction columns `south/east/north/west`, core semantic rows
`grounded/jump/cast/hit`, and movement rows `walk/sprint/slide/roll`. Run
`scripts/build_cardinal_champion_atlas.py` with both movement flags to pack
the versioned 384×1536 atlas with 96×96 cells and pivot `(48,84)`. The builder
derives proportional source boundaries, removes edge-connected matte and uses
one bounded scale per champion across all sixteen cells. Runtime rows are
champion-major then state-minor; runtime columns are the four cardinals. Exact
source prompts, hashes and the build command live in
`assets/sprites/champions_v3/foundation/`.

The debug atlas and
`assets/sprites/skeletons/skeleton_overlay_validation.png` provide the acceptance
reference for all three body types.

## Loader and tests

`SkeletonAnimationLibrary` validates the manifest, asset presence, atlas sizes,
unique blocks, regions, directions, explicit cardinal coverage, and pivot. The
headless test iterates every size, animation, cardinal direction, full direction
and frame so an invalid overlay cannot enter the main branch unnoticed.
