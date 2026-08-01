# FLUX 2 visual direction

## Intent

FLUX 2 should feel like a living magical instrument: handcrafted, old, repaired,
and densely inhabited, yet precise enough for high-speed competitive movement.
The world combines warm masonry, dark wood, botanical overgrowth, aged brass,
deep water, and compact alchemical machinery. Magic is not generic bloom; it is
a controlled system of shapes, pulses, residue, and material change.

The generated [Sanctum visual target](../assets/concept/sanctum-hub-visual-direction-v1.png)
establishes atmosphere and district scale. It does not define final geometry,
camera metrics, tiles, protected routes, or authoritative chemistry cells.

## Visual pillars

1. **Handmade precision.** Crisp pixel clusters, deliberate ramps, restrained
   texture repetition, and readable silhouettes. Avoid smooth AI-painterly
   surfaces in shipped assets.
2. **Dense edges, clear lanes.** Detail lives in gardens, roof lines, machinery,
   water, and boundaries. Combat and movement corridors preserve clean values
   and identifiable collision edges.
3. **Material truth.** Stone, timber, metal, water, oil, frost, smoke, rubble,
   and immutable worldbone remain recognizable before effects are added.
4. **Magic has grammar.** Cyan indicates attunement and stable transit; violet
   indicates mode-space and dimensional energy. Every gameplay element also has
   a distinct shape, animation cadence, sound family, and residue.
5. **Places have silhouettes.** A district remains identifiable on the map with
   color removed: conservatory loops, archive towers, proving-ground basins,
   foundry cylinders, gardens, observatory domes, and portal rings.

## Foundation palette

| Role | Color | Use |
| --- | --- | --- |
| Deep water | `#153c4a` | void framing, canals, flooded layers |
| Forest shadow | `#17261b` | distant vegetation and deep recesses |
| Garden green | `#304b27` | playable grass and planted terraces |
| Moss highlight | `#66834a` | growth edges and soft traversal cues |
| Warm path | `#8b7045` | ordinary walkable masonry |
| Pale stone | `#b6a477` | primary route highlights and plazas |
| Worldbone | `#26282a` | immutable foundation and hard silhouette |
| Timber | `#4b3226` | buildings, rails, warm interiors |
| Aged brass | `#b88438` | machines, trims, important affordances |
| Attunement cyan | `#55dbe0` | stable portals, friendly energy, player |
| Flux violet | `#9b65d9` | mode-space, advanced magic, anomalies |
| Fire amber | `#e58a38` | heat, ignition, dangerous machinery |
| Parchment | `#e2d8b2` | high-value UI text and map drafting |

Final ramps require contrast tests in context. These hex values are coordination
anchors, not permission to flatten pixel art into solid fills.

## Camera, pixels, and density

- Establish one world-to-pixel unit and an integer camera zoom before producing
  final environment tiles.
- Nearest-neighbor sampling is mandatory for pixel assets. Subpixel simulation
  positions are preserved; presentation snaps or filters according to the
  approved camera policy rather than changing authority.
- Characters, projectiles, interactables, hazards, and pickups receive a quiet
  value field around their silhouette during combat.
- Decorations never obscure protected route edges, spawn safety, telegraphs, or
  chemistry state. Foliage and roof layers fade or cut away predictably.
- Effects budgets are per category and support reduced-motion and low-density
  modes without hiding authoritative events.

## Environment kit

The first original modular kit should cover:

- worldbone cliff/foundation masks with stone, root, and runic-metal skins;
- warm path, plaza, stair, ramp, bridge, low wall, full wall, vault edge, rail,
  gap, roof, doorway, canal, and shoreline modules;
- grass, garden, forest-edge, water, undercroft, foundry, archive, observatory,
  and portal-room overlays;
- destructible stone, brick, timber, glass, metal, vegetation, and chemistry
  vessels separated from immutable topology;
- standardized attunement shrine pieces visible at map, room, and interaction
  scales.

All modules require presentation art plus separate authored topology, elevation,
traversal, material seed, reset group, navigation hint, and safety metadata.

## HUD, menus, and the lobby

The Sanctum is the primary menu in spatial form, but common actions must also be
available through a fast, controller-friendly overlay. Spatial and overlay
flows invoke the same application commands; neither owns hidden game state.

UI uses compact dark timber/metal surfaces, aged-brass rules, parchment text,
and cyan focus. Panels should preserve world context where safe. Critical combat
HUD remains simpler and higher contrast than lobby furniture. Every interaction
has focus, disabled, pending, success, failure, and offline states.

## Acceptance gates

An asset or environment slice is not ready because it resembles the concept.
It must also pass silhouette/readability review at gameplay zoom, color-vision
and grayscale checks, collision/material alignment, reduced-effects review,
memory/import budgets, 60/120 Hz presentation smokes, Linux/Windows parity, and
originality/license provenance.
