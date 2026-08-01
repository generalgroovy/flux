# FLUX 2 Godot 4.x Production Specification

## 1. Status

This document is the normative technical specification for reimplementing FLUX in Godot 4.x. Where older prototypes or reference documents conflict with this specification, this document governs runtime architecture, networking, determinism, project structure, and acceptance criteria.

The implementation must remain incremental. Existing gameplay concepts and reference assets are inputs, not reasons to preserve unsuitable runtime architecture.

## 2. Product target

FLUX is a fast top-down elemental arena game emphasizing:

- expressive, momentum-aware movement;
- readable attacks, reactions, hit states, and hazards;
- tactical manipulation of destructible and reactive terrain;
- multiple viable playstyles with explicit counterplay;
- local, hosted online, PvP, PvE, PvPvE, spectator, and training flows;
- Linux and Windows parity;
- browser support where Godot Web constraints and performance gates permit it.

The first production milestone is a two-player hosted vertical slice in one modular arena with core movement, representative abilities, deterministic replay, and a bounded reactive-material region.

## 3. Engine and language policy

### 3.1 Required baseline

- Use the current supported Godot 4.x release selected and pinned by the repository.
- Record the exact engine version in `project.godot`, CI, export tooling, and release metadata.
- Use the Godot compatibility renderer for the first cross-platform slice unless measured requirements justify a different renderer.
- Use typed GDScript for ordinary scene code, editor tools, UI, adapters, and low-frequency gameplay orchestration.
- Introduce C# only through an explicit repository-wide decision; do not mix languages casually.
- Use Rust or C++ GDExtension only for measured simulation or serialization hotspots with stable interfaces and native/Web fallback plans.

### 3.2 Forbidden architecture

- Canonical game state may not live only in scene-node properties.
- Rendering pixels may not determine authoritative collision or chemistry.
- Physics callbacks may not define the network simulation clock.
- RPC calls may not directly mutate arbitrary scene state.
- Clients may not authoritatively create damage, material mutations, pickups, cooldown completion, or match results.
- Material behavior may not depend on unordered dictionary iteration, frame rate, wall-clock time, or nondeterministic physics results.

## 4. System boundaries

```text
Godot platform layer
  input, windowing, export, file access, audio, rendering, editor tooling

Presentation layer
  scenes, animation, particles, camera, HUD, audio cues, interpolation

Application layer
  session flow, lobby, map loading, menus, settings, save data

Deterministic simulation core
  commands, movement, combat, abilities, entities, materials, reactions, bots

Networking layer
  transport adapters, packet protocol, prediction, reconciliation, snapshots

Content layer
  versioned definitions for races, characters, abilities, materials, reactions, maps
```

Dependencies point inward. The simulation core must not depend on rendered nodes, animation completion, audio, UI, or transport-specific classes.

## 5. Proposed repository layout

```text
flux2/
├── project.godot
├── addons/
├── assets/
│   ├── audio/
│   ├── fonts/
│   ├── shaders/
│   ├── sprites/
│   └── tiles/
├── content/
│   ├── abilities/
│   ├── characters/
│   ├── elements/
│   ├── maps/
│   ├── materials/
│   ├── reactions/
│   └── races/
├── scenes/
│   ├── bootstrap/
│   ├── characters/
│   ├── maps/
│   ├── presentation/
│   └── ui/
├── src/
│   ├── app/
│   ├── content/
│   ├── net/
│   ├── presentation/
│   ├── sim/
│   │   ├── abilities/
│   │   ├── combat/
│   │   ├── entities/
│   │   ├── materials/
│   │   ├── movement/
│   │   └── world/
│   └── tools/
├── tests/
│   ├── fixtures/
│   ├── integration/
│   ├── replay/
│   └── unit/
├── docs/
├── reference/
└── export_presets.cfg
```

Autoloads must be few and explicit. Global mutable state is prohibited except for tightly scoped services such as bootstrap configuration, content registry access, and session ownership.

## 6. Simulation clock and determinism

### 6.1 Fixed tick

