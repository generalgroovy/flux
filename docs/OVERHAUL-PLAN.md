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

Production uses a rolling handoff: when the current runtime slice enters final
verification, the next slice begins bounded preproduction—acceptance fixtures,
schema/content drafts, original-asset provenance, and interface contracts. Only
one runtime behavior slice is promoted at a time, so overlap removes idle time
without mixing two unstable system changes or losing the previous green build.

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
- [x] Present a schematic palette/mechanics room; explicitly reject it as the
  final topology, perspective, density, landmark, or environment-art target.
- [ ] In progress (immediate G2): replace that schematic with the first authored
  Nexus Court to Movement Conservatory world slice: distinct connected areas,
  worldbone/elevation, traversal bands, reset zones, ordinary/advanced paths,
  landmarks, distant context, and an original modular pixel kit.
  - Implemented: canonical three-quarter campus identity, graph-connected
    bridges with district-owned endpoints, explicit immutable worldbone,
    deterministic elevation queries, per-district ordinary/advanced routes,
    accessible ordinary coverage, bounded movement/proving reset-zone metadata,
    landmarks, scrolling camera and procedural distant/edge presentation.
  - Candidate evidence: a newly generated twelve-module sheet and alpha version
    have immutable hashes, generator/prompt metadata, explicit presentation-only
    authority, candidate status, transparent-corner/chroma checks and a
    fail-closed 4 x 3 manifest. A Godot-only offline preparation tool now creates
    twelve byte-reproducible alpha-trimmed crops with manifest-bound hashes,
    dimensions and presentation pivots. All files remain excluded from import.
  - Still required for G2 promotion: coherent world-unit/nearest-neighbor import
    rules, license review and explicit approval, a runtime modular pixel kit,
    gameplay-zoom silhouette/readability and grayscale/color-vision review,
    collision/art alignment, measured presentation/import budget, and current
    Garuda/Sway visual evidence. Concept candidates are not runtime assets.
  - Pixel-direction constraint: use original FLUX pixels while targeting the
    compact tile economy, limited-ramp clarity, strong silhouettes and readable
    character-to-world scale broadly associated with Game Boy Color-era
    top-down adventures such as *Oracle of Ages* and *Oracle of Seasons*. Never
    copy or extract their sprites, tiles, maps, palettes, symbols, animation or
    trade dress. Historical generated FLUX character boards remain reference
    material, not passed sprite sheets, until manifest/provenance and full
    gameplay-zoom asset acceptance are checked into this branch.
- [ ] Planned: implement shared semantic LOS plus presentation cutaway/fade/
  ownership silhouette so high terrain/buildings/constructs never cover a
  LOS-visible character and no cue leaks a LOS-hidden character.
- [ ] Planned: implement walk-up station commands for training, muster/friends,
  champions, realm/modes, guide/codex, rites/profile, wardrobe/social, and
  settings/accessibility.
- [ ] Planned: implement overlay parity, map UI, shrine interaction, attunement
  persistence, safe party travel, district streaming, and offline capability
  states.

Exit gate (first product acceptance): a player spawns directly into a spacious,
charming, fleshed-out Sanctum; can complete onboarding, movement, chemistry,
spell, interaction, profile/loadout, guide, settings and social flows; can
attune/travel safely; and can see/invite/join friends through privacy-safe
presence. A host can administer teams, friendly fire, training and safe travel.
All essential flows work offline where applicable and source/package acceptance
passes on Garuda Linux/Sway and Windows.

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
- [x] Persist an offline schema-versioned player profile with validated physical
  keyboard remapping, explicit unbinds, conflict rejection, safe fallback, and
  independent world-relative/aim-relative movement presets.
- [x] Add local full view or aim-facing ranged-cone presentation with an exact
  15–360 degree angle, 160–4096 unit range, saved hotkeys, CLI overrides, and a
  HUD-visible state. It never changes simulation or bypasses host visibility.
- [ ] In progress: add the controller-friendly Settings station, interactive
  event capture/conflict explanation, per-device sensitivity/dead-zone curves,
  reset/import/export, and controller command-equivalence acceptance.
- [ ] Planned: add buffered transitions, variable hop/fall presentation state,
  and authored elevation/low-cover queries.
