# FLUX2 agent worklog

## 2026-08-01 — Godot deterministic movement foundation

Branch: `agent/aider-godot-foundation`

What changed and why:

- Pinned official Godot 4.7.1 with a SHA-256-verified, user-local, rerunnable
  installer and retained offline archive cache.
- Added a compatibility-renderer project, bootstrap scene, explicit input
  router, bounded catch-up loop, and 60/120 Hz pre-match configuration.
- Added renderer-independent scale-1000 commands/state, ordered integer
  collision, FLUX-derived universal deep movement, state hashing, replay
  recording, and per-checkpoint verification.
- Excluded protected concept boards from Godot runtime import without changing
  any original PNG/WebP asset.
- Added Linux/Windows export presets, pinned CI, development instructions, and
  a preserve/reinterpret/replace/archive migration record.
- Established an original expanded Sanctum visual target and encoded its warm
  stone, garden, brass, cyan/violet magic, and dark instrument-panel language
  into the runnable training-court presentation.
- Added a validated nine-district, three-layer Sanctum content definition with
  reciprocal routes, combined functions, multiple entrances, deep-movement
  paths, nine attunement nodes, and fail-closed fast-travel eligibility.
- Rewrote the README as the FLUX2 product brief and added visual/hub contracts
  covering the core loop, combat/chemistry goals, vastness, menus, offline use,
  accessibility, asset provenance, and implementation sequence.
- Added a chapter/subchapter status index and gate-ordered overhaul plan derived
  from the supplied FLUX product brief, with truthful completion checkboxes and
  explicit working-slice boundaries.

Files changed:

- `.github/workflows/ci.yml`, `.gitignore`, `.godot-version`, `project.godot`,
  `export_presets.cfg`, `toolchains/godot.env`;
- `src/app/`, `src/sim/`, `scenes/bootstrap/`, `tests/`;
- `scripts/install-godot.sh`, `scripts/doctor.sh`, `scripts/test.sh`,
  `scripts/run.sh`;
- `README.md`, `SPECIFICATION.md`, `docs/DEVELOPMENT.md`,
  `docs/MIGRATION-FLUX-MOVEMENT.md`, `docs/SANCTUM-HUB.md`,
  `docs/VISUAL-DIRECTION.md`, `docs/OVERHAUL-PLAN.md`, `reference/.gdignore`;
- `assets/concept/`, `content/maps/sanctum_hub_v1.json`,
  `src/content/hub_definition.gd`, `tests/unit/test_hub_definition.gd`.

Validation:

- `scripts/test.sh` outside the restricted socket sandbox: clean Godot import,
  10 core + 340 movement + 10 replay assertions, and 60/120 Hz bootstrap
  launches; all passed.
- `scripts/install-godot.sh` twice from cached archive: both passed; archive
  SHA-256 `c7ff14fd28472c8d4f193043de30278dcf7e5241a1dcf7566b02e27addaa33ba`.
- `bash -n scripts/*.sh` and `git diff --check`: passed.
- GUI launch: Godot 4.7.1 compatibility renderer on AMD Radeon 610M; room,
  player, obstacles, rail, and debug HUD rendered; process closed cleanly.
- Sanctum content validation: 46 assertions covering schema, district scale,
  combined functions, entrances, traversal routes, attunement unlocks, blocked
  states, endpoint identity, and destination clearance; passed.

Known limitations and risks:

- This milestone is the deterministic movement/replay foundation, not the full
  shooter, networking, chemistry, content, animation, or release-export slice.
- The generated Sanctum image is visual direction only and excluded from Godot
  import. It does not replace an original modular runtime art kit or authored
  topology/material layers.
- Foundation collision uses ordered integer boxes; authored elevation columns,
  moving platforms, and material-derived collision are subsequent systems.
- Matching 4.7.1 export templates are not cached yet; editor/headless offline
  development is ready, but offline release export preparation remains.
- CI is configured but its first remote run is pending the branch push.

Commit: `8e6bce6`. Push: `origin/agent/aider-godot-foundation`.

