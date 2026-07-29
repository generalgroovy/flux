# HEX agent memory

## 2026-07-26 — FLUX 0.34.3 native Windows/Linux runtime verification

- **Observed Windows failures:** PowerShell resolved `npm` to an unsigned
  `npm.ps1` shim under the host execution policy, and signal-based server
  shutdown could not run Node's graceful SIGTERM handler on Windows. The live
  WebSocket lifecycle therefore timed out after all 92 deterministic/browser
  checks passed.
- **Implemented solution:** The Windows updater/launcher now invokes
  `npm.cmd` explicitly. Registered source servers store a separate shutdown
  token and accept it only through a loopback-only POST endpoint; the cleanup
  tool uses that path on every OS. The live lifecycle test uses the existing IPC
  shutdown contract, and a Windows/Ubuntu GitHub Actions matrix runs the full
  suite plus native launcher syntax checks. Repository attributes keep shell
  and PowerShell line endings stable across checkouts.
- **Verification:** Native Windows passed 95/95 tests, recursive JavaScript and
  PowerShell syntax checks, the production dependency audit with zero findings,
  and a complete NSIS build at `dist/FLUX-Arena-0.34.3-win-x64.exe`. Linux
  behavior remains covered by the unchanged server protocol plus the Ubuntu CI
  lane.

## 2026-07-26 — HEX 0.13.0 race matrix and spatial arena atlas

- **Player-facing problem:** Race was not selectable, selection did not explain
  tradeoffs before commitment, and arenas appeared as unrelated cards rather
  than locations in a coherent world-selection surface.
- **Implemented solution:** Added twelve validated named races with explicitly
  paired boons/drawbacks bounded to 0.9–1.1 across health, speed, Flux, and FLOW.
  Race identity is server-owned, survives joins/rematches/respawns, appears in
  HUD and field information, and can combine with every complete agent without
  replacing its kit. Local players use horizontally scrollable race columns
  above the agent grid; remote identity adds the same race selection. Race and
  agent hover text exposes tradeoffs, discipline, style, and role. Added region,
  scale, and atlas coordinates to every playable arena and replaced the map card
  row with a responsive spatial atlas whose nodes remain actual selectors.
- **Scope discipline:** Twelve characters per class and twelve multi-scale race
  regions require dozens of complete mechanics and a camera/streaming model;
  neither is represented through fake nodes or stat-reskinned agents. The next
  map slice must prove large-map camera, rotations, sub-region boundaries, spawn
  density, and authoritative snapshot budgets with one complete region first.
- **Verification:** Final phased `npm test` passed 47/47, including race
  authority/persistence, browser navigation, all combat combinations, dynamic
  geometry, multiplayer lifecycle, and the eight-agent soak. Source/shell syntax
  and diff checks passed. A live 0.13.0 server returned valid health plus HTTP
  200 for the shell and game module, then shut down cleanly. Physical atlas
  layout, horizontal race navigation, hover density, and race feel remain the
  Linux/Windows desktop acceptance pass.

## 2026-07-26 — HEX 0.12.0 Flux commitments and seamless lobby links

- **Player-facing problem:** Element powers were cooldown-only, leaving no
  shared magical resource read; the revised discipline vocabulary lacked VEIL
  and NULL mechanics; and lobby hosts shared a code without an immediate link.
- **Implemented solution:** Migrated the visible working identity to HEX — Hunt.
  Evade. eXecute. Added independently tuned Flux with costs on special, defense,
  and character mobility, delayed recovery, dry feedback, HUD state, bot-safe
  authority, reset semantics, and invariant coverage. Primary fire and universal
  FLOW remain available while dry. Mapped the eight complete fighters to EMBER,
  TIDE, GALE, STONE, VOLT, VEIL, PRISM, and NULL. VEIL now plants a readable
  decoy and swaps on recast; NULL deletes nearby fields during its paid special;
  Gale deflects projectiles and Tide can redirect or douse Ember. Hosting now
  supports an authoritative hazards toggle and produces a copyable auto-join
  URL with query-link startup handling.
- **Scope discipline:** Twelve races, forty-eight race characters, eighty spells,
  skill forests, Battle Royale, and combinable roguelike rules are product-scale
  expansions. They remain acceptance-driven backlog work instead of visible
  placeholders; the next slice should prove one race matchup and one meaningful
  knowledge branch end to end.
- **Verification:** Final phased `npm test` passed 46/46. Pure/browser tests,
  live networking, and destructive server cleanup now run as separate processes
  so cleanup cannot terminate another test server; all coverage remains enabled.
  Syntax and diff checks passed. A live 0.12.0 server
  returned valid health and HTTP 200 for an auto-join URL and game module, then
  shut down cleanly. The smoke also exposed an occupied-port stack trace; startup
  now reports that condition concisely. Cross-device link reachability, Flux
  feel, audio, and visual density remain physical desktop acceptance items.

## 2026-07-26 — DIFF 0.11.1 frame recovery and elemental disciplines

- **Player-facing problem:** A reported wall-impact sequence could leave the
  avatar invisible and make restart appear ineffective. Simulation wall stress
  remained finite, but any browser canvas exception terminated the animation
  callback before scheduling its successor, so state could reset without ever
  painting again. Movement also had two overlapping trail treatments.
- **Implemented solution:** The next frame is now scheduled before work begins;
  presentation faults are logged, visibly rate-limited, and recover on the next
  frame so keyboard and pause-menu restart remain usable. Entity drawing resets
  opacity/compositing explicitly. Consolidated trails into one subtle history
  line gated and weighted by real speed. Named the eight complete disciplines
  GALE, STONE, FROST, SPARK, FLAME, FORCE, TIDE, and PRISM; FORCE now bends
  movable fields while STONE geometry resists it.
- **Verification:** Added a synthetic canvas-loss browser regression proving a
  subsequent frame renders and the existing restart path remains active. Final
  `npm test` passed 44/44, including all element combinations, dynamic walls,
  browser navigation/recovery, authoritative networking, cleanup integration,
  all-agent/map/mode stress, and the eight-agent two-minute soak. Syntax and
  diff checks passed; a live 0.11.1 server returned valid health and HTTP 200,
  then shut down cleanly. Physical browser play remains the external acceptance.
- **Recommended next task:** Add a tiny optional reaction laboratory with
  movable field emitters, then author a complete Shade or Bloom agent rather
  than exposing incomplete elements.

## 2026-07-26 — DIFF 0.11.0 physical element fields

- **Player-facing problem:** Character powers did damage or displacement but did
  not persistently alter routes, combine into readable reactions, or establish
  elements as a core spatial decision system. High-speed movement also lacked a
  subtle trace for opponents to read.
- **Implemented solution:** Declared wind, earth, ice, lightning, fire, and water
  affinities plus explicit non-element gravity/ballistics edges. Specials now
  author bounded authoritative fields: force channels, dynamic collision walls,
  slippery ground, short interruption/conduction, pulsed burning terrain, and
  allied FLOW/cleanse water. Added wind→fire carry, water→fire douse, fire→ice
  melt, ice→water freeze, lightning→water conduct, and explosion→earth shatter;
  explosion remains a reaction mechanic rather than an element. Fields combine
  hue with geometry, marks, audio signatures, and comic reaction callouts. Agent
  velocity now drives a restrained directional trail.
- **Verification:** Final `npm test` passed 43/43, including deterministic
  field/reaction coverage, all content combinations, the eight-agent two-minute
  soak, browser shell, authoritative remote lifecycle, and server cleanup. The
  first final run exposed that cleanup and networking integration files could
  race when parallel because both register the same checkout; test-file
  concurrency is now one, preserving every check without cross-test process
  termination. All source/shell syntax and diff checks passed. A live 0.11.0
  server returned its health payload and HTTP 200 for the shell and game module,
  then shut down cleanly. Physical audio/visual/feel acceptance remains pending
  on the installed Linux and Windows launchers because no browser executable is
  available in this runtime.
- **Recommended next task:** Add optional short element trials that teach one
  interaction through movement and observation, then add destructible frozen
  environment props without reducing aim or FLOW importance.

## 2026-07-26 — DIFF 0.10.0 universal FLOW movement

- **Player-facing problem:** Universal movement ended at ordinary acceleration
  and one character mobility button, leaving neutral positioning too shallow
  and giving the introduction no movement mastery to teach.
- **Implemented solution:** Added a validated shared FLOW resource with a
  sustained sprint, momentum-preserving hop, short remembered wall contact, and
  faster directional wall kick. Every option has explicit cost, cooldown or
  recovery delay, bot support, remote-command ownership, a non-color-only HUD
  meter, keyboard/gamepad controls, arena feedback, and a behavior-driven first
  training read. Character mobility remains a separate tactical commitment.
- **Verification:** `npm test` passed 40/40, including new deterministic sprint,
  recovery, hop, wall-kick, tutorial-ownership, full combination, soak, browser
  shell, networking, and server-cleanup coverage. JavaScript syntax checks also
  passed. A live 0.10.0 server returned its valid health payload and HTTP 200 for
  the shell and game module before clean shutdown. One preceding parallel test
  run reported process-level failures for both live-server files without
  assertion detail; both passed immediately in isolation and the full 40-test
  rerun passed. No browser executable is installed, so physical feel, gamepad,
  color, and layout acceptance remain required on the desktop launchers.
- **Recommended next task:** Tune FLOW through hands-on play, then add one
  authored comic action-callout vocabulary before introducing a small,
  deterministic pair of interacting elemental abilities.

## 2026-07-26 — Safe server cleanup and self-updating desktop launchers

- **Player-facing problem:** Repeated test launches could leave occupied ports,
  and testing from a desktop icon was not available on either target desktop OS.
- **Implemented solution:** DIFF servers now register PID, checkout, port,
  version, and an unguessable instance token in the OS temp directory and clean
  the record on shutdown. `npm run stop` verifies the live health token before
  signaling only servers from this checkout. Added an opt-in browser handoff,
  a validated Linux desktop-entry installer, and native PowerShell update/test/
  launch plus Windows shortcut installers.
- **Verification:** Deterministic server registration/cleanup integration,
  Linux shell and desktop-entry validation, JavaScript syntax, and the complete
  regression suite. PowerShell execution remains a Windows acceptance item
  because PowerShell is unavailable in this Linux runtime.
- **Recommended next task:** Add one universal movement resource with visible
  commitment and counterplay, then teach it through FIRST CONTACT.

## 2026-07-26 — DIFF 0.9.3 truthful remote quality diagnostics

- **Player-facing problem:** The remote HUD presented snapshot age as latency,
  so players and testers could not distinguish a healthy connection from
  delayed, jittery, lossy, or stale delivery.
- **Implemented solution:** Added bounded application-level probes outside match
  authority, a pure rolling diagnostic model, and a compact remote readout with
  measured round-trip latency, inter-sample jitter, recent probe loss, snapshot
  staleness, and explicit GOOD/FAIR/POOR/MEASURING text states. Probe sequences
  are validated and remain under the existing transport rate ceiling.
- **Tests passed:** 37/37, including deterministic good/loss/expiry model
  coverage, live probe echo, browser controller, authoritative lobby lifecycle,
  all content combinations, and the eight-agent soak.
- **Recommended next task:** Add safe server cleanup and self-updating Linux and
  Windows desktop launch surfaces, then deterministic adverse-network controls.

## 2026-07-26 — Branch-aware pull-and-run handoff

- **Player-facing problem:** The safe launcher always selected `main` in
  `~/Projects/diff`, while this system runs the newer verified build from
  `/home/otp/Projects/outskilled` on `agent/prototype-loop`.
- **Implemented solution:** Added a validated branch argument (with
  `DIFF_BRANCH` fallback) across
  clone, fetch, switch, tracking, and fast-forward pull operations; documented
  the exact local command; generalized the GitHub CLI install hint; and ignored
  Aider's local history/cache artifacts so they remain on disk without falsely
  making the guarded checkout dirty.
- **Verification:** Shell syntax, invalid-branch rejection, full deterministic
  suite, and an end-to-end clean-checkout pull/test/server-ready smoke.
- **Recommended next task:** Complete the physical browser and two-device 0.9.2
  acceptance passes recorded in the release backlog.

## 2026-07-26 — DIFF 0.9.2 first-contact clarity and arena atmosphere

- **Player-facing problem:** FIRST CONTACT described a four-action language but
  never verified the character special, and its single rotating sentence gave
  weak progress feedback. Fixed-aspect arenas left unused display space as a
  flat void, making presentation feel less authored on non-16:9 screens.
- **Implemented solution:** Reworked onboarding into three compact behavioral
  reads with a persistent, non-color-only checklist: move/fire, mobility/defense,
  then special commitment under live pressure. The deterministic simulation now
  records and confirms all four actions and emits explicit step/completion
  feedback. Added validated per-map floor, void, grid, and accent palettes plus
  restrained ambient overscan lines that fill the physical canvas while keeping
  competitive map bounds and visibility unchanged for local and remote play.
- **Files changed:** `src/content.mjs`, `src/match.mjs`, `src/game.mjs`,
  `index.html`, `styles.css`, `tests/match.test.mjs`,
  `tests/game-dom.test.mjs`, release/version files, `README.md`, backlog, and
  this memory.
- **Commands run:** `npm ci`; `npm test` with localhost WebSocket access;
  syntax checks for all source/server modules; shell syntax checks; diff checks.
- **Tests passed:** 35/35, including the real DOM/canvas controller, explicit
  three-beat four-action tutorial progression and bot-ownership isolation, all 160 content combinations,
  eight-agent soak, and complete WebSocket lobby/reconnect/spectator coverage.
- **Known limitations:** No browser executable is installed in this runtime, so
  final color, density, feel, gamepad, and physical multiplayer judgment still
  require the Garuda/Windows acceptance pass.
- **Recommended next task:** Add deterministic latency/jitter/loss simulation
  diagnostics and an in-game network quality read before expanding content.

## 2026-07-25T18:10:00Z — DIFF 0.9.1 actionable front end and agent identity

- **Player-facing problem:** The first external play pass reported that agents
  felt too large and visually interchangeable, only the introduction appeared
  launchable, menu content did not feel actionable, and there was no toggleable
  in-match information surface.
- **Implemented solution:** Reduced all eight agent collision bodies from the
  old 21-unit circle to bounded 17–19.5-unit profiles and added eight unique,
  facing-oriented geometric silhouettes plus persistent glyph identities.
  Added direct home and ruleset-card launch actions for every mode, agent/map
  actions that update the match builder, a sticky deployment summary/action,
  and explicit validation for all main-menu routes. Added a non-pausing live
  field panel on the HUD, toggled by its button or `F1`, with objective, round,
  arena, health, role, complete kit, and controls. Versioned the health contract
  as 0.9.1 so an old 0.9 server cannot be reused. Added a dirty-tree-safe
  `scripts/test-changes.sh` that installs locked dependencies with a disposable
  cache, checks syntax, runs the full suite, chooses a free port, and launches
  the tested build.
- **Files changed:** `src/content.mjs`, `src/game.mjs`, `index.html`,
  `styles.css`, `tests/game-dom.test.mjs`, `tests/match.test.mjs`,
  `tests/network.test.mjs`, `scripts/serve.mjs`,
  `scripts/pull-and-run.sh`, `scripts/test-changes.sh`, `package.json`,
  `package-lock.json`, `README.md`, `.agent/backlog.md`, and this file.
- **Commands run:** Baseline and repeated `npm test`; syntax checks; full
  `scripts/test-changes.sh` path; HTTP health/static/404 smoke on port 8766.
- **Tests passed:** 33/33. The browser controller test now opens all seven menu
  panels, confirms Host/Join actions are live, launches introduction plus duel,
  control, PvPvE, and PvE from visible UI actions, opens/closes field info,
  selects VOLT and CROWN from their overview cards, starts local 2P, renders,
  pauses, and resets. Existing 160-combination and two-minute eight-agent stress
  coverage remains green. Health returned DIFF 0.9.1/protocol 2; index, game,
  and CSS returned 200; a missing route returned 404.
- **Tests failed and fixed:** Linkedom does not update `:checked` from radio
  properties like a browser, exposing an avoidable selector dependency; choice
  reads now use explicit checked properties and selections clear their group.
  Exercising the online menu initially allowed a real asynchronous fetch after
  the DOM test ended; the test now owns a deterministic lobby response. The
  first full script run could not write the runtime's `/root/.npm`; the script
  now uses a disposable temp cache and its complete second run reached the
  server before the intentional test timeout stopped it.
- **Known limitations:** No browser executable is installed in this runtime, so
  final pixel/feel judgment for the new silhouettes, responsive layout, and
  pointer interaction still requires the user's Garuda/Windows play pass.
- **Recommended next task:** Use the external playtest notes to tune silhouette
  scale and HUD density, then run a real two-device remote lobby soak.

## 2026-07-25T17:22:49Z — DIFF 0.9 live lobby continuity

- **Player-facing problem:** Remote sessions were lost permanently when a
  socket dropped, and live matches could not be watched without consuming and
  controlling a player slot.
