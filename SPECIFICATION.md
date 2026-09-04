# FLUX 2 Godot 4.x Production Specification

> **Historical specification — not current authority.** This file records the
> earlier mixed-platform, 60/120 Hz Sanctum implementation direction. Current
> product truth lives in `README.md`, `.agent/OVERHAUL-IMPLEMENTATION.md`,
> `.agent/OPTIMIZATION-IMPLEMENTATION.md` and validated runtime content. C5.5
> will archive/index useful evidence and replace current-facing specification
> data with the generated Windows/120 Hz state manifest.

## 1. Status

This document was the normative technical specification for an earlier FLUX
implementation phase. It no longer governs current runtime architecture,
networking, determinism, product vocabulary or acceptance criteria.

The implementation must remain incremental. Existing gameplay concepts and reference assets are inputs, not reasons to preserve unsuitable runtime architecture.

Current implementation checkpoint: F1 completes the C0 material registry/
world-column storage and C1 Material Yard seed/worldbone/reset foundation. G1
adds versioned offline player bindings, world/aim-relative movement reference,
and configurable full/ranged-cone POV without changing command protocol or
simulation authority. Material reactions remain gated; G2 replaces the current
schematic court with the first authored Sanctum topology/visual slice.

### 1.1 First product acceptance target: Living Sanctum V1

The first product acceptance test is not a combat mode or a single mechanics
room. It is a fully usable Living Sanctum vertical product that proves the game
can carry every later system without becoming a collection of disconnected
prototypes. Acceptance requires:

- spacious, charming, clearly differentiated Nexus, Conservatory, Proving,
  social/muster, settings, archive/guide, champion, rest/garden, and service
  areas with ordinary paths, deep-movement routes, landmarks, and fast travel;
- a readable original environment kit with strong material/elevation depth,
  dense scenic edges, clear play lanes, responsive props, and no copied assets,
  maps, palettes, layouts, typography, animation frames, or trade dress;
- complete offline arrival, onboarding, settings, training, profile/loadout,
  guide, local interaction, reset/cleanup, and graceful quit flows;
- a basic presentation skeleton whose ground anchor, body lift, shadow,
  facing/aim, movement states, collision, and animation events remain separate;
- satisfying movement and jump presentation, foundational physics/material
  chemistry, at least one safe practice spell path, and stable interactions;
- a friend/session surface that clearly reports privacy-safe presence and makes
  hosting, inviting, joining, leaving, reconnecting, and returning to the same
  Sanctum understandable;
- host administration for lobby policy, teams, training state, safe group
  travel, moderation, and diagnostics with explicit permissions and audit cues;
- one semantic taunt action with an interruptible shared fallback and a unique
  readable animation/cue contract for every later accepted champion;
- headless, replay, 60/120 Hz, modest-hardware, Garuda Linux/Sway and Windows,
  offline, network, accessibility, save migration, package, and clean-shutdown
  evidence.

Other gameplay modes remain gated until Sanctum V1 and its underlying physics,
chemistry, environment, base body/movement, ancestry, champion, spell, and user-
interaction foundations pass their named slices. Online presence is additive:
the Sanctum and all local foundations remain functional without an account,
subscription, lobby service, relay, or internet connection.

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

- Canonical simulation runs at a match-selected 60 or 120 ticks per second.
  The selected rate is frozen before tick zero, negotiated as compatibility
  metadata, and may never change during a match. 60 Hz is the baseline; 120 Hz
  is the high-frequency option for hosts that pass performance budgets.
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
- the frozen 60 or 120 Hz authoritative tick rate;
- map ID and immutable-map hash;
- initial seed and match configuration;
- ordered player and system commands;
- periodic state hashes and optional checkpoints.

Running the same replay on supported platforms must produce identical authoritative hashes at every checkpoint.
Determinism is verified independently at both supported rates; hashes are not
expected to match between rates because the tick stream is part of the replay
contract.

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

### 8.1 Player input and view policy