## 2026-08-01 — Resource and independent-input truth

Branch: `agent/aider-godot-foundation`

What changed and why:

- Corrected the FLUX contract by separating universal movement Stamina from
  spell/champion Flux and Health; each has independent integer bounds, recovery
  rates, remainders, and delays at both supported match rates.
- Versioned canonical commands/state to protocol 2 with deterministic
  independent aim and held-primary input. Moving and aiming in different
  directions is now an explicit replayable state.
- Aligned player-one defaults with the source brief: WASD/mouse, Alt sprint, C
  movement chain, V technique, left click/Space primary, plus action-based
  left/right-stick, trigger, shoulder, and east-button controller defaults.
- Hardened `scripts/test.sh` so Godot parse, compile, load, and invalid-call
  diagnostics fail the gate even when the engine process exits zero.
- Added resource and input-map suites and updated the public implementation
  status/overhaul plan without claiming that primary input fires yet.

Files changed:

- `src/sim/entities/player_state.gd`, `player_tuning.gd`,
  `player_resources_system.gd`;
- `src/sim/core/sim_command.gd`, `sim_config.gd`, `sim_world.gd`;
- `src/sim/movement/`, `src/app/`, `tests/unit/`, `tests/run_all.gd`;
- `scripts/test.sh`, `README.md`, `docs/DEVELOPMENT.md`,
  `docs/OVERHAUL-PLAN.md`.

Validation:

- Full headless gate: 478 assertions, zero failures.
- Godot import and bootstrap at 60 and 120 Hz: passed with protocol 2 and no
  script/runtime diagnostics (restricted-sandbox editor socket warnings only).
- `git diff --check` and `bash -n scripts/*.sh`: passed after whitespace cleanup.

Known limitations and risks:

- Primary input is canonical protocol/state only; it intentionally creates no
  projectile until the focused combat slice.
- Controller defaults are registered and tested structurally; interactive
  device acceptance and saved remapping remain open.
- Edgeweave, authored elevation, and the remaining launched/grappled/status
  movement contracts remain the next Movement Conservatory slice.

Commit: `7ffd6e6`. Push: `origin/agent/aider-godot-foundation`.

## 2026-08-01 — Movement constraints and Conservatory route

Branch: `agent/aider-godot-foundation`

What changed and why:

- Added deterministic wall identities and the FLUX-derived 220 ms per-wall
  lockout so repeated contact cannot refresh infinite wall kicks.
- Added bounded launched, grappled, charging, stunned, rooted, and slowed
  control-state contracts. External speeds clamp to the authored movement
  ceiling and all resulting movement still resolves through ordered collision.
- Added a 60/120 Hz Movement Conservatory integration fixture that completes
  sprint-to-slide, late slide jump, air redirect, marked vault, and crest
  superglide in the same semantic order.
- Explicitly deferred Edgeweave until the projectile slice can distinguish a
  swept hostile miss band from the inner hit volume and prevent repeat farming.

Files changed:

- `src/sim/world/collision_world.gd`, `src/sim/entities/player_state.gd`,
  `src/sim/movement/movement_system.gd`, `movement_tuning.gd`;
- `tests/unit/test_movement.gd`,
  `tests/integration/test_conservatory_route.gd`, `tests/run_all.gd`;
- `README.md`, `docs/OVERHAUL-PLAN.md`,
  `docs/MIGRATION-FLUX-MOVEMENT.md`.

Validation:

- Full headless gate: 526 assertions, zero failures.
- Godot import and 60/120 Hz protocol-2 bootstrap: passed with no script/runtime
  diagnostics (restricted-sandbox editor socket warnings only).

Known limitations and risks:

- The control states expose safe simulation contracts for later abilities and
  statuses; no current input or content grants them.
- Authored elevation bands, hop/fall presentation, buffered inputs, Edgeweave,
  saved remapping, and interactive controller acceptance remain open.

Commit: `8805be0`. Push: `origin/agent/aider-godot-foundation`.

## 2026-08-01 — Canonical ability and loadout configuration

Branch: `agent/aider-godot-foundation`