- **Implemented solution:** Added a 30-second authoritative reservation window
  with opaque reconnect tokens stored only in the local browser. Reconnecting
  rebinds the new socket to the exact entity and match state, resets input
  sequencing, and rotates the bearer token. Host migration remains immediate
  when another connected player exists. Added eight read-only spectator slots
  per lobby; observers receive the same snapshot stream but own no entity,
  cannot send input or change agents, do not consume player capacity, and
  cannot inherit host authority. The lobby browser now exposes Join and Watch,
  reconnect recovery is discoverable, observer HUD state is explicit, and
  playerless lobbies close instead of stranding watchers. Bumped the network
  contract to DIFF 0.9 / protocol 2 so the launcher cannot reuse a stale 0.8
  process.
- **Files changed:** `src/lobbies.mjs`, `scripts/serve.mjs`, `src/game.mjs`,
  `index.html`, `styles.css`, `tests/lobbies.test.mjs`,
  `tests/network.test.mjs`, `scripts/pull-and-run.sh`, `package.json`,
  `package-lock.json`, `README.md`, `.agent/backlog.md`, and this file.
- **Commands run:** `npm test`; targeted lobby/network tests; syntax checks for
  the lobby, browser, and server modules.
- **Tests passed:** 33/33. New coverage verifies exact reconnect identity and
  health/state continuity, token rotation, expiry cleanup, zero-capacity-cost
  observers, rejected spectator input/agent mutations, snapshot delivery,
  playerless-lobby cleanup, and real WebSocket disconnect → host migration →
  reconnect with a second client and live observer.
- **Tests failed:** None in the full suite.
- **Known limitations:** Physical two-device latency and browser/gamepad feel
  still require the external Garuda/Windows acceptance pass. Reconnect
  reservations are intentionally server-memory-only and expire after 30
  seconds; a server restart ends them.
- **Recommended next task:** Add configurable input remapping plus deterministic
  latency, jitter, and packet-loss diagnostics before expanding PvPvE content.

## 2026-07-25T16:06:41Z — DIFF 0.8 complete arena and remote-lobby pass

- **Player-facing problem:** The shipped fundamentals build had one agent and one
  target course; dash/wall contact could make the player disappear, dead render
  order could hide later entities, reset was not reliably reachable, and
  Host/Join were non-functional placeholders.
- **Implemented solution:** Replaced the superseded course with one
  server-compatible fixed-tick match engine. Added a professional main menu,
  immediate/skippable introduction, solo/local/remote formats, eight distinct
  complete agents, four maps, duel/control/PvPvE/PvE modes, bots, objectives,
  waves, overtime, procedural feedback, settings, gamepad support, and fresh
  reset ownership. Movement uses bounded swept collision, dash ends safely on
  walls, coincident units separate deterministically, state/render finiteness is
  enforced, and every renderer save is restored per entity. Added public/private
  WebSocket lobbies with discovery, code join, join-in-progress, protected
  spawns, validated sequenced commands, server snapshots, client reconciliation,
  rate limits, disconnect cleanup, host migration, and rematches.
  The launch health contract is versioned, so a stale DIFF process cannot be
  mistaken for the current lobby-capable server; the launcher selects a new
  port instead.
- **Files changed:** Added `.gitignore`, `package-lock.json`,
  `src/content.mjs`, `src/match.mjs`, `src/lobbies.mjs`,
  `tests/game-dom.test.mjs`, `tests/match.test.mjs`,
  `tests/lobbies.test.mjs`, and `tests/network.test.mjs`; rebuilt `index.html`,
  `styles.css`, `src/game.mjs`, `scripts/serve.mjs`,
  `scripts/pull-and-run.sh`, `package.json`, and `README.md`; removed the
  disconnected legacy config/session/target-course modules and tests.
- **Commands run:** Locked npm install; production and full `npm audit`;
  syntax checks for every JavaScript module; CSS structure validation;
  `bash -n scripts/pull-and-run.sh`; repeated targeted and full `npm test`;
  all-interface remote server smoke; isolated fresh Git clone → `npm ci` →
  tests → HTTP-ready launcher smoke.
- **Tests passed:** 29/29. Coverage includes the actual DOM/canvas controller,
  menu/play/pause/reset/local-2P flow, 160 agent/map/mode combinations, repeated
  wall/corner dash and blink obstruction, coincident units, all eight action
  kits, defense and projectile interactions, hazards/mines, death/round reset,
  overtime, control, cooperative wave escalation, join-in-progress, discovery,
  rate/stale-sequence validation, authoritative snapshots, disconnect/host
  migration, static-route allowlisting/security headers, a real two-client
  WebSocket integration, and an eight-agent two-minute deterministic soak.
  Both npm audits report zero vulnerabilities. Fresh-clone launcher reached
  `http://127.0.0.1:8799` and released the port after interruption. Remote bind
  served health, lobby API, and the app on `0.0.0.0`.
- **Tests failed and fixed:** Content validation rejected unsafe UNDERCURRENT
  spawns; phase timing test exposed an edge-of-window hit; the old shell test
  expected disabled networking; Survival lacked completion/escalation; dead
  render order stopped later entities; remote startup crashed when a restricted
  OS denied interface enumeration; npm audit rejected vulnerable `ws@8.18.3`.
  Each issue was corrected and its relevant suite rerun. `ws@8.21.1` is pinned.
- **Known limitations:** This runtime has no real browser executable, so visual
  balance, perceived input feel, physical gamepads, and audio still need
  hands-on play on the target machines. Internet reachability depends on the
  host's TCP port forwarding or VPN; NAT traversal and durable reconnect
  identity are not yet built.
- **Publication:** Staged from exact `main@a0d79ca` on an isolated release
  branch, read back all 19 shipped files byte-for-byte, confirmed three legacy
  files absent and a 21-commit fast-forward with zero commits behind, then moved
  `main` without force to `af8e9c87128de22e0eba05897e08b0ef4c423354`.
- **Recommended next task:** Run the Garuda Sway/Windows and real two-device
  acceptance passes before adding content.

## 2026-07-25T15:09:31Z — Reliable Sway launch handoff

- **Player-facing problem:** The launcher successfully updated, tested, and
  started DIFF, but its automatic `xdg-open` handoff reached a malformed desktop
  browser handler on Sway and emitted `bash: syntax error near unexpected token
  '('` after server startup.
- **Implemented solution:** Removed automatic desktop-handler execution from the
  launcher. After confirming HTTP readiness it now prints the exact local URL,
  tells the player to open it manually, and keeps the server attached to the
  terminal for predictable `Ctrl+C` shutdown.
- **Files changed:** `scripts/pull-and-run.sh`, `README.md`,
  `.agent/backlog.md`, `.agent/memory.md`.
- **Commands run:** `bash -n scripts/pull-and-run.sh`; `npm test`; syntax checks
  for every JavaScript source/server module; isolated local Git smoke from a
  fresh `main` clone through tests, server startup, HTTP-ready output, and
  interrupt cleanup.
- **Tests passed:** Shell syntax validation; 34/34 deterministic Node tests; all
  JavaScript syntax checks; isolated clone/update/launch reached
  `http://127.0.0.1:8765` and printed the manual-open instruction without
  invoking a desktop handler.
- **Tests failed:** The first smoke fixture accidentally used `master`, so its
  requested `main` clone correctly failed; the fixture was corrected and the
  complete smoke passed. No product assertion failed.
- **Known limitations:** The corrected launcher still needs to replace the older
  downloaded copy on the user's Garuda machine. This workspace has no usable Git
  object database, so it cannot publish the correction.
- **Recommended next task:** Run a hands-on browser playtest from the printed URL
  and address only observed feel/readability issues before Gate 2.

## 2026-07-25T15:05:00Z — Safe pull-and-run launcher

- **Player-facing problem:** The renamed private repository could fetch `main`
  but the legacy `agent/prototype-loop` branch had no upstream or
  `package.json`, causing both `git pull` and `npm start` to fail.
- **Implemented solution:** Added a Fish-invokable Bash launcher that creates
  and exclusively uses `~/Projects/diff`, leaving the legacy checkout untouched.
  It configures the renamed origin, fetches and checks out a tracking `main`,
  permits fast-forward updates only, verifies Node.js 20+, runs the deterministic
  suite, starts the server, waits for an HTTP-ready response, and opens the
  game. It preserves existing branches and refuses to hide dirty or diverged
  work.
- **Files changed:** `scripts/pull-and-run.sh`, `README.md`,
  `.agent/memory.md`, `.agent/backlog.md`.
- **Commands run:** `bash -n scripts/pull-and-run.sh`; `npm test`; JavaScript
  syntax checks; isolated local Git remote smoke covering first clone and repeat
  pull/run cycles.
- **Tests passed:** Shell syntax validation; 34/34 deterministic Node tests; all
  JavaScript syntax checks; both launcher cycles established tracking `main`,
  ran 34/34 tests, started the server, and reached HTTP-ready state.
- **Tests failed:** None.
- **Known limitations:** The runtime copy has no usable Git object database, so
  a live GitHub pull/branch transition cannot be executed here. The launcher
  therefore still needs its first run in the authenticated Garuda checkout.
- **Recommended next task:** Run the full gameplay loop in a desktop browser and
  tune or fix only issues observed in that playtest.

## 2026-07-25T14:55:52Z — Staged BREAKLINE fundamentals encounter

- **Player-facing problem:** Every target appeared at once, weakening the
  behavior-driven introduction and allowing the sentry to compete visually with
  the first aim lesson.
- **Implemented solution:** Authored three deterministic stages: close precision
  target, upper route target, then armed sentry. Each cleared stage has a 480 ms
  transition and spawn burst. Dormant targets remain faintly readable but
  non-colliding, damage-immune, and unable to attack. Objective/coaching state
  reflects transitions without blocking control. The result is a compact
  combined encounter using KITE's kit, cover, the seam, and return fire.
- **Files changed:** `README.md`, `index.html`, `styles.css`, `src/config.mjs`,
  `src/simulation.mjs`, `src/game.mjs`, `tests/simulation.test.mjs`,
  `.agent/backlog.md`, `.agent/memory.md`.
- **Commands run:** `npm test`; syntax checks for all source/server modules;
  temporary DOM/controller/canvas render smoke; local-server HTTP checks for
  the shell, stylesheet, and every browser module; missing-route `404` check;
  CSS block-balance and generated-junk checks; stale-name/TODO scan.
- **Tests passed:** 34/34 Node tests; all syntax checks; DOM/controller/canvas
  smoke; all six shipped HTTP routes returned `200`, the missing route returned
  `404`, CSS structure was balanced, and the junk/stale-name scan was clean.
  New tests cover inactive immunity, stage delay/activation events, contiguous
  stage validation, and pre-activation sentry suppression.
- **Tests failed:** None.
- **Known limitations:** No browser executable exists in this runtime, so
  hands-on visual layout, pointer aim, perceived timing, and game-feel validation
  remain a real release blocker. Git objects are also absent from the provided
  `.git` mount, so these changes cannot be committed or published here.
- **Recommended next task:** Run the full loop in a real desktop browser and
  tune/fix only issues observed in that playtest before beginning the local duel
  ruleset.

## 2026-07-25T14:53:03Z — BREAKLINE route hazard and spawn safety

- **Player-facing problem:** BREAKLINE had cover but no authored hazard creating
  route choice, and spawn clearance was implicit rather than validated.
- **Implemented solution:** Added the central seam: an idle lane marker, 720 ms
  amber warning, short red damage pulse, and cooldown. Its geometry closes the
  direct mid rotation while preserving upper/lower routes. Hazard damage shares
  player immunity/death ownership with sentry fire. Added behavior coaching,
  reduced-flash-aware rendering, centralized timing/damage/geometry, and
  validation that the configured 150-unit safe spawn cannot overlap a hazard.
- **Files changed:** `README.md`, `index.html`, `src/config.mjs`,
  `src/simulation.mjs`, `src/game.mjs`, `tests/simulation.test.mjs`,
  `.agent/backlog.md`, `.agent/memory.md`.
- **Commands run:** `npm test`; syntax checks for all source/server modules;
  temporary DOM/controller/canvas render smoke.
- **Tests passed:** 31/31 Node tests; all syntax checks; DOM/controller/canvas
  smoke. New tests cover spawn clearance, both safe rotations, phase order, and
  bounded pulse damage.
- **Tests failed:** None.
- **Known limitations:** Browser-executable hands-on verification remains
  unavailable. Targets still appear simultaneously rather than forming a paced
  encounter sequence.
- **Recommended next task:** Stage BREAKLINE's precision, route, and sentry
  targets with short deterministic transitions and readable spawn feedback.

## 2026-07-25T14:48:55Z — Complete KITE action kit

- **Player-facing problem:** KITE had a primary and movement burst but no
  close-range commitment tool or active defensive expression, so the first
  character did not satisfy the fundamentals gate.
- **Implemented solution:** Added SHEAR, a short directional strike on
  `E`/right-click, and SLIP, a 160 ms `Q` projectile return. Both actions have
  centralized cooldown/range/damage tuning, explicit command/state ownership,
  dedicated HUD meters, coaching, Field Guide entries, and minimal arc/ring
  feedback. Reflected shots re-enter the normal player projectile pipeline and
  can damage/destroy targets. Arena completion now asks players to demonstrate
  SHEAR and VECTOR without making SLIP mandatory when movement or cover wins.
- **Files changed:** `README.md`, `index.html`, `styles.css`, `src/config.mjs`,
  `src/simulation.mjs`, `src/game.mjs`, `tests/simulation.test.mjs`,
  `tests/session.test.mjs`, `.agent/backlog.md`, `.agent/memory.md`.
- **Commands run:** `npm test`; syntax checks for all source/server modules;
  enhanced temporary LinkeDOM smoke that also executes one canvas render frame.
- **Tests passed:** 28/28 Node tests; all syntax checks; DOM controller and mock
  canvas render smoke. New tests cover SHEAR cone/range/cooldown, SLIP reflection,
  reflected damage ownership, defense cooldown, and completion gating.
- **Tests failed:** None.
- **Known limitations:** Browser-executable visual/play inspection is still
  unavailable. SLIP currently answers projectiles only by design; contact and
  future melee attacks require their own readable counterplay rules.
- **Recommended next task:** Add BREAKLINE's deterministic route hazard and
  verify the spawn remains safe while upper/lower rotations remain viable.

## 2026-07-25T14:42:19Z — First threat, damage, and death loop

- **Player-facing problem:** BREAKLINE had targets but no opposition, so cover,
  dash timing, health, failure, and retry had no combat meaning.
- **Implemented solution:** Armed the right target as a deterministic sentry
  that locks a clear red-line telegraph before firing a hostile projectile.
  Added hard-cover interception, player health, damage immunity, hit feedback,
  health HUD, lethal state ownership, failure presentation, frozen post-death
  simulation, and instant retry. The threat activates only after the player has
  demonstrated a hit, preserving the safe opening lesson.
- **Files changed:** `README.md`, `index.html`, `styles.css`, `src/config.mjs`,
  `src/simulation.mjs`, `src/game.mjs`, `tests/simulation.test.mjs`,
  `tests/session.test.mjs`, `.agent/backlog.md`, `.agent/memory.md`.
- **Commands run:** `npm test`; syntax checks for all source/server modules;
  temporary LinkeDOM menu interaction smoke; local server HTTP checks against
  `/` and `/src/simulation.mjs`.
- **Tests passed:** 25/25 Node tests; all syntax checks; DOM menu interaction
  smoke; HTTP shell/module checks returned `200 OK`. New tests verify full
  warning before fire, locked aim, hostile cover interception, simultaneous-hit
  immunity, lethal state/event ownership, and frozen post-death state.
- **Tests failed:** None.
- **Known limitations:** No browser executable is available for hands-on visual
  play inspection. KITE still needs a close-range secondary and active defense;
  the sentry is a controlled threat harness rather than a complete enemy.
- **Recommended next task:** Add KITE's close-range secondary plus a precisely
  timed projectile defense with visible cooldowns and counterplay.

## 2026-07-25T14:37:22Z — Dash integrity and professional front end

- **Player-facing problem:** Dashing could poison the player transform and make
  KITE disappear, while the build launched directly into an active arena with no
  product-level route to play, pause, configuration, controls, mechanics,
  character skills, maps, or future network modes.
- **Implemented solution:** Sanitized all direction and fixed-delta inputs,
  added a safe dash-direction fallback, isolated trail/player canvas state, and
  forced a fully opaque player draw. Added a deterministic session state machine
  and a responsive main menu with Play, paused-session actions, honest gated
  Host/Join panels, live persisted configuration, and a concise Field Guide for
  controls, mechanics, KITE/Needle/Vector, and BREAKLINE. Gameplay and its timer
  remain frozen outside the playing state.
- **Files changed:** `README.md`, `index.html`, `styles.css`, `package.json`,
  `src/config.mjs`, `src/session.mjs`, `src/simulation.mjs`, `src/game.mjs`,
  `tests/simulation.test.mjs`, `tests/session.test.mjs`,
  `.agent/backlog.md`, `.agent/memory.md`.
