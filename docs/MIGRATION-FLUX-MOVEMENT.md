# FLUX to FLUX2 movement migration

Source baseline: `generalgroovy/flux` at commit `d49c9a9`, inspected 2026-08-01.
Target baseline: Godot 4.7.1, protocol version 3.

## Decisions

| FLUX behavior | Decision | FLUX2 foundation |
| --- | --- | --- |
| 120 Hz fixed match loop | Reinterpret | Match-selectable 60 or 120 Hz; frozen and hashed |
| Floating-point entity state | Replace | Scale-1000 integer position, velocity, direction, resources, and tick timers |
| Sprint and counter-strafe | Preserve | 1.28 sprint and 1.7 reversal acceleration, fixed-point |
| Hop and wall kick | Preserve | Paid edge-trigger, wall memory, explicit 650/780 speeds |
| Double jump and air redirect | Preserve | One paid second jump and one paid bounded redirect |
| Air dodge and wavedash | Preserve | Fixed lane, late angled queue, bounded committed steering |
| Slide and slide jump | Preserve | Entry-speed gate, paid slide, authored late conversion window |
| Marked-cover vault/superglide | Preserve | Stable obstacle IDs, explicit vaultable flag, safe landing query |
| Same-wall lockout | Preserve | Stable collision wall identity and a 220 ms per-wall kick lockout |
| Launched/grappled/charging/status movement | Reinterpret | Explicit bounded control states that still use ordered collision |
| Edgeweave hostile near-miss | Preserve with combat | Swept hostile miss-vs-hit geometry, speed/cooldown/resource/training guards, and one reward per projectile/fighter pair |
| Canvas swept-circle collision | Replace | Renderer-independent ordered integer box queries for the foundation |
| Scene/render loop ownership | Replace | Pure simulation state mirrored by a presentation-only Node2D |
| Browser networking implementation | Archive | Semantics remain reference input; Godot transport work is a later phase |

## Preserved tuning

The foundation records the FLUX values in integer units: Stamina 100; sprint
drain/recovery 34/27 per second; hop 28 at speed 650; wall kick 780; double jump
24 at 700; redirect 10 with 0.72 blend; air dodge 28 at 860; wavedash 740;
slide 22 at 720; slide jump 20 at 790; vault 14; and superglide 26 at the global
universal-movement ceiling of 900.

Durations are authored in integer milliseconds, then rounded upward to ticks
for the selected rate. Position integration carries integer remainders so
per-second velocities do not accumulate truncation drift.

## Second movement checkpoint

The source prototype's 220 ms same-wall lockout now uses stable integer wall
identities. Launched, grappled, charging, stunned, rooted, and slowed states are
explicit, bounded contracts; external speed clamps to 900 and all resulting
motion still resolves through the ordered collision world. A Conservatory
integration route independently verifies slide, late slide jump, air redirect,
marked vault, and crest superglide at 60 and 120 Hz.

## Third movement/combat checkpoint

Protocol 3 now supplies authoritative runtime projectiles and the staged
Edgeweave contract. A swept hostile path entering the 16-unit outer margin while
missing the inner hit volume can restore at most 9 Stamina to a fighter moving
at least 260 units/second. The 220 ms fighter lockout, full-Stamina rejection,
training-source rejection, hostile ownership, ordered simultaneous resolution,
and per-projectile/fighter reward identity are covered at both tick rates.

## Not yet migrated

Variable jump/fast fall, character-specific mobility, moving platforms,
impact influence/ground recovery, wall skims, rails/ziplines/lifts, elevation
columns, full authored map collision, network prediction/reconciliation, and
chemistry-derived surface modifiers remain explicit subsequent slices. Their
schema space must be added with tests rather than inferred from presentation.
