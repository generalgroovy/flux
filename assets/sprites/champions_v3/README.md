# Reusable champion body atlases v3

The current foundation candidate is a body-and-clothing-only atlas for Oh Tipi
and S. Wayne. It deliberately contains no spells, elements, particles, aura,
shadow, environment, tools, weapons, equipment or detached focus; those layers
are composed independently by the runtime. This keeps character art reusable
when a spell, material, HUD or map changes.

The runtime contract has exactly three body types: `small`, `middle`, and
`large`. The canonical body sheet uses six cells per row: south/front idle,
east profile, north/back, front jump, front empty-hand cast preparation and
front hit/recovery. West is a deterministic mirror of east. Front faces are
centered and symmetrical toward the camera; back views are centered and
consistent with the same pivot.

Canonical files:

- `source_sheet_body_v3.png` - editable 1536×1024 source, flat matte, two rows;
- `runtime_atlas_body_v3.png` - deterministic 672×192 RGBA runtime atlas;
- `provenance.json` - source/runtime hashes, import policy and generation prompt.

See `content/visual/foundation_champion_visuals_v1.json` and
`docs/SPRITE-PIPELINE.md` for validation and promotion boundaries. Older v2
race atlases and `size_*` folders are compatibility/archive material, not new
runtime body types.