- [x] G3 input migration: schema-v1 C-jump/Space-primary defaults migrate to
  schema-v2 Space jump/no-key primary without replacing explicit saved
  alternatives; malformed reduced-motion data fails closed and left mouse plus
  controller primary inputs remain intact.
- [x] G3 shared jump presentation: present every current aerial traversal as an
  original compact top-down body-lift arc. Keep the
  body ground anchor/collision stable while the rendered body rises; keep a
  separate shadow on the receiving surface that grows broader/darker through
  ascent, peaks at the apex, contracts on descent, and settles at landing.
  Normalized 60/120 Hz samples, reduced motion, canonical-state immutability and
  all seven current hop/aerial/vault modes are covered by 154 assertions. The
  readability reference is broad classic handheld adventure grammar, never
  copied sprites/frames/timing.
- [x] G3 first sprite-body integration: Oh Tipi's manifest-backed
  integrated-candidate atlas now renders in the playable bootstrap with
  nearest-neighbor sampling, semantic 25-action/eight-direction selection,
  normalized action frames, shared jump lift/ground shadow, pre-POV-mask draw
  ordering and fail-closed procedural fallback. Sixty focused assertions plus
  the full suite and leak-free 60/120 Hz launches pass. This is runtime plumbing,
  not final visual approval; accepted Oh Tipi art and every remaining champion
  integration are still required.
- [ ] Planned: add variable-hop/fast-fall authority, bounded launched-trajectory
  influence, collision-safe timed ground recovery, and marked wall skims without
  weakening stun, recovery, same-wall lockout, or the global speed ceiling.
- [ ] Planned: add deterministic moving-platform relative motion, rails,
  ziplines, lifts, pressure/launch surfaces, currents, wind lanes, grapple
  anchors, and chemistry-derived traction/visibility route modifiers.
- [x] Add Edgeweave Stamina recovery with hostile swept miss-vs-hit geometry,
  committed-speed/full-Stamina/cooldown/training guards, and one reward per
  projectile/fighter pair.
- [ ] In progress: build and measure every ordinary and advanced movement route
  in the authored Conservatory, including exact speed/time records and an
  accessibility bypass; the deterministic integration fixture is complete.

Exit gate: the complete universal grammar works in the live Sanctum with
separate resources, independent aim, deterministic replay, collision safety,
readable state, remappable inputs, authority-safe visibility, and keyboard/
controller acceptance.

## Chapter 4 — Combat and ability configuration

### 4.1 Command and combat kernel

- [x] Version command protocol 3 for independent deterministic aim, held
  primary, and active-one presses; stale/duplicate commands remain rejected.
- [ ] Planned: add packet decoding limits, reject malformed wire vectors, and
  validate projectile/ray/arc/volume/geometry/tether/mobility target requests
  before constructing semantic commands.
- [x] Implement deterministic projectile identity, movement, world/player
  collision, expiry, ownership/team filtering, impact events, state hashing, and
  a reliable no-Flux primary.
- [x] Add authoritative Health damage and out-of-combat recovery with replay
  coverage.
- [ ] Planned: add active/contact volumes, launch/impact influence, invulnerability
  and status timing, projectile clash, guard/parry/absorb/reflect roles,
  deployables/fields/tethers, defeat, respawn, and mode-owned friendly fire.

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
- [ ] Planned: compile Flux Formula variants from approved source-family,
  geometry, operation, catalyst, and constraint components; competitive clients
  request stable formula IDs and never supply outcome parameters.

### 4.3 First complete champion slice

- [x] Preserve the passed eighteen-champion visual board locally with immutable
  SHA-256 provenance and make it the minimum silhouette/expression/material
  quality bar. Treat its labels as non-authoritative and its pixels as concept
  reference, never animation frames or collision data.
- [ ] Planned: replace each pictured champion's integrated direction candidate
  with an accepted original gameplay sprite set covering all applicable actions
  in the 25-action manifest. Require Godot runtime playback, frame/pivot/
  alignment validation, gameplay-zoom and accessibility review, and semantic
  60/120 Hz presentation tests. Do not infer completion from portraits,
  direction previews, skeleton atlases, or generated keyframe boards.

