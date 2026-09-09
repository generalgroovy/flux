# Ephemeral projectile/reaction batch candidate

2026-09-09. Follow-on trial explicitly approved after the initial drill in
README.md. One production candidate, retained for integration pending independent
boundary review and root's Full checkpoint; no other optimization attempted.
Full/export/provenance/delivery remain separate gates.

## Measured result

Fresh baseline and candidate use the unchanged `runtime_stress_probe.gd`,
`--quick --stages --scenario=legal-eight-mixed-deliveries --require-network-clear`,
seed608120, 120 warmup +720 measured ticks, natural cleanup and two reversed-order
repeats. Identical catalog content and fixture-owned zero-obstacle geometry;
no live-map content is loaded. Prior inventory/circle/chemistry guards are in both.

| Measurement | Baseline repeat1 /2 | Candidate repeat1 /2 |
| --- | --- | --- |
| Whole-step median | 4.226 /3.668 ms | 3.545 /3.456 ms |
| Whole-step p95 | 9.586 /9.595 ms | 8.093 /7.990 ms |
| Whole-step p99 | 10.198 /10.004 ms | 8.824 /8.235 ms |
| Whole-step maximum | 12.166 /12.777 ms | 14.076 /11.665 ms |
| Projectile-stage p95 | 6.883 /6.918 ms | 5.484 /5.423 ms |
| Ticks above8.333ms | 127 /124 | 19 /6 |

Whole-step p95 improves **1.493 /1.605ms (15.57% /16.73%)**. This is materially
larger and more consistent than the prior median-only guards. Nonetheless, the
remaining p99/maximum spikes and over-budget ticks mean **no sustained120Hz
acceptance**. No rendered FPS or physical-network performance is measured.

Both stress runs pass16,551 assertions, zero failures, zero omitted projectile/
Field danger, zero snapshot rejection and zero legal network-gap samples. All
non-timing report fields match exactly, including caps, costs/refusals, lifecycle
counts, all12 checkpoints and final hash. The mixed workload still has96 peak
projectiles,32 reactions, zero Fields;18 Heavy/17 Wave/122 Rapid paid starts;
12 capacity and one Flux refusal. No capacity/cost/geometry/lifetime was changed.

## Production scope and exactness argument

Only `src/sim/combat/combat_system.gd` changed: an ephemeral typed candidate list
is built once before a nonempty `advance_projectiles` batch by
`_projectile_reaction_candidates`. It retains currently active references for
the same nine recipe wires used by the unchanged interaction method. Only
`projectile_interaction` receives this list. All Heavy rewind, blast, cover and
line queries still receive the complete original `reactions` array.

The call graph is synchronous. During this batch, neither the tick nor recipe
wire IDs change and no reaction is appended. `projectile_interaction` can consume
health/capacity, shorten decay, or mark a pulse; it cannot activate a previously
inactive reaction. Heavy rewind/line queries are read-only; damage and Edgeweave
affect actors/projectiles, not reaction membership. World terminal consumption
and chemistry formation happen after the entire batch returns.

Selection preserves reference identity, original order and duplicates. The
inner active/wire/health/mask checks remain untouched, so destruction by an
earlier projectile is immediately visible to later projectiles. Health-zero
active reactions are deliberately retained. No copied bounds, persistent cache,
protocol/schema, rule or public standalone interaction signature was added.

## Differential evidence

- Mixed every-tick frozen old-batch oracle: **5,669 assertions/0 failures**.
  All1,582 warmup/measured/cleanup/idle states and ordered public events agree.
  Trace SHA256:
  `ff2bdc56764b3440760974b7e81ae2b11660e83c1180c32d8d3673ec6de7f543`.
  Final clean hash:
  `d4dafe70a3c318a00dc1ced33d4bdcd49b7ae18308a9f33f31f0dfe9f1bede25`.