- Canonical simulation runs at 60 ticks per second unless profiling establishes another fixed value.
- Rendering may run at any rate and interpolates between confirmed simulation states.
- Inputs are converted to semantic commands tagged with simulation tick and player identity.
- Catch-up work is bounded. The game must not silently execute unbounded simulation steps after a stall.

### 6.2 Deterministic rules

- Use integers or explicit fixed-point values for network-critical calculations.
- Use stable entity IDs, content IDs, iteration order, and tie-breaking rules.
- Use seeded deterministic random streams partitioned by subsystem or event identity.
- Never use system time, default random generators, unordered container traversal, or rendered frame count in authoritative outcomes.
- Serialize enough state to reproduce and hash a simulation tick.

### 6.3 Replay contract

A replay contains:

- protocol and content versions;
- map ID and immutable-map hash;
- initial seed and match configuration;
- ordered player and system commands;
- periodic state hashes and optional checkpoints.

Running the same replay on supported platforms must produce identical authoritative hashes at every checkpoint.

## 7. Entity model

Simulation entities are compact data records referenced by stable IDs. Godot nodes mirror them but do not own them.

Minimum player state includes:

- position, elevation, velocity, facing, and aim;
- movement state and timers;
- collision shape class and size class;
- health, shields, resources, statuses, and immunities;
- race, character, affinities, loadout, cooldowns, and ultimate state;
- owner peer, input sequence, and prediction metadata.

Entity creation and destruction occur through deterministic command buffers so iteration is not invalidated mid-step.

## 8. Movement implementation

Movement is a first-class deterministic subsystem, not an assembly of CharacterBody2D side effects.

Required baseline grammar:

- walk, acceleration, braking, sprint;
- jump or hop with explicit elevation state;
- variable jump, double jump, fast fall, and landing recovery;
- slide and slide jump;
- wall contact, wall kick, and bounded wall jump;
- directional air dodge;
- vault and authored ledge traversal;
- momentum-preserving landings and bounded redirect mechanics;
- launched, grappled, charging, stunned, rooted, slowed, ice, water, and unstable-terrain states.

Use custom deterministic collision queries against authored collision data. Godot physics nodes may support presentation and editor visualization, but network-critical resolution must use stable rules and explicit ordering.

## 9. Content model

Characters, races, elements, abilities, materials, reactions, and maps use versioned data definitions. Godot `Resource` files may be used for authoring, but release builds must compile and validate them into stable registries.

Every network-visible definition requires:

- stable string ID;
- numeric wire ID generated by a checked manifest;
- schema version;
- validation rules;
- explicit default values;
- deterministic ordering;
- content hash.

IDs may be deprecated but never silently reassigned.

## 10. Reactive material integration

The reactive-material specification remains authoritative for chemistry behavior. Godot integration follows these additional rules:

- Simulation cells are data, not one Node2D per cell.
- Store dense chunk data in packed arrays or native buffers.
- Maintain separate immutable `worldbone` masks.
- Process only awake chunks and deterministic dirty queues.
- Render chunks through textures, tile batches, MultiMesh, or custom draw paths; never create a sprite node per cell.
- Rebuild collision and navigation only for dirty bounded regions.
- Replicate semantic material events plus periodic chunk corrections.
- Keep chemistry budgets deterministic and independent of camera visibility.

The first implementation target is one 128 x 128 chemistry-cell region with at least worldbone, stone, brick, wood, water, oil, fire, steam, ice, Charge, and rubble.

## 11. Multiplayer topology

### 11.1 Authority model

FLUX uses a host-authoritative listen server:

- one player process acts as host and canonical authority;
- clients send input commands, never final outcomes;
- clients predict locally controlled movement and selected safe effects;
- the host validates commands, advances the world, and emits snapshots/events;
- clients reconcile predicted state and interpolate remote state.

This satisfies player-hosted P2P operation without trusting all peers equally.

### 11.2 Transports

Expose a transport-independent interface.

