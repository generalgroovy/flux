# Extending FLUX2 visual assets

The Wellspring v2 visual pipeline is manifest-driven and deterministic. Runtime
art is generated from versioned profile data and validated before it is accepted
by Godot or CI.

## One-command workflow

```bash
python tools/assets/generate_wellspring_visual_catalog_v2.py
python tools/assets/validate_wellspring_visual_catalog_v2.py
scripts/test.sh
```

## Add a race

1. Add one entry to `RACES` in `tools/assets/wellspring_catalog_data_v2.py`.
2. Provide a stable ID, player-facing name, feature family, default size, palette,
   exemplar name and status.
3. Add exemplar affinities and equipment in
   `tools/assets/generate_wellspring_visual_catalog_v2.py`.
4. Extend race-specific rendering only when the existing feature grammar cannot
   communicate the new anatomy clearly.
5. Regenerate and validate.

The legacy generator creates five archived size paths, masculine and feminine presentation bases, a
named complete exemplar, all 25 animations in eight directions, portraits,
previews, registries and README rows.

Current runtime authoring uses exactly three body types (`small`, `middle`,
`large`). Map legacy `tiny→small`, `medium→middle`, and `huge→large`; do not
add a fourth body type. Champion atlases must contain body/clothing pixels only;
spells, shadows, auras, environment and equipment are separate layers.

## Add a champion

1. Copy `art/templates/champion_profile_v2.json` as a design worksheet.
2. Add the approved profile to the authoritative champion source or the v2
   canonical override table.
3. Use an existing race/body plan. New anatomy belongs in the race layer, not a
   private champion-only skeleton.
4. Regenerate and validate.

A champion package contains its runtime atlas, debug atlas, direction preview,
all-keyframe board, 48 px selection icon, 64 px HUD portrait, 128 px roster
portrait and 256 px hero portrait.

## Add a Wellspring district

1. Copy `art/templates/wellspring_district_v2.json`.
2. Add the district metadata to `DISTRICTS`.
3. Implement a modular 80×45 layout in `district_layout()`.
4. Include at least one landmark, an ordinary route, an advanced route,
   collision, worldbone, navigation, elevation, reset and safety data.
5. Regenerate and validate.

Rendered pixels never replace authoritative simulation state. Collision,
materials, chemistry, damage, navigation and line of sight must be read from
versioned data.

## Add animation or equipment

Animation IDs and blocks are inherited from the canonical skeleton contract in
`tools/assets/generate_visual_assets_v1.py`. Extend that contract through a
versioned migration rather than changing atlas coordinates silently.

Equipment should use the standard hand, back, cast and effect anchors. Oversized
weapons, wings, tails and canopies remain visual attachments and must not alter
collision or attack reach.

## Quality gate

An asset is rejected when its identity depends on a label or recolour, when its
race or equipment is unreadable at gameplay zoom, when keyframes or directions
are missing, when it uses fractional scaling, or when its files are not committed
and registered. Review at 3×, 4× and 6× nearest-neighbour scale.
