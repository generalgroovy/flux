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

The generated [gameplay-scale v3 specimen](../assets/concept/wellspring-gameplay-specimen-v3.png)
narrows that atmosphere into an actual play view: larger expressive champions,
moderately tilted facades over unambiguous top-down floors, dense scenic edges,
clean movement lanes, readable material families, translucent bubbles and a
compact three-resource/layered-spell HUD. Its immutable provenance is stored beside
it. It remains a specification target—not a shippable sprite sheet, tile set,
HUD atlas, collision source or acceptance proof.

The user-passed
[champion board](../assets/concept/flux-champions-visual-style-v1.png) is the
mandatory minimum character-style target: compact expressive bodies, strong
ancestry silhouettes, readable equipment/materials, and immediately legible
elemental personality. Its labels are not gameplay authority and its pixels are
not runtime frames.

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
6. **Perspective never steals information.** A foreground roof, wall, canopy,
   construct, or high ledge fades/cuts away or yields to a restrained ownership
   silhouette when it covers a character inside authoritative LOS. No such cue
   appears for an actor outside permitted LOS.

Broad environmental study may include strongly staged room silhouettes,
layered depth, landmark-first composition, dramatic readable lighting,
responsive ambience, dense scenic edges, and clear combat floors seen in
polished isometric action games. FLUX 2 does not copy Hades/Hades II rooms,
assets, layouts, camera metrics, palettes, props, characters, UI, effects,
symbols, animation, or trade dress.

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
- Basic jumps present an original compact body lift above a stable ground
  anchor. A separate shadow remains on the receiving surface, grows broader and
  darker during ascent, is largest at the apex, contracts during descent, and
  settles on a crisp landing. Space is the production default jump key. The
  same normalized authoritative phase drives presentation at 60 and 120 Hz.
  This studies only the readability of classic handheld
  top-down adventure jumps and copies no sprite, frames, timing, sound, input,
  item, or map behavior.
- Effects budgets are per category and support reduced-motion and low-density
  modes without hiding authoritative events.

### Compact handheld readability target

FLUX may study the broad production discipline of Game Boy Color-era top-down
adventure graphics, including the compact tiles, economical color ramps,
character-to-environment scale and immediate landmark silhouettes associated
with *The Legend of Zelda: Oracle of Ages* and *Oracle of Seasons*. The target is
that level of clarity, not those games' content. FLUX must use original sprites,
tiles, maps, palettes, characters, props, symbols, animation, UI and trade dress.

Generated or user-passed character boards are concept references only. The
passed eighteen-champion board sets the minimum visual bar and may help review
compact body proportions,
directional separation and equipment cues, but they are not approved runtime
sprite sheets and cannot set hitboxes, animation timing or final scale. Any
future promotion requires local provenance, immutable hashes, declared grid,
frame and pivot metadata, animation alignment, and gameplay-zoom accessibility
and performance evidence shared with the environment kit.

Every pictured champion requires a complete original in-game sprite set. The
current runtime-addressable direction atlases and 25-action skeleton contract
are integration foundations, not final animation acceptance. Each champion must
pass idle, movement, jump/rise/fall/land, traversal, combat, defense/damage,
interaction, defeat, and signature/fallback taunt coverage applicable to its
kit, with deterministic semantic event binding and no animation-owned outcomes.

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
