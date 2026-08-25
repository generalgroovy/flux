# Champion affinity implementation plan — first-eight phase

Status: **ordered implementation plan**. This document operationalizes the design-locked weighted-affinity contract in [`CHAMPION-AFFINITIES-FIRST-EIGHT.md`](CHAMPION-AFFINITIES-FIRST-EIGHT.md) and connects it to the first-eight reaction work in [`ELEMENT-REACTIONS-IMPLEMENTATION-PLAN.md`](ELEMENT-REACTIONS-IMPLEMENTATION-PLAN.md).

## Scope lock

The promoted affinity families for this phase are:

`Earth, Fire, Water, Wind, Ice, Charge, Light, Dark`

`Spirit`, `Chaos`, `Gravity`, and `Time` remain reserved and runtime-gated until the first-eight chemistry fundamentals pass their acceptance gate.

Every champion has exactly **3 innate affinity points**:

- ordinary champion: exactly two affinities distributed **2 + 1**;
- Treevor the Mason: the sole approved **1 + 1 + 1** three-affinity exception;
- no mono-element `3` profile in this phase;
- no ordinary duplicate unordered affinity pair.

Affinity strength is a content/build relationship, not an elemental damage multiplier. It may affect explicitly authored affinity discounts, access, specialization depth, tutorial emphasis and later content requirements. It must not silently multiply raw damage, reaction damage, reaction radius, reaction duration, status magnitude or resistance.

## Current canonical corrections

| Character | Canonical weighted affinities | Notes |
| --- | --- | --- |
| Oh Tipi | **Water 2 + Charge 1** | Water-first current specialist; Charge enables conductive follow-up. |
| Fluup | **Wind 2 + Charge 1** | Wind is authoritative primary identity; Charge is secondary storm/electrical support. |
| Waka Aren Si | **Charge 2 + Light 1** | Canonical display name. Existing technical key `nico_lai` remains a temporary compatibility identifier until an explicit ID migration slice. |
| Treevor the Mason | **Earth 1 + Wind 1 + Fire 1** | Sole three-affinity exception. |

The complete roster source remains `content/champions/champion_affinities_first_eight_v1.json`.

## A0 — data contract and validation

Goal: make the three-point model impossible to represent ambiguously.

Required:

1. `affinity_points` is authoritative for strength.
2. Compatibility `affinities` contains exactly the same element IDs as `affinity_points`.
3. Sum of points is exactly `3` for every champion and validated loadout.
4. Ordinary champions have exactly two affinities with values `{2,1}`.
5. Treevor has exactly three affinities with values `{1,1,1}` and canonical Earth/Wind/Fire membership.
6. Only runtime-enabled first-eight IDs are accepted.
7. Unordered ordinary pairs are unique; `water+charge` and `charge+water` are the same pair for uniqueness.
8. Canonical content hashing includes weighted points.
9. Invalid/missing/extra point maps fail closed with actionable diagnostics.

Acceptance:

- unit fixtures reject total `2`, total `4`, strength `0`, strength `3`, undeclared keys, missing keys, gated elements and duplicate ordinary pairs;
- 60/120 Hz simulation hashes remain unchanged when affinity data is not consulted by a runtime action;
- changing a weighted profile changes the canonical champion/content hash predictably.

## A1 — runtime affinity API

Goal: expose one small deterministic API so combat, loadouts, UI and reactions do not each reinterpret affinity data.

Add/standardize:

```text
affinity_strength(champion_id, element_id) -> 0|1|2
primary_affinity(champion_id) -> element_id|null
secondary_affinity(champion_id) -> element_id|null
weighted_affinities(champion_id) -> stable ordered list
```

Rules:

- ordinary primary is the element with strength 2;
- ordinary secondary is strength 1;
- Treevor has no single primary unless future design explicitly adds one; UI presents his three equal affinities;
- stable ordering is content-defined then normalized for hashing, never dictionary iteration order;
- no presentation code may derive authority from colors/icons.

Acceptance:

- Oh Tipi resolves Water=2, Charge=1, all others=0;
- Fluup resolves Wind=2, Charge=1;
- Waka Aren Si resolves Charge=2, Light=1 even while the compatibility key is `nico_lai`;
- Treevor resolves Earth/Wind/Fire each as 1.

## A2 — ability/loadout coupling

Goal: make strength useful without introducing hidden matchup bonuses.

Keep the existing authored rule:

```text
effective_discount = min(champion_affinity_strength, ability.affinity_discount)
effective_active_cost = max(1, authored_points - effective_discount)
```

Implementation constraints:

- abilities explicitly opt into `affinity_discount`;
- current foundation abilities with discount ceiling 1 remain balance-compatible;
- a later ability may deliberately set ceiling 2 to distinguish primary vs secondary affinity;
- affinity may gate optional variants/tutorial suggestions only when authored in content;
- affinity never automatically modifies health, base movement, hitbox, raw spell power, raw reaction power or universal movement costs.

Tests:

- primary strength 2 cannot claim more discount than the ability authors;
- secondary strength 1 cannot claim a 2-point discount;
- unaffiliated elements receive zero discount;
- cost never drops below 1;
- 13-point competitive build validation remains exact.

## A3 — chemistry/reaction coupling

Goal: affinities influence **how a character builds and accesses elemental tools**, while reactions remain properties of actual map/material state.

