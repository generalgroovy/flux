# Skeleton animation pipeline v1

This slice replaces unreadable presentation boards with a deterministic, importable
five-size animation foundation. It is presentation-only: simulation, collision,
movement authority, and combat outcomes remain under `src/sim/`.

## Runtime assets

Each size has two 960×1280 transparent PNG atlases:

- `skeleton_atlas.png` — clean mannequin frames for runtime composition;
- `skeleton_overlay_debug_atlas.png` — the same frames with a cyan silhouette
  envelope, centerline, red shared pivot, and feet baseline.

Every frame uses a **32×32 virtual-pixel cell** and the exact pivot **(16, 28)**.
The body grows from 12 pixels for Tiny through 28 pixels for Huge without moving
the pivot. This is the contract future ancestry and champion layers must inherit.

Direction order is:

```text
south, south_east, east, north_east,
north, north_west, west, south_west
```

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

Character layers may extend outside the mannequin's body envelope for hair,
horns, fins, wings, equipment, or effects, but they may not change the pivot or
silently shift the feet. Oversized features need an explicit attachment anchor
and an authored clipping/occlusion test.

The debug atlas and
`assets/sprites/skeletons/skeleton_overlay_validation.png` provide the acceptance
reference for all five sizes.

## Loader and tests

`SkeletonAnimationLibrary` validates the manifest, asset presence, atlas sizes,
unique blocks, regions, directions, and pivot. The headless test iterates every
size, animation, direction, and frame so an invalid overlay cannot enter the
main branch unnoticed.
