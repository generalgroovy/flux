# Material registry and grid foundation

## Implemented scope

Checkpoint F1 implements reactive-material gates C0 and C1 without pretending
that reactions already exist:

- a versioned canonical catalog with eleven occupancy materials and independent
  amount, temperature, wetness, Charge, and elevation fields;
- stable positive material wire IDs and SHA-256 content hashes;
- a validated Sanctum Material Yard definition authored as compact,
  non-overlapping rectangles and expanded into exactly 128 x 128 cells;
- packed integer columns rather than one Godot node or dictionary per cell;
- a complete worldbone perimeter and internal reset plinth with a separately
  verifiable immutable hash;
- a deterministic deduplicated awake queue processed in ascending cell order
  under a real-time work budget compiled for 60 or 120 Hz;
- guarded runtime writes, exact seed reset, canonical full-state hashing, and a
  read-only one-texture debug preview in the playable Sanctum.

Content sources:

- [`foundation_materials_v1.json`](../content/materials/foundation_materials_v1.json)
- [`sanctum_material_yard_v1.json`](../content/maps/sanctum_material_yard_v1.json)

## Cell storage

Each of the 16,384 cells owns parallel packed integer values:

| Column | Meaning |
| --- | --- |
| Material wire ID | Current occupancy material; `empty` is an explicit stable ID |
| Amount | Scale-1000 occupancy quantity |
| Temperature | Signed authored milli-temperature used by later thermal gates |
| Wetness | Scale-1000 independent coating/exposure field |
| Charge | Scale-1000 independent energy field, allowing charged water/metal later |
| Elevation | Signed authored height/head input for later collision and flow |
| Worldbone mask | Immutable topology membership |
| Awake mask/queue | Deduplicated deterministic pending work |

Charge is deliberately not an occupancy material: water, metal, a device, or a
fighter exposure may carry Charge without losing its material identity. The
grid stores no float and does not depend on camera visibility or rendering.

## Safety and determinism

The definition fails closed on unknown or duplicate IDs/wires, missing cell
fields, wrong dimensions, invalid chunks or work budgets, overlapping/out-of-
bounds seed rectangles, missing required sample materials, invalid quantities,
or any incomplete worldbone edge.

Runtime writes cannot change a worldbone cell or create new worldbone. Mutable
writes validate ID, amount, temperature, wetness, and Charge, then enter the
deduplicated awake queue. Queue insertion history is discarded by canonical
ascending processing. The authored 30,720-cells/second ceiling compiles to 512
cells/tick at 60 Hz and 256 cells/tick at 120 Hz; unused whole-tick capacity is
not banked into an unbounded burst.

Reset copies the immutable seed columns, clears pending work/remainders/errors,
and reproduces the exact original state and worldbone hashes. Presentation
reads these arrays into one 128 x 128 texture and cannot mutate them.

## Deliberate limitations and next gate

F1 imports static examples of empty, worldbone, stone, brick, wood, water, oil,
fire, steam, ice, rubble, Charge, and elevation. It does not yet flow liquids,
transfer heat, burn, freeze, fracture, collapse, conduct, derive collision, or
replicate deltas. F2 must introduce the single material phase orchestrator,
typed structural damage/damaged stages/rubble, then thermal/Fire/steam/ice rules
with conservation, fixed work, reset, replay, collision, and presentation tests.
