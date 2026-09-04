# flux2

Status: **experimental historical design workspace**. Current material and
reaction authority lives in `MATERIAL-GRID-FOUNDATION.md`,
`ELEMENT-REACTIONS-FIRST-EIGHT.md` and
`ELEMENT-REACTIONS-IMPLEMENTATION-PLAN.md`.

Experimental and reference workspace for FLUX.

This repository contains production references, technical design contracts, and
prototype-support material for the main FLUX game. Content in this repository is
not automatically active in the shipped runtime; a system must still pass its
implementation, determinism, networking, performance, gameplay, and visual
acceptance gates before promotion.

## Character reference material

[Open the full character sprite and skeleton reference](../reference/character-sprites/README.md)

![Front view reference preview](../reference/character-sprites/front-views-board.png)

# Reactive pixel-material and chemistry system

## Status and purpose

This section is the ground-up design contract for a persistent reactive-material
system inspired by the systemic possibilities of falling-sand games without
copying any protected implementation, content, material catalog, map, asset, or
trade dress.

The target is not a scientific molecular simulator. The target is a deterministic,
server-authoritative **game chemistry** in which every authored map cell has
explicit material properties and can participate in understandable physical,
thermal, electrical, chemical, biological, and elemental reactions.

FLUX is a top-down arena game, so its simulation must not use the conventional
screen-bottom gravity of a side-view falling-sand game. It uses a **2.5D column
grid**: every cell has authored elevation, occupancy, depth, permeability, and
material layers. Liquids follow hydraulic head, powders settle down elevation
gradients, gases diffuse through connected air space, and structures occupy
explicit collision height.

## Design goals

1. Maps are assembled from reusable materials rather than inert decorative
   tiles.
2. Fire, water, ice, Charge, wind, impact, corrosion, growth, decay, and other
   effects change routes in predictable ways.
3. The same material definitions drive map authoring, simulation, collision,
   rendering, sound, status effects, AI queries, networking, replay, and tests.
4. Emergent interactions create tactical decisions without producing random,
   unreadable, or permanently softlocked competitive maps.
5. A truly immutable material forms the permanent skeleton of every map.
6. Reactions remain computationally bounded on modest Linux and Windows
   hardware.
7. Identical seed, content version, map state, and command history always produce
   the same result.

## Non-goals

- Molecular dynamics or atom-by-atom chemistry.
- Display-resolution simulation of the entire map.
- Unbounded pressure, turbulence, structural finite-element analysis, or rigid
  body fragmentation.
- Hidden instant-kill reactions.
- Arbitrary player-authored reaction scripts in authoritative competitive play.
- Destruction of objective anchors, spawn safety, critical traversal guarantees,
  or the immutable map skeleton.
- Camera-distance simulation shortcuts that would change authoritative outcomes.

## Hard invariants

| Invariant | Required rule |
| --- | --- |
| Immutable topology | `worldbone` is stored in a read-only mask and can never be damaged, heated, cooled, charged, wetted, corroded, transmuted, displaced, replaced, copied, teleported, or erased at runtime. |
| Server authority | Only the authoritative simulation may create, move, react, damage, or delete material. Clients submit semantic actions, never cell writes. |
| Determinism | Fixed-point integer state, fixed processing order, stable rule IDs, seeded hash randomness, and deterministic budgets are mandatory. |
| Bounded simulation | Only authored simulation zones and awakened chunks execute material rules. Work carries over in stable order when a budget is reached. |
| Competitive safety | Spawn clearance, objective clearance, route minima, maximum hazard depth, and reset groups are validated independently from material type. |
| Readability | Dangerous state changes require shape, value, sound, timing, and residue cues; color alone is insufficient. |
| Resetability | Every mutable map region can be restored from its authored seed without rewriting `worldbone`. |
| Layer separation | Rendering pixels never become authority by themselves. Collision and chemistry derive from simulation data, not sampled screen color. |
| Stable content | Material and reaction IDs are versioned wire-format identifiers and may not be silently repurposed. |

## 1. Spatial model: a top-down 2.5D material column

A simulation cell is a world-space material column, not necessarily one monitor
pixel. The initial target is one chemistry cell per **4 × 4 world units**. A
1600 × 900 arena therefore contains 400 × 225 cells, or 90,000 possible cells,
most of which remain asleep.

Each column can contain the following layers:

| Layer | Function |
| --- | --- |
| Immutable base | `worldbone`, permanent void, authored floor elevation, cliff and foundation topology |
| Structural occupant | Wall, pillar, bridge, door, brickwork, timber, metal, glass, crystal, root structure |
| Loose fill | Soil, sand, gravel, rubble, ash, snow, salt, coal dust; represented by material and depth |
| Liquid | Dominant liquid, depth, optional second immiscible layer, and dissolved solutes |
| Surface coating | Wetness, oil, resin, frost, poison, soot, conductive film, holy or dark residue |
| Gas | Dominant gas mixture, concentration, temperature, and local pressure impulse |
| Energy overlays | Heat sources, fire, electrical potential, wind vector, Light, Dark, Gravity, Time, or other fields |
| Derived navigation | Solid occupancy, soft obstruction, friction, hazard, visibility, conductivity, and AI traversal cost |

### Elevation and flow

Every cell owns a base elevation and an effective surface height.

```text
surfaceHeight = baseElevation
              + structuralHeight
              + looseDepth
              + liquidDepth
```

Liquids move toward neighboring cells with lower hydraulic head. Density decides
which immiscible liquid occupies the lower layer. Powders and rubble move toward
lower supported surfaces when their slope and cohesion thresholds are exceeded.
Gases diffuse through connected non-solid volume and are advected by Wind.
Nothing uses screen-down direction as physical gravity.

### Traversal height

A structural cell exposes explicit height bands:

- `surface`: no blocking volume; modifies friction or status only.
- `low`: blocks ground movement but can be jumped or vaulted when authored.
- `full`: blocks actors and ordinary projectiles.
- `roof`: blocks selected vertical or lobbed effects while permitting passage
  beneath where the map defines an interior.
- `immutable`: permanent full collision owned by `worldbone`.

## 2. Immutable map skeleton: `worldbone`

`worldbone` is not “very strong stone.” It is topology outside ordinary material
simulation.

```js
{
  id: "worldbone",
  phase: "immutable",
  collision: "immutable",
  immutable: true,
  runtimeWritable: false,
  destructible: false,
  replaceable: false,
  movable: false,
  thermal: false,
  electrical: false,
  wettable: false,
  soluble: false,
  corrodible: false,
  transmutable: false,
  simulated: false
}
```

Required implementation protections:

1. The immutable mask is loaded into a separate read-only array.
2. Every mutation API rejects coordinates covered by that mask before looking up
   the requested material or effect.
