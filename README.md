# FLUX

FLUX is a fast top-down **2.5D shared elemental sandbox** built in Godot 4.
Players master a deep universal movement system, cast spells through reusable
spatial delivery forms, and manipulate a deterministic reactive world whose
terrain, visibility, routes, structures and projectiles can change during play.

The initial product is **not** a weapon-collection roguelike, a sequence of
procedurally generated rooms, or a conventional twin-stick arena shooter with
elemental damage colors. The first map is a **large authored connected
Wellspring world** where several players can coexist in the same host session,
explore, train, duel, cooperate, trigger local events and combine elemental
states without forcing the whole lobby into one activity.

This repository is the canonical unified FLUX project. The root Godot project is
authoritative; `legacy/web-prototype` remains migration/reference evidence only.

## Core game

FLUX is built around three interacting languages:

```text
movement
+ spell geometry
+ reactive world state
```

Moment to moment:

```text
read players + projectiles + terrain
-> choose a movement line and spell geometry
-> cast into world state
-> trigger or avoid reactions
-> exploit the changed routes/visibility/cover
-> reposition before the next commitment
```

Damage matters, but the deeper game is about changing the opponent's available
choices while preserving your own.

See [`docs/CORE-GAME-DESIGN.md`](docs/CORE-GAME-DESIGN.md) for the canonical
product-direction contract.

## Design pillars

1. **Movement is the primary defensive language.** Ordinary walking/strafe solves
   ordinary pressure; sprint, slide, roll, jump, wall movement, wavedash, air
   redirect/dodge, vault and superglide answer increasingly committed spatial
   problems.
2. **Spell shape and element are separate systems.** Burst, Beam, Spray and the
   other delivery kernels define geometry; Earth/Fire/Water/etc. define the
   payload and world interaction.
3. **Projectiles are moving geometry.** They create temporary safe/danger spaces
   and also place elemental intent into the map. Missing a player can still
   matter if the cast changes terrain or enables a reaction.
4. **Chemistry changes the map, not a hidden weakness wheel.** Reactions alter
   traction, cover, routes, visibility, structures, trajectories, fields and
   resource pressure. Raw bonus damage is not the organizing principle.
5. **Environment interaction is selective.** A material may react strongly,
   weakly or not at all. FLUX chooses useful readable interactions over exhaustive
   realism.
6. **Several players share one world.** The initial networking target is eight
   connected players in one host-authoritative Wellspring session with local
   activities, teams, observers, resets and anti-grief rules.
7. **Readability outranks spectacle.** Shape, motion, timing, value, sound and
   residue carry gameplay meaning; color is supplemental.
8. **The world is authored first.** Procedural/roguelike modes are future uses of
   accepted systems, not the foundation of the initial map.
9. **Simulation owns outcomes.** Rendering, animation and particles never define
   hitboxes, damage, reactions, collision or movement authority.
10. **Players can host and develop locally.** Linux/Windows, offline tools,
    direct hosting, deterministic replay and reversible checkpoints remain core
    production requirements.

## The Wellspring: first shared world

The Wellspring is the first large playable sandbox, not merely a menu hub. It
combines magical campus, fortress, proving ground, foundry, gardens, rooftops,
undercroft, social space and expedition edge into one connected authored world.

Major regions include onboarding/attunement, host/join and social staging,
movement training, elemental proving grounds, archive/replay space, recovery and
crafting areas, foundry/transmutation systems, diagnostics/settings and biome/
private-trial regions.

Every major region should eventually expose:

- an understandable ordinary route;
- a faster/more expressive advanced movement route;
- at least one systemic route created or changed by world state;
- a safe recovery route;
- memorable landmarks and material identity;
- explicit mutable/resettable areas separated from immutable `worldbone`.

Several players can occupy the world simultaneously. A duel, chemistry trial or
boss event may temporarily seal a **local** region without suspending unrelated
players elsewhere.

## Movement

Current deterministic foundations already include:

- move + independent aim;
- acceleration, braking and counter-strafe;
- sprint;
- hop and double jump;
- variable jump and fast fall;
- slide and slide jump;
- wall contact, kick and skim;
- air redirect and air dodge;
- wavedash;
- vault;
- superglide;
- landing cut;
- Edgeweave near-miss Stamina reward;
- explicit launch/stun/root/slow state contracts.

The new movement design treats projectile patterns as temporary geometry:

| Threat | Preferred movement answer |
| --- | --- |
| Simple aimed line | Walk/strafe/counter-strafe |
| Developing field | Sprint or route change |
| Tight ground crossing | Slide or committed ground evade |
| Projectile wall | Timed roll/jump/air action |
| Ground hazard | Hop/jump/route elevation |
| Bad aerial line | Air redirect/dodge |
| Geometry opportunity | Wall kick/skim, vault, wavedash, superglide |
| Element-created route | Ice, current, wind lane, temporary structure, cooled basalt, etc. |

