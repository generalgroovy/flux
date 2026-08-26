# FLUX2 agent worklog

## 2026-08-26 - shared hand-cast phase cue

Playable outcome:

- The foundation spell presenter now reads the validated delivery skeleton phase
  at runtime and layers a small origin ring during `startup` plus a directional
  release flash during `release` at the champion's empty hand.
- The cue is shared by projectile, beam, spray and field profiles, uses the
  existing element ramps and reduced-effects alpha, and leaves spell-specific
  silhouettes and all authoritative timing/outcomes untouched.

Verification:

- `scripts\\test.cmd`: 54 suites, 18,676 assertions, zero failures; source
  boots at 60/120 Hz. Expected legacy archive image-load warnings remain.
- `scripts\\capture-visual.ps1 -Name post-unify-v9-hand-cue-v2 -Resolution
  '1280x720' -TickRate 60 -Frames 8 -GameArguments
  @('--camera-zoom=75','--champion=oh_tipi','--capture-cast-slot=1',
  '--capture-chain-slot=2','--capture-pointer=900,720')` passed with eight
  truthful frames.

Next slice:

- Continue V4 spell readability review with the same phase contract; keep the
  visual gate closed to new mechanics until integrated acceptance is evidenced.

## 2026-08-26 - source-court approach accents

Playable outcome:

- Added six data-authored Nexus source-court accents (two lanterns, two
  planters, and two elemental runes) to the presentation-only architecture kit.
- Decorations validate their kind, element, scale, and interior offset against
  the court footprint; invalid or out-of-bounds content fails closed.
- Rendering uses shared visual-language ramps, shallow shadows, and reduced
  effects alpha. The layer is drawn after pavers and cannot change topology,
  collision, routes, station radii, or simulation state.

Verification:

- `scripts\\test.cmd`: 54 suites, 18,674 assertions, zero failures; source
  boots at 60/120 Hz. Expected legacy archive image-load warnings remain.
- `scripts\\capture-visual.ps1 -Name post-unify-v9-720 -Resolution
  '1280x720' -TickRate 60 -Frames 4 -GameArguments
  @('--camera-zoom=75','--champion=oh_tipi')` passed with four truthful frames.
- Additional captures passed at 1280×720/50%, 1280×720/100%, 1920×1080/75%,
  and a 20-frame 1280×720/75% startup/chain cast review; all dimensions and
  frame counts were verified by the capture harness.
- `scripts\\package.ps1 -Target Windows` rebuilt the package from `main`
  commit `b6756ae`; installer SHA-256 is
  `58c0ea2a0d71d1bc53f85adcd7ffe2f222df140d0a49e067bf50882b71b0c8ea` and
  portable ZIP SHA-256 is
  `f1b00aabd06c73051a0b19c884fe93cd060b6bb43abb3aa1144f3150a3b5e9b9`.
- `exports\\windows\\flux2.exe --headless --quit-after 3 --fixed-fps 120 --
  --tick-rate=120` exited 0 and printed the current visual/content hashes.

Next slice:

- Continue C2 visual review with the integrated source-court readability pass;
  do not advance to new mechanics until visual acceptance evidence is updated.

## 2026-08-26 - central visual registry and diagnostic hash

Playable outcome:

- Registered `spell_animation_skeletons_v1.json` in the central visual asset
  registry and validate it through the same fail-closed loader used by the
  foundation spell presenter.
- Exposed the skeleton manifest hash in the Windows bootstrap diagnostic line,
  making visual-content drift visible in handoff logs and captures.

Verification:

- `scripts\\test.cmd`: 54 suites, 18,671 assertions, zero failures, with
  Windows source boots at 60 and 120 Hz.
- Runtime diagnostics now include `spells <profile-hash>/skeleton
  <skeleton-hash>`; legacy archive image-load warnings remain expected.
- `scripts\\package.ps1 -Target Windows` rebuilt the unified package at
  `c124cec`; installer SHA-256 is
  `dbd1a6253473b3f0a345209c71651318cbbccadb9f6d2073cb5bf780237e2d78` and
  portable ZIP SHA-256 is
  `7fbbf6d445a1b7361a1e8245ced2a0bb4b5099f63c32238fe556cfe596c80b81`.
- The exported `exports\\windows\\flux2.exe` boots headlessly at 120 Hz and
  prints the skeleton hash beside the spell profile hash.

Next slice:

- Continue the C2/V9 visual acceptance with source-court environment review;
  the current package is ready for a trusted Windows playtest.

## 2026-08-26 - reusable spell delivery animation skeletons

Playable outcome:

- Added `SpellAnimationSkeletonLibrary` and a versioned visual manifest covering
  projectile, beam, spray and field delivery families.
- Each family now declares contiguous bounded startup, release, travel, impact
  and residue phases with a draw-family and readability cue; foundation spell
  profiles reference the matching family by `skeleton_id`.
- `FoundationSpellPresenter` validates the cross-layer shape contract and fails
  closed on a missing or mismatched skeleton. No simulation timer, collision,
  cost, cooldown, damage or outcome was changed.

Verification:

- `scripts\\test.cmd`: 54 suites, 18,669 assertions, zero failures, with
  Windows source boots at 60 and 120 Hz.
- Existing body-only captures and package evidence remain valid; a new package
  rebuild is required after the next consolidated commit.

Next slice:

- Continue C2 with live body/effect composition and accessibility/reduced-effects
  acceptance, then author the reusable Wellspring source-court environment kit.

## 2026-08-26 - data-driven body atlas row assignment

Playable outcome:

- Moved champion-to-row selection out of `cartoon_champion_presenter.gd` and
  into the validated visual recipe as `atlas_row`.
- Oh Tipi and S. Wayne now explicitly declare rows `0` and `1`; future
  body-only champions can reuse the atlas contract through content data without
  renderer branching.
- Validation rejects missing or out-of-range rows, and the presenter returns an
  empty region instead of drawing an invalid cell.

Verification:

- `scripts\\test.cmd`: 53 suites, 18,644 assertions, zero failures, with
  Windows source boots at 60 and 120 Hz.
- Existing visual captures, body-only provenance and installer limitations
  remain unchanged; the next packaged installer must be rebuilt after this
  content/renderer commit.

Next slice:

- Continue C2 visual acceptance with live body/effect composition review at
  50/75/100% and accessibility/reduced-effects captures before unfreezing
  gameplay/chemistry work.

## 2026-08-26 - canonical three body types and body-only champion layer

Playable outcome:

- Reworked the current body taxonomy to exactly `small`, `middle`, and `large`.
  Legacy `tiny`, `medium`, and `huge` values are mapped only at compatibility
  boundaries and cannot enter new champion or skeleton data.
- Assigned Oh Tipi to `middle` and S. Wayne to `small`; the skeleton manifest,
  champion catalog, fallback adapter and tests now share the same contract.
- Promoted an original body-only foundation atlas for both champions. South/front
  poses face the camera symmetrically, east is authored profile, west mirrors
  east, north/back is centered, and jump/cast/hit cells preserve the same pivot.
- Removed the old procedural staff/trident and floating-orb fallback. If the
  body atlas is unavailable, the presentation adapter fails closed rather than
  silently reintroducing forbidden props or effects.
- Documented the reusable layer boundary: body/clothing pixels are independent
  from hands-cast effects, spells, projectiles, auras, shadows, environment,
  tools and equipment.
- Added bounded visual scale tokens (`small` 0.90×, `middle` 1.00×, `large`
  1.10×) around the shared feet pivot; simulation radius, hitboxes and outcomes
  remain unchanged.
- Routed local and remote spell-startup visuals through a deterministic
  forward empty-hand origin (`27 px` above the feet pivot with bounded aim and
  side offsets), keeping the body atlas free of magical pixels.

Files and contracts:

- `content/visual/foundation_champion_visuals_v1.json` schema 2,
  `foundation-champion-visuals-v2-body-only`;
- `assets/sprites/champions_v3/foundation/source_sheet_body_v3.png`;
- `assets/sprites/champions_v3/foundation/runtime_atlas_body_v3.png`;
- `assets/sprites/champions_v3/foundation/README.md` and `provenance.json`;
- README, visual overhaul/implementation prompts, sprite pipeline, visual
  system, cast and Wellspring visual-production docs;
- exact source/runtime/imported hashes are repeated in `.agent/memory.md`.

Verification:

- `scripts\\test.cmd`: 53 suites, 18,642 assertions, zero failures, with
  independent Windows source boots at 60 and 120 Hz.
- `scripts\\capture-visual.ps1` produced truthful 1280×720 four-frame captures
  at 50%, 75% and 100% zoom under `.godot/visual-captures/body-v3-*`; Oh Tipi
  (50%/75%) and S. Wayne (100%) were inspected.
- A 24-frame 1280×720 hand-cast capture at 75% (`.godot/visual-captures/hand-cast-v2-720`)
  was inspected; startup art now visibly begins in the empty-hand lane before
  the projectile leaves the actor.
- High-contrast S. Wayne and reduced-effects Oh Tipi 1280×720 captures at 75%
  (`body-v3-high-contrast-720`, `body-v3-reduced-720`) both passed and were
  inspected; body silhouettes, resource bars and spell cells remain readable.
- `scripts\\package.ps1 -Target Windows` rebuilt the export and one-file
  release bundle. The current installer is
  `exports\\release\\FLUX2-Windows-Setup.exe` (SHA-256
  `f78c0463adcf3740adab6aac58a676a3ac5c5f41f01db866ca609e21f3ed640d`). The
  exported `exports\\windows\\flux2.exe` boots headlessly at 120 Hz.
- `scripts\\test-windows-bootstrap.ps1` reached the installer launch but this
  host's Device Guard policy blocked the unsigned installer binary, including
  from `%TEMP%`; the failure is environmental and is retained as an explicit
  release limitation rather than marked as a pass.
- New migration assertions cover every legacy body path and canonical mapping.
- The body source was visually inspected at source and runtime resolution; no
  spell, element, particle, aura, shadow, environment or held focus pixels are
  present in the atlas.

Known limitations and next slice:

- The atlas is a validated integrated candidate, not a final 24-character art
  promotion; full visual acceptance still needs live 50/75/100% captures and
  accessibility/reduced-effects review.
- Legacy v2 race inventories still exist as archived compatibility assets and
  intentionally retain old path names; their loaders now expose canonical body
  mapping so new runtime content cannot grow a fourth type.
- Continue the visual gate with live body/effect composition and
  accessibility/reduced-effects acceptance before resuming frozen
  gameplay/chemistry work. Re-run the installer lifecycle on a Windows machine
  without Device Guard blocking unsigned local binaries.

## 2026-08-26 - quiet, code-page-safe Windows launch

Playable outcome:

- Replaced every non-ASCII status character in the one-file bootstrapper and
  portable friend-build front door with plain ASCII, avoiding mojibake on
  Windows systems that still launch through a legacy console code page.
- Added a lifecycle acceptance assertion that rejects any future non-ASCII byte
  in the shipped command launcher, friend README or bootstrapper source.
- Disabled the repeatedly failing Linux-only `Godot foundation` GitHub workflow
  after confirming 24 consecutive push failures were driving account email;
  no queued or running copies remained. The checked-in successor is deliberately
  manual, Windows-only and installs the official pinned/checksummed engine.

Verification:

- `scripts\\test.cmd`: 53 suites / 18,626 assertions, zero failures, followed by
  independent 60/120 Hz source boots.
- `scripts\\test-windows-bootstrap.ps1`: ASCII contract, clean install, repair
  and installed export boot passed.
- The noisy workflow remains disabled in repository settings; local Windows
  gates remain authoritative until a maintainer deliberately enables and runs
  the manual replacement.

Known limitations and next slice:

- GitHub may retain already-sent historical failure emails, but no automatic
  workflow trigger remains to create new copies. Resume the active C2 whole-
  scene visual-cohesion review without changing simulation rules.

## 2026-08-26 — export-safe nine-element projectile art

Playable outcome:

- Detected that both imported burst-v2 PNG streams were truncated/undecodable;
  removed that unusable package and its failing helper from the active tree.
  The originals remain recoverable at commit `3f79847`.
- Used the built-in image-generation workflow to create a new original,
  transparent nine-element style board, saved project-locally under
  `reference/art/projectiles/burst_v3/` with its production prompt.
- Added a deterministic v3 generator that crops the ordered 3×3 board, anchors
  each projectile on its luminous core, bounds its palette, creates
  spawn/travel/impact/residue phases and derives exact mirrored eight-direction
  rows into nine 512×256 runtime sheets.
- Added an export-safe, fail-closed manifest/presenter. It validates provenance,
  source/generator/asset hashes, grid, pivot, phases, symmetry, blank migration
  cells and memory/disk budgets while explicitly refusing collision authority
  or release approval.
- Integrated the presenter ahead of procedural fallbacks so Arc Primary,
  Vector Lance, Rillshot and Eclipse Disc now use their elemental animation;
  the simulation radius remains visible and ricochet pips remain explicit.

Verification:

- `scripts\\test.cmd`: 53 suites / 18,626 assertions, zero failures, including
  66 new atlas assertions, followed by independent source boots at 60/120 Hz.
- `burst-runtime-v3-rillshot-75`: 20 truthful 1280×720 frames; inspected Water
  travel at default 75% zoom with its core, direction and hit ring readable.
- Windows export and setup generation passed. Packaged GPU safe quit loaded
  burst hash `fa35baa91783`, flushed local state and closed the network peer.
- Setup payload `0.1.0-dev-5c21b55e49-890cf994f9`, SHA-256
  `00b2e51b2e477311102ad7c476644fd371e8c68eb8d9f1c8844988bd946291a1`.

Known limitations and next slice:

- This accepts the runtime projectile-art foundation, not final C2 scene
  cohesion. Review both champions and live projectiles at 50/75/100% under
  standard/high-contrast/reduced profiles, reconcile stale player-facing
  character metadata, then pressure-test five lanes without changing rules.

## 2026-08-26 — Windows lifecycle and in-world friend address

Playable outcome:

- Added a focused type/paste editor directly to the **Join Farflow** station.
  It validates and saves one host/IP locally, supports Enter/Escape and
  controller accept/cancel, and preserves the CLI override for automation.
- Advanced preferences to schema 9 with fail-closed host-address validation and
  schema-v8 migration to the safe `127.0.0.1` default.
- Removed the Windows packaging dependency on `Get-FileHash` by centralizing a
  disposable-stream .NET SHA-256 helper across packaging, bundling, bootstrap
  compilation and installer-update acceptance.
- Extended the installer journey to install a distinct baseline first, prove an
  atomic current-version switch, retain the recoverable old version, repair the
  current payload and boot the installed export.
- Narrowed active release acceptance to Windows while preserving existing Linux
  source and scripts unchanged for a later reopened scope.

Verification:

- `scripts\\test.cmd`: 52 suites / 18,560 assertions, zero failures, followed by
  independent source boots at 60 and 120 Hz.
