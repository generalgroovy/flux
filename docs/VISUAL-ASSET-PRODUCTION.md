# FLUX 2 visual asset production v1

This checkpoint establishes a reproducible, importable visual foundation. It is
not a claim that the complete roster or all nine Sanctum districts are final.
New assets remain behind explicit candidate and presentation-only labels until
their gameplay slices pass full acceptance.

## Included assets

- five clean skeleton atlases and five debug-overlay atlases;
- 32×32 cells, pivot `(16, 28)`, eight directions and all 25 canonical states;
- one ZIP containing 125 singular animation PNG sheets;
- a deterministic generator and independent validator;
- an original Nico Lai integrated-candidate atlas using the Tiny/Gnome body plan;
- one 16×16 modular Sanctum tile atlas;
- one presentation-only 80×45 Nexus-to-Conservatory layout and 1280×720 preview;
- eleven foundation material tiles;
- icons for eight enabled elements, six foundation abilities and twelve common application states;
- a validated Godot registry, headless unit test and standalone gallery scene.

## Generate and validate

From the repository root:

```bash
python tools/assets/generate_visual_assets_v1.py
python tools/assets/validate_visual_assets_v1.py
scripts/test.sh
```

Generated runtime files are intentionally committed. Running the generator must
reproduce the hashes in `content/visual/visual_asset_hashes_v1.json`.

Launch the visual gallery with the repository-pinned Godot executable:

```bash
"$FLUX2_GODOT" --path . res://scenes/presentation/visual_asset_gallery.tscn
```

When `FLUX2_GODOT` is not exported, use the Godot executable installed by
`scripts/install-godot.sh` as documented in `docs/DEVELOPMENT.md`.

## Runtime locations

| Category | Location |
| --- | --- |
| Skeleton atlases | `assets/sprites/skeletons/<size>/` |
| Singular animation archive | `assets/sprites/skeletons/skeleton_animation_pngs_v1.zip` |
| Champion candidate | `assets/sprites/champions/nico_lai/` |
| Sanctum tile kit | `assets/tiles/sanctum/sanctum_tiles_v1.png` |
| Foundation material tiles | `assets/tiles/materials/foundation_material_tiles_v1.png` |
| Icons | `assets/icons/` |
| First visual layout | `content/maps/nexus_to_conservatory_visual_v1.json` |
| Visual registry | `content/visual/visual_asset_registry_v1.json` |
| Reproducibility hashes | `content/visual/visual_asset_hashes_v1.json` |
| Godot loader | `src/presentation/visual_asset_registry.gd` |
| Review gallery | `scenes/presentation/visual_asset_gallery.tscn` |

## Status language

- `production foundation`: reusable and validated infrastructure;
- `integrated candidate`: usable in-engine but awaiting its complete champion or district acceptance matrix;
- `presentation_only`: cannot define collision, chemistry, navigation or other authoritative outcomes;
- `concept/reference`: excluded from runtime promotion.

Nico Lai remains an integrated candidate. The map JSON and preview remain
presentation-only. They do not replace the authoritative worldbone, elevation,
collision, material, reset, traversal or route definitions required by G2.

## Visual constraints

- nearest-neighbor import and display;
- no subpixel filtering for pixel assets;
- stable character pivot and feet baseline;
- ground shadow separated from body lift;
- clear silhouettes at gameplay zoom;
- color never carries the only gameplay meaning;
- worldbone remains visually distinct from destructible stone;
- foreground art must use the shared LOS-safe cutaway contract before promotion;
- all generated assets are original deterministic pixel constructions.

## Next production slices

1. Connect character presentation to confirmed simulation animation events.
2. Convert the presentation layout into authored topology/elevation/material layers and modular Godot map chunks.
3. Complete Nico Lai through selection, loadout, ability cues, taunt, replay, spectator, accessibility and platform acceptance.
4. Expand the tile kit only as required by the accepted G2 route.
5. Promote one additional champion or district at a time from a green branch.