- **Commands run:** `npm test`; syntax checks for `src/config.mjs`,
  `src/session.mjs`, `src/simulation.mjs`, `src/game.mjs`, and
  `scripts/serve.mjs`; `npm start`; HTTP checks against `/` and
  `/src/game.mjs`; temporary LinkeDOM interaction smoke covering menu → play →
  pause → resume → menu → configuration and setting persistence.
- **Tests passed:** 21/21 Node tests; all JavaScript syntax checks; local HTTP
  shell/module checks returned `200 OK`; the DOM controller smoke completed its
  full navigation path. New coverage stress-tests 12 simulated seconds of
  repeated dashes while checking a finite, in-bounds player on every tick.
- **Tests failed:** Initial temporary DOM smoke setup lacked the test library's
  `HTMLFormElement.elements` implementation; after adding the standards-shaped
  test shim, the application interaction smoke passed. No product assertion
  failed.
- **Known limitations:** This environment contains no browser executable, so
  visual pixel/layout inspection and hands-on pointer play remain unperformed.
  Git object data is not present in the provided `.git` mount, so history/status
  comparison and commit publication were unavailable in this iteration.
  Host/Join are intentionally inactive until Gate 2 has real authoritative
  networking.
- **Recommended next task:** Add a telegraphed sentry attack plus player health,
  damage, death, and instant retry to complete the first threat loop.

## 2026-07-25T14:05:37Z — DIFF fundamentals combat slice

- **Player-facing problem:** The first build only tested movement and carried the
  old Outskilled identity. It had no authored character/map identity, aiming,
  attack, dash, cover interaction, hit feedback, or combat objective.
- **Implemented solution:** Rebranded the game as **DIFF — Dodging Instinct.
  Fighting Finesse.** Added the KITE mobility duelist, BREAKLINE cover arena,
  fixed-tick pointer-aimed projectiles, swept hits, directional dash/cooldown,
  reactive destructible targets, obstacle collision, contextual non-blocking
  coaching, completion timing, feedback effects, and instant restart. Added a
  durable gate-ordered autonomous implementation prompt in `AGENTS.md`.
- **Files changed:** `AGENTS.md`, `README.md`, `index.html`, `styles.css`,
  `package.json`, `scripts/serve.mjs`, `src/config.mjs`,
  `src/simulation.mjs`, `src/game.mjs`, `tests/simulation.test.mjs`,
  `.agent/backlog.md`, `.agent/memory.md`.
- **Commands run:** `npm test`; `node --check src/config.mjs`;
  `node --check src/simulation.mjs`; `node --check src/game.mjs`;
  `node --check scripts/serve.mjs`; `node scripts/serve.mjs`; HTTP checks
  against `/` and `/src/game.mjs`; attempted Playwright browser smoke check.
- **Tests passed:** 13/13 Node simulation/configuration tests; syntax checks for
  all JavaScript modules; local HTTP smoke check returned `200 OK` and served
  the game module.
- **Tests failed:** The Playwright interaction/screenshot check could not start
  because this runtime has the Playwright package but no installed browser
  executable. This is an environment limitation, not a game assertion failure.
- **Known limitations:** No enemy attack, player health/death, secondary,
  defensive action, interactive tuning, local duel, or networking yet.
  Interactive browser play verification remains pending because the runtime has
  no browser executable.
- **Recommended next task:** Add one telegraphed sentry attack plus player
  health, damage, death, and instant retry to complete the first threat loop.

## 2026-07-25T13:24:06Z — Movement trial foundation

- **Player-facing problem:** The repository had no branches, commits, or playable
  project, so a player could not launch or experience Outskilled.
- **Implemented solution:** Added a dependency-free browser movement trial with
  responsive fixed-tick movement, four ordered floor signals, contextual
  first-use guidance, a completion timer, and immediate restart.
- **Files changed:** `index.html`, `styles.css`, `package.json`,
  `src/config.mjs`, `src/simulation.mjs`, `src/game.mjs`,
  `scripts/serve.mjs`, `tests/simulation.test.mjs`, `README.md`,
  `.agent/backlog.md`, `.agent/memory.md`.
- **Commands run:** `npm test`; `node --check src/config.mjs`;
  `node --check src/simulation.mjs`; `node --check src/game.mjs`;
  `node --check scripts/serve.mjs`; `npm start`; HTTP checks against `/` and
  `/src/game.mjs` with `curl`.
- **Tests passed:** 7/7 Node simulation tests; syntax checks for all JavaScript
  modules; local HTTP smoke check returned `200 OK` and served the game module.
- **Tests failed:** None.
- **Known limitations:** Keyboard movement is the only gameplay action; there is
  no attack, target reaction, damage, audio, or multiplayer yet. Browser smoke
  testing was limited to syntax, simulation, and HTTP launch checks because an
  interactive browser was not available for hands-on play verification.
- **Recommended next task:** Add one immediate primary attack and one reactive
  target with clear hit confirmation, while preserving the movement trial.

## 2026-07-26 — HEX old-world Flux identity migration

- **Player-facing problem:** The playable systems had moved toward Flux, races,
  and elemental geometry while the roster, modes, arenas, and interface still
  spoke in modern operator language. The conflicting identity obscured the
  intended magic-world fantasy.
- **Implemented solution:** Recast all eight shipped kits as named champions
  native to eight established peoples, with old-world roles, spell names, and
  biographies. Renamed every visible contest and arena without changing stable
  simulation identifiers. Champion choice now selects native ancestry by
  default while preserving ancestry as a deliberate build override. Reworked
  the primary shell toward aged parchment, woven banners, gilt bevels, serif
  display type, and pixel-crisp field rendering. Updated product guidance,
  documentation, browser assertions, and release metadata to HEX 0.14.0.
- **Compatibility:** Internal character, mode, map, launcher, health-product,
  and debug identifiers remain stable so saved settings, join URLs, remote
  protocol checks, and existing automation continue to work.
- **Commands run:** `rg` identity sweeps; `git diff --check`; syntax checks for
  `src/content.mjs` and `src/game.mjs`; `npm test`.
- **Tests passed:** 47/47 tests: 45 deterministic DOM/lobby/match/network-quality
  checks, the complete shipped-server network test, and isolated server cleanup.
- **Known limitations:** No browser executable is installed in this environment,
  so physical visual acceptance remains pending. Four arenas establish the
  world atlas but do not yet constitute the requested nested continent.
- **Recommended next task:** Make one existing arena the first fully illustrated
  nested territory: region lore, readable landmark silhouettes, scale-aware
  atlas zoom, and one environmental Flux interaction with deterministic tests.

## 2026-07-26 — HEX authored realm chart

- **Player-facing problem:** The renamed arenas still appeared as a neon
  technical grid and the atlas was only four floating cards. Neither conveyed an
  inhabited old-world magic setting or gave players memorable spatial anchors.
- **Implemented solution:** Added validated terrain, lore, heraldry, and landmark
  definitions to all four arenas. Rebuilt the atlas as an aged realm chart and
  exposed its authored place information through hover/focus and the map codex.
  Replaced the combat grid with sparse tile marks, regional landmark underlays,
  rune circles, weathered borders, and stone cover. Landmark art remains beneath
  the simulation layer and cannot imitate collision, hazards, or objectives.
- **Commands run:** syntax checks for `src/content.mjs` and `src/game.mjs`;
  `git diff --check`; focused DOM and deterministic match tests; `npm test`;
  clean `scripts/serve.mjs` launch on port 8113; HTTP health, shell, and module
  checks; clean server shutdown.
- **Tests passed:** 48/48 checks: 46 DOM/lobby/match/network-quality tests,
  including authored-place validation for every arena, plus the complete shipped
  server network test and isolated server cleanup.
- **Launch smoke:** Compatibility health reported ready at HEX 0.15.0; `/` and
  `/src/game.mjs` returned `200 OK` with the shipped security headers.
- **Known limitations:** The realm chart has four complete destinations but no
  zoom navigation yet; The Fracture is the selected first nested region. Physical
  visual acceptance remains pending because this environment has no browser.
- **Recommended next task:** Add scale-aware chart zoom into The Fracture and one
  new small Sundered Road sub-map with its own route decision and deterministic
  spawn/combination stress coverage.

## 2026-07-26 — Complete Fracture region ladder

- **Player-facing problem:** The realm chart had authored destinations but no
  actual hierarchy, and The Fracture existed only as a duel arena despite being
  presented as a world region.
- **Implemented solution:** Added realm/Fracture chart depth controls and three
  complete battlegrounds beside Sundered Road: Ashen Ford (small), Pilgrim Steps
  (medium), and Oathscar Vale (large). Each has distinct route grammar, lore,
  heraldry, cover, safe spawn anchors, landmarks, objective placement, and
  restrained telegraphed hazards where appropriate. All seven maps populate
  local and remote selectors from the same validated definitions.
- **Commands run:** syntax checks for content and controller; `git diff --check`;
  focused DOM and deterministic match suites; `npm test`; clean server launch on
  port 8114; HTTP health/shell/module smoke; clean shutdown.
- **Tests passed:** 49/49 checks. Realm/region navigation and selection, Fracture
  scale completeness, all seven maps across the full deterministic character/mode
  interaction matrix and combat soak, authoritative network lifecycle, and
  isolated server cleanup all passed.
- **Launch smoke:** Compatibility health reported ready at HEX 0.16.0; `/` and
  `/src/game.mjs` returned `200 OK` with shipped security headers.
- **Known limitations:** Hands-on visual and route tuning remains pending because
  no browser executable is available here. Other world regions intentionally
  remain single destinations until this hierarchy receives real-player tuning.
- **Recommended next task:** Hands-on tune Fracture routes, hazard cadence, and
  atlas legibility; then add the first movement-reactive environmental Flux
  shrine as a fully counterable objective rather than passive map power.

## 2026-07-26 — Movement-reactive Broken Covenant shrine

- **Player-facing problem:** Flux recovery was almost entirely passive, so map
  mastery and universal movement could not create a deliberate resource swing.
- **Implemented solution:** Added a validated, simulation-owned shrine to the
  exposed center of Oathscar Vale. A fresh crossing above 610 movement speed
  restores up to 24 missing Flux, then visibly locks for everyone for seven
  seconds. Full-Flux passes do not waste the shrine. It grants no health, damage,
  affinity bonus, control lock, or invulnerability. Added distinct world art,
  countdown, comic callout, audio cue, particles, codex metadata, and guide text.
- **Commands run:** Focused shrine/match test; syntax checks for content,
  simulation, and controller; `git diff --check`; `npm test` twice around an
  isolated network rerun; clean server launch on port 8115; HTTP health, shell,
  and module smoke; clean shutdown.
- **Tests passed:** 50/50 on the final full run, including shrine activation,
  bounded reward, shared cooldown, no passive damage, invariant stability,
  seven-map stress, authoritative networking, and isolated cleanup. The first
  full run had one process-level network-test failure with no assertion detail;
  the same network test passed immediately in isolation and the entire suite then
  passed cleanly, so this is recorded as an intermittent harness event rather
  than hidden.
- **Launch smoke:** Compatibility health reported ready at HEX 0.17.0; `/` and
  `/src/game.mjs` returned `200 OK` with shipped security headers.
- **Known limitation:** The threshold/reward/cooldown need hands-on play tuning;
  no browser executable is installed in this environment.
- **Recommended next task:** Add a short optional First Rite shrine trial that
  teaches sprint-versus-dash threshold reads without adding another text step.

## 2026-07-26 — Universal counter-strafe expression

- **Player-facing problem:** Acceleration gave movement weight, but reversing
  direction could feel uniformly sluggish and offered no explicit mastery point
  for baiting shots or changing a peek.
- **Implemented solution:** Added centralized counter-strafe tuning. A genuine
  reversal against meaningful velocity gains a bounded 1.7× control rate, while
  perpendicular steering and ordinary acceleration remain unchanged. Ice still
  scales the resulting control down. Added a speed-gated, cooldown-throttled
  simulation event with concise comic/audio feedback and guide text.
- **Commands run:** Syntax checks for content, simulation, and controller;
  `git diff --check`; focused match suite; `npm test`; clean server launch on
  port 8116; HTTP health/shell/module smoke; clean shutdown.
- **Tests passed:** 51/51 checks, including tuning validation, true-reversal
  detection, faster momentum cut, cue throttling state, seven-map combination
  stress, authoritative networking, and isolated cleanup.
- **Launch smoke:** Compatibility health reported ready at HEX 0.18.0; `/` and
  `/src/game.mjs` returned `200 OK` with shipped security headers.
- **Known limitation:** The multiplier needs hands-on mouse/keyboard and gamepad
  tuning; no browser executable is installed here.
- **Recommended next task:** Make hop landings preserve a bounded fraction of
  entry momentum and test hop-to-counter-strafe, hop-to-wall-kick, and ice chains.

## 2026-07-26 — Bounded hop momentum carry

- **Player-facing problem:** Hops replaced all incoming velocity with a fixed
  vector, flattening diagonal escape routes and making fast movement chains feel
  disconnected.
- **Implemented solution:** Hops now retain 35% of velocity perpendicular to the
  chosen hop direction, hard-capped at 180 units. The forward hop and wall-kick
  speeds remain fixed, FLOW costs remain unchanged, and carry cannot recursively
  stack beyond the cap. Carry state is authoritative, finite, and reset on spawn.
  Added guide text and centralized validation.
- **Commands run:** Syntax checks for content and simulation; `git diff --check`;
  focused match suite; `npm test`; clean server launch on port 8117; HTTP
  health/shell/module smoke; clean shutdown.
- **Tests passed:** 52/52 checks, including lateral carry, hard speed bound,
  reset state, invariants, seven-map stress, authoritative networking, and
  isolated cleanup.
- **Launch smoke:** Compatibility health reported ready at HEX 0.19.0; `/` and
  `/src/game.mjs` returned `200 OK` with shipped security headers.
- **Known limitation:** Hands-on animation/feel tuning remains pending because no
  browser executable is installed here.
- **Recommended next task:** Add a landing micro-window that permits one readable
  counter-strafe cancel without reducing hop commitment or enabling spam.

## 2026-07-26 — Universal committed ground slide

- **Player-facing problem:** Sprint, hop, wall kick, and character mobility left
  no universal low-line commitment for crossing exposed space or changing the
  opponent's aim height and timing.
- **Implemented solution:** Sprint+hop now starts a ground slide only after 250
  speed. It costs 22 FLOW, travels at 720 for 0.3 seconds, steers at 32%, and has
  a 0.78-second cooldown. Holding the chord suppresses accidental follow-up hops;
  cover ends the slide with an explicit impact. Added authoritative state,
  respawn reset, validation, silhouette squash, audio/comic cues, controls,
  guide copy, and First Rite instruction.
- **Commands run:** Syntax checks for content, simulation, and controller;
  `git diff --check`; focused match suite; `npm test`; clean server launch on
  port 8118; HTTP health/shell/module smoke; clean shutdown.
- **Tests passed:** 53/53 checks, including entry threshold, FLOW cost, hop
  exclusion, committed steering, cover termination, seven-map stress,
  authoritative networking, and isolated cleanup.
- **Launch smoke:** Compatibility health reported ready at HEX 0.20.0; `/` and
  `/src/game.mjs` returned `200 OK` with shipped security headers.
- **Known limitation:** Hands-on feel and controller-chord tuning remain pending
  because no browser executable is installed here.
- **Recommended next task:** Add one landing micro-cancel after a completed hop,
  then validate slide→hop, hop→counter-strafe, and wall-kick→slide chains as a
  single bounded movement grammar.

## 2026-07-26 — Full Wyrmbound culture package

- **Player-facing problem:** The twelve race rows were bounded build modifiers,
  but no expansion race demonstrated the complete bar for mechanical identity,
  champion expression, elemental language, world placement, and network support.
- **Implemented solution:** Added Wyrmbound as a thirteenth ancestry. Their scales
  reduce forced movement by 14% in exchange for 6% FLOW and 2% speed. Added Yrsa
  Rimewing, a complete Tide/Frost outrider with paired shards, a frost-field cone,
  precise counter, armored charge, and unique wing silhouette. Added Emberpeak's
  Wyrmfall Aerie with authored routes, safe spawns, rime vent, lore, landmarks,
  heraldry, atlas placement, and objective. All selectors and remote definitions
  derive from the same validated content.
- **Commands run:** Syntax checks for content, simulation, and controller;
  `git diff --check`; focused match suite; `npm test`; clean server launch on
  port 8119; HTTP health/shell/module smoke; clean shutdown.
- **Tests passed:** 54/54 checks, including thirteen-race bounds, resistance
  versus equal raw damage, explicit FLOW weakness, ice reactions, all nine
  champion kits, eight-map stress, authoritative networking, and cleanup.
- **Launch smoke:** Compatibility health reported ready at HEX 0.21.0; `/` and
  `/src/game.mjs` returned `200 OK` with shipped security headers.
- **Known limitation:** Wyrmbound resistance and Yrsa's kit need hands-on matchup
  tuning; no browser executable is installed here.
- **Recommended next task:** Complete movement grammar testing, then make Yrsa the
  first champion to receive the production passive/tactical/ultimate schema used
  for later roster expansion.

