# FLUX2 visual iteration v3

The user-supplied champion roster is the minimum expected visual baseline. The
procedural v2 catalog remains a technical integration scaffold and must not be
presented as accepted final art.

## Pipeline

| Phase | Operation | Gate |
|---|---|---|
| Reference | Commit baseline and canonical briefs | Provenance and naming valid |
| Concept | Generate multiple edited candidates from the baseline | Structural score and contact sheet |
| Visual review | Compare expression, silhouette, material and charm | Every rubric item ≥4; mean ≥4.5 |
| Animation | Generate one animation/direction sheet at a time | Every keyframe reviewed |
| Extraction | Remove background and split exact grid | Pivot, alpha and clipping valid |
| Integration | Pack runtime frames and update catalog | Godot import and playback green |
| Promotion | Replace candidate status | Explicit visual acceptance only |

The dependency-free `SpriteSheetExtractor` is the structural gate between
reviewed sheets and file-producing tooling. It requires an exact grid and exact
frame count, transparent nonempty cells with an unclipped border, then uses
nearest-neighbor scaling to place every frame in a 96×96 cell at the shared
bottom-center `(48, 92)` presentation pivot without mutating the caller image.
Its in-memory manifest records the decoded RGBA source hash, source/content
bounds and deterministic normalized PNG hashes while remaining
`presentation_only` and `runtime_approved: false`. The quarantined 1254×1254 Oh
Tipi study deliberately fails this gate; extraction cannot silently floor cell
dimensions, discard edge pixels, write candidate frames, or promote art.

## Inventory

### Champions

| Champion | Race | Gold standard | Status |
|---|---|---:|---|
| Oh Tipi | seakin | yes | not_started |
| S. Wayne | human | no | not_started |
| The Red Baron | undead | no | not_started |
| Steezo | goblin | no | not_started |
| Treevor the Mason | treefolk | no | not_started |
| Oll' I | minotaur | no | not_started |
| Fluup | orc | no | not_started |
| Wa Bidi | sylph | no | not_started |
| Grace Reava | nymph | no | not_started |
| Nico Lai | gnome | yes | not_started |
| Spai Si | elf | no | not_started |
| Leaf the Hidden | treefolk | no | not_started |
| Ha Rekt | wyrmborn | no | not_started |
| Dr. Apex | stoneborn | no | not_started |
| Haara | gnome | no | not_started |
| Hesus Christo | wyrmborn | no | not_started |
| Grimm Bow | troll | yes | not_started |
| Biggy Bob | dwarf | no | not_started |
| Jan Wicked | human | no | not_started |
| Ba Djoh | minotaur | no | not_started |
| Urzh | orc | no | not_started |
| Donnok | dwarf | no | not_started |
| Djonah Thaan | human | no | not_started |
| Unnamed Angel | angel | no | not_started |

### Races

| Race | Sizes | Presentations | Status |
|---|---:|---:|---|
| Human | 5 | 2 | not_started |
| Dwarf | 5 | 2 | not_started |
| Gnome | 5 | 2 | not_started |
| Hobbit | 5 | 2 | not_started |
| Elf | 5 | 2 | not_started |
| Orc | 5 | 2 | not_started |
| Troll | 5 | 2 | not_started |
| Minotaur | 5 | 2 | not_started |
| Seakin | 5 | 2 | not_started |
| Wyrmborn | 5 | 2 | not_started |
| Stoneborn | 5 | 2 | not_started |
| Treefolk | 5 | 2 | not_started |
| Sylph | 5 | 2 | not_started |
| Undead | 5 | 2 | not_started |
| Goblin | 5 | 2 | not_started |
| Nymph | 5 | 2 | not_started |
| Arachnoid | 5 | 2 | not_started |
| Vampire | 5 | 2 | not_started |
| Demon | 5 | 2 | not_started |
| Angel | 5 | 2 | not_started |
| Werewolf | 5 | 2 | not_started |

### Wellspring locations

| Location | Function | Landmark | Gold standard | Status |
|---|---|---|---:|---|
| Source Court | arrival, onboarding and attunement | Cosmic Wellspring: an eight-current Flux waterfall descending into a sacred basin | yes | not_started |
| Farflow Concourse | host, join, teams and travel | Farflow Gates | no | not_started |
| Movement Gardens | movement training and traversal | Momentum Arbor | yes | not_started |
| Elemental Proving Grounds | aim, bots, destruction and chemistry | Eightfold Basins | no | not_started |
| Living Archive | codex, lore, replays and analytics | Oracular Dome | no | not_started |
| Restoration Grove | recovery and low-pressure interaction | Heartroot Garden | no | not_started |
| Deep Foundry | fabrication and transmutation | Flux Crucible | no | not_started |
| Starward Crown | settings, accessibility and diagnostics | Twin Astrolabes | no | not_started |
| Seasonal Reaches | events and private trials | Fourfold Orrery | no | not_started |

## Reference implementation concepts

The external `blendi-remade/sprite-sheet-creator` project demonstrates a useful
generation flow: a character reference is passed to an image-edit model, each
animation is generated as a compact grid, Bria removes the background, frames are
extracted with content bounds, and previews expose alignment problems. FLUX2 v3
uses those workflow ideas but adds canonical manifests, explicit call budgets,
five generated directions plus mirrored counterparts, 25 animation contracts,
96×96 runtime cells, per-item status, structural quality checks and fail-closed
promotion.

## Commands

```bash
cd tools/visual_ai
npm install --no-audit --no-fund
npm run validate
FAL_KEY=... FLUX_VISUAL_MAX_CALLS=10 \
  node src/cli.mjs run-slice --slice gold_standard_concepts --attempts 2
```