- The reviewed 1280×720 capture `farflow-join-address-v1` shows the live address
  editor, saved-local notice, keyboard controls and UDP port in the world panel.
- Fresh setup payload `0.1.0-dev-5a59a2cf68-bc04b7b4f7`, SHA-256
  `dcdf7e45d88157164f3af1b5993ab2dc8524d08151592e130801073752d56b7a`.
- Baseline update `0.1.0-dev-872b62227a-c08c59e8c4` → current, repair and
  installed export boot passed; packaged GPU safe quit flushed local state and
  closed its peer.
- Packaged 120 Hz Farflow journeys passed Open Commons (8 places), Sparring
  Circle (4) and Duel Knot (2) on UDP 24914–24916, including HELLO, movement
  reconciliation, Hearth/Court flow, exact-actor return, rematch and host
  stewardship; capacity-8/4 journeys also proved late-join spectating.

Known limitations and next slice:

- The development setup is unsigned and direct-IP internet play still requires
  manual UDP forwarding; no signing, relay, NAT traversal or physical two-PC
  acceptance is claimed. Proceed to C2 burst-atlas/runtime visual cohesion.

## 2026-08-23 — impact agency, recovery choice and Momentum Chime

Playable outcome:

- Reordered the standing continuous directive to gameplay/movement → reusable
  animation/environment → live element chemistry → chemistry-integrated spell
  expansion, and made the overlap rule explicit: begin the next safe slice seed
  after acceptance but before committing the current checkpoint.
- Replaced dead authored-launch input with bounded fixed-point directional
  influence. Natural expiry or cover collision enters a 220 ms impact brace at
  42% retained speed; ordinary movement cannot erase it, while buffered V plus
  direction spends exactly 18 Stamina to tech out at 360 px/s.
- Added explicit `IMPACT_RECOVERY` simulation, prediction, canonical state,
  transition and presentation coverage. Movement tuning v3 and transition
  hashes are `ae4a36ec23e4` and `29cd46fd167e`.
- Added the twelfth Wellspring station, **Momentum Chime**, in the Conservatory.
  Its protocol-28 request is proximity- and host-validated, launches only a free
  champion, refuses repeat triggers during launch/recovery, and replicates a
  readable confirmation/refusal without giving the client outcome authority.
- Began the ordered animation/environment successor before checkpointing: a
  data-driven `recovery_brace` accent draws restrained inward arcs and a ground
  mark, scales through Stamina intensity and remains legible in reduced effects.

Verification:

- `scripts\\test.cmd`: passed 52 suites / 18,428 assertions, import validation
  and independent 60/120 Hz source boots at protocol 28. Movement owns 951
  assertions; the 26-assertion Conservatory route now proves the exact Chime
  launch, steering, recovery and tech against authored campus collision at both
  tick rates, and request policy covers launch/recovery retrigger refusal.
  Existing editor-time image-loading warnings remain visible and do not conceal
  a suite or boot failure.
- `scripts\\smoke-farflow.cmd -TickRate 120 -Port 24936 -Charter open_commons
  -TimeoutSeconds 60`: passed host/join, shared HELLO, reconciliation,
  Hearth-to-Court, late-join observation/Hearth handoff, exact-actor return,
  Round 2 and reason-bearing stewardship. An earlier 20-second run expired late
  under local load without a Godot error; the bounded 60-second rerun completed.
- `scripts\\capture-visual.cmd -Name momentum-chime-v1-720 -Resolution 1280x720
  -Frames 4 --capture-spawn=720,720 --capture-expanded-station=momentum-chime
  --camera-zoom=75`: passed and was inspected; the station, binding, three-step
  drill explanation, champion, route context and compact HUD remain readable.
- Capture-only `--capture-movement=impact_recovery` produced and was inspected
  at 75% and 100% zoom; the cyan brace arcs remain distinct against buildings
  and terrain without changing movement authority.

Known limitation and next slice:

- These values are deterministic first-feel candidates, not a hands-on balance
  claim. Physical controller/sensitivity/deadzone review and complete authored
  Conservatory route acceptance remain the movement exit evidence. Continue
  there, deepen natural action phases and route affordances, then promote one
  bounded live chemistry reaction before adding chemistry-aware Water spells.

## 2026-08-21 — global Spell Loom and cooldown authority

Playable outcome:

- Replaced champion-local Spell Loom roles with a stable global runtime library.
  Both current champions can weave Arc Primary, Vector Lance, Rillshot, Tideline,
  Rimewake, Eclipse Disc and Pocket Eclipse into any Plain/Ctrl/Alt 1–4 position;
  the five remaining positions stay explicitly empty and resource-safe.
- Added twelve canonical per-position cooldown values. Cooldown state follows
  spell identity through swaps, all globally woven spells cast through the same
  authoritative startup/Flux/cooldown path, and the three legacy kit cooldown
  properties remain migration adapters rather than the source of new rules.
- Advanced the wire boundary to protocol 27 / snapshot schema 11. Every snapshot
  validates and replicates all twelve wire IDs plus twelve cooldowns, requires
  a unique runtime-proven subset, and rejects duplicates, unknown wires, malformed
  timers and obsolete peers before they can share play. A spell outside the
  selected twelve can replace a position, so the architecture remains valid when
  the global library grows beyond twelve entries.
- Replaced the three-role request encoding with a bounded twelve-by-48 catalog
  lane. Clients send only a position/library intent; the host resolves canonical
  wire order at authoritative Spell Loom proximity. Catalog-only and out-of-range
  requests still fail closed.
- Updated the Loom sheet to show a compact three-spell scrolling picker, mark
  champion-origin versus global spells, and present selected cost, cooldown,
  shape, delivery and sealed material intent without expanding the live HUD.

Verification:

- `scripts\\test.cmd`: passed 52 suites / 18,160 assertions, import validation
  and clean 60/120 Hz source boots. Tests cover global ordering, champion switch,
  honest empties, cooldown identity through swaps, schema-11 round-trip, request
  bounds and the maximum one-MTU snapshot fixture.
- `scripts\\smoke-farflow.cmd -TickRate 120 -Port 24935 -Charter open_commons
  -TimeoutSeconds 40`: passed host/join, reconciliation, Hearth/Court, late-join
  observation, exact-actor reconnect, Round 2 and reason-bearing stewardship.
- `scripts\\capture-visual.cmd -Name global-spell-loom-v1p2-720 -Resolution
  1280x720 -Frames 4 --capture-expanded-station=spell-loom --camera-zoom=75`:
  passed; reviewed frame clearly shows all seven occupied global slots, five
  honest empties, the three-item picker and selected spell detail.

Known limitation and next slice:

- This completes global configuration authority, not the planned 48-spell
  library. Seven spells across Charge, Water, Ice, Dark and Light are live.
  Water is the next complete slice: Rillshot and Tideline remain its pressure
  and control anchors; one movement/utility and one high-commitment spell must be
  promoted through simulation, presentation, Loom, network and acceptance gates.

## 2026-08-21 — positive-Flux fast combat economy

Playable outcome:

- Promoted ability schema 3 with a canonical economy contract: Flux is the only
  spell resource, every runtime spell costs at least one Flux, recovery waits
  700 ms after spend, and pressure/tempo/control cadence tiers fail closed.
- Removed free offense. Arc Primary costs 7 Flux, Rillshot 6 and Eclipse Disc
  8; semantic insufficient-Flux presses refuse visibly and held-primary polling
  stays quiet. Every cast—including a basic attack—pays before startup.
- Retuned action-specific cooldowns without adding a global lock: Arc 200 ms,
  Rillshot 180 ms, Eclipse Disc 230 ms, Vector Lance/Tideline 900 ms, Pocket
  Eclipse 1,000 ms and Rimewake 1,800 ms. Active costs are 24/20/18/24 Flux.
- The compact HUD now shows each spell's positive cost and distinguishes
  `FLUX WAIT 0.7s` from `FLUX RISING`. Oh Tipi and S. Wayne deterministic
  pressure fixtures exhaust exact full reserves inside five seconds, allow no
  free cast, then regain and repay one cast after deliberate recovery.
- Ability/champion compatibility hashes changed through canonical content; the
  existing handshake refuses old economy builds without a protocol/schema
  packet change.

Verification:

- `scripts\\test.cmd`: passed 52 suites / 18,143 assertions plus source/import
  validation and clean 60/120 Hz boots; ability hash `52bbbdc1f5c8` and
  champion hash `3ee4c0016c4e`.
- `scripts\\smoke-farflow.cmd -TickRate 120 -Port 24932 -Charter open_commons
  -TimeoutSeconds 60`: passed the full host/join through stewardship journey.
- `scripts\\capture-visual.cmd -Name economy-v1-oh-tipi-720 -Resolution
  1280x720 -Frames 30 --capture-spawn=640,720 --capture-pointer=1000,720
  --capture-cast-slot=1 --champion=oh_tipi --pov-mode=full --camera-zoom=75`:
  passed; reviewed frame shows `RILLSHOT · 6 F`, 98/104 Flux and `WAIT 0.5s`.
- HUD affordability is boundary-tested in simulation milli-units: a 6-Flux
  spell is unavailable at 5,999 and available at exactly 6,000.

Known limitation and next slice:

- These values are a deterministic first balance candidate, not a claim of
  hands-on competitive balance. The next slice begins the global library with
  one complete four-role element rather than scattering catalog-only spells.

## 2026-08-21 — explicit universal movement/spell transitions

Playable outcome:

- Added `action-transition-matrix-v1`, a fail-closed, canonical policy covering
  all twenty live movement/control modes and all four live spell shapes. The
  simulation owns the policy; presentation only translates its bounded refusal
  vocabulary.
- Removed the implicit global post-cast recovery lock. A different spell may
  begin during presentation recovery when its own cooldown, Flux and physical
  control state permit it, while walking, jumping and advanced movement remain
  live throughout startup and recovery.
- Preserved one visible startup execution channel. A second pressed spell is
  refused as `startup_commitment`; launched, grappled, charging, stunned and
  rooted states name their exact physical refusal; empty, kit, Flux and own-
  cooldown failures are equally explicit and never spend resources.
- Included the canonical transition hash in state hashing, Farflow
  compatibility and boot diagnostics so different action contracts cannot join
  silently. Added deterministic simultaneous jump/cast, moving startup,
  recovery chain, occupied-startup, rooted and cooldown fixtures at 60/120 Hz.
- Added `--capture-chain-slot=1..12` for repeatable two-press presentation
  evidence. The reviewed 1280×720, 75% frame visibly reports `FINISH WEAVE`
  while retaining movement and the four-cell HUD.

Verification:

- `scripts\\test.cmd`: passed 52 suites / 16,104 assertions, source/import
  validation and clean 60/120 Hz boots; transition hash `7e09aa303455`.
- `scripts\\smoke-farflow.cmd -TickRate 120 -Port 24931 -Charter open_commons
  -TimeoutSeconds 60`: passed host/join, reconciliation, round, late join,
  rematch, reconnect and stewardship.
- `scripts\\capture-visual.cmd -Name transition-v1-startup-refusal-720
  -Resolution 1280x720 -Frames 24 --capture-spawn=640,720
  --capture-pointer=1000,720 --capture-cast-slot=1 --capture-chain-slot=3
  --champion=oh_tipi --pov-mode=full --camera-zoom=75`: passed and inspected.

Known limitation and next slice:

- Startup remains a deliberate single-channel commitment and held-primary
  cooldown polling stays quiet to prevent feedback spam. With hidden global
  recovery removed, the next slice gives every offensive cast positive Flux
  cost and retunes action-specific cadence/recovery around fast decisions.

## 2026-08-21 — crisp ordinary movement response

Branch: `codex/continuous-overhaul`

What changed and why:

- Replaced the legacy 360 px/s ordinary profile with a measured 324 px/s
  candidate (10% lower steady speed), raised acceleration from 1,800 to 1,980
  px/s², braking from 2,400 to 3,000 px/s² and counter-strafe response from
  1.7× to 1.9×. Advanced movement speeds, costs, windows and ceilings are
  unchanged.
- Replaced the old high fixed opposing-dot threshold with an explicit low-speed
  threshold, so a genuine opposing input receives counter-strafe response even
  during early acceleration or late braking.
- Kept canonical WALK state active while residual physical speed remains above
  20 px/s, then returns to IDLE at rest. The compact body motion scales from
  actual velocity, removing full-stride skating during acceleration/braking.
- Added one editable `counter_strafe` heel-plant accent to the existing minimal
  motion catalog. It appears only while facing opposes residual velocity,
  respects reduced effects and owns no displacement or legality.
- Added deterministic `brake` and `reverse` visual-capture modes and a dedicated
  open-space response fixture. The full movement tuning profile now contributes
  a stable hash to Farflow compatibility and the boot diagnostic, so builds with
  different movement rules cannot silently share a session.

Measured response:

| Metric | Legacy 60/120 Hz | Candidate 60/120 Hz |
| --- | ---: | ---: |
| One-second walk | 327 / 325.5 px | 300.15 / 298.825 px |
| Release drift | 24 / 25.5 px | 14.9 / 16.15 px |
| Reversal drift before crossing zero | 18.2 / 19.69 px | 11.33 / 12.63 px |
| Reversal time | 133 / 125 ms | 100 / 91 ms |

Validation:

- Full validation passed with 16,015 assertions across 51 suites and zero
  failures; independent 60/120 Hz source boots published the same movement hash
  `5ee38bfb07f2`.
- The existing advanced Conservatory route, all movement techniques, replay,
  prediction/reconciliation and combat suites remain green at both tick rates.
- Truthful 1280×720 captures were reviewed at 50%, 75% and 100% camera scales:
  `.godot/visual-captures/movement-v1-brake-50-final`,
  `movement-v1-reverse-720-final` and `movement-v1-reverse-100-final`.
- The complete 120 Hz Farflow journey passed on UDP 24930 with the movement hash
  in the compatibility identity.

Known limitation: deterministic metrics and frame review establish a safe
candidate, but the user's hands-on A/B feel check remains the final tuning
authority. Universal movement/spell transition work is the next slice.

## 2026-08-21 — V6 integrated visual and accessibility acceptance

Branch: `codex/continuous-overhaul`

What changed and why:

- Added a fail-closed accessibility catalog and one-pass screen filter. Standard
  play pays no filter pass; high contrast is player-facing, while grayscale,
  protanopia, deuteranopia and tritanopia are explicitly review simulations,
  not medical correction claims.
- Migrated preferences to schema 8 with a strictly validated high-contrast
  choice. The in-world Controls Lectern now exposes reduced effects and high
  contrast through M/H or controller L3/R3, saves normal player choices, and
  keeps their current state visible without adding a detached menu.
- Routed champion, environment, spell, field, projectile, cue and reconciliation
  presentation through one reduced-effects query. Effect damping preserves
  authoritative timing, geometry, target response and refusal information.
- Made command-line presentation overrides transient. Visual captures no longer
  rewrite the normal player profile on exit; the user profile accidentally
  changed by an earlier cone-POV diagnostic was restored to its prior full-view
  value before final verification.
