# Champion affinity contract — first-eight phase

Status: **design-locked migration target**. The two currently executable champions also obey this rule in `foundation_champions_v1.json`.

During the first-eight chemistry phase, ordinary champions own exactly **two** element affinities and every ordinary champion must own a **unique unordered affinity pair**. **Treevor the Mason** is the sole deliberate exception and may own three affinities.

This keeps champion identity focused while allowing the wider loadout/Flux Formula system to create cross-element composition. With eight promoted elements there are 28 possible unordered two-element pairs, which is enough to give every ordinary current roster slot its own elemental identity without adding third affinities.

Only the currently promoted element families may be champion affinities during this phase:

`Earth, Fire, Water, Wind, Ice, Charge, Light, Dark`

`Spirit`, `Chaos`, `Gravity`, and `Time` remain runtime-gated until the first-eight fundamental chemistry acceptance gate. Existing historical labels using those families are migration inputs rather than current affinity truth. Legacy `Void` is not a thirteenth family.

Machine-readable source:
[`content/champions/champion_affinities_first_eight_v1.json`](../content/champions/champion_affinities_first_eight_v1.json).

## Roster

| Champion | First-eight affinities | Identity / migration decision |
| --- | --- | --- |
| Oh Tipi | **Water · Ice** | Current rider and freeze-route controller; Charge removed from innate affinity but remains available through legal loadouts. |
| S. Wayne | **Dark · Light** | Eclipse boundary identity; unchanged. |
| The Red Baron | **Fire · Ice** | Thermal aerial controller; legacy Void removed. |
| Steezo | **Fire · Charge** | Volatile detonation engineer. |
| **Treevor the Mason** | **Earth · Wind · Fire** | Sole three-affinity exception; terrain masonry, shaping and combustion liability are all core to the character. |
| Oll' I | **Earth · Dark** | Heavy structural breaker with predatory/attritional pressure; avoids duplicate Earth/Fire. |
| Fluup | **Charge · Wind** | Storm bruiser and landing-current converter. |
| Wa Bidi | **Fire · Wind** | Fast route specialist; changed from duplicate Charge/Wind. |
| Grace Reava | **Water · Wind** | Fluid aerial duelist. |
| Nico Lai | **Charge · Light** | Precision shared-device engineer. |
| Spai Si | **Wind · Dark** | Redirect duelist with deceptive vector control; changed from duplicate Wind/Light. |
| Leaf the Hidden | **Earth · Wind** | Concealed grove route shaper; changed from duplicate Earth/Water. |
| Ha Rekt | **Ice · Wind** | Aerial cold-line hunter. |
| Dr. Apex | **Earth · Light** | Armored support/fortification identity. |
| Haara | **Water · Light** | Bloom/resource planner; Spirit deferred and duplicate Wind/Light avoided. |
| Hesus Christo | **Earth · Water** | Renewal vanguard rebuilding damaged routes. |
| Grimm Bow | **Water · Dark** | Displacement/terrain archer with legacy Void normalized to Dark. |
| Biggy Bob | **Earth · Fire** | Canonical forge-line masonry breacher. |
| Jan Wicked | **Ice · Dark** | Black-ice circuit hunter. |
| Ba Djoh | **Earth · Ice** | Huge permafrost/impact breaker; changed from duplicate Earth/Fire. |
| Urzh | **Earth · Charge** | Conductive kiln/bulwark identity. |
| Donnok | **Fire · Water** | Forge-rhythm terrain shaper with Steam interaction; changed from duplicate Earth/Fire. |
| Djonah Thaan | **Dark · Charge** | Grave-current pursuit controller. |
| Unnamed Angel | **Wind · Light** | Unapproved placeholder; Spirit deferred. |

## Uniqueness rule

For ordinary champions, affinity order does not matter. `Earth + Fire` and `Fire + Earth` are the same pair and cannot be assigned to two different ordinary champions.

The migration catalog therefore validates conceptually against this invariant:

```text
for each ordinary champion:
    affinity_count == 2
    unordered_pair is unique across ordinary roster

Treevor:
    affinity_count <= 3
    canonical target == Earth + Wind + Fire
```

No third affinity should be added merely to distinguish two ordinary champions while unused two-element pairs remain available. A future third-affinity exception requires an explicit schema/design review rather than an ad-hoc roster fix.

## Gameplay intent

Affinities continue to affect **aligned active build cost only**. They do not multiply raw elemental damage and do not grant hidden matchup bonuses.

A champion's pair should communicate both:

1. a strong personal gameplay identity; and
2. at least one characteristic map-interaction route within the first-eight reaction network.

Examples:

- Biggy Bob's Earth/Fire naturally points toward Magma and structural transformation;
- Donnok's Fire/Water points toward Steam and thermal terrain control;
- Fluup's Charge/Wind points toward Ion Storm and movement-pressure lanes;
- Ha Rekt's Ice/Wind points toward Hailstream and low-friction aerial routes;
- S. Wayne's Dark/Light points toward Penumbra and information boundaries.

The wider reaction network still comes from loadout choice, teammates and manipulating existing map states rather than giving each champion access only to their affinity pair.

Treevor keeps three because his character concept is specifically the intersection of **Earth structure**, **Wind shaping**, and **Fire liability/transformation**. The exception must not become precedent for later champions without deliberate review.