3. Map reset restores mutable layers around the mask; it never rewrites the mask.
4. Network snapshots transmit a base-map hash, not mutable worldbone cells.
5. Tests hash the immutable mask before and after every destructive, corrosive,
   elemental, chaos, replay, reconnect, and migration scenario.
6. Visual skins may present worldbone as ancient black stone, runic metal,
   cliff-bedrock, roots, or architecture, but all skins resolve to identical
   mechanics.

## 3. Material taxonomy

| Phase | Motion model | Examples |
| --- | --- | --- |
| Immutable | Never processed | Worldbone |
| Structural solid | Fixed until damaged, transformed, or support-failed | Stone, brick, wood, metal, glass |
| Loose solid | Settles by elevation, slope, density, cohesion, and support | Soil, sand, rubble, salt, snow, ash |
| Liquid | Moves by hydraulic head, viscosity, permeability, and density | Water, oil, acid, lava, mud |
| Gas | Diffuses through air connectivity and responds to Wind | Steam, smoke, toxic gas, flammable gas |
| Coating | Adheres to surfaces and entities; may drip, evaporate, burn, or react | Wetness, oil film, frost, resin, soot |
| Biological | Consumes substrate and grows through allowed cells | Grass, roots, plague growth, fungus |
| Energy or field | Modifies matter without replacing its bulk material slot | Fire, Charge, Wind, Light, Dark, cold |

## 4. Material definition schema

All authored materials use one registry schema. Optional fields use explicit
neutral defaults; simulation code must not contain material-name special cases
when a property or reaction rule can express the behavior.

```js
{
  id: "wood",
  version: 1,
  displayName: "Wood",
  phase: "structural",
  tags: ["organic", "flammable", "porous", "cuttable"],

  // Geometry and movement
  density: 105,
  cohesion: 210,
  viscosity: 0,
  permeability: 70,
  structuralHeight: "full",
  supportStrength: 130,
  friction: 150,

  // Damage and structure
  integrity: 110,
  hardness: 60,
  impactResistance: 65,
  cuttingResistance: 30,
  blastResistance: 45,
  compressionResistance: 80,
  fractureInto: "wood_debris",
  unsupportedInto: "wood_debris",

  // Thermal
  thermalConductivity: 25,
  heatCapacity: 90,
  ignitionTemperature: 300,
  autoIgnitionTemperature: 420,
  fuel: 220,
  burnRate: 14,
  burnInto: "charcoal",
  smokeInto: "smoke",
  meltTemperature: null,
  freezeTemperature: null,
  boilTemperature: null,

  // Liquid and solution behavior
  moistureCapacity: 220,
  absorptionRate: 18,
  solubility: {},
  acidResistance: 35,
  baseResistance: 85,
  oxidationResistance: 70,

  // Electrical and optical
  electricalConductivityDry: 4,
  electricalConductivityWet: 70,
  electricalCapacity: 10,
  opacity: 255,
  refraction: 0,
  reflectivity: 20,

  // Entity and presentation
  entityEffects: [],
  paletteRamp: "wood_warm",
  soundSet: "wood",
  residueMark: "splinter"
}
```

### Property scales

Most properties use deterministic integer tuning scales, not scientific units.

| Scale | Meaning |
| --- | --- |
| `0..255` | None through maximum normal material value |
| Integrity | Damage required to remove or transform one occupied unit |
| Hardness | Minimum tool, impact, or blast penetration class |
| Density | Relative displacement and liquid-layer ordering |
| Cohesion | Resistance to loose-flow separation and slope collapse |
| Viscosity | Resistance to liquid lateral movement |
| Conductivity | Fraction of heat or charge transferred per simulation step |
| Capacity | Amount of heat, charge, moisture, or solute retained |
| Temperature | Signed integer degrees Celsius for readable tuning; calculations remain fixed-point |
| Depth or amount | `0..255` fraction of the cell column |

## 5. Runtime cell state

A dense baseline representation should remain compact and serializable. Rare
mixture data may live in sparse side tables.

```js
{
  structureId,       // Uint16
  structureIntegrity,// Uint8
  looseId,           // Uint16
  looseAmount,       // Uint8
  liquidId,          // Uint16
  liquidAmount,      // Uint8
  gasId,             // Uint16
  gasAmount,         // Uint8
  coatingId,         // Uint16
  coatingAmount,     // Uint8
  temperature,       // Int16
  moisture,          // Uint8
  charge,            // Int16
  flags              // Uint16
}
```

Sparse records are created only when required:

- second immiscible liquid layer;
- up to three dissolved solutes;
- gas-mixture components in sealed or chemically active cells;
- catalyst or contamination records;
- structural support links;
- reaction cooldown and ownership metadata.

## 6. Solutions, mixtures, and concentrations

A separate material ID for every possible mixture would grow combinatorially.
Liquids therefore use a dominant solvent plus bounded composition slots.

```js
{
  solventId: "water",
  amount: 190,
  solutes: [
    { id: "salt", concentration: 48 },
    { id: "toxin", concentration: 12 }
  ],
  acidity: 4,
  oxidationPotential: 8
}
```

Rules:

1. A liquid cell supports one dominant solvent and at most three dissolved
   components.
2. Components below the trace threshold merge into a generic contaminant scalar.
3. Saturated solutes precipitate as loose material.
4. Miscible liquids combine according to registry rules.
5. Up to two immiscible liquid layers coexist and order by density.
6. A third immiscible layer displaces the smallest layer into a neighbor or
   converts it into a defined emulsion.
7. Concentration is conserved during flow, dilution, evaporation, and transfer
   within integer-rounding tolerances.
8. Competitive reactions use coarse, clearly communicated concentration bands:
   trace, weak, active, concentrated.

## 7. Game-chemistry axes

Curated material and reaction data use a small set of chemical axes rather than
attempting a complete periodic table.

| Axis | Purpose |
| --- | --- |
| Acidity / alkalinity | Neutralization, corrosion, cleansing, precipitation |
| Oxidizing / reducing potential | Rust, bleaching, combustion support, decay control |
| Solvent strength | Dissolution of organic, mineral, metallic, or magical matter |
| Fuel | Combustible energy available to Fire |
| Oxidizer | Ability to sustain or intensify combustion |
| Nutrient | Growth support for roots, grass, fungus, or bloom |
| Toxicity | Entity exposure and biological suppression |
| Salinity | Conductivity, freezing behavior, corrosion, growth suppression |
| Volatility | Evaporation and flammable-vapor production |
| Catalysis tags | Required accelerators such as Light, Charge, heat, crystal, or living tissue |
| Magical signature | Earth, Fire, Water, Wind, Ice, Charge, Light, Dark, and later approved families |

These values exist to generate stable tactical rules. They do not claim to be
real laboratory measurements.

## 8. Reaction definition schema

Reactions are registry entries indexed by reactant IDs, tags, phase, and trigger.
The engine must not scan every rule for every cell.

