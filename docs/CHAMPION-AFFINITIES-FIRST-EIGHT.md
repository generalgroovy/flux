# Champion affinity contract — first-eight phase

Status: **design-locked migration target**. The currently executable champions also obey this rule in `foundation_champions_v1.json`.

Every champion receives exactly **3 innate affinity points** during the first-eight phase. Affinity points define how strongly the champion is aligned to an element without creating a hidden elemental damage wheel.

Ordinary champions own exactly **two** affinities and distribute the three points as **2 + 1**:

- `2` = primary/dominant affinity;
- `1` = secondary affinity.

**Treevor the Mason** is the sole current three-affinity exception and distributes the same three-point budget as **1 + 1 + 1** across Earth, Wind and Fire.

No current champion receives `3` points in a single element. The three-point budget is for distribution across affinities, not mono-element specialization.

Ordinary champions must also keep a **unique unordered affinity pair**. With eight promoted elements there are 28 possible unordered two-element pairs, enough for the current roster without duplicate ordinary combinations.

Only the currently promoted element families may receive affinity points during this phase:

`Earth, Fire, Water, Wind, Ice, Charge, Light, Dark`

`Spirit`, `Chaos`, `Gravity`, and `Time` remain runtime-gated until the first-eight fundamental chemistry acceptance gate. Existing historical labels using those families are migration inputs rather than current affinity truth. Legacy `Void` is not a thirteenth family.

Sources and rollout contracts:

- machine-readable roster: [`content/champions/champion_affinities_first_eight_v1.json`](../content/champions/champion_affinities_first_eight_v1.json);
- implementation order and acceptance: [`CHAMPION-AFFINITY-IMPLEMENTATION-PLAN.md`](CHAMPION-AFFINITY-IMPLEMENTATION-PLAN.md);
- identity compatibility migrations: [`content/champions/champion_identity_migrations_v1.json`](../content/champions/champion_identity_migrations_v1.json);
- chemistry implementation: [`ELEMENT-REACTIONS-IMPLEMENTATION-PLAN.md`](ELEMENT-REACTIONS-IMPLEMENTATION-PLAN.md).

## Strength semantics

Affinity strength is deliberately bounded and readable.

| Strength | Meaning | Current mechanical consequence |
| ---: | --- | --- |
| **0** | No innate affinity | No affinity-based build discount for that element. |
| **1** | Secondary affinity | May claim up to 1 point of an ability's authored `affinity_discount`. |
| **2** | Primary affinity | May claim up to 2 points of an ability's authored `affinity_discount`. |

The effective active-build discount is:

```text
effective_discount = min(champion_affinity_strength, ability.affinity_discount)
effective_active_cost = max(1, authored_points - effective_discount)
```

Existing foundation actives currently author `affinity_discount = 1`, so the weighted model **does not silently rebalance the current 13-point foundation loadout**. Primary affinity strength becomes mechanically distinct as later abilities deliberately author a larger affinity-discount ceiling.

Affinity strength does **not** automatically multiply raw damage, status magnitude, reaction damage, reaction radius or reaction duration. Those remain explicit ability/reaction parameters with visible counterplay.

## Roster

