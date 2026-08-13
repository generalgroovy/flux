# FLUX 2 continuous implementation directive

Use this prompt as the standing handoff for every implementation agent. Read it
with `README.md`, `SPECIFICATION.md`, `docs/VISUAL-DIRECTION.md`,
`docs/OVERHAUL-PLAN.md`, `.agent/memory.md`, `.agent/BACKLOG.md` and the newest
entries in `.agent/WORKLOG.md`; when they disagree, preserve tested runtime truth
and update stale prose in the same slice.

## Mission

Continuously turn the newest unified FLUX 2 checkpoint into a charming,
responsive, self-hostable top-down elemental action game. Always leave one
published commit runnable on Windows and Linux. Work in complete player-visible
slices, checkpoint each green result, and immediately start the next accepted
slice. Do not stop at plans, scaffolds, catalogs, generated images or passing
unit tests when the player-facing outcome is still absent.

The current green frontier is protocol 22: two foundation champions, the planned
non-ability movement grammar, full/cone POV with building cutaways, nine
Wellspring stations, direct-IP host/join, shared interactions, Hearth readiness,
one Proving Court round, reconnect, stewardship and late-join observation pass
the maintained Windows source journeys. Preserve all of it. Export templates and
physical Garuda Sway package proof remain honest external gaps.

## Product target

FLUX starts directly in the Wellspring; there is no detached main menu. The
Wellspring is the social lobby, settings room, spell laboratory, champion loom,
movement conservatory, codex, host/join boundary and launch space. Overlays may
open from stations or a single overview action, but closing one always returns
to the living shared world.

Study only broad principles from the supplied references: compact pixel-era
silhouette economy, landmark-dense overworlds, readable character-to-building
scale and a moderately tilted top-down battlefield. Use the original FLUX
palette, geometry, architecture, characters, symbols, UI and animation. Never
copy reference pixels, maps, layouts, camera metrics, palettes, sprites, names,
icons, text, mechanics or trade dress. The gameplay-scale target is
`assets/concept/wellspring-gameplay-specimen-v3.png`; it is a visual specimen,
not runtime art, collision geometry or permission to ship generated pixels.

## Ordered outcomes

| Order | Player-visible outcome | Acceptance gate |
| ---: | --- | --- |
| 1 | One-step portable play | A friend downloads one archive, extracts it, runs one obvious launcher without admin rights, enters the Wellspring, hosts or joins through one short in-world flow, can copy/paste a join card, and every quit path flushes local state, sends a bounded reason when online and leaves no child process; identical commit/content IDs and checksum instructions cover Windows and Linux. |
| 2 | Comfortable in-game controls | A Wellspring Controls lectern exposes keyboard, mouse buttons, mouse-wheel directions and controller bindings; selecting an action captures the next input, shows conflicts and supports swap/unbind/reset/cancel. Defaults are WASD, Shift sprint, C slide, Space jump, V technique, wheel-up jump, wheel-down slide/fast-fall and 1–5 spell slots; Ctrl and Alt are unassigned and legal spell alternatives. Bindings persist, migrate, fail closed and work at 60/120 Hz. |
| 3 | Five-slot spell grammar | Stable `spell_1`…`spell_5` semantic actions and protocol lanes select/cast five loadout entries without trusting the renderer or client. The HUD shows input, element, shape, Flux, cooldown and refusal. The Wellspring Spell Loom edits legal slots and the Proving Grounds safely tests every enabled element through readable projectile, beam, spray, field or movement/defense representatives. |
| 4 | Material-ready spell effects | Spell definitions declare shape, delivery, element, impact, residue and material operation through validated data. Wood, brick, stone, metal, glass, vegetation and immutable worldbone have stable IDs, budgets, hit/reaction hooks, reset ownership and debug fixtures before live destruction/reactions are enabled. Critical routes, spawns and objectives can never become invalid. |
| 5 | In-world player codex | One toggleable, controller-navigable, translucent overview derives its tables from canonical content rather than copied README prose: current champion/stats/kit, five slots, all playable champions, ancestry, elements/effects/interactions, movement grammar, controls, session rules and network status. It never blocks urgent combat state and remains readable at 720p, reduced motion and common color-vision modes. |
| 6 | Eight-way character expression | Hold the Talk action to open a transparent radial wheel, aim with mouse/stick, release to send and cancel by returning to center. Eight stable intents—greeting, taunt, scared, joke, follow me, retreat, thanks and “why are you running?”—map to original character-specific lines, bounded cooldowns and replicated semantic IDs; bubbles are mostly transparent, short, anchored and never reveal hidden actors. |
| 7 | Gameplay-scale visual overhaul | Replace schematic terrain, tiny bodies and debug-strip HUD with an original modular pixel kit that meets the v3 specimen: moderately tilted facades over authoritative top-down floors, compact expressive champions, clean lane values, dense scenic edges, readable doors/water/cover, restrained auras, roof cutaways, translucent bubbles and compact brass/parchment HUD. Prove collision/art alignment, whole-pixel presentation, grayscale/color-vision readability, 720p/1080p clarity, reduced effects and stable frame budgets. |
| 8 | Repository/product cleanup | Remove or quarantine obsolete Hex/Flow/operator/deployment vocabulary, superseded runtime graphics, dead adapters and duplicate documents only after replacement tests pass. Keep legacy history under its explicit archive, make the root README an honest player-first table overview, and keep scripts/docs short enough that a new contributor can locate launch, input, content, authority, rendering and verification boundaries quickly. |
| 9 | Network visibility integrity | Limited-information modes use host-owned per-peer relevance envelopes that omit illegal actors, names, projectiles, effects, cues and audio. Full-view Wellspring and observer focus are explicit policies. Omission, re-entry, interpolation, bandwidth and modified-client tests precede any fog-of-war claim. |
| 10 | Continue complete game slices | Finish one champion and one arena/mode vertically, then chemistry, bots, objectives, more champions, environments, enemies and modes one at a time through the same content/simulation/presentation/network/accessibility/platform gates. |