Physical input is player-local configuration. It maps through named actions and
an approved movement reference into bounded semantic move/aim fields before a
command enters simulation. World-relative input uses fixed screen/world axes;
aim-relative input treats independent aim as forward and rotates local forward/
strafe intent into the same world-space command. Preferences, device type,
sensitivity, and display mode never change acceleration, collision, resources,
cooldowns, damage, or other authoritative outcomes.

Player settings use a versioned offline schema, validate known actions and
value bounds, reject ambiguous non-zero keyboard conflicts, and preserve mouse/
controller events when one keyboard action is rebound or explicitly unbound.
Invalid settings fall back safely and may not prevent offline launch.

Full viewport and ranged-cone POV are presentation policies. If a mode uses
limited vision as a game rule, the host must compute visibility and omit hidden
information from replication, late join, reconnect, spectators, diagnostics,
and client-accessible event streams. A local preference may restrict the
authoritative result but can never widen it. Camera visibility never controls
simulation work, chemistry, collision, bot knowledge, or network authority.

Perspective occlusion is separate from gameplay line of sight. If an actor is
inside the authoritative viewer's permitted LOS but would be covered on screen
by higher terrain, a roof, foliage, building, or construct, presentation must
fade/cut away the foreground or draw a restrained ownership-readable silhouette
so the actor remains visible. If authoritative LOS is blocked, no silhouette,
nameplate, shadow, effect, audio marker, material event, or diagnostics may
reveal the actor. Destructible/moving occluders update both the authoritative LOS
query and presentation cutaway from the same semantic geometry revision.

### 8.2 Jump and body-lift presentation

Jump authority stores ground-plane position and elevation separately.
Presentation uses a compact, immediately readable top-down hop inspired only by
the broad clarity of classic handheld adventure games: the body lifts cleanly
from a stable ground anchor, an attached shadow remains on the receiving
surface and changes scale/value, the apex is unmistakable, and landing has a
short anticipation/impact read. FLUX 2 defines original arcs, timing, sprites,
silhouettes, effects, sounds, and controls; it does not reproduce protected
frames or animation data.

The production default maps the physical Space key to the semantic jump action.
Saved bindings remain remappable, but migration must remove the prototype's
ambiguous Space-to-primary alias without losing an explicit user override. On
takeoff the rendered body rises independently while its collision/ground anchor
stays fixed to authoritative ground-plane motion. A separate shadow stays on
the receiving surface, grows broader and darker through ascent, is largest at
the apex, contracts through descent, and settles crisply on landing. Shadow
phase, body lift, and animation selection derive from normalized authoritative
jump phase and must present equivalent states at 60 and 120 Hz; they never
create height, collision, dodge, invulnerability, or targeting authority.

The current G3 checkpoint implements the shared presentation sample for hop,
wall kick, double jump, slide jump, air dodge, vault, and superglide. It drives
whole-pixel body lift plus a separate broader/darker receiving-surface shadow
from existing authoritative timers. Camera focus, POV origin, collision radius,
canonical serialization, replay data, and gameplay position remain on the
unshifted ground anchor.

Oh Tipi is the first playable manifest-backed sprite candidate. Presentation
maps canonical control and movement states to the existing 25-action atlas,
maps the quantized facing vector to one of eight directions, and derives loop or
action frames from the simulation clock and normalized action phase. Rendering
uses nearest-neighbor sampling, applies lift only to the sprite body, and draws
the body before the authority-preserving POV mask. Missing, invalid, or
unsynchronizable candidate data fails closed to the procedural body. This proves
the runtime integration contract, not final visual acceptance of Oh Tipi or
completion of the remaining champions.

Body lift may not change the ground collision footprint, hide a landing cell,
or invent invulnerability. Elevation affects collision and targeting only
through authoritative elevation bands. Reduced-motion mode keeps the same
timing and uses clearer shadow/outline/value cues with less visual displacement.

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

Content composition has three explicit character layers:

1. an **ancestry/body plan** owns collision class, presentation skeleton,
   locomotion/attachment hooks, size range, and bounded physical modifiers;
2. a **champion** owns identity, affinities, statistics within that budget,
   passive, primary, mobility, ultimate, cues, and lore/visual profile;
