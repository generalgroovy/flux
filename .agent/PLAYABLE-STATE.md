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

## 2026-07-29 S. Wayne visual candidate

- The compatibility runtime remains the playable Windows/Linux baseline;
  S. Wayne is source-only and cannot enter normal or remote rosters.
- The V1 character path now uses modular champion files, shared drawing
  primitives, a registry-compatible barrel, and one shared non-shipping
  specimen harness.
- S. Wayne renders all six authored Hobbit Dark/Light states. The source board
  was reviewed at 1280x720, scrolled through both rows without clipping, and
  produced no browser console errors.
- `npm.cmd test` passes 132/132 on Windows; `node scripts/ci-verify.mjs` repeats
  the suite and passes recursive JavaScript syntax checks.
- PR #10's Windows/Linux Node 20/22 verification and both installable package
  jobs passed for implementation commit `e472bd7`.

## 2026-07-29 Living Sanctum practice candidate

- The runtime now starts against the authored `living_sanctum` map while the
  Living Sanctum menu remains open. Practice launches a local-only free court
  excluded from competitive catalogs, lobby setup, and network authority.
- The court exposes the complete implemented compatibility movement kernel:
  independent move/aim, counter-strafe, Stamina sprint, committed slide, hop,
  landing cut, wall kick, champion mobility, and Edgeweave. It does not claim
  the README's future double jump, air dodge, wavedash, vault, superglide, or air
  redirect.
- Practice provides a toggleable stationary target, previous/next champion
  switching, exact resource/cooldown refill, floor reset, Sanctum return, and an
  `F2` guide for movement, elements, selected abilities, champions, and races.
  All player-facing resource labels use **Stamina**; internal `flow` identifiers
  remain compatibility keys for saved settings, wire data, and deterministic
  simulation.
- `npm.cmd test` passed 133/133: 131 core/DOM/deterministic checks, one live
  WebSocket lifecycle, and one authenticated cleanup check. `node
  scripts/ci-verify.mjs` repeated all 133 and passed recursive syntax checks;
  `npm.cmd audit --omit=dev` found zero production vulnerabilities.
- The Windows source Electron runtime booted fullscreen into the Sanctum,
  exposed all eight chambers through accessibility, and closed normally with no
  remaining FLUX/Electron window. Desktop automation focused controls but did
  not activate them, matching the prior Chromium automation limitation; no
  automated desktop movement claim is made. The Browser surface rendered the
  menu layout without horizontal overflow but blocked `src/game.mjs` as a local
  source module, so browser behavior is not inferred.
- GitHub Actions run `30458296343` passed all six jobs for implementation
  commit `e5627ad`: Windows and Ubuntu on Node 20.19.1 and Node 22, Windows NSIS,
  and Linux AppImage packaging; PR #11 merged as `09d0257`.

## 2026-07-29 complete universal movement candidate

- This candidate supersedes the earlier Sanctum movement limitation. The live
  deterministic runtime now implements sprint, counter-strafe, jump/double
  jump, slide/slide jump, air redirect, air dodge, wavedash, wall jump, landing
  cut, Edgeweave, marked-cover vault, and vault-crest superglide without using a
  champion ability.
- Player 1 uses remappable `Alt`, `C`, and `V`; Player 2 uses `,`, `.`, and `/`;
  gamepad uses left shoulder, right shoulder, and east face. The same semantic
  `technique` command is sanitized by local and remote authority paths.
- All eight competitive battlegrounds and the Living Sanctum own validated,
  visibly marked vault rails. Vault resolution ignores only the selected rail,
  sweeps against every other collision boundary, rolls back if blocked, and
  never crosses unmarked cover.
- HUD state, event/audio cues, settings, controls, practice map copy, and the
  `F2` field guide describe every conversion. Active movement remains bounded
  by explicit Stamina cost, cooldown, edge-trigger, steering, timing, and speed
  ceilings; low Stamina fails closed with an explicit tell.
- `node scripts/ci-verify.mjs` passed 141/141 automated checks and recursive
  JavaScript syntax checks. Coverage includes each new transition, input edge,
  collision interruption, unmarked-cover rejection, low-Stamina rejection,
  refill reset, a 600-tick mixed chain, all content combinations, and the
  eight-agent two-minute soak.
- The in-app browser rendered the source Sanctum at 1280px with exact-width
  layout and no warnings or errors. Its automation focused but again did not
  activate Chromium controls, so no browser play-input claim is made; movement
  behavior is evidenced by deterministic and DOM tests pending hands-on feel.
- `npm.cmd run package:windows:verified` built the exact `0ff6eb0` NSIS
  installer with SHA-256
  `09b09235619d0acfdc18985441777276845aaa97c3933e25b21c958e17286e87`.