- [ ] Planned: select one FLUX-approved champion profile after source/content
  reconciliation; migrate it through definition, selection, training dummy,
  local bot, replay, host/client, reconnect, spectator, accessibility, Linux,
  Windows, and package tests before beginning the next champion.
- [ ] Planned: add one rate-limited semantic taunt input with an interruptible
  shared fallback, then require one original readable taunt animation/audio cue
  per accepted champion; taunts grant no combat, movement, concealment, or
  collision advantage.

Exit gate: one complete champion has a useful primary and configurable legal
loadout; every cast is affordable, interruptible/readable where designed,
authoritative, replayable, and testable without rendering.

## Chapter 5 — Elements, materials, and reactions

- [x] Specify immutable worldbone, deterministic 2.5D columns, stable material
  IDs, bounded awake queues, reset groups, safety rules, and semantic replication.
- [x] Implement C0/C1 foundations: canonical material catalog and wire IDs,
  packed 128 x 128 amount/temperature/wetness/Charge/elevation columns,
  validated compact seed import, complete immutable worldbone perimeter/plinth,
  deterministic bounded awake queue, state/worldbone hashes, exact reset,
  60/120 Hz tests, and a read-only one-texture preview.
- [ ] Planned: implement C2 typed structural damage, damaged stages, support,
  warned ordered collapse, rubble, derived dirty collision, and route safety.
- [ ] Planned: implement C3 heat transfer, Fire/combustion, phase changes,
  steam/ice, thermal shock, conservation/budgets, and semantic cues under one
  authoritative material phase orchestrator.
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
  Angel slot, 20 existing ancestry templates, three provisional arachnoid body
  plans, and the smaller validated data catalog.
- [ ] Planned: approve or rename Weaverkin, Scorpionkin, and Harvestkin body
  plans; validate their normalized footprints, limbs/attachment bones, route
  hooks, size budgets, accessibility reads, and original lore before assigning
  a selectable champion.
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

## Chapter 7 — Maps and world interactions

- [x] Specify versioned map packages containing worldbone/topology, elevation
  bands, mutable seeds, spawns/objectives/portals/interactions, simulation and
  reset groups, navigation/safety hints, presentation layers, and hashes.
- [ ] Planned: implement deterministic elevation/vision/projectile bands,
  bridges/overpasses/undercrofts, low cover, moving surfaces, and derived dirty
  collision/navigation without delegating authority to Godot physics nodes.
- [ ] Planned: define typed reusable devices for doors, switches, relays,
  capacitors, pumps, sluices, furnaces, prisms, mirrors, lifts, cranes, traps,
  portals, and movable cover instead of map-specific scene logic.
- [ ] Planned: author ordinary, committed, and material-created route classes
  with bot costs, accessibility alternatives, spawn/objective route minima, and
  60/120 Hz completion/performance fixtures.
- [ ] Planned: ship one original modular competitive arena through destruction,
  chemistry, objective, reset/rematch, bot, replay, network, dense-fight,
  Linux/Windows, and package acceptance before converting additional maps.
- [ ] Planned: build editor/CI validators for immutable-mask preservation,
  spawn clearance, objective reachability, route redundancy, support/collapse,
  mutable-cell/entity budgets, cleanup, permeability, and content hashes.

Exit gate: maps create meaningful route and material decisions, every device
uses shared typed systems, critical topology survives maximum destruction, and
the same package resets/replays/replicates deterministically.

## Chapter 8 — Modes, networking, and scale

### 8.1 Host/join foundation

- [ ] Planned: implement transport-independent loopback and ENet adapters,
  protocol handshake, capability/content/map hashes, input batches, snapshots,
  prediction, reconciliation, interpolation, rate limits, diagnostics, and clean
  shutdown.
- [ ] Planned: implement join-in-progress, reconnect tokens/checkpoints,
  spectators, and forced-loss host migration before claiming resilience.
- [ ] Planned: make any mode-limited sight authoritative: the host computes
  permitted information and does not replicate hidden actors/events. Local POV
  preferences may restrict that result further and can never reveal more.
- [ ] Planned: add WebRTC/signalling and replaceable self-hosted relay paths only
  after native authority is proven.