3. a **loadout** selects mode-legal catalog actives inside the declared point
   budget.

The existing twenty FLUX ancestry foundations and any expansion—including the
planned arachnoid body-plan family—must enter through this schema. Additional
limbs, tails, wings, roots, reach, or wall-route hooks are explicit tested data,
not presentation-derived hitboxes or unbudgeted attacks.

Composable spell variants are compiled content. A formula may combine an
approved source family, targeting geometry, operation, catalyst, and bounded
constraints, but the result receives its own stable ID, wire ID, defaults,
counterplay, and content hash before selection. Clients never transmit arbitrary
damage, terrain, status, or reaction parameters as a formula.

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
F1 now provides their validated packed storage, static seed, immutable mask,
bounded canonical work queue, hashes, exact reset, and one-texture debug preview.
F2 must add the single authoritative phase orchestrator before any seeded sample
is described as an active reaction.

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

### 11.4 Friends, presence, and joining

Friend identity and presence use replaceable adapters over a local profile and
stable public identifier. When supported and permitted by privacy settings, the
Sanctum roster distinguishes offline, online, away, in Sanctum, in another
activity, joinable, invite-only, full, and incompatible-version states. It
shows why a join is unavailable without leaking a private location, session
code, IP address, concealed mode state, or unapproved activity.

Joining supports LAN discovery, direct address, signed/validated invite URI or
code, and an optional self-hostable directory/presence service. Presence loss
does not terminate an established direct session. Offline profiles, local
friends, recent peers, block lists, favorites, and direct/LAN hosting remain
useful without a central service or subscription.

### 11.5 Lobby host capabilities

The lobby host owns a versioned session policy and may, within declared limits:

- open/close, lock, invite, approve, kick, block, mute, reserve spectator
  places, promote a co-host, and transfer ownership;
- create/rename/color teams, invite or assign players, auto-balance, randomize,
  lock rosters, configure bot fill, and expose every reassignment visibly;
- select friendly-fire `off`, `team_reduced`, or `full`, with exact multipliers,
  self-damage, reflected-damage, healing, collision, and training exceptions;
- choose legal content/rules, privacy, late join, spectators, readiness,
  diagnostics, accessibility floor, tick rate, material budgets, reset policy,
  and practice mutators before the session freezes;
- set shared waypoints, start/stop/reset trials, restore resources, manage
  dummies/bots, reset bounded laboratories, and select ambient presentation
  variants that do not change hidden gameplay rules;
- initiate safe party travel, summon requests, or whole-session transitions to
  validated anchors. Forced relocation is limited to an explicitly opted-in
  host-managed practice session, displays a countdown/reason, and never crosses
  worldbone, active combat, blocked state, or uncleared destination rules;
- pause a private practice session, publish announcements, inspect rate/desync/
  readiness health, export a sanitized session report, and end cleanly.

Policy mutations are authorized, rate-limited, validated, logged in the local
session timeline, and replicated as semantic events. Competitive configuration
freezes at ready/start; it cannot be changed secretly mid-round. Host power does
not permit arbitrary file access, remote commands, client setting changes,
hidden content injection, or bypass of simulation rules. Players always retain
leave, block, report/export, audio/accessibility, and privacy controls.

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

The first body renderer uses a reusable basic skeleton with separate ground
anchor, body/elevation pivot, facing/aim pivot, shadow, equipment/focus points,
effect anchors, and ancestry/champion attachment hooks. Locomotion, jump,
landing, cast, hit, interact, and taunt consume semantic state/events. Every
accepted champion eventually owns an original signature taunt animation and
cue; until then an explicit shared fallback is shown rather than a fake unique
animation. Taunts have no damage, dodge, cancel, concealment, or collision
benefit, are rate-limited, and are interrupted by movement, damage, combat
commitment, travel, or menu/session transitions.

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

### 17.1 Sanctum application hub

