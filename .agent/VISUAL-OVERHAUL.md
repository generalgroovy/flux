# FLUX visual overhaul gate

Latest override (2026-09-05): the user authorizes the G0-G5 order in
`docs/CORE-GAMEPLAY-AND-CHEMISTRY-REVISION.md`, including higher jumps,
control corrections, elemental deposits and first-level pair effects.
Visual proof remains required for every slice; the older mechanical freeze
does not block these explicitly requested changes.

Current override: five playable basics include Grace Riva and Wa Bidi. Follow
`docs/CAST-MOTION-ACCEPTANCE.md` for travel-facing bodies, alternating contacts
and object grounding. The ordinary cranium target is now 20–23% (excluding
hair/fins/crowns), with unchanged 58/68/76 envelopes. This supersedes the older
24–30% figure below. New art is a review candidate, not inherited acceptance.

Newest user override: continue the improved illustrated direction through U1-U5
in `docs/CLARITY-AND-CONTROL-ITERATION.md`. The named menu/jump changes are
authorized despite the older blanket freeze. No mixed-element attacks before
complete chemistry testing. Red Baron proportions define all three body sizes.

Latest user override: reopen visual acceptance for the concept-matched map,
camera angle and all three body/action/direction templates. Follow
`docs/VISUAL-REFINEMENT-ACCEPTANCE.md`; the older score below is historical
baseline evidence, not approval of this replacement. Chemistry is deferred.

