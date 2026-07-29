# FLUX overhaul implementation plan

Date: 2026-07-29
Branch: `integration/unify-flux`
Product source: `README.md`
Visual gate source: `.agent/VISUAL-OVERHAUL.md`

## Outcome

Replace the compatibility game with the FLUX overhaul through small, verified
vertical slices. Build new overhaul systems from clear contracts and reuse old
code only when it is the smallest proven implementation of a requirement.
Windows and Linux must remain launchable throughout the replacement.

## Source-of-truth order

1. The user's latest explicit direction.
2. `AGENTS.md` safety and delivery rules.
3. `.agent/VISUAL-OVERHAUL.md` visual freeze and gate order.
4. `README.md` product vision, roster, elements, movement, and current truth.
5. This implementation plan.
6. `.agent/PLAYABLE-STATE.md` observed implementation status.
7. Existing source code and older design notes.

When lower sources conflict with higher sources, preserve runtime compatibility
but do not let the lower source redefine the overhaul.

## Ground-up replacement rule

Existing code is reusable only when all of these are true:

| Reuse check | Required evidence |
| --- | --- |
| Product fit | Implements an accepted overhaul requirement without carrying obsolete identity or UX |
| Ownership | Keeps simulation, content, renderer, persistence, and network authority boundaries explicit |
| Determinism | Has deterministic tests and bounded work/state |
| Portability | Works through the same Windows and Linux path |
| Modularity | Can serve multiple future slices without copy-paste or character-specific branching in shared systems |
| Migration | Preserves stable IDs/formats or supplies an explicit versioned adapter |
| Clarity | Keeps player-facing state readable and accessible |

If a component fails one of these checks, implement the overhaul version in an
isolated namespace, prove it, migrate consumers, and then remove the obsolete
component. Do not perform unbounded deletion or rewrite working infrastructure
without a proven replacement.

## What is intentionally retained

- Git history, recovery tags, and the unification branch.
- Cross-platform launchers, authenticated process cleanup, packaging, and CI.
- Deterministic fixed-tick and server-authoritative principles.
- Stable entity/content identifiers where migration requires them.
- Network input sequence, snapshot, reconnect, spectator, migration, and rate
  limit contracts that remain valid for the overhaul.
- Test harnesses that assert behavior rather than legacy presentation.
- Central visual tokens, the twenty ancestry templates, and reusable rendering
  primitives that pass their neutrality tests.
- The Living Sanctum shell, ancestry-column selection, and bounded Practice
  court as verified foundations for the final diegetic replacement.

## What is temporary

- `src/content.mjs`, its ten champions, thirteen live races, and old kits.
- Compatibility element names, roster UI content, and map presentation.
- Fixed tactical/defense/mobility slot semantics.
- One-off character render branches and specimen duplication.
- The inactive sixteen-character/eight-family prototype wherever it conflicts
  with the expanded README target.
- The legacy `Hara` display label; stable ID `mara` remains a migration key for
  Haara.

Temporary code may stay callable only until its replacement passes the same
commit's selection, simulation, networking, persistence, accessibility,
Windows/Linux, package, and regression gates.

## Target module boundaries

| Boundary | Responsibility |
| --- | --- |
| `src/overhaul/` | New product modules only; no hidden import from compatibility content |
| Content | Versioned elements, reactions, ancestries, sizes, champions, abilities, maps, modes, and tuning |
| Commands | Semantic, serializable player intent independent from keyboard/controller bindings |
| Simulation | Fixed-tick movement, collision, spells, materials, objectives, AI, and outcomes |
| Network | Server validation, snapshots, reconciliation inputs, reconnect, spectators, migration, and diagnostics |
| Presentation | Visual profiles, spell/map reads, HUD/Sanctum rendering, feedback, accessibility |
| Migration | Explicit adapters between compatibility IDs/formats and accepted overhaul contracts |
| Tests | Contract, deterministic, DOM, soak, network, launch, package, and visual-regression coverage |

`src/overhaul-character-visuals.mjs` remains a compatibility barrel while V1
visual modules move beneath `src/overhaul/`. New character slices must not grow
another monolithic renderer.

## Ordered execution

### Phase A — Canonical contract

- Keep README, visual contract, prompt, plan, backlog, and playable ledger
  mutually consistent.
- Treat twenty-three named champions plus one temporary Angel slot, twenty
  ancestry templates, two-to-three affinities per named champion, and the
  expanded element target as product truth.
- Record gaps in the old inactive catalog; do not silently reinterpret them.

### V0 — Visual tokens

Status: **accepted**. Preserve the centralized value, color, material, outline,
spacing, and motion tokens plus non-shipping reference board.

### V1 — Characters

Status: **paused by P0-P5 pixel-perspective and M0-M5 movement/input order**.
When resumed, produce source-only concepts in this order so compatibility
lessons transfer before unrelated breadth:

| Slice | Champion | Ancestry | State |
| ---: | --- | --- | --- |
| 01 | Spai Si | Demon | Source specimen complete |
| 02 | Urzh | Stoneborn | Source specimen complete |
| 03 | S. Wayne | Hobbit | Source specimen complete |
| 04 | Nico Lai | Gnome | Desktop specimen and live Windows Sanctum accepted; first promoted replacement |
| 05 | Steezo | Goblin | Next V1 source slice after M5 |
| 06 | Djonah Thaan | Vampire | Pending |
| 07 | Grace Reava | Sylph | Pending |
| 08 | Biggy Bob | Dwarf | Pending |
| 09 | Ha Rekt | Wyrmborn | Pending |
| 10 | Treevor the Mason | Treefolk | Pending |
| 11–23 | Remaining named roster in README order | Mixed | Pending |
| 24 | Angel slot decision | Angel | Must be named/approved or removed |

