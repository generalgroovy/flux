# FLUX 2 delivery and architecture optimization plan

This plan turns the current playable foundation into a faster, safer path to
the first-eight chemistry playtest. It is subordinate to the player-facing
order in `OVERHAUL-IMPLEMENTATION.md`: optimizations may remove friction or
create the exact seam required by the active slice, but may not become a
detached rewrite.

## Product focus freeze

Until the C9 Elemental Crucible playtest passes, FLUX keeps exactly three
playable champions, the current universal movement grammar, eight first-phase
elements, the existing Wellspring footprint, twelve equipped spell positions,
and a 2/4/8-player Farflow ceiling. Work improves tuning, readability,
chemistry, delivery, and proof inside that foundation. It does not add another
champion, movement technique, map expansion, deferred element, mode, or
32-player claim.

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
| O3 | `bootstrap.gd` composes the game; it does not own every subsystem. | Apply a strangler refactor only along touched seams: extract capture/CLI diagnostics, session orchestration, station/editor UI and combat presentation into bounded collaborators with explicit inputs. Do not rewrite movement, combat, networking or rendering together. | The root node owns lifecycle/composition only, extracted units have focused tests, no state authority moves to presentation, and source/Farflow/capture behavior is unchanged. |
| O4 | One-file Windows delivery is complete only when Windows can trust and run it. | Add an optional certificate-supplied signing stage after deterministic packaging, verify Authenticode and embedded payload hashes, and preserve unsigned development output as an explicitly labelled local artifact. Never generate or embed a private release key. | A certificate-bearing build fails if signing or verification fails; an eligible physical Windows machine completes install/update/repair/start/safe-quit; unsigned policy blocking remains an explicit external gate until that evidence exists. |
| O5 | Runtime packages contain reachable production assets, while source and provenance stay in Git. | Generate a dependency report from runtime catalogs and scenes; replace `all_resources` export with an allowlisted runtime manifest or equivalent verified exclusions; retain concept/source assets outside the PCK. Delete an asset only after registry and history evidence prove it unreachable. | Source and packaged captures match, all asset hashes resolve, no runtime path is missing, and package size reduction is measured rather than guessed. |
| O6 | Current truth is short and generated; history remains available without dominating handoff context. | Generate a current-state manifest containing protocol/schema, content hashes, roster/runtime-spell counts, test totals and package identity; keep `memory.md` to current invariants and latest checkpoints; archive rather than rewrite the append-only worklog. | README and handoff tables agree with the manifest, stale counts fail a docs check, and a new engineer can find current commands/state without reading historical logs. |
| O7 | Windows development must not create accidental cross-platform diffs. | Add `.gitattributes` rules for LF text, CRLF Windows entrypoints where required, and binary image/archive types; normalize only files already modified by an accepted slice rather than rewriting the repository at once. | `git diff --check` is clean, repeated Windows edits do not report LF/CRLF churn, and launch scripts retain their required encoding. |
| O8 | Automated correctness and actual play quality are separate evidence. | Add a short repeatable Wellspring route and an opt-in local playtest report for time-to-first-cast, movement chains, Flux/Stamina refusals, hits, defeats, reaction creation/reset and route use. Store aggregates, never personal input history. | Every acceptance build has deterministic tests plus one named human route; balance/fun claims cite observed results instead of assertion counts. |
| O9 | Chemistry is bounded world state, not thirty-six custom physics scripts. | Compile the 36 symmetric recipes onto a small integer-channel model (structure, heat, saturation, pressure/momentum, charge, radiance/vitality and decay) and shared spatial primitives. Active cells, propagation, work, events, ownership, snapshots and residues all have hard capacities. | Every pair forms through the same contact path, maps only to validated primitives, exposes a spatial counter, decays/resets deterministically, respects worldbone and survives replay/Farflow tests at 120 Hz. |
| O10 | Performance acceptance represents the intended game, not an empty room. | Add reproducible two- and eight-actor stress journeys with maximum legal projectile, field, exposure and reaction pressure; report simulation, CPU render, GPU, event, entity, snapshot and packet budgets separately. | The target machine sustains 120 Hz inside the 8.33 ms frame budget without unbounded queues or packet fragmentation; reduced-effects changes presentation cost only. |

## Development sequence

| Order | Combined delivery slice | Why now |
|---:|---|---|
| 1 | O0 Burst checkpoint plus O7 line-ending contract | Close the already-green player feature and remove immediate diff ambiguity. |
| 2 | O1 warning-clean test tiers plus the first O6 generated state summary | Improve feedback before the larger chemistry surface begins. |
| 3 | O2 combat-definition authority | Prevent eight spell payloads and 36 recipes from multiplying duplicated tuning. |
| 4 | C5 reaction catalog plus O9 recipe compiler | Establish complete, fail-closed chemistry truth without live mutation yet. |
| 5 | C6 exposure/contact with one O3 extraction seam | Put new authority in a dedicated system instead of enlarging `bootstrap.gd`. |
| 6 | C7 shared primitives, then C8 lifecycle/presentation | Build reusable physics first and readable interpretation second. |
| 7 | O5 runtime asset reachability and O10 full-pressure benchmark | Optimize the exact feature-complete acceptance build, not a moving target. |
| 8 | O4 signed physical Windows proof, O8 human route, C9 package | Finish the honest friend-facing playtest gate. |

## Loop discipline

Each slice begins from a published green rollback point. Focused tests run
before the full suite; source/import/120 Hz boots and relevant visual or Farflow
journeys run before documentation. Unexpected stderr is a failure to classify,
not something to suppress. Refactors must preserve state hashes or document a
versioned migration. The next slice starts only after the current player-facing
outcome is playable, reviewed, documented, and recoverable.
