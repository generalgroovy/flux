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
head (40–45% of total body height), short sturdy limbs, body-and-clothing-only
pixels, 1–2-pixel outlines, 3–5 colors per material and a separate grounded
shadow. South/front faces the camera symmetrically; north/back is centered;
east is authored profile and west mirrors it. Jump, cast and hit silhouettes
must read before detail is approved. The revised concept board at
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

Oh Tipi and S. Wayne now draw from one promoted 672x192 body-only runtime atlas
with 96x96 cells, a 48x84 ground pivot and reviewed south/east/west/north,
jump, cast and hit silhouettes. The 1.7 MB generation source remains provenance-only
and is excluded from exports; the quantized runtime atlas is 46 KB. Atlas,
decoded-pixel and source hashes are pinned by
`content/visual/foundation_champion_visuals_v1.json` and
`assets/sprites/champions_v3/foundation/provenance.json`; the manifest also
requires the canonical body type and explicitly excluded baked layers.

Animation is deliberately reusable rather than baked into gameplay code.
`content/visual/minimal_champion_motion_v1.json` declares bounded idle, walk,
sprint, low-profile, airborne, cast and hit keyframes for two motion profiles,
plus one restrained visual accent for every advanced movement family. The live
presenter derives pose selection only from authoritative state and samples one
60 Hz visual timeline at either simulation rate. Offsets stay within four
pixels, squash/stretch within 6%, reduced motion damps all three channels, and
the `--debug-overlay` diagnostic proves the sprite never owns its hitbox.

## V3 natural-map and modular-campus candidate

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

`content/visual/wellspring_architecture_kit_v1.json` adds the next reusable
environment boundary. Seven building profiles, ten station-furniture profiles,
five landmark frames and one source-court profile validate against the live
campus before rendering. Material-textured facades, roof facets/dormers/domes,
visible doors, planted pavers, shallow water channels and landmark furniture
reuse the approved `SanctumRuntimeKit`; reference/concept pixels never enter the
runtime path.

The source-court profile now carries six bounded decoration anchors. Lanterns
mark the lateral approaches, planters soften the lower corners, and elemental
runes bookend the north/south lanes. Anchors are validated against the court
interior, use shared language ramps, and draw after pavers with reduced-effects
alpha; they are presentation-only and cannot occlude actors, alter collision, or
change station interaction radii.

The architecture kit remains presentation-only. Authored campus data still owns
topology, collision, route endpoints, elevation, station commands and interaction
radii; the existing deterministic cutaway still uses the canonical footprint.
Final engineering captures under `.godot/v3-acceptance-*` cover the garden,
Nexus and proving quarter; Nexus at 50/75/100%; and a deterministic partial
building cutaway. Scenic-edge props remain legible at overview zoom, nearby
waypoint labels yield the actor-readable lane, paths remain above decoration and
the compact HUD preserves its play-space budget. This completes V3's engineering
slice and opens V4; subjective final cohesion is still scored at integrated V6.

The post-unification review on 2026-08-26 extended this evidence with truthful
1280×720 captures at 50%, 75% and 100%, a 1920×1080 capture at 75%, and a
20-frame 1280×720/75% startup-and-chain cast run, plus four-frame
high-contrast and reduced-effects runs. The source court's six decoration
anchors remain visible at overview and detail scales. These captures prove
dimensions, launchability, and alignment only; the V6 rubric still needs
interactive two-player and subjective cohesion review.

## V4 foundation-spell presentation

`content/visual/foundation_spell_visuals_v1.json` is the exact five-spell visual
contract. It is validated against the ability catalog at boot: stable wire ID,
shape, element and residue must match, every spell must own one distinct startup
silhouette, and the effect/lane/curve budgets remain bounded. A catalog mismatch
stops startup rather than silently rendering a misleading spell.

`FoundationSpellPresenter` reads only authoritative presentation state. Pending
cast ticks drive startup progress; projectile and field entities drive their
existing geometry/lifetime; semantic beam, spray, hit, trigger and refusal events
drive short feedback. It cannot change a cast's range, radius, collision, cost,
cooldown, damage, control, material result or outcome.

`content/visual/spell_animation_skeletons_v1.json` is the reusable delivery
grammar shared by those profiles. It defines five bounded phases—startup,
release, travel, impact and residue—for projectile, beam, spray and field
shapes, with explicit draw-family and readability-cue tokens. The
`SpellAnimationSkeletonLibrary` loader rejects missing, overlapping, reordered or
unbounded phases; `FoundationSpellPresenter` refuses a profile whose
`skeleton_id` does not match its authoritative delivery shape. This keeps
hand-origin anticipation, lane/endpoint reads and quiet residue editable data
while simulation continues to own the actual timeline and result. The presenter
now renders the shared startup origin ring and release flash from those first
two phase IDs before each spell's specific silhouette, giving every cast a
consistent readable hand beat without adding a gameplay event.

The manifest is registered in `content/visual/visual_asset_registry_v1.json`
and its SHA-256 is printed in the Windows bootstrap diagnostic next to the
foundation profile hash. A capture or handoff that shows a different skeleton
hash is a different visual build, even when simulation content is unchanged.

