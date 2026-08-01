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

Commit: pending at pre-commit record time. Push: pending.
