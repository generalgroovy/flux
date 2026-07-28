# FLUX concept iteration: characters, balance, and visual language

Date: 2026-07-28
Status: future-facing design foundation; not connected to live gameplay

This pass develops the approved overhaul roster without weakening the repository
unification gate. It changes no live combat values, simulation paths, renderer,
network protocol, save identifier, or packaged runtime. Numerical tuning remains
subject to hands-on play after the unified build passes its launch smoke.

## Decisions locked in this pass

- Keep all fifteen approved character and ability names exactly as authored.
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

| Reference | Character | Race | Player promise | Primary visual and counterplay read |
| --- | --- | --- | --- | --- |
| Michail | Oh Tipi | Seakin | Conductive-field skirmisher who turns Water routes into movement decisions | Streamlined fins, tide ribbons, freeze seams, and visible shared conduction risk |
| Sam | S. Wayne | Human | Mysterious millionaire and eclipse tactician; rumor credits his fortune to mahjong | Split Light/Void mantle and marked boundaries; repositioning needs a personal boundary and lockout |
| Michel | The Red Baron | Undead | Formation controller who commits through dangerous air lanes | Tall officer silhouette, crimson wedges, dark flak circles, and punishable landing recovery |
| Stivo | Steezo | Goblin | Volatile combo engineer whose unmistakable call is “Sheeeeeeeeeeeeeee” | Sparking backpack and exposed construct joints; self-detonation never refunds |
| Trev | Treevor the Mason | Treefolk | Mud-and-herb terrain mason famed for exceptional mudpies | Broad branch crown, mud-block geometry, herb sprigs, huge target, and visible Fire exposure |
| Olli | Oll' I | Minotaur | Structural momentum breaker—one bull you do not grab by the horns | Wide horns, locked torso, long charge lane, poor turning, and long miss recovery |
| Flip | Fluup | Orc | Storm bruiser who converts a committed landing into the next attack | Weighted boots, storm mantle, radial rime fracture, and visible stored-charge cap |
| Kira | Wa Bidi | Sylph | Air-route assassin whose “WABIDI BIBIDI!” battlecry precedes the hit | Streamer wings and open wind arcs; fragile body and high knockback remain readable without sound |
| Nick | Nico Lai | Gnome | Precision shared-device engineer who multiplies one opening | Calibrated coil pack and linked nodes; every device stays breakable and shared |
| Martin | Spai Si | Elf | Cryptic redirect duelist who turns hostile intent into an angle | Narrow leaf silhouette and curved aim guides; fragile body limits repeated contests |
| Sehnou | Hidn Leef | Treefolk | Concealed grove support who lets the battlefield bloom around an unseen route | Layered leaf mantle and growth rings; slow repositioning and Fire-vulnerable growth |
| Tarek | Ha Rekt | Wyrm | Aerial cold-line hunter who marks the escape before the enemy sees it | Rime wings and landing fan; low FLOW capacity limits repeated commitments |
| Daniel | Dr. Apex | Stoneborn | Armored combat medic from the far north | Stone shoulders, triage band, Spring basin, slow movement, and contestable healing |
| Charis | Hara | Gnome | Resourceful planner who always keeps a second option | Compact silhouette and three-element utility; no extreme stat edge |
| Christo | Hesus Christo | Wyrm | Towering renewal vanguard who turns broken ground into a route back | Heavy wings, growth-and-water routes, huge target, and slow response |

## Static balance snapshot

These figures come from `characterBalanceProfile` and are comparison inputs, not
claims about match balance.

| Character | Power budget | Signature points / 13 | Average Flux cost | Average cooldown | Role coverage |
| --- | ---: | ---: | ---: | ---: | --- |
| The Red Baron | 59 | 10 | 36.0 | 3.30 s | control, damage, defense, mobility |
| Treevor the Mason | 70 | 11 | 40.0 | 3.97 s | control, defense, terrain |
| S. Wayne | 50 | 7 | 32.7 | 3.13 s | construct, control, damage, deception, mobility, reveal |
| Steezo | 64 | 11 | 38.0 | 4.50 s | construct, control, mobility |
| Oh Tipi | 67 | 9 | 31.3 | 3.13 s | control, mobility, terrain |
| Oll' I | 71 | 11 | 38.7 | 4.03 s | control, damage, defense, destruction, mobility, terrain |
| Fluup | 66 | 10 | 34.0 | 3.40 s | control, damage, mobility, terrain |
| Wa Bidi | 56 | 7 | 28.7 | 2.73 s | control, defense, mobility |
| Nico Lai | 53 | 9 | 36.7 | 3.80 s | construct, control, damage, interrupt, mobility |
| Spai Si | 59 | 5 | 24.7 | 1.67 s | control, damage, defense, reveal, terrain |
| Hidn Leef | 60 | 6 | 28.7 | 2.73 s | control, damage, reveal, support, terrain |
| Ha Rekt | 65 | 8 | 30.0 | 2.67 s | control, damage, defense, mobility |
| Dr. Apex | 65 | 10 | 39.3 | 4.67 s | defense, support, terrain |
| Hara | 43 | 6 | 20.7 | 1.18 s | control, damage, defense, reveal |
| Hesus Christo | 55 | 6 | 30.0 | 2.60 s | control, defense, support, terrain |

The table exposes two playtest questions rather than prescribing speculative
number changes:

1. Oll' I has the widest role vocabulary. Verify that commitment and turning
   constraints keep that breadth from becoming universal best-in-slot value.
2. Spai Si, Hara, Hidn Leef, and Hesus Christo have inexpensive signatures.
   Verify that geometry, setup, and body drawbacks prevent universal value.
3. Dr. Apex has the slowest average signature cycle. Verify that healing remains
   contestable without making the combat medic inactive between commitments.

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
