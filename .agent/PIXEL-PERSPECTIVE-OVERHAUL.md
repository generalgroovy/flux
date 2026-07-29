# FLUX pixel-perspective overhaul

## Intent and reference boundary

This is the first task after the 2026-07-29 visual references. Translate their
broad qualities into an original FLUX presentation: compact pixel silhouettes,
an inviting three-quarter top-down world, readable tiled terrain and elevation,
clear elemental accents, and economical interface text. Do not reproduce any
reference character, costume, prop, terrain tile, building, map layout, font,
HUD, icon, animation, palette, symbol, or trade dress.

The supplied FLUX roster board is a style target for **proportion and visual
density**, not shipping sprite art or roster authority. Its labels, ancestries,
affinities, equipment, and individual designs do not override the current
README/visual-overhaul roster. The supplied adventure screenshots are
perspective/readability references only. Every runtime asset remains original,
repository-authored, and mechanically honest.

## Projection contract

| Concern | Required FLUX rule |
| --- | --- |
| Camera | Fixed orthographic three-quarter top-down view; never true isometric and never perspective-scaled by screen depth |
| Simulation | Existing authoritative X/Y coordinates, collision radii, aim, projectile paths, and fixed ticks remain unchanged |
| Ground anchor | A champion's feet/shadow center is the authoritative X/Y position; the body may render above it but never moves the hitbox |
| Elevation | Cliffs, stairs, ledges, roofs, bridges, and walls use visible top/front/side faces and occlusion layers; traversability still comes only from authored collision data |
| Pixel grid | World art snaps to an integer virtual-pixel grid and uses nearest-neighbour scaling; fractional camera transforms may not blur silhouettes |
| Read order | Walkable ground -> blockers/elevation -> objectives/hazards -> champions -> spells -> critical HUD; decoration never outranks a threat |

## Visual grammar

| Layer | Original FLUX treatment | Acceptance evidence |
| --- | --- | --- |
| Champions | Compact large-head/short-body pixel silhouettes, ancestry-specific anatomy, one dominant prop, readable feet/facing, practical clothing, dark selective outline | Nico reads as Gnome/engineer at gameplay zoom in idle, move, commit, hit, defend, defeat, and four cardinal facings |
| Maps | Modular grass, worn earth, old stone, timber, water, roots, mud, cliff faces, stairs, rails, and bridges with small cluster variation | Sanctum reads as a navigable place without labels; floor, blocker, elevation, station, route, and exit are distinct in grayscale |
| Elements | Shape-first small pixel motifs: forks, droplets, shards, wedges, stones, rings, rays, void cuts; glow is a restrained secondary edge | Every active element reads without hue and never merges with its caster or terrain |
| Spells | Pixel-stepped anticipation, discrete travel/area silhouette, compact impact burst, short residue, explicit owner/team edge | Primary lanes stay parseable with eight agents and dense scenery |
| Text | Original bitmap-like face or pixel-snapped system fallback; short labels, high x-height, limited sizes, no imitation of reference fonts | Controls and decisions remain readable at 720p, 1080p, 1440p, narrow window, and high contrast |
| Interface | Dark ink/wood/stone panels with parchment highlights used sparingly; icons always pair with text or shape | HUD does not cover navigation space and every keyboard/controller focus state is obvious |

## Palette and material limits

- Use compact per-material ramps with a shared warm light and cool mineral
  shadow; avoid unrestricted gradients, bloom, glass panels, and modern neon.
- Reserve the brightest values for actionable focus, spell cores, damage/guard
  confirmation, and critical resources—not decorative borders.
- Team ownership uses outline/ground marks independent from affinity color.
- Use texture clusters and edge pixels rather than noise. Repeated tiles need
  bounded variants that cannot alter collision or conceal telegraphs.
- Auras remain sparse around the silhouette and never become full-body fog.

## Ordered delivery slices

| Slice | Outcome | Must remain unchanged |
| ---: | --- | --- |
| P0 | Central virtual-pixel, projection, palette, material, outline, and layering tokens plus one non-shipping perspective specimen | Simulation, maps, roster, controls, and networking |
| P1 | Living Sanctum terrain/elevation renderer with original tiles, occlusion, and readable station landmarks | Sanctum geometry, station triggers, spawn, remote company, and movement |
| P2 | Nico runtime sprite proof with cardinal facing, six combat states, ground anchor, team mark, damage wear, and elemental motifs | Stable `volt` ID, hitbox, stats, kit, commands, and authority |
| P3 | One complete spell/element readability pass for Nico's live Charge/Light kit | Ability timing, range, damage, costs, cooldowns, and reactions |
| P4 | HUD, field guide, prompts, and text converted to the restrained pixel/manuscript system | Information, focus order, shortcuts, accessibility, and remapping |
| P5 | Integrated desktop/narrow/high-contrast/reduced-motion/eight-agent acceptance and Windows/Linux source/package smoke | All game rules |

## Slice status

| Slice | State | Evidence / next boundary |
| ---: | --- | --- |
| P0 | Accepted 2026-07-29 | `src/pixel-perspective.mjs` centralizes the 384x216 virtual canvas, feet anchor, projection/layer order, seven-value ladder, and four-value material/Charge/Light ramps; the non-shipping specimen passed desktop, 480px narrow, grayscale, high-contrast, and reduced-motion browser review with no console warnings or errors, and its focused tests pass |
| P1 | Accepted 2026-07-29 | The live Sanctum now uses the accepted materials and stepped layers for water boundary, grass, routes, courts, mirror ward, collision rails, station plinths, and a distinct Rite Gate; desktop and reloaded 480px browser review passed without warnings/errors while map data and rules remained unchanged |
| P2 | Active | Convert Nico's live renderer to compact cardinal pixel reads with a feet-ground anchor, team mark, damage wear, six states, and restrained Charge/Light motifs without changing his hitbox, stats, kit, or commands |
| P3-P5 | Pending | Begin only after the preceding slice is implemented, visually reviewed, tested, and recorded |

Do not start Steezo or another champion until P0-P5 are accepted. A complete
foundation prevents every later character/map/spell from being rebuilt twice.

## Definition of visual acceptance

Acceptance requires captured gameplay evidence, not tests alone: exact virtual
pixel scaling with no blur, clear foreground/background separation, no copied
reference content, no collision/presentation disagreement, no label dependency
for Sanctum navigation, readable Nico facing and state, shape-first Charge/Light
spells, keyboard/controller prompts, reduced motion, high contrast, and stable
presentation under eight-agent stress. Run focused tests, `npm test`, recursive
syntax checks, Windows/Linux packaging, and an actual affected-screen smoke.