| Spell | Startup | Action/trail | Impact/residue |
| --- | --- | --- | --- |
| Rillshot | Gathered Water drop | Faceted drop with split rill wake | Expanding splash ring; no residue |
| Tideline | Rising three-crest fan | Seven curling lanes and bounded fan | Breaker arc; no residue |
| Rimewake | Six-ray frost sigil | Persistent crystal/snowflake field | Freeze star; field is the residue |
| Eclipse Disc | Paired orbiting crescents | Dark/Light disc with orbit echo and bounce pips | Split crescent break; no residue |
| Pocket Eclipse | Converging Light/Dark focus rails | Paired cover-bounded beam | Revealed endpoint diamond; no residue |

Cooldown and Flux remain honest in the compact authoritative HUD; failed casts
retain their text reason and gain a closed-sigil cue without faking an action.
Target impacts render above the practice effigy, while fields remain below actors
and all alpha/effect budgets preserve collision and silhouette reads.

Default-75% 720p evidence for all five spells is under
`.godot/v4-acceptance-720-*`. These captures are ignored test artifacts, not
runtime assets. V4 is engineering-complete, while integrated
charm/accessibility scoring remains mandatory at V6. The V5 sandbox capture
harness now supplies truthful 1080p evidence without rewriting the live project.

## V5 compact HUD and Wellspring interaction language

`content/visual/compact_hud_v1.json` now owns the bounded combat-HUD geometry.
The live frame keeps only champion/location, session state, Health, Flux,
Stamina, the active Plain/Ctrl/Alt layer and exactly four active spell cells.
Detailed controls, mechanics and configuration remain at the existing
translucent Wellspring stations instead of permanently consuming navigation
space. The HUD remains under the shared 19% screen-coverage budget and does
not introduce a fifth spell button.

`content/visual/wellspring_interaction_language_v1.json` owns the presentation
profiles for the exact ten live station kinds plus bounded compact, expanded,
social and notice layouts. `WellspringInteractionPresenter` validates that
coverage against the authored campus and fails closed on missing or duplicate
styles. It draws only screen-space information: a localized current-key
capsule, source tether, station crest, named social bubble and top-center
notice. Commands, activation radii, simulation state and network authority stay
in their existing owners.

The HUD uses stepped old-world frames, miniature champion portraits,
element-shape glyphs and resource tick marks so shape and position carry state
alongside color. Its logical 1280×720 design space scales to 1920×1080 while
camera zoom remains a world-view choice; station prompts and social bubbles
therefore keep the same readable screen relationship at 50/75/100% zoom.

Run `scripts/capture-visual.ps1` on Windows for truthful 1280×720 or 1920×1080
evidence. The wrapper makes a unique system-temporary sandbox, imports there,
changes only that copy's viewport, checks every frame's count and dimensions,
and cleans only the verified sandbox. Reviewed V5 evidence is under ignored
`.godot/visual-captures/v5-acceptance-*-final` directories.

## V6 integrated accessibility and Farflow acceptance

`content/visual/accessibility_profiles_v1.json` owns the exact visual profiles,
their labels, provenance and one-pass budget. `VisualAccessibilityFilter`
validates that contract and the shader before use. Standard play hides the
overlay entirely; high contrast is player-facing, while grayscale,
protanopia, deuteranopia and tritanopia are review simulations for detecting
hue-only information. They are not medical correction profiles.

The Controls Lectern exposes reduced effects with M/controller L3 and high
contrast with H/controller R3 while open. Reduced effects damp champion,
environment, spell, field, projectile, cue and reconciliation presentation but
retain authoritative duration, radius, lane, target, cooldown and resource
truth. High contrast uses the same bounded one-pass filter and never changes
visibility or simulation.

Capture-only flags are exact: `--capture-visual-profile=grayscale|protanopia|
deuteranopia|tritanopia|high_contrast` and `--capture-reduced-effects`. Normal
CLI movement, POV, angle, range and camera overrides are also transient: capture
or diagnostic exit never persists them over the player's saved profile.

Reviewed evidence lives under ignored `.godot/visual-captures/v6-acceptance-*`:
standard and grayscale at 1280×720; common color-vision simulations; high
contrast; reduced-effects Rimewake; geometry/POV alignment; and a 1920×1080
visual-host Farflow pair with two real processes, two visible champions, host
`2/8` state and a network-verified guest greeting. The integrated engineering
scores are cohesion 4.5, silhouette 4.5, material identity 4.5, world overview
5.0, HUD clarity 5.0, animation response 4.0 and spell readability 4.5 (mean
4.57). That clears V6 while identifying animation response as the first
continuing visual-polish target.

`content/visual/wellspring_wayfinding_v1.json` makes the 2560×1440 campus read
as a group of destinations: Movement Conservatory, Recovery Grove, Living
Archive, Wellspring Looms, Settings House, Farflow Gates, Dueling Court and
Elemental Crucible. `WellspringWayfinding` validates each point against its
authored district, shows at most four nearby labels and only draws
presentation-only brass/element markers. The renderer also gives each large
quarter a quiet identity motif—garden terraces, Nexus plaza rings or proving
targets—without changing collision, routes, elevation, visibility or authority.