- Local loopback: deterministic local testing and split-screen foundations.
- ENet: primary Linux and Windows transport.
- WebRTC data channels: browser-compatible direct peer transport.
- WebSocket relay: optional fallback and diagnostics, not the primary latency path.
- Steam Networking Sockets: optional later desktop distribution adapter.

Transport code handles bytes and connection state only. Game rules operate on versioned packets and commands.

### 11.3 Internet hosting infrastructure

Direct internet hosting may require:

- a signalling service for offer, answer, and ICE exchange;
- STUN for public endpoint discovery;
- TURN or another relay fallback for restrictive NAT/firewall combinations;
- an optional lobby service for room discovery and join codes.

No permanent gameplay server is required for ordinary hosted sessions. Infrastructure dependencies must be replaceable and self-hostable.

## 12. Network protocol

All packets include protocol version, session ID, sender ID, sequence, acknowledgment data, and simulation tick where applicable.

Packet families:

- handshake and capability negotiation;
- lobby and session configuration;
- input command batches;
- authoritative entity snapshots;
- reliable gameplay events;
- material-region events and chunk corrections;
- state hash and desync diagnostics;
- reconnect and migration checkpoints;
- spectator bootstrap and stream control.

Use compact binary serialization. Reject malformed, oversized, stale, unauthorized, or version-incompatible packets before they reach simulation code.

## 13. Prediction and reconciliation

- Predict only locally controlled commands and effects with deterministic replay support.
- Retain a bounded input and state history.
- Acknowledge the newest processed input sequence in host snapshots.
- On correction, restore authoritative state, replay unacknowledged commands, and smooth presentation error separately.
- Do not visually smooth through solid walls, lethal boundaries, or ownership changes.
- Remote players use buffered interpolation and bounded extrapolation.

## 14. Reconnect, spectators, and host migration

### 14.1 Reconnect

Clients retain a session token and last acknowledged snapshot. The host maintains a bounded reconnect grace period and can send a current checkpoint plus subsequent events.

### 14.2 Spectators

Spectators receive snapshots and events but cannot submit player commands. Join-in-progress uses a full checkpoint followed by ordered catch-up events.

### 14.3 Host migration

Host migration is a later milestone and requires:

- periodic migration-capable checkpoints replicated to eligible peers;
- recent input and event history;
- deterministic candidate ranking;
- migration epoch and split-brain prevention;
- content, map, and protocol compatibility checks;
- reconnection to the elected authority;
- replay from the newest mutually acknowledged checkpoint.

Migration must not be claimed complete until forced-host-loss tests pass repeatedly under packet loss and latency.

## 15. Security and trust boundaries

The host validates:

- command rate and sequence;
- movement acceleration and reachable position;
- cooldowns, costs, targeting, and ownership;
- damage, status, pickup, spawn, and material mutations;
- match transitions and scoring.

Clients receive only necessary information. Debug RPCs, editor cheats, and arbitrary resource loading are disabled in production sessions. Network parsers have size limits and fuzz tests.

Player-hosted authority cannot eliminate host cheating. Ranked or high-trust competitive modes may later require dedicated authoritative servers using the same headless simulation core.

## 16. Godot scene policy

Recommended root composition:

```text
Bootstrap
├── Application
├── Session
├── SimulationRunner
├── NetworkSession
├── WorldPresentation
├── AudioDirector
├── UI
└── DebugOverlay
```

Presentation nodes subscribe to simulation snapshots and events. They may interpolate, animate, emit particles, and play audio, but may not feed visual completion back into canonical outcomes.

AnimationTree state is derived from simulation state. Hit frames, invulnerability, projectile creation, and movement impulses are simulation events, not animation callbacks.

## 17. Map authoring

A map package contains:

- immutable topology and worldbone mask;
- elevation and traversal bands;
- mutable material seed layers;
- spawn, objective, portal, and interaction anchors;
- simulation-zone and reset-group definitions;
- navigation hints and safety constraints;
- presentation scenes and decorative layers;
- deterministic content and base-map hashes.

Editor tools must validate spawn clearance, route minima, objective access, worldbone protection, resetability, maximum mutable-cell counts, and competitive hazard budgets.

## 18. Testing strategy