What changed and why:

- Added a versioned ability catalog with stable string/wire IDs, roles,
  counterplay, simulation authority, integer timing/resource fields, and
  recursively canonical SHA-256 hashing.
- Declared all twelve intended element families while failing closed on ability
  use of Spirit, Chaos, Gravity, or Time until their later acceptance gates.
- Added a legal foundation loadout with one passive, resource-free primary,
  three unique positive-cost actives, champion mobility, and ultimate.
  Charge/Light affinity discounts fill exactly 13 points and do not modify raw
  damage or other power values.
- Integrated catalog/loadout validation into bootstrap and documented the
  promotion order before implementing casts.

Files changed:

- `content/abilities/foundation_abilities_v1.json`,
  `content/loadouts/foundation_practitioner_v1.json`;
- `src/content/canonical_content.gd`, `ability_catalog.gd`,
  `loadout_definition.gd`, `src/app/bootstrap.gd`;
- `tests/unit/test_ability_content.gd`, `tests/run_all.gd`;
- `README.md`, `docs/ABILITY-CONFIGURATION.md`,
  `docs/OVERHAUL-PLAN.md`.

Validation:

- Ability/loadout suite: 33 assertions covering stable hashes, twelve declared
  families, eight enabled families, positive active contracts, reliable
  zero-Flux primary, exact 13-point loadout, duplicate rejection, budget
  rejection, and invalid active rejection; passed.
- Final integrated headless gate: 559 assertions, zero failures; bootstrap
  validated the catalog/hash and exact 13/13 build at both 60 and 120 Hz.
- `git diff --check` and `bash -n scripts/*.sh`: passed.

Known limitations and risks:

- Authoring JSON is validated and hashed but not yet compiled to a locked
  historical wire manifest or included in session/replay compatibility metadata.
- The catalog is configuration only; input cannot cast, damage, or place
  terrain until the focused combat slices.

Commit: `e7e8ded`. Push: `origin/agent/aider-godot-foundation`.

## 2026-08-01 — Deterministic projectile combat and Edgeweave

Branch: `agent/aider-godot-foundation`

What changed and why:

- Versioned protocol 3 with pressed active-one input and aligned keyboard,
  mouse, and controller defaults.
- Implemented resource-free Arc Primary and 24-Flux Vector Lance through
  startup, aim snapshot, recovery, cooldown, stable projectile IDs, integer
  movement/remainders, ordered collision, swept hostile hits, authoritative
  Health damage, lifetime/impact events, presentation, state hashing, and replay.
- Implemented FLUX-derived Edgeweave: a 16-unit hostile outer miss band at
  260+ speed rewards at most 9 Stamina with a 220 ms fighter lockout; hits,
  full Stamina, training sources, and repeated projectile/fighter pairs do not
  reward.
- Documented tick order and deliberate combat limitations rather than implying
  projectile clash, defenses, statuses, or chemistry already exist.

Files changed:

- `src/sim/combat/`, `src/sim/core/sim_command.gd`, `sim_config.gd`,
  `sim_world.gd`, `src/sim/entities/player_state.gd`;
- `src/app/input_router.gd`, `bootstrap.gd`;
- `tests/unit/test_combat.gd`, `test_ability_content.gd`,
  `test_input_router.gd`, `tests/replay/test_replay.gd`, `tests/run_all.gd`;
- `README.md`, `docs/COMBAT-FOUNDATION.md`,
  `docs/ABILITY-CONFIGURATION.md`, `docs/DEVELOPMENT.md`,
  `docs/OVERHAUL-PLAN.md`.

Validation:

- Full headless gate before final documentation: 727 assertions, zero failures.
- Both 60 and 120 Hz pass primary/active startup and hit tests, exact Flux and
  damage checks, refusal diagnostics, Edgeweave reward/hit/training/repeat
  guards, command-stream replay, import, and protocol-3 bootstrap.

Known limitations and risks:

- Defeat/respawn, clash, defense, statuses, knockback, pierce, fields, bots,
  network packets, chemistry, and production telegraphs are still explicit
  later slices.
