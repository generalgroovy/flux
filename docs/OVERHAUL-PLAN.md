# FLUX 2 overhaul implementation plan

## Status language

- `[x]` means implemented in this repository and covered by the named gate.
- `[ ] In progress` means work exists but its chapter gate is not complete.
- `[ ] Planned` means it remains ordered work, not a runtime claim.

Every slice ends in a launchable repository. The minimum checkpoint is: content
validates; pure simulation tests pass at 60 and 120 Hz where relevant; replay
hashes are stable; the project imports and launches headlessly; presentation
does not own authority; documentation and the worklog state limitations; and a
focused commit can be reverted without discarding later unrelated work.

## Source-of-truth order

1. `SPECIFICATION.md` governs runtime architecture, determinism, networking,
   trust boundaries, map safety, and acceptance.
2. This plan governs implementation order and working-slice boundaries.
3. `README.md` is the product brief and public status index.
4. Focused contracts govern chemistry, Sanctum, visuals, and migrations.
5. The FLUX repository supplies validated game goals, compatibility behavior,
   tuning evidence, and migration inputs. It does not override a newer explicit
   FLUX2 architecture or justify copying unsuitable runtime code.

## Chapter 1 — Foundation and source alignment

- [x] Pin Godot 4.7.1, compatibility renderer, offline installer cache, CI, and
  Linux run/test/doctor entry points.
- [x] Establish typed scale-1000 simulation state, semantic commands, stable
  canonical bytes, ordered collision, state hashing, and replay verification.
- [x] Record migrated FLUX movement values and preserve/reference/archive rules.
- [x] Establish original visual direction and protected-asset import boundaries.
- [ ] Planned: cache matching export templates and prove Linux/Windows package
  reproduction from verified local inputs.

Exit gate: the engine and test suite run with no network, both supported match
rates launch, and deterministic state never depends on rendering.

## Chapter 2 — Living Sanctum application shell

- [x] Define nine large combined districts, three layers, reciprocal routes,
  outbound exits, deep-movement routes, and nine attunement nodes.
- [x] Validate known/unique IDs, layers, entrances, routes, travel endpoints,
  unlocks, blocked states, host authority, and destination clearance.
- [x] Present the palette and spatial language in the playable foundation room.
- [ ] In progress: author Nexus Court to Movement Conservatory topology with
  worldbone, elevation, traversal bands, reset zones, and ordinary/advanced
  paths.
- [ ] Planned: implement walk-up station commands for training, muster/friends,
  champions, realm/modes, guide/codex, rites/profile, wardrobe/social, and
  settings/accessibility.
- [ ] Planned: implement overlay parity, map UI, shrine interaction, attunement
  persistence, safe party travel, district streaming, and offline capability
  states.

Exit gate: a player spawns directly into the Sanctum, can complete onboarding,
move between the Nexus and Conservatory, use all essential menus offline, and
attune/travel without a menu-only hidden state or an unsafe destination.

## Chapter 3 — Sanctum movement

- [x] Implement walk, acceleration, braking, sprint, counter-strafe, hop,
  double jump, wall kick/contact memory, air redirect, air dodge, wavedash,
  slide, slide jump, vault, superglide, landing cut, Stamina recovery timing, and a
  hard authored speed ceiling.
- [x] Identify collision walls deterministically, prevent same-wall kick loops,
  bound external speed, and represent launched, grappled, charging, stunned,
  rooted, and slowed control states without bypassing collision.
- [x] Verify an advanced Conservatory route fixture reaches the same slide,
  slide-jump, redirect, vault, and superglide transitions at 60 and 120 Hz.
- [x] Compile real-time windows independently for 60 and 120 Hz and verify replay
  determinism at each rate.
- [x] Separate universal Stamina, spell Flux, and Health with deterministic
  delays/rates; movement cannot spend Flux or Health.
- [x] Add independent quantized aim, primary command state, action-based
  keyboard/mouse/controller defaults, protocol-v3 bytes, and replay hashing.
