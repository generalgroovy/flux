# First-eight element reaction implementation plan

Status: **ordered implementation plan**. Runtime chemistry remains at F1 storage/
safety until the individual slices below are implemented and accepted.

This focused contract expands Chapter 5 of `OVERHAUL-PLAN.md`. It governs the
order in which the first eight promoted element families enter the deterministic
material simulation. The design source is
[`ELEMENT-REACTIONS-FIRST-EIGHT.md`](ELEMENT-REACTIONS-FIRST-EIGHT.md), with the
machine-readable draft in
[`content/reactions/first_eight_element_reactions_v1.json`](../content/reactions/first_eight_element_reactions_v1.json).

## Scope lock

Fundamental families in scope:

`Earth, Fire, Water, Wind, Ice, Charge, Light, Dark`

Explicitly deferred until the fundamental acceptance gate:

`Spirit, Chaos, Gravity, Time`

No implementation slice may silently introduce behavior for a deferred family.
The twelve-family ID catalog remains stable, but only the first-eight reaction
registry may become executable during this phase.

## Global runtime contract

Before any individual reaction becomes playable, the reaction kernel must own:

- stable reaction IDs and deterministic pair lookup;
- explicit formation thresholds and material/state prerequisites;
- one authoritative phase order per simulation tick;
- bounded dirty/awake work independent of rendering and camera visibility;
- typed actor effects such as slow, DoT, interrupt, reveal, mark, displacement,
  traction and projectile redirect;
- typed map effects such as flow, phase change, structure damage, temporary
  geometry, gas/visibility fields and conductor networks;
- explicit ownership/credit for damage, reaction assists and environment kills;
- formation/active/residue lifecycles with hard area/lifetime/propagation caps;
- exact reset and canonical hashing;
- semantic presentation/network events rather than pixel-derived authority;
- 60/120 Hz deterministic tests and replay fixtures;
- worldbone preservation and route-safety validation.

## F2A — reaction schema and phase orchestrator

Goal: make reaction definitions executable data without enabling meaningful map
mutation yet.

Deliverables:

1. `ReactionCatalog` validator for the first-eight registry.
2. Exactly eight permitted fundamental IDs and 36 unordered pair definitions.
3. Fail closed on unknown/gated element, duplicate/missing pair, asymmetric pair,
   missing counter/telegraph, invalid bounds, or runtime-enabled content before
   the kernel is ready.
4. Stable reaction wire IDs generated/checked by manifest.
5. `MaterialPhaseOrchestrator` with fixed ordered phases, bounded work and no
   frame/render dependencies.
6. Typed reaction-event record carrying tick, reaction ID, owner, region/cell,
   formation stage and semantic outcome.
7. Unit tests for catalog hashes, pair coverage, queue order and 60/120 Hz phase
   scheduling.

Exit gate: the complete 36-pair design compiles and validates but produces no
unreviewed live reaction effects.

## F2B — structure + flagship Magma lifecycle

Goal: prove that chemistry can permanently-for-the-round reshape a route while
remaining resettable and worldbone-safe.

Foundation work:

- typed mutable structural health/damage classes;
- warned damaged stages;
- deterministic support checks;
- ordered collapse;
- rubble material/state;
- dirty derived collision/navigation regions;
- explicit basalt material or structural state.

First reaction:

`Earth + Fire -> Magma -> cooling crust -> Basalt -> fracture -> Rubble`

Magma requirements:

- formation requires authored heat/material threshold;
- molten cells follow deterministic elevation and bounded flow;
- contact applies capped short DoT and ground denial;
- wood/growth ignition and destructible-stone softening are typed operations;
- Water can cause Steam plus rapid cooling;
- Ice can accelerate cooling;
- basalt can create a temporary bridge/wall/route but never worldbone;
- later fracture produces rubble and recomputes only bounded dirty collision.

Exit gate: the Material Yard demonstrates melt -> flow -> cool -> basalt ->
fracture -> rubble identically in replay at 60 and 120 Hz, survives maximum
reaction pressure without altering worldbone, and exactly resets.

## F2C — thermal + hydrology fundamentals

Goal: connect temperature, wetness, flow and traction to movement and terrain.

Promote in order:

1. **Freeze** — Water + Ice: progressive low-friction ice/temporary crossings.
2. **Steam** — Fire + Water: brief scald then occluding gas.
3. **Mud** — Earth + Water: acceleration/slide/takeoff modifier.
4. **Thermal Shock** — Fire + Ice: thresholded structure fracture/Brittle.
5. **Flood** — Water + Water: depth/elevation flow substrate.
6. **Permafrost** — Earth + Ice: rigid route/cover that fractures.
7. **Conflagration** — Fire + Fire: hotter short-lived fuel-consuming front.
8. **Glacier** — Ice + Ice: temporary soft-solid cover/traversal geometry.

Required integration:

- traction modifiers feed deterministic movement rather than presentation;
- gases feed semantic LOS/visibility policy without leaking hidden actors;
- flow uses fixed neighbor order, integer conservation and bounded transfer;
- thermal state uses explicit thresholds/hysteresis to prevent tick-edge flicker.

Exit gate: players can deliberately flood, freeze, melt, steam, muddy and
fracture routes and the same commands reproduce the same map/movement hashes.

## F2D — Charge networks and electrical reactions

