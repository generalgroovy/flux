# FLUX delivery-efficiency plan

Status: **canonical execution-efficiency contract**.

This plan minimizes time from idea or defect to a playable, recoverable FLUX
checkpoint. It is subordinate to the C5–C9 player path and the F0–F7 foundation
contract. Speed means less waiting, duplication and rework—not weaker proof,
larger unfinished batches or hidden alternate rules.

## 1. Current constraints and leverage

| Observation | Cost | Highest-leverage response |
| --- | --- | --- |
| `tests/run_all.gd` exposes 64 stable suite IDs | Script preloading still checks dependencies; selected suite bodies provide fast behavioral feedback | Use explicit Focused selection; Full clears inherited selection/list settings and always runs every suite |
| Windows Fast gate is about 12–13 seconds | Good checkpoint smoke, too slow and too shallow for every edit | Add a warm focused loop; retain Fast for structural changes |
| Latest Full gate: 45.2 seconds with an interactive game open, 64 suites / 18,281 assertions | Affordable per slice, wasteful per micro-edit | Run impacted suites during implementation and Full before a green checkpoint |
| `bootstrap.gd` is 3,452 lines | Every feature risks merge conflict and accidental cross-system coupling | Monotonically extract only the seam touched by the active slice |
| Transport, movement and major presenters are 700–900 lines | Boundaries exist but orchestration, policy and representation are still dense | Split policy/codec/definition from lifecycle/drawing when each area is next modified |
| Current facts are repeated manually | Counts, protocol and names drift and create review/rework | Generate one state manifest and verify README/current-plan blocks |
| Many useful scripts expose separate entry points | Capability is strong, discoverability and evidence collation are weak | Add one thin Windows task front door that calls existing scripts |
| Captures, Farflow, package and test results are separate evidence | A green claim requires manual reconstruction | Produce one machine-readable validation receipt per checkpoint |

These are optimization targets, not permission to rewrite working systems.

## 2. Decision record

This table records the resolved design debate so future contributors do not
repeat it.

| Alternative | Attractive because | Failure mode | Decision |
| --- | --- | --- | --- |
| Rewrite the application around a new architecture | Clean diagrams and fewer legacy names | Long unplayable interval, regression surface, invalidated evidence | Reject; use touched-seam strangler extraction |
| Adopt a generic ECS/framework now | Theoretical content scale | Dependency/abstraction cost before actual need; harder Godot debugging | Reject; keep focused state systems and reusable components |
| Allow executable mod scripts | Maximum theoretical freedom | Security, determinism, networking and migration become unbounded | Reject for gameplay; use validated declarative content compiled to safe kernels |
| Run the full gate after every edit | Maximum immediate certainty | Feedback delay discourages iteration and repeats unaffected work | Use selected suites per edit, Fast at structural boundaries, Full at every checkpoint |
| Trust automatic change-impact selection completely | Very fast common path | A wrong dependency map silently skips a regression | Impact map suggests suites; explicit suite IDs remain visible; Full is mandatory before checkpoint |
| Hot-reload every kind of content | Fast tuning | Peers/replays use different rules and state becomes irreproducible | Reload validated presentation offline only; restart for authoritative content |
| Build a general content editor before C9 | Friendly future workflow | Tool becomes a second product before kernels stabilize | Use validated text content and small scaffold commands first; visual editor only after repeated need |
| Add many characters/spells to test extensibility | Appears to prove scale | Multiplies balance/art/reaction work before the base is sound | Use one non-selectable representative fixture per extension seam, then remove or quarantine it |
| Optimize allocations and rendering pre-emptively | Feels performance-conscious | Complexity without measured benefit | Profile worst-case scenarios; optimize only the dominant measured cost |
| Maintain many long-lived branches | Work can appear parallel | Merge drift, conflicting truths and difficult recovery | One green `main`, one short-lived `codex/<gate>-<outcome>` slice branch, fast-forward at acceptance |
| Keep adding plan documents | Captures every thought | Navigation cost and contradictory authority | One README, one backlog, focused canonical contracts, generated state and indexed history |
| Develop all platforms concurrently | Broad reach | Doubles release/debug work during foundation churn | Windows acceptance only; preserve portable boundaries without new Linux claims |
| Design immediately for 32 live players | Future-proof appearance | Premature packet/world complexity before eight-player pressure is measured | Bound eight now; profile/partition before any later 32-player claim |