```js
{
  id: "water_lava_quench",
  version: 1,
  trigger: "contact",
  priority: 220,

  reactants: [
    { layer: "liquid", id: "water", amount: 24 },
    { layer: "liquid", id: "lava", amount: 16 }
  ],

  conditions: {
    minimumTemperature: 650,
    maximumTemperature: null,
    acidityRange: null,
    requiresTags: [],
    catalystTags: [],
    inhibitorTags: ["worldbone"]
  },

  rate: 16,
  maximumExecutionsPerCellStep: 2,
  products: [
    { layer: "structure", id: "basalt", amount: 12 },
    { layer: "gas", id: "steam", amount: 24 }
  ],

  heatDelta: -180,
  pressureImpulse: 18,
  ownership: "neutral",
  cue: "quench_burst",
  residue: "wet_basalt"
}
```

### Supported reaction classes

| Class | Example |
| --- | --- |
| Phase transition | Water freezes, ice melts, water boils, steam condenses |
| Contact conversion | Water and lava form basalt and steam |
| Dissolution | Salt dissolves into water; acid dissolves vulnerable mortar |
| Precipitation | Saturated brine dries and leaves salt |
| Neutralization | Acid and alkaline wash produce neutral solution, salt, and heat |
| Combustion | Wood, oil, resin, or gas consumes fuel and produces heat and residue |
| Corrosion | Water and oxygen rust iron; brine and Charge accelerate it |
| Thermal decomposition | Heated organic matter becomes charcoal, ash, smoke, or gas |
| Electrochemical | Charge moves through brine and metal; resistance produces heat |
| Catalytic | Light or crystal enables a reaction without being consumed |
| Biological | Wet soil supports roots; toxin or salt suppresses growth |
| Decay | Dark corruption converts living matter into plague growth or sludge |
| Mechanical transformation | Impact cracks brick; blast shatters glass; unsupported wall becomes rubble |
| Magical transmutation | Explicit whitelisted conversions driven by an approved elemental ability |

## 9. Thermal system

### Heat transfer

Temperature is stored per cell. Neighbor exchange uses fixed-point integer math:

```text
transfer = conductivityPair
         × temperatureDifference
         ÷ heatCapacityPair
         ÷ thermalStepDivisor
```

The transfer is clamped so one step cannot overshoot equilibrium. Material heat
capacity controls how quickly temperature changes; conductivity controls how
quickly heat spreads.

### Phase transitions

Each transition defines:

- threshold temperature;
- hysteresis band to stop rapid toggling;
- required energy or cooling debt;
- output material and amount ratio;
- dissolved-solute behavior;
- gas expansion or contraction;
- residue and visual cue.

Examples:

| Transition | Result |
| --- | --- |
| Water below freezing threshold | Ice; salt lowers the effective freezing threshold |
| Ice above melting threshold | Water and loss of brittle collision |
| Water above boiling threshold | Steam; dissolved solutes remain or precipitate |
| Steam on sufficiently cold surfaces | Water coating or liquid deposit |
| Sand under sustained extreme heat | Molten glass |
| Molten glass below solidification threshold | Glass, with thermal-shock brittleness |
| Lava after sufficient cooling | Basalt or stone depending on cooling rate |
| Metal under approved extreme heat | Molten metal; disabled in early competitive implementation unless a map explicitly uses it |

### Thermal shock

Brittle materials track recent temperature delta. Rapid heating or cooling can
convert stone, brick, glass, ceramic, or ice into cracked variants before final
breakage. This produces telegraphed staged destruction rather than instantaneous
removal.

## 10. Combustion system

Fire is an energy overlay coupled to material fuel, temperature, moisture, and
local oxidizer availability.

A combustion step requires:

1. fuel above zero;
2. temperature above flash or ignition threshold;
3. moisture below the suppression threshold;
4. oxidizer available from ambient air or a local gas mixture;
5. no extinguishing or inhibitor reaction winning at higher priority.

Combustion consumes fuel and oxidizer, adds heat, creates smoke or vapor, and
transforms the source material through authored stages.

```text
wood -> scorched wood -> charcoal -> ash
```

Important rules:

- Wet wood may steam and dry before sustained ignition.
- Oil film spreads Fire across connected surfaces and may float on water.
- Flammable gas produces a bounded pressure burst only after a visible ignition
  cue.
- Wind moves flame fronts and gases but does not create fuel.
- Fire never propagates through worldbone or across disallowed simulation zones.
- Open outdoor cells receive ambient oxidizer. Sealed authored gas zones may
  track oxygen explicitly.

## 11. Electricity and Charge

Charge is stored separately from matter so water, metal, wet wood, crystal, or
an entity can all carry electrical state.

### Conductive graph

At each electrical step:

1. Resolve conductive cells from material conductivity, moisture, dissolved
   salinity, coatings, and active fields.
2. Build or incrementally update connected conductive components in dirty chunks.
3. Inject authored source potential.
4. Propagate charge with material-dependent loss.
5. Apply resistive heating.
6. Telegraph overloaded cells before arcs or entity interruption.
7. Discharge through valid adjacent gaps or grounded endpoints.
8. Clear or retain charge according to capacity and leakage.

### Conductivity examples

| Material state | Conductivity |
| --- | --- |
| Dry wood | Very low |
| Wet wood | Medium |
| Fresh water | Medium |
| Brine | Very high |
| Copper | Maximum normal conductor |
| Iron or steel | High |
| Rusted iron | Reduced and resistive |
| Ice | Low to medium, depending on impurities |
| Prism crystal | Medium conductor with high storage capacity |
| Oil and dry glass | Insulating |

Charge may interrupt, reveal, activate devices, accelerate corrosion, ignite
suitable gas, or heat resistance points. It must not silently damage every cell
of a large water body on the same tick; danger propagates with a visible warning
front and bounded discharge timing.

## 12. Acids, bases, corrosion, and cleansing

### Acid and alkaline capacity

Liquids carry signed acidity and neutralization capacity. Contact consumes both
capacities. Neutralization may produce heat, salt, gas, precipitation, or a
neutral solution according to an explicit rule.

### Corrosion

Corrosion damage depends on:

```text
corrosion rate
× reactive concentration
× exposed surface
× material vulnerability
× catalyst multiplier
```

Catalysts may include heat, salinity, moisture, or electrical potential.
Worldbone always rejects the mutation before corrosion is evaluated.

### Readability and pacing

Acid is a slow topology-changing tool, not an invisible eraser. Vulnerable
structures discolor, hiss, lose integrity, crack, and create residue before
opening a route. Competitive acid volumes, lifetimes, and maximum affected cells
are mode-bounded.

## 13. Structural damage and support

Structural matter receives typed damage:

- cutting;
- impact;
- piercing;
- compression;
- blast;
- heat;
- cold shock;
- corrosion;
- decay;
- approved Chaos transmutation.

