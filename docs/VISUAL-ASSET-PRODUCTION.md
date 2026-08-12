# FLUX 2 visual asset production v1

This checkpoint establishes a reproducible, importable visual foundation for the
complete currently specified roster, ancestry/body-plan catalog and Living
Sanctum district set. It does not falsely promote visual candidates into accepted
gameplay content. Champion, ancestry and district assets remain behind explicit
status labels until their simulation, accessibility, networking and platform
gates pass.

## Included assets

### Canonical character foundation

- five clean skeleton atlases and five debug-overlay atlases;
- 32×32 cells, pivot `(16, 28)`, eight directions and all 25 canonical states;
- one ZIP containing 125 singular animation PNG sheets;
- ground shadows, body-lift poses, shared feet baseline and diagnostic overlays;
- deterministic generation, independent validation and SHA-256 manifests.

### Ancestries and champions

- 23 ancestry/body-plan packages;
- clean atlas, debug atlas and attachment preview for every body plan;
- explicit candidate status for Weaverkin, Scorpionkin and Harvestkin;
- all 24 current champion visual slots;
- clean atlas, debug atlas, eight-direction preview, portrait and selection icon
  for every champion;
- distinct proportions, palettes, ancestry features, attachments and equipment;
- requested corrections for Oh Tipi, S. Wayne, Steezo, Spai Si, Haara and Nico Lai;
- Unnamed Angel remains `placeholder_unapproved`;
- all other champions remain `integrated_candidate` until promoted one at a time.

### Living Sanctum

- one 16×16 modular Sanctum tile atlas;
- nine 80×45 presentation-layout packages and 1280×720 previews:
  Nexus Court, Wayfarer Concourse, Movement Conservatory, Alchemical Proving
  Grounds, Living Archive, Verdant Recovery, Foundry Deep, Crown Observatory and
  Seasonal Expanse;
- district-specific silhouettes, landmarks and ordinary/advanced route concepts;
- a 960×720 district overview;
- the connected Nexus-to-Conservatory first-slice preview and layout.

All district files remain `presentation_only`. They do not replace authoritative
worldbone, elevation, collision, material, reset, navigation, LOS or safety data.

### Materials, elements, interactions and UI

- eleven foundation material tiles;
- icons for eight enabled elements, six foundation abilities and twelve common
  application states;
- eight element VFX families across startup, active, travel, impact, residue and
  reduced-motion phases;
- sixteen typed interaction-prop families across idle, focused, disabled,
  pending, active, success, failure and damaged states;
- a versioned Sanctum UI skin;
- roster and district review overviews;
- validated Godot loaders, headless suites and standalone gallery scenes.

## Generate and validate

From the repository root:

```bash
python tools/assets/generate_complete_visual_catalog_v1.py
python tools/assets/validate_visual_assets_v1.py
python tools/assets/validate_complete_visual_catalog_v1.py
scripts/test.sh
```

The complete generator invokes the foundation generator first. Generated runtime
files are intentionally committed. Running the generators must reproduce the
hashes in:

- `content/visual/visual_asset_hashes_v1.json`;
- `content/visual/complete_visual_hashes_v1.json`.

## Review in Godot

Launch the focused first-slice gallery:

```bash
"$FLUX2_GODOT" --path . res://scenes/presentation/visual_asset_gallery.tscn
```

Launch the complete catalog gallery:

```bash
"$FLUX2_GODOT" --path . res://scenes/presentation/complete_visual_gallery.tscn
```

When `FLUX2_GODOT` is not exported, use the Godot executable installed by
`scripts/install-godot.sh` as documented in `docs/DEVELOPMENT.md`.

## Runtime locations

| Category | Location |
| --- | --- |
| Skeleton atlases | `assets/sprites/skeletons/<size>/` |
| Singular animation archive | `assets/sprites/skeletons/skeleton_animation_pngs_v1.zip` |
| Ancestry/body plans | `assets/sprites/ancestries/<ancestry>/` |
| Champion packages | `assets/sprites/champions/<champion>/` |
| Roster overview | `assets/sprites/champions/roster_overview_v1.png` |
| Sanctum tile kit | `assets/tiles/sanctum/sanctum_tiles_v1.png` |
| District previews | `assets/maps/sanctum/districts/` |
| District layouts | `content/maps/districts/` |
| District overview | `assets/maps/sanctum/sanctum_district_overview_v1.png` |
| Foundation material tiles | `assets/tiles/materials/foundation_material_tiles_v1.png` |
| Element VFX | `assets/effects/element_vfx_v1.png` |
| World-interaction props | `assets/props/world_interaction_props_v1.png` |
| UI skin | `assets/ui/sanctum_ui_skin_v1.png` |
| Icons | `assets/icons/` |
| Foundation registry | `content/visual/visual_asset_registry_v1.json` |
| Complete catalog | `content/visual/complete_visual_catalog_v1.json` |
| Complete hashes | `content/visual/complete_visual_hashes_v1.json` |
| Foundation Godot loader | `src/presentation/visual_asset_registry.gd` |
| Complete Godot loader | `src/presentation/complete_visual_catalog.gd` |
| Foundation gallery | `scenes/presentation/visual_asset_gallery.tscn` |
| Complete gallery | `scenes/presentation/complete_visual_gallery.tscn` |

## Status language

- `production_foundation`: reusable, generated, validated infrastructure;
- `integrated_candidate`: complete visual package awaiting its full champion gate;
- `body_plan_candidate`: provisional ancestry package awaiting approval;
- `placeholder_unapproved`: retained only to preserve an explicitly unapproved slot;
- `presentation_only`: cannot define collision, chemistry, navigation or authority;
- `concept/reference`: excluded from runtime promotion.

## Visual constraints

- nearest-neighbor import and display;
- no subpixel filtering for pixel assets;
- stable character pivot and feet baseline;
- ground shadow separated from body lift;
- attachment pixels never silently enlarge hitboxes or reach;
- clear silhouettes at gameplay zoom;
- color never carries the only gameplay meaning;
- worldbone remains visually distinct from destructible stone;
- foreground art must use the shared LOS-safe cutaway contract before promotion;
- all generated assets are original deterministic pixel constructions;
- rendering remains downstream of authoritative simulation and content data.

## Remaining promotion work

The repository now contains usable files for every currently specified visual
slot, but production acceptance remains deliberately serial:

1. connect the character presentation scene to confirmed simulation animation events;
2. promote one champion at a time through selection, loadout, abilities, taunt,
   replay, spectator, accessibility, Linux and Windows acceptance;
3. convert one district at a time from presentation layout into reviewed
   topology, elevation, collision, material, reset, navigation and LOS layers;
4. refine contextual effects and UI in live gameplay rather than judging atlases
   in isolation;
5. preserve this branch as a draft until review explicitly approves promotion.