### 18.1 Unit tests

Test pure simulation functions, schemas, packet codecs, material reactions, movement transitions, cooldowns, and validators without rendering.

### 18.2 Determinism tests

- replay the same command log multiple times;
- compare state hashes across debug and release builds;
- compare Linux and Windows results;
- randomize insertion history while preserving canonical IDs;
- test long-running integer bounds and seeded random streams.

### 18.3 Network tests

Automate host, join, input, prediction, correction, packet loss, reordering, duplication, disconnect, reconnect, spectator join, clean shutdown, and later migration.

### 18.4 Performance tests

Record simulation, rendering, serialization, bandwidth, memory, chunk wake count, active reactions, entities, projectiles, and rollback history. CI enforces regression budgets for representative fixtures.

## 19. Performance budgets

Initial targets on modest supported hardware:

- authoritative 60 Hz simulation with headroom;
- no ordinary simulation frame above the configured hard budget;
- bounded material work per tick with stable carry-over;
- no per-frame allocation in hot simulation loops;
- no Node-per-cell or Node-per-particle architecture;
- configurable snapshot rate, initially 20 to 30 Hz;
- bandwidth measured per player and per active material region;
- graceful visual degradation that never changes authoritative results.

Exact numeric budgets must be added after the first profiling fixture and then treated as release gates.

## 20. Build, CI, and exports

CI must:

- use a pinned Godot version;
- import the project headlessly;
- run linting and formatting checks;
- run unit, replay, integration, and network tests;
- build Linux and Windows artifacts;
- build Web artifacts when enabled;
- verify content manifests and hashes;
- archive logs, test reports, and representative replay files.

Release exports must exclude editor-only tools, private test fixtures, debug cheats, and development credentials.

## 21. Migration plan

### Phase 0: preserve and classify

Inventory current FLUX behavior, tests, content, references, and networking semantics. Mark each item as preserve, reinterpret, replace, or archive.

### Phase 1: Godot foundation

Create the pinned project, directory structure, bootstrap scene, settings, input map, headless test harness, CI, and Linux/Windows exports.

### Phase 2: deterministic movement slice

Implement one player, one room, fixed-tick commands, custom collision, state hashing, replay recording, and presentation interpolation.

### Phase 3: hosted multiplayer

Implement local loopback and ENet host/join, command batching, snapshots, prediction, reconciliation, remote interpolation, and disconnect handling.

### Phase 4: combat and abilities

Implement health, resources, hit resolution, representative projectile/field abilities, statuses, and authoritative event cues.

### Phase 5: reactive materials

Implement chunk storage, worldbone, bounded reactions, rendering, collision updates, semantic replication, and correction snapshots.

### Phase 6: content and Sanctum

Build modular character content and the Sanctum training/lobby area with movement, dummies, bots, settings, host/join, map selection, and debug instrumentation.

### Phase 7: WebRTC and browser gate

Add signalling, WebRTC transport, browser exports, browser performance fixtures, and TURN fallback. Disable unsupported features explicitly rather than silently changing simulation behavior.

### Phase 8: reconnect, spectators, migration

Add robust session continuity only after baseline networking is stable.

## 22. Vertical-slice acceptance criteria

The first Godot vertical slice is accepted only when:

1. Linux and Windows clients can host and join the same match.
2. A Web client can join through WebRTC if the browser milestone is enabled.
3. Two players can execute the core movement slice under simulated latency and packet loss.
4. Prediction corrections do not create wall traversal or invalid invulnerability.
5. A recorded match replays to identical state hashes.
6. One bounded reactive region supports the required initial material set.
7. Material changes replicate and recover from an injected desync.
8. Disconnect and reconnect restore the same authoritative state.
9. Headless tests run without rendering or audio.
10. Profiling confirms that no architecture relies on one node per simulated cell.

## 23. Definition of done

A system is complete only when its implementation, tests, content schema, network behavior, debugging visibility, performance budget, migration notes, and user-facing cues are all present. A visually functional scene without deterministic and network acceptance is a prototype, not a completed FLUX system.
