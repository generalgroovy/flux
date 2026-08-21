# FLUX runtime visual system

The runtime visual system is presentation-only. It may interpret authoritative
state, but it never decides movement, collision, visibility, resources, spell
membership, damage, cooldowns, score or outcomes.

## Expandable foundation

| Boundary | Canonical source | Responsibility |
| --- | --- | --- |
| Visual tokens | `content/visual/visual_language_v1.json` | Pixel grid, ordered ramps, twelve element shape/cadence identities, UI metrics, density budgets, layer order and review thresholds. |
| Validation/API | `src/presentation/visual_language.gd` | Fail-closed loading and typed access without local color invention. |
| Pixel components | `src/presentation/pixel_primitives.gd` | Stepped panels, dividers, material tiles, runes and resource treatments shared by world, spells and GUI. |
| Pixel placement | `src/presentation/pixel_presentation.gd` | Whole-output-pixel translation at 50/75/100% while simulation stays subpixel/fixed-point. |
| Gate specimen | `src/presentation/visual_specimen.gd` | Live `--visual-specimen` review of tokens and components; it is diagnostic evidence, not gameplay authority. |

Every promoted character, environment, spell and GUI slice must reuse these
boundaries or version them explicitly. A local hard-coded palette, arbitrary
layer, unbounded particle count or renderer-owned rule is a regression.

## Perspective and character read

FLUX uses top-down cardinal floors with tilted facades, not a diamond isometric
grid. Walkable tiles remain visually square; horizontal/vertical inputs map to
horizontal/vertical screen movement; wall feet, cover footprints, door
thresholds and elevation transitions stay visible. Facades may rise up to 0.85
of their readable footprint and foreground structures must cut away before they
hide legal information.

Champions use compact cartoon proportions at gameplay scale: a large expressive
head (40–45% of total body height), short sturdy limbs, chunky equipment,
1–2-pixel outlines, 3–5 colors per material and a separate grounded shadow.
South/east/north, jump, cast and hit silhouettes must read before detail is
approved. The revised concept board at
`assets/concept/visual-system-cartoon-perspective-v2.png` clarifies the intended
charm and body language, but its steep courtyard is explicitly not the runtime
camera target.

## V0 baseline

Baseline source captures were recorded on 2026-08-13 from commit `e996610` at
1280x720 and 1920x1080, camera 50/75/100%, full view, fixed 60 Hz. The 75% frame
demonstrates the primary failure clearly: flat schematic surfaces, tiny actor
scale and a text-heavy top HUD preserve rules but do not meet FLUX's charm,
material, silhouette or overview targets.

Run the live token specimen on Windows:

```powershell
scripts/run.cmd 60 --visual-specimen --pov-mode=full --camera-zoom=75
```

Or on Linux:

```bash
scripts/run.sh 60 --visual-specimen --pov-mode=full --camera-zoom=75
```

The specimen freezes vocabulary; it does not open the visual gate. V1–V6 in
`.agent/VISUAL-OVERHAUL.md` still require actual character, environment, spell,
GUI and integrated live evidence.

## V1 live renderer foundation

The Wellspring renderer now refuses to boot without the validated visual
language and derives its water, stone, timber, brass, roof, garden, focus and
text colors from the shared ramps. Quiet floors expose square screen-cardinal
cells, paths carry transverse seams rather than implied diagonal tiles, and
building art preserves its complete authored footprint plus an external door
threshold.

Decorative roofs and facades never own collision. A deterministic
presentation-only proximity mask replaces architecture with its cardinal
footprint near the observed actor, easing across a bounded 26-unit band. Cone
visibility continues to use the separate authoritative building bounds. The
same renderer, camera transform and cutaway calculation run at 60 and 120 Hz;
none of them write simulation state.

V1 captures at 1280x720 and 1920x1080 confirm alignment at the default 75%
overview. They remain internal evidence under `.godot/visual-gate-v1/`: the
live map is still schematic and the v2 character atlases are still too small
and crude. V2 therefore begins with compact cartoon production candidates for
Oh Tipi and S. Wayne before further environment beautification.

## V2 foundation champions and minimal motion

Oh Tipi and S. Wayne now draw from one promoted 672x192 runtime atlas with
96x96 cells, a 48x84 ground pivot and reviewed south/east/west/north, jump,
cast and hit silhouettes. The 1.7 MB generation source remains provenance-only
and is excluded from exports; the quantized runtime atlas is 46 KB. Atlas,
decoded-pixel and source hashes are pinned by
`content/visual/foundation_champion_visuals_v1.json` and
`assets/sprites/champions_v3/foundation/provenance.json`.

Animation is deliberately reusable rather than baked into gameplay code.
`content/visual/minimal_champion_motion_v1.json` declares bounded idle, walk,
sprint, low-profile, airborne, cast and hit keyframes for two motion profiles,
plus one restrained visual accent for every advanced movement family. The live
presenter derives pose selection only from authoritative state and samples one
60 Hz visual timeline at either simulation rate. Offsets stay within four
pixels, squash/stretch within 6%, reduced motion damps all three channels, and
the `--debug-overlay` diagnostic proves the sprite never owns its hitbox.

## V3 natural-map foundation in progress

`content/visual/natural_map_kit_v1.json` is the editable environment recipe.
It declares bounded district vocabularies, density, material ramps, seeded
edge props, ground variation and walk/sprint/slide/air contact marks.
`NaturalMapKit` validates the recipe, produces deterministic natural variation,
smooths visual route polylines without changing authored endpoints, and never
modifies collision, elevation, route metadata or simulation state. Actors and
training targets render after environmental detail so decorative growth cannot
hide gameplay information.

Use the deterministic movement review harness on Windows, changing the final
mode through `walk`, `sprint`, `slide`, `jump`, `air_dodge` and `technique`:

```powershell
scripts/run.cmd 60 --capture-spawn=300,720 --capture-pointer=900,720 --capture-movement=slide --champion=oh_tipi
```

This slice establishes animation/contact quality and reusable map resources; it
does not claim final V3 environment charm. Central architecture, landmark and
station art still require the next modular environment pass.

## Compact HUD and purposeful campus slice

`content/visual/compact_hud_v1.json` now owns the bounded combat-HUD geometry.
The live frame keeps only champion/location, session state, Health, Flux,
Stamina, the active Plain/Ctrl/Alt layer and exactly four active spell cells.
Detailed controls, mechanics and configuration remain at the existing
translucent Wellspring stations instead of permanently consuming navigation
space. The HUD remains under the shared 19% screen-coverage budget and does
not introduce a fifth spell button.

`content/visual/wellspring_wayfinding_v1.json` makes the 2560×1440 campus read
as a group of destinations: Movement Conservatory, Recovery Grove, Living
Archive, Wellspring Looms, Settings House, Farflow Gates, Dueling Court and
Elemental Crucible. `WellspringWayfinding` validates each point against its
authored district, shows at most four nearby labels and only draws
presentation-only brass/element markers. The renderer also gives each large
quarter a quiet identity motif—garden terraces, Nexus plaza rings or proving
targets—without changing collision, routes, elevation, visibility or authority.
