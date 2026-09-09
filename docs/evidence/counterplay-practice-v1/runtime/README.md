# Mixed and Field-heavy runtime baseline

Local Windows / Godot 4.7.1 / Ryzen 3 7320U, 2026-09-09. These are simulation CPU
fixtures with the prior chemistry bounds guard, before the separately proposed
post-cast owner-capacity optimization. No rendered FPS, physical network, human
play quality, release, or sustained 120 Hz acceptance is implied.

## Measured baseline

Each fixture has eight catalog-backed players, seed 608120, a 120-tick warmup,
720 measured ticks, natural cleanup, and two repeats with reversed command order.
StageSampler remains the existing production-subsystem mirror and verifies state
hashes and combat events against actual SimWorld.step after every measured tick.

| Metric (p95, repeat 1 / 2) | Existing mixed deliveries | Legal Field opening |
| --- | --- | --- |
| Whole step | 10.819 / 10.407 ms | 4.585 / 4.443 ms |
| Projectiles | 7.694 / 7.514 ms | 2.720 / 2.718 ms |
| Chemistry | 2.363 / 2.321 ms | 1.468 / 1.547 ms |
| Fields | 0.019 / 0.021 ms | 0.452 / 0.447 ms |
| Capacity accounting | 0.653 / 0.657 ms | 0.537 / 0.563 ms |
| Ticks above 8.333 ms | 142 / 141 | 0 / 1 |

The mixed fixture passed 16,551 assertions; the Field opening passed 14,733.
Both had zero failures, zero omitted projectile/Field danger, zero snapshot
rejections, and zero legal network-gap samples. All non-timing results and 12
checkpoint hashes match between their own two repeats. Snapshots were encoded,
fragmented, reversed and reconstructed locally, not sent across a physical network.
Maxima and p99 values remain noisy and are preserved in the raw logs/JSON.

The two columns are different workloads, not an optimization comparison.
Mixed load still misses the 8.33 ms budget. Its projectile stage dominates;
removing a fraction of the 0.65 ms capacity stage cannot by itself solve that.

## Actual load and natural limits

The unchanged mixed fixture equips all eight actors with real Heavy, Wave and
Rapid spells. It records 18 Heavy, 17 Wave and 122 Rapid paid starts, peaks at
96 projectiles and 32 reactions, and has **zero Fields**. Twelve requests are
capacity-refused and one is Flux-refused. The exact final hash is
`d4dafe70a3c318a00dc1ced33d4bdcd49b7ae18308a9f33f31f0dfe9f1bede25`.

The new Field fixture is a deliberately coordinated legal saturation opening,
not a claim about typical player behavior. Four opposing pairs begin stationary.
Every actor equips Rimewake plus four distinct catalog-backed elemental Fields;
four casts at ticks 0/60/120/180 spend normal positive Flux and reach four Fields
per owner / 32 worldwide. All eight fifth-Field attempts at tick 240 are refused
for capacity before payment. There is no injected Field, resource refill,
cooldown bypass, altered champion stat, or artificial lifetime extension.

All eight Field identities release, with 32 paid starts, 32 releases and 32 real
enemy triggers. The cap lasts 71 ticks; Fields are present for 368/720 ticks,
totaling 6,688 Field-instance-ticks. Actors then move and make 32 Rapid, eight
Wave and four Heavy paid casts; four further Heavy requests are correctly
Flux-refused. Total authored payment is 856,000 milli-Flux across all actors;
minimum observed remaining Flux is 2,090. Peaks are 72 projectiles and 16 reactions.
Formation/active/decay reaction-instance-ticks are 792 / 3,494 / 168; all remaining
projectiles, Fields, deposits and reactions naturally expire during cleanup.
The exact final hash is
`a7b73080a9cd23cb4581c0caba5e3273aaa98a1c90fa61f8dce2231d0a9ee753`.

Conditional timing buckets prevent the no-Field tail from hiding opening cost:

| Condition | Ticks | Step p95 (1 / 2) | Field stage p95 (1 / 2) |
| --- | ---: | --- | --- |
| At the 32-Field cap | 71 | 2.330 / 2.284 ms | 0.664 / 0.597 ms |
| Fields and projectiles both alive | 142 | 4.433 / 4.442 ms | 0.584 / 0.447 ms |
| Any live Fields | 368 | 3.896 / 4.045 ms | 0.521 / 0.509 ms |
| Reaction tail after Fields expire | 323 | 5.239 / 4.919 ms | 0.026 / 0.027 ms |

These conditions intentionally overlap. The cap and projectile peaks do not all
occur simultaneously. The later reaction tail is more costly than Field saturation
in this particular fixture. Fields are not the measured bottleneck here.

## Reproduce and identity

```powershell
$engine = Join-Path $env:LOCALAPPDATA 'FLUX-dev\godot-4.7.1\Godot_v4.7.1-stable_win64.exe'
& $engine --headless --path . --script res://tests/scenarios/runtime_stress_probe.gd -- --quick --stages --scenario=legal-eight-mixed-deliveries --require-network-clear
& $engine --headless --path . --script res://tests/scenarios/runtime_stress_probe.gd -- --quick --stages --scenario=legal-eight-field-opening --require-network-clear
```

The fixture authors its own fixed 12,000 x 6,000 world with zero obstacles. The
live Wellspring map is not loaded. `baseline.json` retains full reports, explicit
repeat comparisons, content/source hashes and original log hashes. The mixed run
preceded test-only reporting/Field-scenario additions; its original harness SHA
is recorded. All baseline simulation source hashes are pinned in that JSON.
Later candidate changes must be compared against these exact hashes/counters,
not presented as a rerun of the old executable. No separate baseline checkout is
retained. Production optimization results, if accepted, must be recorded separately.

`mixed-baseline.log`, `field-opening-final.log` and their empty stderr companions
are byte-identical copies. Earlier Field development logs are not acceptance
evidence; the final run corrects a top-level release-count report and adds the
conditional buckets without changing commands or simulation state.

The approved follow-on experiment is only a stateless post-cast owner inventory helper.
Sequential pre-payment admission and global free-slot reservation stay unchanged.
The existing StageSampler must stay on the old per-owner logic as an equivalence
oracle, so its capacity-stage timings are not candidate helper timings. Actual
SimWorld.step measurements and a separate same-state helper diagnostic will own
any claimed gain. No cap, footprint, protocol or gameplay change is proposed.

[Candidate outcome and precise limits](CAPACITY-CANDIDATE.md) records the completed
oracle and same-input profiles separately from this retained baseline.