- [ ] In progress: persist player remapping and verify controller command
  equivalence through an interactive acceptance fixture.
- [ ] Planned: add buffered transitions, variable hop/fall presentation state,
  and authored elevation/low-cover queries.
- [x] Add Edgeweave Stamina recovery with hostile swept miss-vs-hit geometry,
  committed-speed/full-Stamina/cooldown/training guards, and one reward per
  projectile/fighter pair.
- [ ] In progress: build and measure every ordinary and advanced movement route
  in the authored Conservatory, including exact speed/time records and an
  accessibility bypass; the deterministic integration fixture is complete.

Exit gate: the complete universal grammar works in the live Sanctum with
separate resources, independent aim, deterministic replay, collision safety,
readable state, remappable inputs, and keyboard/controller acceptance.

## Chapter 4 — Combat and ability configuration

### 4.1 Command and combat kernel

- [x] Version command protocol 3 for independent deterministic aim, held
  primary, and active-one presses; stale/duplicate commands remain rejected.
- [ ] Planned: add packet decoding limits and reject malformed wire vectors
  before constructing semantic commands.
- [x] Implement deterministic projectile identity, movement, world/player
  collision, expiry, ownership/team filtering, impact events, state hashing, and
  a reliable no-Flux primary.
- [x] Add authoritative Health damage and out-of-combat recovery with replay
  coverage.
- [ ] Planned: add invulnerability/status timing, defeat, and respawn.

### 4.2 Ability content and loadouts

- [x] Compile versioned ability definitions with stable string IDs,
  generated wire IDs, explicit defaults, content hashes, positive costs,
  cooldowns, startup/recovery, role, targeting, authority, and counterplay.
- [x] Validate one passive, one primary, three unique catalog actives,
  one champion-mobility action, and one ultimate per loadout.
- [x] Enforce the standard 13-point active budget; affinities reduce
  build cost but never multiply raw damage; duplicate actives fail closed.
- [ ] Planned: implement training configuration, preview, save-version migration,
  and host handshake compatibility.

### 4.3 First complete champion slice

- [ ] Planned: select one FLUX-approved champion profile after source/content
  reconciliation; migrate it through definition, selection, training dummy,
  local bot, replay, host/client, reconnect, spectator, accessibility, Linux,
  Windows, and package tests before beginning the next champion.

Exit gate: one complete champion has a useful primary and configurable legal
loadout; every cast is affordable, interruptible/readable where designed,
authoritative, replayable, and testable without rendering.

## Chapter 5 — Elements, materials, and reactions

- [x] Specify immutable worldbone, deterministic 2.5D columns, stable material
  IDs, bounded awake queues, reset groups, safety rules, and semantic replication.
- [ ] Planned: implement one 128 x 128 Proving Grounds laboratory with packed
  cells, worldbone mask, dirty chunks, fixed budgets, reset, hashes, and tests.
- [ ] Planned: promote Earth, Fire, Water, Wind, Ice, Charge, Light, and Dark with
  shape/sound/timing/residue language and representative neutral reactions.
- [ ] Planned: integrate material-derived traversal, collision, AI queries,
  rendering, audio, and network corrections without making pixels authoritative.
- [ ] Planned: gate Spirit, Chaos, Gravity, and Time until schema, bounded
  behavior, counterplay, visual acceptance, performance, and replay pass.

Exit gate: two players can deliberately create, read, exploit, counter, reset,
reconnect to, and replay a bounded chemistry encounter without altering
worldbone or exceeding fixed work budgets.

## Chapter 6 — Champions, ancestries, and progression

- [ ] Planned: reconcile the 24 visual slots, 23 named champions, temporary
  Angel slot, 20 ancestry templates, and the smaller validated data catalog.
- [ ] Planned: centralize bounded size/ancestry changes to health, recovery,
  speed, acceleration, mass, radius, knockback, air control, and utility—never
  passive raw spell superiority.