## 3. One development front door

Keep the existing scripts as focused implementation modules. Add one thin,
non-magical Windows entry point after C5:

```text
scripts\flux.cmd doctor
scripts\flux.cmd run
scripts\flux.cmd test <suite-or-group>
scripts\flux.cmd fast
scripts\flux.cmd full
scripts\flux.cmd scenario <id>
scripts\flux.cmd capture <profile>
scripts\flux.cmd farflow <journey>
scripts\flux.cmd package
scripts\flux.cmd release
```

It prints the exact underlying command, exit code, duration and evidence path.
It does not duplicate test, capture, package or network logic, download tools,
hide warnings or choose a release action implicitly.

The warm inner loop reuses the authoritative worktree's compatible Godot import
cache. Destructive, viewport-changing, capture and release operations continue
to use verified isolated temporary copies. Cache identity includes Godot and
import-contract versions; a cache miss costs time but never changes correctness.

## 4. Feedback ladder

| Loop | Use | Target | Required evidence |
| --- | --- | ---: | --- |
| Static | Every save where applicable | ≤2 s | Parse/schema/docs/link/diff checks for touched files |
| Focused | Every behavior edit | ≤5 s warm | Explicit named suites and scenario assertions |
| Fast | Structural/resource boundary | ≤15 s | Doctor, warning-clean import, independent 120 Hz boot |
| Full | Every candidate checkpoint | ≤45 s | All deterministic suites, import and independent boot |
| Visual/network | When presentation or Farflow is touched | Scenario-bounded | Exact capture/journey manifest and stderr |
| Release | C9/F7 or release change | As required | Package, hashes, install/repair/update/start/safe-quit and receipt |

Targets are local development budgets, not reasons to suppress or skip failed
work. If a tier exceeds its target, record the slow phase before optimizing it.

### 4.1 Selectable test runner

Refactor `tests/run_all.gd` into a stable registry:

```text
suite ID -> script path -> group tags -> owning subsystem
```

Default with no selector remains the complete suite. A selector accepts exact
IDs or declared groups and fails on unknown/empty selection. The output reports
selected count, assertion count, failures and elapsed time. A versioned impact
map may recommend groups from changed paths, but never makes the checkpoint
decision: Full remains mandatory.

Initial groups are `content`, `movement`, `combat`, `chemistry`, `world`,
`presentation`, `network`, `lifecycle`, `replay` and `release-contract`.

### 4.2 Proof pyramid

| Proof | Best at | Purpose |
| --- | --- | --- |
| Schema/contract | Every content edit | Reject incomplete identities, bounds, paths and migrations immediately |
| Unit | Arithmetic and local policy | Make failure small and exact |
| Invariant sweep | Directions, rates, pair order, capacities and hostile values | Cover combinatorial rules without copied examples |
| Scenario | System composition | Prove ordinary commands produce the intended state/event sequence |
| Replay/network | Authority and compatibility | Prove serialization, ordering, prediction and migration boundaries |
| Capture/accessibility | Human-readable presentation | Prove state is understandable at real zoom/density |
| Release journey | Friend-facing lifecycle | Prove the artifact that will actually be shared |

Prefer invariant sweeps over hand-copying eight directions or thirty-six
reaction fixtures. Use fuzz/property-style generation only with a fixed seed,
strict bounds and a minimized failing case written back as a stable fixture.

## 5. Slice card and work-in-progress limits

Every slice has one compact machine-readable card rather than a new prose plan:

| Field | Requirement |
| --- | --- |
| Outcome | One player/developer-visible improvement |
| Authority touched | Exact content/simulation/network/presentation owner |
| Invariants | Hashes, behaviors and formats that must remain unchanged |
| Scenario | Smallest reproduction or acceptance journey |
| Player decision | Choice created, information required, honest cost/counter and quick-retry lesson |
| Tests | Focused group, mandatory integration and final gate |
| Performance | Capacity/budget at risk and measurement point |
| Migration | Schema/wire/save/name impact or explicit `none` |
| Rollback | Last green commit and files created/removed |
| Exit | Observable done condition and evidence path |

Only one gameplay slice is active. Supporting tooling is included only when it
shortens that slice or the immediately following one. Do not maintain multiple
half-implemented mechanics behind unrelated flags.

The planning queue is deliberately small:

| Queue | Limit | Meaning |
| --- | ---: | --- |
| Now | 1 | Active slice with a card and failing/acceptance scenario |
| Next | 2 | Ready outcomes whose dependencies and acceptance are known |
| Later | Unranked | Ideas and options, not implementation promises |
| Rejected/deferred | Recorded | Decision and reopening condition prevent repeated debate |

Implementation proceeds vertically: contract/identity → validation/compiler →
pure authoritative behavior → state/events → presentation/feedback →
replay/network → package evidence. Build only the minimum downstream support
needed to observe the active outcome.

## 6. Scenario-first development

When a bug or feature is concrete, capture its smallest deterministic scenario
before broad implementation:

```text
scenario ID + schema
map/reset group + seed
actors/body profiles/loadouts
initial world/material state
semantic command sequence
duration/capacity limits
state/event/performance assertions
optional capture/Farflow profile
```

The scenario runner must use production catalogs, commands and systems. Unit
tests can isolate arithmetic and validation; the scenario proves composition.
Every fixed bug keeps its scenario when the maintenance value exceeds the small
data cost.

A scenario is also the handoff unit. Its ID, seed, expected result, last receipt
and active diff let another developer resume without reconstructing the entire
conversation or rerunning unrelated exploration.

## 7. Generated truth and validation receipt

C5.5 produces two bounded generated artifacts:

| Artifact | Contains | Never contains |
| --- | --- | --- |
| Current-state manifest | Canonical `main`/compatibility refs, dirty flag, Godot/platform, distinct simulation/snapshot/presentation cadences, protocol/schemas, content hashes/counts, separate authored/runtime-selectable ability counts, reaction-definition count plus enable state, playable/planned roster summaries, body roles versus archive adapters, document-status index and package identity | Historical narrative or manually maintained claims |
| Validation receipt | Selected/full suites, assertions, durations, stderr/warnings, boots, scenarios, captures, Farflow, budgets, package/install results and evidence paths | A green status for a step that did not execute |

README/current-plan tables are generated from or checked against the manifest.
Receipts are ignored local evidence unless intentionally attached to a release;
their schema and generator remain source-controlled.

The same validated runtime-content summary powers the Loom status and the
Windows package's `BUILD-STATE.json`. Package identity is read by executing the
exported PCK outside the checkout and binding its summary to the pack SHA-256;
source report hashes and normalized runtime-catalog hashes are distinct and
must not be compared as interchangeable values. The report never grants
installer, connectivity or human-playtest acceptance.

The C5.5 documentation check must fail when:

- a current file lacks an explicit authority/status class;
- a standing prompt treats historical/migration material as required current
  reading;
- protocol, schema, platform, tick, snapshot cadence, body types versus archive
  paths, station count, authored/runtime spell counts, playable/planned roster or
  reaction definition/enable state disagrees with source;
- planned champions/affinities/assets are presented as selectable;
- a compatibility ID or internal Sanctum path leaks into player-facing current
  vocabulary without a labelled migration context;
- README, in-game Archive and package metadata disagree with the same generated
  state.

## 8. Content scaffolding without framework bloat

After F1–F4 stabilize the kernels, one validator-backed scaffold command may
create disabled templates for a champion, ancestry, spell, delivery, element,
reaction primitive, material, map district, actor/AI policy, objective or mode.
It must:

- allocate no wire ID silently;
- declare schema and compatibility impact;
- include every required field with invalid/disabled sentinel values;
- list missing tests, presentation, interaction and migration work;
- refuse to overwrite existing content;
- never promote the result to a selectable/runtime catalog automatically.
- emit the admission matrix and `draft` lifecycle state defined in
  `docs/FOUNDATION-SYSTEMS.md`.

For an existing kernel, a content addition should normally change authored
data, presentation assets/recipe and focused fixtures—not bootstrap or a copied
simulation controller.

## 9. Architecture acceleration

Apply these rules while touching current hotspots:

| Hotspot | Next extraction boundary | Speed benefit |
| --- | --- | --- |
| `bootstrap.gd` | Runtime-content context, Wellspring coordinator, Farflow coordinator, combat presentation, capture diagnostics, safe quit | Smaller diffs and independent tests; monotonic removal of orchestration branches |
| `session_transport.gd` | Packet codec/validation/rate policy separate from ENet lifecycle | Protocol fixtures run without opening sockets; network lifecycle stays understandable |
| `movement_system.gd` | Intent/action-transition/contact helpers with one state owner | Faster tuning/tests without fragmented movement authority |
| `combat_system.gd` | Delivery execution and contact resolution behind compiled definitions | New spells reuse kernels without giant dispatch edits |
| Major presenters | Pure recipe selection separated from draw batching | Visual iteration avoids simulation risk and supports measured batching |

