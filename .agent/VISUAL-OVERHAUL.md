# FLUX visual-first overhaul contract

## Direction

The user cited **The Legend of Zelda** only as a broad reference for inviting
top-down heroic fantasy, immediate silhouettes, handcrafted natural spaces,
warm adventure atmosphere, and an interface that feels like part of the world.
FLUX must remain unmistakably original. Do not reproduce or closely imitate
Nintendo characters, costumes, creatures, symbols, typography, heart meters,
item icons, menus, maps, compositions, animation, audio, assets, or trade dress.

Translate the reference into FLUX's own language:

| Principle | Original FLUX expression |
| --- | --- |
| Heroic fantasy warmth | Parchment light, mineral shadows, forest/tide accents, ember highlights |
| Instant silhouette | Compact champion shapes with race anatomy, role posture, and one readable focus prop |
| Handcrafted world | Carved runes, woven banners, old stone, roots, mud, water, and regional heraldry |
| Readable magic | Geometric elemental cores, restrained aura edges, explicit tells, clean impact residue |
| Diegetic interface | Illuminated-manuscript frames, stamped tabs, ink labels, carved selection markers |
| Playful adventure | Expressive poses and environmental charm without visual noise or comedy overriding danger |

No visual may encode hidden mechanical information, change hitboxes, conceal
telegraphs, reduce contrast, or grant an affinity an automatic readability
advantage. Color is always paired with shape, motion, value, or a mark.

## Mechanical freeze

Until every visual phase below is accepted, do not add or rebalance movement,
damage, resources, abilities, elements, reactions, races, modes, objectives,
network rules, AI behavior, maps, hazards, or progression. A visual slice may
touch rendering, presentation-only content metadata, CSS, canvas drawing,
assets, animation timing that does not affect simulation, accessibility,
documentation, and visual regression tests. If a presentation change exposes a
mechanical defect, record it in the backlog rather than fixing it in this pass.

## Required order

| Gate | Scope | Completion evidence before advancing |
| ---: | --- | --- |
| V0 | Visual tokens and reference specimen | Original palette/value/outline/material/motion rules are centralized; one non-shipping specimen proves scale and contrast without changing gameplay |
| V1 | Characters | Every shipped champion reads by race, role, facing, health state, and element at gameplay zoom; approved future characters receive concepts only and remain inactive |
| V2 | Spells | Every shipped primary/tactical/defense/mobility/ultimate family has distinct anticipation, travel/area, impact, ownership, and expiry reads under color-blind settings |
| V3 | Maps | Every shipped arena has original regional materials, landmarks, route hierarchy, cover/hazard contrast, spawn/objective readability, and dense-fight clarity |
| V4 | GUI | Menu, Muster Hall, HUD, guide, settings, lobby, pause, results, and tutorial use one restrained manuscript/adventure system with keyboard/gamepad focus and no clipped decisions |
| V5 | Integrated acceptance | Full match, First Rite, every shortcut, compact/narrow layouts, 8-player stress, Windows/Linux source launch, package smoke, and visual/accessibility review pass |

Within V1 through V4, finish one complete production slice at a time. Do not
scatter placeholder restyles across the category. Preserve stable IDs and
existing gameplay behavior throughout.

## Category acceptance

| Category | Required checks |
| --- | --- |
| Characters | Idle/move/commit/hit/defend/defeat silhouettes; ancestry anatomy; aura restraint; opponent/team distinction; no sexualized presentation |
| Spells | Shape before color; caster ownership; threat direction; timing phase; cover interaction; hit confirmation; no aura/projectile blending |
| Maps | Route value hierarchy; walkable/blocked edges; hazard/objective/spawn priority; regional identity; zoom and narrow-window readability |
| GUI | Minimum readable text; focus/hover/pressed/disabled states; full labels; stable layout; reduced motion; high contrast; color-blind redundancy |

## Iteration rule

At the start of each local-agent run, read this file, determine the first
incomplete visual gate, and select exactly one complete slice inside it. State
the unchanged gameplay boundary and visual acceptance checks in the audit.
Capture before/after evidence when the environment supports screenshots; never
claim a visual review that did not occur. Run focused tests, the full suite,
shell checks, and a real local smoke for any changed screen.
