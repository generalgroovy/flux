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
