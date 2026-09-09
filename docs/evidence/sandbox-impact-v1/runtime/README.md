# Chemistry contact broadphase: local runtime evidence

Captured 2026-09-09 on AMD Ryzen 3 7320U, official Godot 4.7.1, Windows.
This records an uncommitted local candidate, not release or multiplayer-capacity acceptance.

The production change adds a stateless rejection guard before the existing
sampled `_entry_point` algorithm in `src/sim/chemistry/element_chemistry_system.gd`.
It does not add caches, array scans, network fields, damage rules, or new physics.
Overlapping bounds run the unchanged sampled algorithm; linked-path shapes always
fall through, including missing links and remote bent path points.

## Result

| Metric | Baseline repeat 1 / 2 | Candidate repeat 1 / 2 |
| --- | --- | --- |
| SimWorld.step p95 | 10.033 / 10.207 ms | 6.726 / 6.792 ms |
| Projectile stage p95 | 7.548 / 7.614 ms | 4.035 / 4.129 ms |
| Ticks above 8.333 ms | 162 / 164 | 16 / 18 |

Step p95 improved by 32.96% / 33.46%, and projectile-stage p95 by 46.54% / 45.77%.
Medians were essentially unchanged; p99/max remained noisy, including a worse
second-repeat step p99. Chemistry-stage timing did not improve. These results do
not establish rendered FPS, field-heavy performance, a sustained 120 Hz guarantee,
socket capacity, or a human play-quality improvement.

Each profile passed 13,016 assertions with zero failures and zero legal network-gap
samples. Both repeats used 720 ticks after the fixture's 120-tick warmup; peaks were
40 projectiles, 29 reactions, and **zero fields**. All 12 checkpoint hashes, the final
hash, and every non-timing report field matched baseline/candidate in both repeats.
The compared and excluded field names are explicit in `comparison.json`.

Final hash for all four traces:

`4b374aef7176d38ece40cb0bd3966b5f7713e55fa94106efe2ff64bbc69cb25f`

## Reproduce and inspect

From the repository, using the pinned official engine:

```powershell
$engine = Join-Path $env:LOCALAPPDATA 'FLUX-dev\godot-4.7.1\Godot_v4.7.1-stable_win64.exe'
& $engine --headless --path . --script res://tests/scenarios/runtime_stress_probe.gd -- --quick --stages --scenario=legal-eight-burst
& $engine --headless --path . --script res://tests/scenarios/chemistry_broadphase_equivalence.gd
```

The profile uses seed 608120, protocol 47, snapshot schema 18, and the same flags
for baseline and candidate. `runtime_stress_probe.gd` constructs its own fixed
12,000,000 x 6,000,000 millipixel CollisionWorld with zero obstacles for this
scenario; the sandbox-annex map JSON is not loaded. Metadata, ability/champion
content hashes, and SimWorld source hash matched exactly. The full logs retain
stage distributions, snapshot measurements, counters, and checkpoint hashes.

The baseline chemistry source SHA was recorded before implementation:
`c8aa04a3f853bfce01d6dcabf03dd3b231f8c9662841ef6416b2db42bd49f92c`.
The candidate SHA is
`b0596612896e2c475994894a99aff40ed2e047866d1ec536eec767bd66d8b28f`.
This evidence does not retain a separate executable baseline checkout. Re-running
the current command measures the candidate, not the pre-change implementation.
`comparison.json` includes SHA-256 hashes of all six logs and the source files at
packaging; file hashes establish identity, not release provenance.

## Differential and focused correctness evidence

`equivalence.log` records **84,312 assertions, zero failures**:

- 23,760 generated exact legacy/candidate entry-query comparisons, each also
  checking that canonical reaction state was not mutated.
- All 36 recipes plus four invalid-wire fallback cases, 11 headings, positive,
  negative and near-100-million centers, reused/mutated instances, odd and zero
  lengths, independently changed endpoints, missing and bent linked paths,
  phase/pulse times, zero-length/tangent/reversed/short and sample-capped segments.
- Existing element-chemistry (1,760), projectile-chemistry integration (10,459),
  and combat (24,573) assertions, including clipping, health/capacity, optical
  damage budgets, approach/continuation paths, and interaction masks.

The frozen test-only `_legacy_entry_point` retains the original sample-count,
integer scaling, early-hit order, and return dictionary. The guard rejected
8,768 / 23,760 queries (36.9%). A diagnostic micro-pass over the same 1,425 calls
in both ordering directions measured legacy 299.200 / 322.183 ms and candidate
79.507 / 82.783 ms, with identical checksums. This mixed generated sample is not
a representative gameplay distribution; no timing threshold is a test assertion.

## Conservativeness and remaining gaps

Every original sampled query point lies inside its endpoint AABB, including
signed truncation. Disk/annulus bounds use the outer radius; corridor bounds use
the current endpoint capsule; cover/plane/lens bounds use exactly the same
perpendicular endpoints as `contains`. Strict separation retains tangencies.
Holes and pulse windows only remove points. Geometry is recomputed on every call,
so moved centers, changed lengths and actual bent/reflected/clipped segments do
not depend on stale cached geometry. Linked geometry does not use the guard.

The generated probe is not exhaustive over every integer combination. It covers
large coordinates without arithmetic overflow; behavior for malformed null
reaction/config inputs, integer-overflow constructions, or future recipe shapes
is not established. Those are not newly supported input contracts. Invalid-wire
disk fallback is covered, but not every invalid serialized state. If shape
semantics change, update and rerun the frozen-oracle comparison. Valid authored
simulation inputs retain the original narrowphase and public-call behavior.

No model inference, Full suite, import, export, or rendered performance run was
performed for this evidence. All owned engine processes ended normally; stderr
files are empty. Broader integration/export acceptance belongs to the parent task.

## Files

- `baseline.log`, `candidate.log`: untouched standard output from the two profiles.
- `equivalence.log`: differential oracle and three focused authority suites.
- Corresponding `.err` files: empty standard error captures.
- `comparison.json`: compact machine-readable identity, counters, hashes, timings,
  and explicit non-timing equivalence comparison.
