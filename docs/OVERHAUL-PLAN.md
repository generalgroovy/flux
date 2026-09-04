# FLUX overhaul implementation plan — shared sandbox core

Status: **historical long-form design and implementation record**.

This file preserves earlier reasoning, completed evidence and unimplemented
ideas, including retired dual-rate and mixed-platform assumptions. It is not a
current task queue. Current order lives in `.agent/BACKLOG.md` and
`.agent/OVERHAUL-IMPLEMENTATION.md`; current product and expansion contracts
live in `CORE-GAME-DESIGN.md`, `PLAYER-EXPERIENCE-OVERHAUL.md` and
`FOUNDATION-SYSTEMS.md`.

This plan once superseded the earlier arena/room-oriented sequencing. Existing green
foundations remain valid, but the product they support is now explicitly the
shared elemental sandbox defined in [`CORE-GAME-DESIGN.md`](CORE-GAME-DESIGN.md).

## Status language

- `[x]` implemented foundation exists and is covered by repository tests/fixtures;
- `[ ] In progress` work exists but the acceptance gate is incomplete;
- `[ ] Planned` design is ordered but not yet runtime truth;
- `[ ] Future` deliberately deferred until the core sandbox is accepted.

A green slice remains launchable, reversible and deterministic. Presentation
never becomes simulation authority.

## Source-of-truth order

1. `SPECIFICATION.md` — determinism, authority, networking, safety and runtime
   architecture unless explicitly superseded by a newer focused contract;
2. this plan — implementation order and product-slice boundaries;
3. `CORE-GAME-DESIGN.md` — canonical product/gameplay direction;
4. focused contracts for spellcasting, chemistry, affinities, visuals,
   Wellspring, controls and migrations;
5. `README.md` — concise public status and entry point;
6. legacy FLUX/browser work — migration evidence only.

If an older document describes the initial product as primarily isolated rooms,
weapon classes or procedural dungeons, this plan and the core-design contract
supersede that framing.

# Phase 0 — preserve the deterministic foundations

These foundations are already valuable and must not be discarded during the
design transition.

- [x] Godot 4 project, headless/offline development path and deterministic
  fixed/integer simulation boundaries.
- [x] 60/120 Hz movement/replay verification and stable state hashing.
- [x] Ordered collision, world bounds and immutable worldbone concepts.
- [x] Universal movement foundation: sprint, counter-strafe, hop/double jump,
  wall contact/kick/skim, air redirect/dodge, wavedash, slide/slide jump, vault,
  superglide, fast fall and landing-cut semantics.
- [x] Separate Health, Stamina and spell Flux resources.
- [x] Independent move/aim command representation.
- [x] Projectile state with deterministic IDs, position/velocity, swept collision,
  ownership, damage/control, bounce, expiry and edgeweave near-miss handling.
- [x] Direct-IP ENet host/join foundation with content/protocol handshake,
  host authority, observers, reconnect behavior and an initial eight-player cap.
- [x] Shared Wellspring/session-state foundations including roster/readiness,
  host-controlled practice and bounded multiplayer rounds.
- [x] Packed material grid foundation, separate Charge/elevation state,
  deterministic work queues, exact reset and immutable worldbone mask.
- [x] First-eight reaction design/registry contracts exist; runtime chemistry
  beyond storage/safety remains gated.
- [x] Weighted three-point affinity design is documented; Oh Tipi is Water 2 +
  Charge 1, Fluup Wind 2 + Charge 1, Waka Aren Si is the canonical player-facing
  name for the temporary `nico_lai` technical key.

Exit condition: these foundations remain green while later phases change product
structure and content architecture.

# Phase 1 — Shared Wellspring Sandbox V1

Goal: turn the existing Wellspring/application shell into the **first large
connected playable world**, not merely a staging hub for isolated matches.

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
- [x] Implemented: add 180 ms semantic buffers for slide, jump-chain and
  technique transitions with deterministic expiry and resource-safe rechecks.
- [x] Implemented: add held/released variable jump timing and explicit C/wheel-down
  fast-fall authority/presentation state at bounded rates.
