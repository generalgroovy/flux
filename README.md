# FLUX 2

FLUX 2 is a fast, top-down magic-and-chemistry arena shooter about mastering
movement, shaping reactive battlefields, and turning elemental rules into
deliberate plays. It is both the Godot 4 reimplementation of FLUX and the
production workspace in which those ideas are made deterministic, hostable,
testable, and expandable.

The target is not a conventional twin-stick shooter with elemental damage
types painted over static rooms. Players preserve momentum through a deep
universal movement grammar, combine character and loadout abilities, and
manipulate a bounded 2.5D material simulation: water conducts Charge, oil
spreads fire, heat creates steam, cold freezes routes, impacts fracture cover,
and immutable `worldbone` guarantees that a match can never destroy its own
critical topology.

## Game and implementation map

Checkboxes report repository truth on the current branch: checked means the
named foundation and its tests exist; unchecked means planned or in progress,
even when design documentation already exists.

- [x] **Chapter 1 — [Product promise](#product-promise)**
  - [x] [Design pillars](#design-pillars)
  - [x] [Player loop](#player-loop)
  - [x] [Visual and audio identity](#visual-and-audio-identity)
- [ ] **Chapter 2 — [The Sanctum](#the-sanctum)** — data/visual foundation
  complete; authored multi-layer runtime map in progress
  - [x] Nine combined districts and three-layer layout contract
  - [x] Validated attunement-node and fail-closed fast-travel rules
  - [x] Styled playable Movement Conservatory foundation
  - [ ] Walk-up stations, overlay menu state machine, map UI, streaming, and
    destination persistence
- [ ] **Chapter 3 — [Movement](docs/OVERHAUL-PLAN.md#chapter-3--sanctum-movement)**
  — deterministic universal grammar in progress
  - [x] Sprint, counter-strafe, hop/double jump, wall kick, air redirect/dodge,
    wavedash, slide/slide jump, vault, superglide, and landing cut
  - [x] Ordered integer collision, per-wall lockout, speed ceiling, explicit
    launch/grapple/charge/stun/root/slow contracts, and 60/120 Hz route/replay
    verification
  - [x] Separate Health, Stamina, and spell Flux; independent quantized aim and
    keyboard/mouse/controller action defaults
  - [ ] Add Edgeweave after hostile projectiles exist, authored elevation, input
    buffering, saved remapping, and interactive route acceptance
- [ ] **Chapter 4 — [Combat and abilities](docs/OVERHAUL-PLAN.md#chapter-4--combat-and-ability-configuration)**
  - [x] Independent move/aim and held-primary command protocol
  - [ ] Reliable resource-free primary projectile and combat resolution
  - [ ] Passive, three budgeted actives, champion mobility, and ultimate slots
  - [ ] Stable ability IDs, validation, 13-point loadout budget, and first
    complete champion vertical slice
- [ ] **Chapter 5 — [Elements and chemistry](docs/OVERHAUL-PLAN.md#chapter-5--elements-materials-and-reactions)**
  - [x] Deterministic reactive-material and immutable-worldbone design contract
  - [ ] Bounded 128 x 128 chemistry laboratory and the first eight element
    families; Spirit, Chaos, Gravity, and Time remain gated
- [ ] **Chapter 6 — [Champions and ancestries](docs/OVERHAUL-PLAN.md#chapter-6--champions-ancestries-and-progression)**
  - [ ] Versioned ancestry/body budgets, champion definitions, statistics, and
    fighting-game selection grid
  - [ ] One champion at a time through selection, bots, network, replay,
    accessibility, and platform gates
- [ ] **Chapter 7 — [Modes and networking](docs/OVERHAUL-PLAN.md#chapter-7--modes-networking-and-scale)**
  - [x] Host-authority, protocol, prediction, reconnect, spectator, and
    host-migration contracts
  - [ ] ENet host/join vertical slice, then PvP, PvPvE, cooperative PvE, bots,
    and measured scale beyond eight players
- [ ] **Chapter 8 — [Production and release](docs/OVERHAUL-PLAN.md#chapter-8--production-accessibility-and-release)**
  - [x] Pinned Godot, headless suites, Linux offline setup, CI definition, and
    original visual-direction provenance
  - [ ] Original runtime art kit, audio system, accessibility gates, Windows
    parity, cached export templates, packages, and release acceptance

The complete gate order, slice boundaries, current status, and definition of a
working checkpoint live in the [FLUX 2 overhaul implementation plan](docs/OVERHAUL-PLAN.md).

![Expanded Sanctum visual direction](assets/concept/sanctum-hub-visual-direction-v1.png)

The image above is an original visual target, not collision geometry or a final
tile set. Its palette, district scale, magical-travel language, layered island
structure, and dense handcrafted pixel-art character define the starting hub
direction.

## Product promise

A successful FLUX 2 encounter should let a new player understand why they were
hit, let a practiced player express a personal movement style, and let an expert
discover useful interactions that remain explainable and reproducible. The game
should feel fast without becoming visually noisy, systemic without becoming
random, and competitive without sacrificing expressive PvE, co-op, training,
social, or experimental modes.

### Design pillars

1. **Movement is a weapon.** Walking, sprinting, counter-strafing, hops, wall
   kicks, double jumps, redirects, air dodges, wavedashes, slides, vaults, and
   superglides share one learnable grammar. Momentum creates options rather than
   bypassing level design.
2. **Chemistry changes decisions.** Materials and elemental fields alter cover,
   traction, visibility, conductivity, routes, hazards, and ability behavior.
   Reactions are telegraphed, deterministic, bounded, and resettable.
3. **Readability outranks spectacle.** Silhouette, shape, motion, timing, sound,
   value, and residue communicate state. Color supports those channels but is
   never the only one.
4. **Depth comes from composition.** Races, characters, abilities, equipment,
   elements, terrain, objectives, and teammates create combinations with
   explicit costs and counterplay instead of one dominant build.
5. **Every mode uses the same rules.** Training, local play, hosted PvP, co-op
   PvE, PvPvE, bots, spectating, and replay analysis share one authoritative
   simulation and content registry.
6. **Players can own the session.** Linux and Windows players can host directly;
   optional signalling or relay services are replaceable and self-hostable.
   Offline solo, bots, training, local tools, documentation, and development
   remain fully usable without a subscription.

## Player loop

The Sanctum is the persistent starting, training, social, and configuration
space. A player learns or tunes a build there, joins a hosted session or chooses
an expedition, enters a resettable arena, then returns with mastery, records,
cosmetic expression, and newly attuned destinations—not power that invalidates
competitive fairness.

Moment to moment:

```text
read terrain -> choose a route -> preserve or spend momentum
      -> cast / fire / interact -> trigger material reactions
      -> read the changed arena -> reposition, counter, or commit
```

Combat should support precise projectiles, shaped fields, melee or contact
techniques, movement attacks, deployables, defensive conversions, and utility.
Aim, collision, damage, cooldowns, reaction ownership, and material mutations
belong to the deterministic simulation; animation, particles, camera, and audio
present confirmed outcomes.

## The Sanctum

The hub is a vast magical academy-fortress spread across a central island,
satellite terraces, rooftop routes, an undercroft, suspended gardens, and
outbound gates. Related activities are combined into memorable districts rather
than isolated menu booths:

- the **Nexus Court** anchors onboarding and the attunement network;
- the **Wayfarer Concourse** combines social, appearance, host/join, modes, and
  expedition staging;
- the **Movement Conservatory** combines fundamentals, advanced routes, races,
  and traversal labs;
- the **Alchemical Proving Grounds** combines aim, bots, destructibles, and safe
  elemental reaction basins;
- the **Living Archive** combines lore, codex, replays, analytics, and research;
- the **Verdant Recovery** combines rest, ingredients, interaction practice,
  dummies, and low-pressure crafting;
- the **Foundry Deep** houses fabrication, the transmutation engine, and the
  flooded undercroft;
- the **Crown Observatory** combines settings, accessibility, diagnostics, and
  session monitoring;
- the **Seasonal Expanse** offers shifting biome pockets and private trials.

Local movement remains rewarding, but distance is never busywork. The central
fountain and district shrines form a diegetic fast-travel network. A shrine must
be discovered and attuned once; unlocked destinations can then be selected from
any safe shrine. Combat, scripted trials, and invalid destinations fail closed.
See [the Sanctum contract](docs/SANCTUM-HUB.md) and its versioned
[map definition](content/maps/sanctum_hub_v1.json).

## Visual and audio identity

FLUX 2 uses richly authored top-down pixel art with warm masonry, dark timber,
aged brass, lush vegetation, deep water, and localized cyan/violet magic. Dense
detail frames clear gameplay lanes; immutable structure is dark and heavy,
interactive systems glow and move, and hazardous chemistry uses distinct shapes
and timing. UI is compact dark-brass instrument work with parchment text fields,
not a wall of opaque fantasy panels. Audio reinforces material, distance,
movement cadence, threat, and successful reactions.

The runtime must remain legible with reduced motion, common color-vision
differences, low effects density, keyboard/mouse, controller, and remapped input.
See [visual direction](docs/VISUAL-DIRECTION.md).

## Runtime architecture

Godot owns presentation, authoring, input, audio, animation, UI, platform
exports, and transport adapters. Canonical gameplay runs in a renderer-independent
fixed-tick layer.

- Engine: pinned Godot 4.7.1, compatibility renderer
- Primary scripting: typed GDScript
- Simulation: integer/fixed-point, deterministic, host-authoritative
- Match tick rate: exactly 60 or 120 Hz, selected before tick zero and frozen
- Native transport target: ENet
- Browser transport target: WebRTC data channels
- Initial platforms: Linux and Windows; Web when its gates pass
- Native extensions: Rust or C++ only after profiling proves a hotspot

```text
semantic input commands
          |
          v
deterministic fixed-tick simulation
          |
          +--> snapshots, state hashes, replay log, network authority
          |
          v
presentation adapters
          +--> pixel art, animation, particles, audio, camera, HUD
```

Godot scene nodes never own the only copy of canonical state. A simulation must
run headlessly, serialize, replay, and verify without rendering. See the
[normative production specification](SPECIFICATION.md) and the
[reactive chemistry contract](docs/reactive-material-system.md).

## Current playable foundation

The repository currently contains a small executable slice, not a finished
game: a styled Sanctum training-room presentation over a deterministic movement
arena, separate Health/Stamina/Flux state, independent quantized aim and primary
input, keyboard/mouse/controller defaults, custom ordered collision, 60/120 Hz
match startup, stable state hashes, replay recording, and headless verification.
It proves the runtime boundary and migrates the first movement values from the
browser FLUX prototype. The primary is command plumbing only until its
projectile slice lands. The full hub art, combat, networking, chemistry runtime,
content, animation, and release exports remain staged milestones.

Run it offline after the engine archive has been prepared once:

```bash
scripts/install-godot.sh
scripts/doctor.sh
scripts/test.sh
scripts/run.sh --tick-rate=120
```

Controls: WASD moves, mouse aims, left click or Space submits primary input, Alt
sprints, C uses the jump/movement chain, V uses the contextual technique, R
restarts the match, and F6 restarts at the other supported tick rate. Controller
defaults use left/right sticks, triggers, shoulders, and east face button. The
rate never mutates inside a running match.

See [development setup](docs/DEVELOPMENT.md) and the
[FLUX movement migration record](docs/MIGRATION-FLUX-MOVEMENT.md).

## Delivery roadmap

1. Deterministic project, movement, collision, replay, CI, and offline toolchain.
2. Sanctum data contract, district traversal slice, menu shell, and asset kit.
3. One representative projectile/ability set and bounded chemistry laboratory.
4. Two-player host/join with prediction, reconciliation, and snapshot replay.
5. Modular arena tooling, bots, objectives, PvP/PvE/PvPvE mode contracts.
6. Reconnect, spectators, accessibility/performance budgets, exports, and
   release packaging.

A slice advances only when determinism, authority, performance, readability,
map safety, replay, and platform gates pass. Scope may grow; correctness is not
waived to make a feature list look complete.

## Project documents

- [Production specification](SPECIFICATION.md)
- [Sanctum hub and fast-travel contract](docs/SANCTUM-HUB.md)
- [Visual direction](docs/VISUAL-DIRECTION.md)
- [Reactive pixel-material and chemistry system](docs/reactive-material-system.md)
- [Movement migration](docs/MIGRATION-FLUX-MOVEMENT.md)
- [Development and offline setup](docs/DEVELOPMENT.md)
- [Character and skeleton reference](reference/character-sprites/README.md)