Orders 1–8 are product priorities, not permission to scatter eight partial
systems. If an earlier slice is externally blocked (for example a physical
Garuda machine), record the exact missing evidence, complete every locally
provable part and continue with the next coherent slice without claiming the
blocked gate.

## Default control language

| Action | Keyboard/mouse default | Controller principle |
| --- | --- | --- |
| Move | WASD | left stick |
| Aim | pointer | right stick |
| Sprint | Shift | left shoulder |
| Slide / fast-fall | C or wheel down | south face |
| Jump | Space or wheel up | right shoulder |
| Context technique | V | east face |
| Spell slots | 1, 2, 3, 4, 5 | five configurable face/shoulder/trigger choices |
| Interact | F | north face |
| Talk wheel | hold T | hold D-pad up or configured action |
| Overview | Tab outside observer mode | configurable menu/view action |

Wheel directions are discrete movement-technique inputs, not continuous walking.
All defaults are replaceable in-world. Mouse/controller events must survive a
keyboard remap; no action may silently acquire two conflicting destructive uses.

## Slice method

At the start of every slice:

1. Inspect branch/remote status, dirty files, latest history, authoritative docs,
   exact launch/test/package commands and the current visual capture.
2. Name one observable player outcome and list deterministic, interaction,
   network, accessibility, visual and platform checks that actually prove it.
3. Preserve stable IDs/formats or define a versioned migration and mismatch
   refusal before editing them.

During implementation:

- keep input, simulation, content, rendering, feedback, persistence, transport
  and platform launch boundaries explicit;
- keep the host authoritative for position, resources, cooldowns, damage,
  materials, visibility, score and outcomes;
- derive overlays/docs from registries where practical so player information
  cannot drift from the game;
- keep defaults fun immediately, expose safe tuning, and make refusal/error
  states readable and recoverable;
- add no large dependency or privileged installer without a demonstrated need;
- preserve the last pushed green commit and never touch unrelated user files.

Before checkpointing:

1. Run focused tests, full headless suites, import, independent 60/120 Hz boots,
   the applicable multi-process journey and an actual visual/interactive smoke.
2. Inspect stderr, packet/MTU budgets, generated files, diff scope, stale terms,
   image provenance and cleanup behavior; a process exiting zero after a crash is
   not a pass.
3. Update README truth, focused contracts, `.agent/memory.md`, the concise
   backlog and append-only worklog with exact commands/results/limitations.
4. Commit and push one reversible green checkpoint, then immediately select the
   next unmet acceptance row.

Never claim packaged Windows/Linux, remote friends, physical controllers,
visual acceptance, hidden-state security or fun/balance without the matching
evidence. Pause only for a real permission, product-choice or external technical
blocker; otherwise keep iterating.