Ground evasion should read as an original **roll** animation; vertical/aerial
evasion should read through **jump/hop/body-lift** language. Animation presents
state but never creates invulnerability or motion authority.

## Spellcasting, not weapon classes

Physical equipment may exist as character identity or presentation, but the
universal combat taxonomy is spell delivery geometry.

The first eight reusable delivery foundations are:

| Delivery | Core behavior |
| --- | --- |
| **Bolt** | One discrete moving cast |
| **Burst** | Several projectiles around true aim |
| **Beam** | Sustained/charged line |
| **Spray** | Continuous cone/stream |
| **Rapid Fire** | Repeated small casts/projectiles |
| **Whip** | Flexible sweep/tether |
| **Orb** | Slow/persistent/lob-capable payload |
| **Wave** | Wide moving front |

A spell is:

```text
delivery kernel
+ elemental payload
+ optional bounded pattern modifier
+ timing/cost/targeting/counterplay
= stable ability definition
```

Every promoted element should eventually be representable through every
delivery foundation. This creates **8 reusable kernels × 8 elemental payloads**,
not 64 independently hard-coded combat systems.

The first new kernel to implement is **Burst**: deterministic symmetric
multi-projectile spawning around the actual aim vector, with a neutral
32x32/center-pivot visual foundation and elemental effects applied afterward.

See [`docs/SPELLCASTING-DELIVERY-FOUNDATIONS.md`](docs/SPELLCASTING-DELIVERY-FOUNDATIONS.md)
and [`docs/ABILITY-CONFIGURATION.md`](docs/ABILITY-CONFIGURATION.md).

## Elements and chemistry

Current promoted families:

`Earth · Fire · Water · Wind · Ice · Charge · Light · Dark`

Future-gated until the fundamentals are accepted:

`Spirit · Chaos · Gravity · Time`

The first eight already have a design-locked 36-pair unordered reaction network.
Examples:

- Earth + Fire -> **Magma -> cooling crust -> basalt -> rubble**;
- Fire + Water -> **Steam**;
- Water + Ice -> **Freeze**;
- Earth + Water -> **Mud**;
- Water + Charge -> **Conductive Flood**;
- Wind + Wind -> **Vortex**;
- Earth + Light -> **Crystal Prism**;
- Ice + Dark -> **Black Ice**;
- Light + Dark -> **Penumbra**.

Reactions should change movement, visibility, terrain, cover, structures,
trajectories and decisions. They are not an elemental matchup multiplier.

See:

- [`docs/ELEMENT-REACTIONS-FIRST-EIGHT.md`](docs/ELEMENT-REACTIONS-FIRST-EIGHT.md)
- [`docs/ELEMENT-REACTIONS-IMPLEMENTATION-PLAN.md`](docs/ELEMENT-REACTIONS-IMPLEMENTATION-PLAN.md)
- [`docs/ELEMENT-ENVIRONMENT-RESPONSES.md`](docs/ELEMENT-ENVIRONMENT-RESPONSES.md)

## Selective environment interaction

FLUX deliberately does **not** simulate every plausible element/material pair.
Each gameplay material/prop declares supported operations; everything else can
be explicitly inert.

Examples:

- Water + soil matters because Mud changes movement;
- Water does not need to erode decorative stone;
- Wind moves gases and loose matter, not every prop;
- Charge follows semantic conductor networks, not metallic-looking pixels;
- Light reflects/refracts from authored optical surfaces, not every shiny object;
- Fire burns authored fuel and selected mutable materials, not all scenery.

This makes interactions learnable, deterministic and performant.

High-value world objects should connect several systems. A sluice can change
Water flow, routes and Charge connectivity; a furnace can heat, ignite and enable
Magma/Steam; a prism can redirect Light and be broken; a relay can store/route
Charge; a support can change cover and produce rubble.

## Multiplayer and ownership

The current first implementation target is **up to eight connected players**.
Foundations already exist for direct-IP ENet host/join, protocol/content
handshake, host-authoritative input/state, observers, bounded snapshots,
reconnect behavior and shared Wellspring activities.

The shared sandbox expands this model:

- players may explore/train/fight concurrently;
- local activities can opt participants in without forcing a global mode switch;
- safe/social zones reject hostile outcomes;
- mutable areas have reset groups and capacity limits;
- several players may combine elements in the same reaction;
- physical reaction outcome comes from world state, not affinity strength;
- source/assist/environment credit is tracked separately;
- team/friendly-fire rules are explicit per activity;
- clients never author material or reaction outcomes.

