# FLUX core game design — shared elemental sandbox

Status: **canonical product-direction contract**.

This document defines what the existing deterministic FLUX foundations are now
building toward. It refines useful lessons from projectile-heavy action games,
immersive systemic games, movement games and roguelikes without copying their
content or forcing their structure onto FLUX.

The core game is **not** a weapon-collection roguelike, a sequence of sealed
combat rooms, or a conventional twin-stick arena shooter with elemental damage
types. The initial product is a **large authored top-down 2.5D shared sandbox
world** in which several players can coexist, travel, train, fight, cooperate and
combine spells while movement and elemental state continuously reshape local
combat space.

## 1. Core statement

FLUX is about three interacting languages:

1. **movement** — how players preserve, spend and redirect momentum;
2. **spell geometry** — how magical intent is delivered through space and time;
3. **world state** — how elements and materials alter terrain, visibility,
   trajectories, structures and future movement.

The canonical moment-to-moment loop is:

```text
read players + projectiles + terrain
-> choose movement line and spell geometry
-> cast into world state
-> world reacts and routes change
-> exploit/counter the new state
-> reposition before the next commitment
```

Damage matters, but the deeper objective is to change the opponent's available
choices while preserving your own.

## 2. Lessons retained from projectile-heavy action games

FLUX adopts broad principles, not franchise-specific mechanics.

| Useful principle | FLUX interpretation |
| --- | --- |
| Projectiles create temporary geometry | Spell trajectories, waves, fields and residues create moving safe/danger spaces that movement must read. |
| Ordinary movement should solve ordinary pressure | Walking, strafing and route choice remain preferable to spending a committed evasive action whenever possible. |
| Strong evasion has commitment | Ground evasion reads as a roll; aerial/vertical evasion reads as a jump/hop/air action. Recovery and destination still matter. |
| High interaction density beats isolated gimmicks | A useful prop or material should connect to movement, elements, projectiles, structure, objectives or players where that connection remains readable. |
| Authored tactical spaces outperform procedural microgeometry | The initial world is handcrafted. Procedural rooms/dungeons are a later mode built only after the shared-world fundamentals are accepted. |
| Randomness should vary situations, not invalidate runs | Later procedural content may use guarded randomness, but the initial sandbox relies on authored geography and deterministic state. |
| Collision should feel fair rather than imitate sprite pixels | Simulation uses explicit bounded shapes; visuals may extend beyond them and never define hits. |
| Visual hierarchy must survive projectile density | Dangerous spell geometry outranks decorative particles; color is never the sole signal. |
| Mastery can earn optional rewards | Training grades, route times, flawless encounters and discoveries may reward mastery without making competitive stats permanently stronger. |

## 3. Initial world: one large authored sandbox

### 3.1 World structure

The Wellspring is no longer understood primarily as a menu hub feeding isolated
rooms. It is the **first large playable world**: a connected magical campus,
fortress, proving ground and wilderness edge with districts, elevation layers,
social spaces, traversal routes, combat pockets, laboratories, destructible
shortcuts, water systems, foundry spaces, gardens, rooftops and undercroft.

The initial world should feel explorable even when no formal match is running.
Players can:

- move freely between safe, social, training and contested spaces;
- encounter other players in the same host session;
- practice routes while others test spells nearby;
- enter locally bounded trials without unloading the surrounding world;
- discover systemic shortcuts and secrets;
- manipulate safe resettable chemistry basins;
- form teams or opt into duels/events;
- spectate or observe activity without forcing everyone into the same mode.

### 3.2 Authored macro and micro structure

For the initial product:

- world geography is handcrafted;
- districts have recognizable silhouettes and environmental identities;
- important routes are authored and tested;
- destructible/mutable regions are explicitly bounded;
- critical topology is immutable `worldbone`;
- local encounter/event composition may vary, but geometry does not need to be
  procedurally invented;
- procedural dungeon/roguelike assembly remains a later application of the same
  movement, spell, chemistry and networking rules.

### 3.3 Route classes

Every meaningful region should support at least:

| Route class | Purpose |
| --- | --- |
| Ordinary | Clear, safe-enough route available without advanced movement. |
| Advanced | Faster or more expressive line using slide, jump, wall, vault or momentum techniques. |
| Systemic | Route created, closed or transformed by elements, structures, devices or other players. |
| Recovery | Readable escape/reset path so one failed technique does not strand a player. |