- [ ] Planned: add fuller landing/recovery presentation state,
  and authored elevation/low-cover queries.
- [x] G3 input migration: schema-v1 C-jump/Space-primary and schema-v3 Ctrl-slide
  defaults migrate to schema-v4 Shift sprint/C slide/Space jump/no-key primary
  without replacing explicit saved alternatives; wheel-up jump/wheel-down
  slide, free Ctrl/Alt, mouse primary and controller inputs remain intact.
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
- [x] Implement held/released variable-hop timing, explicit fast fall, and
  authored-obstacle wall skim with bounded Stamina, duration, exit recovery,
  world-edge exclusion, canonical state and same-surface lockout.
- [x] Implement canonical per-route landing intensity and presentation-owned
  land-strip, shadow-squash and expanding rune-ring cues with normalized 60/120
  Hz timing, reduced-motion equivalence and authority immutability.
- [ ] Planned: add bounded launched-trajectory influence and collision-safe
  timed ground recovery without weakening stun, earned launch, recovery, or the
  global speed ceiling.
- [ ] Planned: add deterministic moving-platform relative motion, rails,
  ziplines, lifts, pressure/launch surfaces, currents, wind lanes, grapple
  anchors, and chemistry-derived traction/visibility route modifiers.
- [x] Add Edgeweave Stamina recovery with hostile swept miss-vs-hit geometry,
  committed-speed/full-Stamina/cooldown/training guards, and one reward per
  projectile/fighter pair.
- [ ] In progress: build and measure every ordinary and advanced movement route
  in the authored Conservatory, including exact speed/time records and an
  accessibility bypass; the deterministic integration fixture is complete.
## 1.1 Authored world continuity

- [ ] In progress: produce one coherent traversable authored world containing
  current districts, elevation bands, rooftops/undercroft, gardens, proving
  spaces, foundry/water systems and outbound edges.
- [ ] Replace schematic/mechanics-only geometry with accepted runtime world art
  and collision alignment.
- [ ] Preserve district identity without hard-loading a new game mode at every
  border.
- [ ] Implement bounded streaming/culling only as a performance concern; world
  simulation ownership remains deterministic and explicit.
- [ ] Add ordinary, advanced, systemic and recovery route classes to each major
  region.
- [ ] Maintain worldbone connectivity between critical districts/spawn/service
  paths.

## 1.2 Concurrent player coexistence

- [x] Initial network cap: eight connected players.
- [x] Host/guest actor replication and observer foundations exist.
- [ ] Allow several players to move around the same Wellspring world while
  different local activities are active.
- [ ] Separate safe/social, training, contested and locally sealed activity zones.
- [ ] A local duel/trial may lock its participants/region without pausing or
  unloading unrelated players elsewhere.
- [ ] Add proximity-aware labels/audio/effect budgets so eight players remain
  readable without exposing hidden information.
- [ ] Add explicit join/leave/late-join behavior for world events and trials.

## 1.3 Shared-world reset/anti-grief

- [ ] Every mutable region declares reset group, capacity, ownership and cleanup.
- [ ] Safe/social areas reject hostile damage/chemistry before mutation creation.
- [ ] Proving/lab regions can reset independently through host or activity rules.
- [ ] Persistent player discoveries are stored separately from transient world
  destruction/material state.
- [ ] Host diagnostics expose active material/projectile/field budgets and reset
  reasons.

### Phase 1 exit gate

Eight local/networked players can coexist in one connected authored world,
separate into activities, reunite, manipulate only permitted regions, reset
without corrupting unrelated regions, reconnect and continue on Linux/Windows.

# Phase 2 — Movement as projectile-navigation language

Goal: tune existing movement around readable moving spell geometry rather than a
single generic dodge mechanic.

## 2.1 Ordinary navigation first

- [x] Walk/acceleration/braking/counter-strafe foundation exists.
- [ ] Tune basic movement so ordinary aimed projectiles can often be avoided
  without spending a special evade.
- [ ] Measure player acceleration, projectile speed and camera scale together.
- [ ] Establish standard reaction windows for slow/medium/fast spell geometry.

