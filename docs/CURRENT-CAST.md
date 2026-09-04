# FLUX current cast contract

Status: **canonical identity/roster plan**. The availability column and live
champion catalog distinguish playable entries from gated concepts/placeholders.

![Hands-only current cast concept board](../assets/concept/current-cast-hands-only-v1.png)

The board is an original concept reference in the exact row-major order below;
the table remains authoritative because generated concept pixels do not define
names, ancestry, abilities, hitboxes, selection state, or gameplay timing. All
magic originates at open hands. Staffs, wands, scepters, rods, and held magical
foci are excluded from current and future champion recipes. Champion body
atlases contain body and clothing only; hands, spells, auras, shadows,
equipment and environment are separate composited layers.

| # | Champion | Ancestry | Body type | Weighted affinities | Current availability |
| ---: | --- | --- | --- | --- | --- |
| 1 | Oh Tipi | Seakin | Middle | Water 2 · Charge 1 | Playable foundation champion |
| 2 | S. Wayne | Hobbit | Small | Dark 2 · Light 1 | Playable foundation champion |
| 3 | The Red Baron | Undead | Large | Fire 2 · Ice 1 | Playable anchor; Cinderbolt + Rimewake |
| 4 | Steezo | Goblin | Small | Charge 1 · Fire 1 · Light 1 | Planned; kit not implemented |
| 5 | Treevor the Mason | Treefolk | Large | Earth 1 · Wind 1 · Fire 1 | Planned; kit not implemented |
| 6 | Oll' I | Werewolf | Large | Earth 1 · Fire 1 · Light 1 | Planned; kit not implemented |
| 7 | Fluup | Orc | Large | Wind 1 · Charge 1 · Ice 1 | Planned; kit not implemented |
| 8 | Wa Bidi | Goblin | Small | Charge 1 · Wind 1 · Fire 1 | Planned; kit not implemented |
| 9 | Grace Reava | Sylph | Small | Wind 1 · Water 1 · Light 1 | Planned; kit not implemented |
| 10 | Waka Aren Si | Gnome | Small | Charge 2 · Light 1 | Planned; `nico_lai` remains a compatibility ID only |
| 11 | Spai Si | Demon | Middle | Wind 1 · Earth 1 · Light 1 | Planned; kit not implemented |
| 12 | Leaf the Hidden | Treefolk | Middle | Water 1 · Earth 1 · Light 1 | Planned; kit not implemented |
| 13 | Ha Rekt | Wyrmborn | Large | Ice 1 · Wind 1 · Fire 1 | Planned; kit not implemented |
| 14 | Dr. Apex | Stoneborn | Large | Earth 1 · Light 1 · Water 1 | Planned; kit not implemented |
| 15 | Haara | Nymph | Small | Light 2 · Wind 1 | Planned; kit not implemented |
| 16 | Hesus Christo | Elf | Middle | Earth 2 · Water 1 | Planned; kit not implemented |
| 17 | Grimm Bow | Troll | Large | Earth 2 · Water 1; Chaos reserved | Planned; kit not implemented |
| 18 | Biggy Bob | Dwarf | Middle | Earth 1 · Fire 1 · Light 1 | Planned; kit not implemented |
| 19 | Jan Wicked | Human | Middle | Ice 1 · Dark 1 · Charge 1 | Planned; kit not implemented |
| 20 | Ba Djoh | Minotaur | Large | Earth 1 · Fire 1 · Water 1 | Planned; kit not implemented |
| 21 | Urzh | Stoneborn | Large | Earth 1 · Fire 1 · Charge 1 | Planned; kit not implemented |
| 22 | Don Doko Don | Dwarf | Middle | Earth 1 · Fire 1 · Water 1 | Planned; `donnok` remains a compatibility ID |
| 23 | Djonah Thaan | Vampire | Middle | Dark 1 · Charge 1 · Fire 1 | Planned; kit not implemented |
| 24 | Unnamed Angel | Angel | Middle | Light 2 · Wind 1 | Non-selectable identity placeholder |

The board is for silhouette and ancestry coordination, not runtime promotion.
The validated [roster manifest](../content/champions/champion_roster_plan_v1.json)
now owns identity, ancestry, body role and availability. Both legacy visual
catalog adapters resolve this metadata and the linked affinity catalog; their
original fields remain under `archive_*` and assets are explicitly marked
`legacy_visual_archive`. Correct labels do not certify old pixels as current
art. Stable technical IDs and paths remain intact until atomic migration.
A champion becomes playable only after its validated data, hands-only action
atlas, effects, feedback, kit, tests, accessibility review, and host/client
evidence pass on the same commit.

The weighted element assignments are machine-owned by
`content/champions/champion_affinities_first_eight_v1.json`. Historical concept
boards can show superseded names, ancestries, or unweighted affinities; they are
visual reference only and never override this table or the content catalog.

## Playable body-role contract

| Body | Role | Foundation champion | Compensation / cost |
|---|---|---|---|
| Small | Skirmisher | S. Wayne | Fast ground tempo and Flux recovery; lowest Health/Stamina reserves |
| Middle | Adapter | Oh Tipi | Balanced resources and routing; no extreme stat |
| Large | Anchor | The Red Baron | Deep Health/Stamina reserves; slowest ground tempo and Flux recovery |

Every body has identical access to universal movement and the shared foundation
collision radius. The distinction is a validated resource/tempo envelope, not
hidden reach, damage, elemental advantage, or evasion.
