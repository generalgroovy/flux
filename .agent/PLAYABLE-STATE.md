# FLUX playable-state ledger

Date: 2026-07-29
Branch: `integration/unify-flux`
Base: `d77c0b2` (`agent/windows-linux-runtime`)

## Integrated state

The branch preserves the complete 0.34.3 live game and its Windows/Linux runtime
repair. It adds the independently tested future overhaul data foundation and one
canonical cross-platform verification workflow. The overhaul catalog remains
inactive: `src/content.mjs` and `src/match.mjs` are still authoritative for live
gameplay.

Integrated work:

- reliable Windows `npm.cmd` launch and authenticated graceful server cleanup;
- audited recovery tags for every pre-unification branch;
- reconciled overhaul constraints, system audit, compatibility matrix, and
  implementation loop;
- future eight-element, sixteen-race, sixteen-character, ability, reaction,
  movement, mode, and destruction data contracts;
- static character-balance profiling and roster diversity/counterplay guards;
- approved simple future display vocabulary and canonical character visual
  direction;
- a fail-closed, headless Hara overhaul prototype with deterministic Ray/Stone
  Shot swapping, Gust Ring, Sun Grid, and bot behavior; it is not exposed in the
  menu or accepted by live lobbies;
- one Windows/Ubuntu Node 20.19.1/22 verification matrix with real packaging
  jobs and failure diagnostics.

No checkpoint payload or checkpoint-generated source was applied. The manifest
cannot be reconstructed deterministically, as recorded in
`.agent/BRANCH-AUDIT.md`.

## Verified on current source

Observed on Windows on 2026-07-28:

- `npm.cmd ci` completed successfully earlier in the integration pass.
- `npm.cmd test` passed 119/119: 117 core/DOM/deterministic checks, one live
  WebSocket lifecycle, and one authenticated server-cleanup check.
- `node scripts/ci-verify.mjs` passed the same 119 tests and recursive syntax
  checks for all desktop, script, source, and test modules.
- PowerShell launcher parsing passed.
- The canonical workflow parsed as valid YAML.
- `npm.cmd audit --omit=dev` reported zero production vulnerabilities.
- A Windows NSIS package built successfully at commit `3a02958` before the
  inactive concept-data pass.

The full dependency audit reports 16 high-severity development-only findings in
the Electron packaging toolchain. Production dependencies remain clean; the dev
findings must be handled through dependency maintenance rather than concealed.

## Pending launch gate

The current source has not yet been rebuilt and exercised interactively after
the concept-data pass. Before publication as the durable `develop` branch:

1. rebuild the Windows package from current HEAD;
2. open the packaged application;
3. enter a real match through the Play flow;
4. close normally and verify all owned child processes exit;
5. push `develop` and wait for the Windows/Ubuntu CI and packaging jobs;
6. update this ledger with the resulting run URLs and artifacts.

Linux packaging and packaged launch require the GitHub Ubuntu job (or a Linux
host); neither is inferred from a Windows build. The unified branch must not be
merged to `main` until both platform gates are green and explicit final approval
is given.

## 2026-07-29 Living Sanctum candidate

- The old HEX/operations home presentation has been replaced by the Living
  Sanctum; Muster, Friends, Champions, Realm & Rites, Controls, and Settings are
  all reachable from one keyboard/gamepad-compatible navigation rail.
- Entering the Sanctum from a remote contest preserves the authoritative socket,
  lobby identity, and reconnect token across every chamber. Returning to play
  and explicitly leaving remote company are distinct tested actions.
- `npm.cmd test` passes 129/129 on Windows, and source renders at desktop and
  narrow widths without body overflow.
- This does not satisfy the pending packaged-match gate. A current-commit Windows
  package match smoke and the GitHub Ubuntu package job are still required before
  publishing `develop` or considering a merge to `main`.
- Muster now presents thirteen ancestry columns as a compact portrait roster.
  Hover and keyboard focus expose champion role, style, affinity, difficulty,
  ancestry tradeoffs, and kit names without changing the locked choice; Player
  1 and Player 2 previews remain independent.

## 2026-07-29 candidate refresh

- `integration/unify-flux` was refreshed with `origin/main`, passed launch
  preflight, and was pushed before packaging.
- `npm.cmd test` passed 126/126 and `npm.cmd audit --omit=dev` found zero
  production vulnerabilities at `2a1277b`.
- `npm.cmd run package:windows:verified` produced
  `dist/FLUX-Arena-0.34.3-win-x64.exe` for exact commit
  `2a1277b7946f40629b0eb9b8503298946ce8ffcc`, 99,915,974 bytes, SHA-256
  `80bd785916cd2c31180bcd94e95b17a638ff61f9fd62d24fa0fdece3d853eb43`.
- The packaged `win-unpacked/FLUX Arena.exe` opened fullscreen and rendered its
  complete home screen. It closed normally through Alt+F4; `npm.cmd stop`
  reported no registered server and no package-owned process remained.
- Windows UI automation could focus and hover launch controls but did not
  activate them, so no packaged match-entry claim is made. Publishing `develop`
  remains blocked on one real match launch, movement/ability/pause observation,
  and normal close at this exact candidate or its documented successor.