- Runtime tuning is guarded against catalog drift by tests; a generated locked
  wire/runtime table remains preferable before wider catalog growth.

Commit: `2896ce6`. Push: `origin/agent/aider-godot-foundation`.

## 2026-08-01 — Published foundation checkpoint

Branch: `agent/aider-godot-foundation`

What changed and why:

- Reconciled the pre-commit worklog records with the five focused commits that
  now exist on the remote branch.
- Updated the implementation plan to identify protocol 3 as the current
  command contract after active-one casting extended the protocol-2 aim work.
- Published the branch as draft PR #5 against the reviewed Godot architecture
  branch so the stacked foundation remains reviewable without targeting main.

Validation:

- Full local headless gate: 727 assertions, zero failures.
- Clean Godot import/bootstrap at both 60 and 120 Hz with protocol 3: passed.
- GitHub draft PR #5: both `headless` checks passed for the current remote
  foundation commits.

Known limitations and risks:

- This checkpoint is a playable engineering skeleton, not a content-complete
  overhaul. The unchecked README/plan items remain deliberately open.
- Export templates, Windows acceptance, networking, authored hub tiles,
  chemistry runtime, and the first complete champion are later gated slices.

Implementation commits: `8e6bce6`, `7ffd6e6`, `8805be0`, `e7e8ded`, and
`2896ce6`. Draft PR: `https://github.com/generalgroovy/flux2/pull/5`.
Documentation commit: pending at pre-commit record time.

## 2026-08-01 — Game breadth and gate-ordered production roadmap

Branch: `agent/aider-godot-foundation`

What changed and why:

- Expanded the README opening status/index from a terse system list into nine
  linked chapters with honest implemented/planned subchapter checkboxes.
- Defined the original movement/traversal grammar, map interactions, targeting
  families, fighter commitments, resources/loadout, validated Flux Formula
  composition, element gates, destruction layers, reusable map packages/devices,
  progression boundaries, and shared-system mode families.
- Carried all 23 named FLUX champion designs plus the unapproved Angel slot as
  migration inputs, separated ancestry/champion/loadout responsibilities, and
  added three provisional original arachnoid body plans without making them
  selectable or inventing permanent champion identities.
- Recorded inspiration only as broad design principles and explicitly barred
  copied characters, assets, abilities, maps, layouts, terminology, code, and
  trade dress.
- Reconciled normative specification and overhaul ordering through checkpoints
  F–O; corrected stale migration/configuration prose now that protocol 3,
  projectile casting, and Edgeweave are implemented.

Files changed:

- `README.md`;
- `SPECIFICATION.md`;
- `docs/OVERHAUL-PLAN.md`;
- `docs/MIGRATION-FLUX-MOVEMENT.md`;
- `docs/ABILITY-CONFIGURATION.md`;
- `.agent/WORKLOG.md`.

Validation:

- Full headless gate: 727 assertions, zero failures.
- Godot import and protocol-3 bootstrap at 60 and 120 Hz: passed.
- `bash -n scripts/*.sh` and `git diff --check`: passed.
- Reviewed all changed Markdown links and confirmed no protected image, audio,
  archive, or other binary asset changed.

Known limitations and risks:

- This is a design/production-management checkpoint; runtime behavior remains
  the previously green checkpoint E combat foundation.
- Weaverkin, Scorpionkin, and Harvestkin are provisional body-plan labels. Names,
  lore, visual designs, traits, and champions require explicit approval before
  data/runtime promotion.
- Formula composition, advanced traversal, ancestry registries, map devices,
  chemistry, networks, modes, and checkpoints F–O remain unchecked until their
  own implementation and acceptance slices pass.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-08 — G2 authored campus topology verification (in progress)

Branch: `agent/aider-godot-foundation`

What changed and why:

- Replaced edge-count topology acceptance with an actual connected-district
  traversal; self-links, unknown districts and bridge endpoints outside their
  declared districts fail closed.
- Declared the current campus buildings as immutable worldbone and made
  district elevation queryable without consulting rendering or scene nodes.