Examples of systemic routes include frozen water crossings, basalt cooled from
magma, collapsed rubble ramps, temporary ice geometry, pressure lanes, opened
sluices, broken supports and prism-controlled barriers.

## 4. Shared multiplayer world

### 4.1 Default concurrency

The existing first implementation cap of **eight connected players** remains the
current acceptance target. Several players can inhabit the same world at the same
time; a lobby is not a menu that disappears when combat begins.

The architecture must support:

- proximity coexistence without forced combat;
- opt-in teams, duels, trials and shared events;
- safe social zones with restricted hostile mutation/damage;
- locally bounded competitive zones with explicit rules;
- players entering/leaving activities independently;
- late join and observer behavior;
- host-owned reset and moderation;
- shared chemistry whose authorship and credit remain deterministic.

Measured scaling beyond eight is future work, not a current promise.

### 4.2 Multiplayer chemistry

Elemental state belongs to the world, not permanently to its caster.

If Player A wets a corridor and Player B applies Charge, Conductive Flood is
resolved from actual world state. The reaction system records source ownership
and assists, but its physics do not become stronger simply because either player
has higher affinity.

For simultaneous actions:

- host simulation is authoritative;
- commands resolve in stable tick/entity/event order;
- reactions consume deterministic state snapshots/phase order;
- ownership and assist credit are separate from physical outcome;
- team/friendly-fire policy is explicit per activity;
- clients never author reaction results.

### 4.3 Anti-grief and persistence rules

A shared sandbox cannot allow one player to permanently ruin the world.

Therefore:

- worldbone is immutable;
- mutable regions declare reset groups and maximum lifetime/persistence;
- safe/social districts may reject hostile mutations entirely;
- laboratories and arenas can reset independently;
- transient matter has hard capacity and cleanup budgets;
- host tools expose clear reset reasons and ownership logs;
- persistent discoveries/unlocks are stored separately from transient combat
  destruction.

### 4.4 Player and developer sandbox symmetry

The Wellspring is simultaneously the player's systemic playground and the
developer's integration surface. Movement routes, Loom configuration, targets,
the Elemental Crucible, duels, Farflow and resets must be enjoyable and
discoverable in ordinary play while also supporting reproducible scenarios.

| Audience | Capability | Shared safeguard |
| --- | --- | --- |
| Player | Configure legal spells, practice movement, combine elements, duel/cooperate, observe and reset bounded areas | In-world context, clear ownership, host validation and no privileged state mutation |
| Developer | Select a scenario/seed, drive semantic commands, inspect state/capacities, capture evidence and inject bounded failures | The production catalog, simulation, networking, presentation and package remain the exercised path |

Debug tools may reveal truth but cannot create a second ruleset. Presentation
content may reload offline after validation; simulation-affecting changes
require a safe restart and a new compatibility hash. The complete architecture,
performance and expansion admission rules live in
[`FOUNDATION-SYSTEMS.md`](FOUNDATION-SYSTEMS.md).

## 5. Movement is the primary defensive language

FLUX does not reduce evasion to one universal dodge roll. Projectile-heavy games
are useful because they show that moving danger can become temporary geometry;
FLUX answers that geometry with a much richer traversal system.

### 5.1 Defensive hierarchy

| Response | Cost/commitment | Best use |
| --- | --- | --- |
| Walk / strafe / counter-strafe | Lowest | Ordinary aimed fire and gap navigation. |
| Sprint / route change | Low-medium Stamina | Leave a developing field or rotate around cover. |
| Slide | Committed ground line | Pass low pressure, preserve momentum, cross a short danger band. |
| Ground evade / roll presentation | Short committed evade | Cross a dangerous projectile boundary when walking is insufficient. |
| Hop / jump / double jump | Vertical/aerial commitment | Change timing/elevation, clear ground pressure or route geometry. |
| Air redirect / air dodge | Expensive correction | Escape a bad aerial line or cross a projectile topology break. |
| Wall kick / wall skim | Geometry dependent | Convert map edges into route changes. |
| Wavedash / slide jump / vault / superglide | Technique dependent | Preserve or convert momentum through authored openings. |
| Element-created traversal | State dependent | Use ice, wind, water, structures or reactions as temporary movement infrastructure. |

### 5.2 Roll and jump readability

Evasion presentation must communicate actual state:

- a grounded committed evade uses a compact **roll** silhouette;
- aerial/vertical avoidance uses **jump/hop/body-lift** language;
- no generic glowing dash should obscure whether the player is grounded,
  airborne, invulnerable, recoverable or colliding;
- collision and canonical movement remain simulation-owned;
- animation never creates invulnerability or movement by itself.

### 5.3 Projectile topology and movement skill

Spell patterns should test different movement knowledge:

- aimed lines test sidesteps and counter-strafe;
- fans test gap recognition;
- bursts test short commitment timing;
- waves test crossing timing;
- fields test route planning;
- ricochets test geometry awareness;
- curved/redirection patterns test prediction;
- lingering residues test future-space planning;
- mixed player crossfire tests global awareness.

The goal is not maximum projectile count. It is **maximum readable decision
density**.

### 5.4 Feel, chaining and body-role contract

Smoothness means immediate, predictable control—not removal of every
commitment. FLUX measures the existing movement language before expanding it.

| Area | Design contract |
| --- | --- |
| Authoritative cadence | Gameplay exists at 120 Hz only; timing is expressed in deterministic ticks and never depends on render rate. |
| Response | A legal input changes authoritative state within one tick; delayed actions visibly communicate the commitment that owns the delay. |
| Chaining | One explicit transition graph owns buffers, cancels, costs, cooldowns and refusals for movement and casting. |
| Momentum | Acceleration, braking, reversal, landing and air steering preserve player intent unless collision, control loss or an authored commitment prevents it. |
| Direction | Digital travel supports all eight normalized directions; analog travel and aim stay continuous; facing remains a separate readable presentation channel. |
| Body roles | Small gains acceleration/recovery, middle remains flexible, and large gains stability/momentum; shared honest collision and universal techniques prevent hidden size advantage. |
| Feedback | A refused action presents one primary cause rather than silently dropping input or emitting several competing messages. |
| Evidence | Input response, stopping distance, reversal time, landing recovery, chain success and route time are captured in repeatable 120 Hz journeys and a named human playtest. |

No new movement technique is justified while an existing technique lacks a
distinct purpose, readable state change, deterministic test or counterplay.

## 6. Spellcasting replaces weapon taxonomy

Weapons are not the primary content axis. Physical equipment may exist as
character identity, an anchor or cosmetic presentation, but the gameplay system
is built around spell geometry and elemental payload.

Universal delivery foundations:

| Delivery | Spatial behavior | Core decision |
| --- | --- | --- |
| Bolt | One discrete moving cast | Precision, lead and placement. |
| Burst | Several projectiles from one cast | Gap coverage and short-range pressure. |
| Beam | Sustained/charged line | Lane commitment and interruption. |
| Spray | Continuous cone/stream | Paint nearby terrain and deny close space. |
| Rapid Fire | Repeated small casts | Tracking, suppression and incremental setup. |
| Whip | Flexible sweeping/tether line | Mid-range control, pull, sweep or redirect. |
| Orb | Slow/lobbed persistent payload | Prediction, delayed setup and larger state change. |
| Wave | Wide traveling front | Route control and timing gates. |

Every first-eight element must eventually be representable through every
foundation. The result is not eight unrelated spell lists; it is:

```text
spell delivery kernel
+ elemental payload
+ authored pattern/modifiers
+ cost/timing/counterplay
= stable spell definition
```

Examples:

```text
Burst + Water  -> several wetting/displacement projectiles
Burst + Earth  -> several heavy structure/rubble projectiles
Burst + Light  -> several reveal/refract projectiles
Burst + Dark   -> several decay/concealment projectiles
```

The **Burst simulation** is shared. Elemental behavior is applied as a payload
and VFX layer rather than baked into the neutral projectile foundation.

### 6.1 Pattern modifiers

Delivery families can accept bounded authored modifiers without becoming new
weapon classes:

- narrow/wide spread;
- simultaneous/staggered release;
- radial/ring release;
- split/child projectiles;
- single bounded ricochet;
- deterministic homing/steering;
- orbit;
- return;
- pierce;
- delayed activation;
- terrain-following wave;
- elevation band.

Each modifier has explicit cost, collision, lifetime and readability rules.

## 7. Projectiles are moving geometry

A projectile has two jobs:

1. threaten or influence an actor;
2. place elemental intent into world space.

That second job is what differentiates FLUX from a conventional bullet shooter.
Missing a player can still matter if the projectile wets ground, heats a wall,
charges a relay, freezes water or creates a visibility state.