The Sanctum is a versioned map package and application shell, not an exception
to simulation or content boundaries. District, layer, connection, travel-node,
and outbound-exit metadata must validate before the hub loads. Spatial desks,
gates, portals, and shrines invoke the same typed application commands as the
overlay menus; neither directly mutates session or simulation state.

The attunement network is session-host authoritative. Both endpoints must be
known, enabled, unlocked, and safe; the origin and destination must differ;
combat/trial/transition/reset states block travel; and destination clearance is
required. Offline solo use executes the same validation locally and never
requires an online service. Each major district also retains an ordinary route
and an authored deep-movement route so fast travel remains convenience rather
than a level-design dependency.

Sanctum composition may study only broad environmental principles associated
with richly staged isometric action games: strong room silhouettes, layered
foreground/midground/background depth, dramatic but readable lighting, densely
dressed non-play edges, responsive ambient props, memorable transitions, and
landmarks visible before labels. FLUX 2 expresses them through its own pixel
perspective, materials, palette ramps, topology, architecture, props, lighting,
characters, UI, and animation. Hades/Hades II maps, assets, palettes, symbols,
rooms, characters, effects, interfaces, camera metrics, and trade dress are not
production inputs.

The pixel-production contract may also study the broad readability constraints
of Game Boy Color-era top-down adventure games, especially the compact tile
economy, restrained ramps, landmark clarity and character/environment scale
associated with *The Legend of Zelda: Oracle of Ages* and *Oracle of Seasons*.
Production inputs must remain original FLUX work: no source sprite, tile, map,
palette extraction, symbol, character, frame, camera metric or trade dress from
those games may enter the repository. Runtime pixel assets use a declared
virtual-pixel grid, nearest-neighbor sampling, integer presentation scale and
manifest-bound dimensions, pivots, animation frames, hashes and provenance.

Historical generated character reference boards are not accepted sprite sheets.
They may constrain review of compact proportions, directional silhouette and
equipment readability only after their provenance is available locally. They
cannot define hitboxes, timing, stats or final palettes, and promotion requires
an explicit asset manifest plus gameplay-zoom, grayscale, color-vision,
alignment, animation, import, memory and performance acceptance evidence.

The user-passed eighteen-champion board at
`assets/concept/flux-champions-visual-style-v1.png` is the mandatory local
minimum for compact silhouette, expression, material/equipment readability,
ancestry identity and elemental personality. Its SHA-256 is
`cb8aa1b3f4e1c41498a35dd37303a3783b0f8fa2c0bbb0b75a89cbd02934732f`.
Its text is non-authoritative where canonical roster data disagrees. Each
pictured champion must ultimately ship as original gameplay sprites covering
every required manifest action and direction; a portrait, direction preview,
skeleton atlas, generated keyframe board, or runtime-addressable candidate does
not satisfy that gate by itself.

### 17.2 Reusable interactions and mode rules

Doors, switches, relays, capacitors, pumps, sluices, furnaces, prisms, mirrors,
lifts, moving platforms, rails, ziplines, traps, portals, and movable cover are
typed reusable simulation devices. Each declares activation/target shapes,
ownership, capacity, cooldown, material/element ports, collision, reset group,
failure diagnostics, accessibility cues, and network serialization. A map may
compose devices but may not hide unique authoritative rules in presentation
scene scripts.

A mode is a versioned ruleset referencing shared maps, actors, catalogs, and
systems. It owns team/player limits, spawns/defeat, objectives, score, rounds,
legal content, friendly fire, material budgets, persistence, late join,
spectating, bots, and networking requirements. Duel, team objectives,
cooperative PvE, PvPvE, roguelike dungeons, lane/stronghold experiments, and
battle royale may add actors/objectives but may not fork movement, combat,
chemistry, champion, replay, or trust-boundary code.

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

### Phase 3: combat and ability foundation

Implement Health/Flux/Stamina separation, independent aim, representative
projectiles/fields, hit resolution, statuses, loadout/formula validation, and
authoritative event cues. Promote one champion only after its complete slot kit
is readable and replayable.

### Phase 4: material and environment foundation