Measured scale beyond eight is future work.

## Champions and affinities

Every current champion has exactly **3 innate affinity points** during the
first-eight phase.

- ordinary champion: two affinities distributed **2 + 1**;
- Treevor the Mason: sole approved **1 + 1 + 1** exception;
- no current mono-element `3` profile;
- ordinary unordered affinity pairs remain unique;
- affinity changes explicitly authored build efficiency/access, not automatic
  raw spell or reaction power.

Current examples:

- **Oh Tipi:** Water 2 + Charge 1;
- **Fluup:** Wind 2 + Charge 1;
- **Waka Aren Si:** Charge 2 + Light 1; temporary technical compatibility key
  remains `nico_lai` until an atomic migration;
- **Treevor:** Earth 1 + Wind 1 + Fire 1.

See [`docs/CHAMPION-AFFINITIES-FIRST-EIGHT.md`](docs/CHAMPION-AFFINITIES-FIRST-EIGHT.md)
and [`docs/CHAMPION-AFFINITY-IMPLEMENTATION-PLAN.md`](docs/CHAMPION-AFFINITY-IMPLEMENTATION-PLAN.md).

## Visual direction

FLUX uses original compact top-down 2.5D pixel/virtual-pixel presentation with:

- nearest-neighbor scaling;
- strong silhouettes and exaggerated key poses;
- visible grounded shadows/body lift for vertical motion;
- eight-direction support where orientation matters;
- symmetric universal casting/projectile foundations;
- elemental VFX layered over neutral spell geometry;
- clear separation between traveling collision, impact and persistent residue;
- shape/value/motion/audio cues in addition to color.

For new directional foundations the target presentation order is:

```text
N, NE, E, SE, S, SW, W, NW
```

Existing atlases using another order require an explicit versioned migration;
they must never be silently reinterpreted.

## Current implementation state

| System | Current state |
| --- | --- |
| Godot deterministic simulation | Foundation live |
| 60/120 Hz movement/replay | Foundation live |
| Deep movement grammar | Foundation live; final route/art tuning incomplete |
| Direct host/join networking | Foundation live |
| Shared Wellspring roster/practice/round systems | Foundation live; open-world coexistence incomplete |
| Projectile simulation | Single-projectile/Bolt-like foundation live |
| Burst delivery kernel | **Next implementation slice** |
| Other spell delivery kernels | Planned |
| Material grid/worldbone/reset | Foundation live |
| First-eight reaction design | Locked |
| Runtime chemistry | Fundamentals pending |
| Selective environment-response system | Design locked; runtime pending |
| Champion weighted affinities | Design/content migration in progress |
| Character sprite integration | Oh Tipi foundation integrated; final roster art/integration pending |
| Initial large authored Wellspring world | In progress |
| Procedural/roguelike maps | Future, after core sandbox acceptance |

## Implementation order

The canonical implementation plan is
[`docs/OVERHAUL-PLAN.md`](docs/OVERHAUL-PLAN.md).

Current high-level order:

```text
preserve deterministic foundations
-> shared connected Wellspring sandbox
-> movement-vs-projectile pattern tuning + roll/jump evade readability
-> Burst and remaining universal spell delivery kernels
-> first-eight elemental payload layer
-> selective environment response system
-> executable first-eight chemistry
-> shared-world encounter ecology / AI
-> multiplayer visual/audio readability
-> champion/loadout vertical slices
-> complete shared-sandbox acceptance
-> only then elements 9-12, procedural dungeons and larger modes
```

## Originality boundary

FLUX studies broad principles from movement games, projectile-heavy action games,
systemic simulations, fighters, MOBAs and classic top-down adventures. It does
not copy their sprites, maps, characters, weapons, bullet patterns, names, UI,
trade dress, timing data or protected assets.

Useful transferred principles include:

- projectiles as temporary geometry;
- handcrafted tactical spaces;
- strong visual threat hierarchy;
- committed defensive movement;
- multi-system environmental objects;
- guarded procedural randomness in later modes;
- combinatorial systemic interactions;
- mastery rewards that do not permanently break competitive fairness.

When a reference conflicts with FLUX readability, determinism, multiplayer
clarity, accessibility, performance or originality, the FLUX rule wins.

## Development rule

Every promoted runtime slice must remain:

- deterministic;
- host-authoritative where networked;
- bounded in work/entities/events;
- worldbone-safe;
- exactly resettable where declared;
- replay/hash tested;
- readable at gameplay zoom;
- accessible without color-only meaning;
- launchable on supported Linux/Windows workflows;
- reversible as a focused checkpoint.
