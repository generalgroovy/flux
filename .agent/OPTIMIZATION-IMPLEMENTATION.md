# FLUX 2 delivery and architecture optimization plan

This plan turns the current playable foundation into a faster, safer path to
the first-eight chemistry playtest. It is subordinate to the player-facing
order in `OVERHAUL-IMPLEMENTATION.md`: optimizations may remove friction or
create the exact seam required by the active slice, but may not become a
detached rewrite.

The concrete feedback ladder, decision record, scenario workflow, generated
receipt, task front door and branch discipline live in
`DELIVERY-EFFICIENCY.md`. That document optimizes how these slices execute; it
does not add product scope.

The product-quality boundary lives in
`../docs/PLAYER-EXPERIENCE-OVERHAUL.md`. Optimization is valuable only when it
shortens the path to a clearer decision, faster safe retry, more expressive
composition or more trustworthy plug-and-play journey without weakening proof.

## Product focus freeze

Until the C9 Elemental Crucible playtest passes, FLUX keeps exactly three
playable champions, the current universal movement grammar, eight first-phase
elements, the existing Wellspring footprint, twelve equipped spell positions,
and a 2/4/8-player Farflow ceiling. Work improves tuning, readability,
chemistry, delivery, and proof inside that foundation. It does not add another
champion, movement technique, map expansion, deferred element, mode, or
32-player claim.

Regression fixes, measurement and presentation clarity apply immediately.
Deliberate movement rebalance and broad visual retuning wait for the C9
playtest evidence so they do not disguise chemistry defects or invalidate the
first-eight control group.

The eight comparable Bursts are the experimental control group: geometry,
damage budget, economy, timing, and capacity remain identical while element
identity changes presentation and the chemistry payload. This makes later
reaction differences observable instead of disguising them as projectile
balance changes.

## Explicit optimization slices

