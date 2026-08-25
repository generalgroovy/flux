# Champion affinity contract — first-eight phase

Status: **design-locked migration target**. The two currently executable
champions also obey this rule in `foundation_champions_v1.json`.

During the first-eight chemistry phase, ordinary champions own exactly **two**
element affinities. **Treevor the Mason** is the sole deliberate exception and
may own three. This keeps champion identity focused while allowing the wider
loadout/Flux Formula system to create cross-element composition without giving
most characters three passive alignment discounts.

Only the currently promoted element families may be champion affinities during
this phase:

`Earth, Fire, Water, Wind, Ice, Charge, Light, Dark`

`Spirit`, `Chaos`, `Gravity`, and `Time` remain runtime-gated until the
first-eight fundamental chemistry acceptance gate. Existing historical labels
using those families are migration inputs rather than current affinity truth.
Legacy `Void` is not a thirteenth family.

Machine-readable source:
[`content/champions/champion_affinities_first_eight_v1.json`](../content/champions/champion_affinities_first_eight_v1.json).

## Roster

| Champion | First-eight affinities | Migration decision |
| --- | --- | --- |
| Oh Tipi | **Water · Ice** | Charge removed from innate affinity; legal loadouts may still use Charge. |
| S. Wayne | **Dark · Light** | Unchanged. |
| The Red Baron | **Fire · Ice** | Legacy Void removed; thermal duality becomes the focused identity. |
| Steezo | **Fire · Charge** | Light removed. |
| **Treevor the Mason** | **Earth · Wind · Fire** | Sole three-affinity exception; terrain-mason identity retained. |
| Oll' I | **Earth · Fire** | Light removed. |
| Fluup | **Charge · Wind** | Ice removed. |
| Wa Bidi | **Charge · Wind** | Fire removed. |
| Grace Reava | **Wind · Water** | Light removed. |
| Nico Lai | **Charge · Light** | Unchanged. |
| Spai Si | **Wind · Light** | Earth removed. |
| Leaf the Hidden | **Water · Earth** | Light removed. |
| Ha Rekt | **Ice · Wind** | Fire removed. |
| Dr. Apex | **Earth · Light** | Water removed. |
| Haara | **Light · Wind** | Spirit deferred. |
| Hesus Christo | **Earth · Water** | Unchanged. |
| Grimm Bow | **Dark · Earth** | Legacy Void normalized to Dark; Water removed. |
| Biggy Bob | **Earth · Fire** | Light removed. |
| Jan Wicked | **Ice · Dark** | Charge removed. |
| Ba Djoh | **Earth · Fire** | Water removed. |
| Urzh | **Earth · Charge** | Fire removed to keep the conductive bulwark identity focused. |
| Donnok | **Earth · Fire** | Water removed. |
| Djonah Thaan | **Dark · Charge** | Fire removed. |
| Unnamed Angel | **Wind · Light** | Spirit deferred; slot remains an unapproved non-selectable placeholder. |

## Runtime rule

`ChampionCatalog` keeps the previous minimum of two affinities but changes the
maximum:

```text
ordinary champion: exactly 2
Treevor the Mason: 2 or 3; target profile uses 3
```

All affinity IDs must remain unique, known to the ability catalog, and
`runtime_enabled`. Therefore a champion cannot acquire Spirit, Chaos, Gravity or
Time by content accident while those families remain gated.

## Gameplay intent

Affinities continue to affect **aligned active build cost only**. They do not
multiply raw elemental damage and do not grant hidden matchup bonuses. A
champion's two affinities define a strong identity; the broader reaction network
comes from loadout choice, teammates and manipulating existing map states.

Treevor keeps three because his character concept is specifically the
intersection of **Earth structure**, **Wind shaping**, and **Fire liability/
transformation**. The exception must not become precedent for later champions
without a deliberate schema/design review.