- GitHub Actions run `30462865622` passed all six jobs for movement commit
  `0ff6eb0`: Windows and Ubuntu on Node 20.19.1 and Node 22, Windows NSIS, and
  Linux AppImage packaging.
- The documentation head repeated all six successfully in run `30463176519`;
  PR #13 merged as `8cd54bb`, and `main` plus `integration/unify-flux` were
  realigned there with a clean unification preflight.

## 2026-07-29 Nico promotion and Linux handoff baseline

- Nico Lai is the first promoted overhaul champion, retaining stable live ID
  `volt` while rendering through the accepted Gnome Charge/Light visual profile.
- Centralized bounded champion statistics now authoritatively control maximum
  Health, safe-delay Health recovery, maximum Flux, Flux recovery, speed,
  Stamina, and Endurance; the Sanctum Training Court and field guide expose the
  selected values without changing universal movement rules.
- The Windows source launcher now serves the complete overhaul runtime module
  graph. A real Electron session started directly in the Living Sanctum as Nico,
  opened the Training Court, displayed the six statistics, and restarted on the
  final presentation with separated station labels.
- `node scripts/ci-verify.mjs` passed 143 checks and recursive syntax validation.
  GitHub Actions run `30473256385` passed Windows and Ubuntu Node 20/22 tests
  plus Windows NSIS and Linux AppImage packaging; PR #16 merged as `0d294b2` and
  `main` plus `integration/unify-flux` were realigned there.
- The tracked Garuda handoff now points Odysseus and Aider at Steezo's bounded
  V1 source specimen through `scripts/linux-agent-handoff.sh`. A real Garuda
  doctor, local-model session, Sway clipboard handoff, and Steezo specimen review
  remain target-machine acceptance work and must not be inferred from Windows.

## 2026-07-29 reference-priority update

- The latest supplied images now guide an original three-quarter top-down
  virtual-pixel presentation; no referenced sprite, tile, map, layout, font,
  icon, palette, animation, HUD, or trade dress may be copied.
- `.agent/PIXEL-PERSPECTIVE-OVERHAUL.md` P0-P5 is the active first task. P0 is
  source-only tokens plus a specimen; later slices convert the Living Sanctum,
  Nico, Charge/Light spells, text/HUD, and integrated presentation in order.
- `.agent/MOVEMENT-INPUT-OVERHAUL.md` M0-M5 is the second task after visual
  acceptance. The live build already implements the requested slide jump,
  wavedash, wall jump, air redirect, air dodge, vault, and superglide. The new
  work is a conventional remappable keyboard/controller layout, deterministic
  body-lift/enlarging-shadow jump presentation, full-device revalidation, and
  one bounded no-speed-gain tap-strafe/aerial-turn rule.
- Steezo and other champion expansion are paused until both new task contracts
  pass. This update changes priority and acceptance only; the current playable
  runtime, controls, movement, maps, spells, networking, and roster are unchanged.

## 2026-07-29 P0 visual foundation checkpoint

- The central pixel-perspective contract and its non-shipping review board are
  implemented and accepted after desktop, narrow, grayscale, high-contrast,
  reduced-motion, regression, and browser-diagnostics review.
- The packaged playable game remains behaviorally identical because P0 is not
  imported by `src/game.mjs`; Living Sanctum conversion begins only in P1.
- The current handoff task is P1 presentation only: preserve every collision,
  station trigger, spawn, movement rule, company/network state, and stable ID.

## 2026-07-29 P1 Living Sanctum presentation checkpoint

- The playable Sanctum now uses the accepted original pixel material grammar
  for floor, route, water edge, shallow courts, ward, rails, station landmarks,
  and Rite Gate; competitive arenas are unchanged.
- Desktop and reloaded 480px loopback play surfaces rendered without browser
  warnings/errors or horizontal overflow, and the complete 145-check verification
  remained green.
- P2 Nico sprite work is now active. His live identity remains `volt`, and no
  hitbox, stat, ability, command, movement, simulation, or network change is in
  scope.

## 2026-07-29 P2 Nico pixel runtime checkpoint

- Nico's stable `volt` slot now renders a compact four-facing pixel Gnome with
  six action/damage states, coil/device reads, ownership mark, health wear, and
  feet-ground shadow separation; all mechanics and network identifiers remain
  unchanged.
- Desktop live Sanctum plus desktop/narrow specimen review completed without
  browser diagnostics, and the full 146-check verification remained green.
- P3 Charge/Light presentation is implementation-complete: all four live Nico
  spells and their phase board pass 147 checks, recursive syntax, normal
  Sanctum browser smoke, and clean browser diagnostics without rule changes.
  Hands-on held-input cast capture remains before P3 is accepted; P4 is frozen.