- Extended the bounded Windows capture harness with a real two-process Farflow
  mode. The movie process is the visual host, a hidden guest joins and sends the
  ordinary shared greeting, and the harness requires host-side join/emote logs,
  truthful frames, exact dimensions and clean process ownership.

Validation and reviewed evidence:

- Full headless/source validation passed with 15,991 assertions across 50
  suites and zero failures; independent 60/120 Hz source boots passed.
- The complete 120 Hz Farflow journey passed on UDP 24929: host/join, shared
  HELLO, movement reconciliation, Hearth-to-Court round, late-join observation,
  Hearth handoff, exact-actor return, rematch and reason-bearing stewardship.
- Reviewed standard and grayscale 1280×720 frames are under
  `.godot/visual-captures/v6-acceptance-720-*-final`. Common color-vision
  simulations, high contrast, reduced Rimewake, geometry/POV alignment and the
  1920×1080 two-process host view are recorded in the corresponding
  `v6-acceptance-*` directories. These remain ignored diagnostic artifacts.
- The 1080p paired frame visibly contains both champions, `2/8` host state and
  the guest's source-anchored `HELLO!`; the harness also verified the real
  network events rather than accepting a capture-only bubble.

Integrated engineering rubric (1–5):

| Cohesion | Silhouette | Material identity | World overview | HUD clarity | Animation response | Spell readability | Mean |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 4.5 | 4.5 | 4.5 | 5.0 | 5.0 | 4.0 | 4.5 | 4.57 |

This clears the V6 engineering threshold (no category below 4.0, mean at least
4.5) and opens measured movement work. It does not declare the art final:
animation response is the weakest scored category and remains a continuing
polish constraint for every subsequent playable slice. Existing bulk-catalog
image-loader warnings predate this slice.

## 2026-08-21 — V5 Wellspring interaction and compact-HUD language

Branch: `codex/continuous-overhaul`

What changed and why:

- Added a fail-closed, presentation-only interaction language for every live
  Wellspring station kind. Compact prompts, expanded station sheets, social
  bubbles and notices now share bounded parchment geometry, source tethers,
  station crests and the existing visual ramps without changing commands,
  proximity, authority or simulation.
- Localized the interaction-key capsule from the saved keyboard binding instead
  of leaving a hard-coded `F`, kept prompts below the top HUD and above the
  bottom HUD, and made the presentation stable at 50/75/100% camera zoom.
- Refined the four-cell combat HUD with compact Oh Tipi/S. Wayne portrait
  medallions, stepped old-world frames, element-shape glyphs, resource tick
  marks and explicit low-Flux/cooldown states. Health, Flux, Stamina, active
  Plain/Ctrl/Alt layer and four spells remain its only permanent combat data.
- Removed the decorative gray strip above the Wellspring while preserving the
  same non-playable/collision boundary.
- Added a sandboxed Windows visual-capture wrapper. It validates the requested
  name/resolution/frame count, copies only bounded source/import caches to a
  temporary project, changes only that copy's viewport, verifies every PNG's
  real dimensions and removes only its verified temporary directory.

Validation:

- Full headless suite passed with 15,965 assertions across 49 suites and zero
  failures; Windows import and independent 60/120 Hz source boots passed.
- Truthful four-frame captures passed at 1280×720 and 1920×1080. Reviewed
  evidence is under `.godot/visual-captures/v5-acceptance-720-social-final`,
  `v5-acceptance-1080-expanded-final` and
  `v5-acceptance-1080-social-final`; these are ignored diagnostic artifacts.
- The complete 120 Hz three-process Farflow journey passed on UDP 24916 with
  host/join, shared HELLO, movement reconciliation, Hearth-to-Court travel,
  late-join spectating/Hearth handoff, exact-actor reconnect, rematch and
  reason-bearing stewardship. The supported 60-second allowance was required;
  the first 20-second run exhausted one shared script deadline during late join.

Known limitations and risks:

- V5 is engineering-complete, not final visual acceptance. V6 must still score
  live grayscale/color-vision readability, high-contrast and reduced-effects
  parity, integrated spell/combat hierarchy and a two-player frame journey.
- Existing bulk-catalog image-loader warnings predate this slice.

## 2026-08-21 — V4 five-spell runtime presentation

Branch: `codex/continuous-overhaul`

What changed and why:

- Added one fail-closed, presentation-only visual catalog and presenter for all
  five playable foundation spells. It validates exact ability wire, shape,
  element and residue alignment and refuses duplicate startup silhouettes.
- Rillshot now gathers and travels as a split-wake Water drop with a layered
  splash; Tideline rises and releases as a seven-lane curling fan with a breaker
  impact; Rimewake grows a frost sigil into a persistent crystal field and star
  trigger; Eclipse Disc gathers orbiting crescents and travels as a Dark/Light
  disc; Pocket Eclipse focuses paired rails into a cover-bounded dual beam and
  endpoint diamond.
- Derived startup progress from authoritative pending-cast ticks and action
  geometry from existing projectile, field and semantic endpoint state. The
  presenter cannot mutate simulation, collision, timing, costs or outcomes.
- Preserved readable cooldown/Flux state in the four-cell HUD, routed refusal
  events through their actual wire ID, layered impacts above the training target
  and removed the unreachable legacy Pocket Eclipse projectile art branch.
- Added explicit capture-only cast diagnostics. They report pending wire/ticks,
  live projectile/field counts and semantic events only when the existing
  `--capture-cast-*` harness is requested.

Validation:

- Full headless suite passed with 15,934 assertions across 48 suites and zero
  failures; Windows import and independent 60/120 Hz source boots passed.
- Explicit 60/120 Hz Rimewake and Pocket Eclipse cast boots passed with matched
  authoritative release positions/endpoints and no script/runtime errors.
- Live 1280×720 default-75% captures under `.godot/v4-acceptance-720-*` cover
  every spell; separate target captures prove projectile travel and actor-hit
  layering. The attempted 1920×1080 movie override still emits the authored
  1280×720 viewport and is not claimed as 1080p evidence.
- The full 120 Hz three-process Farflow spectator, Hearth, round, reconnect,
  rematch and stewardship journey passed on UDP 24914.

Known limitations and risks:

- V4 is engineering-complete but remains subject to the integrated V6 charm and
  accessibility score, including a real 1080p harness; V5 station/prompt/bubble
  review is the next legal slice.
- Existing bulk-catalog image-loader warnings predate this slice.

## 2026-08-21 — V3 three-district and zoom acceptance pass

Branch: `codex/continuous-overhaul`

What changed and why:

- Reviewed live garden, Nexus and proving-quarter captures plus 50/75/100%
  Nexus frames and a near-building cutaway frame on the modular V3 renderer.
- Increased only scenic-edge tree/bush scale through each validated natural-map
  profile so vegetation survives overview zoom while routes still draw above it
  and gameplay actors remain topmost.
- Added a bounded waypoint-label exclusion radius. A player standing on a
  purpose marker now keeps a clear silhouette while the marker remains visible
  and the next useful nearby labels can still render.

Validation:

- Full headless suite passed with 15,911 assertions across 47 suites and zero
  failures; Windows import and independent 60/120 Hz source boots passed.
- Final same-state captures are under `.godot/v3-acceptance-*`; they cover every
  district, all supported zoom levels and the deterministic partial cutaway.
- The V3 engineering deliverable now covers the source court, paths, water,
  academy facades, target, spell station and near scenic edges. Subjective final
  cohesion remains part of integrated V6 review rather than hidden as a pass.

Known limitations and risks:

- V4 existing-spell presentation is now the next legal slice; movement,
  networking, economy and roster work remain frozen through V6.
- Existing bulk-catalog image-loader warnings predate this slice.

## 2026-08-21 — modular Wellspring architecture and source-court slice

Branch: `codex/continuous-overhaul`

What changed and why:

- Added a fail-closed, presentation-only Wellspring architecture kit with seven
  reusable building profiles, ten station-furniture profiles and five landmark
  frames. It covers every style/kind in the live campus and rejects missing,
  duplicate, unknown or over-budget definitions.
- Replaced the remaining generic building pass with material-textured facades,
  faceted roofs, dormers, dome ribs, spires, foundry sawteeth, visible doors and
  external thresholds while retaining the exact authored collision footprint
  and deterministic near-actor cutaway.
- Added a reusable warm-stone Nexus source court with pavers, planted corners,
  shallow water channels and a restrained brass medallion. It is drawn beneath
  the existing authored routes, actors and interactions and owns no topology.
- Reused the eight already runtime-approved, provenance-validated pixel modules
  through `SanctumRuntimeKit`; no concept/reference image entered runtime.
- Bound architecture and wayfinding together at startup and exposed the
  architecture content hash in the boot diagnostic for reproducible captures.

Validation:

- Full headless suite passed with 15,909 assertions across 47 suites and zero
  failures, including 50 new architecture/content/binding assertions.
- Windows import and independent source boots passed at 60 and 120 Hz.
- Fixed-pointer 1280×720 captures were generated and inspected through four
  iterations; `.godot/architecture-capture-720-v4/frame00000002.png` confirms
  the warm source court, layered roofs/facades, station frames and landmarks in
  the live renderer at the default 75% overview.
- `git diff --check` reported no whitespace errors; configured LF-to-CRLF
  notices remain informational.

Known limitations and risks:

- V3 is a live candidate, not subjective acceptance. Remaining V3 review must
  cover the three districts, cutaway alignment and 50/75/100% readability before
  V4 spell presentation begins.
- Existing bulk-catalog image-loader warnings predate this slice.

## 2026-08-21 — compact HUD and purposeful campus slice

Branch: `codex/continuous-overhaul`

What changed and why:

- Added a fail-closed, editable compact combat HUD. It replaces the permanent
  three-row controls/debug strip with a small header, session chip, champion
  resource card and exactly four active spell cells; detailed guidance remains
  available through the existing Wellspring stations.
- Added fail-closed campus wayfinding data for eight distinct destinations:
  Movement Conservatory, Recovery Grove, Living Archive, Wellspring Looms,
  Settings House, Farflow Gates, Dueling Court and Elemental Crucible. Only the
  nearest four labels render, so the wider overview remains useful for play.
- Added quiet presentation-only civic motifs for the garden, Nexus and proving
  quarters. They improve long-range campus identity without modifying collision,
  routes, elevation, visibility or simulation authority.
- Added this slice's concise continuation prompt at
  `.agent/GUI-MAP-UPDATE-PROMPT.md` and deterministic validation for both new
  data contracts.

Validation:

- Windows import plus independent source boots passed at 60 and 120 Hz.
- Full headless suite passed with 15,859 assertions and zero failures.
- Fixed-pointer 1280×720 capture was generated and inspected under
  `.godot/gui-map-capture-720/`; it confirms the open top navigation frame,
  lower-left three-resource card, lower-right four-spell bar and nearby purpose
  markers. The attempted 1920×1080 movie invocation remains constrained to the
  project's 1280×720 authored viewport, so it is not claimed as separate 1080p
  evidence.

Known limitations and risks:

- V3 is still a presentation candidate: most buildings and stations remain
  procedural geometry rather than finished modular art, and V4–V6 are not open.
- Existing bulk-catalog image loader warnings predate this slice.

## 2026-08-13 â€” visual Gate V2 and natural-motion V3 foundation

Branch: `codex/continuous-overhaul`

What changed and why:

- Promoted original compact-cartoon Oh Tipi and S. Wayne candidates into a
  pinned, quantized runtime atlas with explicit dimensions, pivot, directional
  states, action states, decoded/source hashes and provenance; friend exports
  omit the large source sheet.
- Added editable data-driven minimal-motion profiles for idle, walk, sprint,
  low movement, air, cast and hit, normalized to one 60 Hz visual clock at both
  supported simulation rates. Every current movement enum maps to a readable
  family, while double jump, slide, slide jump, air dodge, wavedash, wall kick,
  vault, superglide, fast-fall and wall skim add bounded semantic accents.
- Kept animation presentation-only: hitbox diagnostics stay separate, squash /
  stretch cannot exceed 6%, offsets cannot exceed four pixels, reduced motion
  damps translation/scale/aura, and simulation tuning/legality did not change.
- Began V3 with a fail-closed NaturalMapKit. Editable recipes now own seeded
  ground variation, natural edge props, gentle visual route curves and
  surface-aware contact marks; authored topology, collision, elevation and
  route endpoints remain unchanged. Gameplay actors render above decoration.
- Added a deterministic `--capture-movement=` review harness for walk, sprint,
  slide, jump, air dodge and contextual technique on unobstructed routes.

Validation:

- Full headless suite passed with 15,832 assertions and zero failures after
  final documentation; focused import/source boots continued to pass at 60 and
  120 Hz after the natural-map and movement-accent integrations.
- Fresh checksummed Windows and Linux friend packages completed. The packaged
  Windows launcher loaded the promoted visual stack and completed safe quit;
  exports retain only the 46 KB runtime atlas while the large source image is
  excluded and its reproducibility metadata remains available.
- A fresh real three-process Farflow journey passed at 120 Hz on UDP 24970,
  including movement reconciliation, shared emotes, Hearth-to-Court flow,
  late-join observation, reconnect, rematch and reason-bearing stewardship.
- Live 1280x720 fixed-pointer captures were produced and inspected for idle,
  walk, sprint, slide, jump, air dodge and contextual technique; the open-route
  captures prove distinct silhouette, jump lift/shadow and contact context.
- `git diff --check` passed apart from configured LF-to-CRLF notices.

Known limitations and risks:

- This completes the V2 engineering candidate but not V6 human acceptance.
- V3 remains visibly schematic in architecture, landmarks and stations; the
  next visual slice must replace those with reusable modular environment art.
- Existing bulk-catalog image-loader warnings predate this slice.

## 2026-08-13 — visual Gate V1 live renderer foundation

Branch: `codex/continuous-overhaul`

What changed and why:

- Bound the live Wellspring renderer fail-closed to the V0 language so water,
  masonry, paths, gardens, timber, brass, roofs, text and affordances no longer
  invent disconnected local palettes.
- Added low-contrast screen-cardinal floor cells, sparse authored texture,
  transverse path seams and shallower facades while preserving complete
  collision footprints and external door thresholds.
- Added a deterministic presentation-only near-actor cutaway. It exposes the
  cardinal footprint through decorative architecture, eases across a bounded
  band and never becomes collision or visibility authority.
- Captured the actual renderer at 1280x720 and 1920x1080 at the default 75%
  overview. This is a safe visual foundation, not charm acceptance: schematic
  map geometry and crude v2 character atlases remain visible deficiencies.

Validation:

- Full Godot headless gate passed with zero failures; renderer binding and
  cutaway boundary assertions were added to the visual-language suite.
- Clean import and independent source boots at 60 and 120 Hz passed.
- Fresh three-process 60 Hz Farflow journey on UDP 24968 passed host/join,
  shared emote, movement prediction, Hearth, Round 1, exact-actor reconnect,
  Round 2, late observation and stewardship release.
