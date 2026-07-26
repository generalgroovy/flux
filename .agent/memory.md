# HEX agent memory

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
