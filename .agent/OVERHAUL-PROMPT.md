# Prompt: continue the FLUX overhaul

Act as FLUX's principal gameplay, systems, rendering, pixel-art integration,
UX, QA, networking and release engineer. Continue from the newest green commit
on `main`, keeping `codex/continuous-overhaul` unified as a compatibility branch. Read `README.md`, `AGENTS.md` when it applies,
`.agent/VISUAL-OVERHAUL.md`, `.agent/OVERHAUL-IMPLEMENTATION.md`,
`.agent/CONTINUOUS-IMPLEMENTATION-PROMPT.md`, `.agent/memory.md`,
`.agent/BACKLOG.md`, the newest `.agent/WORKLOG.md` entry and
`docs/VISUAL-DIRECTION.md` before editing. Runtime truth and tests outrank stale
prose; correct stale prose in the same slice.

## Hard priority

Do not implement or retune movement, chaining, cooldowns, Flux/Stamina economy,
new spells, characters, networking features or other mechanics until the live
visual overhaul passes every V0–V6 gate in `.agent/VISUAL-OVERHAUL.md`. This is
a strict product gate, not a suggestion. During it, change only original
runtime art, rendering, camera/pixel presentation, GUI, feedback, animation,
accessibility, visual tests, asset provenance and the smallest rule-neutral
adapters required to expose already-authoritative state.

Current C2 checkpoint: reviewed diagonal grounded/cast/hit/walk/sprint art,
relative gait, safe directional evasion cues, shared eight-way spell delivery,
and Wellspring collision/cutaway/receiving-shadow alignment are green. Jump,
slide and roll retain explicit nearest-cardinal body art until reviewed
diagonal sources exist. D7 integrated multi-zoom/accessibility/Farflow capture
is next. Continuous analog movement/aim, normalized digital diagonals and
simulation authority must remain unchanged. Do not skip to new mechanics or
champions.

Make the Wellspring and GUI match the charm, density, readable perspective and
material richness of the supplied gameplay reference while remaining wholly
original and more useful for play. Preserve the wider 75% default overview and
50/75/100% zoom. Build dense scenic edges around quiet readable lanes; use warm
masonry, dark timber, aged brass, deep water, gardens, banners, runes and
controlled elemental light. Replace schematic buildings, tiny/debug bodies and
the text-heavy top strip with production-quality original pixel presentation.
Use moderately tilted facades above unambiguous top-down floors, predictable
roof/canopy cutaways, expressive Oh Tipi and S. Wayne silhouettes, readable
jump shadows, restrained affinity auras, distinct spell shapes, translucent
bubbles/prompts and a compact brass/parchment HUD.

The HUD must show portrait, Health, Flux, Stamina, network state when relevant,
the active Plain/Ctrl/Alt layer and exactly four active spell cells. The system
still has twelve independently configurable positions—Plain 1–4, Ctrl+1–4 and
Alt+1–4. Do not copy the reference's fifth button. Keep detailed information in
fast translucent station/overview panels so the main frame shows routes,
landmarks, players, threats and interaction options.

Work through visual tokens/pixel pipeline, the exact `small`/`middle`/`large`
body system, eight-direction movement and animation coverage for every gameplay-critical state,
two foundation champions,
Wellspring environment, current spell visuals, GUI/interactions and integrated
acceptance in that exact order. Do not accept a concept image, manifest,
placeholder or isolated specimen as completion: the improvement must run in the
actual game. Champion atlases contain only body and clothing: south/front faces
the camera symmetrically, north is centered back, sides are profiles and all
four diagonals preserve ancestry/clothing identity. Every gameplay-critical
animation and non-spell movement family must select a valid frame in all eight
directions before the visual gate
can advance; compose empty-hand casting, aura, shadow, projectile, equipment
and environment in separate reusable layers. Capture and inspect
720p/1080p frames at relevant zooms, ordinary
and reduced effects, grayscale and common color-vision simulations, with
collision/cutaway diagnostics. Require at least 4/5 in every visual rubric
category and a 4.5/5 mean. Preserve fixed-tick authority and the last pushed
green rollback point throughout.

## After visual acceptance

V0–V6 are accepted. The slower/crisper ordinary profile, explicit transition
matrix and positive-Flux cadence foundation are also engineering-complete.
Continue in the authoritative order from
`.agent/CONTINUOUS-IMPLEMENTATION-PROMPT.md`: finish gameplay and non-ability
movement first; then natural reusable animation and movement-rich environment;
then promote live bounded element chemistry; only then expand one complete
element's spell catalog at a time with declared chemistry behavior. Do not use
the already-complete earlier gates as permission to jump directly to catalog
work.

## Operating discipline

At each slice, inspect branch/status/history and current captures; name one
observable outcome and its deterministic, visual, accessibility, network and
platform checks; implement it without touching unrelated user files; run focused
and full tests, imports, independent 60/120 boots, applicable Farflow journeys
and live frame/interactive review; inspect stderr, diff, MTU/performance and
asset provenance; update the canonical docs and handoff state; commit and push
one reversible green checkpoint. Always keep the Windows source/package
launchable; preserve existing Linux source scripts but make no new Linux
release or acceptance claim in the current scope.
the published commit playable. Never copy protected assets or claim tests,
visual quality, balance, platform parity or remote play without direct evidence.

## Immediate eight-direction movement/animation iteration

Begin with the smallest safe visual slice: add one validated resolver for
`south`, `south_east`, `east`, `north_east`, `north`, `north_west`, `west`, and
`south_west`, then expand one complete action family at a time on both
foundation champions and all three body contracts. Travel direction and facing
direction remain distinct: free locomotion can face travel; aiming/casting uses
aim-facing forward/back/strafe gait. Keyboard diagonals stay normalized and
controller/mouse vectors stay continuous.
Keep body/clothing pixels, hand-cast effects, shadows, auras, projectiles and
environment in independent layers; do not change simulation authority, input,
collision, timing, resource costs, cooldowns or network rules. Use data-driven
direction mappings, boundary/hysteresis tests, fail-closed schema checks, stable feet pivots, nearest
sampling and deterministic 60/120 Hz frame selection. Add focused tests before
editing art, run the full Windows gate and source/imported boots, inspect
eight-direction movement/facing matrix captures at 50/75/100% plus reduced/high-contrast/grayscale
modes, update `README.md`, `.agent/BACKLOG.md`, `.agent/memory.md` and
`.agent/WORKLOG.md`, then commit and push one reversible green checkpoint.
Immediately start the next visual substep after the checkpoint; pause only for
a real blocker or when the integrated V0–V6 rubric is honestly evidenced.
