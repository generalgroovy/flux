# Reusable champion body atlases v3

The current foundation candidate is a state-scoped eight-direction
body-and-clothing-only atlas
for Oh Tipi and S. Wayne. It deliberately contains no spells, elements, particles, aura,
shadow, environment, tools, weapons, equipment or detached focus; those layers
are composed independently by the runtime. This keeps character art reusable
when a spell, material, HUD or map changes.

The runtime contract has exactly three body types: `small`, `middle`, and
`large`. Champion-to-row assignment lives in the visual recipe. Each source has
eight runtime direction columns (`S/SE/E/NE/N/NW/W/SW`). Its core cardinal
source contributes grounded/jump/cast/hit, its movement source contributes
walk/sprint/slide/roll, and its diagonal core source promotes grounded/cast/hit;
unpromoted diagonal states resolve explicitly to the nearest cardinal. Front
faces are centered and symmetrical toward the camera, back views are centered,
and both profiles are authored rather than mirrored at runtime.

Canonical files:

- `source_cardinal_*_v4.png`, `source_movement_*_v5.png`, and `source_diagonal_core_*_v6.png` - editable flat-matte sources;
- `runtime_atlas_eight_v6.png` - deterministic 768×1536 RGBA runtime atlas;
- `provenance.json` - source/runtime hashes, import policy and generation prompt.

See `content/visual/foundation_champion_visuals_v1.json` and
`docs/SPRITE-PIPELINE.md` for validation and promotion boundaries. Older v2
race atlases and `size_*` folders are compatibility/archive material, not new
runtime body types.