Implement chunk storage, worldbone, bounded reactions, rendering, collision
updates, semantic replication, correction snapshots, and the first original
environment modules needed by the Sanctum.

### Phase 5: Living Sanctum V1 acceptance track

Deliver the first acceptance target through small green slices: authored
spacious districts; elevation/traversal and compact top-down body lift; base
skeleton and interactions; offline stations/settings/profile; training physics,
chemistry, spells and resets; ancestry/champion presentation; taunts; friend
presence; host/join; lobby administration; attunement travel; accessibility;
diagnostics; saves; and clean Garuda Linux/Sway and Windows packages.

The networking slices inside this phase implement local loopback and ENet,
command batching, snapshots, prediction, reconciliation, remote interpolation,
presence adapters, diagnostics, reconnect, and disconnect handling. Hosted
Sanctum sessions are product infrastructure, not a separate competitive mode.

### Phase 6: first arena and mode

Complete one original modular arena through destruction/material safety,
objectives, bots, duel/team rules, rounds, rematch, results, replay, network,
performance, accessibility, and package gates.

### Phase 7: continuity, WebRTC, and browser gate

Add reconnect, spectators, forced host migration, signalling, WebRTC transport,
browser exports, browser performance fixtures, and replaceable relay/TURN
fallback. Disable unsupported features explicitly rather than silently changing
simulation behavior.

### Phase 8: mode/content expansion and release

Add cooperative PvE, PvPvE, seeded roguelike dungeons, lane/stronghold
experiments, and a measured battle-royale slice only on proven shared systems.
Expand one champion/ancestry/biome/reaction/enemy family at a time, then satisfy
Linux/Windows packaging, accessibility, performance, update/rollback, and
release-provenance gates.

## 22. Living Sanctum V1 acceptance criteria

The first product acceptance test passes only when:

1. Fresh Garuda Linux/Sway and Windows source launches and packages enter the
   same spacious authored Sanctum, preserve settings/saves, and stop cleanly.
2. Offline users can onboard, traverse, fast travel, configure controls/view/
   audio/accessibility, inspect the guide/roster/loadout, train, interact,
   reset, and quit without a service or subscription.
3. The Nexus, Conservatory, Proving Grounds, social/muster, archive, champion,
   settings, and recovery functions are visually/spatially distinct, charming,
   legible at gameplay zoom, and reachable by accessible ordinary routes.
4. The original basic body skeleton presents facing, aim, locomotion, compact
   body-lift jump/shadow/apex/landing, cast, hit, interact, and fallback taunt
   without presentation owning collision, invulnerability, or outcomes.
5. Foundational physics/movement, one bounded chemistry laboratory, one legal
   loadout/spell path, basic ancestry/champion data, and shared interactions
   work at 60 and 120 Hz with deterministic replay/reset evidence.
6. Friends can understand privacy-safe online/joinable state, invite or join by
   supported direct/LAN/optional directory paths, leave/reconnect, and retain an
   established session if optional presence goes away.
7. A host can configure friendly fire, teams, readiness, privacy, late join,
   bots/dummies, trials, safe travel/summons, moderation, diagnostics, and clean
   shutdown; permission errors and policy changes are visible and tested.
8. Two Garuda Linux/Sway and Windows clients can share the Sanctum under tested
   latency/loss; prediction never crosses worldbone or creates invalid state.
9. Saved/reconnected state and recorded sessions reproduce authoritative hashes;
   chemistry and host policy recover from injected desync/invalid commands.
10. Headless and interactive performance passes modest-hardware budgets with no
    node-per-cell architecture, hidden online dependency, credential leakage,
    inaccessible essential flow, or unresolved critical cleanup failure.

Web participation is a later optional acceptance extension. PvP, cooperative
PvE, PvPvE, roguelike, stronghold, and battle-royale product modes begin only
after this Sanctum acceptance track is green.

## 23. Definition of done

A system is complete only when its implementation, tests, content schema, network behavior, debugging visibility, performance budget, migration notes, and user-facing cues are all present. A visually functional scene without deterministic and network acceptance is a prototype, not a completed FLUX system.