- Required ordinary and advanced routes in every visible district, one
  accessible ordinary route per district, and route points owned by their
  declared district.
- Added bounded Conservatory movement and Proving practice reset-zone metadata.
- Preserved the existing G2 camera, procedural presentation, canonical map
  identity and all unrelated dirty work.

Validation:

- AUTOCODE offline executor: complete `bash scripts/test.sh` gate passed with
  external networking isolated and a private safe `/dev`.
- Sanctum campus suite: 86 assertions, zero failures; complete repository gate:
  960 assertions, zero failures.
- Godot import and bootstrap at 60 and 120 Hz passed.
- A deterministic 1280 x 720 three-frame runtime capture completed through the
  offline executor; the capture confirms the scrolling campus is functional but
  remains visibly sparse and procedural.
- `bash -n scripts/*.sh` and `git diff --check` passed.

Known limitations and risks:

- G2 is not complete. The older untracked `v1` environment sheet remains an
  unreviewed candidate and is untouched. The new generated `v2` source/alpha
  candidate has immutable hashes, generator/prompt provenance, a fail-closed
  twelve-slot manifest and alpha/chroma validation, but license review remains
  pending and it is intentionally excluded from runtime import.
- The runtime presentation is code-drawn and does not yet pass modular pixel-kit,
  gameplay-zoom silhouette, grayscale/color-vision, collision/art alignment,
  import/memory/performance, or Garuda/Sway visual acceptance.
- Reset zones are validated map metadata only; typed reset execution remains a
  later systemic Sanctum slice.

Asset-pipeline evidence added after the topology gate:

- `assets/concept/sanctum-modular-kit-generated-source-v2.png` and
  `sanctum-modular-kit-alpha-candidate-v2.png`;
- `content/assets/sanctum_modular_kit_candidate_v2.json`;
- `src/content/environment_kit_manifest.gd` and
  `tests/unit/test_environment_kit_manifest.gd`;
- environment manifest: 36 assertions, zero failures; complete offline gate:
  996 assertions, zero failures.
- deterministic Godot-only preparation now emits twelve alpha-trimmed candidate
  crops with manifest-bound paths, hashes, dimensions and bottom-center
  presentation pivots. Hash replay was byte-identical; the expanded asset suite
  passes 64 assertions and the complete offline gate passes 1,024.
- Added bounded `--capture-pointer=X,Y` visual-test input so movie capture does
  not inherit nondeterministic host cursor state. Two independent 60 Hz captures
  were byte-identical; the world region below the HUD was pixel-identical at 60
  and 120 Hz for the same capture frame. A 1280 x 720 grayscale inspection kept
  player, path, vault, building-edge and shrine silhouettes legible.
- These checks prove repeatable presentation output, not artistic acceptance:
  the procedural campus remains sparse and the candidate crops are still
  excluded from runtime pending approval and alignment gates.

Commit: deferred until the complete G2 promotion gate passes. Push: deferred.

## 2026-08-01 — G1 offline controls and configurable POV

Branch: `agent/aider-godot-foundation`

What changed and why:

- Added a versioned local-only player-preferences profile with safe defaults,
  exact JSON persistence, schema/bounds validation, conflict rejection, and
  explicit per-action physical-key unbinding while retaining mouse/controller
  events.
- Added independent `world_relative` and `aim_relative` movement presets. The
  latter treats independent aim as forward and converts forward/strafe intent
  into the same bounded world command with integer math.
- Added independent `full` and `cone` POV presentation. Cone mode accepts
  15–360 degrees and a 160–4096 unit range, including a finite circular
  360-degree view; the mask renders after actors and before HUD/debug panels.
- Added F7–F10 saved runtime controls and exact launcher overrides for movement
  reference, POV mode, angle, and range. The launch script now forwards user
  arguments to Godot.
- Defined the multiplayer trust boundary: local POV can restrict presentation,
  while any mode-owned hidden information must be host-enforced and omitted
  from replication.
- Promoted G2—the first authored Nexus-to-Conservatory topology/visual slice—
  ahead of F2 reaction work, and explicitly documented that the current
  concentric court is only a mechanics fixture, not accepted Sanctum art.