| Champion | Weighted affinities | Identity |
| --- | --- | --- |
| **Oh Tipi** | **Water 2 · Charge 1** | Strong current/water specialist with secondary conductive alignment. |
| **S. Wayne** | **Dark 2 · Light 1** | Eclipse tactician leaning toward concealment/attrition while retaining Light boundary play. |
| **The Red Baron** | **Fire 2 · Ice 1** | Thermal aerial controller with Fire as the dominant pressure element. |
| **Steezo** | **Charge 2 · Fire 1** | Device/detonation engineer whose electrical machinery dominates the volatile Fire layer. |
| **Treevor the Mason** | **Earth 1 · Wind 1 · Fire 1** | Sole 1+1+1 exception: masonry, shaping and combustion liability are equally structural to the concept. |
| **Oll' I** | **Earth 2 · Dark 1** | Heavy structural breaker with secondary predatory attrition. |
| **Fluup** | **Wind 2 · Charge 1** | Storm bruiser centered on airflow, pressure and movement, with Charge as electrical support. |
| **Wa Bidi** | **Wind 2 · Fire 1** | Fast route specialist whose movement/vector identity dominates combustion. |
| **Grace Reava** | **Wind 2 · Water 1** | Aerial duelist driven by airflow with fluid secondary control. |
| **Waka Aren Si** | **Charge 2 · Light 1** | Precision device engineer with Light as optical/support alignment; technical migration key remains `nico_lai` until the explicit compatibility slice. |
| **Spai Si** | **Wind 2 · Dark 1** | Redirect duelist with deceptive Dark secondary pressure. |
| **Leaf the Hidden** | **Earth 2 · Wind 1** | Grove/route shaper anchored in terrain with Wind for concealment and shaping. |
| **Ha Rekt** | **Ice 2 · Wind 1** | Cold-line hunter with Wind supporting aerial routing. |
| **Dr. Apex** | **Light 2 · Earth 1** | Support/fortification character dominated by Light protection and recovery identity. |
| **Haara** | **Light 2 · Water 1** | Bloom/resource planner; Spirit remains deferred. |
| **Hesus Christo** | **Earth 2 · Water 1** | Renewal vanguard with structure first and Water-assisted rebuilding. |
| **Grimm Bow** | **Dark 2 · Water 1** | Concealment/attrition archer with Water displacement; legacy Void remains normalized to Dark. |
| **Biggy Bob** | **Earth 2 · Fire 1** | Forge-line masonry breacher whose structure identity dominates the heat layer. |
| **Jan Wicked** | **Ice 2 · Dark 1** | Black-ice hunter with Ice as the main control axis. |
| **Ba Djoh** | **Earth 2 · Ice 1** | Large permafrost/impact breaker anchored in mass and terrain. |
| **Urzh** | **Charge 2 · Earth 1** | Conductive bulwark with Charge as the primary systems identity. |
| **Donnok** | **Fire 2 · Water 1** | Forge-rhythm terrain shaper strongly aligned to heat with Steam-capable Water support. |
| **Djonah Thaan** | **Dark 2 · Charge 1** | Grave-current pursuit controller dominated by Dark pressure. |
| **Unnamed Angel** | **Light 2 · Wind 1** | Unapproved placeholder; Spirit remains deferred. |

## Validation invariants

For every current champion:

```text
sum(affinity_points) == 3
all affinity point values are positive
all affinity IDs are known and runtime-enabled
```

For ordinary champions:

```text
affinity_count == 2
point distribution == 2 + 1
unordered affinity pair is unique across ordinary roster
```

For Treevor:

```text
affinity_count == 3
point distribution == 1 + 1 + 1
canonical profile == Earth 1 + Wind 1 + Fire 1
```

The compatibility `affinities` list remains in champion/loadout JSON during migration, but `affinity_points` is the authoritative strength representation. Validators require both representations to contain the same element IDs so they cannot drift.

Waka Aren Si is the canonical player-facing name. The technical key `nico_lai` is a temporary compatibility detail and must be migrated only through the explicit versioned identity migration contract; old saves/replays must resolve through a documented adapter or fail clearly rather than silently selecting another character.

## Gameplay intent

The weighted system adds identity without creating matchup multipliers. A primary affinity should mean **deeper access/efficiency in authored content**, while a secondary affinity establishes a meaningful second reaction route.

Examples:

- Oh Tipi's **Water 2 + Charge 1** emphasizes Water abilities while retaining Conductive Flood synergy;
- S. Wayne's **Dark 2 + Light 1** emphasizes concealment/attrition while preserving Penumbra boundary play;
- Donnok's **Fire 2 + Water 1** points naturally toward Steam and thermal terrain control;
- Fluup's **Wind 2 + Charge 1** emphasizes vector/movement control while retaining Ion Storm and electrical landing interactions;
- Waka Aren Si's **Charge 2 + Light 1** emphasizes device/conductor play with optical support;
- Ha Rekt's **Ice 2 + Wind 1** emphasizes Freeze/Black Ice control with Hailstream and aerial support.

The wider reaction network still comes from loadout choice, teammates and manipulating existing map states rather than giving each champion exclusive ownership of their affinity reactions.
