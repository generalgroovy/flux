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
  slide, slide jump, vault, superglide, landing cut, flow recovery timing, and a
  hard authored speed ceiling.
- [x] Compile real-time windows independently for 60 and 120 Hz and verify replay
  determinism at each rate.
- [ ] In progress: rename/separate the universal movement resource as Stamina;
  add independent spell Flux, health, and out-of-combat recovery state.
- [ ] In progress: add independent quantized aim, primary input, remapping, and
  keyboard/mouse/controller command equivalence.
- [ ] Planned: add buffered transitions, variable hop/fall presentation state,
  authored elevation/low-cover queries, per-wall lockout, launch/grapple/charge/
  stun/root/slow contracts, and Edgeweave stamina recovery.
- [ ] Planned: build and measure every ordinary and advanced movement route in
  the Conservatory, including exact speed/time records and accessibility bypass.

Exit gate: the complete universal grammar works in the live Sanctum with
separate resources, independent aim, deterministic replay, collision safety,
readable state, remappable inputs, and keyboard/controller acceptance.

## Chapter 4 — Combat and ability configuration

### 4.1 Command and combat kernel

- [ ] Planned: version the command protocol for independent aim and held/pressed
  combat actions; reject malformed vectors and stale/duplicate commands.
- [ ] Planned: implement deterministic projectile identity, movement, collision,
  expiry, ownership, impact events, and a reliable no-Flux primary.
- [ ] Planned: add Health, damage, invulnerability/status timing, defeat, respawn,
  and out-of-combat recovery with state-hash/replay coverage.

### 4.2 Ability content and loadouts

- [ ] Planned: compile versioned ability definitions with stable string IDs,
  generated wire IDs, explicit defaults, content hashes, positive costs,
  cooldowns, startup/recovery, role, targeting, authority, and counterplay.
- [ ] Planned: validate one passive, one primary, three unique catalog actives,
  one champion-mobility action, and one ultimate per loadout.
- [ ] Planned: enforce the standard 13-point active budget; affinities reduce
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
2. **Slice B — resource and input truth:** separate Stamina/Flux/Health, version
   independent aim and primary input, add remapping/controller defaults, update
   HUD and replay tests.
3. **Slice C — movement completion:** Edgeweave, remaining authoritative movement
   states, authored elevation/low-cover semantics, and Conservatory route fixture.
4. **Slice D — ability configuration:** stable ability registry, legal loadout
   validator, affinities/budget, training configuration, hashes, and migrations.
5. **Slice E — first combat ability:** deterministic primary projectile plus one
   active with startup/cost/cooldown/counterplay and full replay/presentation.
6. **Slice F — chemistry laboratory:** bounded material grid and a small readable
   reaction set in the Proving Grounds.

Only one slice is promoted at a time. If a later experiment fails, the previous
checkpoint remains runnable and does not need reconstruction.
