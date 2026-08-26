# Foundation cardinal body atlas provenance

This directory contains the active body-and-clothing-only production candidate
for Oh Tipi and S. Wayne. Every grounded, jump, empty-hand cast, and
hit/recovery pose has dedicated south, east, north, and west art. Spells,
elements, auras, projectiles, shadows, environments, tools, and equipment remain
independent runtime layers, so a pose or spell can be replaced without redrawing
the other.

## Reproducible layout

| Asset | Contract |
|---|---|
| `source_cardinal_oh_tipi_v4.png` | 1254×1254 matte source; 4 directions × 4 states |
| `source_cardinal_s_wayne_v4.png` | 1254×1254 matte source; 4 directions × 4 states |
| `runtime_atlas_cardinal_v4.png` | 384×768 RGBA; 96×96 cells; pivot `(48,84)` |
| Columns | south/front, east, north/back, west |
| Rows per champion | grounded, jump, empty-hand cast, hit/recovery |
| Atlas row layout | champion-major, state-minor: all Oh Tipi rows, then all S. Wayne rows |

Rebuild deterministically from repository root:

```powershell
python scripts/build_cardinal_champion_atlas.py assets/sprites/champions_v3/foundation/source_cardinal_oh_tipi_v4.png assets/sprites/champions_v3/foundation/source_cardinal_s_wayne_v4.png assets/sprites/champions_v3/foundation/runtime_atlas_cardinal_v4.png
```

The builder uses proportional source-cell boundaries because the generated
1254px canvas is not divisible by four. It removes only edge-connected magenta,
uses one bounded scale per champion, aligns every cell to the shared feet pivot,
and packs the versioned atlas. Exact source, PNG, and Godot-imported RGBA hashes
are pinned in `provenance.json`.

## Exact ImageGen prompts

Oh Tipi:

```text
Use case: precise-object-edit
Asset type: production-candidate body-only source sheet for a 2D top-down cartoon pixel-action game
Input image: Image 1 is the identity, clothing, proportion, palette, and pixel-treatment reference. Use only the blue seakin champion Oh Tipi from the top row.
Primary request: Create a clean 4 by 4 equal-cell sprite source sheet of Oh Tipi with exactly sixteen isolated full-body poses.
Grid contract: columns from left to right are SOUTH/front camera-facing, EAST/right profile, NORTH/centered back, WEST/left profile. Rows from top to bottom are IDLE, JUMP, EMPTY-HAND CAST PREPARATION, HIT/RECOVERY. Keep every figure centered in its cell with the same feet baseline, scale, outline weight, outfit, face, fin crown, cheek fins, tail, and compact proportions. South is balanced and symmetrical; north is a true centered back; east and west are readable opposing profiles. Jump, cast, and hit silhouettes must remain visibly distinct in every direction.
Scene/backdrop: one flat opaque vivid magenta matte across the entire canvas; generous clear space between cells.
Style/medium: original charming compact cartoon pixel art, crisp 1-2 pixel outlines at intended gameplay scale, readable top-down cardinal facing, no smooth painted rendering.
Constraints: champion pixels contain body and clothing only; all hands empty; no text or labels; no cell borders; no shadows; no magic; no elemental effects; no aura; no projectiles; no particles; no weapons; no staff, wand, rod, scepter, trident, focus, equipment, props, or environment. Preserve the non-sexualized compact body design. Do not add or remove limbs, fins, tail, clothing, or ancestry features. Keep exactly one Oh Tipi in each of sixteen cells and no other character.
Avoid: cropped figures, overlapping cells, inconsistent identity or scale, three-quarter/diagonal poses, isometric perspective, duplicated direction, spell pixels, detached objects, extra characters, logos, watermark.
```

S. Wayne:

```text
Use case: precise-object-edit
Asset type: production-candidate body-only source sheet for a 2D top-down cartoon pixel-action game
Input image: Image 1 is the identity, clothing, proportion, palette, and pixel-treatment reference. Use only the small hobbit champion S. Wayne from the bottom row.
Primary request: Create a clean 4 by 4 equal-cell sprite source sheet of S. Wayne with exactly sixteen isolated full-body poses.
Grid contract: columns from left to right are SOUTH/front camera-facing, EAST/right profile, NORTH/centered back, WEST/left profile. Rows from top to bottom are IDLE, JUMP, EMPTY-HAND CAST PREPARATION, HIT/RECOVERY. Keep every figure centered in its cell with the same feet baseline, scale, outline weight, face, round dark hair, purple-and-gold short cloak, large bare hobbit feet, and compact proportions. South is balanced and symmetrical; north is a true centered back; east and west are readable opposing profiles. Jump, cast, and hit silhouettes must remain visibly distinct in every direction.
Scene/backdrop: one flat opaque vivid magenta matte across the entire canvas; generous clear space between cells.
Style/medium: original charming compact cartoon pixel art, crisp 1-2 pixel outlines at intended gameplay scale, readable top-down cardinal facing, no smooth painted rendering.
Constraints: champion pixels contain body and clothing only; all hands empty; no text or labels; no cell borders; no shadows; no magic; no elemental effects; no aura; no projectiles; no particles; no weapons; no staff, wand, rod, scepter, focus, equipment, props, or environment. Preserve the non-sexualized compact body design. Do not add or remove limbs, hair, clothing, or ancestry features. Keep exactly one S. Wayne in each of sixteen cells and no other character.
Avoid: cropped figures, overlapping cells, inconsistent identity or scale, three-quarter/diagonal poses, isometric perspective, duplicated direction, spell pixels, detached objects, extra characters, logos, watermark.
```

Human visual/originality acceptance is still required before final-art
promotion; automated validation proves structure, provenance, importability,
layer separation, and live mapping only.
