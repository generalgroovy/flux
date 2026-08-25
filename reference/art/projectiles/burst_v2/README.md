# Burst projectile visual reference v2

Reference-only visual package for FLUX's first delivery-shape slice.

## Contract

- Top-down / three-quarter 2.5D presentation.
- Simulation aim remains continuous; the eight rows are presentation orientation.
- Row order: `N, NE, E, SE, S, SW, W, NW`.
- Exact mirror symmetry is enforced:
  - `S = vertical mirror(N)`
  - `SW = horizontal mirror(SE)`
  - `W = horizontal mirror(E)`
  - `NW = horizontal mirror(NE)`
- Reference atlas: 16 columns x 8 rows, 64x64 cells.
- Runtime candidate: 16 columns x 8 rows, 32x32 cells.
- Projectile pivot is the cell center.
- Transparent RGBA, no caster, UI, labels, spell circles, or baked hitboxes.

## Columns / phases

| Columns | Phase | Use |
| --- | --- | --- |
| 0-1 | spawn | compact formation / release |
| 2-7 | travel | six-frame directional travel loop/reference |
| 8-11 | impact | contact expansion and breakup |
| 12-14 | residue | dissipating fragments/particles |
| 15 | reserved | intentionally blank for migration |

## Layering

`neutral` is the geometry/readability foundation. Fire, Water, Wind, Earth, Charge, Ice, Light and Dark are element-style references aligned to the identical grid. Runtime composition should preserve neutral delivery geometry and apply elemental presentation as a separate layer/variant. Element choice must not alter deterministic fan angles, projectile IDs, collision radius, or material reaction rules unless the authored ability explicitly changes simulation parameters.

## Burst simulation target

Initial test bundle: five projectiles at `-24, -12, 0, +12, +24` degrees around the true continuous aim vector. Spawn and ID ordering is left-to-right / negative-to-positive angle for deterministic replay. The atlas itself does not encode the fan.

## Quality status

These files are optimized references/runtime candidates derived from generated concept material. They are suitable for in-engine readability and timing tests, but remain replaceable until gameplay-zoom, accessibility, collision-clarity and performance acceptance is complete.

## Combined atlas layout

The committed reference material is stacked vertically in this order:

`neutral, fire, water, wind, earth, charge, ice, light, dark`

Each element occupies 8 directional rows. The 64 px reference atlas is `1024x4608`; the 32 px runtime candidate is `512x2304`. Use the JSON manifest to resolve row ranges. The helper script can split the combined atlas into per-element runtime sheets when needed.
