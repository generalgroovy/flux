# Remaining mixed-tail projectile drill

2026-09-09, Windows / Ryzen 3 7320U / pinned Godot 4.7.1. **Initial investigation:
no production optimization was attempted during this first drill.** Existing
inventory and contact guards remain unchanged. This is not a Full, render,
export, physical-network, or sustained 120 Hz acceptance receipt.

Root subsequently approved one batch-list trial based on this evidence. Its
production scope, measured p95 improvement, exact oracles, rejected initial
attempt and remaining limits are in [BATCH-CANDIDATE.md](BATCH-CANDIDATE.md).
The first ranked seam below is therefore a historical proposal, now trialed;
the second and third remain unimplemented.

## Finding

The expensive mixed ticks are dominated by repeated projectile/reaction
enumeration, filtering and conservative-bounds queries, not sampled contact or
line-of-sight work. The existing bounds guard already rejects almost everything
that reaches it in this particular fixed, parallel-lane fixture.

One current-source paired run covered 120 warmup, 720 measured, 741 natural
cleanup and one final idle tick. The separately timed, unmodified production
step measured median **3.850 ms**, p95 **9.316 ms**, p99 **10.226 ms**, maximum
15.642 ms; 121 measured ticks exceeded 8.333 ms. These are one-run diagnostics,
not a before/after optimization comparison.

| Actual measured-window count | Total |
| --- | ---: |
| Projectile chemistry-interaction calls | 21,474 |
| Reaction entries visited | 578,770 |
| Active reaction entries visited | 439,229 |
| Projectile-eligible entry queries | 105,057 |
| Rejected by existing strict bounds | 105,029 (99.973%) |
| Actual contains samples | 75 |
| Successful entry queries / clear-line calls | 17 / 17 |
| Actual clear-line samples | 255 |
| Already-masked hits after geometry | 0 |

Only wires 301 and 327 were projectile-eligible in this mixed journey, with
54,487 and 50,570 queries respectively. This is not coverage of all 36 reaction
behaviors, dense close combat, or a different live-map obstacle arrangement.

For the slowest 36 production ticks (top 5%), median counts were 86 projectile
interactions, 2,340 reaction visits, 2,236 active visits, 516 eligible queries
and 516 strict-bounds rejects. The instrumented observer's bucket medians were:

| Observer bucket | Median on those slow ticks |
| --- | ---: |
| Entire projectile stage | 8.279 ms |
| Chemistry interaction, inclusive | 5.406 ms |
| Entry query, inclusive of bounds/contains | 2.155 ms |
| Bounds calculation itself | 1.296 ms |
| Interaction minus entry/line buckets | 3.235 ms |
| Contains samples | 0 ms |
| Clear-line samples | 0 ms |

The residual includes iteration, active/wire filtering, response construction,
dispatch and instrumentation. Timers and dictionary counters add overhead;
these values are **not unbiased production helper timings**. Buckets are nested,
and their independently computed percentiles must not be summed. The trace
establishes where repeated work occurs, not how many milliseconds an unbuilt
optimization would save. The rare terminal spike at tick645 remains separately
visible in the raw rows (34 projectiles disappear; observer terminals4.121ms).

## Ranked next seams, not approved changes

1. **One order-preserving candidate list per projectile batch.** In
   `CombatSystem.advance_projectiles`, build an ephemeral list of currently
   active projectile-interacting reaction references once, then pass it only to
   `ElementChemistrySystem.projectile_interaction`. Keep the full original list
   for Heavy rewind, blast and cover/line tests. Retain the inner active check:
   earlier projectiles can destroy cover and shorten its decay within the batch.
   Do not filter by health or interaction mask, because response IDs and later
   checks must keep their existing behavior. Of 578,770 visits, 473,713 are not
   eligible; at a representative 90-projectile/27-reaction tick with six eligible
   reactions, visit work could fall from 2,430 to about 567 including the one
   selection pass. This is the largest plausible low-state tail opportunity,
   but **no timing gain has yet been measured**.

   Equivalence conditions: preserve reference identity, duplicates and order;
   tick and wire IDs are fixed during the batch; inactive reactions cannot become
   active there; health/capacity/pulse/decay mutations remain live through shared
   references. `ElementReactionState.active` is phase-only. Geometry and new
   chemistry formation occur later in the world step, not during this batch.
   Public standalone interaction calls must retain their original behavior.
   Test against the frozen complete projectile loop with all36 recipes,
   forming/active/decay boundaries, health-zero active cover, duplicate references,
   same-batch destruction, earlier masks, optical split capacity and ordered
   events. Require all-tick state/event and cap/counter equality plus a fresh
   same-input uninstrumented p95 comparison before retaining any implementation.