## 2026-07-26 — One-use hop landing cut

- **Player-facing problem:** Hop carry produced expressive arcs, but the landing
  had no precise conversion point into grounded footwork.
- **Implemented solution:** A fully completed hop now opens a 110 ms landing
  window. One true counter-strafe during it gains 18% additional control and
  consumes the state immediately. The cut cannot cancel hop commitment, cannot
  repeat, and remains reduced on ice. Added authoritative/reset state, bounded
  tuning validation, comic/audio feedback, and guide copy.
- **Commands run:** Syntax checks for content, simulation, and controller;
  `git diff --check`; focused match suite; `npm test`; clean server launch on
  port 8120; HTTP health/shell/module smoke; clean shutdown.
- **Tests passed:** 55/55 checks, including full hop commitment, one-use landing
  cut, nine-champion/eight-map stress, authoritative networking, and cleanup.
- **Launch smoke:** Compatibility health reported ready at HEX 0.22.0; `/` and
  `/src/game.mjs` returned `200 OK` with shipped security headers.
- **Known limitation:** Hands-on latency and animation tuning remains pending
  because no browser executable is installed here.
- **Recommended next task:** Add deterministic chain tests for slide→hop,
  wall-kick→slide, hop→landing-cut, and shrine traversal, then lock the movement
  grammar before expanding champion ultimates.

## 2026-07-26 — Adaptive First Rite FLOW chain

- **Player-facing problem:** The opening rite advanced after only one sprint tick
  and one hop, leaving the new committed slide untaught and presenting the whole
  instruction at once.
- **Implemented solution:** The same first of four reads now observes a genuine
  sprint, completed slide, and separate hop. The live prompt adapts to the next
  missing behavior, while skip remains immediate and bot actions remain excluded.
  Slide and hop cannot overlap, preventing accidental completion through a held
  chord.
- **Commands run:** Syntax checks for simulation and controller; `git diff
  --check`; focused match suite twice around the repaired flag; `npm test`; clean
  server launch on port 8121; HTTP health/shell/module smoke; clean shutdown.
- **Tests passed:** 55/55 checks, including behavior order, real slide activation,
  separate hop, adaptive state, bot exclusion, expanded stress, networking, and
  cleanup.
- **Launch smoke:** Compatibility health reported ready at HEX 0.23.0; `/` and
  `/src/game.mjs` returned `200 OK` with shipped security headers.
- **Regression repaired:** The first implementation placed the slide-observed flag
  in sprint recovery; review caught it, moved it to successful slide start, and
  reran the complete focused suite.
- **Known limitation:** New-player observation remains pending because no browser
  executable or external playtester is available here.
- **Recommended next task:** Add the movement-chain regression matrix, then begin
  the production passive/tactical/ultimate schema with Yrsa as the first pilot.

## 2026-07-26 — Locked universal movement-chain boundaries

- **Player-facing problem:** Individual movement verbs were tested, but their
  transitions could still hide overlapping state or an unbounded chain exploit.
- **Implemented solution:** Added deterministic slide→hop, mobility-exclusion,
  held-input, commitment, and 600-tick adversarial speed/invariant coverage.
  Universal slide or hop can no longer begin under active character mobility;
  slides cannot be silently hop-cancelled, while completed slides route into hops.
- **Regression found and repaired:** The new matrix exposed universal states
  starting beneath character mobility. Both entry paths now reject the overlap.
- **Commands run:** Syntax and diff checks; focused chain test; initial sandboxed
  full suite; escalated full suite with loopback access; clean server launch on
  port 8122; HTTP health/shell/module smoke; clean shutdown.
- **Tests passed:** 56/56 checks with required loopback access, including chain
  matrix, commitment boundaries, speed ceiling, expanded stress, authoritative
  networking, and cleanup.
- **Environment diagnosis:** The first full run's server test failed because this
  turn's sandbox denied `listen(127.0.0.1)` with `EPERM`. A temporary port-retry
  idea was removed after direct diagnosis; the unchanged strict test passed under
  its project-scoped loopback permission.
- **Launch smoke:** Compatibility health reported ready at HEX 0.24.0; `/` and
  `/src/game.mjs` returned `200 OK` with shipped security headers.
- **Recommended next task:** Begin the production passive/tactical/ultimate
  schema with Yrsa as the first fully wired champion pilot.

## 2026-07-26 — Yrsa production champion contract

- **Player-facing problem:** Nine baseline kits were playable, but champion
  passives and ultimates had no production state, input, charge, telegraph, or
  network contract. Adding roster breadth before proving that layer would have
  multiplied incomplete behavior.
- **Implemented solution:** HEX 0.25.0 introduces a tactical alias while retaining
  the stable `special` wire field, match schema v2, an allowlisted ultimate
  command, bounded authoritative state, and the first fully authored pilot.
  Yrsa's **Ridgeline Hunt** turns a wall kick or landing cut into one 18%-faster,
  55%-tighter Rime Fangs cast without increasing damage. Dealing non-ultimate
  damage earns **The White Hunt**. At 100 charge, `F`/`H`/north button commits a
  fixed lane for 0.58 seconds at 38% ground speed, then releases five rime fangs
  and three shared ice fields. Cover clips the lane; Volt interruption cancels
  the spent cast; the resulting ice continues to use Ember, Tide, and Null's
  existing physical reactions. Ultimate damage cannot recharge the same cast.
- **Communication and usability:** Added conditional HUD state, charge and ready
  marks, an unambiguous dashed lane wedge and commitment bar, passive/readiness/
  cast/interruption comic and audio cues, complete controls, and passive/tactical/
  ultimate codex entries. The slot is forcibly absent for champions without a
  complete authored ultimate, so no broken input is exposed.
- **Authority and reliability:** Bots use the same command and charge rules;
  remote commands remain sanitized and sequence-owned by the server. Charge,
  channel, aim lock, passive window, fields, and projectiles are snapshot state.
  Review also explicitly versioned the new match schema and added the CSS hidden
  guarantee before release.
- **Commands run:** content/simulation/controller/server syntax checks; shell
  launcher syntax checks; `git diff --check`; focused match, DOM, and lobby
  suites; fully escalated `npm test`; clean server launch on port 8123; health,
  HTML, and module HTTP smoke with shipped security headers; clean shutdown.
- **Tests passed:** 60/60 checks: 58 DOM/lobby/match/network-quality checks, one
  live authoritative WebSocket lifecycle check, and one isolated server cleanup
  check. New coverage includes damage-neutral passive conversion, combat-only
  bounded charge, no self-recharge, aim lock, delayed resolve, field count,
  Volt cancellation, hidden/visible HUD state, codex discoverability, and remote
  ultimate authority.
- **Launch smoke:** Health reported ready at HEX 0.25.0/protocol 2; `/` and
  `/src/game.mjs` returned `200 OK` with CSP, COOP, no-referrer, nosniff, and
  frame-deny headers. The server stopped cleanly.
- **Known limitation:** No browser executable is installed in this environment,
  so hands-on feel, telegraph density, gamepad comfort, audio mix, and real-device
  remote prediction remain pending; the deterministic DOM/canvas harness passed.
- **Recommended next task:** Hands-on tune Yrsa where available; meanwhile author
  her mechanically opposed Wyrmbound counterpart as the second complete champion
  contract, proving a different passive/ultimate kind rather than cloning the
  line-volley implementation.

## 2026-07-26 — Opposed Wyrmbound pair: Varka Ashmaw

- **Player-facing problem:** Wyrmbound had one complete champion, but not the
  contrasting decision profile needed to prove that the new passive/ultimate
  contract could support a race roster without reskins.
- **Implemented solution:** HEX 0.26.0 adds Varka Ashmaw, Yrsa's oath-broken Ember
  counterpart. Cinder Tooth is an exact medium projectile. Pyre Furrow authors
  three short-lived, douseable fire fields. While Varka occupies allied fire,
  Pyre-Forged keeps the same 23 damage but trades 32% projectile speed for a 50%
  larger heavy spell and 2.1× knockback. Smoke Shed phases through a committed
  spell; Talon Vault recoils from the aimed threat. This creates direct-aim versus
  predictive-clash choices without an elemental damage bonus.
- **Ultimate and counterplay:** Combat damage earns The Ashen Crown. Its fixed
  distant target is shown for 0.72 seconds while Varka moves at 50% speed; six
  52-radius fire sigils sit on a 180-radius ring with validation-enforced open
  seams. Tide douses breaches, Gale redirects fire, Null clears the ring from its
  center, Volt cancels the spent windup, and cover clips target acquisition.
  Ultimate-authored fire cannot recharge the same meter.
- **Presentation and authority:** Added a unique oriented maw silhouette, active
  passive mark, element-colored HUD state, crown target line, six exact field
  previews, progress ring, distinct comic/audio feedback, codex/selection copy,
  bot use, remote command coverage, reset/repair state, and bounded validation.
- **Regression caught:** The first crown test expected its fire pulse one tick
  after the observation loop; the simulation had correctly pulsed during the
  post-cast ticks. The test observation window was corrected without changing or
  weakening gameplay.
- **Commands run:** syntax checks for content, match, controller, server, and
  shell launchers; `git diff --check`; focused Varka/crown/bot suites; combined
  DOM/lobby/match suite; fully escalated `npm test`; clean server launch on port
  8124; health, HTML, and module HTTP smoke; clean shutdown.
- **Tests passed:** 63/63 checks: 61 DOM/lobby/match/network-quality checks, one
  live authoritative WebSocket lifecycle check, and one isolated cleanup check.
  Coverage includes ordinary/tempered damage equality, projectile tradeoffs,
  allied-field ownership, Tide dousing, crown seam geometry, fire pulse, no
  ultimate self-charge, Null erasure, bot activation, DOM/codex discovery,
  ten-champion stress, and both ultimate kinds through remote authority.
- **Launch smoke:** Health reported HEX 0.26.0/protocol 2; `/` and
  `/src/game.mjs` returned `200 OK` with all shipped security headers, then the
  server stopped cleanly.
- **Known limitation:** No browser executable is installed here. Hands-on
  readability, audio mix, controller feel, and real-device remote prediction
  remain pending; deterministic DOM/canvas and network harnesses passed.
- **Recommended next task:** Hands-on tune the Yrsa/Varka matchup where available;
  meanwhile promote a third mechanically distinct champion to the production
  contract so Gate 2 has three complete high-depth matchup anchors before further
  roster multiplication.

## 2026-07-26 — Aerwyn reflection and trajectory contract

- **Player-facing problem:** Gate 2 needed a third complete champion whose reward
  came from reaction and aim expression rather than another damage or terrain
  conversion.
- **Implemented solution:** HEX 0.27.0 gives Aerwyn **Thread the Turn**: reflecting
  a hostile spell primes one Wind Needle for 1.4 seconds. The converted shot keeps
  22 damage, trades 8% speed for 0.58 seconds of live aim steering, and turns at a
  validated 3.4 radians/second ceiling. A later reflection cancels its guidance.
  Combat earns **The Turning Sky**, a cover-clipped 0.64-second target commitment
  that creates one 3.1-second shared vortex. Its explicit rotation bends each
  projectile once while preserving speed, applies bounded tangential force to all
  fighters, and carries overlapping Ember without dealing damage. Volt interrupts
  the windup and Null erases the resulting field.
- **Presentation and authority:** Added a vortex target disk, progress arc,
  directional field arrows, guided-shot fins, non-color glyphs, distinct Gale
  audio/comic feedback, ready copy, full field-guide/codex discovery, bot use, and
  the existing server-authoritative ultimate input/snapshot path.
- **Regression caught:** Full diff review found the guided-shot decoration placed
  in the movement-trail renderer, where its projectile variables were undefined.
  It was moved to projectile rendering before release. Two focused test setups
  were also moved clear of the central ruin and hostile Ember so they measured the
  intended vortex rules rather than incidental collision or damage.
- **Commands run:** syntax checks for all source/server modules and shell
  launchers; `git diff --check`; focused match, DOM, and lobby suites; `npm test`;
  clean server launch on port 8125; health, HTML, and module HTTP smoke; clean
  shutdown.
- **Tests passed:** 65/65 checks: 63 DOM/lobby/match/network-quality checks, one
  live authoritative WebSocket lifecycle check, and one isolated cleanup check.
  New coverage includes bounded guide turn/speed/damage, guide expiry, vortex
  target/windup/field count, damage neutrality, fighter and Ember movement,
  one-time projectile bending with speed preservation, Null erasure, bot use,
  DOM/codex discovery, ten-champion stress, and all three ultimate kinds through
  remote authority.
- **Launch smoke:** Health reported HEX 0.27.0/protocol 2; `/` and
  `/src/game.mjs` returned `200 OK` with all shipped security headers, then the
  server stopped cleanly.
- **Known limitation:** No browser executable is installed here. Hands-on vortex
  readability, guided-aim feel, audio mix, gamepad comfort, and real-device remote
  prediction remain pending; deterministic DOM/canvas and network harnesses pass.
- **Recommended next task:** With three production champions complete, add
  deterministic latency/jitter/loss simulation and input remapping before further
  roster multiplication, then use those tools to tune movement and spell reads.

## 2026-07-26 — Persistent input-aware controls

- **Player-facing problem:** Fixed Player 1 keys limited accessibility and made
  teaching copy unreliable as soon as controls changed.
- **Implemented solution:** HEX 0.28.0 adds live keyboard capture for movement and
  all seven combat actions. Assigning an occupied key swaps the two actions;
  match-control and fixed Player 2 keys are rejected with text feedback; Escape
  cancels; reset restores every default. Valid unique bindings persist inside the
  existing settings record, while older or corrupt records migrate safely.
- **Discoverability:** Settings use obvious focus/capture/error/success states.
  The HUD, ability bar, field guide, live field panel, codex kit, and every First
  Rite instruction/progress label derive from the active bindings. Mouse, gamepad,
  Player 2, simulation commands, prediction, and network authority are unchanged.
- **Commands/results:** All source and launcher syntax checks and `git diff
  --check` passed. The first sandboxed network subprocess reproduced the known
  loopback `EPERM`; the unchanged escalated `npm test` passed 65/65 checks. DOM
  coverage proves swap, reserved-key rejection, cancellation, persistence, reset,
  visible label updates, and a remapped sprint advancing authoritative tutorial
  state. Server smoke on port 8126 reported HEX 0.28.0/protocol 2; `/` and
  `/src/game.mjs` returned `200 OK` with all security headers, then stopped cleanly.
- **Known limitation / next task:** No browser executable is installed here, so
  hands-on keyboard-layout, responsive layout, controller, and audio verification
  remain pending. Next add deterministic latency/jitter/loss simulation for
  repeatable reconciliation tuning.

## 2026-07-26 — Deterministic adverse-network lab

- **Player-facing/QA problem:** Real RTT diagnostics identified poor links but
  could not reproduce latency, jitter, loss, or snapshot reordering on demand.
- **Implemented solution:** HEX 0.29.0 adds bounded persisted network-lab sliders
  for 0–250 ms latency, 0–100 ms jitter, and 0–20% loss. A pure seeded scheduler
  conditions only outgoing gameplay inputs and incoming authoritative snapshots;
  zero uses the original direct path. Control requests and real probes remain
  immediate. The HUD distinguishes real measurements from the active LAB profile
  and reports delivered/dropped counts. Match, disconnect, reset, and config
  boundaries clear queued packets.
- **Synchronization hardening:** Authoritative server ticks now advance
  monotonically on the client, so jitter-reordered or duplicate snapshots cannot
  roll prediction backward. Pending-input replay and server ownership are
  otherwise unchanged.
- **Verification:** Source/launcher syntax and diff checks passed. `npm test`
  passed 69/69 checks: 67 deterministic/DOM/lobby/conditioner/diagnostic checks,
  one live WebSocket lifecycle, and one isolated cleanup check. New coverage
  proves bounds, zero bypass configuration, seeded reproducibility, directional
  queues, time order, clean resets, stale-tick rejection, persistence, and the
  allowlisted browser module. Server smoke on port 8127 reported HEX
  0.29.0/protocol 2; `/`, `/src/game.mjs`, and
  `/src/network-conditioner.mjs` returned `200 OK` with security headers, then
  stopped cleanly.
- **Known limitation / next task:** No browser executable or second real device is
  available here; hands-on feel under impairment remains pending. Use the lab for
  reconciliation tuning, then add one behavior-driven elemental interaction trial.

## 2026-07-26 — First Rite defensive interaction trial

- **Player-facing problem:** The defense stage advanced from pressing the defense
  key while its spar was forbidden to attack, so it taught input recall rather
  than timing, threat reading, or each champion's actual defense contract.
- **Implemented solution:** HEX 0.30.0 lets the spar cast one visually marked
  practice spell during the defense stage. It is capped at 6 damage, has no
  knockback, cannot eliminate the learner or build ultimate charge, and repeats
  no faster than 1.1 seconds. Empty defense presses no longer count. Reflection,
  guard, phase, absorb, and counter advance the rite only when they resolve an
  incoming spell. Input-aware coaching first asks for mobility, then the timed
  answer; a gold diamond, restrained tone, and comic callout communicate the read.
