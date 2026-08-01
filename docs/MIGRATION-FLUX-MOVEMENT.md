# FLUX to FLUX2 movement migration

Source baseline: `generalgroovy/flux` at commit `d49c9a9`, inspected 2026-08-01.
Target baseline: Godot 4.7.1, protocol version 1.

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

## Not yet migrated

Variable jump/fast fall, character-specific mobility, launched/grappled/
charging/status movement, moving platforms, elevation columns, full authored
map collision, network prediction/reconciliation, and chemistry-derived
surface modifiers remain explicit subsequent slices. Their enum/schema space
must be added with tests rather than inferred from presentation.
