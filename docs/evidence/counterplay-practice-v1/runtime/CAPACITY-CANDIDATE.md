# Post-cast owner inventory: candidate outcome

Local candidate, 2026-09-09. Correctness and measured modest median improvement
support retaining this bounded helper. It does not solve mixed-load 120 Hz timing.
This is not Full, export, rendered-frame, physical-network or release acceptance.

## Exact change

Only the post-cast owner-material dictionary in `SimWorld.step` calls the new
stateless `_owner_material_slots()`. It makes one fresh multi-owner inventory of
projectiles, deposits and living pending cast patterns. Empty/single-player
worlds retain the old per-owner query. Sequential pre-payment
`available_cast_capacity()` and `_free_material_slots()` are unchanged.

The helper preserves global and owner minima, full five-lane pending reservations,
defeated-owner material, ignored dead pending casts, orphan global reservations,
duplicate player-entry counting and output-key order. Fields are not rescanned
because the requested x component never depends on Field capacity. No cache,
schema, constants, cap, ordering, damage, economy or protocol change was added.

## Correctness

The standalone `owner_material_capacity_equivalence.gd` compares every requested
owner to the unchanged original query across 384 seeded worlds, both traversal
orders, and explicit five-lane boundaries: **5,784 assertions, zero failures**.
It checks exact dictionaries/key order and no state mutation. Query-only edge
fixtures include empty/offline, capped/overbooked, missing/zero owners, duplicate
entries, unknown pending wire, dead pending casts, and unrelated Field counts;
these robustness fixtures are not claimed to be network-valid game states.

The two candidate production profiles also passed: mixed **16,551**, Field opening
**14,733** assertions, zero failures and zero legal network-gap samples. The
unchanged StageSampler uses the old per-owner loop and matches actual canonical
state and combat events after every measured tick. All baseline checkpoints,
final hashes, shared non-timing report fields and Field phase tick counts match.
Only the expected SimWorld source hash changes in runtime metadata. The mixed
report has three documented test-only additions (caps and empty Field diagnostics);
`capacity-comparison.json` lists these explicitly rather than hiding schema drift.

A small non-timing regression was subsequently added to the existing `core` unit
suite so normal Full retains offline/empty, pending Wave, orphan/global-cap,
dead-owner, reorder, deposit-cap and state-purity coverage. That addition belongs
to the parent's integrated validation; no additional engine run was made here.

## Observed CPU result

| Fixture/metric | Baseline repeat 1 / 2 | Candidate repeat 1 / 2 |
| --- | --- | --- |
| Mixed step median | 4.324 / 4.429 ms | 4.107 / 4.123 ms |
| Mixed step p95 | 10.819 / 10.407 ms | 11.004 / 10.213 ms |
| Field-opening step median | 2.432 / 2.449 ms | 2.191 / 2.185 ms |
| Field-opening step p95 | 4.585 / 4.443 ms | 3.873 / 3.763 ms |

Mixed median saved 0.217 / 0.306 ms (5.02% / 6.91%); Field-opening median saved
0.241 / 0.264 ms (9.91% / 10.78%). Mixed p95 went slightly the wrong way once and
slightly the right way once: **no consistent mixed tail improvement is established**.
Field-opening p95 improved in both repeats, but the workloads differ and this is
not a general Field or frame-rate guarantee. Maxima remain noisy, including a
34.986 ms mixed-candidate outlier and a 15.157 ms Field-opening outlier. Do not
convert reduced median inventory cost into a sustained 120 Hz claim.

A separate same-state microdiagnostic ran 480 queries per pass in both orderings:
legacy 115.980 / 113.863 ms; candidate 39.216 / 40.426 ms; matching checksum 6496.
This is approximately 65% less helper time on the diagnostic mixture, not 65%
less simulation time. It is not a representative gameplay distribution and has
no hardware-dependent pass threshold.

StageSampler deliberately stays on the legacy capacity implementation as the
oracle. Its post-change capacity timings therefore **must not be presented as
candidate helper timings**. Whole production steps and the separate helper
diagnostic are the before/after measurements. Source/content/command seeds match
apart from the intended SimWorld helper and documented test reporting changes.

## Reproduce / artifacts

Use the two baseline commands in `README.md` on current sources for the candidate,
and run the standalone oracle with:

```text
--headless --path <repo> --script res://tests/scenarios/owner_material_capacity_equivalence.gd
```

`mixed-candidate.log`, `field-opening-candidate.log`, `capacity-equivalence.log`
and their empty stderr files are untouched copies. `capacity-comparison.json`
records raw candidate reports, exact comparison scope, source/log SHA-256 hashes,
and original baseline metrics. The baseline logs remain unchanged. The earlier
chemistry guard SHA stays `b0596612896e2c475994894a99aff40ed2e047866d1ec536eec767bd66d8b28f`;
the candidate SimWorld SHA is
`8acc7c3539776c9c8d0d2ad308563083becfe8d07274a276646ea63ece008112`.

All owned engine processes exited normally. No local model, Full, import/export,
commit, push or publication was run by this runtime lane. Further optimization
should return to the measured projectile/chemistry-heavy tail, not enlarge caps
or footprints merely because this inventory work is cheaper.
