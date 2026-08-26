# Reusable champion body atlases v3

The current foundation candidate is a four-cardinal body-and-clothing-only atlas
for Oh Tipi and S. Wayne. It deliberately contains no spells, elements, particles, aura,
shadow, environment, tools, weapons, equipment or detached focus; those layers
are composed independently by the runtime. This keeps character art reusable
when a spell, material, HUD or map changes.

The runtime contract has exactly three body types: `small`, `middle`, and
`large`. Champion-to-row assignment lives in the visual recipe. Each source has
four direction columns (south/east/north/west). Its core source contributes
grounded/jump/cast/hit and its movement source contributes
walk/sprint/slide/roll; the runtime packs all eight states under each champion. Front
faces are centered and symmetrical toward the camera, back views are centered,
and both profiles are authored rather than mirrored at runtime.

Canonical files:

- `source_cardinal_*_v4.png` and `source_movement_*_v5.png` - editable 4×4 flat-matte sources;
- `runtime_atlas_cardinal_v5.png` - deterministic 384×1536 RGBA runtime atlas;
- `provenance.json` - source/runtime hashes, import policy and generation prompt.

See `content/visual/foundation_champion_visuals_v1.json` and
`docs/SPRITE-PIPELINE.md` for validation and promotion boundaries. Older v2
race atlases and `size_*` folders are compatibility/archive material, not new
runtime body types.