The reaction resolver must not ask "who has the stronger element?" to determine physical outcomes. For example:

- Water + Charge creates Conductive Flood from world state regardless of whether Oh Tipi or another character produced the inputs;
- Wind + Charge creates Ion Storm from world state regardless of Fluup's affinity values;
- Earth + Fire creates Magma from thresholds/material state, not champion affinity totals;
- Light + Dark creates Penumbra from spatial overlap, not attacker/defender matchup bonuses.

Affinity may affect an authored ability's cost, available variant, preparation speed or resource efficiency only when that effect is explicit in the ability definition and visible to players.

Acceptance:

- identical material inputs produce identical reaction results when produced by different champions;
- changing champion affinity points cannot alter reaction hashes unless it changes the selected/authored ability parameters before the reaction is formed;
- reaction ownership/assist credit remains separate from affinity strength.

## A4 — roster migration and Waka Aren Si identity transition

Goal: change player-facing identity safely without breaking existing assets, saved profiles, replays or references.

### Canonical name

`Waka Aren Si` is the player-facing canonical character name.

### Temporary compatibility state

`nico_lai` may remain as the technical content key during the first-eight migration because existing references may use it. It must not remain exposed as the player-facing name.

### Dedicated future ID-migration slice

When all references are enumerated, migrate atomically:

```text
nico_lai -> waka_aren_si
```

The migration must cover:

- champion definitions and wire manifests;
- sprite/animation manifests and asset paths;
- loadouts and saved player profiles;
- replay metadata;
- bot/training definitions;
- selection UI and localization keys;
- tests and fixtures;
- documentation and historical migration aliases.

Compatibility requirements:

- old saved data containing `nico_lai` resolves to Waka Aren Si;
- old replay/content metadata either resolves through an explicit adapter or fails with a clear version mismatch rather than silently selecting another champion;
- stable wire IDs are preserved where feasible;
- asset rename occurs only after all runtime references are proven.

Do not perform a blind global text replacement because historical notes/provenance may intentionally mention the former name.

## A5 — UI and readability

Goal: make the 3-point system immediately understandable without requiring a wiki.

Selection/loadout UI should present:

- exactly three visible affinity pips per champion;
- primary `2` as two pips on one element and secondary `1` as one pip on another;
- Treevor as three single pips across Earth/Wind/Fire;
- element name + icon/shape + numeric/pip strength so color is not the only cue;
- concise text explaining what affinity actually affects: authored build efficiency/specialization, not universal damage bonuses.

Examples:

```text
Oh Tipi      Water ●●   Charge ●
Fluup        Wind  ●●   Charge ●
Waka Aren Si Charge ●●  Light  ●
Treevor      Earth ●  Wind ●  Fire ●
```

Accessibility acceptance:

- readable in grayscale and supported color-vision simulations;
- keyboard/controller focus exposes the same information;
- screen-reader/localized strings include element names and strengths;
- no meaning is conveyed by hue alone.

## A6 — champion rollout order

The affinity system should be proven on a small representative set before full roster promotion.

1. **Oh Tipi — Water 2 + Charge 1**: validates primary/secondary discount semantics and Conductive Flood-oriented build guidance.
2. **S. Wayne — Dark 2 + Light 1**: validates opposed-element pair presentation and Penumbra-oriented guidance.
3. **Fluup — Wind 2 + Charge 1**: validates that reversing primary/secondary emphasis changes identity/build guidance without changing the underlying Wind+Charge reaction rule.
4. **Waka Aren Si — Charge 2 + Light 1**: validates canonical display-name migration plus weighted affinity presentation.
5. **Treevor — Earth 1 + Wind 1 + Fire 1**: validates the equal three-way exception without inventing a hidden primary.
6. Remaining roster, one complete champion slice at a time.

Each champion promotion requires definition validation, selection UI, loadout legality, bot/training visibility, replay/network compatibility and accepted sprite/runtime integration.

## A7 — acceptance gate before affinity expansion

Before adding a fourth affinity point, strength 3, more than two ordinary affinities, or Spirit/Chaos/Gravity/Time affinities, require all of:

| Gate | Evidence |
| --- | --- |
| Budget correctness | Every promoted champion totals exactly 3 points. |
| Pair correctness | Every ordinary roster pair is unique and 2+1; Treevor alone is 1+1+1. |
| Determinism | Weighted lookups and loadout costing pass stable 60/120 Hz content/replay tests. |
| Balance safety | No implicit raw damage/reaction multiplier exists. |
| Chemistry separation | Same world inputs yield same reaction outcomes regardless of champion affinity. |
| UI clarity | Players can identify primary/secondary affinities and understand their purpose without external documentation. |
| Compatibility | Waka Aren Si player-facing rename is stable; any technical-ID migration is explicit and versioned. |
| First-eight scope | No affinity points reference Spirit, Chaos, Gravity or Time before chemistry fundamentals are accepted. |

## Recommended implementation sequence

```text
A0 validate weighted data
-> A1 central runtime lookup API
-> A2 loadout/ability integration tests
-> A3 chemistry separation tests
-> A4 Waka Aren Si compatibility migration contract
-> A5 selection/loadout UI
-> A6 representative champion rollout
-> full roster migration
-> first-eight chemistry acceptance
-> only then reconsider affinity-system expansion or elements 9-12
```

Every slice should remain reversible, launchable and covered by deterministic tests before the next slice becomes authoritative.