| ID | Design decision | Implementation boundary | Acceptance |
|---:|---|---|---|
| O0 | Every accepted gameplay slice has one clean, recoverable truth. | Finish the eight-Burst visual review; update README, backlog, memory and worklog; commit and push `main`; make the local and remote compatibility branch point to the same commit without touching unrelated user files. | Full deterministic suite, clean import, independent 120 Hz boot, truthful in-game Burst evidence, documentation parity, and one green published commit. |
| O1 | A warning is actionable signal, not normal background noise. | Replace export-unsafe direct PNG loads in validators with one reusable import-safe image inspection helper; split checks into named fast, full and release tiers; record duration and stderr size; reject unexpected warnings. | Normal source validation emits zero known image-load warnings, logs remain compact, all prior assertions still pass, and each tier reports its elapsed time and exact scope. |
| O2 | Authored spell content is the only balance truth. | Validate integer content once and compile it into an immutable `CombatDefinitionTable` used by simulation, compatibility hashing and UI; retain stable wire IDs and fail closed on missing or non-integral fields. Remove mirrored runtime constants only after parity fixtures prove identical commands, snapshots and replays. | Editing one authored value changes the compiled definition and compatibility hash; catalog/runtime drift is impossible; existing 120 Hz combat fixtures remain byte-for-byte stable before intentional tuning. |
| O3 | `bootstrap.gd` composes the game; it does not own every subsystem. | Apply a strangler refactor only along touched seams: extract a runtime-content context, capture/CLI diagnostics, Wellspring interaction coordination, Farflow orchestration, combat presentation and safe-quit handling into bounded collaborators with explicit inputs. Split packet validation/codec work from ENet lifecycle only when networking is already touched. Do not rewrite movement, combat, networking or rendering together. | The root node owns lifecycle/composition only, extracted units have focused tests, no state authority moves to presentation, and source/Farflow/capture behavior is unchanged. |
| O4 | One-file Windows delivery is complete only when Windows can trust and run it. | Add an optional certificate-supplied signing stage after deterministic packaging, verify Authenticode and embedded payload hashes, and preserve unsigned development output as an explicitly labelled local artifact. Never generate or embed a private release key. | A certificate-bearing build fails if signing or verification fails; an eligible physical Windows machine completes install/update/repair/start/safe-quit; unsigned policy blocking remains an explicit external gate until that evidence exists. |
| O5 | Runtime packages contain reachable production assets, while source and provenance stay in Git. | Generate a dependency report from scenes, registries, hashes and live catalogs; classify each file as runtime, test/capture, source/provenance, historical reference or unreachable. Replace `all_resources` export with an allowlisted runtime manifest or equivalent verified exclusions. Migrate live visual catalogs before archiving their predecessors; delete only assets proven unreachable by registry and history evidence. | Source and packaged captures match, all runtime hashes resolve, no path is missing, every exported asset is classified, and package-size reduction is measured rather than guessed. |
| O6 | Current truth is short and generated; history remains available without dominating handoff context. | Generate a current-state manifest containing protocol/schema, tick rate, platform scope, content hashes, three-body contract, canonical roster, runtime-spell/reaction counts, test totals and package identity. Make README consume or verify that truth; mark the old root specification and mixed-platform development notes historical until replaced; migrate stale names and five-size vocabulary out of live visual catalogs through versioned adapters. Archive rather than silently rewrite evidence. | README, current plans, runtime diagnostics and handoff tables agree; protocol 32, Windows-only acceptance and 120 Hz cannot drift; stale counts/names/body types fail a docs/content check; history remains discoverable under an archive index. |
| O7 | Windows development must not create accidental cross-platform diffs. | Add `.gitattributes` rules for LF text, CRLF Windows entrypoints where required, and binary image/archive types; normalize only files already modified by an accepted slice rather than rewriting the repository at once. | `git diff --check` is clean, repeated Windows edits do not report LF/CRLF churn, and launch scripts retain their required encoding. |
| O8 | Automated correctness and actual play quality are separate evidence. | Add short repeatable solo, movement, pressure, chemistry, friend, accessibility and recovery journeys plus an opt-in local playtest report for time-to-first-action/cast, input response, stopping/reversal, chains, refusals, hits, reaction creation/reset, route use and observed confusion. Store aggregate timings/outcomes, never personal input history. | Every acceptance build has deterministic tests plus the applicable named human journey; feel, usability, balance, clarity and fun claims cite observed results instead of assertion counts. |
| O9 | Chemistry is bounded world state, not thirty-six custom physics scripts. | Compile the 36 symmetric recipes onto a small integer-channel model (structure, heat, saturation, pressure/momentum, charge, radiance/vitality and decay) and shared spatial primitives. Active cells, propagation, work, events, ownership, snapshots and residues all have hard capacities. | Every pair forms through the same contact path, maps only to validated primitives, exposes a spatial counter, decays/resets deterministically, respects worldbone and survives replay/Farflow tests at 120 Hz. |
| O10 | Performance acceptance represents the intended game, not an empty room. | Add reproducible two- and eight-actor stress journeys with maximum legal projectile, field, exposure and reaction pressure; report simulation, CPU render, GPU, event, entity, snapshot and packet budgets separately; pool bounded transient presentation objects only where measurements justify it. | The declared Windows target sustains 120 Hz inside 8.33 ms with measured headroom, no unbounded queues/allocations or packet fragmentation, and reduced-effects changes presentation cost only. |
| O11 | Existing movement forms one crisp, learnable action language before it grows. | After C9 feedback, centralize the legal action/cancel/buffer/refusal graph; tune acceleration, braking, reversal, landing and airborne steering only at 120 Hz; preserve normalized eight-way keyboard movement, continuous analog aim, deterministic authority and universal techniques. Give small/middle/large profiles meaningful acceleration/recovery/stability differences without hidden reach or collision advantage. Add no new technique until every existing one has a distinct purpose and readable transition. | Legal inputs begin within one simulation tick unless an authored commitment blocks them; every blocked action gives one reason; direction journeys are equivalent; movement outcomes are replay/Farflow stable; named playtests confirm deliberate rather than slippery control. |
| O12 | Visual cohesion is a maintained production system, not a one-time screenshot gate. | Version one shared grammar for warm-world materials, three body envelopes, outline/value hierarchy, receiving-surface shadows, bare-hand effects, projectile size/speed classes, interface chrome and density. Apply it incrementally to touched assets; keep quiet movement lanes, strong landmarks, independent layers and capture diagnostics outside ordinary presentation. | At 50/75/100% zoom and 720p/1080p, champions read first, threats second, interactions third and scenery last; body size/pivots never drift by animation; hostile lanes survive grayscale/reduced effects; the ordinary frame reads as an inhabited Wellspring rather than a debug board. |
| O13 | Expansion composes validated kernels instead of copying systems. | Implement sections 11–15 of `docs/FOUNDATION-SYSTEMS.md`: enforce directed dependencies; compile versioned champion/spell/element/map/actor/objective/mode units; classify compatibility; separate machine identity from display text; generate admission matrices; require migrations/tombstones for schema/wire changes. Prove one fixture at a time instead of building a general plugin platform. | Representative fourth-champion, existing-kernel spell, district, command-driven bot and composed-ruleset fixtures need no identity-specific bootstrap/simulation branch; invalid, cyclic, over-budget or incompatible units fail with named errors; existing hashes/outcomes remain stable. |
| O14 | Player and developer sandboxes exercise the production game, not privileged parallel rules. | Complete Wellspring movement, Loom, Crucible, Proving Court, Farflow and Archive experiment/reset loops; add versioned scenario definitions, focused journey runner, read-only diagnostics, fault injection and packaged scenario proof that all submit ordinary semantic commands. Permit validated presentation reload offline; simulation changes require safe restart and a new compatibility hash. | Players can configure, experiment, understand and reset quickly without a detached menu; developers can reproduce a report from one scenario/seed across source, replay, Farflow and package; no tool directly mutates authoritative state. |