Damage first compares penetration class against hardness, then consumes integrity
using the relevant resistance. Materials may transition through damaged variants:

```text
brick -> cracked_brick -> rubble
wood -> splintered_wood -> wood_debris
iron -> bent_iron -> scrap
stone -> fractured_stone -> stone_rubble
glass -> cracked_glass -> glass_shards
```

### Bounded support model

FLUX does not need unrestricted rigid-body building collapse. Structural cells
use authored support classes:

- foundation-supported;
- wall-supported;
- beam-supported;
- self-supporting;
- hanging;
- temporary construct.

Dirty structural regions run a bounded connectivity check. Unsupported material
waits through a visible collapse warning, then converts into debris or falls to
an adjacent lower elevation. Large structures use authored break groups so the
result remains readable and performant.

## 14. Entity exposure and surface status

Entities sample the cells under their ground anchor, nearby gas concentration,
and attached coatings. Effects use thresholds and decay rather than one-frame
contact toggles.

| Status | Source | Principal effect |
| --- | --- | --- |
| Wet | Water, mist, wet coating | Raises conductivity, suppresses burning, supports freezing |
| Soaked | Sustained deep water | Stronger conductivity and longer dry time |
| Oily | Oil or resin coating | Increases ignition risk and flame persistence |
| Burning | Fire plus available fuel | Damage over time and heat emission; removable by water or sufficient cold |
| Chilled | Cold exposure | Reduced traction or recovery according to balance tuning |
| Frozen | Wet plus sufficient cold | Brief brittle control state with explicit breakout and immunity window |
| Conductive | Charge retained on wet or metallic equipment | Enables linked discharge and device interactions |
| Corroded | Acid or electrochemical exposure | Temporary armor or structure weakness, never permanent character-stat loss |
| Muddy | Mud depth or coating | Ground acceleration and braking penalty |
| Toxic | Sludge or toxic gas | Bounded damage or resource disruption with clear meter |
| Obscured | Smoke or steam concentration | Visibility reduction capped so silhouettes and threat outlines remain readable |
| Brittle | Thermal shock, Ice, or material-specific state | Increased structural fracture, not generic bonus character damage |

Statuses must include source ownership, duration, intensity, stack rule,
cleansing rule, immunity window, UI cue, and network serialization.

## 15. Element-to-chemistry contract

Elements inject energy, matter, or catalysts through the same material APIs.
They do not bypass worldbone, map safety masks, cell budgets, or reaction order.

| Element | Chemistry role |
| --- | --- |
| Earth | Creates approved mineral, metal, soil, sand, or growth matter; fractures or supports structures; never creates worldbone |
| Fire | Adds heat, ignition, drying, combustion pressure, and molten states |
| Water | Deposits liquid, Wet, pressure flow, dilution, cooling, cleansing, and solution transport |
| Wind | Adds directional advection for gas, flame, ash, loose light matter, surface water, and projectiles |
| Ice | Removes heat, freezes liquids, creates frost coating, and raises brittleness |
| Charge | Injects electrical potential, interrupts, activates devices, heats resistance, and drives electrochemical reactions |
| Light | Reveals, refracts, sterilizes selected toxins or Dark growth, and catalyzes approved photochemical reactions |
| Dark | Accelerates decay, corrupts biological matter, preserves toxins, and creates explicit plague materials |
| Spirit | Later: affects living or psyche-linked material only through approved catalyst rules; no topology erasure |
| Chaos | Later: whitelisted temporary transmutations with strict cell, duration, and collapse limits |
| Gravity | Later: changes effective weight or flow vector inside a field; never moves worldbone or critical anchors |
| Time | Later: changes reaction rate or expiry inside a field; never duplicates direct-hit damage or rewinds immutable topology |

## 16. Initial material catalog

The first production catalog should be broad enough to build distinctive maps
while remaining understandable.

### Immutable and mineral structures

| Material | Phase | Defining properties | Key reactions and role |
| --- | --- | --- | --- |
| Worldbone | Immutable | Infinite topology, no runtime state | Permanent map skeleton and critical foundations |
| Stone | Structural | Hard, heat-storing, weak conductor | Heavy blast fractures it; sustained heat creates heated stone or lava in approved maps |
| Basalt | Structural | Dense, heat-resistant, brittle under severe shock | Produced by rapid lava cooling; strong volcanic cover |
| Limestone | Structural | Medium hardness, acid-vulnerable | Slowly dissolves and may release gas; readable corrosion routes |
| Brick | Structural | Medium hardness, high heat capacity | Cracks from impact or thermal shock; standard destructible wall |
| Cracked brick | Structural | Low integrity, porous | Breaks into rubble and absorbs water |
| Mortar | Structural binder | Soft, porous, acid-sensitive | Saturation weakens joints and enables staged wall collapse |
| Clay | Loose or structural | Plastic when wet, hard when fired | Water forms workable clay; heat produces ceramic |
| Ceramic | Structural | Heat-resistant, brittle | Strong thermal use, poor impact resistance |
| Glass | Structural | Transparent, insulating, brittle | Blast and shock produce shards; extreme heat creates molten glass |
| Prism crystal | Structural crystal | Refractive, charge-storing | Splits Light, stores Charge, fractures into crystal debris |

### Metals and technical matter

| Material | Phase | Defining properties | Key reactions and role |
| --- | --- | --- | --- |
| Iron | Structural metal | Strong, conductive, oxidizable | Rusts with water and oxygen; acid and brine accelerate damage |
| Steel | Structural metal | Harder than iron, conductive | High-value gates and machinery; extreme heat softens it |
| Copper | Structural metal | Excellent conductor, softer | Electrical routing, devices, visible circuits |
| Bronze | Structural metal | Corrosion-resistant, medium conductor | Durable mechanisms and ancient machinery |
| Rusted iron | Brittle structural | Lower integrity and conductivity | Breaks into scrap and rust powder |
| Scrap metal | Loose heavy solid | Conductive, irregular | Explosion residue, salvage, partial obstruction |
| Rune alloy | Structural magical metal | Stores one approved elemental signature | Device and objective material with strict authored reactions |
| Molten metal | Heavy liquid | Extremely hot, conductive | Late-phase or authored hazard; cools into metal or slag |

### Organic and biological matter

