# FLUX current cast contract

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
| 3 | The Red Baron | Undead | Middle | Fire 2 · Ice 1 | Planned; kit not implemented |
| 4 | Steezo | Goblin | Small | Charge 2 · Fire 1 | Planned; kit not implemented |
| 5 | Treevor the Mason | Treefolk | Large | Earth 1 · Wind 1 · Fire 1 | Planned three-affinity exception |
| 6 | Oll' I | Werewolf | Large | Earth 2 · Dark 1 | Planned; kit not implemented |
| 7 | Fluup | Orc | Large | Wind 2 · Charge 1 | Planned; kit not implemented |
| 8 | Wa Bidi | Goblin | Small | Wind 2 · Fire 1 | Planned; kit not implemented |
| 9 | Grace Reava | Sylph | Small | Wind 2 · Water 1 | Planned; kit not implemented |
| 10 | Waka Aren Si | Gnome | Small | Charge 2 · Light 1 | Planned; `nico_lai` remains a compatibility ID only |
| 11 | Spai Si | Demon | Middle | Wind 2 · Dark 1 | Planned; kit not implemented |
| 12 | Leaf the Hidden | Treefolk | Middle | Earth 2 · Wind 1 | Planned; kit not implemented |
| 13 | Ha Rekt | Wyrmborn | Large | Ice 2 · Wind 1 | Planned; kit not implemented |
| 14 | Dr. Apex | Stoneborn | Large | Light 2 · Earth 1 | Planned; kit not implemented |
| 15 | Haara | Nymph | Small | Light 2 · Water 1 | Planned; kit not implemented |
| 16 | Hesus Christo | Elf | Middle | Earth 2 · Water 1 | Planned; kit not implemented |
| 17 | Grimm Bow | Troll | Large | Dark 2 · Water 1 | Planned; kit not implemented |
| 18 | Biggy Bob | Dwarf | Middle | Earth 2 · Fire 1 | Planned; kit not implemented |
| 19 | Jan Wicked | Human | Middle | Ice 2 · Dark 1 | Planned; kit not implemented |
| 20 | Ba Djoh | Minotaur | Large | Earth 2 · Ice 1 | Planned; kit not implemented |
| 21 | Urzh | Stoneborn | Large | Charge 2 · Earth 1 | Planned; kit not implemented |
| 22 | Donnok | Dwarf | Middle | Fire 2 · Water 1 | Planned; kit not implemented |
| 23 | Djonah Thaan | Vampire | Middle | Dark 2 · Charge 1 | Planned; kit not implemented |
| 24 | Unnamed Angel | Angel | Middle | Light 2 · Wind 1 | Non-selectable identity placeholder |

The board is for silhouette and ancestry coordination, not runtime promotion.
A champion becomes playable only after its validated data, hands-only action
atlas, effects, feedback, kit, tests, accessibility review, and host/client
evidence pass on the same commit.

The weighted element assignments are machine-owned by
`content/champions/champion_affinities_first_eight_v1.json`. Historical concept
boards can show superseded names, ancestries, or unweighted affinities; they are
visual reference only and never override this table or the content catalog.