- **Verification:** Source/server and shell syntax checks plus `git diff --check`
  passed. Focused match coverage passed 48/48. The final complete `npm test`
  passed 72/72 checks: 70 deterministic/DOM/lobby/network-conditioner/diagnostic checks,
  one live authoritative WebSocket lifecycle check, and one isolated cleanup
  check. New tests prove every defense family, reject empty-button completion,
  enforce nonlethal/no-knockback/no-ultimate training pressure, and preserve the
  full interaction and two-minute combat soaks.
- **Launch smoke:** The release server on port 8128 reported HEX 0.30.0/protocol
  2; `/` and `/src/game.mjs` returned `200 OK` with all security headers. The
  shipped cleanup command then stopped PID 212439 and a failed health request
  confirmed the port was closed.
- **Known limitation / next task:** No browser executable or second device is
  installed here. Hands-on timing, gold-mark visibility, audio mix, remapped-key
  comfort, and impaired-network play remain pending. Next build one similarly
  behavior-driven Flux/element reaction trial without lengthening the rite or
  blocking immediate skip.

## 2026-07-26 — First Rite discipline proof

- **Player-facing problem:** The rite's final stage still completed on an empty
  tactical key press. It did not teach that Flux magic must create world state,
  connect through geometry, or survive a timing commitment.
- **Implemented solution:** HEX 0.31.0 replaces that input check with production
  outcomes. Gale, Stone, Tide, Rime, and Ember terrain must be created validly;
  Veil must author a decoy; aimed Volt and Prism must hit; Null must catch a
  nearby target; and Cinder's trap must finish arming. Tailored input-aware copy
  explains each proof. Misses
  and blocked Stone do not advance. The spar retains movement but cannot fire or
  use abilities through the unfinished final stage, preserving safe practice.
  Completion has a concise comic/audio cue and the rite still has four stages and
  an immediate skip.
- **Verification:** Source/server and shell syntax plus `git diff --check` passed.
  Focused simulation coverage passed 51/51. Full `npm test` passed 75/75 checks:
  73 deterministic/DOM/lobby/network-conditioner/diagnostic checks, one live
  authoritative WebSocket lifecycle check, and one isolated cleanup check. New
  coverage proves every tactical family, real miss rejection, delayed trap arm,
  three seconds of restrained spar safety, invariant health, and existing combat
  stress/soak behavior.
- **Launch smoke:** Port 8129 reported HEX 0.31.0/protocol 2; `/` and
  `/src/game.mjs` returned `200 OK` with all security headers. Ctrl+C exited the
  server with status 0, and a failed health request confirmed the port closed.
  A subsequent shipped `npm stop` found no registered instances, the registry
  directory was empty, and `ps -C node` found no remaining Node process. Socket
  enumeration itself was unavailable inside the restricted sandbox.
- **Known limitation / next task:** No browser executable or second device is
  installed here. Hands-on trial pacing, copy legibility, sound mix, and remote
  prediction remain pending. Next add a short optional interaction drill where
  two elements combine through geometry, starting with Gale bending a hostile
  spell or Tide redirecting Ember, without adding elemental damage bonuses.

## 2026-07-26 — Universal Edgeweave near-miss

- **Player-facing problem:** Universal movement offered strong traversal and
  escape routes but no precise, systemic reward for deliberately staying close
  to hostile pressure instead of simply disengaging.
- **Implemented solution:** HEX 0.32.0 adds Edgeweave. A swept hostile projectile
  path inside a 16-unit outer miss band rewards a fighter moving at 260+ speed
  with 9 FLOW. The inner hit volume never pays; marked First Rite pressure,
  stationary proximity, full FLOW, and a 0.22-second per-fighter lockout do not
  pay. Each projectile records rewarded fighter IDs, preventing repeat farming.
  The result is damage-neutral and discipline-neutral. A small trail-colored
  burst, local comic/audio cue, live lockout read, and field-guide entry expose
  the mechanic without adding input or screen clutter.
- **Verification:** Source/server and shell syntax plus `git diff --check` passed.
  Focused match coverage passed 53/53. Full `npm test` passed 77/77 checks: 75
  deterministic/DOM/lobby/network-conditioner/diagnostic checks, one live
  authoritative WebSocket lifecycle check, and one isolated cleanup check. New
  coverage proves exact swept near-misses, one reward across simultaneous fan
  shots, no hit reward, no stationary reward, no training reward, resource and
  cooldown bounds, and invariant stability through the existing stress/soak. A
  final local-only cue scoping pass retained clean syntax/diff checks and passed
  the DOM/canvas smoke 1/1.
- **Launch and cleanup:** Port 8130 reported HEX 0.32.0/protocol 2; `/` and
  `/src/game.mjs` returned `200 OK` with all security headers. The shipped stopper
  terminated PID 229345. Health then refused connection, `ps -C node` returned no
  process, and the server registry was empty.
- **Known limitation / next task:** No browser executable or second device is
  installed here. Hands-on tuning must validate whether the 16-unit band,
  260-speed floor, 9-FLOW return, cue mix, and high-latency prediction feel fair.
  Next prioritize one additional complete contrasting champion for an existing
  race and validate it in compact PvP before expanding PvPvE content.

## 2026-07-26 — HEX 0.33.0 coherent Muster Hall and readable ancestries

- **Player-facing problem:** Play was a long, space-wasting form whose launch
  action sat below a large atlas. Race and champion were independent selectors,
  permitting thematically and visually incoherent combinations. Text and
  callouts were too small/opaque, the HUD had no compact/detail choice, and race
  silhouettes were communicated mostly by a name.
- **Implemented solution:** Rebuilt Play as a responsive two-pane Muster Hall.
  Format, functional rites, a horizontally comparable race-column champion
  matrix, spatial atlas, real hazard rule, bot count, live champion/element/map
  summary, and launch action now form one usable flow. Each champion carries its
  home ancestry through configured, quick, bot-default, and online presentation;
  online ancestry is visible but locked. All thirteen races declare unique
  physical marks rendered on bodies (ears, tusks, antlers, beard, cap, ribs,
  wings, fins, shoulders, crest). Stable element colors are paired with names
  and glyphs. Base type is 17 px, the persistent HUD toggles compact/full detail,
  and comic/toast fills are exactly 31% opaque (69% transparent) with contrast
  edges, blur, and shadow. Empty race columns are honest and non-interactive.
- **Verification:** `node --check` passed for game/content sources;
  `git diff --check` passed before documentation. Focused DOM/gameplay coverage
  passed 54/54. The final first full run passed its 75-check deterministic/DOM/
  lobby/conditioner stage, then correctly failed the live-server assertion after
  the release version changed; the stale assertion was updated. Focused live
  authoritative networking passed 1/1 and isolated cleanup passed 1/1. New DOM
  coverage proves 13 columns, 10 playable rows, no independent local race input,
  race-feature copy, champion-bound quick-start ancestry, persistent HUD detail,
  real hazard disabling, and clean local 2P launch.
- **Final release check:** After synchronizing the server, updater, and network
  assertion versions, the complete `npm test` passed 77/77: 75 deterministic/
  DOM/lobby/conditioner/diagnostic checks, one live authoritative WebSocket
  lifecycle, and one isolated cleanup check. One preceding combined-shell run
  reported a file-level live-network failure without diagnostic detail; cleanup,
  the isolated network test, and the exact full rerun all passed.
- **Launch and cleanup:** Canonical port 8000 returned HEX 0.33.0/protocol 2;
  `/`, `/src/game.mjs`, and the health endpoint returned successfully with
  security headers. `npm stop` terminated PID 267474 and a failed follow-up
  request confirmed port 8000 was closed. Future smokes reuse port 8000 after
  cleanup instead of incrementing ports.
- **Known limitation / next task:** No browser executable or second device is
  installed here, so hands-on layout, silhouette, alpha/contrast, controller,
  and remote-device acceptance remain pending. Only Wyrmbound currently has a
  complete two-champion column. Next author one mechanically contrasting,
  production-complete pair for an empty ancestry or second champion for an
  existing ancestry, validate it in compact PvP, and repeat without stat reskins.

## 2026-07-26 — WILDMARCH Wayseal route objective and shutdown contract

- **Live starting evidence:** The tracked checkout began clean at HEX 0.32.0
  with three pre-existing untracked user files left untouched. Baseline
  `npm test` passed 77/77 checks. Every `src/*.mjs` and `scripts/*.mjs`
  `node --check`, the three Linux `bash -n` launcher checks, and
  `git diff --check` passed. Port 8131 served 0.32.0 health, the shell,
  controller module, security headers, and empty lobby discovery, then closed
  cleanly. No browser executable or PowerShell was installed.
- **Player-facing problem:** WILDMARCH reused center control and neutral kill
  points without a distinct PvPvE reward, route decision, loot/extraction state,
  or truthful graceful-host-shutdown outcome. Its neutral layer did not yet
  satisfy Gate 3.
- **Implemented solution:** HEX 0.33.0 gives every arena two validated outer
  waystones. Defeating a neutral warden releases one Wayseal; an unprotected
  fighter can claim it and has 16 seconds to deliver it to either route.
  Delivery moves the scoring rune there for 14 seconds, then restores center.
  The seal changes no health, damage, Flux, or FLOW. It drops on elimination,
  leave, or disconnect, can be stolen by either team, returns against stalling,
  and remains singular while a route is active. Bots pursue loose seals, carry
  them to the nearer authored route, and target hostile carriers.
- **Authority and clarity:** Match schema v3 owns seal, carrier, timer, route,
  and dynamic-objective state. Late joins, spectators, prediction, reconnects,
  and host migration use the existing snapshots. Disconnect advances the
  authoritative network tick before its immediate drop snapshot. Canvas
  waystones, seal geometry, carrier roster text, live coaching, field info,
  guide copy, and restrained comic/audio cues expose every phase. Tied clocks
  state that the next score wins and deterministically end on the first score
  delta.
- **Host shutdown:** Graceful server shutdown now sends a terminal
  `server-shutdown` message before closing sockets. The browser distinguishes it
  from a recoverable drop, pauses with `Host realm closed`, removes the unusable
  reconnect token, and directs the player back to Host / Join. Ordinary drops
  keep the existing 30-second reservation copy.
- **Commands/results:** Focused Wayseal/lobby/DOM/network checks passed, including
  the combined DOM/lobby/match run at 72/72. Final `npm test` passed 81/81
  checks: 79 deterministic/DOM/lobby/match/network-conditioner/diagnostic
  checks, one real WebSocket lifecycle including shutdown delivery to player and
  spectator clients, and one isolated registered-server cleanup check. All
  JavaScript and Linux launcher syntax checks plus `git diff --check` passed.
- **Launch/cleanup:** Port 8133 reported HEX 0.33.0/protocol 2; `/`,
  `/src/game.mjs`, and `/src/match.mjs` returned `200 OK` with all shipped
  security headers, and lobby discovery returned an empty list. The shipped
  `npm stop` stopped PID 353171, health then refused connection, and a second
  stopper found no registered server for this checkout.
- **Known limitation / next task:** Physical Garuda/Windows play, gamepad,
  Wayseal timing/readability/cue tuning, and the two-device remote soak remain
  unavailable here. Gate 3 is software-complete; do not begin Gate 4 enemy
  families until that real-player combat/objective acceptance makes tuning
  credible.

# 2026-07-26 — Responsive menu input and unclipped muster copy

- **Player-facing problem:** The reported play menu did not react to directional
  input, while mode descriptions and the final launch summary intentionally
  clipped text. Primary navigation labels were also too small and visually
  technical for the old-world presentation.
- **Implemented solution:** Added bounded Up/Down navigation with immediate panel
  activation, Right movement into the active panel, and Left return to its
  navigation entry. Preserved the home-screen Enter shortcut. Removed mode-card
  line clamping and summary ellipsis, enabled safe wrapping, and enlarged the
  primary labels using the established chronicle serif stack.
- **Verification:** `node --check src/game.mjs`, the focused browser-shell test,
  the full `npm test` suite (81/81), shell syntax checks, and `git diff --check`
  passed. The DOM regression now proves directional activation of Play and
  Host/Join. No browser executable is installed, so physical pointer, focus,
  narrow-layout, font rendering, and gamepad acceptance remain outstanding.
- **Recommended next task:** Add deterministic gamepad menu traversal through the
  same focus/activation contract, then hands-on accept the complete Muster Hall
  on Garuda and Windows before expanding chemistry or destructible terrain.

# 2026-07-26 — Edge-triggered gamepad menu traversal

- **Player-facing problem:** The gamepad worked only after entering combat, so a
  controller-first player could not traverse the menu that launches the game.
- **Implemented solution:** The first connected pad now drives menu Up/Down with
  the D-pad or left stick, Left/Right across navigation and panel controls, and
  the south face button as accept. Inputs are edge-triggered and reset on release
  or menu exit, preventing a held stick from racing through every panel.
- **Verification:** `node --check src/game.mjs`, focused DOM coverage for gamepad
  panel traversal, the full `npm test` suite (81/81), shell syntax checks, and
  `git diff --check` passed. Physical controller feel remains a Garuda/Windows
  acceptance item because no browser/gamepad device is available here.
- **Recommended next task:** Hands-on accept pointer, keyboard, and controller
  behavior at desktop and narrow widths, then address any focus/layout defects
  before beginning a bounded chemistry/environment slice.

# 2026-07-26 — Neutral Tide–Ember vapor chemistry

- **Player-facing problem:** Tide erased Ember outright, so the most obvious
  elemental combination removed state rather than creating a new positioning
  decision.
- **Implemented solution:** A direct overlap now consumes both fields into one
  1.8-second neutral vapor cloud with a dotted pale-green mark and bounded
  three-damage pulses against every fighter. Directed, offset Tide still
  redirects Ember, making the reaction depend on placement rather than affinity.
- **Verification:** Focused chemistry tests and the full `npm test` suite (81/81)
  passed with invariant and Varka counterplay coverage. JavaScript syntax and
  diff checks passed. Physical effect density and dodge timing remain untested
  without a browser.
- **Recommended next task:** Complete the user-directed HEX→FLUX repository,
  checkout, product, launcher, package, documentation, and compatibility
  migration before adding magma or destructible environment state.

# 2026-07-26 — FLUX identity and project-structure migration

- **Player-facing problem:** The shipped interface said HEX while package,
  server, storage, automation, checkout, and repository surfaces still mixed HEX
  and DIFF identities. The iteration entrypoint also cluttered the project root.
- **Implemented solution:** Made FLUX the canonical title and package identity,
  adopted the line “Flow. Learn. Unleash. eXecute.”, migrated health/debug/save
  and launcher surfaces to FLUX, and updated Linux/Windows defaults for the
  `flux` repository and checkout. Legacy DIFF environment variables, health
  route, debug handle, and browser storage remain explicit read-compatible
  aliases. Moved the iteration entrypoint into `scripts/start-flux-iteration.sh`.
  Added Enter the Gungeon as a principle-level reference for gunplay, pixel
  silhouettes, projectile lanes, cadence, and dense-fight clarity without
  copying protected expression.
- **Verification:** JavaScript syntax, all shell syntax, focused browser/server
  migration checks, the full `npm test` suite (81/81), and `git diff --check`
  passed on Linux. PowerShell and physical desktop launchers remain Windows
  acceptance items.
- **Recommended next task:** Rename the GitHub repository and local checkout to
  `flux`, verify the redirected remote and tests from the new path, then begin a
  bounded project-module extraction before Stone–Ember magma or destructibles.

# 2026-07-26 — Network boundary extraction and completed rename

- **Implemented solution:** Renamed the existing GitHub repository in place to
  `generalgroovy/flux`, updated `origin`, and moved the checkout to
  `/home/otp/Projects/flux`. Grouped lobby authority, adverse-network
  conditioning, and connection diagnostics under `src/network/`; updated browser
  public-file allowlists, server imports, tests, documentation, and recursive
  syntax verification accordingly.
- **Verification:** The remote branch resolves at the new repository, and the
  complete 81-test suite plus syntax and diff checks passed from the renamed
  local directory. The harmless host `pcilib` warning occurs before commands in
  this environment and did not affect exit status or checks.
- **Recommended next task:** Extract element-reaction rules from the large match
  module behind a deterministic simulation boundary, then implement and tune one
  Stone–Ember magma slow before introducing destructible environment props.

# 2026-07-26 — Neutral Stone–Ember magma routes

- **Player-facing problem:** Stone and Ember could overlap without reacting,
  missing an intuitive chemistry outcome and leaving temporary cover untouched.
- **Implemented solution:** Overlap now consumes both fields into a 2.4-second,
  86-unit neutral magma patch. Its broken-orange mark slows grounded speed to
  62% without damage; universal hops ignore the ground modifier and provide the
  clean escape. The reaction grants neither owner charge or affinity immunity.
- **Verification:** Focused reaction coverage proves formation, neutrality,
  non-damage, bounded speed, and invariants. The full suite passed 82/82,
  including browser, authoritative networking, combination stress, and server
  cleanup checks.
- **Recommended next task:** Extract the now-growing chemistry resolver from
  `match.mjs`, then introduce one destructible prop family whose lifecycle and
  elemental outcomes are authoritative, deterministic, and visually explicit.

