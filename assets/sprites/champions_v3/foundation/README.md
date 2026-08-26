# Foundation body atlas provenance

This is the current body-only production candidate for the Windows runtime.
The source and runtime PNG are repository-local generated assets, not copied
from a game or web reference. The runtime atlas is deliberately kept separate
from spells, elements, auras, shadows, environment, tools and equipment so
each layer can be edited or replaced without redrawing the character body.

## Generation record

- Generator: built-in ImageGen followed by `scripts/build_foundation_champion_sprites.py`.
- Source: `source_sheet_body_v3.png`, 1536×1024, two rows × six cells, flat matte.
- Runtime: `runtime_atlas_body_v3.png`, 672×192, 96×96 cells, pivot `(48,84)`.
- Rows: Oh Tipi, S. Wayne.
- Columns: south/front idle, east profile, north/back, front jump, front empty-hand cast preparation, front hit/recovery; runtime west mirrors east.
- Exact hashes and import policy: `provenance.json`.

## Final image-generation prompt

```text
Use case: precise-object-edit
Asset type: reusable body-only source sheet for a 2D top-down cartoon pixel-action game
Input image: Image 1 is the edit target. Preserve its exact 1536x1024 canvas, two rows, six evenly spaced cells per row, champion identities, clothes, compact proportions, pixel-art treatment, and flat magenta matte.
Primary request: Make every champion sprite contain body and clothing only. Remove every magical or environmental pixel: water ribbons, droplets, ice shards, lightning, sparks, smoke, glow, portals, rings, dark flames, particles, auras, shadows, props, staffs, tridents, wands, rods, weapons, and detached or held foci. Reconstruct clean hands and clothing where effects were removed.
Pose grammar by column for both rows: 1) SOUTH/FRONT idle facing directly toward the camera, face and torso centered, balanced symmetrical feet and arms, hands equally open at the sides; 2) EAST/right movement profile; 3) NORTH/back view centered; 4) FRONT jump pose centered; 5) FRONT bare-hand cast-preparation pose with both empty hands visibly open and balanced, but absolutely no magic/effect; 6) FRONT hit/recovery pose with empty hands and no effect. The runtime will mirror EAST to create WEST.
Invariants: First row remains Oh Tipi, second row remains S. Wayne. Keep faces, fin crown/hair, ancestry silhouettes, outfits and colors consistent across all cells. The front-facing face must look directly at camera and read symmetrically. Keep all figures isolated with generous empty matte between cells.
Avoid: any spell, element, projectile, portal, particle, aura, glow, detached orb, environment, shadow, ground mark, text, UI, label, weapon, staff, wand or asymmetrical front idle.
```

Human visual acceptance is still required before this candidate is promoted to
final art; validation proves structure, provenance, importability and separation
only.
