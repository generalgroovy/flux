# Ability, spell and loadout configuration

Status: **canonical configuration boundary for current combat foundations**.

FLUX combat is organized around **spell delivery geometry + elemental payload +
authored constraints**, not weapon classes. Existing names such as Arc Primary,
Vector Lance, Rillshot, Tideline, Eclipse Disc and Pocket Eclipse remain valid
content entries, but they are now treated as early spell implementations inside
a broader reusable casting grammar.

See [`SPELLCASTING-DELIVERY-FOUNDATIONS.md`](SPELLCASTING-DELIVERY-FOUNDATIONS.md)
for the delivery-kernel contract and [`CORE-GAME-DESIGN.md`](CORE-GAME-DESIGN.md)
for the shared sandbox combat model.

## Scope and authority

Runtime boot validates:

- `content/abilities/foundation_abilities_v1.json`;
- `content/champions/foundation_champions_v1.json`;
- `content/loadouts/foundation_practitioner_v1.json`.

Invalid content fails boot and the headless gate. Definitions are canonicalized
and hashed. Array order remains meaningful. Stable wire IDs may be deprecated but
must never be silently reassigned.

Animation, equipment and VFX present a confirmed cast; they do not create the
cast, hit, reaction or movement authority.

## Element-family gate

The twelve intended family IDs remain stable:

`Earth, Fire, Water, Wind, Ice, Charge, Light, Dark, Spirit, Chaos, Gravity, Time`

Only the first eight are runtime-enabled during the current fundamental phase.
Abilities referencing gated families fail closed.

Affinity is governed by the weighted three-point champion contract. Affinity may
modify **explicitly authored build efficiency/access**, never raw spell damage,
reaction magnitude, radius, duration, movement speed or resistance implicitly.

## Spell definition model

A spell is conceptually:

```text
elemental payload
+ delivery foundation
+ optional pattern modifier(s)
+ targeting
+ resource/timing constraints
+ ownership/friendly-fire rules
+ explicit counterplay
= stable ability ID
```

The first universal delivery set is:

| Delivery | Geometry |
| --- | --- |
| Bolt | One discrete projectile. |
| Burst | Several symmetric projectiles around true aim. |
| Beam | Sustained/charged line. |
| Spray | Continuous cone/stream. |
| Rapid Fire | Repeated small casts/projectiles. |
| Whip | Flexible sweep/tether. |
| Orb | Slow/persistent/lob-capable payload. |
| Wave | Wide moving front. |

These are reusable simulation/presentation foundations. Fire Burst and Water
Burst share Burst geometry; their elemental payload and world interactions are
different.

## Targeting families

Delivery does not replace targeting validation. The host still validates the
actual semantic request:

- projectile/swept projectile;
- ray/line;
- cone/volume;
- bounded curve/tether;
- ground/elevation region;
- placed geometry/structure;
- mobility destination/anchor.

Clients request approved spell IDs and bounded aim/target information. They never
send arbitrary damage, reaction, radius or geometry parameters.

## Loadout shape

The current competitive baseline remains:

| Slot | Count | Rule |
| --- | ---: | --- |
| Passive | 1 | Champion identity; no hidden duplicate stacking. |
| Primary | 1 | Reliable zero-Flux pressure/placement spell. |
| Catalog actives | 3 | Unique approved spells inside the build-point budget. |
| Champion mobility | 1 | Flux-paid identity action, collision/speed bounded. |
| Ultimate | 1 | High-impact commitment with visible preparation/counterplay. |

The current active budget remains 13 points until a deliberate balance migration.
Alternative modes may publish another hashed budget rather than mutate a live
session.

## Resources and timing

Every active spell declares, as applicable:

- build points;
- affinity discount ceiling;
- Flux cost;
- startup;
- active/travel duration;
- recovery;
- cooldown;
- lifetime;
- capacity/count limits;
- targeting bounds;
- collision class;
- friendly-fire policy hook;
- pattern modifier limits;
- cleanup/reset behavior;
- counterplay.

A primary can remain resource-free but is not exempt from cadence, collision,
ownership and readability rules.