# 2026-07-26 — Local Odysseus and Aider unrestricted handoff

- **Implemented solution:** Added tracked shared context, Aider configuration,
  resumable Odysseus state/decisions/tests, an interactive Aider YOLO launcher,
  and a persistent Odysseus-style supervisor that runs bounded Aider iterations,
  verifies, commits, and pushes the active agent branch. Both use the installed
  local Qwen 2.5 Coder 7B model, share a file lock, refuse `main`, and refuse a
  dirty starting tree. Repaired the broken user-local `odysseus` dispatcher
  symlink and installed the **FLUX Principal Agent** Odysseus preset without
  storing credentials.
- **Safety boundary:** “YOLO” accepts shell/edit prompts inside this checkout;
  it does not permit force-push, history rewriting, credential access, releases,
  destructive system changes, or unrelated external mutation.
- **Verification:** Aider 0.86.2 parsed `.aider.conf.yml` with the local
  `ollama_chat/qwen2.5-coder:7b-instruct` model; Odysseus 0.1.0 dispatch and the
  FLUX preset round-trip passed; both shell launchers passed syntax checks.
- **Recommended next task:** Use one launcher at a time for the chemistry-module
  extraction and destructible-prop slice; stop autonomous work through
  `.agent/STOP` before manual edits.

# 2026-07-26 — FLUX 0.34.0 desktop runtime and private invite foundation

- **Player-facing problem:** Remote lobbies were browser-hosted and required
  players to understand reachable ports or VPNs. The source desktop shortcuts
  still opened a browser, packaged auto-update did not exist, and there was no
  application-owned invite or shutdown lifecycle.
- **Implemented solution:** Electron 43 now owns a Linux/Windows FLUX window and
  launches the existing authoritative server as one exact IPC child on a random
  loopback port. The renderer is sandboxed with Node integration off, context
  isolation and web security on, device/data reads denied, only same-origin
  sanitized clipboard writes allowed, popups/webviews denied, and navigation
  locked to a launch-token-authenticated local authority. Normal
  shutdown asks that authority to close, stops the exact tunnel child, and uses
  bounded targeted escalation only for those owned PIDs. AppImage and NSIS
  packaging, a pixel-rune app icon, startup update probing, and `flux://` desktop
  invite registration are configured. Linux/Windows source installers now add
  normal and **Play with Friends** shortcuts; both update and test before opening
  the desktop app.
- **Friend transport:** Friend mode downloads the current official Linux/Windows
  `cloudflared` asset into app user data, rejects missing or mismatched GitHub
  SHA-256 metadata, creates a private HTTPS/WebSocket route, validates public
  health, and retries boundedly before exposing it. Desktop lobby creation emits
  a strict `flux://join` link containing only an HTTPS origin and six-character
  lobby code. Browser/LAN development remains explicitly available.
- **Verification run:** Baseline `npm test` passed 82/82. Desktop/runtime/tunnel/
  invite focused tests, recursive JavaScript syntax, Linux shell syntax, JSON,
  diff, and production dependency audit passed. The final expanded full suite
  passed 94/94: 92 deterministic/DOM/lobby/match/desktop/network checks, one
  live WebSocket lifecycle, and one isolated server cleanup. Source Electron opened on Wayland
  and a forced close left no child or registry residue. Linux AppImage packaging
  and packaged launch passed; the owned server started from ASAR and closed.
  `npm audit --omit=dev` reported zero production vulnerabilities.
- **Failures and limitations:** The first Linux package build rejected a
  misplaced `desktopName`; moving it to package scope fixed the build. The
  packaged GitHub update probe returned 404 because the repository has no
  player-accessible release feed; its previously duplicated unhandled rejection
  is now caught, but signed auto-update remains release-blocked. Windows files
  assembled on Linux, then NSIS creation stopped because Wine is absent; no
  system package was installed. Real Quick Tunnel registration worked and one
  public health probe passed, but repeated generated hostnames intermittently
  failed DNS publication. The implementation retries and fails closed, but an
  owned authenticated relay is still required for dependable friend play.
- **Recommended next task:** Establish a signed public update feed and stable
  authenticated relay, then run a two-device Linux/Windows `flux://` join soak
  before treating remote desktop play as out-of-box release-ready.

# 2026-07-26 — FLUX 0.34.1 fullscreen and playable Muster Hall

- **Player-facing problem:** The desktop did not declare fullscreen as a runtime
  invariant, and the visible **Enter arena** button did nothing. The application
  root mirrors menu state through `data-panel`; broad delegated click matching
  mistook that root for a navigation control and cancelled the submit button's
  default action.
- **Implemented solution:** Restricted panel delegation to actual links and
  buttons. The Electron window now starts fullscreen, asserts fullscreen again
  before first show, focuses itself, and restores fullscreen through both a
  native leave hook and a one-second lifecycle watchdog if the window manager
  clears it. The watchdog is released with the window. Normal OS close still
  uses the existing bounded, exact-child cleanup path.
- **Verification run:** The final suite passed 94/94. A source Electron session
  on Wayland reported a 2560×1440 viewport matching its active screen; DevTools
  Protocol pointer events opened **Play**, hit the visible **Enter arena**
  button, entered Oath Duel with two valid entities, and reported no simulation
  invariant or renderer exception. The Linux AppImage and Windows x64 directory
  rebuilt from the final code. The rebuilt AppImage launched fullscreen on the
  complete 2560×1440 Sway output, recovered to fullscreen after a forced
  compositor exit, and its window, authority, renderer, and AppImage mount all
  closed. Recursive source syntax, shell syntax, JSON, and diff checks passed.
- **Next task:** Establish the signed player-accessible update feed and stable
  authenticated relay, then complete the two-device Linux/Windows invite soak.

# 2026-07-26 — FLUX 0.34.2 readable fullscreen Muster Hall

- **Player-facing problem:** The Play screen was functionally restored, but its
  default fullscreen presentation still rendered mode copy at 10.37 px,
  champion names at 11.05 px, and element lines at 9.69 px. Several decision
  cards could report text overflow, making the dense selector hard to scan.
- **Implemented solution:** Established a scoped ~12 px default floor across
  Play legends, mode descriptions/tags, race traits, champion names/elements,
  map lore, settings, summary labels, and launch state. Mode choices now use an
  auto-fitting minimum width and race columns are wider with safely wrapping
  champion names. The race matrix remains an explicit horizontal column strip;
  other decision text does not intentionally clip.
- **Verification:** The final suite passed 94/94, and Linux AppImage plus Windows
  x64 payloads assembled. In the rebuilt AppImage at 1920×1080 fullscreen, all
  five modes remained in one row; computed-style and geometry checks found no
  visible Play text leaf below 11.8 px and no clipped mode, champion, or map
  text. Real pointer events opened Play and **Enter arena** launched a valid
  two-entity Oath Duel without renderer errors or simulation invariant failures.
  The packaged window recovered after a forced compositor fullscreen exit and
  closed without a remaining renderer, authority, or AppImage process.
- **Next task:** Continue the signed update feed and stable authenticated relay
  acceptance work, followed by the two-device Linux/Windows invite soak.

# 2026-07-28 — Future roster concept and static balance pass

- **Scope:** Worked only in the inactive overhaul content foundation while the
  unified Windows package awaits hands-on launch verification. Live gameplay,
  rendering, networking, save IDs, and package behavior were not changed.
- **Design correction:** Preserved the stable IDs `dark`, `scaleheir`,
  `stonewrought`, and `rootwarden` while aligning their player-facing names to
  the approved vocabulary: Void, Wyrm, Stoneborn, and Treefolk.
- **Balance foundation:** Added deterministic character profiles for power
  budget, effective signature points, role/element coverage, average Flux cost,
  and cooldown. Validation now rejects duplicate signature skills or affinities,
  missing ability counterplay, invalid paid-action costs/cooldowns, signatures
  without role breadth, signatures over the standard 13-point limit, and active
  reuse beyond 25% of the roster.
- **Concept direction:** Authored silhouette, motion, counterplay, and effect
  language for the seven canonical future characters in
  `.agent/CONCEPT-ITERATION.md`. No speculative combat values were changed.
- **Verification:** Focused overhaul tests passed 13/13. The current complete
  Windows test command and consolidated CI helper then passed 108/108 plus all
  recursive JavaScript syntax checks. Interactive and Linux package gates remain
  required before publication.
- **Next task:** Complete the scheduled packaged Windows smoke, then run the
  full suite and publish the unified `develop` branch only if all gates pass.

# 2026-07-28 — Launch and branch-cleanup operational hardening

- **Problem:** Recovery tags captured the original branch audit, but two remote
  writers continued advancing. Deleting from that stale snapshot would have
  lost newly applied overhaul work. Package output also lacked a durable link
  from installer hash to the exact source commit.
- **Implemented solution:** Added fresh recovery tags at 12:41 and 12:46, an
  explicit unification manifest, and a fail-closed preflight that verifies the
  current integration branch, clean tree, main ancestry, every expected remote
  head, and every pushed archive target. Added a clean-tree packaging wrapper
  that records commit, artifact size, and SHA-256, plus CI artifact publication
  and an exact launch/unification runbook.
- **Deferred work:** The advanced full-overhaul branch contains substantial live
  checkpoint code. Its first replacement CI run failed the same DOM reset
  assertion on all four platform/version lanes; a later test-contract revision
  was still pending. The complete tip is archived but intentionally excluded
  from the stable candidate.
- **Verification:** The preflight passed against all eight currently recorded
  remote tips and pushed archive tags. The package wrapper correctly refused a
  dirty tree. JSON, workflow YAML, new script syntax, and the full 108-test
  Windows verification passed.
- **Next task:** Rerun clean preflight immediately before packaging, execute the
  commit-bound Windows smoke, and stop if any remote branch moves again.

- **Gate refinement:** The full-overhaul branch moved again immediately after a
  clean check, confirming an active writer. Launch and cleanup are now separate
  preflight phases: drift is a visible non-blocking warning for packaging the
  immutable candidate, but remains a hard failure for branch deletion.

# 2026-07-28 — S. Wayne future-roster rework

- **Direction:** Replaced the future Samwise DeWayne concept with **S. Wayne**, a
  medium Human with strong internal Dark/Light affinities and a player-facing
  Void/Light identity. The stable `samwise` ID remains as a compatibility key.
- **Kit:** Authored the eclipse-boundary passive **BETWEEN SHADOWS**, with PRISM
  TRIPWIRE, BURROWED SHADOW, Ray, and Sun Grid as the signature kit. The concept
  now communicates contrast boundaries through a split mantle, prism lines,
  shadow anchors, and reveal rays.
- **Roster contract:** Two Humans and no assigned Hobbit are now intentional.
  Validation retains exactly sixteen future races and sixteen future characters
  but no longer fabricates one representative per race.
- **Compatibility:** This changes only inactive overhaul data, tests, and design
  documents. The ten-character 0.34.3 live roster is untouched.
- **Verification:** The focused overhaul suite passed 14/14 and the generated
  balance profile is valid at 50 power-budget points and 7/13 signature points.
  The complete Windows verification then passed 109/109 plus recursive syntax
  checks.

# 2026-07-28 — Superseded fifteen-character overhaul roster

- **Direction:** Replaced the provisional sixteen-character future roster with
  the fifteen requested named concepts: Oh Tipi, S. Wayne, The Red Baron,
  Steezo, Treevor the Mason, Oll' I, Fluup, Wa Bidi, Nico Lai, Spai Si, Hidn
  Leef, Ha Rekt, Dr. Apex, Hara, and Hesus Christo.
- **Reuse:** Reworked fifteen existing data slots rather than adding parallel
  characters. Only the unrequested Brum placeholder was retired. Existing IDs
  remain compatibility keys even where player-facing names and races changed.
- **Authored identity:** Added draft lore for every future character. Explicit races
  are locked for Wa Bidi, Hidn Leef, Ha Rekt, Dr. Apex, Hara, and Hesus Christo.
- **Mechanical adaptation:** Most characters retain the nearest existing kit.
  Dr. Apex is now a Stoneborn combat medic using ROOT RAMPART, Spring, MIRROR
  BULWARK, Deep Spring, and the non-damage FIELD TRIAGE passive.
- **Compatibility:** Live 0.34.3 content remains unchanged. The future validator
  now requires exactly the fifteen approved names, non-empty lore, valid race
  sizes, diverse signature roles, bounded budgets, and explicit counterplay.
- **Verification:** The focused future-content suite passed 14/14 after the
  complete roster remap.

# 2026-07-28 — Mechanics-first roster and Grimm Bow

- **Privacy and lore boundary:** Removed personal reference mappings from the
  concept documentation. Existing humorous descriptions remain unchanged as
  `draft-placeholder` source copy and are blocked from in-game use until the
  author explicitly rewrites and approves them.
- **Roster:** Restored the retired `brum` compatibility slot as **Grimm Bow**, a
  size-4 Troll with Void 2 / Earth 1 / Water 1 affinities. The future roster is
  again sixteen characters; live 0.34.3 content remains untouched.
- **Mechanical loop:** DROWNED MARK lets personal Void/Water displacement steady
  the next Stone Shot without increasing damage. Stone Shot, Void Pull,
  TIDELINE, and Moss Flood reuse the existing catalog, keeping the first
  prototype feasible while preserving setup, escape, and miss-recovery play.
- **Promotion contract:** Every future character is `design-only`. Promotion
  requires a mechanic prototype, deterministic local tests, server authority,
  bot use, readability/accessibility review, and packaged smoke verification;
  mechanical acceptance never approves lore.
- **Verification:** Focused future-content checks passed 15/15. The complete
  Windows verification passed 110/110 (108 core/DOM/deterministic checks, one
  live WebSocket lifecycle, and one server-cleanup check), plus recursive
  JavaScript syntax checks.

# 2026-07-28 — First feature-gated overhaul runtime slice

- **Safety boundary:** Added the `overhaul-preview` match content profile while
  preserving `live` as the default. The normal menu and lobby service continue
  to resolve only the shipped roster; requests for the preview-only `mara` ID
  fail closed to the existing live fallback.
- **Hara mechanics:** Implemented Ray and heavy Stone Shot as distinct primary
  commitments, SECOND PLAN as one swap per round at a personal spawn sanctuary,
  Gust Ring with a real safe center, and Sun Grid as three telegraphed lanes
  that cannot multi-hit one target. Draft lore is absent from runtime data.
- **Bots and protocol:** Added an optional, strictly boolean `swap` command with
  a false default for existing clients. Preview bots use the same sanitizer and
  can select Stone Shot at a sanctuary against heavy or distant targets.
- **Promotion:** Mechanic-prototype, deterministic-local-test, and bot-use gates
  pass. UI/input exposure, remote preview authority, accessibility/readability,
  and packaged smoke gates remain pending, so Hara is not user-playable.
- **Verification:** The complete Windows verification passed 119/119: 117
  core/DOM/deterministic checks, one live WebSocket lifecycle, and one
  authenticated server-cleanup check. Recursive JavaScript syntax checks also
  passed.

# 2026-07-29 — Safe Garuda local-model handoff

- **Outcome:** Replaced the stale machine/branch-specific unrestricted launchers
  with a path-independent Garuda/Arch setup doctor and a shared local-agent
  runner for interactive or bounded work.
- **Stack:** Ollama uses the official `qwen2.5-coder:3b` or `:7b` tags through
  Aider's `ollama_chat/` adapter. Both profiles use 16K context and a 2K
  repository map; automatic selection prefers 7B at 16 GiB RAM or 7 GiB VRAM.
- **Safety:** Setup changes require explicit `--install`/`--pull`. Agent work
  refuses protected/detached branches, dirty trees, and concurrent runs; it
  defaults to one iteration, no commit, and no push. Those external Git actions
  require separate `--commit` and `--push` choices.
- **Odysseus:** Converted its prompt/state/decisions to live-state discovery.
  Odysseus remains an optional authenticated workspace while Aider supplies the
  supported repository-editing equivalent and the same task/test gate. A
  clipboard helper renders current branch, commit, status, and recent history
  directly through Sway's `wl-copy` without creating repository artifacts.
- **Verification:** `node --test tests/local-agent-handoff.test.mjs` passed 2/2;
  Git for Windows Bash parsed every `scripts/*.sh`; `git diff --check` passed;
  and `npm.cmd test` passed 121/121 (119 core/DOM/deterministic checks, one live
  WebSocket lifecycle, and one authenticated cleanup check).
- **Limitation:** The Garuda package/service/model/GPU doctor and Sway
  notifications require execution on the target Linux machine and remain
  unverified here; this tooling-only slice did not change or interactively
  playtest game behavior.

# 2026-07-29 — Autonomous local-only agent runtime

- **Direction:** Made both interactive and bounded Qwen sessions operate without
  tool confirmations while preserving branch, clean-tree, concurrency, and
  deterministic verification gates.
- **Interactive behavior:** Aider stays open for follow-up prompts, auto-approves
  local shell/file actions, runs `npm test` after edits, and makes local commits.
  Bounded runs now also commit verified work by default; `--no-commit` retains a
  review diff, and no runtime path exposes push.
