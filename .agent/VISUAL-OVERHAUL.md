# FLUX visual overhaul gate

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
| Champions | Oh Tipi and S. Wayne use compact cartoon pixel proportions: head 40–45% of body height, short readable limbs, expressive face/pose, 44–68px gameplay height, strong ancestry silhouettes and 1–2px outlines. Every gameplay-critical animation has an explicit south/front, east, north/back, and west/profile direction contract; south faces the camera symmetrically, north is centered back, east is authored profile, and west is a deterministic mirror or reviewed profile. Realistic/lanky or sexualized bodies fail review. |
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
| V1 | Runtime presentation foundation | Prove pixel snap/filtering, layering, cutaway masks, light/effect budgets and camera transforms in the actual game at 60/120 Hz. |
| V2 | Two foundation champions | Replace schematic bodies for Oh Tipi and S. Wayne with original body-and-clothing-only production candidates, canonical `middle`/`small` assignments and all gameplay-critical action states in all four cardinal directions; front/back symmetry, authored east profile, reviewed/mirrored west, separate effects/shadows and diagnostic hitboxes are proven live. |
| V3 | Wellspring environment | Replace the central source court, readable paths, water, academy facade, training target, spell station and near scenic edges with a coherent modular kit aligned to authored collision. |
| V4 | Existing spell visuals | Give Rillshot, Tideline, Rimewake, Eclipse Disc and Pocket Eclipse distinct readable startup/action/impact/residue treatment plus honest refusal/cooldown/Flux feedback. |
| V5 | GUI and interaction language | Replace the top debug strip with the compact three-resource/four-spell HUD, active layer indicator, contextual prompt and translucent station/bubble language at 720p and 1080p. |
| V6 | Integrated visual acceptance | Capture live movement, casting, occlusion, station use and two-player Farflow frames in south/east/north/west; compare against the target rubric and fix every failed item before declaring the visual gate open. |
| V7 | Body/effect separation re-acceptance | Validate the exact current 24-entry cast/status table, original 6×4 concept board, three-body contract, body-only foundation atlases, separate bare-hand effects, grounded roll/jump evasion cue and reusable action aliases without promoting concept pixels as runtime art. |
| V8 | Spell animation skeletons | Add delivery-specific hand anticipation, release, travel/extent, impact and recovery skeletons for projectile, beam, spray and field while simulation remains authoritative. |
| V9 | Wellspring environment assets | Produce a small reusable source-court kit whose quiet lanes, cover reads, interaction anchors and material surfaces survive spell-pattern density at every zoom. |
| V10 | Pattern-density acceptance | Capture two-player projectile, beam, spray and field combinations at 50/75/100%, grayscale and reduced effects; reject any frame without readable ownership and an escape lane. |

## Four-cardinal animation contract

The first visual acceptance slice is direction-complete in the four gameplay
cardinals: `south` (camera-facing front), `east` (authored profile), `north`
(centered back), and `west` (reviewed profile or deterministic east mirror).
Each body type and every gameplay-critical state—idle, locomotion, airborne,
evasion, cast, hit/recovery, control-loss, interaction and defeat—must expose a
bounded frame region for all four directions. Diagonal rows may be authored or
derived from the nearest cardinal, but they never replace cardinal coverage.
Direction selection is presentation-only; simulation aim, collision, timing,
invulnerability and outcomes remain authoritative and continuous.

The current integrated candidate supplies grounded, jump, empty-hand cast,
hit/recovery, walk, sprint, slide and roll rows for both foundation champions
with dedicated art in all four columns. Advanced airborne moves derive from
jump and Wave Dash/Wall Skim derive from the low slide row while retaining
separate motion/accent layers. V2 remains open until the remaining live
defense/interaction/emote/defeat/control aliases and integrated two-player
evidence pass; no additional movement body row is currently missing.

Acceptance evidence must include a direction matrix capture showing both
foundation champions in all four cardinals while idle, walking, jumping,
casting, taking damage and using an evasion action at 50/75/100% zoom. The
matrix must preserve the shared feet pivot, empty-hand casting origin,
receiving-surface shadow and readable silhouettes in standard, high-contrast,
grayscale and reduced-effects modes.

## Integrated acceptance

The visual gate opens only when all of these are true in the live game:

1. Side-by-side 720p and 1080p captures at the default 75% zoom show a charming,
   cohesive Wellspring rather than schematic blocks or debug text.
2. Two champions are recognizable by silhouette at every zoom and remain
   readable while moving, jumping, casting, taking damage and standing in auras.
3. The player can distinguish Health, Flux, Stamina, active spell layer, four
   spell states, cooldown, insufficient Flux, interactions and network status
   at a glance without covering important routes.
4. Collision, aiming, spell endpoints, field radii, shadows, elevation and roof
   cutaways align in diagnostic and ordinary frames.
5. Grayscale, color-vision and reduced-effects captures preserve gameplay
   information; no effect or decoration hides an actor or threat.
6. Independent 60/120 Hz boots, deterministic tests, source Farflow smoke and a
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
