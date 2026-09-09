# Projectile circle rejection trial

Local Windows / Ryzen 3 7320U / Godot 4.7.1, 2026-09-09. This is a bounded,
same-input CPU trial, not rendered FPS, physical-network, human-play, release,
or sustained 120 Hz acceptance. Root reviewed and retained the nine-line guard
as a modest median-cost optimization, not completion of the mixed slow-tail gate.

## Result and tradeoff

One strict axis-bounds rejection was added at the start of
`CombatSystem._segment_circle_hit`. Its original integer projection and final
circle test are unchanged. There is no new cache, array scan, state, schema,
capacity, cost, targeting order, physics rule, or chemistry rule.

The trial improves the mixed fixture's median, but does **not** demonstrate a
consistent p95 improvement. It must not be described as a solved slow tail.

| Whole SimWorld.step | Baseline repeat 1 / 2 | Candidate repeat 1 / 2 |
| --- | --- | --- |
| Median | 3.853 / 4.022 ms | 3.592 / 3.668 ms |
| p95 | 9.376 / 10.118 ms | 9.977 / 9.626 ms |
| p99 | 10.486 / 11.662 ms | 10.690 / 9.953 ms |
| Ticks above 8.333 ms | 141 / 135 | 136 / 128 |
| Projectile-stage median | 2.667 / 2.845 ms | 2.463 / 2.465 ms |
| Projectile-stage p95 | 6.832 / 7.401 ms | 7.102 / 6.995 ms |

Median savings are 0.261 / 0.354 ms (6.77% / 8.80%). The p95 changes have
opposite signs; maxima and p99 are noisy and remain in the original logs.
StageSampler is unchanged, including its legacy post-cast capacity accounting;
its capacity stage is not a measurement of the earlier one-pass helper.

The standalone query diagnostic reuses real, positive-cost mixed commands and
samples surviving projectiles every 12 ticks. All 20,734 sampled eligible target
pairs are far misses; the surviving eligible pair count is 336 median / 672 p95
per tick. These are **not exact production call counts**: terminated projectiles
are absent and no removed projectile is reconstructed.

Same frozen queries, equal checksums, both execution orders:

| Helper workload | Calls per pass | Old, two passes | Guard, two passes |
| --- | ---: | --- | --- |
| Paid mixed survivor samples | 82,936 | 166.943 / 164.611 ms | 110.929 / 117.097 ms |
| Boundary / near-hit samples | 9,216 | 15.771 / 14.654 ms | 20.124 / 19.923 ms |
| Synthetic eight-target close cluster | 32,768 | 44.185 / 48.728 ms | 63.347 / 69.529 ms |

Thus the helper saves about 0.57-0.68 microseconds on the sampled far-miss calls,
but adds about 0.58-0.63 microseconds per call in the dense synthetic cluster.
The cluster contains 128 query-only projectile poses and eight nearby targets;
it is not injected free casts in a game, nor a whole-world performance claim.
No universal or close-combat speedup is claimed.

## Equivalence and correctness

- Both stress runs pass 16,551 assertions, zero failures, and zero legal
  network-gap samples. All shared non-timing report fields, 12 checkpoint hashes,
  caps, paid/refused counts, lifecycle counts, snapshot results and final hash
  are identical across old/new and command-order repeats.
- The dedicated oracle retains the exact old helper in test code. It checks
  39,230 core boundary/real queries plus 1,024 synthetic close-cluster queries
  against both the production helper and the test-only guard, also checking
  projectile/player state purity. The JSON meta line precedes the added cluster,
  while the final query total includes it.
- Final standalone + focused combat/projectile-chemistry run: **157,458
  assertions, zero failures**. Combat contributes 24,612; projectile-chemistry
  integration contributes 10,459. Normal Full includes the added 39 non-timing
  combat assertions (13 mutable-object cases); Full itself is owned by root.
- Every one of the 1,582 warmup, measured, natural-cleanup and idle ticks is
  hashed with its complete canonical state and ordered public event batch.
  Old/new rolling trace SHA256 is
  `ff2bdc56764b3440760974b7e81ae2b11660e83c1180c32d8d3673ec6de7f543`.
- Both final clean hashes are
  `d4dafe70a3c318a00dc1ced33d4bdcd49b7ae18308a9f33f31f0dfe9f1bede25`.
  Exact trace events: 157 paid starts, 225 projectile spawns, 202 expiries,
  76 chemistry formations and 13 refusals; natural cleanup takes 741 ticks.

Conservativeness follows directly from the unchanged clamped projection:
without integer overflow, each truncated closest-point component lies between
the two endpoint components, including signed deltas. A nonnegative-radius
circle strictly outside that endpoint box cannot contain the chosen point.
Strict `<` / `>` rejection retains tangent contact and endpoint inclusivity.
Negative radii bypass the guard and retain the original squared-radius behavior.
Zero-length paths, radius zero, signed truncation, reversed paths, large signed
coordinates near 100 million, mutable instances, and inside-box circle misses
are covered. This is not a proof for arbitrary overflowing 64-bit arithmetic;
those inputs are outside the tested/proved non-overflow geometry domain.

The first combined run (`circle-candidate.log`) has one failing hand-authored
expected value: a radius-zero target on a non-axis segment was incorrectly
expected to hit despite integer truncation. The frozen oracle and replay already
matched. The expectation was corrected to false and a radius-one hit added;
`circle-candidate-v2.log` is the clean rerun. No production correction was needed.
The failed receipt is retained rather than hidden. All stderr files are empty.

## Input identity and reproduction

The existing `runtime_stress_probe.gd` and `runtime_stage_sampler.gd` were not
changed. Both stress invocations use seed 608120, eight catalog-backed actors,
120 warmup + 720 measured ticks, real Heavy/Wave/Rapid costs, natural cleanup,
and a fixed 12,000 x 6,000 world with zero obstacles. The live Wellspring JSON is
not loaded. The old inventory and chemistry guard remain in both variants.

Actual pressure peaks at 96 projectiles, 32 reactions and zero Fields; paid starts
are 18 Heavy, 17 Wave and 122 Rapid, with 12 capacity and one Flux refusal.
No resources, health or lifetimes are refilled or extended. Local snapshot
fragmentation/reconstruction is checked, but no physical network is measured.

Baseline combat SHA256:
`239e8040a88f62262f41b0c50210136ea981f729b8c0a02646dcfc80049c7bb8`.
Trial combat SHA256:
`788cc518ef1b59ae042b58792b777cc45d26296425a4ecd5a5fcc1a907f6b874`.
`comparison.json` records all relevant source/content hashes, exact comparisons,
raw timing summaries, trace metadata and microbenchmarks. The six original logs
and six stderr receipts are copied unchanged from `.godot/qv-runtime-20260909`.

```powershell
$engine = Join-Path $env:LOCALAPPDATA 'FLUX-dev/godot-4.7.1/Godot_v4.7.1-stable_win64.exe'
& $engine --headless --path . --script res://tests/scenarios/projectile_circle_equivalence.gd -- --with-suites
& $engine --headless --path . --script res://tests/scenarios/runtime_stress_probe.gd -- --quick --stages --scenario=legal-eight-mixed-deliveries --require-network-clear
```

No Full, import, export, rendered capture, model inference, commit, or push was
performed in this runtime lane. Production provenance pins remain root-owned.