| Material | Phase | Defining properties | Key reactions and role |
| --- | --- | --- | --- |
| Wood | Structural organic | Porous, cuttable, flammable | Absorbs water; burns through scorched and charcoal stages |
| Wood debris | Loose organic | Light, flammable | Wind-movable residue and secondary fuel |
| Charcoal | Loose or structural fuel | High fuel, low integrity | Burns hot and becomes ash |
| Grass | Biological coating | Fast growth and fast ignition | Spreads over wet nutrient soil; transmits fire |
| Roots | Biological structure | Grows through allowed soil, porous | Creates cover; burns, freezes, or corrupts |
| Moss | Biological coating | Retains moisture | Slows drying and supports growth, but carries Charge when wet |
| Cloth | Structural/coating | Absorbent, light, flammable | Banners, ropes, curtains, temporary fire paths |
| Resin | Viscous coating/liquid | Sticky, volatile | Bonds debris, slows movement, ignites into persistent fire |
| Bone or chitin | Brittle organic solid | Medium hardness, low conductivity | Breaks into fragments; Dark may animate or corrupt only through approved content |
| Bloom growth | Biological structure | Light- and water-responsive | Support terrain that can be cut, burned, salted, or cleansed |
| Plague growth | Corrupted biological | Toxic, Dark-supported | Spreads through nutrient matter; stopped by source destruction, Light, salt, or fire |

### Loose and granular matter

| Material | Phase | Defining properties | Key reactions and role |
| --- | --- | --- | --- |
| Soil | Loose | Nutrient, absorbent | Water creates mud; heat dries it; supports roots |
| Sand | Loose | Low cohesion, moderate density | Settles on slopes; extreme heat forms molten glass |
| Gravel | Loose | Heavy, noisy, high friction | Fills pits and forms unstable routes |
| Rubble | Loose/soft obstruction | Heavy, irregular | Created by masonry destruction; depth slows or blocks movement |
| Ash | Fine loose | Very light, absorbent | Wind carries it; water creates ash slurry |
| Salt | Soluble loose | High solubility | Creates brine, suppresses growth, precipitates after evaporation |
| Snow | Light loose | Cold, absorbent | Melts to water, compacts into ice, drifts under Wind |
| Coal | Loose fuel | High fuel, dirty combustion | Burns into heat, smoke, and ash |
| Crystal dust | Loose crystal | Refractive trace, charge-sensitive | Used in magical solutions and conductive residue |
| Volatile dust | Fictional loose reagent | Ignites only under explicit authored thresholds | Bounded explosive environmental setup without real-world formulation data |

### Liquids and slurries

| Material | Phase | Defining properties | Key reactions and role |
| --- | --- | --- | --- |
| Water | Liquid | Medium density, high heat capacity | Wet, cooling, freezing, boiling, dilution, Charge conduction |
| Brine | Liquid solution | Dense, highly conductive | Salt water; stronger corrosion and lower freezing point |
| Mud | Slurry | Dense, viscous, high friction | Soil plus water; dries, freezes, and slows grounded movement |
| Oil | Liquid | Light, immiscible, flammable | Floats on water, coats surfaces, creates spreading fire |
| Acid | Liquid solution | Corrosive, toxic | Slowly attacks vulnerable matter; neutralized by alkaline wash |
| Alkaline wash | Liquid solution | Cleansing, neutralizing | Reduces acid and selected toxins; may leave salts |
| Toxic sludge | Viscous liquid | Toxic, nutrient-corrupting | Water dilutes it; Fire produces toxic smoke; Dark preserves it |
| Sap | Viscous liquid | Nutrient, sticky, flammable | Supports growth, forms resin, attracts fire risk |
| Lava | Heavy hot liquid | Extreme heat, high viscosity | Ignites fuel; water creates basalt and steam |
| Molten glass | Heavy hot liquid | Very viscous, insulating | Cools into brittle glass; shock creates fragments |
| Healing spring | Magical solution | Cleansing, low toxicity | Support material with strict ownership and anti-stall limits |
| Void ichor | Magical liquid | Dark catalyst, toxic | Corrupts living matter but is neutralized by approved Light or cleansing reactions |

### Gases and transient matter

| Material | Phase | Defining properties | Key reactions and role |
| --- | --- | --- | --- |
| Steam | Gas | Hot, wet, medium diffusion | Condenses on cold surfaces and obscures within capped limits |
| Smoke | Gas | Light, opaque, irritating | Wind-driven combustion residue; disperses and stains surfaces |
| Toxic smoke | Gas | Toxic, medium diffusion | Produced from burning sludge or plague matter; mist helps remove it |
| Flammable gas | Gas | Volatile | Ignites after a visible cue and bounded pressure burst |
| Frost mist | Gas/coating | Cold, wet | Chills and deposits frost on nearby surfaces |
| Charged vapor | Gas/energy mixture | Conductive, short-lived | Creates visible arc paths and interruption zones |
| Spore cloud | Biological gas | Growth vector | Seeds only allowed nutrient cells; fire, Light, or filters remove it |
| Darkness haze | Magical gas/field | Concealing, decay catalyst | Must retain silhouette outlines and have explicit source and duration |

### Residues and derived materials

| Material | Created by | Purpose |
| --- | --- | --- |
| Heated stone | Stone plus sustained heat | Delayed ground hazard and thermal storage |
| Scorched wood | Partial combustion | Warning stage before structural loss |
| Charcoal | Wood pyrolysis | Secondary high-temperature fuel |
| Ash slurry | Ash plus water | Dark slippery residue that dries back to ash |
| Slag | Impure molten metal cooling | Heavy low-value obstruction |
| Glass shards | Glass fracture | Sharp debris and readable opened sightline |
| Rust powder | Advanced iron corrosion | Weak loose residue and color cue |
| Neutral solution | Acid-base neutralization | Safe or mildly saline liquid depending on products |
| Dirty water | Diluted toxin, ash, or soil | Reduced but nonzero hazard and visibility cue |
| Frozen mud | Mud plus strong cold | Brittle slow terrain that shatters into soil and ice |

## 17. Core reaction catalog

