# FLUX 2 continuous implementation directive

Use this prompt as the standing handoff for every implementation agent. Read it
with `README.md`, `SPECIFICATION.md`, `.agent/VISUAL-OVERHAUL.md`,
`.agent/OVERHAUL-IMPLEMENTATION.md`, `.agent/OVERHAUL-PROMPT.md`,
`docs/VISUAL-DIRECTION.md`, `docs/OVERHAUL-PLAN.md`, `.agent/memory.md`,
`.agent/BACKLOG.md` and the newest entries in `.agent/WORKLOG.md`; when they
disagree, preserve tested runtime truth and update stale prose in the same slice.

## Immediate hard gate

The visual overhaul is Gate 0 and freezes every new mechanic. Do not select
movement tuning, action chaining, spell economy/catalog, roster, material,
networking or cleanup work until V0–V6 in `.agent/VISUAL-OVERHAUL.md` pass in the
live game. Concepts, manifests and detached mockups are not acceptance. V0–V6
now pass; preserve protocol 27 and all accepted gameplay while replacing any remaining schematic runtime with
an original charming Wellspring, two readable champions, current spell effects
and compact four-cell/layered GUI. After visual acceptance, execute the strict
movement → chaining → economy → global element-catalog order in
`.agent/OVERHAUL-IMPLEMENTATION.md`.

## Mission

Continuously turn the newest unified FLUX 2 checkpoint into a charming,
responsive, self-hostable top-down elemental action game. Always leave one
published commit runnable on Windows and Linux. Work in complete player-visible
slices, checkpoint each green result, and immediately start the next accepted
slice. Do not stop at plans, scaffolds, catalogs, generated images or passing
unit tests when the player-facing outcome is still absent.

The current green frontier is protocol 27 / snapshot schema 11: two foundation champions, the planned
non-ability movement grammar, full/cone POV with building cutaways, eleven
Wellspring stations including a host-authoritative 3×4 Spell Loom,
direct-IP host/join, shared interactions, Hearth readiness,
one Proving Court round, reconnect, stewardship and late-join observation pass
the maintained Windows source journeys; Pocket Eclipse is a cover-stopped Light
beam, Tideline a cover-aware multi-target Water spray and Rimewake a persistent
single-trigger Ice field. All seven runtime-proven spells are globally weaveable
for either champion with identity-owned replicated cooldowns and five honest
empty positions. A persisted 50/75/100% world zoom defaults to the wider
75% view. Preserve all of it. Export templates and
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
| 0 | Gameplay-scale visual overhaul | Complete V0–V6 in `.agent/VISUAL-OVERHAUL.md`; no new mechanics until live integrated visual acceptance. |
| 1 | Crisp readable movement | Slightly lower ordinary speed while tightening stop/reversal/control and preserving the full deterministic movement grammar. |
| 2 | Universal action chaining | Every physically legal movement/spell transition works; no hidden global recovery or animation lock. |
| 3 | Fast Flux/Stamina economy | Every offensive cast costs positive Flux, movement spends Stamina, and shorter action-specific cooldowns create rapid tradeoffs rather than idle time. |
| 4 | Global element spell library | Each of twelve elements receives four runtime-proven role-distinct spells; every champion may configure every proven spell in the Wellspring 3×4 weave. |
| 5 | One-step portable play | A friend downloads one archive, extracts it, runs one obvious launcher without admin rights, enters the Wellspring, hosts or joins through one short in-world flow, can copy/paste a join card, and every quit path flushes local state, sends a bounded reason when online and leaves no child process; identical commit/content IDs and checksum instructions cover Windows and Linux. |
| 6 | Material-ready spell effects | Spell definitions declare shape, delivery, element, impact, residue and material operation through validated data; critical routes, spawns and objectives remain valid. |
| 7 | In-world player codex and expression | Canonical translucent overview plus an eight-way character expression wheel remain readable, controller-friendly and visibility-safe. |
| 8 | Repository/product cleanup | Remove obsolete vocabulary, graphics and adapters only after their accepted replacements pass. |
| 9 | Network visibility integrity | Host-owned per-peer relevance envelopes omit all illegal information in limited-view modes. |
| 10 | Continue complete game slices | Finish champions, arenas, chemistry, bots, objectives, environments, enemies and modes one vertical slice at a time. |

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
| Spell buttons | 1, 2, 3, 4 | four configurable face/shoulder/trigger choices |
| Spell layers | Plain, Ctrl, Alt | two configurable modifier actions plus the plain layer; 12 positions total |
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