## 2.2 Evade presentation and semantics

- [ ] Ground committed evade uses an original **roll** presentation.
- [x] Hop/double jump/body-lift/shadow presentation foundation exists.
- [ ] Air/vertical evade reads as jump/hop/body lift rather than a generic dash.
- [ ] Define exact invulnerability policy, if any, in simulation data rather than
  animation frames.
- [ ] Every evade exposes startup/commitment/recovery/destination risk.
- [ ] Reduced-motion mode retains grounded/airborne/readiness distinction.

## 2.3 Movement answers to spell patterns

Create deterministic fixtures for:

- [ ] aimed bolt -> sidestep/counter-strafe;
- [ ] burst/fan -> gap selection/short commitment;
- [ ] wave -> crossing timing;
- [ ] field/residue -> route rotation;
- [ ] ricochet -> geometry prediction;
- [ ] redirected/curving line -> prediction and bait;
- [ ] vertical/ground pressure -> jump/slide choices;
- [ ] multiplayer crossfire -> global spatial awareness.

## 2.4 Existing advanced grammar integration

- [x] Slide, slide jump, air redirect/dodge, wavedash, wall kick/skim, vault and
  superglide foundations exist.
- [ ] Author world routes that make each technique useful without mandatory
  exploitation.
- [ ] Element-created traversal (ice, wind, currents, temporary geometry) feeds
  the same movement state machine instead of teleporting around it.
- [ ] Add bounded impact influence/ground recovery without erasing earned hits.

### Phase 2 exit gate

Combat fixtures demonstrate that movement choices—not invulnerability spam—solve
spell patterns. A new player can identify why a line failed; an expert can use
momentum and environment for better solutions.

# Phase 3 — Universal spell delivery kernels

Goal: replace per-ability projectile special cases and weapon-type thinking with
reusable element-independent delivery geometry.

Canonical contract:
[`SPELLCASTING-DELIVERY-FOUNDATIONS.md`](SPELLCASTING-DELIVERY-FOUNDATIONS.md).

## 3.1 Shared data model

- [ ] Add stable `delivery_id` to authored spell definitions.
- [ ] Validate delivery-specific parameters and forbidden combinations.
- [ ] Separate `delivery` from `elemental_payload` and `pattern_modifiers`.
- [ ] Clients request stable spell IDs + bounded aim/target data only.
- [ ] Canonical hash includes delivery/payload/modifiers/timing.

## 3.2 Burst — first new kernel

- [ ] Change projectile release API from zero/one projectile result to a bounded
  deterministic spawn bundle/event list.
- [ ] Baseline five-shot angles: `-24,-12,0,+12,+24` around **true aim**.
- [ ] Stable left-to-right child ID allocation.
- [ ] Shared speed/radius/lifetime baseline plus schema caps.
- [ ] Exact 60/120 Hz spawn/movement/hit/replay fixtures.
- [ ] Network packet/event budget under simultaneous eight-player burst pressure.
- [ ] Neutral 32x32 center-pivot sprite/VFX foundation with spawn/travel/impact/
  expire phases, no element baked into the base.
- [ ] Test at least two contrasting payloads (recommended Water and Earth or
  Charge) before Burst is accepted.

## 3.3 Normalize Bolt

- [x] Existing projectile behavior is a working Bolt-like foundation.
- [ ] Promote it into explicit `bolt` delivery data rather than hidden assumptions
  in `CombatSystem`.
- [ ] Keep existing wire IDs behavior-compatible; geometry changes require
  versioned migrations.

## 3.4 Remaining kernels

Implement one at a time:

1. [ ] Beam — true line/active-duration semantics, not a very fast projectile.
2. [ ] Spray — bounded cone/stream sampling, not hundreds of entities.
3. [ ] Rapid Fire — cadence kernel with deterministic rate/resource limits.
4. [ ] Whip — semantic curve/segments/tether, never sprite-pixel collision.
5. [ ] Orb — slow/persistent payload; authoritative elevation/lob design before
   gameplay arcs.
6. [ ] Wave — moving region/front with width/speed/elevation rules.

