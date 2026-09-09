# Radiance / Steam: paid counter evidence

Status: **guarded capture v2 current; capture v1 superseded and retained**.
The current five frames and render logs are in [v2](v2/). The shared capture
harness now makes fixture preferences transient. The actual
[preferences lifecycle guard](../capture-preferences-guard.json) passed:
saved settings retained the same SHA-256 and last-write timestamp across both
complete rerun processes, including teardown. Current render stderr is empty.

That guard covers these reruns only. Earlier unguarded capture teardown could
persist fixture defaults; this is not proof that original pre-v1 user settings
were preserved. No speculative settings restoration was performed. Root-level
v1 PNGs and render logs remain unchanged, explicitly superseded for acceptance.

Local Windows evidence, 2026-09-09, official Godot 4.7.1. All logs and original
1280 x 720 PNGs were copied unchanged. `manifest.json` records original paths,
byte lengths, verified source/copy SHA-256 identity, artifact status and the
linked guard's hash. No engine was launched while packaging this folder.

## Checkpoints and scope

`focused-v3.log` records **4,197 assertions, zero failures**, with empty stderr.
It covers the conditional coach, real paid casts, current geometry/phases,
reveal expiry, worldbone interruption, host/snapshot parity and nonmutation.
It predates the final one-line actual-origin assertion refinement and root's
standalone Steam hint pointing to Light + Light Radiance. The root task reports
the later integrated **91 suites / 462,658 assertions / zero failures**, including
chemistry-practice-coach at 4,198. That checkpoint predates the harness lifecycle
fix. The [final integrated rerun](../full-receipt.json) passed91 suites /462,661
assertions /zero failures and stderr in90.542s, including the teardown guard.
The Full log belongs to the parent checkpoint, not this earlier focused log.
No historical log was rewritten to the newer count.

The current [v2 render log](v2/render-root-v2.log) records five actual
compatibility-rendered frames using inherited gameplay, material,
actor-visibility and compact-card drawing:

| Captured stage | World tick | Target reveal / conceal ticks | Chemistry-visible |
| --- | ---: | ---: | --- |
| Overlap, normal and reduced | 300 | 2 / 2 | true |
| Reveal expired, normal | 302 | 0 / 2 | false |
| Worldbone, normal and reduced | 287 | 0 / 2 | false |

Current frames: [overlap normal](v2/overlap-normal.png),
[overlap reduced](v2/overlap-reduced.png),
[reveal expired](v2/reveal-expired-normal.png),
[worldbone normal](v2/worldbone-normal.png), and
[worldbone reduced](v2/worldbone-reduced.png). Their bytes match the earlier
v1 images: the correction isolates teardown, not rendered content.

The overlap card intentionally remains conditional even when the target is
hidden: two current reaction footprints overlap, but the model has no actor
status/collision argument and cannot claim an individual was revealed.

## Actual cast and phase receipts

The earlier `paid-cast-probe-v1.log` retains exact startup receipts. Each setup
uses four different paid casts, **6 Flux each, 24 total**, with ordinary cooldown
and elapsed-world-time waits; no refill or automatic casting is added to play.
Requested endpoints are pixel coordinates; simulation stores millipixels.

| Cast | Wire | Requested endpoint | Open / blocked startup tick |
| --- | ---: | --- | --- |
| Light Bolt, first | 173 | 1504, 1328 | 0 / 0 |
| Light Bolt, second | 173 | 1504, 1328 | 39 / 39 |
| Fire Bolt | 145 | 1600, 1328 | 179 / 166 |
| Water Bolt | 140 | 1600, 1328 | 206 / 193 |

Light + Light produces Radiance (334); Fire + Water independently produces
Steam (310). Their origins occupy distinct 96 px admission cells. Their active
footprints overlap; neither reaction is an input to another recipe.

| Setup | Radiance active / decay / expiry | Steam active / decay / expiry |
| --- | --- | --- |
| Open | 109 / 409 / 457 | 259 / 511 / 571 |
| Worldbone | 96 / 396 / 444 | 246 / 498 / 558 |

The immutable test wall spans (1528,1304) to (1536,1360) px. It also intercepts
the Light projectiles, so blocked Radiance's actual origin is
(1526.972,1370.800), not the requested cursor endpoint. Open Radiance forms at
(1503.996,1327.992); Steam forms at (1599.934,1327.995). Tests use actual terminal
origins, current masks and the existing clear-line rule. Leaving Radiance gives
one remaining reveal tick, then zero; Steam persists. Radiance's earlier decay
also stops refreshing reveal while Steam still conceals. Both results later
expire without damage, healing or a recursive descendant.

## Reproduce and limitations

From the repository, using the pinned engine:

```powershell
. ./scripts/flux2-common.ps1
$counterEvidenceEngine = Get-FluxGodot
& $counterEvidenceEngine --headless --path . --script res://tests/run_all.gd -- --suite=chemistry-practice-coach
```

For an actual render, use `tests/visual/capture_chemistry_counter.gd` with a fresh
`--output=res://.godot/chemistry-counter-v1/render-NEW` argument. The helper
`Invoke-FluxGodotChecked` can run it with `--rendering-method gl_compatibility`
and a hidden window. Existing evidence/output directories must not be overwritten.

The wall exists only in the isolated test collision fixture, not the campus map.
Target positions are staged; cast starts and all chemistry/status/expiry outcomes
use real simulation ticks. The timing probe precedes the final snapshot-valid
target-profile setup; host/guest parity is proved by the later focused suite.
Frames demonstrate rendered state, not human route execution, learning success,
fun, combat readability under load or multiplayer performance. This folder does
not prove export/installer/publication, and later-source reruns may differ.