- **Local resources:** Runtime accepts only a loopback Ollama URL and disables
  Aider telemetry/update checks/URL ingestion, Playwright downloads, npm online
  resolution, Git network protocols, and standard HTTP(S)/SOCKS egress while
  preserving loopback for inference and local network tests.
- **Scope boundary:** Setup remains the explicit networked package/model phase.
  Full unsandboxed user-shell access can deliberately override environment
  restrictions, so the prompt forbids remote access and the documentation names
  this limitation instead of claiming kernel-level isolation.
- **Verification:** The focused handoff suite passed 2/2, Git for Windows Bash
  parsed every shell launcher, explicit model/loopback selection accepted local
  endpoints and rejected a remote endpoint, `git diff --check` passed, and the
  complete Windows suite passed 121/121 both normally and from the configured
  proxy-denied/npm-offline local runtime environment.

# 2026-07-29 — Complete observable development audit

- **Outcome:** Every interactive or bounded local-agent session now creates a
  private, timestamped audit below the user's XDG state directory and prints
  its location at start and exit. `local-agent.sh logs` discovers the newest
  session without requiring Ollama or Aider.
- **Evidence:** The audit contains a start manifest, timestamped event stream,
  visible terminal/tool/test/Git output, interactive input history, chat
  history, raw local-LLM request/response history, final exit/Git state,
  session commit list, diff statistics, and committed/staged/uncommitted
  patches. Aider also runs verbose and displays commit diffs.
- **Privacy:** Audit directories use a restrictive umask and remain outside the
  repository because they may contain source, prompts, and terminal output.
  The agent contract forbids suppressing or deleting audit evidence.
- **Verification:** The handoff contract passed 2/2, all shell scripts parsed,
  the synthetic XDG-state `logs` lookup listed the expected manifest/events,
  `git diff --check` passed, and the complete Windows suite passed 121/121.
- **Limitation:** Aider is not installed in this Windows checkout, so an actual
  Qwen interactive session and its raw transcript must still be accepted on the
  target Garuda host; hidden model chain-of-thought is intentionally not treated
  as trustworthy engineering documentation.

# 2026-07-29 — Visual-first production freeze

- **Direction:** Froze new mechanical implementation until an ordered original
  visual overhaul is accepted: V0 centralized tokens/non-shipping specimen, V1
  characters, V2 spells, V3 maps, V4 GUI, and V5 integrated acceptance.
- **Reference boundary:** Recorded The Legend of Zelda only as a broad reference
  for inviting top-down heroic fantasy, silhouette clarity, handcrafted nature,
  and restrained adventure UI. The contract explicitly rejects copying its
  characters, costumes, creatures, symbols, typography, meters, icons, menus,
  maps, compositions, animation, audio, assets, or trade dress.
- **Implementation boundary:** Visual work may touch rendering, presentation
  metadata, CSS/canvas/assets, non-simulation animation, accessibility, and
  visual tests. It may not alter movement, hitboxes, timing, damage, resources,
  abilities, elements, races, AI, networking, objectives, modes, or progression.
- **Agent routing:** Root instructions, audited local task, handoff context,
  backlog, Odysseus state/decisions, README, and regression tests all route the
  next run to the first incomplete visual gate. Approved future characters may
  receive concepts in V1 but stay inactive.
- **Verification:** The focused handoff/visual contract suite passed 3/3, every
  shell script parsed, `git diff --check` passed, and the full Windows suite
  passed 122/122.
- **Limitation:** This slice establishes and verifies the production contract;
  it does not claim V0 art tokens or any visual asset was implemented or
  visually accepted. The next audited Garuda agent run must implement V0 first.
# 2026-07-29 — V1 ancestry redistribution

- **Scope:** Updated presentation planning only; live content, preview adapters,
  runtime ancestry IDs, kits, balance, networking, and packaged behavior remain
  unchanged under the visual-first mechanical freeze.
- **Roster truth:** Recorded the approved twenty-three-character concept roster
  in `.agent/VISUAL-OVERHAUL.md` and exposed the integration gap in `README.md`:
  this branch still contains sixteen validated design records while seven later
  concepts await deliberate branch unification.
- **New ancestry assignments:** The Red Baron is planned as Vampire, Fluup as
  Werewolf, Spai Si as Angel, and provisional Donnok as Demon. The assignments
  preserve stronger locks: S. Wayne remains Hobbit, Haara Nymph, Wa Bidi Goblin,
  Grace Reava the sole Sylph, and Ha Rekt/Hesus Christo anthropomorphic
  Wyrmborn.
- **Representation:** The planned roster covers eighteen of twenty ancestry
  foundations; Elf and Orc intentionally remain empty rather than forcing a
  weak reskin. The roster remains 23 champions total.
- **Verification:** `git diff --check` passed; the local-agent visual-contract
  and focused overhaul suites passed 18/18, then the full deterministic suite
  passed 122/122 across its standard, WebSocket, and cleanup lanes. No playtest
  is claimed for a presentation-only planning change.

# 2026-07-29 — Corrected ancestry plan and V0 visual specimen

- **User mapping:** Superseded the prior distribution. Spai Si is planned as
  Demon, Fluup as Orc, Oll' I as Werewolf, The Red Baron as Undead, Djonah
  Thaan as Vampire, and Hesus Christo as Elf. The twenty-three named champions
  now cover nineteen ancestries; one explicitly unnamed Angel placeholder gives
  the final ancestry a visual slot but has no ID, lore, kit, mechanics, or
  runtime record.
- **V0 implementation:** Centralized a seven-step value ladder, eight restrained
  palette roles, three outline weights, five old-world material treatments,
  spacing, corners, four timing tiers, and one response easing curve in
  `styles.css`. Existing interface variables now alias those tokens without
  changing simulation behavior.
- **Reference specimen:** Added `tools/visual-specimen.html` and its scoped CSS
  as a source-server-only board for palette, contrast, materials, gameplay
  geometry, scale, outlines, and motion. The route is allowlisted only for local
  source review and `tools/` remains excluded from desktop package inputs.
- **Accessibility:** The specimen is responsive and reduced-motion safe. Tests
  enforce all token families, package exclusion, all six reference sections,
  and at least 4.5:1 contrast for primary, secondary, focus, and danger roles;
  the lowest enforced pair is Danger on the darkest ground at 4.72:1.
- **Rendered verification:** The in-app browser rendered the specimen at
  1440×900, 800×700, and 390×844 with all six sections visible, no horizontal
  overflow, and no clipped text after one header-line-height correction. The
  live main menu also rendered at 1440×900 with no console warnings. The
  in-app browser did not initialize the gameplay module during an attempted
  First Contact click, so no interactive combat playtest is claimed; the
  deterministic browser-shell test did launch, pause, and reset successfully.
- **Automated verification:** Focused visual/handoff checks passed 4/4;
  `npm.cmd test` passed 123/123 across 121 standard checks, one live WebSocket
  lifecycle, and one authenticated cleanup check; all tracked shell scripts
  parsed with Git Bash; package JSON, server syntax, and `git diff --check`
  passed.
- **Next gate:** V0 is implemented but awaits user visual acceptance. Do not
  start V1 character production until the token/specimen direction is accepted
  or revised; the Angel placeholder must be resolved before V1 can complete.

# 2026-07-29 — Legacy retirement map and V1 Spai Si specimen

- **Gate transition:** Treated the user's continuation as V0 acceptance and
  advanced only to V1 characters; V2 mechanics/spells and later visual gates
  remain blocked by order.
- **Roster decision:** Reclassified all ten shipped champions as temporary
  compatibility scaffolding. Added a one-to-one tested transfer ledger:
  Aerwyn→Spai Si, Gorum→Urzh, Vellyn→S. Wayne, Nim→Nico Lai, Serek→Steezo,
  Morcant→Djonah Thaan, Neris→Grace Reava, Branna→Biggy Bob, Yrsa→Ha Rekt,
  and Varka→Treevor the Mason. Every transfer records retained concepts and
  retired identity so no old champion becomes a permanent overhaul addition.
- **Playable boundary:** Did not delete or modify live runtime entries and did
  not import the new presentation module into `src/game.mjs`. Removal waits for
  a complete successor plus selection, authority, migration, launch, and
  regression checks in the same playable slice.
- **V1 slice:** Added the source-only Spai Si specimen with six gameplay reads,
  swept Demon horns, ember tail, Wind arcs, Light spindle, Earth-weighted
  mantle, team-shape redundancy, low-health wear, and a nonsexualized compact
  silhouette. It inherits Aerwyn's redirect readability but explicitly retires
  Aerwyn's name, ancestry, fiction, and complete kit.
- **Rendered verification:** The in-app browser rendered
  `tools/spai-si-specimen.html` at its 1280×720 desktop viewport with all six
  state cards, no horizontal overflow, and no console errors. No narrow-window
  render or live combat playtest is claimed for this presentation-only slice.
- **Automated verification:** Focused visual checks passed 4/4. `npm.cmd test`
  passed 126/126: 124 sequential checks, one live WebSocket lifecycle, and one
  authenticated cleanup check. Final syntax, diff, and source-route checks are
  recorded in the commit handoff.
- **Next decision:** Visually accept or revise Spai Si before creating the next
  character specimen; keep the Angel placeholder unresolved and inactive.

# 2026-07-29 — Recovery refresh, pushed integration, and V1 Urzh slice

- **Recovery/unification:** Audited remote drift before integration. Pushed
  annotated recovery tags for `main` at `eebf01c`, full-overhaul at `8590ce5`,
  and resource-HUD at `7cd5795`; updated the manifest/classifications; merged
  refreshed `origin/main`; launch preflight then passed every ancestry/head/tag
  check. Pushed `integration/unify-flux` without force or branch deletion.
- **Deferred mechanics:** The full-overhaul PR matrix is green, but its construct
  durability and parallel live-content expansion remain deferred under the V1
  mechanical freeze. The resource-HUD delta remains checkpoint CI only.
- **Verification:** A first post-merge full run found one stale exact phrase in
  the local-agent visual contract. Restored the explicit inactive-future-roster
  invariant; focused checks passed 7/7 and the rerun passed 126/126. Production
  dependency audit reported zero vulnerabilities.
- **Package evidence:** The verified Windows package is bound to `2a1277b` with
  SHA-256 `80bd785916cd2c31180bcd94e95b17a638ff61f9fd62d24fa0fdece3d853eb43`.
  The packaged app rendered fullscreen and closed normally with no owned
  processes left. Automation could focus but not activate a match control, so
  `develop` was not published and no packaged combat claim is made.
- **V1 slice 02:** Added Urzh as a source-only Stoneborn specimen inheriting
  Gorum's brace/lane-anchor discipline while retiring Gorum's name, Iron Orc
  ancestry, lore, and complete kit. Squared shoulders, ember seams, kiln
  buckler, Earth plates, Fire exhaust, and Charge forks distinguish ancestry,
  role, affinities, action state, and ownership without simulation changes.
- **Rendered verification:** The in-app browser rendered all six Urzh state
  cards at 1280×720 with no horizontal overflow or console errors. Focused
  character/visual checks passed 5/5; the full suite passed 127/127 across 125
  standard checks, one live WebSocket lifecycle, and one authenticated cleanup.
- **Next decision:** Visually accept or revise Urzh before the third V1 champion.
  A real packaged match launch remains required before publishing `develop`.

# 2026-07-29 — Modular ancestry visual foundation

- **Architecture:** Added `src/ancestry-visual-templates.mjs` with twenty frozen,
  validated presentation templates. Each owns only body shape, anatomy feature
  recipes, material, and motion read; champion profile composition owns role,
  prop, affinities, palette, ownership, health wear, and action-state effects.
- **Migration proof:** Spai Si now composes the Demon template and Urzh composes
  the Stoneborn template. Their champion-specific aura and prop layers remain
  independent, and no live renderer, simulation radius, runtime race ID,
  ability, network rule, or balance value changed.
- **Modding path:** A new champion normally selects an `ancestryId` and supplies
  profile layers. A genuinely new ancestry adds one registry entry and, only if
  necessary, one shared body/feature recipe; it does not copy a full champion
  renderer.
- **Review board:** Added `tools/ancestry-template-specimen.html`, showing every
  foundation, body-shape key, anatomy hooks, material, and motion read in one
  responsive source-only board.
- **Rendered verification:** The in-app browser rendered all twenty cards at
  1280×720 with a complete 1,384-pixel document, no horizontal overflow, and no
  console errors. Spai Si and Urzh each retained six cards, no overflow, and no
  console errors after migration.
- **Focused verification:** Seven ancestry/character/visual checks passed,
  including every template's generic body/anatomy renderer and two independent
  champions sharing one template. The full suite passed 129/129 across 127
  standard checks, one live WebSocket lifecycle, and one authenticated cleanup.

# 2026-07-29 — Living Sanctum menu and persistent remote company

- **Concept cleanup:** Removed the obsolete H/E/X background lettering and
  operations/deployment-facing menu copy. The home presentation is now the
  Living Sanctum, with an original eight-point geometric seal and old-world
  Muster, Friends, Realm & Rites, Controls, and Settings language.
- **Unified navigation:** Every existing front-end route is a Sanctum chamber.
  Entering the Sanctum from pause or results preserves the current local or
  remote contest; a persistent top-bar action and connected-company card return
  directly to play.
- **Remote lifecycle:** Sanctum navigation no longer sends `leave` or closes the
  WebSocket. Connected players can visit all seven chambers while the
  authoritative contest continues. Disconnect is now the explicit **Leave
  remote company** action, which is separately regression-tested.
- **Automated verification:** `npm.cmd test` passed 129/129 across 127 standard
  checks, one live WebSocket lifecycle, and one authenticated cleanup. The DOM
  test proves remote state/socket retention across every chamber, return to
  contest, explicit leave, reconnection, and host shutdown. `node --check
  src/game.mjs` and `git diff --check` passed.
- **Rendered verification:** The source Sanctum rendered at 1280×720 and
  390×844 with no body overflow; the desktop rail had zero horizontal overflow,
  and the narrow rail remained intentionally scrollable. The browser surface
  did not execute `src/game.mjs`, so its clicks could not verify live behavior;
  no browser multiplayer playtest is claimed.
- **Gate boundary:** This is a direct-user-authorized V4 foundation only. V1
  character work remains active, and broader GUI styling, spells, maps, and
  mechanics remain ordered behind their existing gates.

# 2026-07-29 — Ancestry-column champion selection

- **Player-facing problem:** Muster exposed ancestry columns, but each champion
  row spent most of its space on repeated copy and did not provide the immediate
  portrait scan or inspect-before-lock behavior expected of a fighting-game
  roster.
- **Implemented solution:** Recast both local-player selectors as thirteen
  compact ancestry columns with layered ancestry/champion portrait marks.
  Hovering or focusing a tile now fills a shared detail card with the champion's
  role, style, affinity edge, difficulty, ancestry boon/drawback, and complete
  kit names. Leaving the roster restores the locked champion, and previewing
  never changes the radio selection.
- **Responsive/accessibility contract:** Pointer hover and keyboard focus share
  one code path; labels remain the actual stable radio controls; Player 1 and
  Player 2 own independent live regions; narrow layouts stack the readout while
  preserving the horizontally comparable ancestry strip.
- **Automated verification:** `npm.cmd test` passed 129/129 across 127 standard
  checks, one live WebSocket lifecycle, and one authenticated cleanup check.
  The DOM coverage includes all thirteen columns, ten live portrait choices,
  both initial previews, a Gorum hover preview, locked-selection stability, and
  leave-to-restore behavior.
- **Rendered limitation:** The Windows source build rendered the Living Sanctum
  fullscreen and accepted focus on **Enter Muster Hall**, but Electron desktop
  automation again did not dispatch activation. No interactive roster render or
  match-entry claim is made from that automation run.
- **Gate boundary:** This is the user's second bounded V4 foundation request.
  V1 remains active; the change introduces no champion, affinity, ability,
  balance, networking, or simulation behavior.

# 2026-07-29 — Overhaul-first README

- **Documentation correction:** Replaced the compatibility-build changelog as
  the README's organizing frame. The document now describes the overhaul
  product first: movement, resources, ability/loadout grammar, expanded element
  vision and reactions, twenty ancestry templates, the twenty-three named
  champions plus temporary Angel slot, Sanctum, maps/modes, visual direction,
  delivery gates, and cross-platform workflow.
- **Truth boundary:** The README explicitly distinguishes intended overhaul
  behavior from the inactive eight-family/sixteen-character data prototype and
  the ten-character compatibility runtime. It does not claim that future
  characters, Spirit/Chaos/Gravity/Time, the full movement grammar, or 32-player
  scale are currently playable.
- **Legacy handling:** Old champion names appear only in a clearly marked
  mechanical-transfer ledger. Haara is the target name; the existing headless
  prototype's legacy `Hara` label and stable `mara` ID are disclosed as an
  implementation migration still to complete.
- **Verification:** `npm.cmd test` passed 129/129 across 127 standard checks,
  one live WebSocket lifecycle, and one authenticated cleanup check;
  `git diff --check` passed before the run.