Each kernel requires neutral visuals, accessibility representation and at least
two contrasting element payload tests.

### Phase 3 exit gate

All eight kernels exist as reusable simulation/presentation foundations with no
elemental assumptions, deterministic multiplayer tests and documented pattern
modifier limits.

# Phase 4 — First-eight elemental payload layer

Goal: make element behavior attach cleanly to every spell geometry and actual
world state.

Promoted families remain:

`Earth, Fire, Water, Wind, Ice, Charge, Light, Dark`

Deferred:

`Spirit, Chaos, Gravity, Time`

## 4.1 Payload operation API

- [ ] Define typed operations such as heat, wet, cool, charge, push, fracture,
  reveal, decay and structure/device interaction.
- [ ] A spell impact produces bounded operations, not arbitrary callbacks.
- [ ] Same element payload can attach to Bolt/Burst/Beam/etc.
- [ ] Affinity affects authored access/build efficiency only; no automatic raw
  payload multiplier.

## 4.2 Coverage target

- [ ] Every first-eight element has at least one accepted variant for every
  delivery foundation.
- [ ] Coverage is achieved through data/configuration after kernels and payload
  operations are tested, not by writing 64 independent combat systems.

## 4.3 Visual payload layer

- [ ] Neutral geometry remains readable beneath element VFX.
- [ ] Element grammar uses shape/value/motion/audio in addition to hue.
- [ ] `startup/cast/travel/field/impact/residue/status/reduced_motion` phases map
  consistently across elements.
- [ ] Multiple simultaneous players/elements pass clutter tests.

### Phase 4 exit gate

A spell's geometry can be swapped independently from its element without
rewriting simulation. Element variants remain recognizable and readable in
multi-player crossfire.

# Phase 5 — Selective environment response system

Goal: make the authored world respond differently to elements **only where the
interaction creates useful gameplay**.

Canonical contract:
[`ELEMENT-ENVIRONMENT-RESPONSES.md`](ELEMENT-ENVIRONMENT-RESPONSES.md).

## 5.1 Response schema

- [ ] Materials/props declare explicit supported operations and explicit inert
  responses.
- [ ] Never infer conductivity, flammability, prism behavior or structural
  mutability from sprite appearance.
- [ ] Response classes: inert, cosmetic, state, movement, visibility,
  trajectory, structural, network, hazard, conversion.
- [ ] Strong outcomes declare thresholds, capacity, warning, cleanup and reset.

## 5.2 High-value environmental archetypes

Implement a small interaction-dense set before broad material expansion:

1. [ ] Water basin / sluice / pump.
2. [ ] Furnace / heat source / fuel.
3. [ ] Mutable soil/stone/brick + support structure.
4. [ ] Relay/capacitor/grounding node.
5. [ ] Prism/mirror optical surface.
6. [ ] Vegetation/growth/burn state.
7. [ ] Loose rubble/movable cover.
8. [ ] Wind/pressure device.

Each should touch several existing systems without requiring exhaustive physics.

## 5.3 World authoring tools

- [ ] Debug overlay for material tags, allowed responses, worldbone, reset group
  and active state.
- [ ] Map validator rejects undeclared strong mutations.
- [ ] Editor/test tooling previews response matrix and reset behavior.

### Phase 5 exit gate

Players can predict which authored environment objects react and which are inert;
interactions are useful, readable and performant rather than exhaustive realism.

# Phase 6 — First-eight chemistry execution

Goal: execute the already designed 36 unordered first-eight pair identities as
bounded world-state reactions.

Detailed order remains in
[`ELEMENT-REACTIONS-IMPLEMENTATION-PLAN.md`](ELEMENT-REACTIONS-IMPLEMENTATION-PLAN.md),
with this sandbox priority:

## 6.1 Flagship terrain chain

- [ ] Earth + Fire -> Magma.
- [ ] Elevation-driven bounded molten flow.
- [ ] Water -> Steam + accelerated cooling.
- [ ] Ice -> accelerated solidification.
- [ ] Cooling crust -> Basalt.
- [ ] Fracture -> Rubble.
- [ ] Route/collision/nav update remains local and worldbone-safe.