## Development sequence

| Order | Combined delivery slice | Why now |
|---:|---|---|
| 1 | O0 Burst checkpoint plus O7 line-ending contract | Close the already-green player feature and remove immediate diff ambiguity. |
| 2 | O1 warning-clean test tiers plus the first O6 generated state summary | Improve feedback before the larger chemistry surface begins. |
| 3 | O2 combat-definition authority | Prevent eight spell payloads and 36 recipes from multiplying duplicated tuning. |
| 4 | C5 reaction catalog plus O9 recipe compiler | Establish complete, fail-closed chemistry truth without live mutation yet. |
| 5 | C5.5 current-truth cleanup: O6 manifest/docs, O5 reachability discovery/live-catalog migration, selectable suite registry, thin task front door and receipt schema | Remove authority conflicts and shorten feedback before new saved/networked world state depends on them; archive nothing until the replacement validates. |
| 6 | C6 exposure/contact with one O3 extraction seam | Put new authority in a dedicated system instead of enlarging `bootstrap.gd`. |
| 7 | C7 shared primitives, then C8 lifecycle/presentation | Build reusable physics first and readable interpretation second. |
| 8 | O5 export pruning and O10 full-pressure benchmark | Optimize the exact feature-complete acceptance build, not a moving target. |
| 9 | O4 signed physical Windows proof, O8 human route, C9 package | Finish the honest friend-facing playtest gate. |
| 10 | C9 playtest pause, then O11 movement feel and O12 cohesion from recorded feedback | Polish the proven loop before roster, map or mechanic expansion. |
| 11 | O13 composable foundation plus O14 production-path sandboxes through F0–F7 | Prove maintainability, understandability, expansion and player/developer iteration before routine content growth. |

## Current optimization state

| Slice | State | Evidence / next boundary |
|---:|---|---|
| O0 | **Complete** | Unified/published `main` and compatibility branch; first-eight Burst simulation, truthful captures and current docs are green. |
| O1 | **Complete in source** | `ImageAssetInspector` removed all 2,649 unsafe-load warnings; Fast and Full gates reject unexpected warnings and report time/stderr. Release invokes package/install/repair/boot and retains the external signing gate. |
| O7 | **Foundation complete** | `.gitattributes` owns text/binary newline policy; normalize touched files per slice without a repository-wide churn commit. |
| O2 | **Complete** | All 16 live spells compile once from validated catalog integers; simulation, UI/runtime ordering and compatibility hashing consume the immutable table. Pre-migration definition signatures, snapshots and replays remain green, while mirrored balance constants/builders are removed. |
| O9 | **C5 compiler complete; C6 next** | The complete fail-closed 36-pair truth compiles onto bounded shared primitives with mutation disabled; C6 adds exposure/contact through the first dedicated chemistry authority. |
| O6 | **Complete in this checkpoint** | Generated state/drift checks, document statuses, canonical roster/visual adapters and derived Loom/package summaries are tested. Keep archival pixels distinct from current identity and preserve compatibility IDs. Unsigned installer trust remains independently blocked. |
| O11–O14 | **Standards active; hardening queued after C9** | Fix regressions immediately, gather evidence during C6–C9, then harden feel, cohesion, composability and production-path sandbox tooling through F0–F7 before expanding scope. |

## Loop discipline

Each slice begins from a published green rollback point. Focused tests run
before the full suite; source/import/120 Hz boots and relevant visual or Farflow
journeys run before documentation. Unexpected stderr is a failure to classify,
not something to suppress. Refactors must preserve state hashes or document a
versioned migration. No asset, identifier, document or compatibility adapter is
removed until its replacement, reachability result and migration coverage are
green. The next slice starts only after the current player-facing outcome is
playable, reviewed, documented, and recoverable.