- `git diff --check`: passed; only configured LF-to-CRLF notices were emitted.

Known limitations and risks:

- V1 does not accept the final environment. Building shapes, stations, labels
  and scene density remain schematic and belong to V3 after foundation actors.
- V2 must replace Oh Tipi and S. Wayne's existing tiny/crude atlases with
  original compact cartoon candidates before any mechanics resume.
- Existing export-time image-loader warnings predate this slice.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-13 — visual Gate V0 runtime language

Branch: `codex/continuous-overhaul`

What changed and why:

- Captured the live schematic baseline at 720p/1080p and 50/75/100% zoom, then
  scored it 2.0/5 rather than mistaking functional readability for visual charm.
- Added a fail-closed visual language covering eleven ordered material/UI ramps,
  twelve shape/cadence-distinct elements, explicit renderer layers, density/HUD
  budgets and a human-only 4-each/4.5-mean quality rubric.
- Defined a user-friendly projection: square screen-cardinal floors, visible
  collision footprints/thresholds, tilted facades bounded to 0.85x footprint,
  mandatory cutaways and no diamond/isometric navigation.
- Defined compact cartoon champions: 40–45% head ratio, short expressive bodies,
  44–68px gameplay height, 1–2px outlines, 3–5-color material ramps, separate
  shadow and bounded south/east/north/jump/cast/hit silhouette review.
- Added reusable pixel panels, dividers, materials, resources, twelve unique
  element glyphs, whole-output-pixel camera helpers and a live diagnostic
  `--visual-specimen`; integrated the visual hash into source boot evidence.
- Generated and preserved two original, immutable, provenanced exploration
  boards as quarantined references. Their cartoon characters/material language
  guide production; the second board's steep isometric court is explicitly
  rejected as a runtime projection and neither image is a shippable atlas.

Validation:

- Full Godot headless gate: 15,692 assertions, zero failures, including 79 new
  visual-language/perspective/pixel-placement adversarial assertions.
- Clean import and independent source boots at 60 and 120 Hz passed.
- Real 1280x720 AMD/OpenGL V0 specimen frame was inspected; material ramps,
  resources, four cells, prompt language and all twelve shape-distinct element
  glyphs render together.
- `git diff --check`: passed; only configured LF-to-CRLF notices were emitted.

Known limitations and risks:

- V0 is an expandable production framework, not visual acceptance. The actual
  Wellspring, champions, spells and combat GUI still use the schematic runtime.
- The generated boards remain concept-only and may not be cropped/shipped or
  used for collision without separate original-asset production and review.
- Existing export-time image-loader warnings predate this slice and remain a
  known visual-pipeline cleanup item.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-13 — visual-first continuation contract

Branch: `codex/continuous-overhaul`

What changed and why:

- Added a strict V0–V6 live visual gate using the approved Wellspring specimen
  and newest user reference as mood/composition targets with an explicit
  originality boundary.
- Added the post-visual implementation order: crisp/slightly slower movement,
  exhaustive physically legal action chaining, positive-Flux offense with
  shorter action-specific cooldowns, then a globally selectable 48-spell
  minimum across twelve elements.
- Reconciled the reference's five visible buttons with FLUX's canonical twelve
  positions: the HUD shows four active cells while Plain/Ctrl/Alt layers remain
  independently configurable at the Spell Loom.
- Updated the standing handoff, active backlog and compact memory so no agent
  may select new mechanical work before integrated visual acceptance.

Validation:

- Documentation consistency search confirms Gate 0, V0–V6, four-cell HUD and
  post-visual order are present across the active handoff files.
- `git diff --check`: passed; only configured LF-to-CRLF notices were emitted.
- Runtime tests were not rerun because this checkpoint changes documentation
  and planning contracts only; published gameplay remains commit `8b94070`.

Known limitations and risks:

- The new image remains a concept/mood reference, not runtime art or visual
  acceptance evidence.
- Charm still requires live frame review; the rubric makes that review bounded
  but does not pre-approve any generated or placeholder asset.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-13 — twelve-position spell weave, Rimewake and wider camera

Branch: `codex/continuous-overhaul`

What changed and why:

- Replaced the five-button spell row with twelve stable, independently
  configurable positions: Plain 1–4, Ctrl+1–4 and Alt+1–4. The active layer
  remains a compact four-cell play HUD while the in-world Spell Loom exposes the
  complete 3x4 arrangement.
- Migrated preferences to schema 7 and loadouts to schema 3, preserving older
  bindings safely, removing retired spell-5 data and refusing to steal Ctrl or
  Alt when a legacy custom binding already owns it.
- Added a persisted 50/75/100% camera scale, defaulting to the wider 75% view,
  with matching pointer aim, sight cone, building occlusion and diagnostic CLI
  transforms.
- Promoted Oh Tipi's Rimewake as the first host-authoritative persistent field:
  safe far-to-near placement, bounded lifetime, stable hostile processing,
  one slow per actor, cues, compact snapshot state and sealed material cooling.
- Advanced the wire contract to protocol 26 / snapshot schema 10. Spell layouts
  use occupied indices and the public projectile presentation cap is bounded so
  the maximum snapshot remains inside one 1,392-byte ENet MTU.

Validation:

- Full Godot headless gate: 15,613 assertions, zero failures.
- Clean import and source boots at 60 and 120 Hz: passed as part of the full gate.
- Source Farflow smoke at 60 Hz on UDP 24967: host/join, shared HELLO, movement
  reconciliation, Hearth-to-Court round, late-join observation and handoff,
  exact-actor reconnect, rematch and reason-bearing stewardship passed.
- Diagnostic movie captures at 75% verify a readable active four-position HUD,
  successful Rimewake placement/feedback and the complete 3x4 Spell Loom.
- `git diff --check`: passed; only configured LF-to-CRLF notices were emitted.

Known limitations and risks:

- This slice validates source play on Windows; portable archives last passed at
  the preceding checkpoint and were not regenerated into user-owned output.
- Physical Garuda/Sway and real two-machine friend-network proof remain external
  acceptance gaps.
- Rimewake's material operation remains deliberately sealed until environment
  reset ownership and route-safety fixtures exist.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-13 — first deterministic multi-target spray shape

Branch: `codex/continuous-overhaul`

What changed and why:

- Reworked Oh Tipi's existing Tideline from another projectile into FLUX's first
  true spray while retaining its Water identity, cost, startup, cooldown, exact
  damage and launch control.
- Added a fixed-point 280-unit fan. It evaluates actors after all movement in
  stable entity order, affects every legal target inside the bounded cone once,
  tests cover separately for each target and ignores allies, protected actors,
  out-of-cone actors and projectile-only Edgeweave rules.
- Advanced protocol 25 / snapshot schema 9. One bounded `spray_fired` event
  carries the fan endpoint/count and one `spray_hit` event names each affected
  actor; the host alone owns fan membership, cover, damage, launch and defeats.
- Added an original translucent fan presentation with a center current, readable
  edges and separate launch/damage feedback. The compact bar now truthfully
  labels Tideline `WATER SPRAY`.

Validation:

- Full Godot gate: 14,948 assertions, zero failures; import and independent
  source boots passed at 60 and 120 Hz.
- Tests prove two in-fan targets receive one exact hit/launch in stable order,
  an outside target remains untouched, cover prevents a hidden hit, no
  projectile is stored, catalog/compiled shapes agree and fan/hit cues roundtrip.
- A real 1280×720 AMD/OpenGL frame at
  `.godot/spray-capture/frame00000012.png` was inspected; the fan, endpoint,
  damage/launch cue and `WATER SPRAY` HUD label remain readable together.
- A fresh three-process 60 Hz Farflow journey passed host/join, HELLO, movement
  reconciliation, Hearth/Court, late observer handoff, exact-actor reconnect,
  Round 2 and reason-bearing stewardship on UDP 24945.
- Both portable archives rebuilt successfully. Packaged Windows safe quit passed
  a real protocol-25 AMD/OpenGL boot, preference flush, peer close and code 0.

Known limitations and risks:

- Final spray animation/audio, reduced-effects tuning and balance playtesting
  remain; the geometric foundation is intentionally restrained.
- Field, defense and movement shapes remain unpromoted. Tideline's planned
  material push is still sealed and changes no terrain.
- Physical Garuda/Sway and remote two-machine friend proof remain external gaps.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-13 — first deterministic non-projectile spell shape

Branch: `codex/continuous-overhaul`

What changed and why:

- Reworked S. Wayne's existing Pocket Eclipse from a projectile into FLUX's
  first true beam while retaining its Light identity, 20 Flux cost, readable
  startup, cooldown, exact damage and bounded slow.
- Added a fixed-point 520-unit beam trace that stops at authored collision and
  applies once to the nearest legal actor in its lane. Beam requests resolve
  only after every actor moves for the tick, preventing entity-order-dependent
  control duration or targeting; beams never enter projectile storage or earn
  projectile-only Edgeweave rewards.
- Advanced protocol 24 / snapshot schema 8 with a bounded `beam_fired` semantic
  endpoint. The host owns trace, target, damage and slow; peers receive only the
  identity/endpoint needed for a short translucent lane and impact cue.
- Added the testing-only `--capture-cast-active` argument so already-implemented
  spells can receive repeatable in-engine frame review without a fake menu or
  player-facing shortcut.

Validation:

- Full Godot gate: 14,928 assertions, zero failures; import and independent
  source boots passed at 60 and 120 Hz.
- Focused tests prove exact beam cost/startup/damage/slow at both rates, no
  projectile state, first-target choice, cover stopping, no damage through
  cover, catalog/compiled shape agreement and semantic endpoint roundtrip.
- A real 1280×720 AMD/OpenGL frame at
  `.godot/beam-capture/frame00000013.png` was inspected: the compact HUD names
  `LIGHT BEAM`, the lane ends at the effigy, and damage/slow remain readable.
- A fresh three-process 120 Hz Farflow journey passed host/join, HELLO, movement
  reconciliation, Hearth/Court, late observer handoff, exact-actor reconnect,
  Round 2 and reason-bearing stewardship on UDP 24944.
- `scripts/package.ps1 -Target All` rebuilt the checksummed Windows ZIP and
  Linux tar.gz. Packaged Windows `PLAY-FLUX.cmd -- --safe-quit-smoke` completed
  a protocol-24 AMD/OpenGL boot, preference flush, peer close and exit code 0.

Known limitations and risks:

- The beam has deterministic geometry and feedback, but final character/spell
  animation, audio, reduced-effects polish and balance playtesting remain.
- Spray, field, defense and movement shapes remain unpromoted. Every material
  operation remains sealed; Pocket Eclipse does not reveal or mutate terrain.
- Physical Garuda/Sway and remote two-machine friend proof remain external gaps.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-13 — host-authoritative five-row Spell Loom

Branch: `codex/continuous-overhaul`

What changed and why:

- Added the eleventh walk-up Wellspring station, the Spell Loom. Its modal
  in-world editor shows five numbered rows, the selected champion's two proven
  roles and canonical ability metadata while the shared world/network continue.
- Advanced the network protocol to 23 and snapshot schema to 7. Every player
  now owns five validated spell wire slots; the host accepts only a bounded
  role/row request from authoritative Spell Loom proximity and snapshots the
  resulting order to every peer.
- Spell placement swaps the existing primary or active into the chosen row,
  preserving exactly one of each and three explicit empties. Empty casts refuse
  without cost, catalog-only spells never enter the selector, legacy click/key
  access remains explicit, and champion changes restore the safe 1/2 layout.
- Combat resolves semantic slot commands through canonical player state rather
  than renderer/HUD position. Match restart defensively closes open binding and
  spell editors before constructing the new simulation.

Validation:

- Full Godot gate: 14,909 assertions, zero failures; import and independent
  60/120 Hz source boots passed on protocol 23.
- New unit coverage proves editor navigation/encoding, safe swapping, canonical
  slot invariants, reordered combat casts, snapshot roundtrip/fail-closed data,
  typed transport values, smuggled-value refusal and host station proximity.
- A real 1280×720 GPU frame at
  `.godot/spell-loom-capture/frame00000001.png` was inspected: all five rows,
  selected role, ability shape/element/cost and authority state remain readable.
- `scripts/package.ps1 -Target All` rebuilt the checksummed Windows ZIP and
  Linux tar.gz. Packaged Windows `PLAY-FLUX.cmd -- --safe-quit-smoke` completed
  a real AMD/OpenGL 120 Hz boot, preference flush, peer close and exit code 0.

Known limitations and risks:

- Spell order is deliberately session-scoped and resets on champion change;
  persistence needs a versioned profile decision rather than an implicit save.
- Only the two proven projectile spells per champion are selectable. Beam,
  spray, field, defense, movement and material effects remain honest next slices.
- Physical Garuda/Sway and remote two-machine friend proof remain external gaps.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-13 — truthful spell shape and material-operation contract

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced the ability catalog to schema 2. Every ability now declares one
  validated shape, delivery, impact, residue, planned material operation,
  material-runtime gate and playable/catalog-only status.
- Added a sorted playable-spell query that exposes only the six abilities whose
  simulation is already end to end. Prism Ward, Stone Channel, Phase Step and
  Convergence remain useful validated designs without entering runtime choice.
- Updated the five-slot HUD to show compact element + shape labels. Planned
  wet/Charge/push/decay/reveal/fracture operations are authored but all remain
  explicitly disabled until material mutation has authority and reset proof.

Validation:

- Full Godot gate: 14,868 assertions, zero failures; import and 60/120 Hz boots
  passed with the new ability/champion compatibility hashes.
- Negative tests reject unknown shapes and an enabled no-op material mutation.
  Positive tests pin the six playable IDs and every current material gate.
- A real 1280×720 GPU frame at
  `.godot/spell-shape-hud-capture/frame00000001.png` was inspected; element,
  projectile shape, Flux/free state, readiness and honest empties fit each cell.
- `scripts/package.ps1 -Target All` rebuilt both checksummed friend archives;
  packaged Windows safe quit completed a real AMD/OpenGL protocol-22 boot and
  bounded clean exit with code 0.
- `git diff --check`: passed.

Known limitations and risks:

- No beam, spray, field, defense or movement spell is promoted by this content
  contract; the host-authoritative Loom and one-at-a-time runtime promotion are
  next.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-13 — five-slot spell command and HUD foundation

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced the network protocol to 22 and player preferences to schema 6. Five
  stable edge-triggered `spell_1`…`spell_5` actions default to number keys 1–5,
  remain independently bindable across keyboard/mouse/controller, and migrate
  schema-v1 through schema-v5 profiles without reclaiming Ctrl or Alt.
- Advanced the foundation loadout to schema 2 with exactly five known, unique,
  ordered primary/active/mobility IDs. Runtime slots 1/2 deliberately adapt to
  each champion's existing proven primary/active; unimplemented slots 3–5 emit
  a semantic `empty_slot` refusal and spend no Flux.