| Inputs | Conditions | Outputs | Tactical consequence |
| --- | --- | --- | --- |
| Wood + Fire | Dry enough and above ignition | Scorched wood, charcoal, ash, smoke | Cover degrades gradually and becomes secondary fuel |
| Wet wood + Fire | Moisture above suppression | Steam, drying, limited scorching | Water buys time rather than granting permanent immunity |
| Oil + Fire | Oil film above flash threshold | Burning oil, smoke | Flame travels across surfaces and floats on water |
| Flammable gas + Fire/Charge | Concentration and ignition cue complete | Pressure impulse, fire, smoke | Telegraphed environmental burst |
| Water + Fire | Sufficient water and heat capacity | Reduced fire, steam | Converts denial into temporary obscuration |
| Water + Ice/cold | Below transition threshold | Ice or frost | Creates slippery and brittle routes |
| Ice + heat | Above melt threshold | Water | Restores conductivity and removes brittle collision |
| Water + lava | Contact and temperature threshold | Basalt, steam, pressure impulse | Turns lethal liquid into new destructible terrain |
| Sand + extreme heat | Sustained energy | Molten glass | Creates a delayed construction material |
| Molten glass + cooling | Below solidification threshold | Glass | Forms brittle transparent cover |
| Heated glass/brick + rapid water or Ice | Thermal delta above shock threshold | Cracked material, shards or rubble | Opens routes through preparation and timing |
| Soil + water | Saturation reached | Mud | Converts neutral floor into slow terrain |
| Mud + heat/wind | Moisture falls below threshold | Soil or cracked clay | Route recovers gradually |
| Mud + strong cold | Below freezing threshold | Frozen mud | Hard brittle slow terrain |
| Salt + water | Solubility available | Brine | Creates a highly conductive, corrosive route |
| Brine + evaporation | Water amount falls | Concentrated brine, then salt precipitate | Conductive zone contracts visibly |
| Acid + alkaline wash | Capacities overlap | Neutral solution, salt, heat | Direct cleansing counterplay |
| Acid + limestone/mortar | Resistance check and concentration | Integrity loss, residue, possible gas | Slow visible route cutting |
| Water + iron + oxygen | Long exposure | Rusted iron | Persistent environmental aging |
| Brine + iron + Charge | Conductive contact | Accelerated corrosion, heat | Electrical routes trade power for structure damage |
| Copper/metal + Charge | Connected conductive graph | Propagated charge, resistive heat | Device circuits and linked hazard lanes |
| Water/brine + Charge | Connected wet cells | Warning front, delayed discharge | Large threatened region with reaction time |
| Roots + wet soil | Growth budget and allowed mask | New roots | Creates contestable organic cover |
| Roots/grass + Fire | Fuel and ignition | Charcoal, ash, smoke | Growth becomes a fire liability |
| Roots + Dark | Sustained corruption | Plague growth | Spreading hazard with cleanse and source counters |
| Plague growth + Light | Approved intensity and exposure | Sterile residue or normal roots | Light supports recovery without instant map reset |
| Toxic sludge + water | Dilution threshold | Weaker sludge or dirty water | Cleansing reduces rather than erases danger |
| Toxic sludge + Fire | High heat | Toxic smoke, residue | Punishes careless burning |
| Smoke/steam + Wind | Active vector | Advected gas | Wind changes sightline and hazard geometry |
| Snow/ash + Wind | Force above movement threshold | Drifted loose material | Makes wind direction visible in the environment |
| Prism crystal + Light | Beam contact | Refracted beam path | Geometric light routing |
| Prism crystal + Charge | Capacity available | Stored charge, delayed discharge | Breakable electrical capacitor |
| Heavy impact + brick/stone/glass | Penetration exceeds hardness | Cracks, rubble, shards | Destruction depends on attack class |
| Blast + loose material | Pressure impulse | Scattered debris and dust | Temporary visibility and route change |

## 18. Deterministic simulation order

The chemistry simulation runs at a fixed divisor of the main authoritative tick.
The initial target is 120 Hz actor simulation and 30 Hz material simulation.

Every material step executes in this order:

1. Validate content version, chunk order, and immutable-mask hash.
2. Apply queued external actions in stable command sequence order: deposits,
   impacts, cuts, blasts, heat, cold, Charge, and fields.
3. Apply structural integrity damage and mark support regions dirty.
4. Exchange heat and update reaction energy accumulators.
5. Resolve phase transitions with hysteresis.
6. Resolve high-priority contact, neutralization, and extinguishing reactions.
7. Resolve combustion and thermal decomposition.
8. Move liquids by hydraulic head, viscosity, permeability, and density.
9. Mix solutions, dissolve solutes, and precipitate saturation excess.
10. Settle powders, rubble, snow, and other loose matter by elevation and slope.
11. Diffuse and advect gases; apply bounded pressure impulses.
12. Rebuild dirty conductive components and propagate Charge.
13. Resolve electrochemical reactions and resistive heating.
14. Resolve corrosion, biological growth, decay, and catalysts.
15. Resolve support failure and schedule warned collapse for a later step.
16. Aggregate entity surface, coating, gas, and hazard exposure.
17. Rebuild dirty collision, navigation, visibility, and AI-cost masks.
18. Emit ordered events, chunk checksums, and compressed network deltas.
19. Put unchanged chunks to sleep after the stable-step threshold.

A reaction created in a later phase does not jump backward in the same step. It
becomes eligible in the next material step unless a rule explicitly defines an
immediate bounded secondary product. This prevents order-dependent reaction
loops.

## 19. Determinism and conflict resolution

- Use integers or fixed-point values only in authoritative material state.
- Never call `Math.random()` from material simulation.
- Probabilistic-looking behavior uses a stateless hash of map seed, material
  tick, cell coordinate, rule ID, and attempt index.
- Candidate reactions sort by priority, stable rule ID, and coordinate.
- Each cell may participate in a bounded number of reactions per step.
- Double-buffer movement phases or deterministic checkerboard partitions prevent
  two cells claiming the same destination.
- Alternating neighbor order derives from tick parity and seed, not wall-clock
  state.
- Budget exhaustion records a deterministic continuation cursor.
- Replay checksums cover all authoritative material arrays and sparse records.
- Content hashes are part of replay and network compatibility.

## 20. Chunking and performance budget

Recommended initial configuration:

| Setting | Initial target |
| --- | ---: |
| Cell size | 4 × 4 world units |
| Arena cells | 400 × 225 for a 1600 × 900 map |
| Chunk size | 16 × 16 cells |
| Maximum chunks | 25 × 15 = 375 |
| Material rate | 30 fixed steps per second |
| Maximum mobile moves | One primary move plus one bounded secondary spread per material step |
| Stable sleep threshold | 8 unchanged material steps |
| Initial active-cell budget | 12,000 processed cell-phase operations per material step, tuned from profiling |
| Gas cap | Authored per zone and globally bounded |
| Persistent residue cap | Coalesce equivalent neighboring residues before deleting meaningful state |

Authority may never reduce chemistry based on camera distance. Performance comes
from simulation zones, sleeping chunks, dirty masks, indexed reaction lookup,
coalesced residues, bounded products, and deterministic work carryover.

## 21. Collision, projectiles, and navigation

### Collision derivation

A single isolated solid pixel should not create an unreadable full wall. Collision
uses connected occupancy, depth, height, and authored thresholds.

| Condition | Derived result |
| --- | --- |
| Worldbone | Permanent full collision |
| Supported full-height structure | Solid actor and projectile blocker |
| Low supported structure | Ground blocker; vault or jump only when authored |
| Thin or damaged structure below occupancy threshold | Soft obstruction or projectile attenuation |
| Loose fill below shallow threshold | Surface modifier only |
| Deep rubble, snow, or sand | Increasing traversal cost; may become soft blocker |
| Liquid | Surface and depth effects, not ordinary collision |
| Ice sheet | Surface friction and optional low collision where sufficient depth freezes |
| Gas | No collision; visibility and exposure only |

### Projectile-material interaction

Projectiles declare:

- penetration class;
- material damage type;
- energy or damage budget;
- heat, cold, Charge, liquid, coating, or catalyst deposit;
- ricochet and refraction behavior;
- maximum affected cells;
- residue and ownership.

A projectile spends penetration energy while crossing occupied cells. Heavy
projectiles may pass through low-integrity material after reducing their remaining
energy; ordinary projectiles stop at stable full cover.

### AI queries

Bots read derived fields rather than raw materials:

- passable;
- movement cost;
- expected hazard over time;
- cover strength;
- visibility attenuation;
- conductivity risk;
- likely imminent reaction;
- destructible shortcut cost;
- reset-safe objective route.

## 22. Map authoring contract

Each reactive map should contain the following source layers:

```text
maps/<map-id>/
  worldbone-mask.png
  elevation.png
  structure-materials.png
  loose-materials.png
  liquid-seed.png
  coatings.png
  simulation-zones.png
  destruction-mask.png
  deposition-mask.png
  fluid-mask.png
  growth-mask.png
  objective-clearance.png
  spawn-clearance.png
  route-minimums.json
  reset-groups.json
  chemistry-overrides.json
  material-palette.json
```

### Safety masks

| Mask or rule | Purpose |
| --- | --- |
| Immutable mask | Permanent topology and foundations |
| Simulation zones | Only these chunks may awaken chemistry |
| Destruction allowed | Limits structural damage |
| Deposition allowed | Limits persistent player-created matter |
| Fluid allowed | Prevents flooding outside intended basins |
| Growth allowed | Bounds roots, bloom, fungus, and plague |
| Spawn clearance | Prevents persistent obstruction or hazard at spawn |
| Objective clearance | Preserves objective access and telegraph space |
| Route minimum | Guarantees at least one legal path or triggers authored repair |
| Maximum material depth | Prevents unbounded piles and floods |
| Reset group | Restores selected structures between rounds or on practice reset |
| Competitive lifetime override | Caps persistent ability-created matter without changing natural map material |

### Authoring validator

The map build must fail when:

- worldbone is missing around required outer bounds;
- a mutable source overlaps worldbone;
- a spawn or objective begins obstructed;
- route-minimum analysis finds no permanent path;
- a reaction can create an unbounded product chain;
- a material or reaction ID is unknown or version-incompatible;
- a simulation zone exceeds its allowed active-cell or gas budget;
- reset groups reference immutable or unowned cells;
- an authored liquid has no valid basin or depth cap;
- a hazard lacks visual, audio, timing, and cleanup metadata.

## 23. Networking, replay, reconnect, and host migration

The authoritative host or dedicated server owns all material state.

### Snapshot format

```js
{
  materialVersion,
  registryHash,
  mapBaseHash,
  materialTick,
  continuationCursor,
  changedChunks: [
    {
      chunkId,
      checksum,
      encoding: "rle-delta-v1",
      payload
    }
  ]
}
```

Rules:

1. Base map material and worldbone are referenced by hash.
2. Only changed mutable chunks are transmitted after initial synchronization.
3. Chunk payloads use run-length or palette-indexed deltas plus sparse mixture
   records.
4. Clients interpolate visual flow but do not predict authoritative reactions
   that affect collision, damage, or traversal.
5. Reconnect receives the base hash, full changed-chunk set, current material
   tick, and pending warned reactions.
6. Spectators receive the same authoritative state without command rights.
7. Replays store seed, content hashes, semantic commands, and authoritative
   exceptional events; deterministic resimulation verifies checksums.
8. Host migration includes a verified complete material snapshot and pending work
   cursor before authority transfers.
9. A checksum mismatch requests chunk repair; it never silently accepts divergent
   chemistry.

## 24. Presentation and readability

Every material needs compact palette ramps, edge rules, damage stages, and
state cues that fit FLUX’s three-quarter pixel perspective.

Required visible distinctions:

- dry, damp, wet, and flooded;
- cold, frozen, warm, hot, and molten;
- intact, stressed, cracked, and collapsing;
- uncharged, conducting, overloaded, and discharged;
- clean, contaminated, toxic, corrupted, and neutralized;
- inert fuel, smoldering, burning, and spent residue.

Danger priority is:

```text
objective and collision edge
> imminent reaction warning
> active hazard core
> champion and projectile silhouette
> persistent material state
> decorative texture
```

Smoke, steam, haze, darkness, vegetation, and debris may never fully remove
champion outlines, ownership marks, critical projectiles, objective edges, or
exit routes.

## 25. Debugging and editor tools

The development build should expose:

- material inspector under cursor;
- layer-by-layer cell view;
- temperature, moisture, charge, acidity, toxicity, and support overlays;
- active and sleeping chunk view;
- reaction candidate and winner trace;
- deterministic hash input and result;
- per-phase cell-operation counters;
- network chunk checksum comparison;
- pause and single material-step;
- seed, fill, drain, heat, cool, charge, wet, ignite, damage, and reset brushes;
- route-minimum and spawn/objective safety overlay;
- worldbone write-attempt log;
- replay checksum timeline.

Debug tools must use the same public mutation commands as gameplay or clearly mark
the state as non-authoritative.

## 26. Test strategy and invariants

### Unit tests

- Property defaulting and registry validation.
- Density and immiscible-liquid ordering.
- Hydraulic-head flow across elevation.
- Powder slope, cohesion, and support behavior.
- Heat exchange and phase hysteresis.
- Combustion fuel, moisture, and residue stages.
- Dissolution, dilution, saturation, and precipitation.
- Neutralization and corrosion resistance.
- Conductive-component propagation and resistive heating.
- Structural damage, support warnings, and rubble conversion.
- Status threshold, cleansing, and immunity windows.

### Determinism tests

- Same seed and actions produce byte-identical cell arrays.
- Different frame rates do not change material results.
- Chunk sleep and wake preserve results.
- Budget carryover produces the same final state as an unlimited reference step.
- Reordered network delivery cannot reorder authoritative commands.
- Replay checksums remain stable on Linux and Windows.

### Safety invariants

- Worldbone hash never changes.
- No mutable material exists outside allowed cells.
- No negative amount, invalid material ID, overflow, or non-finite state.
- Spawn and objective clearance remain valid or execute the authored repair rule.
- Persistent depth and active gases remain below map budgets.
- Reaction graph contains no zero-cost infinite production cycle.
- Every destructive reaction declares ownership, cell cap, and cleanup behavior.

### Network and soak tests

- Late join during active fire, flow, collapse, and Charge.
- Reconnect after chunk delta loss.
- Spectator consistency.
- Host migration with active chemistry.
- Eight-player ability spam in the maximum authored active region.
- One-hour seeded soak with checksum comparison and memory ceiling.
- Reset and rematch after maximum destruction.

### Gameplay acceptance

