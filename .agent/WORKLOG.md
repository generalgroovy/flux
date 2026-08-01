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

Commit: `8e6bce6`. Push: pending.

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

Commit: `7ffd6e6`. Push: pending.

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

Commit: pending at pre-commit record time. Push: pending.