### 7.1 Projectile fairness

- simulation collision uses explicit geometric radii/sweeps, not opaque pixels;
- hostile geometry has strong silhouette and timing hierarchy;
- allied, hostile and neutral/world-owned effects differ through shape/outline/
  motion as well as color;
- decorative trails may never conceal the collision core;
- impact visuals rapidly surrender visual priority after dangerous frames;
- multiple-player crossfire must remain legible in grayscale and reduced-effects
  modes.

### 7.2 Aiming and directions

Simulation aim remains continuous/quantized world-space direction, not restricted
to eight sprite headings. Presentation may select one of eight directional
frames or rotate a compatible neutral sprite.

For directional sprite foundations the target order is:

```text
north, north_east, east, south_east,
south, south_west, west, north_west
```

Horizontal counterparts should be exact mirrors where the design is intended to
be symmetric. Universal projectile and cast foundations must not assume a staff,
gun, dominant hand or asymmetric muzzle.

## 8. Element + material + environment

### 8.1 Reactions are selective, not a realism simulator

Every material does **not** need a special response to every element.

A material/element pair may deliberately be:

- inert;
- cosmetic-only;
- a state modifier;
- a movement modifier;
- a visibility modifier;
- a projectile/trajectory modifier;
- a structural transformation;
- a field/network interaction;
- a damaging hazard.

**Inert is a valid and often desirable result.** FLUX prefers a small number of
clear, useful systemic consequences over exhaustive physical realism.

Examples:

- Water wets soil because Mud changes movement meaningfully;
- ordinary decorative stone does not need to dissolve under Water;
- Wind moves smoke/steam and loose matter but does not simulate every cloth or
  leaf independently;
- Light refracts from authored prism/mirror surfaces, not every shiny pixel;
- Fire burns authored fuel and heats selected mutable materials, not all props;
- Charge propagates through explicit conductive networks, not arbitrary visual
  metal colors.

### 8.2 First-eight scope

Current promoted families remain:

`Earth, Fire, Water, Wind, Ice, Charge, Light, Dark`

`Spirit, Chaos, Gravity, Time` remain future-gated until the first-eight
fundamental reaction system is accepted.

The existing 36 unordered first-eight pair identities remain canonical. Their
purpose is to alter **map state and decisions**, not provide hidden elemental
bonus damage.

### 8.3 Environmental response authoring

Each map material/prop/region should declare explicit response channels rather
than infer behavior from appearance:

```text
material tags
+ allowed elemental operations
+ thresholds/capacity
+ output state
+ actor/map effects
+ cleanup/reset
+ presentation cues
```

This keeps chemistry deterministic, performant and understandable.

## 9. Environment as an active participant

The world should contain fewer disposable decorations and more multi-system
objects.

High-value examples:

| Object | Possible interactions |
| --- | --- |
| Sluice/gate | Opens water route, floods basin, conducts Charge, changes movement. |
| Furnace | Heat source, ignites fuel, enables Magma/Steam, can be disabled/overloaded. |
| Prism/mirror | Redirects Light, may become cover, can break or be repositioned. |
| Capacitor/relay | Stores/routes Charge, overloads, powers doors/lifts. |
| Breakable support | Changes cover/route, creates rubble, may expose another path. |
| Vegetation | Cover/readability, growth state, burns, may obstruct routes. |
| Iceable water | Hazard, route, projectile substrate, Charge network. |
| Movable cover | Blocks projectiles, changes lane geometry, may be pushed or destroyed. |
| Pressure/wind device | Movement route, projectile redirect, gas movement. |

New props should be evaluated by **interaction density**, not merely appearance.

## 10. Encounters in an open world

The world does not need to lock into a room every time combat occurs.

Encounter types include:

- spontaneous player skirmish in contestable regions;
- opt-in duel/training rings;
- cooperative enemy events;
- roaming enemies or hazards;
- local objective events;
- chemistry challenges;
- movement races;
- boss/world-event arenas that temporarily seal only the relevant region;
- team exercises;
- discovery/secrets requiring element + movement knowledge.

Enemy composition should create **spatial roles** rather than only health tiers:
long-range lines, pursuit, field placement, structure pressure, mobility denial,
projectile walls, support, summoning, redirection and material manipulation.

Bosses should combine known spell/movement/element grammars into readable exams
rather than introduce unrelated exceptions.

## 11. Secrets and exploration

Secrets should be inferable from world rules.