## 6.2 Movement-state chemistry

- [ ] Water + Ice -> Freeze.
- [ ] Earth + Water -> Mud.
- [ ] Water + Water -> Flood.
- [ ] Ice + Ice -> Glacier.
- [ ] Earth + Ice -> Permafrost.

These feed real traction, acceleration, slide, jump/route and collision rules.

## 6.3 Visibility/vector/network chemistry

- [ ] Fire + Water -> Steam.
- [ ] Wind gas movement / Mistcurrent / Dustfront / Shadowdraft.
- [ ] Water + Charge -> Conductive Flood.
- [ ] Charge networks/grounding/overload/superconduct.
- [ ] Light prism/lens/mirror/boundary interactions.
- [ ] Dark residues/concealment with mandatory disturbance cues.

## 6.4 Multiplayer chemistry ownership

- [ ] Multiple players can contribute sequential/simultaneous element inputs.
- [ ] Physical outcome depends on world state, not affinity contests.
- [ ] Ownership/assist/environment kill credit is deterministic and separate.
- [ ] Team/friendly-fire policy applies through explicit reaction rules.
- [ ] Reaction event/network budgets withstand eight-player stress.

### Phase 6 exit gate

All 36 first-eight pairs have one tested executable baseline with map/movement/
visibility/trajectory/structure significance, deterministic reset and multiplayer
counterplay. Only then can elements 9-12 be reconsidered.

# Phase 7 — Encounter ecology for the shared world

Goal: make the open sandbox interesting without converting every interaction into
an isolated locked room.

## 7.1 Activity types

- [ ] Free exploration and social/training coexistence.
- [ ] Opt-in duels/team exercises.
- [ ] Chemistry challenges and movement races.
- [ ] Roaming PvE encounters.
- [ ] Cooperative local events.
- [ ] Objective/control events.
- [ ] World bosses/major events that seal only the relevant local region when
  required for safety/readability.
- [ ] Secrets/discoveries based on understandable element + movement rules.

## 7.2 Enemy spatial roles

Build small composable archetypes before large enemy counts:

- [ ] aimed-line pressure;
- [ ] fan/burst gap pressure;
- [ ] wave/crossing pressure;
- [ ] pursuit;
- [ ] field/residue placement;
- [ ] support/buff;
- [ ] structure/material manipulation;
- [ ] redirection/reflector;
- [ ] summon/reinforcement;
- [ ] objective/anchor defense.

Bosses compose already-learned spell and movement grammars rather than introduce
opaque exceptions.

## 7.3 Encounter fairness

- [ ] Safe spawn/entry/read time.
- [ ] Environmental state considered when spawning/starting an event.
- [ ] Avoid unavoidable crossfire from unrelated nearby activities.
- [ ] Activity ownership defines hostile boundaries and spectator safety.

### Phase 7 exit gate

The same world supports peaceful activity, training, PvP and PvE without global
mode switches or unreadable overlapping combat.

# Phase 8 — Visual, audio and information hierarchy

Goal: make dense multiplayer spell/chemistry play readable at actual gameplay
zoom.

## 8.1 Character contract

- [x] Eight-direction/semantic animation foundation exists.
- [ ] Migrate directional presentation order deliberately to:
  `N, NE, E, SE, S, SW, W, NW` where new asset contracts require it; do not
  silently reinterpret existing atlases.
- [ ] Universal cast foundations remain symmetric and weapon-independent.
- [ ] Ground roll and aerial jump/evasion states are immediately distinct.
- [ ] Complete remaining champion sprite integration against shared pivots and
  gameplay silhouettes.

## 8.2 Spell hierarchy

Priority:

1. local player state;
2. hostile collision core;
3. immediate terrain/collision;
4. cast/reaction telegraph;
5. other actor silhouette;
6. persistent material state;
7. decoration.

- [ ] Impact VFX surrender priority quickly after dangerous frames.
- [ ] Allied/hostile ownership uses more than color.
- [ ] Element identity uses more than color.
- [ ] Reduced-effects mode preserves all gameplay reads.
- [ ] Multi-player worst-case effect budgets are measured.