2. **Ephemeral current-batch static bounds.** The 105,029 bounds misses repeatedly
   derive current shape/endpoints and return a miss dictionary. Precomputing only
   immutable geometry once per batch could address part of the observed bounds
   bucket. It has a larger proof burden: all center/length/endpoint/path mutations,
   linked-path fallthrough and callback reachability must be audited first. Do
   not introduce a persistent cache or reuse geometry across ticks. This is
   second-ranked behind removing ineligible iteration altogether.

3. **A boolean-only entry path for projectile callers.** `_segment_enters` throws
   away the point from `_entry_point`, whose miss path constructs a dictionary.
   The trace counts105,057 entry results, nearly all misses. A shared exact
   sampler with a boolean-only interface might avoid that construction while
   preserving ray contact points. Allocation counts/cost were not measured by an
   allocator, and the likely win is smaller than reaction-list filtering.
   Do not pursue first or duplicate the geometry algorithm without an oracle.

Further micro-tuning of contains/clear-line or skipping already-masked contacts
is not supported by this workload: those paths are almost absent here. Wider
footprints would change that workload and still need their own costed acceptance.

## Harness and proof

`tests/scenarios/runtime_projectile_drill.gd` reuses the existing real catalog,
commands and fixed 12,000 x 6,000 / zero-obstacle world from
`runtime_stress_probe.gd`. No live Wellspring JSON is loaded. Source hashes are
recorded in the metadata and `drill-summary.json`.

Three test-only companions retain source-derived observed bodies:
`runtime_drill_combat.gd`, `runtime_drill_chemistry.gd`, and
`runtime_drill_sampler.gd`. The last uses the current stateless owner inventory;
all ordinary movement/target/terminal helpers remain production calls. No
production source or shared normal test runner was edited.

**5,669 assertions, zero failures, empty stderr.** Every observed tick, including
reversed measured command order, matches actual canonical state and ordered
public events. Both sides naturally clean up. The rolling state/event trace is
`ff2bdc56764b3440760974b7e81ae2b11660e83c1180c32d8d3673ec6de7f543`,
identical to the prior current-source trace. Final clean hash is
`d4dafe70a3c318a00dc1ced33d4bdcd49b7ae18308a9f33f31f0dfe9f1bede25`.
Exact events:157 paid starts,225 spawns,202 expiries,76 formations,13 refusals.

After capture, the entry scenario received a fail-closed raw-source-hash guard
for its copied combat/chemistry bodies. Only this preflight guard was added;
the mirrored mechanics and measurement remained unchanged. It was inspected and
the pins verified, but not followed by another engine run. Recorded scenario
SHA is the captured version; final guarded scenario SHA is
`54e020ecf926ecb04853e2ee90a5bbb723ee6f4a026b9ef50ef7cb2089ff68db`.
The subsequent approved batch trial added its reviewed source hash and a Field
selector; its final tested source identity is in `batch-comparison.json`.
Future source changes require explicit mirror review and pin refresh.

```powershell
$engine = Join-Path $env:LOCALAPPDATA 'FLUX-dev/godot-4.7.1/Godot_v4.7.1-stable_win64.exe'
& $engine --headless --path . --script res://tests/scenarios/runtime_projectile_drill.gd
```

`projectile-drill.log` preserves all720 measured rows and metadata; its stderr
receipt is empty. `drill-summary.json` contains all/slowest/over-budget/dense
conditional summaries and the12 slowest raw rows. Timing changes after source,
hardware, cache or workload changes require a new run, not reuse of this result.
