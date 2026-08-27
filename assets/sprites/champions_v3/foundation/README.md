# Foundation eight-direction body atlas provenance

This directory contains the active body-and-clothing-only production candidate
for Oh Tipi and S. Wayne. Grounded, empty-hand cast, and hit/recovery have
dedicated `S/SE/E/NE/N/NW/W/SW` art. Jump, walk, sprint, slide, and roll retain
the validated south/east/north/west art and deliberately resolve to the nearest
cardinal until their diagonal source sheets pass review. Spells,
elements, auras, projectiles, shadows, environments, tools, and equipment remain
independent runtime layers, so a pose or spell can be replaced without redrawing
the other.

## Reproducible layout

| Asset | Contract |
|---|---|
| `source_cardinal_oh_tipi_v4.png` | 1254×1254 matte source; 4 directions × 4 states |
| `source_cardinal_s_wayne_v4.png` | 1254×1254 matte source; 4 directions × 4 states |
| `source_movement_oh_tipi_v5.png` | 1254×1254 matte source; walk/sprint/slide/roll × 4 directions |
| `source_movement_s_wayne_v5.png` | 1254×1254 matte source; walk/sprint/slide/roll × 4 directions |
| `source_diagonal_core_oh_tipi_v6.png` | 1254×1254 matte source; SE/NE/NW/SW × grounded/cast/hit |
| `source_diagonal_core_s_wayne_v6.png` | 1254×1254 matte source; SE/NE/NW/SW × grounded/cast/hit |
| `runtime_atlas_eight_v6.png` | 768×1536 RGBA; 96×96 cells; pivot `(48,84)` |
| Columns | south/front, south-east, east, north-east, north/back, north-west, west, south-west |
| Rows per champion | grounded, jump, empty-hand cast, hit/recovery, walk, sprint, slide, roll |
| Atlas row layout | champion-major, state-minor: all Oh Tipi rows, then all S. Wayne rows |

Rebuild deterministically from repository root:

```powershell
python scripts/build_cardinal_champion_atlas.py assets/sprites/champions_v3/foundation/source_cardinal_oh_tipi_v4.png assets/sprites/champions_v3/foundation/source_cardinal_s_wayne_v4.png assets/sprites/champions_v3/foundation/runtime_atlas_eight_v6.png --oh-tipi-movement assets/sprites/champions_v3/foundation/source_movement_oh_tipi_v5.png --s-wayne-movement assets/sprites/champions_v3/foundation/source_movement_s_wayne_v5.png --oh-tipi-diagonal-core assets/sprites/champions_v3/foundation/source_diagonal_core_oh_tipi_v6.png --s-wayne-diagonal-core assets/sprites/champions_v3/foundation/source_diagonal_core_s_wayne_v6.png
```

The builder uses proportional source-cell boundaries because the generated
1254px canvas is not divisible by four. It removes only edge-connected magenta,
uses one bounded scale per champion, aligns every cell to the shared feet pivot,
packs the versioned atlas, and leaves unpromoted diagonal state cells transparent.
Exact source, PNG, and Godot-imported RGBA hashes
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

Oh Tipi movement/evasion:

```text
Use case: precise-object-edit
Asset type: production-candidate body-only locomotion source sheet for an original 2D top-down cartoon pixel-action game
Input image: Image 1 is the exact identity, clothing, proportions, palette, outline, and pixel-treatment reference for the blue seakin champion Oh Tipi.
Primary request: Create a clean 4 by 4 equal-cell sprite source sheet of Oh Tipi with exactly sixteen isolated full-body movement/evasion poses.
Grid contract: columns from left to right are SOUTH/front camera-facing, EAST/right profile, NORTH/centered back, WEST/left profile. Rows from top to bottom are WALK CONTACT, SPRINT DRIVE, LOW SLIDE, TUCKED ROLL. Maintain one consistent champion scale, feet baseline, outline weight, outfit, face, fin crown, cheek fins, tail, and compact proportions across the sheet. WALK shows a clear planted step with opposing arm/leg cadence; SPRINT has a stronger controlled directional lean and drive; SLIDE is low, elongated, and immediately distinct from running; ROLL is a compact tucked invulnerability silhouette. South stays balanced and camera-facing, north is a true centered back, east and west are opposing profiles.
Scene/backdrop: one flat opaque vivid magenta matte across the entire canvas; generous clear space between cells.
Style/medium: original charming compact cartoon pixel art, crisp 1-2 pixel outlines at intended gameplay scale, readable top-down cardinal facing, economical action silhouettes, no smooth painted rendering.
Constraints: champion pixels contain body and clothing only; all hands empty; no text or labels; no cell borders; no shadows; no magic; no elemental effects; no aura; no speed lines; no dust; no projectiles; no particles; no weapons; no staff, wand, rod, scepter, trident, focus, equipment, props, or environment. Preserve the non-sexualized compact body design. Do not add or remove limbs, fins, tail, clothing, or ancestry features. Keep exactly one Oh Tipi in each of sixteen cells and no other character.
Avoid: cropped figures, overlapping cells, inconsistent identity or scale, three-quarter/diagonal poses, isometric perspective, duplicated direction, spell pixels, detached objects, motion-effect pixels, extra characters, logos, watermark.
```

S. Wayne movement/evasion:

```text
Use case: precise-object-edit
Asset type: production-candidate body-only locomotion source sheet for an original 2D top-down cartoon pixel-action game
Input image: Image 1 is the exact identity, clothing, proportions, palette, outline, and pixel-treatment reference for the small hobbit champion S. Wayne.
Primary request: Create a clean 4 by 4 equal-cell sprite source sheet of S. Wayne with exactly sixteen isolated full-body movement/evasion poses.
Grid contract: columns from left to right are SOUTH/front camera-facing, EAST/right profile, NORTH/centered back, WEST/left profile. Rows from top to bottom are WALK CONTACT, SPRINT DRIVE, LOW SLIDE, TUCKED ROLL. Maintain one consistent champion scale, feet baseline, outline weight, face, round dark hair, purple-and-gold short cloak, large bare hobbit feet, and compact proportions across the sheet. WALK shows a clear planted step with opposing arm/leg cadence; SPRINT has a stronger controlled directional lean and drive; SLIDE is low, elongated, and immediately distinct from running; ROLL is a compact tucked invulnerability silhouette. South stays balanced and camera-facing, north is a true centered back, east and west are opposing profiles.
Scene/backdrop: one flat opaque vivid magenta matte across the entire canvas; generous clear space between cells.
Style/medium: original charming compact cartoon pixel art, crisp 1-2 pixel outlines at intended gameplay scale, readable top-down cardinal facing, economical action silhouettes, no smooth painted rendering.
Constraints: champion pixels contain body and clothing only; all hands empty; no text or labels; no cell borders; no shadows; no magic; no elemental effects; no aura; no speed lines; no dust; no projectiles; no particles; no weapons; no staff, wand, rod, scepter, focus, equipment, props, or environment. Preserve the non-sexualized compact body design. Do not add or remove limbs, hair, clothing, large bare feet, or ancestry features. Keep exactly one S. Wayne in each of sixteen cells and no other character.
Avoid: cropped figures, overlapping cells, inconsistent identity or scale, three-quarter/diagonal poses, isometric perspective, duplicated direction, spell pixels, detached objects, motion-effect pixels, extra characters, logos, watermark.
```

Oh Tipi diagonal core:

```text
Use case: precise-object-edit
Asset type: production-candidate body-only diagonal source sheet for an original 2D top-down cartoon pixel-action game
Input images: Image 1 is the exact identity, outfit, proportions, palette, outline, and pixel-treatment reference for the blue seakin champion Oh Tipi.
Primary request: Create a NEW clean 4-column by 3-row equal-cell sprite source sheet containing exactly twelve isolated full-body poses of the same Oh Tipi.
Grid contract: columns left to right are SOUTH-EAST/front-right three-quarter facing, NORTH-EAST/back-right three-quarter facing, NORTH-WEST/back-left three-quarter facing, SOUTH-WEST/front-left three-quarter facing. Rows top to bottom are GROUNDED/IDLE, EMPTY-HAND CAST PREPARATION, HIT/RECOVERY. Each diagonal must sit exactly halfway between the matching cardinal views from Image 1, clearly distinct from front/profile/back. Keep one consistent scale, centered feet baseline, outline weight, face, fin crown, cheek fins, tail, black-and-gold clothing, and compact non-sexualized proportions. Cast uses expressive empty hands; hit/recovery has a readable recoil silhouette.
Scene/backdrop: one flat opaque vivid magenta matte across the entire canvas, with generous clear space between equal cells.
Style/medium: original charming compact cartoon pixel art matching Image 1; crisp economical pixel clusters and gameplay-readable silhouette; no smooth painted rendering.
Constraints: body and clothing pixels only; exactly one Oh Tipi per cell; no text, labels, borders, shadows, magic, elements, auras, projectiles, particles, speed lines, weapons, staff, wand, trident, equipment, props, or environment. Preserve identity and anatomy. No cropped figures or overlaps.
Avoid: cardinal-only poses, duplicated columns, isometric view, spell pixels, detached objects, extra characters, logos, watermark.
```

S. Wayne diagonal core:

```text
Use case: precise-object-edit
Asset type: production-candidate body-only diagonal source sheet for an original 2D top-down cartoon pixel-action game
Input images: Image 1 is the exact identity, outfit, proportions, palette, outline, and pixel-treatment reference for the small hobbit champion S. Wayne.
Primary request: Create a NEW clean 4-column by 3-row equal-cell sprite source sheet containing exactly twelve isolated full-body poses of the same S. Wayne.
Grid contract: columns left to right are SOUTH-EAST/front-right three-quarter facing, NORTH-EAST/back-right three-quarter facing, NORTH-WEST/back-left three-quarter facing, SOUTH-WEST/front-left three-quarter facing. Rows top to bottom are GROUNDED/IDLE, EMPTY-HAND CAST PREPARATION, HIT/RECOVERY. Each diagonal must sit exactly halfway between the matching cardinal views from Image 1, clearly distinct from front/profile/back. Keep one consistent scale, centered feet baseline, outline weight, face, round dark hair, purple-and-gold short cloak, large bare hobbit feet, warm skin tone, and compact non-sexualized proportions. Cast uses expressive empty hands; hit/recovery has a readable recoil silhouette.
Scene/backdrop: one flat opaque vivid magenta matte across the entire canvas, with generous clear space between equal cells.
Style/medium: original charming compact cartoon pixel art matching Image 1; crisp economical pixel clusters and gameplay-readable silhouette; no smooth painted rendering.
Constraints: body and clothing pixels only; exactly one S. Wayne per cell; no text, labels, borders, shadows, magic, elements, auras, projectiles, particles, speed lines, weapons, staff, wand, focus, equipment, props, or environment. Preserve identity and anatomy. No cropped figures or overlaps.
Avoid: cardinal-only poses, duplicated columns, isometric view, spell pixels, detached objects, extra characters, logos, watermark.
```

Human visual/originality acceptance is still required before final-art
promotion; automated validation proves structure, provenance, importability,
layer separation, and live mapping only.
