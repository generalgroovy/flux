# Pixel asset integration checkpoint

Status: **verified playable source candidate; human visual acceptance pending** (2026-09-06).

This presentation-only slice follows the verified low-hop/first-eight chemistry
checkpoint `286bd8f`. The user's finished packs replace material/movement effect
drawing and selected Wellspring terrain/props, not the simulation or layout.

| Source | Authority and use | Deliberate boundary |
|---|---|---|
| [Oh Tipi](../reference/art/oh_tipi_authority_v1/README.md) | New authoritative character-design/rework reference, copied unchanged | One illustration, not an eight-direction action atlas; preserve live characters until replacement passes motion review |
| [Magic pack](../art_batches/pixel_v1/magic/integration.md) | 474 normal/reduced sequences, 1,960 frames, three shared RGBA pages; phase timing from 120 Hz authority | Frame availability is not user visual acceptance; source metadata remains original candidate evidence |
| [Map pack](../art_batches/pixel_v1/map/integration.md) | User ZIP, 250 asset IDs / 274 frames, four category atlases; terrain/prop presentation on existing campus | Original provisional material palette reviewed as a test candidate, not a canonical shared palette rewrite; sample courtyard is not production geometry |

![New character styling authority](../reference/art/oh_tipi_authority_v1/oh-tipi-authoritative-reference.png)

The reference trident and atmospheric aura are not instructions to restore
weapons or bake effects into body sprites. Hands cast; shadows/magic remain
separate. Small/middle/large and all eight motion directions stay unchanged.

## Ordered acceptance slices

| Slice | Implementation | Proof required |
|---|---|---|
| P1 shared magic | Hash-checked immutable manifest/pages, nearest lossless sampling, exact 120 Hz frame timing | Authored validator, malformed metadata and exact imported RGBA tests |
| P2 spells/movement | Pixel flight, tails, impact, hand cues, beam/spray/field materials, actual jump/slide/landing/protection accents | No changes to hit shapes, paid admission or invulnerability; reduced/expired cues and body-only masks tested |
| P3 chemistry | Native pixel material in exact occupied masks; safe holes, connected paths, worldbone clipping and single Hail pulse | All 36 reactions, live-link expiry, phase cancellation, bounded optional decoration and real paid casts |
| P4 Wellspring | Existing surface classifications and real prop slots use map pack; existing worldbone footprints retained | Terrain seams, pivot/atlas bounds, exact import pixels, gameplay-scale screenshot |
| P5 combined checkpoint | Full source gate, representative rendered capture, export resource check, local host/join and source launch | Record exact evidence below; do not claim installer/internet/120 FPS acceptance |
| Later character work | Oh Tipi middle-body pilot, complete eight-way extension, then remaining bodies | User visual approval and stable action extents before replacing live sheets |

## Asset safety and maintainability

- Original pack manifests, QA reports and source art remain unchanged; this
  separate integration record distinguishes candidate authorship from runtime use.
- User map ZIP SHA-256:
  `21829cb6619d4f8f7caf7e4049bad4f4d51a82ff803237ef8a51db35a7e67486`;
  316 validated unique paths / 4,625,775 expanded bytes, no existing files overwritten.
- Map and magic use cached atlas textures, not one scene node per grain or tile.
  Pixel textures never define collision, timing, spell admission or damage.
- Connected matter ends when its actual required links die. Empty ring centres,
  worldbone shadows and actual optical segment origins must stay honest.
- Original map architecture parts remain available for a later facade-composition
  slice; arbitrary existing buildings are not stretched to a mismatched sample facade.
- Editable sources and previews stay in `art_batches/pixel_v1`; player exports
  should contain only required metadata and runtime resources, never reference art.

## Test and launch

| Final check | Result / evidence |
|---|---|
| Full Windows source gate | 85 suites / 270,135 assertions; zero failures/warnings, stderr 0 bytes; `.godot/receipts/pixel-assets-integration-final.json` |
| Real paid chemistry capture | Fire + Water form Steam at tick 65 through ordinary paid casts; 120 captured frames each in normal100% and reduced75% modes |
| Map capture | Actual1280x720 at75%; new paving/earth/grass transitions, lecterns, banners and planters; unchanged layout |
| Local Farflow | Host/join, shared greeting, reconciliation, round transition, late join, spectating, rematch and stewardship pass; `.godot/farflow-smoke/` |
| Exported resources | Nine required files present; all474 magic sequences/3 pages and250 map assets/4 pages pass exact loader integrity; `.godot/pixel-assets-export/audit-v3-pack.log` |
| Windows player boot | Real exported Windows executable starts from an isolated directory at120Hz, no source checkout dependency; `.godot/pixel-assets-export/boot-v3-isolated.log` |

![Actual map integration](evidence/pixel-assets-v1/wellspring-source.png)

[Normal Steam capture](evidence/pixel-assets-v1/steam-standard.png) and
[reduced-effects capture](evidence/pixel-assets-v1/steam-reduced.png) are actual
rendered frames, not art targets. Movie recording time includes PNG encoding and
does not establish live performance. Heavy-load120FPS and human charm/readability
approval remain open from the previous checkpoint.

The first export audit caught Godot omitting original PNGs despite include filters.
`addons/pixel_assets_export` now atomically adds the seven exact hash-checked
originals (118,849 bytes) while preserving normal imported textures. The addon
and authoring previews/sources are excluded from player payloads. Source file
hash checks remain source-only where appropriate; no loader integrity was weakened.

An editor binary running a PCK still reports the editor feature and is not a
valid substitute for a release executable boot. The final boot used the actual
Windows release template, with no unsupported path-override flags.

Run `flux.cmd play` from the checkout for this source checkpoint.
Already-downloaded installers do not gain these assets automatically.