- [ ] Planned: expose Health, recovery, Flux, focus/recovery, speed, and Endurance
  directly in training and selection.
- [ ] Planned: implement ancestry-column champion grid, locked-choice behavior,
  original lore approval, cosmetics, profile/version migration, and bot kits.
- [ ] Planned: preserve stable IDs or provide explicit adapters as compatibility
  champions are replaced one complete successor at a time.

Exit gate: roster data and visuals agree, no placeholder is presented as final,
and every selectable champion passes the same full vertical-slice matrix.

## Chapter 7 — Modes, networking, and scale

### 7.1 Host/join foundation

- [ ] Planned: implement transport-independent loopback and ENet adapters,
  protocol handshake, capability/content/map hashes, input batches, snapshots,
  prediction, reconciliation, interpolation, rate limits, diagnostics, and clean
  shutdown.
- [ ] Planned: implement join-in-progress, reconnect tokens/checkpoints,
  spectators, and forced-loss host migration before claiming resilience.
- [ ] Planned: add WebRTC/signalling and replaceable self-hosted relay paths only
  after native authority is proven.

### 7.2 Mode order

- [ ] Planned: fundamentals/freeplay, First Rite, one champion, one map.
- [ ] Planned: PvP duel/team/control/draft/mirror, bots, rounds, rematch.
- [ ] Planned: PvPvE neutral threats, contestable objectives, late join, bounded
  rewards, extraction/convergence.
- [ ] Planned: cooperative PvE survival/siege, enemy grammar, elites, bosses,
  difficulty, and save stability.
- [ ] Planned: measure eight-player readability/authority first; design protocol
  limits for 32+, and attempt larger modes only after profiling and recovery.

Exit gate: ownership is unambiguous under latency/loss, local/offline modes use
the same rules, and no scale claim exceeds tested simulation/network/visual
budgets.

## Chapter 8 — Production, accessibility, and release

- [ ] Planned: create original pixel-art environment, character, projectile,
  reaction, UI, animation, and audio kits from the approved direction.
- [ ] Planned: enforce shape-before-color, collision/danger priority, reduced
  motion/effects, color-vision/grayscale, remapping, controller, readable text,
  and audio-cue alternatives.
- [ ] Planned: add performance budgets for simulation, material work, network,
  rendering, memory, import size, and load/transition time on modest hardware.
- [ ] Planned: prove Linux and Windows source, headless, interactive, package,
  save migration, update/rollback, and clean uninstall.
- [ ] Planned: publish only from clean reviewed commits with provenance, license,
  replay/protocol/content compatibility notes, checksums, and known limitations.

Exit gate: the build is professionally distributable, recoverable, accessible,
observable, and honest about optional online infrastructure and unsupported
features.

## Immediate working slices

1. **Checkpoint A — present branch:** deterministic movement/replay core,
   expanded Sanctum definition/visual target, validated fast-travel eligibility,
   and styled training room.
2. **Checkpoint B — resource and input truth:** separate Stamina/Flux/Health,
   version independent aim and primary input, add action-based controller
   defaults, update HUD/replay tests, and harden smoke-error detection.
3. **Checkpoint C — movement constraints:** deterministic wall identity and
   same-wall lockout, bounded external control states, and a 60/120 Hz advanced
   Conservatory route fixture. Edgeweave waits for Slice E projectiles.
4. **Checkpoint D — ability configuration:** stable ability/wire registry,
   canonical hashes, legal slot/loadout validator, eight enabled and four gated
   elements, affinity-only discounts, and exact 13-point foundation build.
5. **Checkpoint E — first combat abilities:** protocol-3 primary/active input,
   Arc Primary and Vector Lance startup/resource/cooldown/recovery, deterministic
   projectile/hit/damage/replay/presentation, and complete Edgeweave guards.
6. **Slice F — chemistry laboratory:** bounded material grid and a small readable
   reaction set in the Proving Grounds.

Only one slice is promoted at a time. If a later experiment fails, the previous
checkpoint remains runnable and does not need reconstruction.