Do not target line count mechanically. Success is fewer reasons for a file to
change, explicit inputs/outputs, focused tests and preserved state hashes.

## 10. Performance workflow

1. Reproduce maximum legal pressure through a deterministic scenario.
2. Record p50/p95/p99 and worst tick/frame by subsystem, entity/event count,
   allocation growth, snapshot bytes and packet fragments.
3. Optimize the largest measured contributor without changing authority.
4. Re-run the same seed and compare receipt data.
5. Retain the optimization only when the gain is material and clarity does not
   regress.

Prefer bounded arrays, precompiled lookup tables, spatial queries, cached
content access and batched draw preparation. Avoid repeated scene-tree search,
JSON parsing inside play, per-frame string construction, unbounded queues and
one node per transient effect when measured density makes that costly.

## 11. Critical-path rollout

| Earliest point | Efficiency work | Why it belongs there |
| --- | --- | --- |
| C5 close | No new framework; finish tests/docs and publish rollback point | Avoid mixing process work into already-green reaction truth |
| C5.5 — complete in this checkpoint | Current-state generator/docs check, 64 stable suite IDs/selector, `.\flux.cmd`, receipts, asset inventory, canonical roster adapters and derived Loom/exported-pack state are verified | Immediate feedback and truth improvements before C6 live reaction state grows |
| C6 | First production scenario: two-source exposure/contact; first bootstrap content/chemistry extraction | Proves scenario and architecture patterns on the active feature |
| C7 | Primitive coverage generator and capacity/property fixtures | Eliminates repetitive tests across 36 recipes |
| C8 | Scenario-driven visual lifecycle/capture and presentation budget reporting | Makes readability iteration reproducible |
| C9 | Unified gate receipt, eight-player pressure, package/Farflow/install proof | Produces one auditable playtest artifact |
| F0–F4 | Generalize only patterns proven during C6–C9; add content scaffolds | Avoid speculative developer platform work |
| F5–F7 | Complete player/developer sandbox, fault injection and release proof | Opens routine expansion on a measured foundation |

## 12. Checkpoint and branch discipline

- `main` is the published playable truth.
- Start one short-lived `codex/<gate>-<outcome>` branch from green `main` after
  the current C5 working state is published.
- Keep the active worktree runnable; commit only coherent green slices.
- Fast-forward `main` after Full plus required scenario/capture/Farflow gates;
  avoid merge commits for a single linear slice.
- Delete merged local slice branches after remote ancestry and recovery are
  confirmed; keep no second compatibility branch with divergent content.
- Never stage personal dependencies, firewall rules, shortcuts, credentials,
  local captures, logs or generated package output.

## 13. Efficiency acceptance

The delivery system is successful when:

1. a developer can identify current state, active slice and exact next command
   in under two minutes;
2. one named command reproduces every maintained defect or acceptance journey;
3. focused feedback is normally under five seconds and never hides the required
   checkpoint gate;
4. a green checkpoint has one receipt tying source identity to tests, runtime,
   scenarios, performance and package evidence;
5. additions using an existing kernel do not edit bootstrap or copy a gameplay
   controller;
6. architecture hotspots lose responsibilities as they are touched;
7. current documentation cannot drift from generated runtime facts;
8. the project remains launchable, resettable and safe to quit at every
   interruption boundary.

## 14. Parallel and handoff discipline

Parallel work is useful only after the shared schema/interface and acceptance
scenario are frozen. Safe parallel lanes include original source-art work,
presentation recipes, independent fixtures, documentation generated from the
same manifest, and platform packaging that does not edit gameplay authority.
Do not parallel-edit the same catalog, protocol, simulation owner or generated
artifact.

Every handoff contains only:

1. source branch/commit and dirty-state summary;
2. active slice card and scenario command;
3. changed authorities and invariants;
4. last focused/Fast/Full receipt paths;
5. exact blocker or next smallest failing assertion;
6. user-owned files that must remain untouched.
7. applicable player-experience journey and the last observed confusion or
   correction, when player-facing behavior changed.

This keeps handoffs transparent while avoiding repeated full-repository
analysis and contradictory prompts.
