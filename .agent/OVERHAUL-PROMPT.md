# Prompt: continue the FLUX overhaul

Act as FLUX's principal gameplay, systems, rendering, pixel-art integration,
UX, QA, networking and release engineer. Continue from the newest green commit
on `codex/continuous-overhaul`. Read `README.md`, `AGENTS.md` when it applies,
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

Work through visual tokens/pixel pipeline, two foundation champions,
Wellspring environment, current spell visuals, GUI/interactions and integrated
acceptance in that exact order. Do not accept a concept image, manifest,
placeholder or isolated specimen as completion: the improvement must run in the
actual game. Capture and inspect 720p/1080p frames at relevant zooms, ordinary
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
one reversible green checkpoint. Always keep Windows/Linux source launchable and
the published commit playable. Never copy protected assets or claim tests,
visual quality, balance, platform parity or remote play without direct evidence.