- Began bounded G2/Sanctum-V1 preproduction during G1 final verification: the
  first product acceptance matrix now requires spacious authored areas,
  environment charm/readability, base body/jump/interaction/taunt, chemistry,
  friends/presence/join, host teams/friendly-fire/practice/travel controls,
  authoritative LOS with foreground cutaways, and co-equal Garuda Linux/Sway
  plus Windows source/package evidence before later gameplay modes.

Files changed:

- `src/app/player_preferences.gd`;
- `src/app/input_router.gd` and `src/app/bootstrap.gd`;
- `scripts/run.sh`;
- `tests/unit/test_player_preferences.gd`, input-router coverage, and the suite
  runner;
- `docs/PLAYER-CONTROLS-AND-POV.md`, README, specification, Sanctum contract,
  Living Sanctum V1 acceptance contract, visual direction, development
  instructions, and overhaul plan.

Validation:

- Full headless gate: 872 assertions, zero failures.
- Clean bootstrap at 60 and 120 Hz: passed with protocol 3 and safe default
  `world_relative`/`full` settings.
- Offline save/load round trip, unknown/conflicting actions, explicit unbind,
  numeric bounds, exact 360-degree view, both movement transforms, and retained
  controller/mouse events: passed.
- Interactive AMD Radeon 610M compatibility-renderer smoke using
  `aim_relative`, `cone`, 135 degrees, and 520 units: passed. Cone direction and
  finite range were visible; HUD and Material Yard diagnostics remained
  unobscured.
- `bash -n scripts/*.sh` and `git diff --check`: passed.

Known limitations and risks:

- The current cone is a local presentation option, not authoritative wall
  occlusion. Competitive limited-information modes must add host visibility
  queries and information-leak tests before use.
- Physical keyboard bindings are editable in the generated offline JSON. The
  Settings station, interactive input capture, per-device sensitivity/dead-zone
  curves, controller profile persistence, and import/export remain G3 work.
- The current Sanctum renderer remains the visibly inadequate schematic that
  G2 now replaces next; this checkpoint does not claim visual acceptance.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-01 — F1 deterministic Material Yard storage foundation

Branch: `agent/aider-godot-foundation`

What changed and why:

- Added a fail-closed, stable-wire material catalog for the first eleven
  occupancy materials while keeping charge as an independent field so water
  and other matter can carry stored force without changing identity.
- Added an exact 128-by-128 authored Material Yard seed definition with
  immutable Worldbone, a complete perimeter, deterministic reset ownership,
  elevation samples, and a rate-independent work budget.
- Implemented packed parallel material fields, guarded writes, deterministic
  sorted/deduplicated awake work, reset, and stable state/Worldbone hashes.
- Integrated catalog and yard validation into startup and exposed a read-only
  in-world development preview; rendering cannot mutate simulation state.
- Reordered the production plan around the new F1 checkpoint. Reaction
  scheduling remains F2 and is intentionally absent from this storage slice.

Files changed:

- `content/materials/foundation_materials_v1.json`;
- `content/maps/sanctum_material_yard_v1.json`;
- `src/content/material_registry.gd`;
- `src/content/material_yard_definition.gd`;
- `src/sim/materials/material_grid.gd`;
- `src/app/bootstrap.gd`;
- `tests/unit/test_material_content.gd`;
- `tests/unit/test_material_grid.gd`;
- `tests/run_all.gd`;
- `README.md`, `SPECIFICATION.md`, and the related development/overhaul/material
  documentation.

Validation:

- Full headless gate at the final source state: 818 assertions, zero failures.
- Clean bootstrap at both 60 and 120 Hz: passed; material catalog hash
  `1c9b15a12d94`, yard hash `3b466b916d6e`.
- Interactive AMD Radeon 610M compatibility-renderer smoke: passed. The preview
  frame, plinth, material bands, charged-water cue, and hashes were visible and
  left the training lanes unobstructed.
- `bash -n scripts/*.sh` and `git diff --check`: passed.