## 8.3 Audio

- [ ] Delivery families have distinct timing/geometry cues.
- [ ] Elements layer identity without masking hostile timing.
- [ ] Off-screen/local-event cues are bounded by authoritative information.
- [ ] Safe/social ambience remains quieter than active combat regions.

### Phase 8 exit gate

Eight-player stress scenes remain readable in normal, grayscale, common
color-vision simulations and reduced-effects settings.

# Phase 9 — Champion/loadout integration

Goal: prove that champion identity sits on the shared movement/spell/world system
rather than becoming isolated character scripts.

- [x] Weighted affinity contract: exactly three affinity points, ordinary 2+1,
  Treevor 1+1+1 exception, first-eight only.
- [x] Oh Tipi canonical design: Water 2 + Charge 1.
- [x] Fluup canonical design: Wind 2 + Charge 1.
- [x] Waka Aren Si canonical player-facing name; `nico_lai` remains temporary
  compatibility key pending atomic migration.
- [ ] Central runtime affinity-strength API and full roster content migration.
- [ ] Selection/loadout UI uses three pips and explains affinity as authored
  efficiency/specialization rather than damage bonus.
- [ ] Champion-specific passive/mobility/ultimate compose with shared spell
  kernels and environment rules.
- [ ] One champion at a time passes bot/network/replay/accessibility/platform
  gates.

Recommended representative order remains Oh Tipi -> S. Wayne -> Fluup -> Waka
Aren Si -> Treevor -> remainder.

# Phase 10 — Core vertical-slice acceptance

Before adding major new modes or elements 9-12, prove one complete shared-world
slice.

Required evidence:

| Area | Acceptance |
| --- | --- |
| Shared world | Eight players coexist in one connected authored sandbox and enter/leave local activities independently. |
| Movement | Ordinary and advanced movement both solve readable spell patterns; roll/jump evade states are distinct. |
| Spellcasting | All eight delivery kernels exist; at least a representative subset has polished first-eight payloads. |
| Chemistry | First-eight fundamental reactions meaningfully change routes, surfaces, visibility, trajectories or structures. |
| Environment | Explicit response/inert matrix works; no sprite-derived material authority. |
| Multiplayer | Combined player spells/reactions resolve deterministically with ownership/assist credit and anti-grief rules. |
| Readability | Worst-case local crossfire remains understandable at gameplay zoom and accessibility settings. |
| Safety | Worldbone, reset groups, spawn/objective routes and packet/work budgets remain valid. |
| Determinism | 60/120 Hz suites, replay hashes and supported-platform tests remain stable. |
| Product feel | Players can explore, train, fight, cooperate and discover interactions without requiring a separate procedural mode. |

# Phase 11 — Later expansions

Only after Phase 10 acceptance:

## 11.1 Deferred elements

- [ ] Future design review for Spirit, Chaos, Gravity and Time.
- [ ] No production behavior until first-eight complexity/performance/readability
  measurements are accepted.

## 11.2 Procedural/roguelike modes

- [ ] Future: assemble **authored tactical spaces** through procedural macro
  structure/event selection.
- [ ] Add guarded resource/reward generation and impossible-run prevention.
- [ ] Reuse the same movement/spell/chemistry/AI systems; do not fork gameplay
  physics.

## 11.3 Additional modes/scale

- [ ] Measured scale beyond eight players.
- [ ] Larger PvP/PvPvE/extraction/objective modes.
- [ ] Stronghold/lane/battle-royale experiments only where map/readability/network
  evidence supports them.

These are downstream applications, not prerequisites for the first coherent
FLUX product.

# Development cadence

Every runtime slice follows:

```text
design contract
-> schema/content
-> failing deterministic fixture
-> minimal authoritative implementation
-> replay/reset/hash tests
-> multiplayer/ownership test
-> neutral presentation
-> element/world integration
-> readability/counterplay review
-> stress/performance test
-> Linux/Windows launch/package gate
-> focused reversible checkpoint
```

Bounded preproduction for the next slice may overlap final verification, but only
one unstable authoritative behavior slice is promoted at a time.