- Added a compact five-cell combat HUD showing the real champion spell names,
  elements, Flux costs, readiness/cooldown and honest empty states. Extended the
  Controls Lectern to scroll all 17 actions inside its existing 720p panel.
- Updated player controls, ability/loadout, network, README, backlog and handoff
  records to distinguish the playable adapter from unpromoted catalog content.

Validation:

- Full Godot gate: 14,849 assertions, zero failures. New coverage includes
  command bit/copy priority, 60/120 Hz slot 1/2 casts, empty-slot no-spend
  refusal, schema-v5 migration, five-slot content validation and editor scroll.
- Godot import and source 60/120 Hz boots passed on protocol 22.
- A real 1280×720 GPU movie frame was inspected at
  `.godot/spell-hud-capture/frame00000001.png`; ready, paid and empty states are
  readable over ranged-cone play without depending on debug output.
- `scripts/package.ps1 -Target All` rebuilt checksummed Windows ZIP/Linux tar.gz
  friend bundles. Packaged Windows `PLAY-FLUX.cmd -- --safe-quit-smoke` completed
  a real AMD/OpenGL boot, schema migration and bounded exit with code 0.
- `git diff --check`: passed.

Known limitations and risks:

- Spell Loom editing, authored shape metadata and beam/spray/field/
  movement-defense implementations remain next; the HUD never claims those
  catalog entries are currently castable.
- Physical Linux and real remote-friend acceptance gaps are unchanged.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-13 — in-world conflict-safe Controls Lectern

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced preferences to schema 5 with validated, persisted controller button
  and signed-axis bindings plus optional mouse lanes for every current gameplay
  action; schema-v4 profiles migrate without changing established inputs.
- Added a tenth walk-up Wellspring station, the Controls Lectern west of the
  Champion Loom, with an original parchment/brass/cyan table at 1280×720.
- Keyboard, mouse, wheel and controller navigation/capture now support explicit
  cancel, unbind, safe reset and disclosed conflict swaps. Each accepted change
  updates the runtime map and offline profile immediately.
- Opening the lectern suppresses local movement, combat and station input while
  the fixed-tick world/network session keeps advancing; close/capture events are
  guarded so they cannot leak into gameplay on the following frame.
- Updated the Movement Guide, renderer glyph, controls/player-experience docs,
  backlog and handoff memory to match playable truth.

Validation:

- Full Godot gate: 14,796 assertions, zero failures; import and 60/120 Hz boots
  passed. New coverage includes capture device filtering, navigation wrapping,
  conflict swap, unbind/reset, controller validation/migration and station data.
- Deterministic `--capture-spawn=1080,900
  --capture-expanded-station=controls-lectern` movie capture completed at 60 Hz;
  the final 12-row 1280×720 frame was inspected for table fit, contrast and
  live bindings, including interaction/talk conflict safety.
- `scripts/package.ps1 -Target All`: passed; rebuilt runtime-only Windows/Linux
  friend archives include the lectern, and packaged Windows safe quit completed
  a real GPU boot, schema-v5 migration and bounded exit with code 0.
- `git diff --check`: passed.

Known limitations and risks:

- Named controller profiles, sensitivity/dead-zone curves and per-category reset
  remain later polish; spell-slot actions enter the same validated grammar next.
- Physical Linux and real remote-friend acceptance gaps are unchanged.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-13 — schema-4 mouse and keyboard movement defaults

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced preferences to schema 4. New profiles use C for slide/fast-fall,
  wheel-up for jump, wheel-down for slide/fast-fall and leave Ctrl/Alt free for
  the five-slot spell grammar.
- Added validated, conflict-free mouse-button/wheel persistence and generic
  runtime routing without replacing keyboard or controller inputs.
- Schema-v3's authored default Ctrl slide migrates to C while explicit player
  alternatives remain unchanged; older profiles gain the safe mouse defaults.
- Reconciled the runtime movement ribbon and player/developer documentation with
  the actual schema-4 controls.

Validation:

- Full Godot gate: 14,756 assertions, zero failures; import and 60/120 Hz boots
  passed.
- Input-router and preference suites cover default mappings, migration,
  conflict rejection, unbinding and keyboard/mouse coexistence.
- `scripts/package.ps1 -Target All`: passed for the Windows ZIP and Linux
  tar.gz; the rebuilt Windows `PLAY-FLUX.cmd -- --safe-quit-smoke` completed a
  real GPU boot and bounded clean exit with code 0.

Known limitations and risks:

- The Wellspring Controls lectern and live capture UX remain the next slice;
  this checkpoint provides its validated persistence/routing foundation.
- Physical Linux and real remote-friend acceptance gaps are unchanged.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-13 — portable friend builds, safe lifecycle and visual target

Branch: `codex/continuous-overhaul`

What changed and why:

- Replaced the continuous handoff with an acceptance-ordered prompt covering
  portable onboarding, in-world binding, five spell slots, materials, codex,
  expression, visual replacement, cleanup and visibility without scattering
  partially integrated systems.
- Added the original gameplay-scale Wellspring v3 specimen and immutable
  provenance. It sets champion scale, tilted-facade/top-down-floor composition,
  lane clarity, material identity, translucent bubbles and compact HUD intent;
  it is explicitly specification-only and not shippable runtime art.
- Added bounded official-template installers that read the pinned Godot 4.7.1
  TPZ central directory by HTTP range, fetch only Linux/Windows release entries,
  validate each ZIP size/CRC and replace destination files atomically.
- Export presets now exclude user dependencies, concepts, documentation and
  tooling from runtime packages. PowerShell export uses quoted checked process
  execution and centralized logs.
- Added portable Windows/Linux bundle construction, obvious launchers,
  first-read safety/host guidance, platform and archive SHA-256 manifests and a
  deterministic Linux tar writer that preserves executable modes on Windows.
- Disabled automatic window quit. The application now flushes preferences,
  sends hosted guests a bounded semantic close reason, waits up to 500 ms,
  closes ENet and then exits; `_exit_tree` remains the cleanup fallback.
- Added exact safe-quit argument coverage and concise player-experience,
  README, backlog and memory handoff tables.

Validation:

- Official selective template install: Linux 73,470,264 bytes and Windows
  109,212,160 bytes, both CRC/size verified.
- `scripts/package.ps1 -Target All`: passed; runtime-only portable Windows ZIP
  (90,035,605 bytes) and Linux tar.gz (80,231,324 bytes) plus checksums emitted.
- Windows packaged executable and `PLAY-FLUX.cmd -- --safe-quit-smoke`: real GPU
  boot, Wellspring initialization, preference/network cleanup and exit code 0.
- Linux payload: ELF magic, SHA-256 archive manifest and executable modes for
  both binary and launcher verified; no physical Linux runtime was available.
- Full Godot gate: 14,742 assertions, zero failures; import and 60/120 Hz boots
  passed. Git-Bash syntax, Python bytecode compilation and `git diff --check`
  passed.

Known limitations and risks:

- A packaged two-computer remote journey and physical Garuda/Sway package run
  remain required; the local Docker WSL distribution cannot mount the workspace
  and is not accepted as Linux gameplay evidence.
- Host/join still relies on a configured address rather than an in-world text
  field and copy/paste join card. Public direct-IP may require router/firewall
  setup.
- The v3 image is a visual target only; runtime remains schematic until the
  character → spell → map → GUI visual gates are implemented and accepted.
- The long-standing export-time `Image.load_from_file` warnings remain; they do
  not fail source tests or the packaged boot but require a focused cleanup.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-12 — authority-safe late-join observer

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced friend play to protocol 21. A guest accepted during an active or
  result-phase Proving Court remains outside the participant roster and receives
  a host-owned zero-input command; movement, casts, jumps and button holds cannot
  influence the live round even if a modified client sends them.
- Added a presentation-local spectator focus model over replicated public state.
  It deterministically follows the lowest available participant, cycles with Tab
  or controller D-pad right, survives participant departure/result state and
  never converts an actual participant into an observer.
- The camera, full/cone POV origin, compact Health/Flux/Stamina kit HUD and
  next-gathering prompt follow the selected participant. The observer's own actor
  remains inert; F is suppressed, T remains social, and no input/prediction or
  reconciliation stream is sent while the court is locked.
- On synchronized return, observer state clears, the local camera/actor return to
  the real Hearth and ordinary validated readiness admits that traveller to
  Round 2. No spectator-only world-state channel was added; host per-peer LOS
  filtering remains the next limited-information gate.
- Replaced raw public snapshot envelopes with validated, bounded FastLZ wire
  envelopes. The receiver caps expansion, decodes without objects and validates
  schema again; both the maximum eight-player fixture and live three-player
  journey fit one 1,392-byte ENet MTU.
- Extended Windows and Bash acceptance wrappers to launch a late third process
  for Open Commons/Sparring Circle, verify observer focus, Hearth handoff and
  Round-2 participation, and clean up all three processes. Duel Knot retains its
  capacity-correct two-process path.

Validation:

- `scripts\test.cmd`: passed import, the full **14,740-assertion** suite and
  independent 60/120 Hz protocol-21 boots with zero failures; spectator focus
  14, authoritative session 111, session transport 154, session snapshot 51 and
  input router 102 assertions all passed.
- `scripts\smoke-farflow.cmd -Port 24937 -TickRate 120 -Charter open_commons
  -TimeoutSeconds 45`: passed the complete three-process journey.
- `scripts\smoke-farflow.cmd -Port 24938 -TickRate 60 -Charter sparring_circle
  -TimeoutSeconds 45`: passed the equivalent journey; host/guest/late-guest stderr
  remained empty and no late-observer prediction spam or ENet MTU warning remained.
- `scripts\smoke-farflow.cmd -Port 24939 -TickRate 60 -Charter duel_knot
  -TimeoutSeconds 45`: preserved the capacity-correct two-process journey.
- Godot editor/import parsing, both boot logs and `git diff --check`: passed.

Known limitations and next slice:

- This is an observer over the same public replicated state, not a security claim
  for fog-of-war play. Limited-information modes still need host-owned per-peer
  actor/projectile/event/name omission, policy tests and bandwidth diagnostics.
- Matching 4.7.1 export templates and physical Garuda Sway proof remain external
  acceptance work; Bash wrapper parity is maintained but cannot run on this host.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-12 — reason-bearing host stewardship

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced friend play to protocol 20 and added two authored, collision-cleared
  Wellspring stations. The Company Ledger cycles only connected guests in stable
  order and takes no destructive action; the separate Parting Bell requires a
  second press on the same selection within three seconds.
- Host Farflow now uses the same explicit two-press confirmation before closing
  a company. Join Farflow remains the guest's local leave boundary, so neither
  side can accidentally close the other flow from the wrong station.
- Added deterministic `SessionSteward` state for selection, action identity,
  bounded confirmation and expiry. Changing the action/selection rearms rather
  than confirming, stale guests clear safely, and unit coverage verifies the
  one-press safety boundary.
- Added a host-only reason-bearing transport packet. A cooperative guest clears
  its memory-only return capability and closes after receipt; a modified client
  is forcibly disconnected after a 250 ms bound. Administrative departures are
  final, never create return reservations, and client-forged administration is
  ignored.
- Extended both maintained Windows and Bash Farflow journeys. Only after HELLO,
  prediction, Hearth, Round 1, exact-actor return and active Round 2 does the
  diagnostic confirm release; success requires the exact guest reason, revoked
  return capability and host-observed non-reserved departure.

Validation:

- `scripts\test.cmd`: passed import, the full **14,709-assertion** suite and
  independent 60/120 Hz boots with zero failures.
- `scripts\smoke-farflow.cmd -Port 24928 -TickRate 120 -Charter open_commons
  -TimeoutSeconds 30`: passed the complete Round-2-to-stewardship journey.
- `scripts\smoke-farflow.cmd -Port 24929 -TickRate 60 -Charter duel_knot
  -TimeoutSeconds 30`: passed the equivalent journey at 60 Hz.
- Godot editor/import parsing and `git diff --check`: passed; matching export
  templates and a physical Garuda run remain unavailable on this Windows host.
- A deterministic 1280x720 capture at the Company Ledger was inspected: the
  Ledger, Parting Bell, Hearth and Farflow gates remain distinct and readable in
  one camera view, with the expanded transparent bubble anchored correctly.

Known limitations and next slice:

- The direct-IP boundary intentionally has no identity account, encryption,
  relay, NAT traversal, persisted bans or host migration yet; test only with
  trusted friends.
- Late joiners safely wait outside an active court but do not yet receive a
  deliberate spectator camera. The next slice gives them participant focus,
  clear next-gathering status and automatic Hearth handoff without authority or
  hidden-state leakage.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-12 — gathered Hearth return and same-roster rematch

Branch: `codex/continuous-overhaul`

What changed and why:

- Turned the post-result reset into a real diegetic return: every connected
  champion now appears at one of eight validated, collision-cleared positions
  around the Session Hearth, all inside its interaction circle.
- Preserved round serials across world refreshes. The Hearth names the next
  round, the persistent HUD shows its live three-second countdown and rules,
  readiness resets explicitly, and the same roster can ready and enter Round 2
  without closing or reopening Farflow.
- Renamed remaining player-facing “shared practice” language to Proving Court
  language while retaining stable compatibility event IDs internally.
- The eight gather points are authored campus data with district, interaction-
  radius, pair-separation and collision validation; malformed or overlapping
  layouts fail closed.
- Fixed the diagnostic reconnect path so a returning smoke actor is never
  moved out of an active round. Added a bounded rematch diagnostic that closes
  Round 1 only after exact-actor return, verifies both actors gather/readies at
  the real Hearth, and succeeds only when the guest receives active Round 2.

Validation:

- `scripts\test.cmd`: passed import, the full **14,653-assertion** suite and
  independent 60/120 Hz boots with zero failures.
- `scripts\smoke-farflow.cmd -Port 24924 -TickRate 120 -Charter open_commons
  -TimeoutSeconds 30`: passed host/join, movement, Hearth, Round 1, exact-actor
  return, gathered Hearth readiness and active Round 2.
- `scripts\smoke-farflow.cmd -Port 24925 -TickRate 60 -Charter duel_knot
  -TimeoutSeconds 30`: passed the equivalent same-roster rematch at 60 Hz.
- Godot editor/import parser and `git diff --check`: passed.

Known limitations and next slice:

- Court countdown/result state is now persistent and readable, but bespoke
  character animation/audio for victory, defeat and rematch remain later art
  work.
- Explicit-confirmation host kick/close stewardship is the next coherent
  friend-play slice; it must preserve the gathered/rematch loop.
- Matching export templates and physical Garuda direct-IP proof remain external
  acceptance work, not a claimed pass.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-12 — first host-owned Proving Court round

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced friend play to protocol 19 / snapshot schema 6 and replaced the
  Hearth's shared-reset destination with the first real arena lifecycle.
- Added a validated authored Proving Court definition with a fixed court
  boundary, eight safe spawn anchors, first-to-three scoring, a 90-second clock,
  1.8-second respawn, 1.2-second visible spawn ward and six-second result.