Known limitations and risks:

- This slice establishes storage, validation, work ordering, reset, and a
  diagnostic preview only. It does not yet execute reactions, destruction,
  propagation, or network deltas.
- The current training court is still a schematic mechanics harness, not the
  approved vast Living Sanctum presentation. Authored Sanctum topology and
  visual replacement have been promoted immediately after the requested
  control/POV checkpoint.
- Material Yard colors are diagnostic and are not shipping art direction.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-09 — unified G2 topology/runtime-kit and champion visual contract

Branch: `integration/all-branches-20260809`

What changed and why:

- Integrated the preserved dirty G2 work over the consolidated FLUX2 branch
  lineage: canonical Sanctum campus topology, immutable worldbone, elevation,
  ordinary/advanced/accessibility routes, reset metadata, renderer, content
  validators, deterministic local runtime-kit generator, and tests.
- Preserved the user-passed eighteen-champion board at
  `assets/concept/flux-champions-visual-style-v1.png`; recorded its dimensions,
  SHA-256, visual-reference authority, and non-authoritative label boundary.
- Repaired visual-production manifests that referenced missing local images.
  All champion style references now resolve to the preserved board.
- Updated README, normative specification, visual direction, and overhaul plan
  with the mandatory compact expressive pixel-art bar, the original-art and
  asset-promotion gates, complete per-champion animation requirement, and the
  production Space-to-jump migration.
- Defined jump presentation precisely: stable authoritative ground anchor,
  independently lifted body, separate receiving-surface shadow that broadens
  and darkens through ascent, peaks at apex, contracts on descent, and is driven
  from equivalent normalized authoritative phase at 60 and 120 Hz.

Validation:

- Full Godot headless gate: 12,250 assertions, zero failures.
- Clean bootstrap at 60 and 120 Hz: passed with campus hash `13bd675242c8`.
- Both visual JSON manifests parse and all 26 collected reference paths exist.
- Supplied board: 1536 x 1024 RGBA PNG, SHA-256
  `cb8aa1b3f4e1c41498a35dd37303a3783b0f8fa2c0bbb0b75a89cbd02934732f`.
- `git diff --check`: passed.

Known limitations and risks:

- Runtime-addressable eight-direction champion candidates and a 25-action
  skeleton contract exist, but the production animations remain planned; no
  portrait, direction preview, skeleton atlas, or generated keyframe board is
  claimed as final in-game animation acceptance.
- Visual validators currently emit Godot export warnings because they load PNG
  files through `Image.load_from_file`; assertions and boots pass, but an
  export-safe validator-loading cleanup remains required.
- The legacy browser FLUX test gate is 145/146 locally because `linkedom` is not
  installed and no package manager is available. No dependency was fetched or
  installed without approval.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-09 — canonical FLUX repository unification

Branch: `integration/all-branches-20260809`

What changed and why:

- Consolidated every fetched legacy browser FLUX branch into tip `1d0c807`.
  Later pixel work was merged normally; superseded archival tips were retained
  as tree-preserving merge parents with an explicit audit record.
- Imported that complete legacy ancestry under `legacy/web-prototype/` while
  keeping the Godot project at repository root authoritative.
- Updated the root README and branch-consolidation record with the canonical
  layout and the legacy dependency limitation.

Validation:

- Imported subtree tree object exactly matches legacy tip `1d0c807`:
  `3675a862d23de980e5b7700fe02fa0162fb50ff9`.
- Godot full gate: 12,250 assertions, zero failures; clean 60 and 120 Hz boots.
- Legacy dependency-independent gate: 149 tests, 149 pass, zero failures.
- The three excluded legacy test files remain explicitly dependency-blocked by
  absent locked `linkedom`/`ws`; they are not represented as passing.
- Every fetched branch tip in both source repositories is retained as an
  ancestor of its consolidated lineage.

Known limitations and risks:

- Exact legacy `npm test` still requires preparing the locked dependencies.
- Repository cutover and remote push remain separate reversible operations.

Commit: pending at pre-commit record time. Push: pending.