- Players can predict the next reaction from visible state.
- Reactions create choices rather than unavoidable damage.
- Destruction opens and closes routes without eliminating all valid paths.
- Material residue remains strategically relevant but does not accumulate into
  unreadable noise.
- Counters exist for every persistent hazard.
- Color-blind, high-contrast, reduced-motion, 720p, 1080p, 1440p, and narrow-window
  modes remain readable.

## 27. Implementation structure

Proposed runtime modules:

```text
src/materials/
  material-registry.mjs
  reaction-registry.mjs
  material-world.mjs
  material-chunks.mjs
  material-mutations.mjs
  step-external.mjs
  step-structure.mjs
  step-thermal.mjs
  step-phase.mjs
  step-reactions.mjs
  step-liquids.mjs
  step-solutions.mjs
  step-granular.mjs
  step-gases.mjs
  step-electric.mjs
  step-biology.mjs
  material-exposure.mjs
  material-collision.mjs
  material-navigation.mjs
  material-network.mjs
  material-replay.mjs
  material-render.mjs
  material-debug.mjs

tests/materials/
  registry.test.mjs
  flow.test.mjs
  thermal.test.mjs
  reactions.test.mjs
  electricity.test.mjs
  structure.test.mjs
  determinism.test.mjs
  network.test.mjs
  safety.test.mjs
  soak.test.mjs
```

A single orchestrator owns phase order. Individual phase modules may not call a
later or earlier phase directly.

## 28. Delivery sequence

Current Flux2 status: the F1 checkpoint implements the C0 registry/world-column
foundation and C1 worldbone/seed/reset safety foundation. C2 and later behavior
remains gated; static seeded Fire, steam, ice, liquids, Charge, and rubble are
storage/preview proof, not active reactions.

| Gate | Scope | Acceptance before advancing |
| ---: | --- | --- |
| C0 | Registry, schemas, IDs, fixed-point conventions, world-column model | Content validation and serialization round-trip |
| C1 | Worldbone, elevation, map import, masks, reset groups | Immutable hash and map-safety tests |
| C2 | Structural materials, typed damage, damaged stages, rubble, derived collision | Deterministic destruction and route validation |
| C3 | Heat, phase transitions, thermal shock, Fire and combustion | Wood, water, ice, brick, glass, smoke end-to-end |
| C4 | Hydraulic liquids, wetness, coatings, mud, oil | Elevation-aware flow and bounded flooding |
| C5 | Charge, conductive graphs, brine, metal, resistive heat | Telegraph, delayed discharge, reconnect consistency |
| C6 | Solutions, concentration, dissolution, precipitation, acid/base, corrosion | Conservation and readable acid counterplay |
| C7 | Gases, diffusion, Wind advection, sealed-zone oxidizer, pressure impulses | Visibility caps and gas budgets |
| C8 | Growth, roots, grass, plague, nutrients, toxin, Light cleansing | Growth masks and counter rules |
| C9 | Complete elemental integration through public material commands | No element bypasses safety or authority |
| C10 | Chunk deltas, replay, spectator, reconnect, host migration | Cross-platform deterministic network tests |
| C11 | Material editor, inspector, validators, profiling overlays | Author can build and diagnose a region without code changes |
| C12 | Living Sanctum Material Yard vertical slice | All core reactions playable in one resettable bounded area |
| C13 | One competitive map conversion | Eight-player stress, safety, readability, balance, package smoke |
| C14 | Regional material expansion and remaining maps | No duplicated special-case logic; full acceptance suite |

## 29. First playable vertical slice: Sanctum Material Yard

Build a resettable Material Yard inside the Living Sanctum before converting a
competitive arena.

| Station | Materials and proof |
| --- | --- |
| Permanent frame | Worldbone perimeter, foundations, and reset plinth |
| Masonry lane | Brick, mortar, cracked brick, rubble, impact, blast, saturation, acid |
| Timber lane | Wood, water, Fire, charcoal, ash, smoke, collapse warning |
| Flow basin | Elevation, water, mud, ice, steam, drainage and depth limits |
| Conductivity lane | Water, brine, copper, iron, Charge warning front and discharge |
| Thermal forge | Sand, glass, lava, basalt, thermal shock |
| Organic garden | Soil, water, grass, roots, salt, Fire, Dark corruption, Light cleansing |
| Gas chamber | Steam, smoke, toxic smoke, Wind, sealed-zone limit and visibility cap |
| Reset station | Restores all mutable cells from seed while worldbone hash remains identical |

Vertical-slice acceptance:

- Identical result from identical seed and actions.
- No worldbone mutation under any tool or reaction.
- All reactions remain inside the authored simulation zone.
- No station, spawn, or exit can be permanently blocked.
- Reset restores the initial mutable state exactly.
- Spectator and reconnect reconstruct active chemistry.
- High-contrast and reduced-motion cues remain complete.
- Material processing remains inside the profiled fixed budget.

## 30. Further proposals after the core system

These are later extensions, not initial requirements:

- Seasonal temperature and moisture profiles per map.
- Authored current fields, pumps, drains, sluices, gates, and pressure plates.
- Conductive devices, switches, relays, capacitors, and destructible circuits.
- Alchemical objectives based on safely producing or neutralizing a material.
- PvE creatures that consume, excrete, freeze, ignite, infect, or build materials.
- Material-carrying projectiles and bounded container breakage.
- Player tools for scooping, spraying, vacuuming, filtering, freezing, grounding,
  or compacting matter.
- Regional material ecologies such as tidal salt marsh, glass desert, fungal
  undercroft, volcanic forge, frozen aqueduct, plague garden, and storm archive.
- Reaction discovery codex that records observed inputs, conditions, products,
  counters, and tactical use without exposing hidden numeric internals.
- Destructible sound propagation, footprints, scent, and AI tracking derived from
  material state.
- Material-driven crafting only where it supports immediate arena decisions and
  does not create inventory grind.
- Offline sandbox rulesets with relaxed budgets and additional fictional
  substances, kept separate from competitive content hashes.

## Research basis

The design uses broad public lessons from these references while remaining an
original FLUX architecture:

- Noita official site and Falling Everything Engine overview:
  https://noitagame.com/
- Noita community material categories and properties:
  https://noita.wiki.gg/wiki/Material
- Noita community material information table:
  https://noita.wiki.gg/wiki/Material_Information_Table
- The Powder Toy, a sandbox combining elements, heat, pressure, gravity, and
  electronics:
  https://powdertoy.co.uk/
- Falling Turnip, a cellular-automata falling-sand implementation using local
  block rules:
  https://github.com/tranma/falling-turnip
- Devlin and Schuster, “Probabilistic Cellular Automata for Granular Media in
  Video Games”:
  https://arxiv.org/abs/2008.06341

The main adaptation is deliberate: side-view falling-sand behavior is translated
into a deterministic top-down elevation-column model suitable for FLUX movement,
collision, networking, map safety, and competitive readability.