- Added a simulation-owned `SessionRound` state machine. It moves the intact
  connected roster into distinct combat teams, seals live actors to the court,
  consumes only host-authored lethal-hit events, scores knockouts, respawns on
  exact ticks, resolves score or time results, freezes the result and signals a
  synchronized return to the Hearth.
- Defeated champions now idle safely until round respawn. Spawn protection is
  canonical, decrements at fixed tick, blocks projectile hits, renders as a ward
  around local and remote champions, hashes into simulation state and replicates
  through bounded packed player/round lanes.
- The top HUD changes to Proving Court state with roster scores, time and score
  target; semantic knockout, respawn, result and return events use redundant,
  deduplicated snapshot feedback.
- Extended both Windows and Bash two-process journeys with a diagnostic round
  assertion that succeeds only after the guest validates the active packed
  Proving Court serial. The normal in-world Hearth interaction remains the
  player-facing start path.
- Late joins during an active court now receive a replicated, safely idle
  `round_wait` actor and a clear next-gathering notice. Non-social station
  requests fail closed until the round returns, preventing a lobby-side Bell or
  Hearth request from mutating live play; HELLO remains available.
- Active/result court inputs cannot be bypassed through unresolved projectiles,
  result-pause commands, the host's local reset hotkey or a departing last
  rival; departures resolve for the survivor and stay snapshot-valid.
- Round serials, simulation ticks, semantic event IDs, roster identities and
  champion attunements remain monotonic/stable across Hearth returns and
  rematches.

Validation:

- `scripts\test.cmd`: passed import, the full **14,636-assertion** suite and
  independent 60/120 Hz boots with zero failures.
- `scripts\smoke-farflow.cmd -Port 24922 -TickRate 120 -Charter open_commons
  -TimeoutSeconds 30`: passed real source host/join, HELLO, prediction,
  Hearth-to-Court entry, leave and exact-actor return.
- `scripts\smoke-farflow.cmd -Port 24923 -TickRate 60 -Charter duel_knot
  -TimeoutSeconds 30`: passed the equivalent real source journey at 60 Hz.
- Maximum public snapshot envelope remains below the guarded 8 KiB transport
  cap; malformed round/player/event state fails closed.
- Renderer-backed 1280x720 AMD compatibility capture passed with the authored
  court boundary, non-overlapping rules plaque, spawn runes, nearby Hearth and
  Farflow stations readable in one camera journey.
- `git diff --check`: passed before checkpoint.

Known limitations and next slice:

- Result and transition feedback are functional but still text-led; the next
  slice should add a concise court countdown/result presentation and an
  explicit same-roster rematch flow at the Hearth.
- Late joins deliberately wait for the next Hearth gathering; a richer
  spectator camera remains future work.
- Explicit host confirmation for kick/close remains the following stewardship
  slice.
- Matching Godot 4.7.1 export templates and physical Garuda direct-IP evidence
  remain unavailable locally; no packaged cross-platform claim is made.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-12 — Session Hearth and synchronized shared start

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced friend sessions to protocol 18 / snapshot schema 5 and added the
  seventh walk-up Wellspring station, the **Session Hearth**, without adding a
  detached lobby menu.
- Added a host-owned packed Hearth model for connected/returning presence,
  readiness, sealed capacity and a deterministic three-second countdown.
  Returning, joining or expiring identities clear readiness and cancel a live
  countdown; at least two connected travellers must all be ready.
- Replicated Hearth state in every validated snapshot and added semantic
  ready/countdown/start/cancel events. Reliable ready/start requests use the
  same monotonic request lane, trusted entity stamping and authoritative
  station-proximity checks as Bell/Loom interactions.
- The Hearth bubble shows profile capacity, connected/returning counts, up to
  four named roster entries, each readiness state and the correct local action.
  The host alone starts after everyone readies.
- Shared reset now preserves the session's monotonic simulation tick and event
  ID sequence, preventing a guest from rejecting the new round or deduplicating
  its start event as stale. Champion attunements and live Farflow roster survive.
- Packed Hearth entries and 32-bit bounded player snapshot lanes recover MTU
  headroom. The normal two-player combat and post-Hearth start packets remain
  below ENet's 1,392-byte single-packet boundary.
- Extended Windows and Bash Farflow journeys with a test-only Hearth diagnostic
  that gathers the pair at the real station and still exercises normal guarded
  request/authority paths before exact-actor reconnect.
- Capture-only expanded-station state is applied after diagnostic host/join
  startup, so startup notices cannot hide the station selected for visual QA.

Validation:

- `scripts\test.cmd`: passed import, the full **14,554-assertion** suite and
  independent 60/120 Hz boots with zero failures at protocol 18, snapshot schema
  5 and campus hash `0d09109383bb`.
- `scripts\smoke-farflow.cmd -Port 24922 -TimeoutSeconds 30 -Charter
  sparring_circle`: passed the final complete 120 Hz source journey in 6.5 seconds:
  host/join, shared HELLO, authoritative movement/reconciliation, both-ready
  Hearth countdown/start, leave and exact-actor return.
- `scripts\smoke-farflow.cmd -Port 24921 -TimeoutSeconds 30 -TickRate 60
  -Charter duel_knot`: passed the equivalent 60 Hz Duel Knot journey in 4.7
  seconds.
- The first black-box attempt exposed a 1,456-byte fragmented start snapshot;
  the second exposed reset event-ID reuse. Both failures were repaired and the
  exact same process gate passed at both supported cadences. No failed run is
  represented as acceptance.
- Matching Godot 4.7.1 export templates are still missing locally; source
  run/test remains green, while packaged Windows and physical Garuda evidence
  is not claimed. Existing untracked `dist/` and `node_modules/` were untouched.
- A one-frame 1280×720 AMD Radeon compatibility-renderer capture at the online
  Hearth confirmed its distinct marker and expanded Sparring Circle roster
  bubble (`1/4`, host name, `WAITING`, action) are readable at gameplay scale.

Known limitations and next task:

- The Hearth does not yet provide explicit-confirmation kick/close moderation.
  Eight travellers remain the public cap, but multi-player snapshot paging or
  deltas must replace single whole-state unreliable packets before measured
  eight-player load acceptance.
- Hearth start currently restores the shared Wellspring practice seed. The next
  slice is one bounded combat court with spawn safety, round countdown,
  score/time limits, death/respawn, result and synchronized return/rematch.
- Packaged Windows/physical Garuda direct-IP acceptance remains blocked only by
  absent local release templates/hardware, not by the source launch path.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-12 — diegetic Farflow Charter

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced friend sessions to protocol 17 and added a sixth fixed-position
  Wellspring station, the **Farflow Charter**. Players turn it in-world before
  hosting; no detached settings menu was introduced.
- Added three validated profiles with distinct rule identities: Open Commons
  (8 places, no traveller damage, any Bell user), Sparring Circle (4 places,
  individual combat teams, any Bell user), and Duel Knot (2 places, individual
  combat teams, host-only Bell reset).
- The host seals one Charter while Farflow is open. Its catalog identity joins
  build compatibility; exact profile ID/hash/capacity are assigned and
  validated during guarded acceptance. The physical transport ceiling remains
  eight so a charter-full traveller receives an explicit refusal.
- Authoritative champion teams now follow the sealed profile, including return
  identities. Practice actors use their stable entity as a separate team so
  every champion can still damage the effigy in every profile.
- Host/Join bubbles expose profile/capacity; the expanded parchment bubble shows
  the next profile, current places, traveller damage and Practice Bell policy.
  Capture-only spawn/expanded-station arguments make this state repeatable
  without changing normal spawning or interaction.
- Extended the source/package Farflow acceptance wrappers with a validated
  Charter selector for Windows and Bash.

Validation:

- Full pinned Godot 4.7.1 Windows gate passed with **14,488 assertions**, zero
  failures across 34 suites; import plus independent 60/120 Hz boots passed at
  protocol 17 and campus hash `60f19ad129af`.
- Transport coverage proves profile assignment/hash/capacity, explicit excess
  refusal, catalog mismatch refusal, safe default and reconnect compatibility;
  authority tests prove social versus sparring teams and invalid-rule rejection.
- Real two-process Windows source journey passed Sparring Circle at 120 Hz on
  UDP 24896 and Duel Knot at 60 Hz on UDP 24897, including host/join, shared
  HELLO, authoritative movement reconciliation and exact-actor return.
- Interactive Windows renderer inspection at the Charter anchor confirmed the
  original parchment station marker, normal prompt and expanded four-line
  profile bubble remain readable at the normal camera scale.
- Godot's Windows dummy renderer crashed in headless movie-writer mode at
  `texture_2d_get`; the visible renderer and ordinary headless run/test paths
  remained green. No headless-movie success is claimed.
- `git diff --check`: passed before checkpoint preparation; existing untracked
  `dist/` and `node_modules/` remained untouched.

Known limitations and next task:

- Charter choice is intentionally session-memory only and fixed while online.
  Player-facing lobby naming, roster/readiness, host moderation and a shared
  practice-start flow remain.
- Matching Godot 4.7.1 export templates and physical Garuda Sway hardware remain
  required for packaged cross-platform acceptance.
- Next slice is an in-world **Session Hearth**: visible connected/returning
  roster, traveller readiness and host-authoritative practice start, followed
  by the first bounded arena round.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-12 — cross-platform source and release acceptance tooling

Branch: `codex/continuous-overhaul`

What changed and why:

- Added Windows `.cmd` entry points for doctor, test, run, package and Farflow
  acceptance. They use a child-process-only PowerShell execution-policy bypass,
  so a stock Windows policy can run the project without weakening machine
  policy; paths with spaces and Windows PowerShell 5.1 remain supported.
- Added symmetric Bash packaging and Farflow acceptance. Both package paths use
  the pinned engine/presets, require exact platform release-template files,
  write portable SHA-256 manifests and never download templates implicitly.
- Added a source-or-package, two-process Farflow journey that proves host/join,
  shared HELLO, authoritative movement reconciliation, leave and exact-actor
  return before cleaning up both processes and retaining local logs.
- The combined journey exposed and fixed two diagnostic sequencing bugs: input
  sequence count was incorrectly used as its movement duration, and reconnect
  could close a reliable interaction before it replicated. Diagnostics now
  count their own movement inputs and wait for interaction send plus confirmed
  movement before disconnecting; player-facing networking semantics are
  unchanged.

Validation:

- PowerShell parser: all six `.ps1` files passed; Git Bash `bash -n`: doctor,
  test, run, install, package and Farflow scripts passed.
- `scripts\\doctor.cmd`: passed with exact Godot
  `4.7.1.stable.official.a13da4feb`; it reports export templates missing while
  leaving source use available.
- `scripts\\test.cmd`: full suite passed with **14,428 assertions** and zero
  failures; import plus independent 60/120 Hz boots passed at protocol 16 with
  campus/ability/champion hashes
  `c981419a5b33` / `566a637aa616` / `81962afbff12`.
- `scripts\\smoke-farflow.cmd -Port 24894 -TimeoutSeconds 30`: passed the full
  combined two-process Windows source journey and cleaned up both processes.
- The same journey passed at 60 Hz on UDP 24895; the earlier 120 Hz run covered
  the other supported cadence.
- Windows package preflight failed as designed before export because
  `windows_release_x86_64.exe` is absent from the local Godot 4.7.1 template
  directory; no package success or Garuda evidence is claimed.

Known limitations and next task:

- Matching Godot 4.7.1 release templates must be installed/cached before an
  actual Windows/Linux export can run. This machine has no physical Garuda Sway
  environment, so physical Linux and remote-router proof remain external gates.
- Next slice is a small diegetic host/session settings station: bounded capacity
  and friendly/practice policy, with visible host authority and compatibility
  identity rather than a detached menu.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-12 — bounded Farflow return continuity

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced the friend-session boundary to protocol 16 and added a 15-second
  in-memory return reservation. A disconnected guest's exact authoritative
  actor becomes safely idle instead of disappearing; a valid return resumes its
  entity, champion, position, health and resources without client-owned state.
- Each accepted guest receives a random 256-bit endpoint/build-scoped capability
  that never enters snapshots, public rosters, logs or files. A return requires
  the token and original validated name, rotates the capability on success and
  fails closed after expiry or mismatch.
- Reservations count against the eight-player capacity. Expiry emits an
  explicit host-side removal event, releases the slot and prevents permanent
  ghosts. Established clients now convert ENet host loss into an actionable
  offline status while retaining the memory-only capability for a restarted
  host at the same endpoint/build.
- Added `--farflow-smoke-reconnect` for repeatable full-game leave/resume proof;
  normal players simply use Join Farflow again during the return window.

Validation:

- Full pinned Godot 4.7.1 suite passed with **14,424 assertions**, zero failures
  across 33 suites; `session-transport` contributed 96 and
  `authoritative-session` 71 assertions.
- Real ENet coverage proves token shape/secrecy, name mismatch refusal without
  consumption, token rotation, exact entity recovery, capacity reservation,
  deterministic expiry and explicit forced host-loss state.
- Two complete Windows headless processes connected over UDP localhost on port
  24881 under protocol 16. RiverGuest joined entity 2, left, received a host
  reservation, returned as entity 2 and resumed reconciliation at host tick 104.
- Independent 60/120 Hz boots passed with campus/ability/champion hashes
  `c981419a5b33` / `566a637aa616` / `81962afbff12`.

Known limitations and next task:

- Capabilities are intentionally memory-only, so a client process restart does
  not yet rejoin; encrypted/versioned persistence requires a product/security
  decision and is not implied by this foundation.
- There is no automatic retry loop, host process restart recovery, moderation,
  authentication/encryption, NAT traversal or host migration.
- Next slice is packaged Windows/Garuda Linux direct-IP acceptance plus doctor/
  launch diagnostics, followed by a small diegetic host/session settings flow.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-12 — bounded Farflow movement prediction

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced the friend-session boundary to protocol 15 and added a separate
  unreliable-ordered reconciliation channel. Every remote traveller receives
  only its own full movement state plus the last input sequence the host
  actually processed; the shared combat/target snapshot remains unchanged.
- Added `ClientPrediction`, which strips all combat bits, keeps at most 48
  movement inputs, predicts the complete universal movement grammar against the
  authored collision world, drops acknowledged inputs and deterministically
  replays the remainder from each host state.
- Small corrections retain a capped, rapidly decaying draw-only offset; large,
  reduced-motion or history-overflow corrections snap explicitly. Health, Flux,
  damage, spells, cooldowns, targets and stations remain snapshot/host-owned.
- The Farflow HUD now shows estimated acknowledgement delay and the last
  correction magnitude. Diagnostic `--farflow-smoke-prediction` produces a
  short movement input without adding a player-facing menu.
- Corrected the shared snapshot cadence to one tick at 60 Hz and two ticks at
  120 Hz so both supported simulations publish the contracted 60 snapshots per
  second.
