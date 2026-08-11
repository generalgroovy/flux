# FLUX 2

FLUX 2 is a fast, top-down magic-and-chemistry arena shooter about mastering
movement, shaping reactive battlefields, and turning elemental rules into
deliberate plays. It is both the Godot 4 reimplementation of FLUX and the
production workspace in which those ideas are made deterministic, hostable,
testable, and expandable.

This is the canonical unified FLUX repository. The Godot project at the root is
authoritative; the consolidated historical browser implementation is preserved
with its Git ancestry under [`legacy/web-prototype`](legacy/web-prototype) for
reference and migration evidence. Legacy JavaScript state never overrides the
normative Godot specification or simulation.

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
  - [x] [Reference principles and originality boundary](#reference-principles-and-originality-boundary)
  - [x] [Visual and audio identity](#visual-and-audio-identity)
- [ ] **Chapter 2 — [The Wellspring](#the-wellspring)** — data/visual foundation
  complete; authored multi-layer runtime map in progress
  - [x] Nine combined districts and three-layer layout contract
  - [x] Validated attunement-node and fail-closed fast-travel rules
  - [x] Playable schematic mechanics court (not accepted Wellspring art/topology)
  - [ ] Authored Nexus-to-Conservatory world slice matching the approved scale,
    dense-edge/clear-lane composition, district landmarks, and pixel direction
  - [ ] Offline-complete stations plus privacy-safe friends/presence, simple
    host/join, host teams/rules/practice/travel tools, and Garuda Sway/Windows
    acceptance
  - [ ] Walk-up stations, overlay menu state machine, map UI, streaming, and
    destination persistence
- [ ] **Chapter 3 — [Movement and traversal](#movement-and-traversal)**
  — deterministic universal grammar in progress
  - [x] Sprint, counter-strafe, hop/double jump, wall kick, air redirect/dodge,
    wavedash, slide/slide jump, vault, superglide, and landing cut
  - [x] Ordered integer collision, per-wall lockout, speed ceiling, explicit
    launch/grapple/charge/stun/root/slow contracts, and 60/120 Hz route/replay
    verification
  - [x] Semantic slide, jump-chain and technique presses buffer for 180 ms while
    every eventual transition still revalidates state, collision and Stamina
  - [x] Holding Space preserves the full jump arc, release cuts to a bounded
    minimum, and airborne Ctrl/C fast-falls through explicit canonical state
  - [x] V converts recent authored-obstacle contact into a bounded wall skim;
    world edges are excluded and same-surface chaining is locked out
  - [x] Separate Health, Stamina, and spell Flux; independent quantized aim and
    keyboard/mouse/controller action defaults
  - [x] Offline saved keyboard bindings, world-relative and aim-relative
    movement presets, and full/ranged-cone POV with 15–360° angle and adjustable
    range; production defaults are Shift sprint, Ctrl/C direct slide and Space
    jump
  - [x] Cone presentation clamps to 15–360° and masks space behind authored
    `los_cutaway` buildings while low traversal rails remain visible
  - [x] Edgeweave swept hostile near-miss reward with speed, cooldown,
    miss-vs-hit, full-Stamina, training, and per-projectile farming guards
  - [x] Space-only default jump plus timer-normalized body lift and a separate
    receiving-surface shadow for hop, wall kick, double jump, slide jump, air
    dodge, vault, and superglide; reduced-motion and 60/120 Hz presentation
    samples are covered without moving collision, camera, or POV authority
  - [x] Oh Tipi's manifest-backed integrated-candidate atlas is the first
    playable sprite body: semantic movement selects its 25-action/eight-direction
    regions with nearest-neighbor rendering, composed with the shared jump lift
    and ground shadow before POV masking, and fails closed to the procedural body
  - [ ] Add bounded impact influence, timed ground recovery,
    authored elevation, interactive binding UI,
    controller profile persistence, accepted final per-champion animation art,
    remaining champion runtime integration, and interactive route acceptance
- [ ] **Chapter 4 — [Aiming, combat, and abilities](#aiming-combat-and-ability-composition)**
  - [x] Independent move/aim and held-primary command protocol
  - [x] Resource-free Arc Primary and Flux-paid Vector Lance through startup,
    deterministic projectile, swept hit, damage, cooldown, and replay
  - [x] Stable ability/wire IDs, canonical hashes, affinity discounts, gated
    elements, slot validation, and an exact 13-point foundation loadout
  - [ ] Complete targeting families, defense/clash/launch/status rules, passive,
    three actives, mobility, ultimate, formula variants, and configuration UI
  - [ ] First complete champion vertical slice
- [ ] **Chapter 5 — [Elements, chemistry, and destruction](#elements-chemistry-and-destruction)**
  - [x] Deterministic reactive-material and immutable-worldbone design contract
  - [x] Validated material registry, bounded packed 128 x 128 Material Yard
    seed, separate Charge/elevation fields, immutable perimeter/plinth,
    deterministic work queue, hashes, exact reset, and read-only preview
  - [ ] Structural damage and the first live material reactions; the first
    eight element families remain staged and Spirit/Chaos/Gravity/Time gated
  - [ ] Structural fracture, fluids, fire/heat, ice, Charge, gases, residues,
    cleanup, reset, replication, and readable reaction presentation
- [ ] **Chapter 6 — [Ancestries and champions](#ancestries-and-champions)**
  - [ ] Versioned ancestry/body budgets for the existing twenty foundations and
    an original three-body-plan arachnoid family
  - [ ] Reconcile the 23 named designs, temporary Angel slot, visual references,
    affinities, statistics, lore approval, and fighting-game selection grid
  - [ ] One champion at a time through selection, bots, network, replay,
    accessibility, original per-character taunt, and platform gates
- [ ] **Chapter 7 — [Maps and world interactions](#maps-and-world-interactions)**
  - [x] Worldbone, map-package, reset-group, route, hazard, objective, and
    mutable-region contracts
  - [ ] Multi-elevation arena kit, devices, moving surfaces, traversal helpers,
    destructible shortcuts, biome reactions, validators, and modular maps
- [ ] **Chapter 8 — [Modes and networking](#modes-networking-and-progression)**
  - [x] Host-authority, protocol, prediction, reconnect, spectator, and
    host-migration contracts
  - [ ] Living Wellspring friend presence/join and host administration before other
    modes; ENet host/join vertical slice, duel/team/objective PvP, cooperative PvE,
    PvPvE extraction/convergence, roguelike dungeons, lane/stronghold modes,
    battle royale, bots, and measured scale beyond eight players
- [ ] **Chapter 9 — [Production roadmap](#production-roadmap)**
  - [x] Pinned Godot, headless suites, Linux offline setup, CI definition, and
    original visual-direction provenance
- [x] Focused reversible checkpoints A–E remain playable and published
  - [x] Checkpoint F1 establishes chemistry storage/worldbone/reset safety
  - [x] Checkpoint G1 adds persisted controls and configurable POV
  - [ ] G2/G3 continue the Living Wellspring V1 track: authored world, complete
    champion body/animation integration,
    reactions/interactions, first ancestry/champion/spells, friends/host tools,
    then Garuda Sway/Windows acceptance before other modes

The complete gate order, slice boundaries, current status, and definition of a
working checkpoint live in the [FLUX 2 overhaul implementation plan](docs/OVERHAUL-PLAN.md).

![Expanded Wellspring visual direction](assets/concept/sanctum-hub-visual-direction-v1.png)

The image above is an original visual target, not collision geometry or a final
tile set. Its palette, district scale, magical-travel language, layered island
structure, and dense handcrafted pixel-art character define the starting hub
direction.

## Reference principles and originality boundary

FLUX 2 studies successful design principles without reproducing protected
content. Every sprite, sound, name, character, ability, map, mode presentation,
icon, font, animation, layout, and line of code must be original or carry a
compatible documented license.

| Broad reference | Principle considered | Original FLUX 2 interpretation |
| --- | --- | --- |
| The Legend of Zelda: Oracle of Ages / Oracle of Seasons | Compact Game Boy Color-era top-down tiles, economical color ramps, strong character-to-environment scale, readable silhouettes, and clear interaction landmarks | An original FLUX virtual-pixel grid, palette, architecture, characters, props, animation, UI, and effects; no copied sprites, tiles, maps, symbols, palette extraction, characters, animation frames, or trade dress |
| Titanfall/Apex family | Movement routes, momentum conversion, readable traversal objects, independent aim, squad legibility | A stamina-bounded universal movement grammar in authored top-down elevation lanes; champion mobility never bypasses collision or the global speed ceiling |
| Super Smash Bros. Melee | Commitment, recovery, precise landing timing, momentum expression, bounded launch influence | Top-down landing cuts, wavedash geometry, readable startup/active/recovery phases, and future collision-safe impact influence—without copying characters, stages, move data, or control layout |
| Classic handheld Zelda games | A top-down jump reads instantly through compact body lift, a grounded shadow, apex, and crisp landing | An original authoritative elevation arc and original body/shadow presentation; no copied sprite, frame, timing, sound, map, input, or item behavior |
| Hades / Hades II | Strong room silhouettes, layered depth, dramatic landmarks, dense scenic edges, responsive ambience, and clear combat floors | Original pixel-perspective Wellspring districts with FLUX materials, architecture, palette ramps, props, routes, lighting, UI, and interaction grammar; no copied rooms, assets, camera metrics, palette, symbols, or trade dress |
| Noita | Materials and spells producing systemic consequences | A deterministic, host-authoritative, bounded 2.5D chemistry grid with reset groups, work budgets, explicit ownership, and immutable worldbone |
| Magicka | Element composition as a learnable casting language | Versioned Flux Formulas made from approved source, geometry, operation, and catalyst components; competitive recipes are hashed content, not arbitrary unvalidated packets |
| League of Legends | Skillshot clarity, role composition, cooldown/resource decisions, objective pressure | Shape-first aimed abilities, loadout roles, contestable terrain, and modular objective rules without copying champions, abilities, map topology, terminology, or presentation |
| StarCraft/Warcraft | Strong faction/body silhouettes and asymmetric strategic identity | Original ancestry body plans and bounded physical budgets; ancestry never grants automatic spell-damage superiority and no existing faction, creature, lore, or visual design is imported |
| The FINALS | Destruction creating tactical routes | Authored structural layers and contestable shortcuts whose collapse can never destroy spawn safety, objectives, or critical topology |

These references are design-review shorthand, not dependencies or acceptance
criteria. When a reference conflicts with FLUX 2 readability, determinism,
fairness, accessibility, performance, or originality, the FLUX 2 rule wins.

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

The Wellspring is the persistent starting, training, social, and configuration
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

## The Wellspring

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
See [the Wellspring contract](docs/WELLSPRING-HUB.md) and its versioned
[map definition](content/maps/wellspring_hub_v2.json).

### Living Wellspring V1 — first acceptance test

The first accepted product is the Wellspring itself, not an isolated duel or
chemistry demo. It must feel spacious, charming, inhabited, and coherent while
serving as the fully functional application shell. Nexus, movement, chemistry,
social/muster, champion/loadout, archive/guide, settings, recovery, and service
areas need memorable silhouettes, layered elevation, clear ordinary routes,
rewarding advanced routes, environmental responses, and fast travel.

Offline users can arrive, onboard, configure, train, inspect builds/guide,
interact, reset laboratories, traverse, save, and quit without a service. When
connected, the muster/friends surface shows privacy-safe presence such as
offline, online, away, in Wellspring/activity, joinable, invite-only, full, or
incompatible, with a clear reason when joining is unavailable. Direct/LAN and
validated invite joining remain primary; any directory, signalling, or relay is
replaceable and self-hostable.

The host can form/name/color/lock teams, invite/assign/auto-balance players,
choose explicit friendly-fire/self-damage/healing/collision policy, manage
privacy/readiness/late join/spectators/bots, run/reset trials and dummies,
restore practice resources, set shared waypoints, initiate validated group
travel or opted-in announced practice ports, moderate, inspect diagnostics, and
end cleanly. Changes are permission-checked, visible, rate-limited, logged, and
frozen where competition demands it; hosting never grants remote file/shell or
client-setting control.

Foreground terrain, roofs, foliage, buildings, and constructs fade/cut away or
yield to an ownership-readable silhouette when they overlap a character that is
inside the viewer's authoritative line of sight. A character outside LOS is not
revealed by silhouettes, labels, shadows, effects, audio markers, or debug UI.

Acceptance is co-equal on Garuda Linux with Sway and supported Windows: source
and packaged launch, input/window/audio behavior, saves, networking, reconnect,
performance, accessibility, cleanup, and uninstall/rollback evidence. See the
[Living Wellspring V1 acceptance contract](docs/SANCTUM-V1-ACCEPTANCE.md).

## Movement and traversal

Movement must feel expressive at ordinary speed and become deep through timing,
route knowledge, and composition—not through undocumented exploits. Universal
actions spend Stamina; spells and champion actions spend Flux. A character may
specialize in movement, but ancestry, loadout, map devices, or a champion skill
cannot disable ordered collision, erase recovery, or exceed the authored global
speed ceiling.

### Control reference and point of view

Control style and information presentation are independent player choices. The
default `world_relative` preset keeps W/A/S/D aligned to the screen while aim
remains independent. The `aim_relative` preset treats mouse/right-stick aim as
forward: W/S move along facing and A/D strafe perpendicular to it. Neither
preset changes movement tuning or authority; both compile to the same bounded
world-space command fields before tick zero processing.

The default `full` view exposes the whole local viewport. The optional `cone`
view follows aim and accepts an exact integer angle from 15 through 360 degrees
and a range from 160 through 4096 world units. A 360-degree cone is therefore a
circular ranged view, distinct from unrestricted full view. This checkpoint is
a local presentation option; competitive hidden information must later be
host-enforced, and clients may never use a preference to reveal state the mode
did not replicate.

Current physical keyboard bindings, movement reference, view mode, angle, and
range persist in an offline versioned profile. See
[player controls and POV](docs/PLAYER-CONTROLS-AND-POV.md) for hotkeys, exact
command-line values, the editable JSON schema, bounds, and future Settings
station acceptance.

### Universal movement grammar

| Action | Tactical purpose | Commitment and counterplay | Runtime status |
| --- | --- | --- | --- |
| Move + independent aim | Strafe, lead targets, hold crossfire, and retreat without surrendering aim | Acceleration, braking, and counter-strafe timing preserve readable momentum | Implemented |
| Sprint | Pursuit, disengagement, and objective rotation | Continuous Stamina drain and delayed recovery; loud/visible movement signature planned | Implemented |
| Hop / double jump | Clear ground pressure and vary elevation/timing | Paid edges, bounded aerial options, explicit landing state | Foundation implemented; authored elevation pending |
| Slide / slide jump | Commit low and fast, then convert late into a longer route | Entry-speed gate, weak steering, Stamina cost, recovery, and hard cover stops | Implemented |
| Air redirect / air dodge | Correct one line or make one committed aerial escape | Limited use, high cost, fixed duration, collision-safe recovery | Implemented |
| Wavedash | Convert a late angled air dodge into grounded momentum | Exact landing geometry, one queued conversion, no free stacking | Implemented |
| Wall contact / wall kick | Rebound from a brief valid wall-contact window | Stable wall identity and a 220 ms same-wall lockout prevent loops | Implemented |
| Vault / superglide | Cross marked low cover and convert the narrow crest window | Only authored vault surfaces qualify; destination clearance and fixed ceiling are mandatory | Implemented against foundation geometry |
| Landing cut | Trade a timed landing input for reduced recovery and route continuity | Never deletes an attack/status commitment and must remain readable | Foundation implemented |
| Edgeweave | Skim the swept edge of a hostile projectile at committed speed to regain Stamina | No reward on hit, full Stamina, training pressure, low speed, cooldown, or repeat contact | Implemented |
| Variable hop / fast fall | Change aerial duration and contest timing without a new jump | Held/released duration and a no-cost committed fast fall remain bounded and canonical | Implemented |
| Impact influence / brace | Bend a launched trajectory slightly or time a safe ground recovery | Cannot cancel knockback, cross worldbone, or remove the attacker’s earned advantage | Planned |
| Wall skim | Run briefly along an authored traversable wall | One Stamina purchase, 420 ms maximum, exit recovery, same-surface lockout, and no world-edge activation | Implemented against authored obstacle identity |

The input layer will buffer only named transitions for short real-time windows
compiled independently at 60 and 120 Hz. It will not buffer arbitrary actions
through stun, charge, grapple, menus, or network correction. Every action has a
semantic event and a presentation state, so tutorials, bots, replay analysis,
audio cues, and accessibility assists consume the same truth.

### Traversal interactions

Map traversal extends the universal grammar through visible authored objects:

- rails, grind lines, ropes, ziplines, lifts, moving platforms, pressure vents,
  launch surfaces, spring growth, water currents, wind lanes, portals, and
  grapple anchors;
- marked vault/ledge profiles, wall-skim bands, breakable shortcuts, collapsing
  floors, doors, gates, switches, pressure plates, relays, and counterweights;
- ice, mud, oil, water depth, rubble, webbing, vegetation, smoke, steam, low
  gravity, and other surfaces that modify traction, visibility, acceleration,
  or route availability through explicit bounded rules;
- champion mobility that targets a valid anchor, direction, or destination and
  pays Flux rather than masquerading as free universal movement.

An interaction declares ownership, activation shape, capacity, cooldown,
failure reason, collision behavior, network authority, reset group, and
accessibility cue. A moving platform carries riders through deterministic
relative motion; a zipline cannot teleport through blocked geometry; a grapple
must resolve a visible anchor and safe arc; a destructible shortcut must leave a
valid route after collapse.

### Route and movement acceptance

Every competitive map provides at least three understandable route classes: a
low-risk ordinary route, a faster committed route, and a situational route
created or changed by combat/material state. Each route is measured at both
tick rates for completion time, maximum speed, Stamina/Flux cost, failure
recovery, collision clearance, camera readability, bot navigation, and an
accessibility alternative. No advanced technique is required to leave spawn,
reach an objective, or recover from fast travel.

## Aiming, combat, and ability composition

FLUX 2 combines shooter precision with fighter commitment. Moving never points
the character’s aim automatically. Mouse, right stick, keyboard aim, bots, and
replay commands all produce the same quantized direction; the simulation owns
the final ray, sweep, projectile, volume, or placement query.

### Aim language and targeting

| Targeting family | Examples of decisions | Required read |
| --- | --- | --- |
| Projectile | Lead, intercept, weave, clash, reflect, or use cover | Origin, direction, speed class, radius, ownership, element, impact, expiry |
| Ray / beam | Hold a lane, sweep deliberately, interrupt a channel | Startup line, active duration, obstruction, break state, recovery |
| Arc / cone / contact | Commit close, punish movement, protect a flank | Facing, reach, active window, launch direction, punishable recovery |
| Ground or elevation volume | Deny, cleanse, heal, reveal, slow, or prime terrain | Exact boundary, elevation band, activation delay, duration, owner, escape |
| Placed geometry | Create cover, a prism, bridge, trap, relay, or structure | Placement validity, construction time, health/support, collision, destruction answer |
| Tether / channel | Pull, sustain, transfer, guide, or contest | Source/target line, range, interruption, occlusion, sever rule |
| Mobility target | Dash, grapple, vault, launch, swap, or redirect | Destination/anchor validity, path, collision, safe landing, recovery |

Competitive assists may tune stick response, dead zone, sensitivity, reticle
contrast, target friction, limited slowdown, and motion/audio indicators. They
never fabricate a hit, lead perfectly, see concealed targets, alter canonical
projectiles, or differ by network authority. Training-only lead and trajectory
previews are labeled and unavailable where a mode forbids them.

### Fighter rules inside a shooter

Attacks and defenses use explicit startup, active/travel, impact, recovery,
cooldown, ownership, interruption, and expiry phases. Planned combat depth
includes projectile clash priority, guard/parry/absorb/reflect roles, shields
with visible break state, typed stagger and launch, bounded victim impact
influence, collision-safe ground recovery, pierce/bounce/split rules, channels,
fields, deployables, status cleansing, and friendly-fire policy per mode.

Cancel routes are an authored graph, never an animation accident. Hit pause,
camera impulse, particles, and controller rumble may emphasize a confirmed
event but cannot delay or create authority. Every damaging or controlling
action exposes a reaction window or a deliberate positional answer; unavoidable
combos require an explicit short cap and escape rule.

### Resources and loadout

| Layer | Contract |
| --- | --- |
| Health | Defeat resource; recovery begins only after the authored no-damage delay and remains mode configurable |
| Stamina | Universal movement resource for sprinting, hops, slides, air actions, wall routes, and selected recovery techniques |
| Flux | Spell/champion resource; casting delays recovery and insufficient Flux refuses the cast before outcome creation |
| Ultimate charge | Earned through active combat/objective contribution; never passive waiting, self-damage, or target-dummy farming |
| Passive | One champion-defining behavior with a demonstrated trigger, visible state, and anti-farming lockout |
| Primary | Reliable independent-aim pressure that remains useful at zero Flux |
| Active slots | Three unique catalog abilities inside the mode budget; damage, defense, support, terrain, control, and mobility are roles rather than mandatory duplicates |
| Champion mobility | One identity-bearing Flux-paid traversal/combat action, still bounded by collision and speed rules |
| Ultimate | One high-impact commitment with startup, safe routes, ownership, interruption/destruction, expiry, and recovery rules |

The standard competitive active budget is 13 points. An affinity may reduce an
aligned active’s build cost to its declared minimum; it never silently
multiplies damage, healing, duration, radius, control strength, or resource
capacity. Alternative modes may publish a different budget as part of their
hashed ruleset rather than mutate a live match.

### Flux Formulas

The expandable magic layer is a validated formula system, not an unbounded
runtime scripting language. A formula composes approved components:

```text
source family + geometry + operation + optional catalyst + constraints
      -> stable ability variant ID + canonical parameters + counterplay
```

- **Source family** supplies Earth, Fire, Water, Wind, Ice, Charge, Light,
  Dark, or a later approved family.
- **Geometry** chooses a bolt, ray, arc, pulse, field, wall, tether, orbit,
  structure, trail, or movement route.
- **Operation** describes physical intent such as heat, cool, wet, charge,
  push, pull, lift, bind, fracture, grow, decay, cleanse, reveal, refract, or
  redirect.
- **Catalyst** is a second approved element, carried reagent, device, champion
  hook, or material already present in the arena.
- **Constraints** declare cost, points, startup, recovery, cooldown, targeting,
  capacity, cell/entity budgets, ownership, friendly fire, cleanup, and every
  counterplay rule.

Authored recipes compile to stable IDs and content hashes before selection.
Competitive play exposes a curated legal catalog; the Proving Grounds, custom
games, and roguelike modes may expose larger experimental catalogs while using
the same validator. A client can request only an approved formula ID—never send
arbitrary damage, reaction, or geometry parameters to the host.

## Elements, chemistry, and destruction

Elements describe magical intent; materials describe arena state. Neither is a
hidden damage wheel. A Fire champion is not automatically stronger against an
Ice champion. Power comes from aim, timing, geometry, material preparation,
movement, ownership, and the opponent’s visible responses.

| Family | Spatial/chemical identity | Runtime gate |
| --- | --- | --- |
| Earth | Mass, stone, metal, growth, structure, roots, fracture, grounded routes | Catalog enabled; chemistry pending |
| Fire | Heat, ignition, ash, smoke, spreading pressure, delayed bursts | Catalog enabled; chemistry pending |
| Water | Flow, pressure, wetness, current, cleansing, displacement | Catalog enabled; chemistry pending |
| Wind | Directional pressure, sound, push/lift, projectile bending, gas motion | Catalog enabled; chemistry pending |
| Ice | Cooling, brittle matter, frozen terrain, friction, shatter setup | Catalog enabled; chemistry pending |
| Charge | Conductivity, stored force, linked devices, interrupt, delayed discharge | Catalog enabled; projectile foundation live |
| Light | Refraction, reveal, life, healing, geometric protection | Catalog enabled; chemistry pending |
| Dark | Decay, death, blood, shadow, concealment, sacrifice, attrition | Catalog enabled; chemistry pending |
| Spirit | Psyche, dream, resolve, illusion, memory, possession boundaries | Declared but runtime gated |
| Chaos | Entropy, instability, mutation, spatial failure, dangerous rule disruption | Declared but runtime gated |
| Gravity | Weight, pull, orbit, anchoring, curved trajectories, vertical commitment | Declared but runtime gated |
| Time | Delay, haste, echo, recorded state, bounded rewind, cooldown distortion | Declared but runtime gated |

The initial chemistry laboratory uses bounded packed cells and at least
worldbone, stone, brick, timber, metal, glass, soil, vegetation, water, oil,
fire, steam, smoke, ice, Charge, and rubble. It proves deterministic heat,
wetness/flow, ignition, freezing, conductivity, structural damage, derived
collision, reset, replay, and semantic network correction before additional
materials are promoted.

Representative decisions include water conducting a warned Charge discharge;
oil moving before it burns; Fire and Water creating occluding steam; Water and
Ice creating a breakable low-friction route; thermal shock cracking glass or
stone; Earth and Water creating mud; Wind driving gases and loose matter; Light
refracting through a temporary prism; growth creating cover that can later burn;
and collapse producing rubble that changes movement without deleting worldbone.

### Destruction safety

Every map separates three structural layers:

1. **Worldbone** is immutable critical topology: outer bounds, spawn safety,
   objective foundations, essential portals, reset machinery, and minimum
   connectivity.
2. **Authored structure** is staged and destructible: walls, floors, supports,
   doors, bridges, glass, devices, trees, and cover with typed damage and clear
   damaged states.
3. **Transient matter** is bounded match state: liquids, gases, loose solids,
   fields, residues, growth, debris, and ability-created geometry with explicit
   capacity and cleanup.

Support loss enters a warned failure stage before ordered collapse. Safety
validators prove spawn clearance, objective access, route minima, resetability,
active-cell limits, debris limits, and immutable-mask hashes before a map can be
selected. Competitive cleanup is predictable; PvE may allow longer persistence
but still obeys hard budgets.

## Ancestries and champions

“Race” in older notes maps to **ancestry** in current content. An ancestry owns
body geometry, locomotion hooks, anatomy attachments, material read, size range,
and bounded physical modifiers. A champion separately owns identity, posture,
equipment, affinities, passive, primary, mobility, ultimate, voice/audio, lore,
and visual profile. A loadout then selects catalog actives. This separation lets
new champions reuse tested body plans without copied renderers or changed
competitive hitboxes.

### Ancestry body-plan catalog

The twenty FLUX foundations remain design inputs. The arachnoid expansion adds
three provisional original body plans; names and lore remain subject to author
approval before player-facing use.

| Ancestry/body plan | Direction and bounded gameplay hooks |
| --- | --- |
| Human | Adaptable gear-led silhouette; no extreme body advantage |
| Dwarf | Broad grounded form, structure resistance, slower route profile |
| Gnome | Tiny device specialist, low health/mass, compact readable equipment |
| Hobbit | Low profile and recovery focus, increased launch vulnerability |
| Elf | Tall precise posture and air control, fragile body budget |
| Orc | Heavy commitments and bounded interruption resistance, slower recovery |
| Troll | Huge enduring body, delayed recovery, very readable actions |
| Minotaur | Forward momentum and structural impact, poor turning/miss recovery |
| Seakin | Fins and water-route steering whose value depends on authored currents |
| Wyrmborn | Scaled wing silhouette and one strong aerial commitment, reduced Stamina |
| Stoneborn | Braced mineral mass and structure synergy, slow movement |
| Treefolk | Rooted stability and growth hooks, large fire-vulnerable presentation |
| Sylph | Streamer-wing air control with very low health and mass |
| Undead | Remnant/rune anatomy, reduced ordinary healing, explicit restoration rules |
| Goblin | Fast tool-led play and bounded salvage, fragile body |
| Nymph | Bloom/support interactions whose power depends on readable reactions |
| Vampire | Controlled pursuit and interruptible sustain through Dark/blood setup |
| Werewolf | Forward-weighted breaker with strong commitment and weak turning |
| Angel | Feather-wing visual/body foundation only; permanent champion identity remains unapproved |
| Demon | Angular redirect silhouette without sexualized anatomy or religious caricature |
| Weaverkin (provisional arachnoid) | Low, wide eight-limb runner with authored wall/web route hooks; normalized combat footprint and no passive wall bypass |
| Scorpionkin (provisional arachnoid) | Braced pincers and segmented tail with long readable attack attachments; armor/mass paid by speed, radius, and recovery budget |
| Harvestkin (provisional arachnoid) | Tall long-limbed sensor/stride profile with fragile joints and clear ground footprint; reach never silently enlarges hitboxes or spell damage |

Size classes modify only bounded Health, recovery, speed, acceleration, mass,
footprint, knockback response, air control, camera/readability, and traversal
clearance. Auxiliary arms, wings, tails, roots, horns, fins, and arachnoid legs
declare presentation bones and ability anchors; they are not surprise hitboxes
or free attacks. Every ancestry must fit standardized navigation footprints or
an explicitly tested large-body class.

### Existing character design roster

<!-- BEGIN CHARACTER_ROSTER_V1 -->

The 24 entries below are the current migration roster: 23 named designs
and one deliberately unapproved Angel slot. **Ancestry** is the current
term for race. The supplied FLUX Champions sheet below is the minimum
accepted visual baseline for character expression, silhouette, equipment,
materials, elemental framing and pixel-art density. Canonical Flux2 data
still overrides conflicting labels visible in that reference.

![FLUX Champions minimum character-art baseline](assets/concept/flux-champions-visual-style-v1.png)

The first higher-detail action study is a quarantined 25-pose Oh Tipi board:

![Oh Tipi quarantined 25-pose visual candidate](assets/concept/champion_keypose_candidates/oh_tipi/oh_tipi_keypose_imagegen_v1.png)

It is deliberately excluded from Godot import. It improves the identity,
silhouette, equipment and elemental read, but it is not a sprite atlas: its
1254-pixel grid is not evenly divisible into five cells, it has one view per
action rather than eight, and its body/effects still require deterministic
extraction, transparent cleanup, pivot alignment and runtime validation. The
current v2 atlas therefore remains the playable candidate.

Every roster entry therefore shows both the higher-detail character
candidate and the current eight-direction runtime sprite. The runtime image
is the one connected to the in-game atlas; the larger image is a visual
review candidate. Neither is accepted final art until the runtime sprite
matches or exceeds the baseline and passes the ordered visual-quality gate.

![Current runtime-addressable champion sprite roster](assets/sprites/champions/roster_overview_v1.png)

| Repository fact | Current meaning |
| --- | --- |
| Executable shared combat foundation | Arc Primary and Vector Lance exist, but they are not final per-champion kits |
| Preserved named kits | Oh Tipi, S. Wayne, The Red Baron, Steezo, Treevor the Mason, Oll' I and Fluup retain approved ability names; mechanics remain unimplemented |
| Remaining named champions | Identity, ancestry, elements, role and sprite package exist; character-specific ability names remain pending |
| Void terminology | The Red Baron and Grimm Bow still carry legacy Void design data while visual generation currently uses Dark; this must be reconciled explicitly |
| Angel slot | Body-plan and visual placeholder only; identity, lore and kit remain unapproved and non-selectable |

### Character roster index

| Sprite | Champion | Ancestry (race) | Size | Elements | Intended role | Kit state |
| --- | --- | --- | --- | --- | --- | --- |
| <img src="assets/sprites/champions_v2/oh_tipi/hero_portrait_256.png" alt="Oh Tipi high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/oh_tipi/oh_tipi_direction_preview.png" alt="Oh Tipi current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Oh Tipi** | Seakin | Medium | Water · Ice · Charge | Conductive-field skirmisher and current rider | Named design kit; not implemented |
| <img src="assets/sprites/champions_v2/s_wayne/hero_portrait_256.png" alt="S. Wayne high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/s_wayne/s_wayne_direction_preview.png" alt="S. Wayne current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **S. Wayne** | Hobbit | Small | Dark · Light | Eclipse-boundary tactician and decoy router | Named design kit; not implemented |
| <img src="assets/sprites/champions_v2/red_baron/hero_portrait_256.png" alt="The Red Baron high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/red_baron/red_baron_direction_preview.png" alt="The Red Baron current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **The Red Baron** | Undead | Medium | Void (legacy, unresolved) · Fire · Ice | Airborne formation controller with punishable landings | Named design kit; not implemented |
| <img src="assets/sprites/champions_v2/steezo/hero_portrait_256.png" alt="Steezo high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/steezo/steezo_direction_preview.png" alt="Steezo current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Steezo** | Goblin | Small | Fire · Charge · Light | Volatile construct engineer and detonation sequencer | Named design kit; not implemented |
| <img src="assets/sprites/champions_v2/treevor_mason/hero_portrait_256.png" alt="Treevor the Mason high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/treevor_mason/treevor_mason_direction_preview.png" alt="Treevor the Mason current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Treevor the Mason** | Treefolk | Large | Earth · Wind · Fire | Terrain mason creating routes, cover and fire liabilities | Named design kit; not implemented |
| <img src="assets/sprites/champions_v2/oll_i/hero_portrait_256.png" alt="Oll' I high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/oll_i/oll_i_direction_preview.png" alt="Oll' I current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Oll' I** | Werewolf | Large | Earth · Fire · Light | Forward structural breaker with high commitment | Named design kit; not implemented |
| <img src="assets/sprites/champions_v2/fluup/hero_portrait_256.png" alt="Fluup high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/fluup/fluup_direction_preview.png" alt="Fluup current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Fluup** | Orc | Large | Charge · Wind · Ice | Storm bruiser converting committed landings | Named design kit; not implemented |
| <img src="assets/sprites/champions_v2/wa_bidi/hero_portrait_256.png" alt="Wa Bidi high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/wa_bidi/wa_bidi_direction_preview.png" alt="Wa Bidi current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Wa Bidi** | Goblin | Small | Charge · Wind · Fire | Fast battlecry route specialist with visible and audible cues | Kit pending |
| <img src="assets/sprites/champions_v2/grace_reava/hero_portrait_256.png" alt="Grace Reava high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/grace_reava/grace_reava_direction_preview.png" alt="Grace Reava current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Grace Reava** | Sylph | Small | Wind · Water · Light | Luminous-current aerial duelist | Kit pending |
| <img src="assets/sprites/champions_v2/nico_lai/hero_portrait_256.png" alt="Nico Lai high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/nico_lai/nico_lai_direction_preview.png" alt="Nico Lai current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Nico Lai** | Gnome | Tiny | Charge · Light | Precision shared-device engineer | Kit pending |
| <img src="assets/sprites/champions_v2/spai_si/hero_portrait_256.png" alt="Spai Si high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/spai_si/spai_si_direction_preview.png" alt="Spai Si current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Spai Si** | Demon | Medium | Wind · Light · Earth | Redirect duelist converting hostile intent into angles | Kit pending |
| <img src="assets/sprites/champions_v2/leaf_hidden/hero_portrait_256.png" alt="Leaf the Hidden high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/leaf_hidden/leaf_hidden_direction_preview.png" alt="Leaf the Hidden current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Leaf the Hidden** | Treefolk | Medium | Water · Earth · Light | Concealed grove support and planned-route grower | Kit pending |
| <img src="assets/sprites/champions_v2/ha_rekt/hero_portrait_256.png" alt="Ha Rekt high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/ha_rekt/ha_rekt_direction_preview.png" alt="Ha Rekt current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Ha Rekt** | Wyrmborn | Large | Ice · Wind · Fire | Aerial cold-line hunter with marked escape routes | Kit pending |
| <img src="assets/sprites/champions_v2/dr_apex/hero_portrait_256.png" alt="Dr. Apex high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/dr_apex/dr_apex_direction_preview.png" alt="Dr. Apex current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Dr. Apex** | Stoneborn | Large | Earth · Light · Water | Armored combat medic with contestable support zones | Kit pending |
| <img src="assets/sprites/champions_v2/haara/hero_portrait_256.png" alt="Haara high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/haara/haara_direction_preview.png" alt="Haara current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Haara** | Nymph | Small | Light · Wind · Spirit | Bloom planner with flexible resource routing | Kit pending |
| <img src="assets/sprites/champions_v2/hesus_christo/hero_portrait_256.png" alt="Hesus Christo high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/hesus_christo/hesus_christo_direction_preview.png" alt="Hesus Christo current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Hesus Christo** | Elf | Medium | Earth · Water | Tall renewal vanguard rebuilding broken routes | Kit pending |
| <img src="assets/sprites/champions_v2/grimm_bow/hero_portrait_256.png" alt="Grimm Bow high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/grimm_bow/grimm_bow_direction_preview.png" alt="Grimm Bow current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Grimm Bow** | Troll | Huge | Void (legacy, unresolved) · Earth · Water | Terrain archer converting displacement into precision, never bonus damage | Kit pending |
| <img src="assets/sprites/champions_v2/biggy_bob/hero_portrait_256.png" alt="Biggy Bob high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/biggy_bob/biggy_bob_direction_preview.png" alt="Biggy Bob current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Biggy Bob** | Dwarf | Medium | Earth · Fire · Light | Forge-line breacher and masonry specialist | Kit pending |
| <img src="assets/sprites/champions_v2/jan_wicked/hero_portrait_256.png" alt="Jan Wicked high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/jan_wicked/jan_wicked_direction_preview.png" alt="Jan Wicked current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Jan Wicked** | Human | Medium | Ice · Dark · Charge | Black-ice circuit hunter | Kit pending |
| <img src="assets/sprites/champions_v2/ba_djoh/hero_portrait_256.png" alt="Ba Djoh high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/ba_djoh/ba_djoh_direction_preview.png" alt="Ba Djoh current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Ba Djoh** | Minotaur | Huge | Earth · Fire · Water | Three-current charge breaker | Kit pending |
| <img src="assets/sprites/champions_v2/urzh/hero_portrait_256.png" alt="Urzh high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/urzh/urzh_direction_preview.png" alt="Urzh current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Urzh** | Stoneborn | Large | Earth · Fire · Charge | Conductive kiln bulwark and lane anchor | Kit pending |
| <img src="assets/sprites/champions_v2/donnok/hero_portrait_256.png" alt="Donnok high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/donnok/donnok_direction_preview.png" alt="Donnok current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Donnok** | Dwarf | Medium | Earth · Fire · Water | Forge-rhythm terrain shaper | Kit pending |
| <img src="assets/sprites/champions_v2/djonah_thaan/hero_portrait_256.png" alt="Djonah Thaan high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/djonah_thaan/djonah_thaan_direction_preview.png" alt="Djonah Thaan current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Djonah Thaan** | Vampire | Medium | Dark · Charge · Fire | Grave-current pursuit controller | Kit pending |
| <img src="assets/sprites/champions_v2/unnamed_angel/hero_portrait_256.png" alt="Unnamed Angel high-detail character candidate" width="128"><br><sub>detail candidate</sub><br><img src="assets/sprites/champions/unnamed_angel/unnamed_angel_direction_preview.png" alt="Unnamed Angel current in-game directional sprite" width="192"><br><sub>current runtime sprite</sub> | **Unnamed Angel** | Angel | Medium | Wind · Light · Spirit | Visual and body-plan placeholder only | Unapproved placeholder |

### Detailed character cards

<details id="champion-oh_tipi">
<summary><strong>Oh Tipi</strong> — Seakin · Water · Ice · Charge</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/oh_tipi/hero_portrait_256.png" alt="Oh Tipi high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/oh_tipi/oh_tipi_direction_preview.png" alt="Oh Tipi current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Seakin** |
| Visual size class | **Medium** |
| Draft affinities | **Water · Ice · Charge** |
| Signature equipment | **Conduit** |
| Core gameplay identity | Conductive-field skirmisher and current rider |
| Identity and migration notes | Large head fins and a route-first silhouette distinguish water setup, freezing and current traversal. |
| Runtime atlas | [`assets/sprites/champions/oh_tipi/oh_tipi_atlas.png`](assets/sprites/champions/oh_tipi/oh_tipi_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/oh_tipi/oh_tipi_portrait.png`](assets/sprites/champions/oh_tipi/oh_tipi_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/oh_tipi/hero_portrait_256.png`](assets/sprites/champions_v2/oh_tipi/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/oh_tipi/keyframe_board.png`](assets/sprites/champions_v2/oh_tipi/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Exercised by the playable bootstrap as the first manifest-backed runtime candidate; not final accepted art and not proof that the remaining champions are integrated |

| Ability slot | Preserved design name | Implementation state |
| --- | --- | --- |
| Passive | **Living Current** | Named design input; simulation and balance not implemented |
| Champion primary | Not committed | Current Arc Primary is a shared foundation placeholder, not the final champion primary |
| Active I | **Tideline** | Named design input; simulation and balance not implemented |
| Active II | **Flash Freeze** | Named design input; simulation and balance not implemented |
| Mobility | **Eel Step** | Named design input; must obey global collision and speed limits |
| Ultimate | **Stormtide Basin** | Named design input; charge, startup, interruption and recovery rules pending |

</details>

<details id="champion-s_wayne">
<summary><strong>S. Wayne</strong> — Hobbit · Dark · Light</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/s_wayne/hero_portrait_256.png" alt="S. Wayne high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/s_wayne/s_wayne_direction_preview.png" alt="S. Wayne current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Hobbit** |
| Visual size class | **Small** |
| Draft affinities | **Dark · Light** |
| Signature equipment | **Eclipse disc** |
| Core gameplay identity | Eclipse-boundary tactician and decoy router |
| Identity and migration notes | The preserved kit names were authored under the legacy name Samwise DeWayne and require identity/affinity reconciliation before promotion. |
| Runtime atlas | [`assets/sprites/champions/s_wayne/s_wayne_atlas.png`](assets/sprites/champions/s_wayne/s_wayne_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/s_wayne/s_wayne_portrait.png`](assets/sprites/champions/s_wayne/s_wayne_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/s_wayne/hero_portrait_256.png`](assets/sprites/champions_v2/s_wayne/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/s_wayne/keyframe_board.png`](assets/sprites/champions_v2/s_wayne/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Preserved design name | Implementation state |
| --- | --- | --- |
| Passive | **Small Target, Big Exit** | Named design input; simulation and balance not implemented |
| Champion primary | Not committed | Current Arc Primary is a shared foundation placeholder, not the final champion primary |
| Active I | **Pocket Tempest** | Named design input; simulation and balance not implemented |
| Active II | **Burrowed Shadow** | Named design input; simulation and balance not implemented |
| Mobility | **Campfire Feint** | Named design input; must obey global collision and speed limits |
| Ultimate | **There and Back Again** | Named design input; charge, startup, interruption and recovery rules pending |

</details>

<details id="champion-red_baron">
<summary><strong>The Red Baron</strong> — Undead · Void (legacy, unresolved) · Fire · Ice</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/red_baron/hero_portrait_256.png" alt="The Red Baron high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/red_baron/red_baron_direction_preview.png" alt="The Red Baron current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Undead** |
| Visual size class | **Medium** |
| Draft affinities | **Void (legacy, unresolved) · Fire · Ice** |
| Signature equipment | **Sabre** |
| Core gameplay identity | Airborne formation controller with punishable landings |
| Identity and migration notes | The visual catalog currently tags Dark, while the design roster still says Void. Selection remains blocked until that mapping is approved. |
| Runtime atlas | [`assets/sprites/champions/red_baron/red_baron_atlas.png`](assets/sprites/champions/red_baron/red_baron_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/red_baron/red_baron_portrait.png`](assets/sprites/champions/red_baron/red_baron_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/red_baron/hero_portrait_256.png`](assets/sprites/champions_v2/red_baron/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/red_baron/keyframe_board.png`](assets/sprites/champions_v2/red_baron/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Preserved design name | Implementation state |
| --- | --- | --- |
| Passive | **Cold Ashes** | Named design input; simulation and balance not implemented |
| Champion primary | Not committed | Current Arc Primary is a shared foundation placeholder, not the final champion primary |
| Active I | **Crimson Comet** | Named design input; simulation and balance not implemented |
| Active II | **Night Flak** | Named design input; simulation and balance not implemented |
| Mobility | **Rime Wing** | Named design input; must obey global collision and speed limits |
| Ultimate | **The Dead Sky** | Named design input; charge, startup, interruption and recovery rules pending |

</details>

<details id="champion-steezo">
<summary><strong>Steezo</strong> — Goblin · Fire · Charge · Light</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/steezo/hero_portrait_256.png" alt="Steezo high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/steezo/steezo_direction_preview.png" alt="Steezo current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Goblin** |
| Visual size class | **Small** |
| Draft affinities | **Fire · Charge · Light** |
| Signature equipment | **Detonator** |
| Core gameplay identity | Volatile construct engineer and detonation sequencer |
| Identity and migration notes | Red skin, tool-led silhouette and readable devices are identity requirements rather than optional cosmetics. |
| Runtime atlas | [`assets/sprites/champions/steezo/steezo_atlas.png`](assets/sprites/champions/steezo/steezo_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/steezo/steezo_portrait.png`](assets/sprites/champions/steezo/steezo_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/steezo/hero_portrait_256.png`](assets/sprites/champions_v2/steezo/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/steezo/keyframe_board.png`](assets/sprites/champions_v2/steezo/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Preserved design name | Implementation state |
| --- | --- | --- |
| Passive | **Questionable Engineering** | Named design input; simulation and balance not implemented |
| Champion primary | Not committed | Current Arc Primary is a shared foundation placeholder, not the final champion primary |
| Active I | **Spark Keg** | Named design input; simulation and balance not implemented |
| Active II | **Prism Tripwire** | Named design input; simulation and balance not implemented |
| Mobility | **Coil Hopper** | Named design input; must obey global collision and speed limits |
| Ultimate | **Perfectly Safe Machine** | Named design input; charge, startup, interruption and recovery rules pending |

</details>

<details id="champion-treevor_mason">
<summary><strong>Treevor the Mason</strong> — Treefolk · Earth · Wind · Fire</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/treevor_mason/hero_portrait_256.png" alt="Treevor the Mason high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/treevor_mason/treevor_mason_direction_preview.png" alt="Treevor the Mason current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Treefolk** |
| Visual size class | **Large** |
| Draft affinities | **Earth · Wind · Fire** |
| Signature equipment | **Mason hammer** |
| Core gameplay identity | Terrain mason creating routes, cover and fire liabilities |
| Identity and migration notes | Canopy, roots and masonry equipment must remain readable independently of elemental effects. |
| Runtime atlas | [`assets/sprites/champions/treevor_mason/treevor_mason_atlas.png`](assets/sprites/champions/treevor_mason/treevor_mason_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/treevor_mason/treevor_mason_portrait.png`](assets/sprites/champions/treevor_mason/treevor_mason_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/treevor_mason/hero_portrait_256.png`](assets/sprites/champions_v2/treevor_mason/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/treevor_mason/keyframe_board.png`](assets/sprites/champions_v2/treevor_mason/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Preserved design name | Implementation state |
| --- | --- | --- |
| Passive | **Deep Roots** | Named design input; simulation and balance not implemented |
| Champion primary | Not committed | Current Arc Primary is a shared foundation placeholder, not the final champion primary |
| Active I | **Root Rampart** | Named design input; simulation and balance not implemented |
| Active II | **Branch Gale** | Named design input; simulation and balance not implemented |
| Mobility | **Ember Seed** | Named design input; must obey global collision and speed limits |
| Ultimate | **Crown of the Wildfire** | Named design input; charge, startup, interruption and recovery rules pending |

</details>

<details id="champion-oll_i">
<summary><strong>Oll' I</strong> — Werewolf · Earth · Fire · Light</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/oll_i/hero_portrait_256.png" alt="Oll' I high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/oll_i/oll_i_direction_preview.png" alt="Oll' I current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Werewolf** |
| Visual size class | **Large** |
| Draft affinities | **Earth · Fire · Light** |
| Signature equipment | **Impact gauntlets** |
| Core gameplay identity | Forward structural breaker with high commitment |
| Identity and migration notes | Current Flux2 ancestry is Werewolf; older Minotaur imagery is migration reference, not current repository truth. |
| Runtime atlas | [`assets/sprites/champions/oll_i/oll_i_atlas.png`](assets/sprites/champions/oll_i/oll_i_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/oll_i/oll_i_portrait.png`](assets/sprites/champions/oll_i/oll_i_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/oll_i/hero_portrait_256.png`](assets/sprites/champions_v2/oll_i/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/oll_i/keyframe_board.png`](assets/sprites/champions_v2/oll_i/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Preserved design name | Implementation state |
| --- | --- | --- |
| Passive | **Labyrinth Momentum** | Named design input; simulation and balance not implemented |
| Champion primary | Not committed | Current Arc Primary is a shared foundation placeholder, not the final champion primary |
| Active I | **Sunhorn Charge** | Named design input; simulation and balance not implemented |
| Active II | **Furnace Stomp** | Named design input; simulation and balance not implemented |
| Mobility | **Mirror Bulwark** | Named design input; must obey global collision and speed limits |
| Ultimate | **The Burning Maze** | Named design input; charge, startup, interruption and recovery rules pending |

</details>

<details id="champion-fluup">
<summary><strong>Fluup</strong> — Orc · Charge · Wind · Ice</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/fluup/hero_portrait_256.png" alt="Fluup high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/fluup/fluup_direction_preview.png" alt="Fluup current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Orc** |
| Visual size class | **Large** |
| Draft affinities | **Charge · Wind · Ice** |
| Signature equipment | **Storm maul** |
| Core gameplay identity | Storm bruiser converting committed landings |
| Identity and migration notes | Heavy action timing and storm effects must preserve the underlying Orc silhouette and recovery read. |
| Runtime atlas | [`assets/sprites/champions/fluup/fluup_atlas.png`](assets/sprites/champions/fluup/fluup_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/fluup/fluup_portrait.png`](assets/sprites/champions/fluup/fluup_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/fluup/hero_portrait_256.png`](assets/sprites/champions_v2/fluup/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/fluup/keyframe_board.png`](assets/sprites/champions_v2/fluup/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Preserved design name | Implementation state |
| --- | --- | --- |
| Passive | **Stormweight** | Named design input; simulation and balance not implemented |
| Champion primary | Not committed | Current Arc Primary is a shared foundation placeholder, not the final champion primary |
| Active I | **Thunder Shove** | Named design input; simulation and balance not implemented |
| Active II | **Squall Leap** | Named design input; simulation and balance not implemented |
| Mobility | **Rime Crash** | Named design input; must obey global collision and speed limits |
| Ultimate | **Bad Weather** | Named design input; charge, startup, interruption and recovery rules pending |

</details>

<details id="champion-wa_bidi">
<summary><strong>Wa Bidi</strong> — Goblin · Charge · Wind · Fire</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/wa_bidi/hero_portrait_256.png" alt="Wa Bidi high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/wa_bidi/wa_bidi_direction_preview.png" alt="Wa Bidi current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Goblin** |
| Visual size class | **Small** |
| Draft affinities | **Charge · Wind · Fire** |
| Signature equipment | **Battle horn** |
| Core gameplay identity | Fast battlecry route specialist with visible and audible cues |
| Identity and migration notes | No approved character-specific ability names are committed yet. |
| Runtime atlas | [`assets/sprites/champions/wa_bidi/wa_bidi_atlas.png`](assets/sprites/champions/wa_bidi/wa_bidi_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/wa_bidi/wa_bidi_portrait.png`](assets/sprites/champions/wa_bidi/wa_bidi_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/wa_bidi/hero_portrait_256.png`](assets/sprites/champions_v2/wa_bidi/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/wa_bidi/keyframe_board.png`](assets/sprites/champions_v2/wa_bidi/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-grace_reava">
<summary><strong>Grace Reava</strong> — Sylph · Wind · Water · Light</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/grace_reava/hero_portrait_256.png" alt="Grace Reava high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/grace_reava/grace_reava_direction_preview.png" alt="Grace Reava current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Sylph** |
| Visual size class | **Small** |
| Draft affinities | **Wind · Water · Light** |
| Signature equipment | **Rapier** |
| Core gameplay identity | Luminous-current aerial duelist |
| Identity and migration notes | No approved character-specific ability names are committed yet. |
| Runtime atlas | [`assets/sprites/champions/grace_reava/grace_reava_atlas.png`](assets/sprites/champions/grace_reava/grace_reava_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/grace_reava/grace_reava_portrait.png`](assets/sprites/champions/grace_reava/grace_reava_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/grace_reava/hero_portrait_256.png`](assets/sprites/champions_v2/grace_reava/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/grace_reava/keyframe_board.png`](assets/sprites/champions_v2/grace_reava/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-nico_lai">
<summary><strong>Nico Lai</strong> — Gnome · Charge · Light</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/nico_lai/hero_portrait_256.png" alt="Nico Lai high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/nico_lai/nico_lai_direction_preview.png" alt="Nico Lai current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Gnome** |
| Visual size class | **Tiny** |
| Draft affinities | **Charge · Light** |
| Signature equipment | **Charge gauntlet** |
| Core gameplay identity | Precision shared-device engineer |
| Identity and migration notes | Bald crown, strong swept side-hair silhouette and oversized engineering equipment are required identity anchors. |
| Runtime atlas | [`assets/sprites/champions/nico_lai/nico_lai_atlas.png`](assets/sprites/champions/nico_lai/nico_lai_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/nico_lai/nico_lai_portrait.png`](assets/sprites/champions/nico_lai/nico_lai_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/nico_lai/hero_portrait_256.png`](assets/sprites/champions_v2/nico_lai/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/nico_lai/keyframe_board.png`](assets/sprites/champions_v2/nico_lai/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-spai_si">
<summary><strong>Spai Si</strong> — Demon · Wind · Light · Earth</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/spai_si/hero_portrait_256.png" alt="Spai Si high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/spai_si/spai_si_direction_preview.png" alt="Spai Si current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Demon** |
| Visual size class | **Medium** |
| Draft affinities | **Wind · Light · Earth** |
| Signature equipment | **Redirect blade** |
| Core gameplay identity | Redirect duelist converting hostile intent into angles |
| Identity and migration notes | Current design is male with short dark hair; no approved character-specific ability names are committed yet. |
| Runtime atlas | [`assets/sprites/champions/spai_si/spai_si_atlas.png`](assets/sprites/champions/spai_si/spai_si_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/spai_si/spai_si_portrait.png`](assets/sprites/champions/spai_si/spai_si_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/spai_si/hero_portrait_256.png`](assets/sprites/champions_v2/spai_si/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/spai_si/keyframe_board.png`](assets/sprites/champions_v2/spai_si/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-leaf_hidden">
<summary><strong>Leaf the Hidden</strong> — Treefolk · Water · Earth · Light</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/leaf_hidden/hero_portrait_256.png" alt="Leaf the Hidden high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/leaf_hidden/leaf_hidden_direction_preview.png" alt="Leaf the Hidden current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Treefolk** |
| Visual size class | **Medium** |
| Draft affinities | **Water · Earth · Light** |
| Signature equipment | **Grove staff** |
| Core gameplay identity | Concealed grove support and planned-route grower |
| Identity and migration notes | Legacy art may label this design Hidin Leef; Flux2 uses Leaf the Hidden. |
| Runtime atlas | [`assets/sprites/champions/leaf_hidden/leaf_hidden_atlas.png`](assets/sprites/champions/leaf_hidden/leaf_hidden_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/leaf_hidden/leaf_hidden_portrait.png`](assets/sprites/champions/leaf_hidden/leaf_hidden_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/leaf_hidden/hero_portrait_256.png`](assets/sprites/champions_v2/leaf_hidden/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/leaf_hidden/keyframe_board.png`](assets/sprites/champions_v2/leaf_hidden/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-ha_rekt">
<summary><strong>Ha Rekt</strong> — Wyrmborn · Ice · Wind · Fire</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/ha_rekt/hero_portrait_256.png" alt="Ha Rekt high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/ha_rekt/ha_rekt_direction_preview.png" alt="Ha Rekt current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Wyrmborn** |
| Visual size class | **Large** |
| Draft affinities | **Ice · Wind · Fire** |
| Signature equipment | **Cold lance** |
| Core gameplay identity | Aerial cold-line hunter with marked escape routes |
| Identity and migration notes | Wyrmborn is an anthropomorphic scaled body plan, not a conventional quadrupedal wyrm. |
| Runtime atlas | [`assets/sprites/champions/ha_rekt/ha_rekt_atlas.png`](assets/sprites/champions/ha_rekt/ha_rekt_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/ha_rekt/ha_rekt_portrait.png`](assets/sprites/champions/ha_rekt/ha_rekt_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/ha_rekt/hero_portrait_256.png`](assets/sprites/champions_v2/ha_rekt/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/ha_rekt/keyframe_board.png`](assets/sprites/champions_v2/ha_rekt/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-dr_apex">
<summary><strong>Dr. Apex</strong> — Stoneborn · Earth · Light · Water</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/dr_apex/hero_portrait_256.png" alt="Dr. Apex high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/dr_apex/dr_apex_direction_preview.png" alt="Dr. Apex current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Stoneborn** |
| Visual size class | **Large** |
| Draft affinities | **Earth · Light · Water** |
| Signature equipment | **Medic prism** |
| Core gameplay identity | Armored combat medic with contestable support zones |
| Identity and migration notes | No approved character-specific ability names are committed yet. |
| Runtime atlas | [`assets/sprites/champions/dr_apex/dr_apex_atlas.png`](assets/sprites/champions/dr_apex/dr_apex_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/dr_apex/dr_apex_portrait.png`](assets/sprites/champions/dr_apex/dr_apex_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/dr_apex/hero_portrait_256.png`](assets/sprites/champions_v2/dr_apex/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/dr_apex/keyframe_board.png`](assets/sprites/champions_v2/dr_apex/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-haara">
<summary><strong>Haara</strong> — Nymph · Light · Wind · Spirit</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/haara/hero_portrait_256.png" alt="Haara high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/haara/haara_direction_preview.png" alt="Haara current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Nymph** |
| Visual size class | **Small** |
| Draft affinities | **Light · Wind · Spirit** |
| Signature equipment | **Bloom orb** |
| Core gameplay identity | Bloom planner with flexible resource routing |
| Identity and migration notes | Short dark hair is the current identity direction. Spirit remains runtime gated. |
| Runtime atlas | [`assets/sprites/champions/haara/haara_atlas.png`](assets/sprites/champions/haara/haara_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/haara/haara_portrait.png`](assets/sprites/champions/haara/haara_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/haara/hero_portrait_256.png`](assets/sprites/champions_v2/haara/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/haara/keyframe_board.png`](assets/sprites/champions_v2/haara/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-hesus_christo">
<summary><strong>Hesus Christo</strong> — Elf · Earth · Water</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/hesus_christo/hero_portrait_256.png" alt="Hesus Christo high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/hesus_christo/hesus_christo_direction_preview.png" alt="Hesus Christo current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Elf** |
| Visual size class | **Medium** |
| Draft affinities | **Earth · Water** |
| Signature equipment | **Renewal staff** |
| Core gameplay identity | Tall renewal vanguard rebuilding broken routes |
| Identity and migration notes | No approved character-specific ability names are committed yet. |
| Runtime atlas | [`assets/sprites/champions/hesus_christo/hesus_christo_atlas.png`](assets/sprites/champions/hesus_christo/hesus_christo_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/hesus_christo/hesus_christo_portrait.png`](assets/sprites/champions/hesus_christo/hesus_christo_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/hesus_christo/hero_portrait_256.png`](assets/sprites/champions_v2/hesus_christo/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/hesus_christo/keyframe_board.png`](assets/sprites/champions_v2/hesus_christo/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-grimm_bow">
<summary><strong>Grimm Bow</strong> — Troll · Void (legacy, unresolved) · Earth · Water</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/grimm_bow/hero_portrait_256.png" alt="Grimm Bow high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/grimm_bow/grimm_bow_direction_preview.png" alt="Grimm Bow current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Troll** |
| Visual size class | **Huge** |
| Draft affinities | **Void (legacy, unresolved) · Earth · Water** |
| Signature equipment | **Greatbow** |
| Core gameplay identity | Terrain archer converting displacement into precision, never bonus damage |
| Identity and migration notes | The visual catalog currently tags Dark, while the design roster still says Void. Selection remains blocked until that mapping is approved. |
| Runtime atlas | [`assets/sprites/champions/grimm_bow/grimm_bow_atlas.png`](assets/sprites/champions/grimm_bow/grimm_bow_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/grimm_bow/grimm_bow_portrait.png`](assets/sprites/champions/grimm_bow/grimm_bow_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/grimm_bow/hero_portrait_256.png`](assets/sprites/champions_v2/grimm_bow/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/grimm_bow/keyframe_board.png`](assets/sprites/champions_v2/grimm_bow/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-biggy_bob">
<summary><strong>Biggy Bob</strong> — Dwarf · Earth · Fire · Light</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/biggy_bob/hero_portrait_256.png" alt="Biggy Bob high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/biggy_bob/biggy_bob_direction_preview.png" alt="Biggy Bob current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Dwarf** |
| Visual size class | **Medium** |
| Draft affinities | **Earth · Fire · Light** |
| Signature equipment | **Breach hammer** |
| Core gameplay identity | Forge-line breacher and masonry specialist |
| Identity and migration notes | No approved character-specific ability names are committed yet. |
| Runtime atlas | [`assets/sprites/champions/biggy_bob/biggy_bob_atlas.png`](assets/sprites/champions/biggy_bob/biggy_bob_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/biggy_bob/biggy_bob_portrait.png`](assets/sprites/champions/biggy_bob/biggy_bob_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/biggy_bob/hero_portrait_256.png`](assets/sprites/champions_v2/biggy_bob/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/biggy_bob/keyframe_board.png`](assets/sprites/champions_v2/biggy_bob/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-jan_wicked">
<summary><strong>Jan Wicked</strong> — Human · Ice · Dark · Charge</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/jan_wicked/hero_portrait_256.png" alt="Jan Wicked high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/jan_wicked/jan_wicked_direction_preview.png" alt="Jan Wicked current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Human** |
| Visual size class | **Medium** |
| Draft affinities | **Ice · Dark · Charge** |
| Signature equipment | **Ice blade** |
| Core gameplay identity | Black-ice circuit hunter |
| Identity and migration notes | No approved character-specific ability names are committed yet. |
| Runtime atlas | [`assets/sprites/champions/jan_wicked/jan_wicked_atlas.png`](assets/sprites/champions/jan_wicked/jan_wicked_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/jan_wicked/jan_wicked_portrait.png`](assets/sprites/champions/jan_wicked/jan_wicked_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/jan_wicked/hero_portrait_256.png`](assets/sprites/champions_v2/jan_wicked/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/jan_wicked/keyframe_board.png`](assets/sprites/champions_v2/jan_wicked/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-ba_djoh">
<summary><strong>Ba Djoh</strong> — Minotaur · Earth · Fire · Water</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/ba_djoh/hero_portrait_256.png" alt="Ba Djoh high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/ba_djoh/ba_djoh_direction_preview.png" alt="Ba Djoh current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Minotaur** |
| Visual size class | **Huge** |
| Draft affinities | **Earth · Fire · Water** |
| Signature equipment | **Breaker** |
| Core gameplay identity | Three-current charge breaker |
| Identity and migration notes | No approved character-specific ability names are committed yet. |
| Runtime atlas | [`assets/sprites/champions/ba_djoh/ba_djoh_atlas.png`](assets/sprites/champions/ba_djoh/ba_djoh_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/ba_djoh/ba_djoh_portrait.png`](assets/sprites/champions/ba_djoh/ba_djoh_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/ba_djoh/hero_portrait_256.png`](assets/sprites/champions_v2/ba_djoh/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/ba_djoh/keyframe_board.png`](assets/sprites/champions_v2/ba_djoh/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-urzh">
<summary><strong>Urzh</strong> — Stoneborn · Earth · Fire · Charge</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/urzh/hero_portrait_256.png" alt="Urzh high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/urzh/urzh_direction_preview.png" alt="Urzh current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Stoneborn** |
| Visual size class | **Large** |
| Draft affinities | **Earth · Fire · Charge** |
| Signature equipment | **Kiln shield** |
| Core gameplay identity | Conductive kiln bulwark and lane anchor |
| Identity and migration notes | No approved character-specific ability names are committed yet. |
| Runtime atlas | [`assets/sprites/champions/urzh/urzh_atlas.png`](assets/sprites/champions/urzh/urzh_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/urzh/urzh_portrait.png`](assets/sprites/champions/urzh/urzh_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/urzh/hero_portrait_256.png`](assets/sprites/champions_v2/urzh/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/urzh/keyframe_board.png`](assets/sprites/champions_v2/urzh/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-donnok">
<summary><strong>Donnok</strong> — Dwarf · Earth · Fire · Water</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/donnok/hero_portrait_256.png" alt="Donnok high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/donnok/donnok_direction_preview.png" alt="Donnok current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Dwarf** |
| Visual size class | **Medium** |
| Draft affinities | **Earth · Fire · Water** |
| Signature equipment | **Terrain hammer** |
| Core gameplay identity | Forge-rhythm terrain shaper |
| Identity and migration notes | No approved character-specific ability names are committed yet. |
| Runtime atlas | [`assets/sprites/champions/donnok/donnok_atlas.png`](assets/sprites/champions/donnok/donnok_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/donnok/donnok_portrait.png`](assets/sprites/champions/donnok/donnok_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/donnok/hero_portrait_256.png`](assets/sprites/champions_v2/donnok/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/donnok/keyframe_board.png`](assets/sprites/champions_v2/donnok/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-djonah_thaan">
<summary><strong>Djonah Thaan</strong> — Vampire · Dark · Charge · Fire</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/djonah_thaan/hero_portrait_256.png" alt="Djonah Thaan high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/djonah_thaan/djonah_thaan_direction_preview.png" alt="Djonah Thaan current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Vampire** |
| Visual size class | **Medium** |
| Draft affinities | **Dark · Charge · Fire** |
| Signature equipment | **Grave coil** |
| Core gameplay identity | Grave-current pursuit controller |
| Identity and migration notes | No approved character-specific ability names are committed yet. |
| Runtime atlas | [`assets/sprites/champions/djonah_thaan/djonah_thaan_atlas.png`](assets/sprites/champions/djonah_thaan/djonah_thaan_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/djonah_thaan/djonah_thaan_portrait.png`](assets/sprites/champions/djonah_thaan/djonah_thaan_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/djonah_thaan/hero_portrait_256.png`](assets/sprites/champions_v2/djonah_thaan/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/djonah_thaan/keyframe_board.png`](assets/sprites/champions_v2/djonah_thaan/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive | Pending champion promotion; no approved name or mechanic is committed |
| Champion primary | Pending; Arc Primary remains the shared executable foundation |
| Active I / Active II | Pending; intended role is recorded above, but a kit is not invented by this README |
| Mobility | Pending; must use the universal collision, Stamina/Flux and speed-ceiling contracts |
| Ultimate | Pending; requires charge, startup, counterplay, interruption, expiry and recovery definitions |

</details>

<details id="champion-unnamed_angel">
<summary><strong>Unnamed Angel</strong> — Angel · Wind · Light · Spirit</summary>

<table>
<tr>
<td align="center"><img src="assets/sprites/champions_v2/unnamed_angel/hero_portrait_256.png" alt="Unnamed Angel high-detail character candidate" width="256"></td>
<td align="center"><img src="assets/sprites/champions/unnamed_angel/unnamed_angel_direction_preview.png" alt="Unnamed Angel current eight-direction in-game sprite" width="512"></td>
</tr>
<tr>
<td align="center"><strong>Character-detail candidate</strong><br>expression, materials, equipment and elemental identity</td>
<td align="center"><strong>Current runtime sprite</strong><br>eight directions linked to the in-game atlas</td>
</tr>
</table>

| Field | Repository state |
| --- | --- |
| Ancestry / legacy race | **Angel** |
| Visual size class | **Medium** |
| Draft affinities | **Wind · Light · Spirit** |
| Signature equipment | **Placeholder orb** |
| Core gameplay identity | Visual and body-plan placeholder only |
| Identity and migration notes | Identity, lore, kit and selection status are unapproved. This slot must not become playable merely to fill the roster. |
| Runtime atlas | [`assets/sprites/champions/unnamed_angel/unnamed_angel_atlas.png`](assets/sprites/champions/unnamed_angel/unnamed_angel_atlas.png) |
| Runtime portrait candidate | [`assets/sprites/champions/unnamed_angel/unnamed_angel_portrait.png`](assets/sprites/champions/unnamed_angel/unnamed_angel_portrait.png) |
| High-detail portrait candidate | [`assets/sprites/champions_v2/unnamed_angel/hero_portrait_256.png`](assets/sprites/champions_v2/unnamed_angel/hero_portrait_256.png) |
| Animation/keyframe board | [`assets/sprites/champions_v2/unnamed_angel/keyframe_board.png`](assets/sprites/champions_v2/unnamed_angel/keyframe_board.png) |
| Visual acceptance target | Must match or exceed [`assets/concept/flux-champions-visual-style-v1.png`](assets/concept/flux-champions-visual-style-v1.png) in expression, silhouette, material detail and charm |
| Sprite status | Runtime-addressable integrated candidate; not final accepted art and not proof of playability |

| Ability slot | Status |
| --- | --- |
| Passive, primary, actives, mobility and ultimate | **Unapproved placeholder.** No names or mechanics may be inferred from the temporary artwork. |

</details>

New arachnoid champions occupy expansion slots only after the body plans,
names, lore, silhouettes, skeletons, movement clearance, trait budgets and
one complete kit are reviewed. No placeholder becomes selectable merely to
fill a roster column.

<!-- END CHARACTER_ROSTER_V1 -->

### Champion promotion pipeline

One champion is promoted at a time through stable definition/wire IDs, ancestry
budget, six displayed statistics, legal loadout, passive/primary/actives/
mobility/ultimate, training dummy, bot behavior, local replay, network authority,
reconnect, spectator view, accessibility cues, Linux/Windows source launch,
package smoke, a unique interruptible semantic taunt, and visual/audio
acceptance. Character-specific mechanics may
extend validated systems but may not introduce a private physics engine,
material simulation, status language, or network rule.

## Maps and world interactions

A FLUX 2 map is a versioned package, not one monolithic scene. It contains
immutable topology, elevation/traversal bands, mutable material seeds, collision
and navigation sources, spawns, objectives, devices, portals, interaction
anchors, reset groups, active-simulation regions, presentation layers, and
canonical hashes.

| Map layer | Responsibilities |
| --- | --- |
| Topology/worldbone | Bounds, minimum routes, spawn/objective safety, portal foundations, critical supports |
| Elevation | Ground height, low cover, ledges, overpasses, bridges, undercrofts, projectile/vision bands |
| Structural shell | Typed destructible walls, floors, roofs, supports, doors, glass, vegetation, devices |
| Material seed | Solids, loose matter, liquids, gases, coatings, temperature, wetness, charge, residues |
| Traversal graph | Ordinary paths, advanced chains, accessibility alternatives, bot costs, interaction anchors |
| Objective graph | Capture/escort/extract/defend/deliver/spawn relationships independent of decoration |
| Reset and budget regions | Deterministic restoration, awake-cell/entity limits, cleanup and mode overrides |
| Presentation | Original tiles, props, parallax/elevation read, audio zones, landmarks, weather, non-authoritative effects |

World interactions include doors and switches; destructible circuits; pumps,
sluices, turbines, furnaces, capacitors, prisms, mirrors, lifts, cranes, bells,
traps, bridges, and portals; harvestable or reactive vegetation; movable cover;
neutral creatures; hazards; and mode objectives. Devices expose typed ports for
pressure, flow, heat, Charge, Light, physical impact, ownership, and reset, so a
map can compose systems rather than add bespoke scene scripts.

Arena layouts must support readable lanes without becoming static corridors.
Elevation creates over/under routes and projectile bands; destruction opens
temporary angles; fluids and gases cross boundaries only through authored
permeability; and objectives force players to choose between controlling the
current arena state and preparing the next rotation. Dense art frames playable
space but never hides collision, danger, ownership, or the minimum safe route.

## Modes, networking, and progression

Modes are versioned rulesets over the same authoritative simulation. A mode
selects player/team limits, maps, actors, spawn/defeat rules, objectives,
scoring, round flow, legal catalogs, material budgets, persistence, late join,
spectating, bot fill, and network requirements. It does not fork movement,
combat, chemistry, or champion implementations.

Hosted Sanctum presence, joining, and lobby administration are application
infrastructure and therefore precede these gameplay modes. PvP, PvE, PvPvE,
roguelike, stronghold, battle-royale, and custom mode claims begin only after
Living Wellspring V1 passes its full foundation and two-platform acceptance matrix.

| Family | Planned first expression | Production gate |
| --- | --- | --- |
| Training / freeplay | Sanctum practice, field guide, configurable dummy/bot, chemistry reset, movement time trials | Fully offline, instant reset, instrumentation, accessibility paths |
| First Rite / campaign onboarding | Short authored sequence teaching movement, aim, one reaction, one objective, return to Sanctum | Skippable/replayable, no hidden permanent power, save migration |
| PvP duel | 1v1 stock/round and timed variants on one compact arena | Spawn fairness, rematch, replay, bots, latency/loss, deterministic results |
| Team PvP | 2v2–4v4 skirmish, control, delivery, territory, draft/mirror variants | Team readability, objective telemetry, role diversity, no dominant composition |
| Cooperative PvE | Survival and siege with enemy families, elites, bosses, hazards, difficulty and revive rules | Deterministic AI, save stability, scalable encounter budgets, drop-in/out policy |
| PvPvE expedition | Teams contest neutral threats, material-rich objectives, bounded loot, extraction or convergence | Ownership, late join, anti-snowball rewards, reconnect, spectator information rules |
| Roguelike dungeons | Seeded rooms/biomes, branching routes, run-scoped formulas/items, bosses, return to Sanctum | Reproducible seeds, run-save recovery, no run power leaking into competitive stats |
| Lane / stronghold | Teams escort generated forces, contest reactors and destroy authored outer structures around immutable cores | AI/nav budgets, objective clarity, match length, comeback rules, no copied MOBA topology |
| Battle royale | Small measured survival slice with closing pressure and reactive sectors before any 32+ claim | Large-map streaming, spawn/loot fairness, authority, recovery, bandwidth, readability and hardware profiling |
| Custom / laboratory | Host-approved rules, maps, formulas, bots, mutators, replay sharing | Versioned manifests, safe limits, explicit incompatibility, no arbitrary client authority |

Native multiplayer begins with loopback and ENet host/join. Input prediction,
reconciliation, interpolation, rate limits, diagnostics, disconnect/reconnect,
join-in-progress, spectators, and forced host-loss tests precede browser WebRTC,
self-hostable signalling/relay, or large-player claims. Offline solo, local
multiplayer, bots, replays, editors, and documentation never require an account
or subscription.

Persistent progression records tutorials, mastery, records, cosmetics, presets,
discoveries, codex entries, and attuned destinations. Competitive effectiveness
comes from the selected legal build and player execution, not accumulated
account power. PvE/roguelike run upgrades are mode-scoped and reset or convert
to non-competitive rewards at the declared boundary.

## Visual and audio identity

FLUX 2 uses richly authored top-down pixel art with warm masonry, dark timber,
aged brass, lush vegetation, deep water, and localized cyan/violet magic. Dense
detail frames clear gameplay lanes; immutable structure is dark and heavy,
interactive systems glow and move, and hazardous chemistry uses distinct shapes
and timing. UI is compact dark-brass instrument work with parchment text fields,
not a wall of opaque fantasy panels. Audio reinforces material, distance,
movement cadence, threat, and successful reactions.

The production grid targets the compact readability of Game Boy Color-era
top-down adventure art, including the broad tile economy and silhouette clarity
associated with *Oracle of Ages* and *Oracle of Seasons*. This is direction,
not a source library: FLUX uses original pixels, ramps, proportions, maps,
characters, props, symbols, animation and interface language. Historical
generated character boards from earlier repository history may inform body-scale
and silhouette discussion, but their own manifest labels them concept/reference
only. They do not become accepted sprite sheets unless restored with provenance,
hashes, a virtual-pixel/frame/pivot manifest and an explicit visual acceptance
record.

The user-passed
[eighteen-champion board](assets/concept/flux-champions-visual-style-v1.png)
is now the mandatory local minimum for champion silhouette, expression,
materials, equipment, ancestry shape language, and elemental personality
(SHA-256
`cb8aa1b3f4e1c41498a35dd37303a3783b0f8fa2c0bbb0b75a89cbd02934732f`).
Its labels do not override canonical roster data, and the board itself is not a
sprite sheet. Every pictured champion still requires an original, aligned
in-game sprite set covering all applicable required animations. Existing
eight-direction runtime candidates and the 25-action skeleton manifest are
production foundations, not proof that those animations are final.

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
game: an in-progress scrolling G2 Sanctum campus over a deterministic movement
arena, separate Health/Stamina/Flux state, independent quantized aim,
persisted keyboard bindings, world/aim-relative movement presets, full/ranged-
cone POV, keyboard/mouse/controller defaults, custom ordered collision, resource-free Arc
Primary, Flux-paid Vector Lance, authoritative projectiles/damage, Edgeweave,
60/120 Hz match startup, stable state hashes, replay recording, and headless
verification. It proves the runtime boundary and migrates the first movement and
combat contracts from the browser FLUX prototype. A canonical ability catalog
and legal 13-point loadout validate at boot. A canonical material registry and
packed 128 x 128 Sanctum Material Yard seed also validate, hash, reset, and
render as a read-only debug preview; reactions do not step yet. The full hub art,
champion kit, networking, active chemistry, animation, and release exports
remain staged milestones. The G2 campus now has renderer-independent connected
district topology, explicit worldbone collision, queryable elevation, ordinary/
advanced routes, one accessible ordinary route per district, bounded reset-zone
metadata, landmarks and canonical map identity. Its procedural presentation is
still below the approved modular-pixel-art, density, provenance and visual-
accessibility bar, so G2 remains in progress.

Run it offline after the engine archive has been prepared once:

```bash
scripts/install-godot.sh
scripts/doctor.sh
scripts/test.sh
scripts/run.sh --tick-rate=120
```

Current foundation controls: WASD moves, mouse aims, left click fires Arc
Primary, right click or E casts Vector Lance, Shift sprints, Ctrl or C slides,
Space uses the jump/movement chain, V uses the contextual vault/wall-skim/air technique,
R restarts the match, and F6 restarts at the
other supported tick rate. F7 changes movement reference, F8 changes view, and
F9/F10 adjust cone angle/range (hold Shift to reduce). Controller defaults use
left/right sticks, right trigger, west/east face buttons, and shoulders. The
rate never mutates inside a running match.

G3 now uses protocol 7 and preference schema 3: Space invokes the semantic jump
action, Shift sprints, Ctrl/C directly slides, and primary no longer aliases
Space. Schema-v1/v2 defaults migrate safely, explicit saved alternatives remain
supported, and malformed reduced-motion data fails closed. The jump presentation keeps the collision
anchor grounded while the body rises and a separate receiving-surface shadow
grows broader/darker to the apex, then contracts through descent at equivalent
60/120 Hz phase.

See [development setup](docs/DEVELOPMENT.md) and the
[FLUX movement migration record](docs/MIGRATION-FLUX-MOVEMENT.md).

## Production roadmap

Production advances through small vertical slices. Each checkpoint must leave a
launchable game, focused history, truthful status index, known rollback commit,
and enough instrumentation to diagnose the next slice. Features remain behind
validated content/runtime gates until their simulation, presentation, tests,
tools, accessibility, and compatibility agree.

| Checkpoint | Deliverable | Status / exit evidence |
| --- | --- | --- |
| A — deterministic Sanctum foundation | Pinned engine, pure integer movement/replay core, styled room, vast hub definition, original visual target, attunement rules | Complete: 60/120 Hz tests and playable foundation |
| B — resource/input truth | Separate Health/Stamina/Flux, independent aim, action defaults, protocol and HUD state | Complete |
| C — movement constraints | Same-wall lockout, bounded control states, advanced Conservatory route fixture | Complete |
| D — ability configuration | Stable ability/element/wire IDs, canonical hashes, legal 13-point loadout, gated families | Complete |
| E — first combat path | Arc Primary, Vector Lance, projectiles, swept hit/damage, replay and full Edgeweave invariants | Complete |
| F1 — chemistry storage/safety | Validated material registry, 128 x 128 packed columns, seeded materials/Charge/elevation, immutable worldbone, canonical queue/budgets/hashes, exact reset, read-only preview | Complete |
| G1 — player configuration | Persisted keyboard remapping, world/aim-relative movement, full/cone POV, exact angle/range, CLI/hotkey controls, deterministic transforms | Complete |
| G2 — authored Sanctum | Replace the schematic court with the first vast Nexus-to-Conservatory multi-area topology/visual slice, clear routes, landmarks, elevations, responsive ambience, fast-travel context, and original pixel kit | In progress: canonical campus topology, routes, worldbone, elevation/reset metadata, camera and procedural presentation validate; a generated 12-module source/alpha candidate now has hash/provenance/authority validation but remains excluded and unapproved pending crop/alignment, license, import, performance and visual gates |
| G3 — body/jump/interaction | Reusable basic skeleton, original compact body-lift/shadow jump, landing/interact/fallback-taunt presentation, reduced-motion parity | In progress: Space-jump migration and the timer-normalized shared body-lift/shadow sampler validate; sprite-body integration, per-champion frames, landing/interact/fallback taunt and semantic event wiring remain pending |
| F2/G4 — systemic Sanctum | Structural/thermal reactions, authored traversal devices, input/controller UI, physics/chemistry practice and reset | Planned |
| H1 — first ancestry/champion/spells | One approved body plan and character through loadout, unique taunt, dummy/bot, cues, replay, accessibility and platform source gates | Planned |
| I1/I2 — shared Sanctum | Loopback/ENet, friend presence/join/reconnect, teams, friendly fire/session policy, host practice/travel/moderation/diagnostics | Planned |
| Sanctum V1 acceptance | Complete stations/overlays, LOS cutaways, charm/readability polish, offline/save/network/accessibility/performance, Garuda Sway and Windows packages/cleanup | First product acceptance |
| J — first complete arena/mode | Original modular map, objectives, destruction/material safety, duel/team rules, bots, round/rematch/results | Planned |
| K — session continuity | Late join, reconnect, spectators, forced host migration, diagnostics, self-hostable online boundary | Planned |
| L — cooperative content | Enemy grammar, survival/siege, elite/boss, difficulty, save/rejoin stability | Planned |
| M — systemic mode expansion | PvPvE expedition, roguelike dungeons, lane/stronghold experiment, then measured battle-royale slice | Planned |
| N — roster/biome expansion | One accepted champion, ancestry, map biome, reaction pack, and enemy family at a time | Planned |
| O — production acceptance | Original art/audio kit, accessibility, performance budgets, Linux/Windows packages, migration/update/rollback, release provenance | Planned |

### Slice contract

Every implementation slice follows the same sequence:

1. define the player decision, authority boundary, data/schema IDs, failure
   behavior, performance budget, and counterplay;
2. add or migrate the smallest canonical content set without widening the legal
   runtime catalog accidentally;
3. implement pure deterministic simulation and failure diagnostics;
4. add presentation as a consumer of semantic state/events;
5. add unit, integration, replay, invalid-content, 60/120 Hz, and applicable
   network/performance/accessibility fixtures;
6. expose debug views, reset/cleanup, configuration, and operator commands;
7. update README status, focused contracts, migration notes, and the append-only
   worklog before committing;
8. launch/import/test from a clean checkout, publish a focused reversible commit,
   and retain the preceding green checkpoint.

Content breadth does not outrun system depth: one champion completes every gate
before the next begins; one material reaction proves the full data-to-network
path before a catalog expands; one mode reuses shared rules before another mode
adds new objectives. Experimental content fails closed when its schema, feature
flag, content hash, map budget, or host capability is absent.

### Management and sources of truth

- `README.md` is the public game brief, chapter index, and honest implementation
  status.
- `SPECIFICATION.md` is normative for architecture, determinism, trust,
  networking, map packages, tests, and release gates.
- `docs/OVERHAUL-PLAN.md` owns ordered checkpoints and chapter exit criteria.
- Focused documents own Sanctum, visual, movement-migration, abilities, combat,
  chemistry, and development contracts.
- Versioned content manifests own selectable data; code defaults may not create
  undeclared network-visible content.
- `.agent/WORKLOG.md` records exact changes, validation, limitations, commit, and
  push state for every slice.
- FLUX is the legacy playable prototype and design/tuning evidence. It is not a
  Flux2 runtime dependency, and conflicting legacy behavior requires an explicit
  preserve/reinterpret/replace/archive decision.

A slice advances only when determinism, authority, performance, readability,
map safety, replay, accessibility, offline operation, and applicable platform
gates pass. Scope may grow; correctness is never waived to make a feature list
look complete.

## Project documents

- [Production specification](SPECIFICATION.md)
- [Sanctum hub and fast-travel contract](docs/SANCTUM-HUB.md)
- [Living Wellspring V1 acceptance contract](docs/SANCTUM-V1-ACCEPTANCE.md)
- [Visual direction](docs/VISUAL-DIRECTION.md)
- [Reactive pixel-material and chemistry system](docs/reactive-material-system.md)
- [Material registry/grid foundation](docs/MATERIAL-GRID-FOUNDATION.md)
- [Movement migration](docs/MIGRATION-FLUX-MOVEMENT.md)
- [Ability and loadout configuration](docs/ABILITY-CONFIGURATION.md)
- [Deterministic combat foundation](docs/COMBAT-FOUNDATION.md)
- [Gate-ordered overhaul implementation plan](docs/OVERHAUL-PLAN.md)
- [Development and offline setup](docs/DEVELOPMENT.md)
- [Character and skeleton reference](reference/character-sprites/README.md)

<!-- BEGIN WELLSPRING_VISUAL_V2 -->
## Wellspring visual-production v2

| Asset family | Complete |
| --- | ---: |
| Race foundations: 21 races × 5 sizes × 2 presentations | 210 |
| Complete race exemplars | 21 |
| Complete champion visual packages | 24 |
| Wellspring district packages | 9 |
| Enabled element VFX families | 8 |
| Material/state cells | 132 |
| Prop/state cells | 220 |

See [the complete tabular visual catalog](docs/WELLSPRING-VISUAL-PRODUCTION.md).
<!-- END WELLSPRING_VISUAL_V2 -->