- Separate legal Field-opening oracle: **5,646 assertions/0 failures**.
  All1,521 states/event batches agree, including32 real Field spawns,32 triggers,
  32 expiries,76 paid cast starts and13 projectile-hit events. Cleanup680ticks.
  Trace SHA256:
  `b04ecc54f2b37bb4b21871441231b9e4c2ffa498130de15f46a432663531f669`.
  Final clean hash:
  `a7b73080a9cd23cb4581c0caba5e3273aaa98a1c90fa61f8dce2231d0a9ee753`.
  This is a correctness smoke, not an old/new Field timing comparison.
- Seeded batch edge oracle plus focused combat: **28,957 assertions/0 failures**,
  288 fixtures,864 batch steps, all36 recipe identities, both input orders.
  Covers forming/active/decay boundaries, health-zero cover, duplicate references,
  prior masks, worldbone, Heavy paths, owner/global split bookkeeping and complete
  canonical actors/projectiles/reactions/deposits/IDs. Explicit assertions prove
  first-shot cover destruction and seven later shots passing it, real prism
  reflection and real Light-lens split-reservation consumption.
- Normal Full gains **16 non-timing assertions** in
  `test_combat.gd::_test_projectile_reaction_candidates`; focused combat totals
  24,628 assertions. Empty input, all36 wires, health-zero active retention,
  exact order/references, phase boundaries and mutable aliases are protected.

The old batch oracle is the frozen pre-trial projectile loop in
`runtime_drill_combat.gd`; its chemistry observation copy remains pre-trial too.
Inherited contact/Heavy/actor helpers are unchanged by this trial. The paired
scenario accepts only the reviewed old/candidate combat hashes and unchanged
chemistry hash, failing closed on subsequent source drift. Its optional
`--fields` selector was added for the second correctness workload. Source and
test hashes are in `batch-comparison.json`.

## Rejected first attempt and retained receipts

The initial candidate used a typed-array ternary with generic `[]` on the empty
branch. Godot raised runtime assignment errors although state assertions could
still pass on empty frames. **Those receipts are rejected**, not acceptance.
The owned profile was stopped. Only initialization changed to an explicitly
typed empty array followed by an ordinary `if`; the candidate algorithm did not
change. All clean v2 runs and the strengthened v3 edge run have zero exit code
and empty stderr. The launch gate now checks stderr as well as exit status.

The eight raw files from the rejected attempt are preserved losslessly in
`failed-typed-array-attempt.zip`. Final successful logs/stderr are copied and
SHA-checked: `mixed-batch-baseline`, `mixed-batch-candidate-v2`,
`mixed-batch-oracle-v2`, `field-batch-oracle-v2`, and `batch-edges-v3`.
`batch-comparison.json` retains complete non-timing comparisons and summaries.

Baseline combat raw SHA256:
`788cc518ef1b59ae042b58792b777cc45d26296425a4ecd5a5fcc1a907f6b874`.
Candidate raw SHA256:
`cdce33b7ee0528c57870cd1a3f5ce8faa52bee9517ec56962bdf8551b6aebd1a`.
Candidate canonical-LF SHA256 for root-owned provenance:
`fafc913872bb2ec4957aa109b943b669c9d4580c0e1c6b7ece2092f5bb391bc3`.

```powershell
$engine = Join-Path $env:LOCALAPPDATA 'FLUX-dev/godot-4.7.1/Godot_v4.7.1-stable_win64.exe'
& $engine --headless --path . --script res://tests/scenarios/projectile_reaction_batch_equivalence.gd
& $engine --headless --path . --script res://tests/scenarios/runtime_projectile_drill.gd
& $engine --headless --path . --script res://tests/scenarios/runtime_projectile_drill.gd -- --fields
& $engine --headless --path . --script res://tests/scenarios/runtime_stress_probe.gd -- --quick --stages --scenario=legal-eight-mixed-deliveries --require-network-clear
```

No Full, import, export, renderer, model inference, commit or push was performed
by this runtime lane. Root owns integration and any refreshed delivery artifact.