- Added stable semantic event IDs, four-snapshot redundancy and a bounded
  64-event client inbox. This prevents a fresher unreliable snapshot from
  erasing HELLO/combat feedback before presentation while deduplicating every
  retained resend.

Validation:

- Full pinned Godot 4.7.1 suite passed with **14,384 assertions**, zero failures
  across 33 suites. The 111 prediction assertions cover 60/120 Hz convergence,
  complete jump/movement state, combat-bit stripping, bounded history, stale
  authority, soft correction decay/cap and hard-snap behavior.
- Real ENet tests keep the reconciliation packet below one 1,392-byte MTU,
  scope it to the target peer/entity and isolate it from the shared snapshot
  channel.
- Two complete Windows headless processes connected over UDP localhost on port
  24878 under protocol 15. RiverGuest confirmed host-authoritative displacement
  at input sequence 10 and also completed the shared HELLO path.
- Independent 60/120 Hz boots passed with campus/ability/champion hashes
  `c981419a5b33` / `566a637aa616` / `81962afbff12`.

Known limitations and next task:

- `ACK ~ms` is an outstanding-input age estimate, not a network round-trip ping;
  timestamped RTT/jitter/loss diagnostics remain.
- Reconnect identity, forced host shutdown, packaged Garuda Linux direct-IP,
  authentication/encryption and dense eight-player snapshot batching remain.
- Next slice reserves a bounded reconnect identity, communicates host loss and
  proves leave/rejoin cleanup before broader session configuration.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-11 — host-authorized Wellspring interactions

Branch: `codex/continuous-overhaul`

What changed and why:

- Added a bounded reliable request channel for social emotes, Practice Bell
  restoration and Champion Loom attunement. The server stamps the trusted peer
  identity, rejects replayed sequences and validates every station request
  against the authoritative actor position before changing shared state.
- Made `T` / controller D-pad up produce a transparent in-world **HELLO!**
  bubble with a host-enforced cooldown. Accepted and refused requests are
  returned as semantic events so a guest receives an explicit result instead
  of guessing whether an interaction happened.
- Replicated the four bounded training-target states, including health and
  reset, so remote combat and the Practice Bell now describe the same court.
  Champion attunements survive a practice reset and only the actor at the Loom
  changes champion.
- Compacted player entries, hashes and overflow counters so a representative
  two-player combat snapshot with target state fits within one 1,392-byte ENet
  MTU while the measured eight-player public envelope remains capped at 8 KiB.

Validation:

- Full pinned Godot 4.7.1 suite passed with **14,246 assertions**, zero
  failures across 32 suites; request policy, malformed/replayed packets, social
  events, shared target health and the single-MTU fixture are covered.
- Two complete Windows headless processes connected over UDP localhost on port
  24876 under protocol 14. The guest sent an emote request after its first snapshot; the host
  accepted RiverGuest as entity 2 and both processes confirmed the same shared
  emote.
- Advanced the wire boundary to protocol 14 / snapshot schema 3 so older
  protocol-13 combat clients fail the handshake instead of decoding the compact
  target-aware tuple layout incorrectly.
- Independent 60/120 Hz boots passed with protocol 14 and campus/ability/
  champion hashes `c981419a5b33` / `566a637aa616` / `81962afbff12`.
- `git diff --check` passed; generated `dist/` and `node_modules/` remained out
  of scope.

Known limitations and next task:

- Guests still render interpolated authority without local prediction or
  correction metrics; the next slice adds bounded input history, prediction,
  reconciliation and visible latency/correction diagnostics.
- Reconnect identity, forced host shutdown, packaged Garuda Linux direct-IP,
  encryption/authentication, richer social actions and settings/travel remain.
- Dense eight-player combat may exceed one MTU even though it remains below the
  explicit packet cap; measured delta/batching work precedes that acceptance.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-11 — protocol-13 Farflow combat presentation

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced the network protocol to 13 and snapshot schema to 2 so older peers
  fail compatibility instead of joining and silently dropping combat state.
- Extended snapshots with the player cast/cooldown fields needed by the HUD,
  compact render-only projectile lanes, readable last-action state and strictly
  encoded cast, hit, impact, bounce and Edgeweave events. Guests reconstruct
  presentation only; projectile collision, damage, control and resources still
  come solely from the host simulation.
- Added short, restrained in-world feedback rings/labels for damage, Edgeweave,
  refused/blocked casts and ricochets on both host and guest.
- Preserved the 8 KiB packet cap. The measured public envelope covers eight
  maximum-name travellers, 26 simultaneous projectiles and 12 recent events;
  excess presentation is counted and surfaced as Farflow load rather than
  silently expanding the trust/memory boundary.

Validation:

- Full pinned Godot 4.7.1 suite passed with **14,216 assertions**, zero failures;
  `authoritative-session` contributed 57, real-ENet `session-transport` 46 and
  `session-snapshot` 32 assertions.
- Maximum-envelope serialization, projectile/event round-trip, malformed field
  rejection and one-shot event acknowledgement pass.
- Two complete Windows headless processes connected over UDP localhost on port
  24874 under protocol 13; guest entity 2 applied the schema-2 two-player stream.
- Independent 60/120 Hz boots passed with campus/ability/champion hashes
  `c981419a5b33` / `566a637aa616` / `81962afbff12`.

Known limitations and next task:

- Snapshot overflow is explicit but still a visual omission; a later measured
  batching/delta scheme is required before dense eight-player combat acceptance.
- Host-authorized station interaction, champion requests, emotes, prediction,
  reconciliation, reconnect and Linux direct-IP packaging remain.
- Next slice adds a validated client request/host confirmation channel, starting
  with a transparent social emote and shared Practice Bell restoration.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-11 — authoritative Farflow travellers and movement snapshots

Branch: `codex/continuous-overhaul`

What changed and why:

- Added stable session entity IDs 1-8, accepted/disconnected presence queues and
  trusted peer-to-entity stamping. The host owns the roster; the first guest is
  S. Wayne beside host Oh Tipi so the playable network check exercises both
  foundation champions instead of cloning one placeholder.
- Added `AuthoritativeSession`: it creates/removes collision-cleared peer actors,
  merges one-shot inputs without losing presses, stamps every command to the host
  tick, simulates all travellers together and fails stale remote input to idle
  after 250 ms. Clients still cannot choose position, resources or outcomes.
- Added a compact, strictly validated snapshot schema for up to eight sorted
  travellers. The host publishes at 60 Hz from both supported simulation rates;
  guests follow their assigned actor and render authoritative movement, jump,
  resources, champion kit, display names and the other traveller's champion
  sprite/health. Projectiles are deliberately the next replication slice.
- Added diagnostic `--farflow=host|join` startup switches for repeatable platform
  smoke tests while preserving the walk-up Farflow stations as the player-facing
  flow. Client reset, tick-rate and attunement mutations now explain that host
  authorization is required instead of silently diverging.

Validation:

- Pinned Godot 4.7.1 import and full headless suite passed with **14,197
  assertions**, zero failures. New evidence: `authoritative-session` 54,
  `session-transport` 44 and `session-snapshot` 18 assertions.
- Independent 60/120 Hz boots passed at protocol 12 with campus/ability/champion
  hashes `c981419a5b33` / `566a637aa616` / `81962afbff12`.
- Two complete Windows headless game processes connected over UDP localhost on
  diagnostic port 24873: host logged `RiverGuest` as entity 2 and guest applied
  a two-traveller snapshot at host tick 150. This caught and fixed a runtime-only
  typed-array startup failure that import and unit parsing did not expose.
- `git diff --check`: passed; generated `dist/` and `node_modules/` stayed out of
  scope.

Known limitations and next task:

- Guest movement/resources are authoritative and visible, but projectile state,
  semantic combat feedback, shared station requests, emotes, prediction and
  reconciliation are not yet replicated.
- Windows localhost is proven; packaged Windows and Garuda Linux direct-IP
  acceptance, firewall UX, reconnect and host shutdown remain required.
- Next slice adds bounded projectile snapshots and shared impact/cast feedback,
  then host-authorized Wellspring interaction and a transparent social emote.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-11 — diegetic Farflow ENet transport boundary

Branch: `codex/continuous-overhaul`

What changed and why:

- Added a platform-native raw ENet/UDP session transport with direct host/join,
  an eight-player public cap, explicit offline/hosting/seeking/joined state and
  safe leave/refusal/disconnect cleanup. It uses no external service or account.
- Added a fail-closed SHA-256 handshake over protocol, tick rate, campus, ability
  and champion hashes. Packets are object-free, capped at 8 KiB and processed
  under a 64-packet budget; host input validation is strictly typed/ranged,
  sequence-monotonic and bounded to 28 queued commands.
- Advanced the campus to schema 4 and added distinct **Host Farflow** and **Join
  Farflow** walk-up stations in the eastern concourse. F opens/closes each gate;
  bubbles and the always-visible HUD report offline, seeking, host count, joined
  or refusal state. Join defaults to loopback and accepts direct-IP CLI overrides.
- Added `docs/NETWORKING.md` with exact friend setup, firewall/UDP constraints,
  security limitations, current truth and the authoritative replication order.

Validation:

- Real single-process ENet loopback passes compatible handshake, sender-stamped
  bounded input, mismatched-build rejection and accepted-peer disconnect cleanup.
- Full pinned Godot 4.7.1 headless gate passed after station integration with
  14,111 assertions and zero failures; transport itself contributed 33 assertions.
- Canonical campus JSON parse, pinned import and `git diff --check`: passed.
- Independent 60/120 Hz bootstrap smokes passed with protocol 12 and campus hash
  `c981419a5b33`; ability/champion hashes remained `566a637aa616`/`81962afbff12`.

Known limitations and next task:

- Connected peers do not yet share simulation actors or snapshots; this is a
  working transport/handshake checkpoint, not a claim of remote gameplay.
- Direct Internet hosting currently needs manual UDP firewall/router forwarding;
  discovery, relay, NAT traversal, encryption and authentication are future gates.
- Next slice maps accepted peer IDs to authoritative simulation actors, consumes
  inputs on the host, broadcasts a bounded roster/snapshot and renders both peers.

Commit: pending. Push: pending.

## 2026-08-11 — S. Wayne basic combat pair

Branch: `codex/continuous-overhaul`

What changed and why:

- Replaced S. Wayne's shared placeholders with **Eclipse Disc** (wire 142), a
  resource-free Dark primary whose slower, larger lane can ricochet exactly once,
  and **Pocket Eclipse** (wire 143), a 20-Flux Light active that exchanges burst
  damage for a readable 600 ms movement slow at 55% speed.
- Added canonical projectile bounce count and on-hit slow strength. World
  collision owns axis reflection, every bounce emits a semantic event, and
  protocol advanced to 12 so replay/session mismatch cannot omit either field.
- Gave the spells distinct presentation silhouettes: the disc reads as a split
  Dark/Light ring with a trail, while Pocket Eclipse reads as a bright occluded
  orb with four restrained rays. Presentation reads confirmed simulation state
  and owns no reflection, damage or status decisions.

Validation:

- Canonical JSON parse and `git diff --check`: passed.
- Pinned Godot 4.7.1 full headless gate: 14,074 assertions, zero failures.
  New 60/120 Hz coverage proves catalog/compiler parity, champion kit binding,
  exact cost/startup/damage, one surviving world ricochet, reflected velocity,
  consumed bounce count and exact bounded slow duration/ratio.
- Pinned Godot 4.7.1 import: passed with no script/import/runtime error markers.
- Independent 60/120 Hz bootstrap smokes passed with protocol 12, ability hash
  `566a637aa616`, champion hash `81962afbff12` and campus hash `a26f6ecd6105`.
- A compatibility-renderer 1280 x 720 S. Wayne capture passed and was visually
  inspected: selected champion, exact resource maxima and both named controls
  are readable in the always-visible Wellspring HUD.

Known limitations and next task:

- The two champions now have working, differentiated basic pairs but still need
  deeper dummy behavior, defense, full kits, final animation/audio, accessibility,
  replay/network and Windows/Linux package acceptance.
- Next slice promotes the Wellspring's host/join stations and authoritative ENet
  loopback boundary so two players can connect, move and interact without a menu.

Commit: pending. Push: pending.

## 2026-08-11 — Oh Tipi basic combat pair and sparring effigy

Branch: `codex/continuous-overhaul`

What changed and why:

- Replaced Oh Tipi's shared foundation kit with **Rillshot** (wire 140), a
  resource-free Water primary with quick readable cadence, and **Tideline**
  (wire 141), a slower 22-Flux Water crest that deals modest damage and applies
  a bounded 180 ms launch. S. Wayne intentionally retains Arc Primary/Vector
  Lance until the next distinct-kit slice.
- Made equipped primary/active wire IDs canonical champion state. The combat
  compiler now resolves all four projectile definitions by stable wire ID, and
  projectile state carries canonical on-hit control without moving authority
  into presentation. Protocol advanced to 11 for actor kind, equipped kit and
  hit-control compatibility.
- Advanced the campus to schema 3 with a validated 80-Health Sparring Effigy
  beside spawn. It is a stable host-simulation entity, receives ordinary swept
  hits and Tideline launch, has no hidden recovery, renders a clear target/Health
  cue, and resets with the existing Practice Bell.
- Reworked the always-visible HUD to show current/maximum Health, Flux and
  Stamina, readable semantic cast names, each selected champion's actual LMB/RMB
  actions, active Flux cost/cooldown, F interaction and current view mode.

Validation:

- Pinned Godot 4.7.1 import: passed.
- Full pinned headless gate: 13,901 assertions, zero failures. New coverage
  verifies catalog/compiled-value parity, champion kit binding, exact Rillshot
  and Tideline startup/cost/damage/cooldown at 60/120 Hz, Tideline launch state,
  canonical actor kind, target schema/placement/clearance and invalid refusal.
- Independent 60 and 120 Hz bootstrap smokes: passed with protocol 11, ability
  hash `c9339a6c7b62`, champion hash `18f62965e9e2` and campus hash
  `a26f6ecd6105`.
- A compatibility-renderer 1280 x 720 capture passed and was visually inspected:
  named kit hints, exact maxima, the target and all three stations are readable.
- Windows app control successfully aimed and fired Rillshot into the effigy;
  its Health bar decreased. Synthetic right-click was interpreted as another
  left click by the automation layer, so normal hardware Tideline activation
  remains the user's interactive check; exact simulation behavior is covered.
- `git diff --check`: passed; pre-existing `dist/` and `node_modules/` remain
  untouched and untracked.

Known limitations and next task:

- Rillshot/Tideline still use economical procedural projectile VFX and no audio;
  full counterplay presentation, defense, deeper kit slots and final art remain.
- Next slice gives S. Wayne a distinct Dark/Light basic pair that counterplays
  Oh Tipi without automatic elemental damage advantage, then both basic pairs
  enter replay/effigy and local two-player acceptance before host/join transport.

Commit: pending. Push: pending.

## 2026-08-11 — canonical first two champion identities

Branch: `codex/continuous-overhaul`

What changed and why:

- Added a fail-closed `foundation-champions-v1` content catalog for Oh Tipi and
  S. Wayne with stable positive wire IDs, two-to-three validated affinities,
  ancestry/size identity, bounded simulation stats and valid foundation ability
  references. Oh Tipi is a steady Seakin; S. Wayne is now consistently a small
  Hobbit rather than the stale Human/vampire-cloak production entry.
- Promoted champion identity, maxima, recovery rates and bounded ground-speed
  ratio into canonical `PlayerState`; recovery, movement, Edgeweave, HUD and
  replay hashing consume those authoritative fields. Protocol advanced to 9.
- Added the collision-clear Champion Loom below spawn. F/controller north-face
  cycles Oh Tipi and S. Wayne, atomically applies the profile, reloads the
  eight-direction candidate sprite and reports the attunement in a transparent
  world bubble. Both champions keep the full universal movement grammar.
- Added `--champion=oh_tipi|s_wayne` as a deterministic visual/boot diagnostic,
  not as a player-facing menu. Updated the runtime HUD, roadmap, roster truth,
  visual production notes and active backlog.

Validation:

- Pinned Godot 4.7.1 import: passed and generated tracked UIDs for the champion
  catalog and focused suite.
- Full pinned headless gate: 13,728 assertions, zero failures. Coverage proves
  catalog refusal, exact 60/120 Hz profile movement/recovery, resource-ratio
  migration, stable cycling, station focus and canonical identity divergence.
- Independent 60 and 120 Hz bootstrap smokes: passed with protocol 9, champion
  catalog hash `9f807091310f` and campus hash `2700e76503bd`.
- Compatibility-renderer three-frame captures passed for both Oh Tipi and
  S. Wayne at 1280 x 720. Both distinct sprites, named HUD profiles, exact
  resource maxima and the labeled Champion Loom were visually inspected.
- A dummy-renderer movie attempt crashed inside Godot's null texture storage;
  the equivalent compatibility-renderer capture passed, so visual capture must
  continue without `--headless` when runtime textures are drawn.
- `git diff --check`: passed; only pre-existing `dist/` and `node_modules/`
  remain intentionally untracked.

Known limitations and next task:

- The two champions still share Arc Primary and Vector Lance as explicit
  foundation placeholders. The next slice gives Oh Tipi the first distinct,
  readable basic primary/active behavior and a deterministic practice target,
  then gives S. Wayne a counterplaying Dark/Light basic kit.
- Physical F/controller activation still needs the user's normal hardware
  playtest because external synthetic physical-key injection is unreliable in
  Godot; catalog, station focus and app action paths are otherwise covered.

Commit: pending. Push: pending.

## 2026-08-11 — first diegetic walk-up stations

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced the campus to schema 2 with two collision-clear Nexus stations: the
  Movement Guide exposes concise movement notes and the Practice Bell restores
  the deterministic training court and all player resources.
- Added a pure fixed-point nearest-station model with bounded authored radii,
  stable lexical tie-breaking and fail-closed malformed-entry behavior.
- Added F and controller north-face interaction defaults. The Guide toggles a
  transparent world-space bubble; the host-authority Bell executes locally in
  offline play and shows a short player-anchored restoration notice.
- Added original pulsing book/bell pedestals and concise labels. Station content
  validates known command, authority, district, collision clearance, radius and
  one-to-six-line copy before the campus can boot; no detached menu was added.

Validation:

- `git diff --check`: passed; campus JSON parses as schema 2 with two stations.
- Pinned Godot 4.7.1 import: passed and generated tracked UIDs for the station
  focus model and focused test suite.
- Pinned Godot 4.7.1 full headless gate: 13,315 assertions, zero failures.
- Repository stations, exact-range exit, nearest choice, equal-distance stable
  tie-break, invalid entry refusal, invalid command/radius/collision placement,
  F binding and controller binding are covered.
- Independent 60 and 120 Hz headless bootstrap smokes exited successfully.
- Windows interactive smoke remained responsive; both labeled pedestals and
  the F interaction legend were visible at gameplay zoom.

Known limitations and next task:

- External synthetic keyboard injection did not produce reliable Godot
  physical-key events, so bubble activation still needs the user's normal
  keyboard/controller playtest; model, bindings and app flow are structurally
  covered and the build remains open for that check.
- Offline play is the local host, but network request/authorization transport
  does not exist yet; the Practice Bell's declared host authority is content
  policy in preparation for that slice.
- Next slice extends the reusable station contract with champion switching,
  then implements Oh Tipi and S. Wayne selection/runtime identity before
  settings and host/join stations.

Commit: pending. Push: pending.

## 2026-08-11 — intensity-scaled landing readability

Branch: `codex/continuous-overhaul`

What changed and why:

- Added canonical 0–1000 landing intensity selected from the completed route:
  hop, double jump, slide jump, wall kick, fast fall, air dodge and wall skim
  now retain distinct readable impact weight through the short landing window.
- Added a pure presentation sampler with normalized phase, intensity-scaled
  shadow squash and an expanding/fading four-mark rune ring. Reduced motion
  keeps the timing information while limiting travel, opacity and stroke width.
- The runtime composes the pulse beneath the existing semantic land animation,
  clears it on a new traversal action or landing cut, and labels V as the
  contextual technique instead of the incomplete vault/air-only wording.
- Advanced protocol to 8 so replay/session mismatch cannot silently omit the
  canonical landing intensity.

Validation:

- `git diff --check`: passed.
- Pinned Godot 4.7.1 import: passed and generated tracked UIDs for the new
  presentation sampler and focused test suite.
- Pinned Godot 4.7.1 full headless gate: 13,293 assertions, zero failures.
- Landing phase, ring radius/opacity, shadow width and reduced-motion behavior
  are normalized at 60/120 Hz; sampling does not mutate canonical authority.
- Simulation verifies fast-fall intensity survives to landing, wall-skim exit
  uses its authored lighter pulse, and intensity clears with recovery expiry.
- Independent 60 and 120 Hz headless bootstrap smokes exited successfully with
  protocol 8; Windows interactive smoke remained responsive.

Known limitations and next task:

- The ring is procedural original presentation; accepted atlas-specific dust,
  material contact particles and audio remain later polish.
- Collision-safe combat knockdown recovery remains a separate combat slice and
  must not become a universal cancel or erase earned launch advantage.
- Next implementation slice begins walk-up Wellspring station interactions,
  starting with a reusable deterministic proximity/selection model and the
  Movement Guide plus training-reset stations.

Commit: pending. Push: pending.

## 2026-08-11 — bounded authored-obstacle wall skim

Branch: `codex/continuous-overhaul`

What changed and why:

- Added a contextual V wall skim after recent contact with a positive-ID
  authored obstacle: an 18-Stamina purchase produces 420 ms of fixed-speed
  tangent travel and never activates on reserved negative-ID world boundaries.
- Added a separate 300 ms general cooldown and 900 ms same-surface lockout so
  the route is expressive but cannot loop one wall; vault retains priority and
  airborne V retains redirect/air-dodge behavior.
- Added canonical skim direction, timers, surface identity, lockout and explicit
  movement/event state; the existing landing window now provides a short exit
  recovery animation contract. Advanced protocol to 7.

Validation:

- `git diff --check`: passed.
- Pinned Godot 4.7.1 full headless gate: 13,219 assertions, zero failures.
- At both 60 and 120 Hz: positive obstacle contact starts the exact bounded
  skim and cost, requested tangent advances, exit recovery appears, immediate
  same-surface retry spends nothing, and outer boundaries cannot activate it.
- Independent 60 and 120 Hz headless bootstrap smokes exited successfully with
  protocol 7.

Known limitations and next task:

- Wall skim currently reuses the wall-kick animation family until accepted
  character atlases receive a distinct skim strip and surface dust/audio cue.
- Landing state exists and the skim now enters it, but authored intensity,
  squash/ring/audio and collision-safe timed recovery remain incomplete.
- Next implementation slice adds presentation-owned landing/recovery cues, then
  begins walk-up Wellspring station interactions.

Commit: pending. Push: pending.

## 2026-08-11 — variable jump and explicit fast fall

Branch: `codex/continuous-overhaul`

What changed and why:

- Added canonical held-jump and fast-fall command bits. Holding Space preserves
  the authored arc, releasing cuts remaining air time to a bounded 90 ms
  minimum, and airborne Ctrl/C advances descent by one extra tick per tick.
- Added explicit fast-fall simulation/presentation state and mapped it to the
  existing validated fall animation contract; fast fall costs no Stamina because
  accepting an earlier landing is the commitment.
- Added one canonical transition-grace tick so slide-jump and air-redirect events
  remain observable before release-cut timing begins.
- Advanced protocol to 6 and updated movement documentation and status.
- Corrected three earlier worklog assertion totals by summing their preserved
  test logs; no test outcome changed.

Validation:

- `git diff --check`: passed.
- Pinned Godot 4.7.1 full headless gate: 13,106 assertions, zero failures.
- At both 60 and 120 Hz: held jumps outlast released jumps, release preserves
  the exact bounded minimum, fast fall has an explicit mode and exact extra
  descent rate, spends no Stamina, and all Conservatory route transitions remain
  ordered and observable.
- Headless bootstrap at 60 and 120 Hz passed with protocol 6 and unchanged
  canonical campus/ability/material hashes.

Known limitations and next task:

- Jump authority remains a timer-normalized top-down body lift, not a separate
  vertical collision axis; this intentionally preserves the current 2.5D
  topology contract.
- Wall skim and fuller landing/recovery cues remain the final named universal
  movement-feel slices before interactive physical-controller acceptance.
- Next implementation slice adds bounded same-surface wall skim, then begins
  walk-up Wellspring station interactions.

Commit: pending. Push: pending.

## 2026-08-11 — deterministic movement intent buffering

Branch: `codex/continuous-overhaul`

What changed and why:

- Added a shared 180 ms deterministic buffer for dedicated slide, jump-chain
  and contextual technique press edges so slightly early inputs survive narrow
  transition windows without making movement automatic.
- Buffers store semantic intent only. Every tick rechecks speed, aerial stage,
  cooldown, collision target, Stamina and control locks; success consumes the
  matching buffer and expiry spends no resource.
- Included all buffer timers in canonical player state and advanced the command
  protocol to 5 so older replays/sessions cannot silently interpret new timing.
- Updated the public movement contract, overhaul status and active backlog.

Validation:

- `git diff --check`: passed.
- Pinned Godot 4.7.1 full headless gate: 13,081 assertions, zero failures.
- At both 60 and 120 Hz: an early slide fires only after legal entry speed, an
  early jump converts inside the late slide-jump window, successful actions
  consume their buffer, and impossible standing slide expires with no Stamina
  loss.
- Headless bootstrap at 60 and 120 Hz passed with protocol 5 and unchanged
  canonical campus/ability/material hashes.
- Windows interactive compatibility-renderer smoke launched and remained
  responsive with the verified HUD and control legend.

Known limitations and next task:

- Variable jump/fast fall, wall skim and fuller landing/recovery feedback remain
  the open non-ability movement work.
- Controller mapping is structurally tested, but a physical-device acceptance
  session remains required.
- Next slice adds variable jump and fast fall as authoritative bounded state,
  then continues to the Wellspring walk-up interaction layer.

Commit: pending. Push: pending.

## 2026-08-11 — bounded building occlusion for cone view

Branch: `codex/continuous-overhaul`

What changed and why:

- Added pure `SightOcclusion` geometry that projects each axis-aligned
  occluder's two silhouette tangents away from the viewer to a bounded outer
  distance without consulting renderer-owned game state.
- Cone mode now masks space behind every campus building declared
  `los_cutaway`; `low_never_occludes` traversal rails remain visible.
- Preserved the existing validated 15–360° angle and 160–4096 range bounds;
  full-view Sanctum presentation remains the default.
- Updated the public controls/POV contract and active backlog without claiming
  host-side hidden-entity filtering before networking exists.

Validation:

- Pinned Godot 4.7.1 import: passed and registered `SightOcclusion`.
- Full headless gate: 12,944 assertions, zero failures; tangent ownership,
  projection direction, bounded distance, opposite-side viewing and invalid
  inputs are covered.
- 60/120 Hz headless boots with cone 360°/720: passed with protocol 4 and
  identical canonical content hashes.
- Windows interactive 1280 x 720 cone smoke at 120°/720: building north of
  spawn visibly occluded the space behind it while the adjacent vault rail
  remained visible; HUD stayed outside the mask.

Known limitations and next task:

- This is local presentation policy. Authoritative multiplayer modes must omit
  hidden actors/effects/audio from replication and test reconnect, spectator,
  replay and bot paths before cone visibility can govern competitive secrecy.
- Occlusion currently uses a strong opaque wedge. Roof cutaways, soft
  ownership-readable edges and accepted art remain visual-polish work.
- Next slice returns to movement feel completion, then walk-up Wellspring
  interactions and the first two champion vertical slices.

Commit: pending. Push: pending.

## 2026-08-11 — continuous directive and discoverable movement controls

Branch: `codex/continuous-overhaul`

What changed and why:

- Added the repository-owned continuous implementation directive and compact
  active backlog, prioritizing movement, honest visibility, charming readable
  presentation, two complete champions, interactive Wellspring stations and
  authoritative friend hosting/joining while preserving a green checkpoint.
- Versioned commands to protocol 4 with a dedicated slide edge. Shift now
  sprints, Ctrl/C directly slides after the existing readable entry-speed
  commitment, Space jumps/chains, and V retains contextual vault/air control;
  keyboard remapping and controller inputs remain supported.
- Migrated preference schema 1/2 defaults to schema 3 without replacing
  explicit saved alternatives.
- Replaced compressed HP/ST/FX text with distinct Health, Flux and Stamina bars,
  a bounded live movement/event lane and a concise production control legend.
- Made runtime-kit generator provenance hashing newline-canonical so the exact
  approved source validates on Windows CRLF and Linux LF checkouts.

Validation:

- `git diff --check`: passed.
- Pinned Godot 4.7.1 full headless gate: 12,933 assertions, zero failures.
- Dedicated slide entry/cost passed at 60 and 120 Hz; schema 1/2 migrations,
  Shift/Ctrl/C input defaults and portable generator provenance are covered.
- Headless bootstrap at 60 and 120 Hz: passed with protocol 4 and canonical
  campus/ability/material hashes.
- Windows interactive compatibility-renderer smoke: responsive `FLUX 2
  (DEBUG)` window at 1280 x 720; computer-control capture exposed and verified
  repair of an initial title/state overlap; resource bars and controls remain
  legible over the world.

Known limitations and next task:

- Direct slide intentionally requires ordinary movement speed; it is not a
  free standing dash. Input buffering and additional feel work remain backlog.
- The HUD is still code-drawn and uses the fallback font; accepted pixel font,
  bubbles, cooldown cues and settings UI remain later visual slices.
- Cone view still masks by angle/range only. The next slice adds deterministic
  `los_cutaway` building occlusion without granting presentation authority.

Commit: pending. Push: pending.

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