Good secret logic:

```text
observe unusual environment
-> understand material/element rule
-> spend movement/spell/resource commitment
-> reveal route or state
-> receive discovery/reward
```

Examples include freezing a water route, cooling magma into a crossing, breaking
a cracked support, using Wind to clear a gas clue, refracting Light into a relay,
or manipulating a sluice from another elevation.

Avoid invisible arbitrary interactions that require external lookup.

## 12. Visual style and information hierarchy

FLUX remains an original compact pixel-art / virtual-pixel top-down 2.5D game.

Priority at gameplay zoom:

1. local player silhouette and state;
2. hostile spell collision geometry;
3. nearby terrain/collision and route edges;
4. major cast/reaction telegraphs;
5. other player/enemy silhouettes;
6. persistent material state;
7. decorative effects.

Rules:

- nearest-neighbor scaling;
- strong silhouettes and exaggerated key poses;
- eight-direction character/projectile support where orientation matters;
- symmetrical universal foundations unless a specific champion attachment
  explicitly breaks symmetry;
- shadows/body lift explain vertical movement without moving canonical collision;
- elemental VFX are layered onto neutral spell foundations;
- hit/impact particles cannot obscure the next threat;
- hue is supplemental; shape, value, timing, motion and sound carry meaning too.

The maintained visual hierarchy is:

| Layer | Cohesive language |
| --- | --- |
| World | Warm masonry, dark timber, aged brass, deep water and restrained growth; quiet movement lanes carry less contrast than their scenic edges. |
| Landmarks | Large silhouettes establish district and route identity before small decoration is added. |
| Champions | Stable `small`/`middle`/`large` envelopes share one feet pivot and body/clothing-only construction; ancestry, posture and material blocks preserve identity. |
| Shadow/elevation | A separate receiving-surface shadow communicates contact and jump height without scaling the champion or changing collision. |
| Spells/projectiles | Dark outer shape, bright elemental core, ownership geometry, speed/size class, travel cue, impact and restrained residue remain distinct without relying on hue. |
| Interface | Health, Flux, Stamina, active spell layer and four spell cells remain immediate; rules, configuration and diagnostics appear only in contextual Wellspring surfaces. |
| Ambient detail | Decoration supports place and rhythm but yields to actors, danger, collision edges, routes and interaction anchors. |

At every supported zoom the reading order is champion → dangerous geometry →
interaction → architecture → ambient detail. Ordinary gameplay must feel like
an inhabited old-world magical campus, never a debug board or detached menu.

## 13. Progression and economy

The core progression should expand **possibilities and knowledge**, not create
permanent competitive stat superiority.

Potential rewards:

- new authored spell formulas/delivery variants;
- cosmetics and presentation options;
- codex discoveries;
- training medals and route records;
- new destinations/attunements;
- optional PvE modifiers;
- build presets;
- world/lore discoveries.

Competitive rulesets hash and validate legal spell catalogs/budgets before play.

## 14. Procedural modes are downstream

Roguelike/procedural dungeons remain useful, but they are **not the foundation
for the initial map**.

Only after the shared sandbox proves movement, spell geometry, chemistry,
multiplayer readability, AI and reset safety should later modes assemble tested
rooms/regions procedurally.

When procedural generation arrives, prefer:

```text
authored tactical spaces
+ procedural macro connection/event selection
+ guarded rewards/resources
```

over unrestricted procedural microgeometry.

## 15. Core acceptance questions

A feature belongs in the core only if it survives these questions:

1. Does it create a meaningful movement, spell, world-state or teamwork decision?
2. Is the result readable before/while it becomes dangerous?
3. Can several players use/counter it simultaneously without ambiguity?
4. Is the simulation deterministic, bounded and host-authoritative?
5. Does it preserve worldbone and reset safety?
6. Can the environment explicitly opt out when interaction would add noise or
   unrealistic complexity without gameplay value?
7. Does the visual layer remain downstream of gameplay authority?
8. Does it remain responsive, reproducible and measurable at the single 120 Hz
   authority rather than merely looking smooth in one capture?
9. Does it extend shared content, action and visual contracts instead of adding
   another local exception or competing source of truth?
10. Does it compose with existing systems instead of becoming a one-off gimmick?
11. Is there practical counterplay or a clear resource/position cost?
12. Can a new player understand the failure while an expert can still discover
    deeper use?

If not, simplify, defer or remove it.
