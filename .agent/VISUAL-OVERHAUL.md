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

## V1 planned ancestry distribution

This is the authoritative visual-concept distribution for the approved
twenty-three-champion overhaul roster. It supersedes older concept tables that
show The Red Baron as Undead, Fluup as Orc, Spai Si as Elf, or Donnok as Dwarf.
The four reassigned champions keep their stable character IDs, affinities,
kits, balance values, and implementation status. Runtime `raceId` values remain
unchanged until V1 character concepts are accepted and a separately tested
mechanical migration is authorized.

| Champion | Planned ancestry | Visual role read |
| --- | --- | --- |
| Oh Tipi | Seakin | Compact tide skirmisher with cheek fins and a trident line |
| S. Wayne | Hobbit | Low eclipse tactician with bare feet and a split mantle |
| The Red Baron | **Vampire** | Aristocratic air controller with a high collar, fangs, and rigid crimson wedges |
| Steezo | Goblin | Small volatile engineer with a tool rig and sparking pack |
| Treevor the Mason | Treefolk | Huge terrain mason with a branch crown and mud-block mass |
| Oll' I | Minotaur | Broad horned breaker with a locked charge posture |
| Fluup | **Werewolf** | Heavy storm bruiser with a wolf muzzle, mane, and weighted landing stance |
| Wa Bidi | Goblin | Fast battlecry route specialist with large ears and wind-swept gear |
| Grace Reava | Sylph | Light streamer-wing duelist with practical layered travel clothes |
| Nico Lai | Gnome | Tiny precision engineer with a high cap and calibrated coil pack |
| Spai Si | **Angel** | Narrow redirect duelist with feathered wings, a simple halo mark, and poised aim lines |
| Leaf the Hidden | Treefolk | Large concealed support with a layered leaf mantle and growth rings |
| Ha Rekt | Wyrmborn | Anthropomorphic rime hunter with scaled wings and an aerial attack posture |
| Dr. Apex | Stoneborn | Large armored medic with square stone shoulders and a triage focus |
| Haara | Nymph | Small bloom planner with a petal mantle and restrained pollen motes |
| Hesus Christo | Wyrmborn | Huge anthropomorphic renewal vanguard with heavy scaled wings |
| Grimm Bow | Troll | Large terrain archer with moss horns and an inward-drawn bow stance |
| Biggy Bob | Dwarf | Broad forge breacher with brown hair, a brown beard, and a masonry hammer |
| Jan Wicked | Human | Medium black-ice hunter whose identity comes from gear and stance, not anatomy |
| Ba Djoh | Minotaur | Huge three-current breaker with broad horns and a wet hoof trail |
| Urzh | Stoneborn | Large kiln bulwark with ember seams in a squared stone frame |
| Donnok | **Demon** | Compact chthonic forge shaper with swept horns, an ember tail, and steam-worn wraps |
| Djonah Thaan | Undead | Medium pursuit controller with rune ribs and a deathly wake |

The new ancestry silhouettes are presentation concepts only in V1: Vampires
use high collars, fangs, and controlled posture; Werewolves use muzzles, manes,
and forward weight; Angels use feathered wings and a plain geometric halo;
Demons use swept horns, an ember tail, and grounded chthonic materials. Avoid
sexualized anatomy, religious caricature, copied fantasy iconography, and aura
shapes that obscure attacks or body boundaries.

| Ancestry | Champions | Count |
| --- | --- | ---: |
| Human | Jan Wicked | 1 |
| Dwarf | Biggy Bob | 1 |
| Gnome | Nico Lai | 1 |
| Hobbit | S. Wayne | 1 |
| Elf | — | 0 |
| Orc | — | 0 |
| Troll | Grimm Bow | 1 |
| Minotaur | Oll' I; Ba Djoh | 2 |
| Seakin | Oh Tipi | 1 |
| Wyrmborn | Ha Rekt; Hesus Christo | 2 |
| Stoneborn | Dr. Apex; Urzh | 2 |
| Treefolk | Treevor the Mason; Leaf the Hidden | 2 |
| Sylph | Grace Reava | 1 |
| Undead | Djonah Thaan | 1 |
| Goblin | Steezo; Wa Bidi | 2 |
| Nymph | Haara | 1 |
| **Vampire** | The Red Baron | 1 |
| **Werewolf** | Fluup | 1 |
| **Angel** | Spai Si | 1 |
| **Demon** | Donnok | 1 |

Elf and Orc remain valid ancestry foundations but deliberately have no champion
in this roster. Do not distort a champion solely to achieve one-per-ancestry
coverage; add a future champion only when its play and visual promise are
distinct.

## Iteration rule

At the start of each local-agent run, read this file, determine the first
incomplete visual gate, and select exactly one complete slice inside it. State
the unchanged gameplay boundary and visual acceptance checks in the audit.
Capture before/after evidence when the environment supports screenshots; never
claim a visual review that did not occur. Run focused tests, the full suite,
shell checks, and a real local smoke for any changed screen.
