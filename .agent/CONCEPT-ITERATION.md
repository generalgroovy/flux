# FLUX concept iteration: characters, balance, and visual language

Date: 2026-07-28
Status: future-facing design foundation; not connected to live gameplay

This pass develops the approved overhaul roster without weakening the repository
unification gate. It changes no live combat values, simulation paths, renderer,
network protocol, save identifier, or packaged runtime. Numerical tuning remains
subject to hands-on play after the unified build passes its launch smoke.

## Decisions locked in this pass

- Keep all seven approved character and ability names exactly as authored.
- Keep the stable internal IDs `dark`, `scaleheir`, `stonewrought`, and
  `rootwarden`; display them to players as **Void**, **Wyrm**, **Stoneborn**, and
  **Treefolk**.
- Treat the 100-point character budget as a safety ceiling, not a power ranking.
  A lower score does not prove that a kit is weaker because reliability, geometry,
  team utility, and matchup dependence still need playtest data.
- Require three unique signature actives, at least two distinct gameplay roles,
  an effective standard-loadout cost no greater than 13, positive paid-action
  costs and cooldowns, and explicit counterplay on every ability.
- Do not allow one active to appear in more than 25% of signature kits. Shared
  catalog skills are desirable; a roster monoculture is not.
- Never balance ancestry, size, or affinity with direct spell-damage bonuses.
  Their value belongs in movement, body geometry, resource shape, terrain use,
  and bounded utility.

## Canonical character concepts

| Character | Player promise | Silhouette and motion read | Spell-shape language | Required weakness read |
| --- | --- | --- | --- | --- |
| Der Rote Baron | Formation controller who commits through dangerous air lanes | Tall narrow undead officer, split coat tails, rigid banking turns | Crimson wedges, black flak circles, pale rime fins | Landing recovery and reduced healing must be visible before opponents commit |
| Treevor | Giant terrain tank who grows the route he wants to defend | Broad rooted trunk, asymmetric branch crown, slow planted turns | Blocky roots, sweeping leaf cones, ember nodes on breakable growth | Huge target and burning exposure use persistent outline changes, not hidden modifiers |
| Samwise DeWayne | Small route trickster who escapes through prepared misdirection | Low round silhouette, oversized travel pack, quick stop-start footwork | Tight wind orbit, marked burrow anchor, triangular campfire decoy | Short reach and low durability stay readable despite his small target profile |
| Steezo | Volatile engineer who builds a combo, then risks losing its pieces | Forward-leaning goblin, tool belt and sparking backpack, spring-loaded steps | Keg circles, prism line segments, coil arcs with exposed joints | Every construct has a distinct break state; refunds never trigger on self-detonation |
| Oh Tipi | Field skirmisher who turns water routes into movement decisions | Streamlined fins and trailing mantle, lateral skating posture | Narrow tide ribbons, faceted freeze seams, surface-following charge line | Peak steering requires authored Water and all conductive routes remain shared danger |
| Oll'I | Structural breaker who wins by maintaining a readable commitment | Wide horns, heavy forward lean, rectangular shoulders, slow turn radius | Long charge lane, ground shock rings, frontal mirror plane | Poor turning and miss recovery are telegraphed through locked torso and dust wake |
| Fluup | Storm bruiser who converts a committed landing into the next attack | Large orc with weighted boots and loose storm mantle, high vertical arcs | Short charge cone, wind launch ribbon, radial rime fracture | Miss recovery creates a clear punish window; stored movement charge has a visible cap |

## Static balance snapshot

These figures come from `characterBalanceProfile` and are comparison inputs, not
claims about match balance.

| Character | Power budget | Signature points / 13 | Average Flux cost | Average cooldown | Role coverage |
| --- | ---: | ---: | ---: | ---: | --- |
| Der Rote Baron | 59 | 10 | 36.0 | 3.30 s | control, damage, defense, mobility |
| Treevor | 70 | 11 | 40.0 | 3.97 s | control, defense, terrain |
| Samwise DeWayne | 56 | 10 | 34.0 | 3.40 s | control, deception, defense, mobility |
| Steezo | 64 | 11 | 38.0 | 4.50 s | construct, control, mobility |
| Oh Tipi | 67 | 9 | 31.3 | 3.13 s | control, mobility, terrain |
| Oll'I | 71 | 11 | 38.7 | 4.03 s | control, damage, defense, destruction, mobility, terrain |
| Fluup | 66 | 10 | 34.0 | 3.40 s | control, damage, mobility, terrain |

The table exposes two playtest questions rather than prescribing speculative
number changes:

1. Oll'I has the widest role vocabulary. Verify that commitment and turning
   constraints keep that breadth from becoming universal best-in-slot value.
2. Oh Tipi pays the lowest effective signature cost. Verify that dependence on
   Water setup and shared conduction risk meaningfully tax the kit in open space.

## Visual system

### Element language

Color is a fast cue, never the only cue. Every element also owns a mark, edge,
motion style, and impact sound family.

| Element | Reference color | Geometry | Motion |
| --- | --- | --- | --- |
| Earth | `#A9824D` | blocks, diamonds, cracks | weighty starts and abrupt stops |
| Fire | `#FF7048` | wedges, sparks, expanding rings | accelerating flicker and directional spread |
| Water | `#43C6DF` | ribbons, waves, concentric ripples | continuous flow and redirection |
| Wind | `#9BE5CC` | arcs, streamlines, open circles | fast sweep with fading tails |
| Ice | `#B7DEFF` | facets, needles, broken seams | crisp growth followed by brittle fracture |
| Charge | `#F1D95B` | branches, zigzags, linked nodes | stepped pulses between readable anchors |
| Light | `#FFE9A3` | rays, grids, prisms | straight travel and hard reflective turns |
| Void | `#9276C9` | disks, inward chevrons, erased gaps | pull, decay, and brief negative-space holds |

Team ownership uses outline and ground-marker shape; element uses interior color
and motion. This prevents a red team Fire spell or blue team Water spell from
collapsing two different meanings into the same cue.

### Combat readability hierarchy

1. Collision and danger boundary.
2. Startup direction and time-to-impact.
3. Ownership and interrupt/break state.
4. Element and reaction opportunity.
5. Decorative particles.

Decorative particles may be dropped first under load. Telegraph boundaries,
break states, aim lines, and status marks may not disappear. Live text stays at
one to three words; full rules remain in setup, hover/focus, guide, and freeplay
diagnostics. Text and essential UI components must retain accessible contrast,
and all color-coded states require a shape or label counterpart.

## Later hands-on acceptance

- Test each canonical character against one fast, one heavy, and one field-heavy
  opponent before changing budget inputs.
- Measure pick/round success, dry-cast frequency, ability contribution, damage
  taken during recovery, and field uptime; do not balance from win rate alone.
- Run mirror matches to separate kit execution from matchup effects.
- Verify silhouettes at combat zoom, in grayscale, and during overlapping fields.
- Verify reduced motion keeps timing and boundaries readable without relying on
  large camera or screen effects.
- Change one balance axis at a time and record the result in `.agent/memory.md`.