### 8.2 Sanctum friends and host administration

- [ ] Planned before any other mode: show privacy-safe friend presence states—
  offline, online, away, in Sanctum/activity, joinable, invite-only, full, and
  incompatible—with clear join-disabled reasons and no IP/session leakage.
- [ ] Planned: support local friends/recent peers/favorites/blocking, LAN
  discovery, direct address, validated invite links/codes, and an optional
  replaceable self-hosted directory/presence adapter. Established sessions must
  survive optional presence loss; offline functionality cannot depend on it.
- [ ] Planned: expose host open/lock/invite/approve/kick/mute/co-host/transfer,
  spectator reservations, readiness, privacy, late join, bot fill, diagnostics,
  announcements, clean end, and sanitized session-report controls.
- [ ] Planned: expose versioned friendly-fire policies (`off`, reduced team, or
  full plus explicit self/reflection/heal/collision rules), named/colored teams,
  assignment/invite/auto-balance/randomize/roster locks, and freeze competitive
  policy at ready/start.
- [ ] Planned: expose shared waypoints, trial/dummy/bot/laboratory reset,
  resource refill, safe party travel/summon, and whole-session transitions.
  Forced ports require an opted-in host-managed practice policy, countdown,
  reason, safe anchor, state clearance, and a visible session-timeline event.
- [ ] Planned: fuzz authorization/rate/size/state boundaries; host privilege
  never permits remote shell/files, client setting mutation, content injection,
  secret mid-round policy changes, or simulation bypass.

### 8.3 Mode order (after Living Sanctum V1)

- [ ] Planned first: fundamentals/freeplay and First Rite over the already
  accepted Sanctum physics, chemistry, environment, base skeleton/movement,
  ancestry, champion, spell, interaction, taunt, friend, and host systems.
- [ ] Planned: PvP duel/team/control/draft/mirror, bots, rounds, rematch.
- [ ] Planned: PvPvE neutral threats, contestable objectives, late join, bounded
  rewards, extraction/convergence.
- [ ] Planned: cooperative PvE survival/siege, enemy grammar, elites, bosses,
  difficulty, and save stability.
- [ ] Planned: seeded roguelike dungeons with branching rooms, run-scoped
  formulas/items, recovery saves, and no competitive-stat leakage.
- [ ] Planned: an original lane/stronghold experiment using shared objectives,
  generated forces, destructible outer structures, and immutable cores; do not
  copy a MOBA map, role roster, item system, terminology, or presentation.
- [ ] Planned: a small battle-royale survival slice with closing pressure and
  reactive sectors only after authority, streaming, spawn/loot fairness,
  reconnect, hardware, and readability gates pass.
- [ ] Planned: measure eight-player readability/authority first; design protocol
  limits for 32+, and attempt larger modes only after profiling and recovery.
- [ ] Planned: encode every mode as a versioned ruleset over shared movement,
  combat, chemistry, champion, map, AI, replay, and network systems rather than
  forking simulation code.

Exit gate: ownership is unambiguous under latency/loss, local/offline modes use
the same rules, and no scale claim exceeds tested simulation/network/visual
budgets.

## Chapter 9 — Production, accessibility, and release

- [ ] Planned: create original pixel-art environment, character, projectile,
  reaction, UI, animation, and audio kits from the approved direction.
- [ ] Planned: lock one virtual-pixel grid and integer camera scale across the
  environment kit and the first accepted character sheet; validate module/frame
  dimensions, pivots, palette ramps, nearest-neighbor import, silhouettes and
  animation alignment before expanding either library.
- [ ] Planned: enforce shape-before-color, collision/danger priority, reduced
  motion/effects, color-vision/grayscale, remapping, controller, readable text,
  and audio-cue alternatives.
- [ ] Planned: add performance budgets for simulation, material work, network,
  rendering, memory, import size, and load/transition time on modest hardware.
- [ ] Planned: prove Linux and Windows source, headless, interactive, package,
  save migration, update/rollback, and clean uninstall.