2026-09-04 user override: map first, then the authorized M0-M2 movement revision.
Both are now implemented source candidates; vault and crest-superglide runtime
activation is retired. Historical captures/enum adapters are not requirements
to reintroduce them. The prior artwork passed its visual gate; preserve its clarity
bar while validating the new map and movement. Follow the
[current/target movement revision](../docs/PLAYER-CONTROLS-AND-POV.md#movement-revision-no-vaulting-2026-09-04)
for slide protection, wallrun and movement-space acceptance, and the
[current acceptance ledger](../docs/WELLSPRING-MOVEMENT-ACCEPTANCE.md) for evidence
and remaining human visual/feel acceptance. The original gate below is retained
as historical baseline; the newest override freezes new mechanical work while
this authorized visual replacement is verified.

This is the mandatory first gate for all new FLUX work. Until the integrated
acceptance section below passes, do not change movement tuning, action chaining,
spell economy, spell availability, combat balance, networking rules, or roster
scope. Rendering adapters may expose existing authoritative state but may not
change it.

## Target

Rebuild the live Wellspring and combat HUD into an original, charming,
gameplay-first pixel presentation guided by
`assets/concept/wellspring-gameplay-specimen-v3.png` and the newest user-passed
1672x941 Wellspring reference (SHA-256
`a24b0721490db55338502ee4f356cf5c00993f9d6bfd936c737f14d6484ad681`).
The repository specimen is a composition target, not shippable art. Never copy
reference pixels, map geometry, UI trade dress, icons, typography, characters,
symbols, palettes, or animation.

The desired read is a moderately tilted old-world academy built from warm
masonry, dark timber, aged brass, deep water, gardens, banners, runes, compact
machinery and controlled elemental light. It must show more useful world than
the current schematic runtime while keeping champions, hazards, cover,
projectiles, spell residues and interaction prompts instantly legible.

## Non-negotiable presentation rules

| Area | Required live result |
| --- | --- |
| Camera | Preserve 50/75/100% options and default to the wider 75% overview; world-to-screen transforms, pointer aim, cutaways and collision overlays remain aligned. |
| Pixel policy | One documented world-pixel scale, nearest-neighbor sampling, stable pivots and deliberate whole-pixel presentation without changing fixed-point authority. |
| Play space | Dense detail belongs at scenic edges; navigable floors use quiet values, crisp silhouettes and obvious elevation/collision boundaries. |
| Perspective | Gameplay floors remain square and screen-cardinal; tilted facades may rise no more than 0.85x their readable footprint, wall feet/door thresholds stay visible, and any occluding roof/canopy/wall cuts away predictably. Diamond-grid/isometric navigation is forbidden. |
| Champions | S. Wayne, Oh Tipi and The Red Baron use mature compact cartoon pixel proportions: ordinary cranium/skull 24–30% of body height (excluding hair, fins, horns and ancestry crowns), clear torsos/limbs, a bounded 58/68/76px small-to-large progression, strong ancestry silhouettes and 1–2px outlines. Every gameplay-critical animation has an explicit `S/SE/E/NE/N/NW/W/SW` contract; south faces the camera symmetrically, north is centered back, side views are clear profiles, and diagonal views preserve ancestry asymmetry. Realistic/lanky, baby/chibi or sexualized bodies fail review. |
| Movement direction | Keyboard combinations must produce all eight compass directions with normalized speed; controller and mouse-derived vectors remain continuous. Presentation bins travel and facing independently into eight stable sectors with bounded hysteresis, so diagonal movement is readable without snapping simulation or aim. |
| Body types | Exactly three canonical IDs exist: `small`, `middle`, `large`. `tiny→small`, `medium→middle`, and `huge→large` are migration mappings only; no content, manifest, selector or future generator may expose a fourth runtime type. |
| Layer separation | Champion sprite pixels contain body and clothing only. Shadow/elevation, aura, spell, projectile, residue, environment, tool, equipment and focus visuals are independent reusable layers with their own pivots, provenance and budgets. |
| Casting | Every champion channels magic visibly from empty hands through separate action/effect layers. Staffs, wands, scepters, rods, held magical foci and floating companion foci are forbidden. |
| Spells | Every currently playable projectile, beam, spray and field gets its own silhouette, cadence, travel/extent, impact and residue language; effects never erase actors or collision edges. Dense patterns preserve quiet actor rings and at least one legible escape lane. |
| Bullet readability | Projectiles are gameplay state, never decoration: ownership, shape, speed tier, collision size, active timing and residue must parse without color, and the live effects budget prevents overlapping particles from disguising a lane. |
| HUD | Compact brass/timber/parchment framing, portrait plus readable Health/Flux/Stamina, active Plain/Ctrl/Alt layer and exactly four active spell cells; never display a fifth spell button. |
| Prompts | Short translucent parchment bubbles and contextual interaction prompts anchor near their source, avoid combat state and disappear promptly. |
| Overview | The default frame shows routes, landmarks and nearby interaction choices without a debug-strip wall of text; detailed information stays in fast translucent overlays/stations. |
| Accessibility | Critical distinctions survive grayscale and common color-vision simulation; reduced-effects mode preserves authoritative timing, shape and impact information. |

## Strict visual slice order

| Gate | Deliverable | Evidence required before moving on |
| ---: | --- | --- |
| V0 | Baseline and token specimen | Capture current 720p/1080p frames at 50/75/100%; freeze palette ramps, spacing, typography, outline, shadow, aura, effect and panel tokens in one runtime specimen scene. |
| V1 | Runtime presentation foundation | Prove pixel snap/filtering, layering, cutaway masks, light/effect budgets and camera transforms in the actual game at 120 Hz. |
| V2 | Two foundation champions | Replace schematic bodies for Oh Tipi and S. Wayne with original body-and-clothing-only production candidates, canonical `middle`/`small` assignments and all gameplay-critical action states in all eight compass directions; front/back symmetry, readable sides/diagonals, separate effects/shadows and diagnostic hitboxes are proven live. |
| V3 | Wellspring environment | Replace the central source court, readable paths, water, academy facade, training target, spell station and near scenic edges with a coherent modular kit aligned to authored collision. |
| V4 | Existing spell visuals | Give Rillshot, Tideline, Rimewake, Eclipse Disc and Pocket Eclipse distinct readable startup/action/impact/residue treatment plus honest refusal/cooldown/Flux feedback. |
| V5 | GUI and interaction language | Replace the top debug strip with the compact three-resource/four-spell HUD, active layer indicator, contextual prompt and translucent station/bubble language at 720p and 1080p. |
| V6 | Integrated visual acceptance | Capture live movement, casting, occlusion, station use and two-player Farflow frames in `S/SE/E/NE/N/NW/W/SW`; compare against the target rubric and fix every failed item before declaring the visual gate open. |
| V7 | Body/effect separation re-acceptance | Validate the exact current 24-entry cast/status table, original 6×4 concept board, three-body contract, body-only foundation atlases, separate bare-hand effects, grounded roll/jump evasion cue and reusable action aliases without promoting concept pixels as runtime art. |
| V8 | Spell animation skeletons | Add delivery-specific hand anticipation, release, travel/extent, impact and recovery skeletons for projectile, beam, spray and field while simulation remains authoritative. |
| V9 | Wellspring environment assets | Produce a small reusable source-court kit whose quiet lanes, cover reads, interaction anchors and material surfaces survive spell-pattern density at every zoom. |
| V10 | Pattern-density acceptance | Capture two-player projectile, beam, spray and field combinations at 50/75/100%, grayscale and reduced effects; reject any frame without readable ownership and an escape lane. |

## Eight-direction movement and animation contract

Final acceptance is direction-complete in this fixed clockwise order:
`south`, `south_east`, `east`, `north_east`, `north`, `north_west`, `west`,
`south_west`. Each body type and every gameplay-critical state—idle,
locomotion, airborne, evasion, cast, hit/recovery, control-loss, interaction and
defeat—must expose a bounded frame region for every direction. Side and diagonal
mirrors are allowed only when ancestry/clothing asymmetry is corrected and the
result is reviewed.

Movement and aim are distinct inputs to presentation. Keyboard movement supports
all eight normalized combinations; analog travel and spell aim stay continuous.
The shared eight-sector resolver selects art without snapping simulation.
Moving bodies always face physical travel, including during casting; separate
bare-hand effects communicate spell aim. Stationary casting faces aim. Walk and
sprint keep alternating contacts while casting; air/low poses remain air/low.
This changes no fixed-point position, speed, collision, timing, invulnerability,
network value or outcome. Artwork must independently pass direction review.

The current integrated candidate supplies authored eight-way grounded,
empty-hand cast, hit/recovery, jump, slide and roll art for both foundation
champions. Walk and sprint each alternate two opposite planted-leg contacts in
all eight directions on an editable, rate-independent presentation cadence; the
independent eight-way invulnerability cue remains a reinforcing layer. Advanced airborne moves derive from jump and Wave
Dash/Wall Skim derive from the low slide row through a versioned semantic-alias
manifest while retaining separate motion/accent layers. Movement, control,
cast/recovery and defeat are live; attack, defense, interaction and taunt
aliases remain reserved without fabricating simulation timers. V2 remains open
until every remaining body family and integrated two-player evidence pass.

Spell delivery uses one validated fail-closed direction contract. Body
cast/recovery, hand gather/release, projectile orientation and trail art select
the nearest stable `S/SE/E/NE/N/NW/W/SW` sector, while continuous simulation
aim, hand offset and beam/spray geometry remain unquantized. Zero input falls
back explicitly to south. D5 is green only because startup and release were
captured diagonally for both foundation champions without changing collision,
timing, cost, authority or outcome.

Wellspring surface alignment is likewise presentation-only and fail-closed.
Exact collision-corner marks, exterior thresholds and configured cutaway
margins reveal a warm cardinal floor plan on approach; local and remote actor
shadows sample water/garden/Nexus/proving material plus authored elevation.
Diagnostic diagonal captures prove architecture, low cover, contact shadow and
simulation footprint agree. D6 is green without granting art authority over
collision, topology, movement, visibility or spell endpoints.

D7 now has a reproducible non-overwriting evidence runner. Its accepted
three-champion extension has 27 cells covering all playable body roles, all eight direction/action
assignments, every zoom and accessibility review profile, 720p/1080p overviews
and a real mixed-champion Farflow pair. The first exact-commit review scored
cohesion 4.5, silhouette 4.5, material identity 4.5, world overview 5, HUD clarity 5,
animation response 4.5 and spell readability 4.5: 4.64/5. Every category and
the required mean pass. V10 also passed 1,080 sampled two-player frames across
50/75/100%, grayscale, reduced effects, projectile, beam, spray and field
pressure without losing actor ownership or the last escape lane. The visual
freeze is open; every added champion or spell must pass the same local gates.
The current extension is `.godot/visual-captures/d7-three-v1-contact-sheet.png`;
its real Farflow pair, both overview resolutions and every Red Baron action cell
completed without capture/import errors.

Acceptance evidence must include a direction matrix capture showing every
playable champion in all eight compass directions while idle, walking,
sprinting, reversing/strafe-moving, jumping, casting, taking damage and using
an evasion action at 50/75/100% zoom. The
matrix must preserve the shared feet pivot, empty-hand casting origin,
receiving-surface shadow and readable silhouettes in standard, high-contrast,
grayscale and reduced-effects modes.

## Integrated acceptance

The visual gate opens only when all of these are true in the live game:

1. Side-by-side 720p and 1080p captures at the default 75% zoom show a charming,
   cohesive Wellspring rather than schematic blocks or debug text.
2. Every playable champion is recognizable by silhouette at every zoom and remains
   readable while moving, jumping, casting, taking damage and standing in auras.
3. The player can distinguish Health, Flux, Stamina, active spell layer, four
   spell states, cooldown, insufficient Flux, interactions and network status
   at a glance without covering important routes.
4. Collision, aiming, spell endpoints, field radii, shadows, elevation and roof
   cutaways align in diagnostic and ordinary frames.
5. Grayscale, color-vision and reduced-effects captures preserve gameplay
   information; no effect or decoration hides an actor or threat.
6. Independent 120 Hz boots, deterministic tests, source Farflow smoke and a
   real interactive capture pass on the same commit.
7. Every runtime asset has provenance, license/originality notes, declared
   dimensions/pivots/import rules and a bounded memory/performance budget.
8. Projectiles remain readable as discrete owned hazards under dense two-player
   patterns; actor silhouettes and at least one safe response lane remain clear.

Subjective charm requires review, but it is not an excuse for an unbounded gate:
record one rubric score from 1–5 for cohesion, silhouette, material identity,
world overview, HUD clarity, animation response and spell readability. Every
category must reach at least 4 and the mean at least 4.5 before mechanical work
resumes.
