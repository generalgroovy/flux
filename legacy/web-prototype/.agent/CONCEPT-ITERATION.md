# FLUX concept iteration: characters, balance, and visual language

Date: 2026-07-28
Status: superseded historical concept snapshot; not an implementation source

The current roster, elements, ancestries, and delivery order are defined by
`README.md`, `.agent/VISUAL-OVERHAUL.md`, and
`.agent/OVERHAUL-IMPLEMENTATION.md`. Conflicting rows below are retained only as
design history and must not drive implementation.

This pass develops the approved overhaul roster without weakening the repository
unification gate. It changes no live combat values, simulation paths, renderer,
network protocol, save identifier, or packaged runtime. Numerical tuning remains
subject to hands-on play after the unified build passes its launch smoke.

## Decisions locked in this pass

- Keep all sixteen approved character and ability names exactly as authored.
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
- Treat every character description as `draft-placeholder` copy. The existing
  wording stays available for the author to rework, but it must not enter the
  live game, marketing, localization, or voice pipeline before that rewrite.

## Canonical character concepts

| Character | Race | Player promise | Primary visual and counterplay read |
| --- | --- | --- | --- |
| Oh Tipi | Seakin | Conductive-field skirmisher who turns Water routes into movement decisions | Streamlined fins, tide ribbons, freeze seams, and visible shared conduction risk |
| S. Wayne | Human | Eclipse tactician who creates and crosses personal Light/Void boundaries | Split Light/Void mantle and marked boundaries; repositioning needs a personal boundary and lockout |
| The Red Baron | Undead | Formation controller who commits through dangerous air lanes | Tall officer silhouette, crimson wedges, dark flak circles, and punishable landing recovery |
| Steezo | Goblin | Volatile combo engineer who builds a risky detonation chain | Sparking backpack and exposed construct joints; self-detonation never refunds |
| Treevor the Mason | Treefolk | Terrain mason who creates cover, routes, and Fire liabilities | Broad branch crown, mud-block geometry, herb sprigs, huge target, and visible Fire exposure |
| Oll' I | Minotaur | Structural momentum breaker with high commitment | Wide horns, locked torso, long charge lane, poor turning, and long miss recovery |
| Fluup | Orc | Storm bruiser who converts a committed landing into the next attack | Weighted boots, storm mantle, radial rime fracture, and visible stored-charge cap |
| Wa Bidi | Sylph | Air-route assassin who trades safety for movement angles | Streamer wings and open wind arcs; fragile body and high knockback remain readable without sound |
| Nico Lai | Gnome | Precision shared-device engineer who multiplies one opening | Calibrated coil pack and linked nodes; every device stays breakable and shared |
| Spai Si | Elf | Redirect duelist who turns hostile intent into an angle | Narrow leaf silhouette and curved aim guides; fragile body limits repeated contests |
| Hidn Leef | Treefolk | Concealed grove support who grows value around a planned route | Layered leaf mantle and growth rings; slow repositioning and Fire-vulnerable growth |
| Ha Rekt | Wyrm | Aerial cold-line hunter who marks an escape route | Rime wings and landing fan; low FLOW capacity limits repeated commitments |
| Dr. Apex | Stoneborn | Armored combat medic with contestable area support | Stone shoulders, triage band, Spring basin, slow movement, and contestable healing |
| Hara | Gnome | Resourceful planner who always keeps a second option | Compact silhouette and two-element utility; no extreme stat edge |
| Hesus Christo | Wyrm | Towering renewal vanguard who turns broken ground into a route back | Heavy wings, growth-and-water routes, huge target, and slow response |
| Grimm Bow | Troll | Void-current terrain archer who converts displacement into a steadier follow-up | Heavy archer silhouette, inward Void marks, water lanes, a visible shot-ready cue, and long miss recovery |

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
| Grimm Bow | 61 | 6 | 26.0 | 2.12 s | control, damage, terrain |

The table exposes two playtest questions rather than prescribing speculative
number changes:

1. Oll' I has the widest role vocabulary. Verify that commitment and turning
   constraints keep that breadth from becoming universal best-in-slot value.
2. Spai Si, Hara, Hidn Leef, and Hesus Christo have inexpensive signatures.
   Verify that geometry, setup, and body drawbacks prevent universal value.
3. Dr. Apex has the slowest average signature cycle. Verify that healing remains
   contestable without making the combat medic inactive between commitments.
4. Grimm Bow's setup should improve aim stability only, never damage. Verify that
   opponents can read and escape the displacement-to-shot sequence.

## Mechanical depth and implementation feasibility

Depth comes from sequencing, positioning, shared terrain, and punishable
commitment rather than hidden multipliers. Prototype one loop at a time and use
existing catalog abilities before adding simulation primitives.

| Character group | Loop to prove first | Clarity requirement | Initial risk |
| --- | --- | --- | --- |
| Hara, Spai Si, Fluup, Ha Rekt | Existing movement and projectile abilities in new combinations | Standard startup, landing, and recovery cues | Low: catalog reuse |
| Nico Lai, The Red Baron, Oh Tipi | Shared devices, lanes, and fields that both teams can contest | Ownership plus break/interrupt state | Medium: persistent shared state |
| S. Wayne, Oll' I, Steezo | Commit, expose a response window, then convert only on success | Boundary, charge lane, stored state, and miss recovery | Medium: short-lived state machines |
| Treevor the Mason, Hidn Leef, Grimm Bow | Create or exploit terrain without trapping play into one route | Terrain lifetime, collision, mark, and teardown cues | Medium: authored terrain interactions |
| Wa Bidi | Route advantage without audio dependence | Battlecry timing must also have a shape and motion cue | High: accessibility and mobility validation |
| Dr. Apex, Hesus Christo | Contestable sustain with clear interruption and downtime | Heal source, radius, suspension, and recovery | High: support tuning and server authority |

Future roster data remains `design-only`. Hara now has a separate
`prototype-local` runtime adapter whose mechanic prototype, deterministic local
tests, and bot-use coverage pass. Server-authoritative remote play,
readability/accessibility review, and packaged smoke testing remain pending.
Lore approval is a separate author-owned gate and cannot be inferred from
mechanical acceptance.

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