Every V1 slice requires:

- one neutral ancestry template plus champion-specific posture and focus prop;
- two or three affinity reads that never obscure body or spell telegraphs;
- idle, move, commit, hit/low-health, defend, and defeated states;
- shape plus color team ownership;
- reduced-motion and narrow-layout behavior;
- no sexualized presentation, draft lore, hitbox, balance, or runtime changes;
- one source-only specimen, deterministic drawing/profile tests, full suite,
  and an observed render before acceptance.

V1 completion requires all slots, grayscale/contrast review, overlap review,
and user acceptance. A specimen does not promote a champion to matchmaking.

### V2 — Spells

Build a new data-driven visual grammar for anticipation, travel/area, impact,
ownership, interaction, break/interrupt, and expiry. Cover every accepted
primary, active, and ultimate family before runtime mechanics change.

### V3 — Maps

Rebuild maps around original regional materials, route hierarchy, collision,
cover, hazards, spawns, objectives, landmarks, interaction space, dense-fight
clarity, and bounded destruction reads.

### V4 — GUI and Sanctum

Finish the diegetic Sanctum, practice space, fighting-grid roster, loadout
builder, HUD, guide, settings, remote company, pause, results, and tutorial.
Keyboard, mouse, controller, reduced motion, contrast, and narrow layouts must
share semantic behavior.

### V5 — Integrated visual acceptance

Accept a complete match, First Rite, shortcuts, local two-player flow,
eight-player stress, remote company, every accepted visual family, and source
plus package runs on Windows and Linux.

### Phase B — Ground-up playable overhaul

After V5 acceptance, implement mechanics in this order:

1. Versioned overhaul content and semantic command contracts.
2. Universal movement/physics kernel and Stamina.
3. Flux economy, loadout budget, primary, three actives, and ultimate charge.
4. Materials and bounded element reactions.
5. One complete champion, one complete map, Freeplay, and First Rite.
6. Duel and authoritative remote play.
7. Two additional complete champions and two additional maps.
8. Control, then PvPvE, then PvE.
9. Destruction and multi-level spaces.
10. Only after eight-player acceptance, staged work toward 32-player lobbies.

The compatibility runtime now proves the complete universal movement grammar
and collision-safe marked vault routes by direct user exception. Phase B still
migrates that proven contract into the ground-up overhaul boundary rather than
duplicating or redesigning it.

Each accepted production slice migrates one consumer from compatibility code.
Delete the superseded path only after references, saves, tests, launchers, and
package manifests prove it unused.

## Promotion gates

| Level | Required evidence |
| --- | --- |
| Concept | Canonical data, visual states, explicit counterplay/read, source-only review |
| Local prototype | Deterministic mechanics, bots/harness, renderer/input, accessibility |
| Remote preview | Server authority, snapshots, reconciliation, reconnect, spectators, migration |
| Candidate | Normal selection behind a versioned migration, save/update handling, full suite |
| Production | Windows/Linux source and package smoke, hands-on acceptance, rollback path |

Haara's existing headless `mara` prototype remains frozen at local-prototype
evidence. It does not bypass V1–V5 and must be relabeled/migrated before later
promotion.

## Completed slice

S. Wayne is implemented as a source-only Hobbit visual:

- stable visual/migration ID `samwise`;
- low, bare-footed Hobbit anatomy;
- split mantle and eclipse waystone for a boundary tactician;
- Dark and Light auras separated by shape and value;
- six authored states, team redundancy, health wear, reduced motion;
- shared specimen runner rather than a third copied harness;
- no gameplay, lore, roster, network, or balance changes.

The six-state board rendered without console errors and its inherited
app-stylesheet overflow conflict was corrected inside the specimen boundary.
Focused tests, the 132-check full suite, syntax checks, and diff hygiene pass.
PR #10's Windows/Linux Node 20/22 verification and both package jobs passed for
implementation commit `e472bd7`. The next implementation slice is Nico Lai.

Nico Lai's implementation is now promoted:

- required visual ID `nico`, with inactive content ID `nix` recorded only as a
  compatibility field;
- compact Gnome ancestry composition with a high cap and measured tool frame;
- calibrated coil pack plus a detached, breakable device and explicit team
  tether;
- Charge forks separated from Light calibration diamonds by shape and value;
- idle, move, commit, hit/low-health, defend, and defeated reads;
- shared specimen runner plus shared live renderer integration through the
  stable `volt` runtime ID, with no hitbox or packet identifier migration;
- focused profile, transfer, all-state draw, responsive specimen, and route
  tests passing.

Desktop specimen review and a real Windows Living Sanctum run both passed with
no console errors after fixing the local authority's missing overhaul module
routes. Nico now starts in Sanctum with visible Health, recovery, Flux,
focus, speed, and Endurance statistics. P0 pixel-perspective foundation is now
active; Steezo resumes after P0-P5 and M0-M5 acceptance.
