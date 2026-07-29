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

## 2026-07-29 reference-priority override

The latest user direction inserts two repository-wide tasks ahead of further
champion production:

| Priority | Contract | State |
| ---: | --- | --- |
| 1 | `.agent/PIXEL-PERSPECTIVE-OVERHAUL.md` P0-P5: original three-quarter top-down pixel perspective across characters, Sanctum/maps, spells/elements, text, and interface | P0-P2 accepted; P3 Nico Charge/Light spells active |
| 2 | `.agent/MOVEMENT-INPUT-OVERHAUL.md` M0-M5: conventional remappable keyboard/controller layout, stronger jump/shadow read, revalidation of advanced movement, then bounded tap-strafe/aerial turn | Blocked by P5 acceptance |
| 3 | Resume V1 champion production with Steezo | Blocked by M5 acceptance |

The reference images provide proportion, perspective, pixel-density, terrain
layering, and readability principles only. Do not copy their sprites, tiles,
maps, layouts, fonts, HUD, icons, palettes, animation, or trade dress. The new
pixel renderer remains a presentation layer over the current authoritative X/Y
simulation and stable gameplay identifiers.

## Mechanical freeze

Until every visual phase below is accepted, do not add or rebalance movement,
damage, resources, abilities, elements, reactions, races, modes, objectives,
network rules, AI behavior, maps, hazards, or progression. A visual slice may
touch rendering, presentation-only content metadata, CSS, canvas drawing,
assets, animation timing that does not affect simulation, accessibility,
documentation, and visual regression tests. If a presentation change exposes a
mechanical defect, record it in the backlog rather than fixing it in this pass.

The user's 2026-07-29 direct movement request authorizes one bounded exception:
complete the already specified universal Stamina grammar through double jump,
slide jump, air redirect, air dodge, wavedash, marked-cover vault, and
vault-crest superglide, including controls, Sanctum teaching, deterministic
tests, and collision-safe authored rails. This exception does not authorize new
champion abilities, elements, damage, objectives, networking, AI, or modes;
after its acceptance, priority returns to V1.

That exception is complete. The later direct reference request authorizes the
separate M0-M5 input/movement pass only after P0-P5 visual acceptance. Until
then, no movement mechanics or bindings change. M0-M5 may add the specified
bounded tap-strafe/aerial turn, but it may not add free speed, reproduce an
engine exploit, or weaken fixed-tick/server/collision ownership.

## Required order

| Gate | Scope | Completion evidence before advancing |
| ---: | --- | --- |
| V0 | Visual tokens and reference specimen | Original palette/value/outline/material/motion rules are centralized; one non-shipping specimen proves scale and contrast without changing gameplay |
| V1 | Characters | Every approved overhaul champion concept reads by ancestry, role, facing, health state, and element at gameplay zoom; approved future characters receive concepts only and remain inactive while shipped sources await safe retirement |
| V2 | Spells | Every shipped primary/tactical/defense/mobility/ultimate family has distinct anticipation, travel/area, impact, ownership, and expiry reads under color-blind settings |
| V3 | Maps | Every shipped arena has original regional materials, landmarks, route hierarchy, cover/hazard contrast, spawn/objective readability, and dense-fight clarity |
| V4 | GUI | Menu, Muster Hall, HUD, guide, settings, lobby, pause, results, and tutorial use one restrained manuscript/adventure system with keyboard/gamepad focus and no clipped decisions |
| V5 | Integrated acceptance | Full match, First Rite, every shortcut, compact/narrow layouts, 8-player stress, Windows/Linux source launch, package smoke, and visual/accessibility review pass |

## Gate status

| Gate | Status | Evidence / next decision |
| ---: | --- | --- |
| V0 | Accepted | Central tokens live in `styles.css`; the source-only specimen passed desktop and narrow review; the user's continuation authorized V1 |
| V1 | Paused by reference-priority override | Spai Si, Urzh, and S. Wayne are reviewed source specimens; Nico Lai passed desktop specimen and live Windows Sanctum review and is the first promoted visual/runtime replacement; Steezo resumes only after P0-P5 and M0-M5 |
| V2–V3, V5 | Blocked by order | Do not begin until the preceding visual gate is accepted |
| V4 | Foundation plus complete movement court by direct request | Players spawn directly on the Living Sanctum floor; eight proximity stations own all option routes, preserve resumable local/remote contests, and expose movement teaching, marked vault rails, character switching, refill/reset, and a field guide; Muster adds ancestry-column portrait selection with independent non-mutating hover/focus previews; full GUI acceptance remains blocked until V1–V3 complete |