Goal: make Charge spatially dependent on actual conductor connectivity.

Promote:

1. **Conductive Flood** — Water + Charge.
2. **Grounding Network** — Earth + Charge.
3. **Overload** — Charge + Charge.
4. **Superconduct** — Ice + Charge.
5. **Arcflash** — Charge + Light.
6. **Plasma Arc** — Fire + Charge.
7. **Ion Storm** — Wind + Charge.
8. **Static Shroud** — Dark + Charge.

Required systems:

- Charge remains an independent field, never an occupancy replacement;
- deterministic conductor graph/region discovery with hard visit limits;
- visible warning before propagated damage/interrupt;
- no repeated same-tick farming of one actor/network edge;
- grounding and network-break counters are simulation facts;
- device/capacitor hooks use shared typed interfaces, not map-specific scripts.

Exit gate: connected Water/metal/device fixtures produce bounded predictable
propagation, grounding, overload and interruption with exact reset/replay.

## F2E — vector, optical and visibility interactions

Goal: connect reactions to trajectories, cover, airborne movement and visual
information without making rendering authoritative.

Promote:

- **Vortex** — Wind + Wind;
- **Dustfront** — Earth + Wind;
- **Firestorm** — Fire + Wind;
- **Mistcurrent** — Water + Wind;
- **Hailstream** — Ice + Wind;
- **Lightbend** — Wind + Light;
- **Crystal Prism** — Earth + Light;
- **Crystal Lens** — Ice + Light;
- **Mirrorwater** — Water + Light;
- **Solar Flare** — Fire + Light;
- **Radiance** — Light + Light;
- **Penumbra** — Light + Dark.

Required systems:

- vector fields have explicit integer direction/strength and spatial bounds;
- projectile redirection is deterministic and visibly previewed;
- actor air influence respects mass, collision and global speed ceilings;
- reflective/refractive geometry uses semantic surfaces/angles, not sprite pixels;
- visibility effects modify authoritative permitted information only when the
  mode owns limited sight; local effects never reveal unreplicated state.

Exit gate: a player can intentionally curve a projectile, use a vortex for
movement, create/remove occlusion and manipulate a Light/Dark boundary with
clear counterplay and no information leak.

## F2F — Dark, residues and completion of all 36 pairs

Goal: complete the first-eight matrix and prove lifecycle/counter interactions.

Promote remaining reactions:

- **Blightsoil** — Earth + Dark;
- **Cinderveil** — Fire + Dark;
- **Blackwater** — Water + Dark;
- **Shadowdraft** — Wind + Dark;
- **Black Ice** — Ice + Dark;
- **Umbral Field** — Dark + Dark;
- **Fortify** — Earth + Earth;
- plus any first-eight pair not already promoted by F2B–F2E.

This slice also standardizes residue cleanup, overlapping-field ownership,
reaction replacement/priority, repeated exposure guards and accessibility cues.
Dark concealment must never become an information-security bypass: host-owned
visibility and replication remain authoritative.

Exit gate: all 36 unordered first-eight pair IDs have one tested executable
baseline outcome, explicit counterplay and bounded lifecycle.

## Fundamental acceptance gate — required before the last four elements

Spirit, Chaos, Gravity and Time remain design/runtime gated until **all** of the
following are true for the first eight:

| Gate | Required evidence |
| --- | --- |
| Pair completeness | Exactly 36 unordered pair definitions validate and execute; no implicit fallback reactions. |
| Determinism | 60 and 120 Hz suites pass independently; same-rate replay hashes are stable across supported platforms. |
| Worldbone safety | Maximum reaction/destruction fixtures cannot mutate worldbone or remove required spawn/objective connectivity. |
| Reset | Every material, field, structure, residue, conductor and derived-collision state returns exactly to seed. |
| Bounded work | Per-tick material/reaction/network work has measured hard ceilings and no camera dependence. |
| Map interaction | Reactions demonstrably create/remove routes, alter traction/visibility, redirect movement/projectiles, or change cover; the system is not a damage-wheel implementation. |
| Counterplay | Every strong outcome has visible preparation and at least one practical positional/material counter. |
| Network | Host remains authoritative; clients receive bounded semantic events/corrections and cannot author reaction outcomes. |
| Readability | Shape/motion/timing/residue communicate state in normal, grayscale, color-vision and reduced-effects tests. |
| Performance | Dense first-eight stress fixtures pass the modest-hardware simulation/render/network budgets. |
| Gameplay | Two-player chemistry sessions show repeatable deliberate setups, counters, route changes and recoverable mistakes. |

Only after this gate may a new design review propose executable interactions for
Spirit, Chaos, Gravity or Time. Their existing IDs stay reserved; no promises
about their eventual reaction mechanics are made by this plan.

## Recommended development cadence

Each reaction slice should follow the same reversible loop:

```text
content definition
-> validator + failing deterministic fixture
-> minimal authoritative simulation
-> reset/replay/hash checks
-> movement/combat/map integration
-> semantic presentation/network event
-> counterplay fixture
-> dense-work/performance fixture
-> 60/120 + Linux/Windows gate
-> documented checkpoint
```

Do not promote the next behavior slice while the current slice is red. Bounded
schema/fixture preproduction for the next slice may overlap final verification,
consistent with the repository rolling-handoff policy.