# 2026-07-29 — Ground-up overhaul boundary and V1 S. Wayne slice

- **Documentation contract:** Reworked `AGENTS.md`,
  `.agent/OVERHAUL-IMPLEMENTATION.md`, `.agent/OVERHAUL-PROMPT.md`,
  `.agent/IMPLEMENTATION-LOOP.md`, and `.agent/backlog.md` around one canonical
  read order, explicit clean-reuse criteria, controlled replacement, visual
  V0–V5 order, modular target boundaries, and measured slice acceptance.
  `.agent/CONCEPT-ITERATION.md` is now explicitly historical where it conflicts
  with the overhaul-first README.
- **Architecture:** Split the monolithic champion drawing path into shared
  primitives and one module per authored character under `src/overhaul/`.
  `src/overhaul-character-visuals.mjs` remains a compatibility registry/barrel,
  and all character boards now use one shared source-only specimen runner and
  stylesheet.
- **V1 slice 03:** Added S. Wayne with stable visual/migration ID `samwise`,
  Hobbit anatomy, an eclipse waystone, separate Dark/Light value and shape
  language, team redundancy, health wear, and six authored gameplay reads. No
  live roster, simulation, network, lore, or balance behavior changed.
- **Rendered verification:** The in-app browser loaded
  `tools/s-wayne-specimen.html` at 1280x720 and reported no console errors.
  Review caught global `overflow: hidden` clipping the lower state row; the
  shared specimen document now owns scrolling, and both rows, annotations, and
  footer were then visually inspected.
- **Automated verification:** Focused visual tests passed 10/10.
  `npm.cmd test` passed 132/132: 130 standard checks, one live WebSocket
  lifecycle, and one authenticated cleanup check. `node scripts/ci-verify.mjs`
  repeated the suite and passed syntax checks for all JavaScript modules.
  `git diff --check` passed.
- **Next target:** Implement Nico Lai as the next source-only V1 Gnome
  character using the shared rendering/specimen boundary.
- **Remote verification:** GitHub Actions run `30454561082` passed all six jobs
  for implementation commit `e472bd7`: Windows and Ubuntu on Node 20.19.1 and
  Node 22, plus Windows NSIS and Ubuntu AppImage package builds.

# 2026-07-29 — Living Sanctum practice floor and Stamina language

- **Player-facing outcome:** FLUX now starts in the rendered Living Sanctum.
  Its Practice chamber launches an authored old-world rune court divided into a
  Stamina circuit, movement cloister, spell court, and mirror ward, with an
  optional stationary target and no competitive/network catalog exposure.
- **Complete test controls:** The live strip switches champions in place,
  restores health, Stamina, Flux, ultimate, cooldowns, and recovery windows,
  resets the floor, opens the full reference, or returns to the Sanctum. `F2`
  toggles movement, elements, selected abilities, champions, and races.
- **Compatibility boundary:** Player-facing FLOW became Stamina across HUD,
  guide, ancestry copy, practice reference, README, and active planning notes.
  Internal `flow` fields remain stable simulation/wire/persistence identifiers.
- **Simulation safety:** `living_sanctum` and mode `sanctum` resolve through the
  normal validated content accessors but remain outside competitive map/mode
  arrays. The target uses the shared entity contract with an explicit idle
  command, and refill is rejected outside active local Sanctum practice.
- **Automated verification:** `npm.cmd test` passed 133/133; `node
  scripts/ci-verify.mjs` independently repeated the suite and all recursive
  syntax checks; `npm.cmd audit --omit=dev` reported zero vulnerabilities; the
  focused simulation/DOM/visual run passed 61/61 and `git diff --check` passed.
- **Rendered verification:** The Windows source Electron runtime rendered the
  full Sanctum at desktop resolution, exposed all eight chambers through UI
  Automation, and closed without a remaining Electron window. Automation could
  focus but not activate Chromium controls, so the interactive movement result
  is sourced from deterministic and DOM tests, not a claimed manual playtest.
  The in-app Browser rendered the menu without horizontal overflow but blocked
  the main local source module (`ERR_BLOCKED_BY_CLIENT`), so it was not used to
  infer live gameplay.
- **Remote acceptance:** GitHub Actions run `30458296343` passed all six jobs
  for implementation commit `e5627ad`: Windows and Ubuntu on Node 20.19.1 and
  Node 22, Windows NSIS, and Linux AppImage packaging. PR #11 merged as
  `09d0257`, and `main` plus `integration/unify-flux` were realigned there.
- **Next:** resume the active V1 Nico Lai visual slice.

# 2026-07-29 — Complete universal Stamina movement

- **Direct exception:** The user's explicit request completed the universal
  movement grammar before V1 resumed. No champion ability, element, damage,
  objective, network rule, AI, or mode was added.
- **Authoritative movement:** Added edge-triggered double jump and slide jump,
  one bounded air redirect, fixed-lane air dodge, late angled wavedash,
  marked-cover vault, and vault-crest superglide alongside the existing sprint,
  counter-strafe, jump, slide, wall jump, landing cut, and Edgeweave kernel.
- **Safety and tuning:** Every transition has centralized Stamina cost, timing,
  steering, cooldown, and speed bounds. New state is reset on respawn, repaired
  at the simulation boundary, checked by invariants, blocked during champion
  mobility/ultimate commitments, and interrupted safely by collision.
- **Authored routes:** Every competitive map and the Living Sanctum now provides
  one or more validated `vaultable` rails with stable IDs and a visible `V`.
  Vaults sweep past only their selected rail, retain every other collision, roll
  back blocked travel, and reject unmarked cover.
- **Controls and teaching:** Added the semantic `technique` command across
  sanitization, Player 1 remapping (`V`), Player 2 (`/`), and gamepad east face;
  `Alt+V` air-dodges. HUD state, feedback, practice copy, controls, and the `F2`
  guide expose every conversion with Stamina language.
- **Verification:** `node scripts/ci-verify.mjs` passed 141/141 tests and all
  recursive syntax checks. Deterministic coverage proves every new transition,
  input-edge and non-stacking rule, collision interruption, unmarked-cover and
  low-Stamina rejection, refill reset, mixed-chain ceiling, all content stress,
  and the eight-agent soak.
- **Visual review:** The source Sanctum rendered at 1280px with no horizontal
  overflow and no browser warnings/errors. Browser automation focused controls
  but did not activate them, so no browser movement-input claim is made.
- **Local package:** `npm.cmd run package:windows:verified` built the exact
  `0ff6eb0` NSIS installer with SHA-256
  `09b09235619d0acfdc18985441777276845aaa97c3933e25b21c958e17286e87`.
- **Remote acceptance:** GitHub Actions run `30462865622` passed all six jobs
  for movement commit `0ff6eb0`: Windows and Ubuntu on Node 20.19.1 and Node 22,
  Windows NSIS, and Linux AppImage packaging. The documentation head repeated
  all six successfully in run `30463176519`; PR #13 merged as `8cd54bb`, and
  `integration/unify-flux` plus `main` were realigned there. Resume V1 Nico Lai.

# 2026-07-29 — Direct-spawn Living Sanctum stations

- **Player-facing outcome:** Removed the separate startup menu. A source launch
  now creates the playable Living Sanctum immediately, with the player standing
  inside the Training Court interaction radius.
- **Diegetic option access:** Added eight authored, visible floor stations for
  training, champions, realm, muster, guide, rites, friends, and settings.
  The nearest station exposes a remap-aware interaction prompt; the tactical
  key or gamepad west button opens that station, and `Escape` returns to the
  same live floor instead of opening a Sanctum pause menu.
- **Contest continuity:** Entering the Sanctum from a local contest suspends and
  restores the exact state. Entering from a remote contest keeps its socket,
  lobby, snapshots, and explicit leave path alive while the local Sanctum runs;
  the Rite Gate returns to that contest without dissolving the company.
- **Interface cleanup:** Removed the always-on practice action bar and moved
  champion setup, target toggle, refill, reset, and guide controls into the
  Training Court station. The legacy navigation rail remains inert and hidden
  only as compatibility markup while current chamber panels are reused.
- **Automated verification:** `node scripts/ci-verify.mjs` passed 139/139
  standard checks, the live WebSocket lifecycle, authenticated cleanup, and all
  recursive JavaScript syntax checks. Focused DOM/simulation coverage passed
  67/67 and proves direct spawn, physical interaction, every station route,
  no Sanctum Escape menu, local/remote suspension, and invariant safety.
- **Windows handoff:** The source Electron app launched fullscreen and remained
  running for the user. Windows app-control inspection was stopped by the
  user's physical `Escape`, so no automated interactive visual acceptance is
  claimed; the running window was left untouched for hands-on play.
- **Next:** After the user's station-layout feedback, resume the ordered V1
  Nico Lai source-only visual slice.

# 2026-07-29 — V1 Nico Lai source implementation

- **User boundary:** The user retained PC control. No Windows application was
  launched, focused, captured, or given input during this slice; observed
  desktop and narrow visual review remains explicitly pending.
- **V1 slice 04 source:** Added Nico Lai as a modular source-only Gnome visual
  with required visual ID `nico`. The inactive overhaul catalog's `nix` ID is
  retained only as `contentCompatibilityId`; neither ID enters the live roster.
- **Read hierarchy:** The high-cap compact ancestry foundation supplies anatomy.
  Nico's measured leather frame and calibrated coil pack supply role, forked
  Charge paths and Light calibration diamonds stay shape-distinct, and a
  detached device uses a visible team tether plus split hit/defeat states to
  communicate ownership and breakability.
- **Six-state contract:** Idle docks and calibrates; move uses segmented charge
  cadence; commit extends the owned device into an open aperture; hit breaks the
  tether and device; defend raises a forward bracket with an open rear; defeat
  collapses the cap/frame and leaves separated coil halves.
- **Isolation:** The shared presentation registry and specimen runner are the
  only consumers. Tests prove `src/game.mjs` imports no overhaul visual registry
  or Nico module; simulation, hitboxes, balance, abilities, networking, normal
  selection, package manifests, and runtime state are unchanged.
- **Verification:** Focused profile, migration, finite animated/static draw,
  six-state registry, responsive specimen, source-route, and runtime-isolation
  checks passed 11/11. `node scripts/ci-verify.mjs` passed 140/140 standard
  checks, the live WebSocket lifecycle, authenticated cleanup, and every
  recursive JavaScript syntax check. `git diff --check` passed.
- **Acceptance boundary:** Source implementation is complete, but the slice is
  not visually accepted because no render was observed. When the user returns
  PC control, review `tools/nico-lai-specimen.html` at desktop and narrow
  widths, including reduced motion and both team marks; revise or accept it
  before beginning Steezo.

# 2026-07-29 — Nico Lai live promotion and champion statistics

- **Observed visual acceptance:** Rendered Nico's six-state board in the local
  browser with no warnings or errors, then launched the real Windows Electron
  source build and inspected the live Living Sanctum and Training Court. The
  compact Gnome body, high cap, coil pack, team tether, Charge forks, Light
  diamonds, ability names, ownership, and health read remained visible at
  gameplay zoom.
- **Startup repair:** The interactive run exposed a real pre-existing boot
  failure: `scripts/serve.mjs` omitted `overhaul-runtime.mjs` and
  `overhaul-content.mjs` even though `match.mjs` imported them. Added both
  explicit routes; the Windows app then booted directly into Sanctum as Nico.
- **Stable promotion:** Replaced Nim Copperspark's presentation with Nico Lai
  while preserving runtime ID `volt`, Gnome ancestry, hitbox, packet/save
  identity, and proven Charge mechanics. Renamed the kit to Coil Dart, Arc
  Chain, Prism Ground, and Coil Hop and connected only the shared overhaul
  renderer registry, never the champion module directly.
- **Simple stat contract:** Added bounded per-champion Health recovery, Flux
  capacity/recovery, and Endurance alongside existing Health and speed. The
  authoritative simulation resolves ancestry plus character values, applies
  5.5-second damage-gated Health recovery, scales Flux/Stamina recovery, and
  exposes Health, Recovery, Flux, Focus, Speed, and Endurance in the Sanctum.
- **Sanctum clarity:** Nico is the default practice entrant. The Training Court
  displays the full stat card and selected-statistics guide next to the complete
  universal movement reference. Landmark labels now use authored positions so
  station and court names do not stack at the map center.
- **Verification:** `npm.cmd test` passed 143/143 checks including complete
  movement chains, health recovery, reconnect preservation, live WebSocket
  lifecycle, cleanup, renderer registry isolation, and stress/soak coverage.
  Recursive syntax checks and focused desktop/visual checks passed; the real
  Windows Sanctum and Training Court opened successfully. Linux/package jobs
  still require the pushed GitHub Actions matrix for this commit.
- **Next:** Implement Steezo as the next source visual slice using the accepted
  Goblin ancestry template and separate Charge/Fire/Light shape language; keep
  the live promotion behind its own observed and deterministic acceptance.

# 2026-07-29 — Current Garuda Odysseus/Aider handoff

- **Canonical entry point:** Added `scripts/linux-agent-handoff.sh` as a small
  dispatcher for setup, doctor, interactive Aider, bounded Odysseus-style runs,
  live Odysseus clipboard handoff, audit discovery, and stop. It delegates to
  the existing audited scripts and introduces no alternate agent path.
- **Current task:** Replaced the stale Urzh state with the reviewed baseline:
  Nico Lai is promoted and Steezo is the next single V1 slice. Both Odysseus and
  Aider are instructed to build Steezo's source-only six-state Goblin
  Charge/Fire/Light specimen and defer runtime promotion until a real Garuda
  visual review supplies evidence.
- **Sway behavior:** `odysseus` automatically copies the live repository,
  branch, commit, status, history, and exact audited run command when
  `WAYLAND_DISPLAY`, `SWAYSOCK`, and `wl-copy` are present; otherwise it prints
  the same handoff. Setup remains the only package/model download phase.
- **Transparency and access:** Execution stays unsandboxed as the current Linux
  user, auto-approves local actions, accepts only loopback Ollama, records the
  full private manifest/transcripts/events/model history/final state/patches,
  may commit verified work locally, and cannot push through the launcher.
- **Verification:** The focused handoff contract passed 3/3. Git for Windows
  Bash parsed every tracked shell script and exercised the dispatcher help plus
  rendered handoff. `node scripts/ci-verify.mjs` passed all 143 checks and every
  recursive JavaScript syntax check. The actual Garuda packages, Ollama service,
  selected GPU backend, Sway clipboard, and local Qwen session remain explicitly
  unverified until run on that host.
- **Next:** On Garuda, create or select a clean non-protected branch, run
  `bash scripts/linux-agent-handoff.sh setup --check`, then doctor and one
  bounded `run --model auto --iterations 1`; inspect the private audit and
  Steezo specimen before allowing a follow-up promotion slice.

# 2026-07-29 — Pixel perspective and movement priority contracts

- **User reference decision:** Inspected the supplied champion board and two
  classic top-down adventure screenshots. Extracted only broad principles:
  compact pixel proportions, three-quarter orthographic readability, tiled
  terrain/elevation, strong value grouping, short readable text, and economical
  elemental motifs. The roster board's outdated labels/ancestries/affinities are
  explicitly non-authoritative, and no reference asset/layout/font/HUD/palette
  may be copied.
- **New first task:** Added `.agent/PIXEL-PERSPECTIVE-OVERHAUL.md` P0-P5. It
  preserves simulation X/Y and feet-anchored hitboxes while establishing virtual
  pixels, integer snapping, nearest-neighbour scaling, layered elevation,
  original material ramps, compact champion silhouettes, shape-first elements,
  and restrained text/HUD. P0 alone is active as source-only tokens plus one
  non-shipping perspective specimen; later slices convert Sanctum, Nico,
  Charge/Light spells, GUI/text, then integrated acceptance.
- **New second task:** Added `.agent/MOVEMENT-INPUT-OVERHAUL.md` M0-M5, blocked
  until P5. The live runtime already owns double/slide jump, wall jump, air
  redirect/dodge, wavedash, vault, and superglide. The planned delta is a
  conventional fully remappable keyboard/controller layout, deterministic body
  lift plus the explicitly requested enlarging ground shadow, full-device
  revalidation, and one original bounded tap-strafe/aerial turn that consumes
  the redirect allowance and can never add velocity.
- **Agent routing:** Updated the visual contract, Odysseus prompt/task/state,
  Aider read set, implementation prompt/matrix, backlog, playable ledger, README,
  and handoff tests to enforce P0-P5 -> M0-M5 -> Steezo. No runtime rendering,
  movement, binding, roster, spell, map, simulation, or network behavior changed.
- **Verification:** The focused handoff contract passed 3/3, every shell script
  parsed with Git for Windows Bash, `git diff --check` passed, and
  `node scripts/ci-verify.mjs` passed all 143 checks plus recursive JavaScript
  syntax validation.
- **Next:** Run one Garuda local-agent P0 iteration, review the original
  perspective specimen at desktop/narrow/grayscale/high-contrast/reduced-motion,
  and accept or revise the foundation before any P1 runtime Sanctum conversion.