Within V1 through V4, finish one complete production slice at a time. Do not
scatter placeholder restyles across the category. Preserve stable IDs and
existing gameplay behavior throughout.

### Modular ancestry templates

`src/ancestry-visual-templates.mjs` is the V1 ancestry foundation registry.
Each of the twenty entries owns only body geometry, anatomy feature hooks,
material, and motion read. Champion profiles separately compose role posture,
focus prop, affinities, palette, state effects, health wear, and team ownership.
This permits several champions to share one ancestry without becoming palette
swaps or sharing gameplay data.

To introduce or revise an ancestry visually:

1. edit one registry entry or add one body/feature recipe;
2. compose a champion profile with `ancestryId` rather than copying anatomy;
3. review all foundations at `tools/ancestry-template-specimen.html` and the
   champion's six-state specimen;
4. run `tests/overhaul-character-visuals.test.mjs` and the full suite.

Templates are presentation-only. They may not encode hitboxes, statistics,
affinity advantages, abilities, runtime race migration, or hidden tells. The
2026-07-29 user-authorized Nico promotion keeps its runtime mechanics and stable
`volt` ID separate from the visual profile while centralized champion stats
remain simulation-owned content.

## Category acceptance

| Category | Required checks |
| --- | --- |
| Characters | Idle/move/commit/hit/defend/defeat silhouettes; ancestry anatomy; aura restraint; opponent/team distinction; no sexualized presentation |
| Spells | Shape before color; caster ownership; threat direction; timing phase; cover interaction; hit confirmation; no aura/projectile blending |
| Maps | Route value hierarchy; walkable/blocked edges; hazard/objective/spawn priority; regional identity; zoom and narrow-window readability |
| GUI | Minimum readable text; focus/hover/pressed/disabled states; full labels; stable layout; reduced motion; high contrast; color-blind redundancy |

## V1 planned ancestry distribution

This is the authoritative visual-concept distribution for the approved
twenty-three named champions plus one explicitly temporary Angel placeholder.
It supersedes older concept tables that show different assignments. Reassigned
champions keep their stable character IDs, affinities, kits, balance values,
and implementation status. Runtime `raceId` values remain unchanged until V1
character concepts are accepted and a separately tested mechanical migration
is authorized. The Angel placeholder has no gameplay ID, kit, lore, or runtime
record and must be replaced or removed before V1 acceptance.

| Champion | Planned ancestry | Visual role read |
| --- | --- | --- |
| Oh Tipi | Seakin | Compact tide skirmisher with cheek fins and a trident line |
| S. Wayne | Hobbit | Low eclipse tactician with bare feet and a split mantle |
| The Red Baron | Undead | Air controller with rune ribs, an officer mantle, and rigid crimson wedges |
| Steezo | Goblin | Small volatile engineer with a tool rig and sparking pack |
| Treevor the Mason | Treefolk | Huge terrain mason with a branch crown and mud-block mass |
| Oll' I | **Werewolf** | Heavy breaker with a wolf muzzle, mane, and a locked forward posture |
| Fluup | Orc | Heavy storm bruiser with tusks and a weighted landing stance |
| Wa Bidi | Goblin | Fast battlecry route specialist with large ears and wind-swept gear |
| Grace Reava | Sylph | Light streamer-wing duelist with practical layered travel clothes |
| Nico Lai | Gnome | Tiny precision engineer with a high cap and calibrated coil pack |
| Spai Si | **Demon** | Narrow redirect duelist with swept horns, an ember tail, and poised aim lines |
| Leaf the Hidden | Treefolk | Large concealed support with a layered leaf mantle and growth rings |
| Ha Rekt | Wyrmborn | Anthropomorphic rime hunter with scaled wings and an aerial attack posture |
| Dr. Apex | Stoneborn | Large armored medic with square stone shoulders and a triage focus |
| Haara | Nymph | Small bloom planner with a petal mantle and restrained pollen motes |
| Hesus Christo | **Elf** | Tall renewal vanguard with long ears, a grounded mantle, and deliberate posture |
| Grimm Bow | Troll | Large terrain archer with moss horns and an inward-drawn bow stance |
| Biggy Bob | Dwarf | Broad forge breacher with brown hair, a brown beard, and a masonry hammer |
| Jan Wicked | Human | Medium black-ice hunter whose identity comes from gear and stance, not anatomy |
| Ba Djoh | Minotaur | Huge three-current breaker with broad horns and a wet hoof trail |
| Urzh | Stoneborn | Large kiln bulwark with ember seams in a squared stone frame |
| Donnok | Dwarf | Compact forge shaper with a square silhouette and steam-worn wraps |
| Djonah Thaan | **Vampire** | Medium pursuit controller with a high collar, fangs, and a deathly wake |
| Unnamed Angel (placeholder) | **Angel** | Temporary feather-wing and plain-halo silhouette slot; no approved character identity yet |

