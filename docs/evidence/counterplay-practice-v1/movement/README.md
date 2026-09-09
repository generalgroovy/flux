# Southern movement-practice coach evidence

Status: finalized preference-safe v3 capture package, 2026-09-09; focused/integration evidence passed and all six image contents inspected. Final Full after the teardown guard passed. No human gameplay, controller hardware, performance or release acceptance is claimed.

## Verification

| Run | Result |
| --- | --- |
| [Focused model/guide](focused.log) | Movement coach 252 + existing guide 339 = **591 assertions**, zero failures |
| [Inherited integration/shared chemistry](integration-focused.log) | Integration 124 + movement coach 252 + existing chemistry coach 4,197 = **4,573 assertions**, zero failures |
| [Parent Full before fixture guard](../full-before-fixture-guard.json) | **91 suites / 462,658 assertions / zero failures / zero stderr**, 98.525 seconds |
| [Final Full after fixture guard](../full-receipt.json) | **91 suites / 462,661 assertions / zero failures / zero stderr**, 90.542 seconds |
| [Actual-render capture](render.log) | Six successful 1280x720 frames, Godot 4.7.1 GL compatibility |
| [Complete-process preferences guard](../capture-preferences-guard.json) | Saved preference SHA-256 and last-write timestamp identical before/after the safe movement and chemistry reruns |

The focused totals are separate runs, not additional unique Full assertions.
All three copied stderr files are empty. The linked initial Full predates the
test-only capture teardown guard. Its three new teardown assertions passed in the
refreshed Full receipt in parent-owned checkpoint documentation;
the historical focused logs here are not relabeled as that later run.
[MANIFEST.json](MANIFEST.json) records
the exact byte size and SHA-256 of every copied PNG and log. `.gdignore` keeps
this diagnostic evidence out of runtime asset import.

## Actual frames

| Frame | Mode / world zoom | Authoritative fixture state |
| --- | --- | --- |
| [Grounded](grounded.png) | Keyboard, normal, 100% | Tick 0; Stamina 660/660; ordinary walking and optional wallrun hint |
| [Wallrun](wallrun.png) | Keyboard, normal, 100% | Tick 13; Stamina 642/660; fresh Jump kick and finite air-budget caveat |
| [Wall exit](wall-exit.png) | Keyboard, normal, 100% | Tick 25; Stamina 611.2/660; paid turn and fresh held Float instructions |
| [Float](float.png) | Keyboard, normal, 100% | Tick 37; Stamina 572.4/660; hold height, release to fall, finite duration |
| [Float controller 75%](float-controller-75-reduced.png) | Controller labels, reduced, 75% | Same live Float state at tick 37 |
| [Float controller 50%](float-controller-50-reduced.png) | Controller labels, reduced, 50% | Same live Float state at tick 37 |

All six image contents were visually inspected during packaging; every final v3
PNG is byte-identical to its inspected v2 candidate. The existing compact card's
title, Stamina phase and two execution lines fit without truncation; at 50%
world zoom the actor is smaller but the screen-space coach remains readable.
This is a representative matrix, not every state at every zoom/effects setting.

## Fixture and acceptance boundary

`tests/visual/capture_movement_coach.gd` uses the inherited gameplay draw through
`ChemistryCoachHarness.configure_fixture(true)`. It explicitly stages one start
beside the actual southern worldbone surface 115, then uses ordinary 120 Hz
`SimWorld.step` commands to approach, pay for wallrun, kick away and enter paid
Float. It waits through the actual opening commitments and checks each resulting
coach kind. The later controller/reduced/zoom frames reuse that same resulting
Float state; controller label mode is selected programmatically, not by a
physical controller session.

The new integration tests exercise inherited free-practice admission for actual
area entry/exit, every menu/modal, focus/rearm, alive identity, valid host and
guest round states, missing-guest fallback and spectators. Input tests retain
the real `_unhandled_input` and movement-device observer, but suppress rendering
and unrelated station action-map queries; no InputRouter is constructed. They
verify that simulation, preferences and the complete global InputMap do not
change. The unchanged chemistry suite separately covers the shared gate.

These captures are not a played match, timed challenge, achievement, proof of
mastery, animation-template approval, a complete accessibility evaluation,
rendered FPS benchmark, physical LAN test or installer/export result. Font-fit
and state tests are not human fun or comfort acceptance.

The successful v3 render stdout is preserved verbatim. The shared harness now
sets `preference_overrides_are_transient = true` in its constructor, retaining
ordinary teardown cleanup without saving fixture settings. The linked guard
record independently checked the actual saved file across both complete capture
processes: SHA-256 stayed
`f8e2d8f27f7720ef09c473cf9612a92f042997acce7df9395447cf11b10f1d8c`
and the UTC last-write timestamp stayed at .NET ticks `639245355837132274`.
This proves those safe reruns only. Earlier unguarded teardown could persist
fixture defaults; it does not establish the user's original settings, and no
speculative settings restoration was performed. Earlier v2 candidate captures
are superseded; all six packaged files were copied from v3.

## Reproduce the focused checks

```powershell
.\scripts\test.ps1 -Tier Focused -Suite movement-practice-coach,movement-guide-model
.\scripts\test.ps1 -Tier Focused -Suite practice-coach-integration,chemistry-practice-coach,movement-practice-coach
```

Run engine checks serially with runtime profiling. For a new render, use the
named capture fixture and a fresh `--output=res://.godot/movement-coach-render-NAME`
directory; retain the transient-preference constructor guard (or isolated user
data) for capture teardown. No engine was run and no production/test file was edited while this
evidence subfolder was packaged.