## Delivery and element separation

Neutral delivery code owns:

- spawn pattern;
- geometry;
- trajectory/movement;
- lifetime;
- collision query;
- neutral animation phases;
- deterministic child ordering.

Element payload owns:

- heat/wet/cold/charge/etc. operations;
- actor status/control intent;
- material/structure/device operation;
- reaction eligibility;
- elemental presentation overlay.

This separation is mandatory for scalability and testing.

Example:

```text
Burst kernel:
  count = 5
  angles = -24,-12,0,+12,+24
  speed/radius/lifetime = authored

Water payload:
  wet + bounded displacement + Water world operation

Charge payload:
  Charge deposition + authored interrupt + conductor operation
```

The Burst kernel is tested once; each payload is tested against the same contract.

## Current foundation implementations

The current projectile combat code already proves:

- independent quantized aim;
- startup/release/recovery;
- deterministic projectile IDs and movement;
- swept world/player collision;
- lifetime/expiry;
- one bounded ricochet for content that authors it;
- damage/control events;
- edgeweave near-miss integration;
- replay/network authority.

Current content examples remain useful migration fixtures:

| Spell | Current role | Delivery interpretation |
| --- | --- | --- |
| Arc Primary | Charge aimed pressure | Bolt |
| Vector Lance | Charge high-commitment line projectile foundation | Bolt today; future Beam variant should be distinct rather than silently changing behavior |
| Rillshot | Water cadence pressure | Bolt / Rapid-Fire-like cadence fixture |
| Tideline | Water displacement lane | Wave candidate; current projectile implementation remains compatibility evidence until migrated deliberately |
| Eclipse Disc | Dark angle pressure with one bounce | Bolt + ricochet modifier |
| Pocket Eclipse | Light tempo/slow pressure | Current projectile compatibility spell; final delivery classification requires design migration |

Do not silently reinterpret a live wire ID when promoting a new delivery kernel.
If geometry changes materially, create/migrate a versioned ability definition.

## Flux Formulas

The expandable magic layer remains a validated content compiler rather than a
runtime scripting language.

The refined formula model is:

```text
element family
+ delivery foundation
+ operation/payload
+ optional pattern modifier/catalyst
+ constraints
-> stable spell variant ID
```

Examples of operations include heat, cool, wet, charge, push, lift, fracture,
grow, decay, cleanse, reveal, refract and redirect.

Catalysts may include:

- second approved element;
- carried reagent;
- device;
- champion-specific hook;
- material already present in the world.

Competitive play exposes curated legal formulas. The shared sandbox, Proving
Grounds and experimental/PvE modes may expose broader catalogs while using the
same validation and authority rules.

## Multiplayer spell rules

Several players may cast simultaneously in the same world.

Therefore:

- projectile/field IDs are host-authoritative and stably ordered;
- player/team ownership is explicit;
- physical reactions resolve from world state, not affinity contests;
- assist/environment credit is recorded separately from physical outcome;
- hostile/allied spell geometry is readable by shape/motion/audio as well as
  color;
- safe regions may reject hostile spell outcomes before mutation is created;
- dense effects have hard count/work/network budgets.

## Promotion sequence

1. Preserve current Bolt-like projectile foundation and its deterministic tests.
2. Implement **Burst** as the first true multi-projectile delivery kernel.
3. Normalize Bolt as a named reusable kernel rather than per-spell projectile
   special cases.
4. Implement Beam.
5. Implement Spray.
6. Implement Rapid Fire.
7. Implement Whip.
8. Implement Orb, including an explicit elevation/lob contract before any
   authoritative 2.5D arc behavior.
9. Implement Wave as a moving region/front rather than a shotgun approximation.
10. Apply at least two contrasting elemental payloads to each kernel before
    declaring the kernel accepted.
11. Expand to all first-eight element/delivery combinations through authored
    content after the fundamental kernels are proven.

No additional spell breadth is useful if its geometry, counterplay, world-state
operation or multiplayer readability cannot pass the shared core acceptance
criteria.