The new ancestry silhouettes are presentation concepts only in V1: Vampires
use high collars, fangs, and controlled posture; Werewolves use muzzles, manes,
and forward weight; Angels use feathered wings and a plain geometric halo;
Demons use swept horns, an ember tail, and grounded chthonic materials. Avoid
sexualized anatomy, religious caricature, copied fantasy iconography, and aura
shapes that obscure attacks or body boundaries.

| Ancestry | Champions | Count |
| --- | --- | ---: |
| Human | Jan Wicked | 1 |
| Dwarf | Biggy Bob; Donnok | 2 |
| Gnome | Nico Lai | 1 |
| Hobbit | S. Wayne | 1 |
| Elf | Hesus Christo | 1 |
| Orc | Fluup | 1 |
| Troll | Grimm Bow | 1 |
| Minotaur | Ba Djoh | 1 |
| Seakin | Oh Tipi | 1 |
| Wyrmborn | Ha Rekt | 1 |
| Stoneborn | Dr. Apex; Urzh | 2 |
| Treefolk | Treevor the Mason; Leaf the Hidden | 2 |
| Sylph | Grace Reava | 1 |
| Undead | The Red Baron | 1 |
| Goblin | Steezo; Wa Bidi | 2 |
| Nymph | Haara | 1 |
| **Vampire** | Djonah Thaan | 1 |
| **Werewolf** | Oll' I | 1 |
| **Angel** | Unnamed placeholder | 1 |
| **Demon** | Spai Si | 1 |

All twenty ancestry foundations now have a visual representative, but the Angel
slot is intentionally not a character approval. Do not invent its permanent
name, lore, kit, or mechanics merely to convert coverage into fake completion.

## Legacy concept retirement

The ten shipped champions are compatibility scaffolding, not members of the
overhaul roster. Remove each only after its successor is complete and the same
commit proves launch, selection, authority, tests, and migration safety.

| Shipped source | Overhaul successor | Concept retained |
| --- | --- | --- |
| Aerwyn | Spai Si | Redirect timing, forward posture, Wind-angle guides |
| Gorum | Urzh | Brace discipline, lane anchor, squared stone mass |
| Vellyn | S. Wayne | Intent division, decoy spacing, visible swap boundary |
| Nim Copperspark | Nico Lai | Charge sequencing, interrupts, calibrated devices |
| Serek Ashborn | Steezo | Route traps, bounded detonation, backblast recovery |
| Morcant | Djonah Thaan | Ground denial, pursuit pressure, silence cue |
| Neris Pearldive | Grace Reava | Current redirection, brief protection, Tide rhythm |
| Branna Runesight | Biggy Bob | Sightline control, focus tool, forge-prism geometry |
| Yrsa Rimewing | Ha Rekt | Aerial cold-line hunt, marked escape, committed landing |
| Varka Ashmaw | Treevor the Mason | Terrain shaping, Fire liability, crown climax |

`src/overhaul-character-visuals.mjs` is the tested source of truth for this
retirement ledger. Nico Lai is the first explicit exception promoted into the
live renderer by direct user request; every other entry remains source-only
until separately reviewed and promoted without adding champion branches to the
shared renderer.

## Iteration rule

At the start of each local-agent run, read this file, determine the first
incomplete priority contract and select exactly one complete slice inside it.
P0 is now the first incomplete slice; do not select Steezo yet. State
the unchanged gameplay boundary and visual acceptance checks in the audit.
Capture before/after evidence when the environment supports screenshots; never
claim a visual review that did not occur. Run focused tests, the full suite,
shell checks, and a real local smoke for any changed screen.