- [ ] Planned: make Garuda Linux/Sway window/input/audio/portal behavior and a
  supported Windows desktop version co-equal Living Sanctum V1 acceptance gates;
  record exact OS/driver/package evidence rather than assuming engine parity.
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
   Conservatory route fixture. Edgeweave was staged until Slice E projectiles.
4. **Checkpoint D — ability configuration:** stable ability/wire registry,
   canonical hashes, legal slot/loadout validator, eight enabled and four gated
   elements, affinity-only discounts, and exact 13-point foundation build.
5. **Checkpoint E — first combat abilities:** protocol-3 primary/active input,
   Arc Primary and Vector Lance startup/resource/cooldown/recovery, deterministic
   projectile/hit/damage/replay/presentation, and complete Edgeweave guards.
6. **Checkpoint F1 — chemistry storage/safety:** canonical material registry,
   packed 128 x 128 columns, compact Material Yard seed, immutable worldbone,
   bounded canonical work queue, hashes, exact reset, and read-only preview.
7. **Checkpoint G1 — player configuration:** versioned offline physical-key
   bindings; world-relative and aim-relative movement; full or ranged-cone POV;
   exact angle/range; persisted hotkeys; CLI overrides; deterministic command
   transforms; authority-safe visibility contract.
8. **Slice G2 — immediate authored Sanctum replacement:** replace the schematic
   mechanics court with the first vast Nexus-to-Conservatory topology/visual
   slice, district silhouettes, route hierarchy, elevation reads, fast-travel
   context, charming responsive edge dressing, and an original modular pixel
   environment kit. G2 preproduction begins during G1 final verification.
9. **Slice G3 — base body and jump presentation:** reusable ground/body/aim/
   shadow/effect skeleton, original compact handheld-readable body-lift jump,
   landing, interactions, shared fallback taunt, reduced motion, and semantic
   presentation events. The timer-normalized generic body-lift/shadow sampler is
   implemented, and Oh Tipi proves the manifest-backed sprite-body runtime path;
   accepted final art, remaining champion integration, landing/interaction
   event completion, fallback taunt and semantic presentation-event wiring
   remain open.
10. **Slice F2 — structural/thermal reactions:** resume with one phase
   orchestrator, typed damage/stages/rubble/derived collision, then heat/Fire/
   steam/ice and readable deterministic reaction events.
11. **Slice G4 — authored traversal and interaction depth:** variable hop/fast
   fall, input buffers, interactive binding/controller gate, and shared
   traversal devices inside the accepted Sanctum route.
12. **Slice H1 — ancestry/champion/spell foundation:** reconcile body plans and
   one approved design through ancestry, full kit/loadout UI, cues, unique taunt,
   dummy/bot, replay, schema, accessibility, and platform source gates.
13. **Slice I1 — shared Sanctum authority:** loopback then ENet host/join,
   handshake hashes, prediction/reconciliation, snapshot replay, friend status,
   presence adapter boundary, diagnostics, reconnect, and clean shutdown.
14. **Slice I2 — lobby host tools:** teams, friendly-fire/session policy,
   readiness/privacy, moderation, practice controls, safe group travel/ports,
   audit timeline, invalid-permission tests, and Settings/muster UI.
15. **Sanctum V1 acceptance:** complete the remaining walk-up/overlay flows,
   original environment/body/audio polish, performance/accessibility, offline,
   save migration, and Garuda Linux/Sway plus Windows source/package matrix.
16. **Slice J — first arena/mode:** one original map package with objective,
    chemistry/destruction safety, duel/team rules, bots, rounds, rematch, and
    results.
17. **Slice K — continuity:** late join, reconnect, spectators, and forced host
    migration before optional WebRTC/signalling/relay work.
18. **Slices L–M — breadth on proven systems:** cooperative survival/siege,
    then PvPvE expedition, seeded roguelike dungeons, lane/stronghold experiment,
    and only then a measured battle-royale slice.
19. **Slices N–O — content and release:** expand one champion/ancestry/biome/
    reaction/enemy family at a time, then complete original art/audio,
    accessibility/performance, packages, migration, rollback, and release gates.

Only one runtime slice is promoted at a time. Bounded next-slice preproduction
starts during final verification of the current slice. If a later experiment
fails, the previous checkpoint remains runnable and does not need reconstruction.
