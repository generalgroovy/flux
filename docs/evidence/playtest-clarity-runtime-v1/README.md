# Eight-player paid-load diagnostic

2026-09-09, Godot4.7.1, AMD Ryzen3 7320U, protocol47/snapshot18,120Hz.
Production SimWorld.step, ordinary paid mixed Wave/Heavy/Rapid commands,
720 measured ticks after120 warmup, repeated with reversed command order.
This is an empty-obstacle diagnostic, not the rendered Wellspring or Internet.

| Measurement | Repeat1 | Repeat2 |
|---|---:|---:|
| Simulation median | 4.938ms | 5.001ms |
| Simulation p95 | 10.606ms | 9.868ms |
| Simulation p99 | 12.247ms | 10.612ms |
| Simulation maximum | 27.423ms | 13.521ms |
| Ticks over8.333ms | 95/720 | 133/720 |
| Snapshot capture/packing median | 3.893ms | 4.111ms |
| Snapshot p95 | 5.144ms | 4.755ms |
| Missing projectile/field danger or rejected snapshots | 0 | 0 |

12,455 correctness assertions passed, final hashes and expiry counts agree.
Peak96 projectiles,82 deposits,32 reactions; the bounded event envelope can omit
cosmetic events (peak overflow30), while complete danger state remains present.
No socket transmission or rendering was measured.

**The steady120Hz CPU budget is not met at this stress level.** Correctness
passing is not a timing pass. Snapshot work is measured separately and adds
work at60Hz; these values must not be described as rendered120FPS acceptance.
No speed/damage/cap change was made to conceal the result. The next performance
slice should isolate projectile/reaction query work and snapshot construction,
compare identical paid inputs, preserve all state hashes, and rerun on the actual
map with rendered/same-build peer measurements.

Raw evidence: [checked log](w5-eight-runtime-v1.log) and its empty stderr sibling.

## Exact exported local network smoke

The new windows-playtest-clarity-p47-20260909 portable subsequently passed the
real localhost ENet smoke on UDP24962 at120Hz, with isolated APPDATA/LOCALAPPDATA:
host/join, shared HELLO, movement reconciliation, Hearth-to-Court round,
late-join spectator/Hearth handoff, exact actor return, rematch and reason-bearing
host stewardship. All owned helper processes ended; no firewall/security policy
was changed. [Host log](farflow/host.log), [guest log](farflow/guest.log),
[late guest log](farflow/late-guest.log). This is not physical two-PC or Internet
acceptance; direct remote play still needs suitable routing/firewall/overlay.
