# Visual Gate V0 baseline — 2026-08-13

Source commit: `e996610`. Captures: Windows source, Godot 4.7.1, AMD OpenGL,
fixed 60 Hz, full view, 1280x720 and 1920x1080, camera 50/75/100%.

| Category | Baseline /5 | Evidence |
| --- | ---: | --- |
| Cohesion | 2 | The limited palette is consistent, but schematic buildings, tiny sprite, station labels and debug HUD do not form one finished visual language. |
| Silhouette | 1 | The local champion occupies too few pixels at 75%; equipment, face, ancestry and animation state disappear. |
| Material identity | 2 | Water/grass/path/roof families differ by color, but most surfaces read as flat polygons rather than stone, timber, brass, water and growth. |
| World overview | 3 | Wider zoom exposes useful routes and stations, but long labels, flat value fields and ambiguous building height weaken navigation hierarchy. |
| HUD clarity | 2 | Exact resources/spells are readable, but the 148px top stack dominates 720p and duplicates controls/help better suited to contextual overlays. |
| Animation response | 2 | Jump shadow and semantic states exist; the tiny character and minimal effect language hide most response. |
| Spell readability | 2 | Shapes now differ functionally, but effects and HUD cells lack one coherent element silhouette/cadence system. |

Baseline mean: **2.0/5**. This is not visual acceptance.

V0 adds an expandable, validated runtime vocabulary and live diagnostic
specimen. The current V0 specimen is evidence that the vocabulary loads and
renders, not evidence that the game has passed V1–V6. Human review remains
mandatory at every production promotion.
