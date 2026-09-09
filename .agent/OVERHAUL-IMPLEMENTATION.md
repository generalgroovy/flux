# FLUX active implementation queue

Status: paused at user request, 2026-09-09; M0/M1 and D1 automated checkpoint
passed. W4 performance follow-up and human acceptance remain open. No M2 or
new art/map slice has started. W0-W5 are the preserved predecessor checkpoint.

Authority: [SPECIFICATION.md](../SPECIFICATION.md), validated runtime/content,
and [CURRENT-CAST.md](../docs/CURRENT-CAST.md). This is the only active queue.
Active playable profiles: 29.
Weekly cutoff: **10% remaining** for this workstream; earlier floors are historical.

## Verified baseline and delivery boundary

Latest: [Rampart M1 checkpoint](../docs/RAMPART-M1-CHECKPOINT.md), Full95 /
537,802, 38 actual-game captures, strict portable export/raw boot, exact frozen
source and same-export localhost Farflow lifecycle. The current pointer selects
this new M1 build; previous playtest-clarity files remain intact. The historical
installer EXE was unavailable at final recheck; its receipt does not make it a
current runnable download. Use `current-checkpoint.ps1 -ReportOnly` to see the
separate current-portable and historical-installer statuses.

The [playtest clarity checkpoint](../docs/PLAYTEST-CLARITY-CHECKPOINT.md)
is the verified integrated baseline: Full **94 suites / 537,041 assertions**,
zero failures/stderr, 26 actual-game captures, strict Windows portable export,
PCK identity verification and isolated standalone boot. The builder verified
3,079 frozen source/package files remained unchanged. Later work does not
inherit this verification. The [warm-style/trails checkpoint](../docs/WARM-STYLE-TRAILS-CHECKPOINT.md)
remains preserved historical evidence.
Names, stats and affinities stay distinct across three shared clothed body sizes.
Named skins and human movement/style acceptance are not complete.

[Current checkpoint pointer](../docs/current-checkpoint.json) selects the exact
local portable and its evidence, separately from the older verified QV installer.
Run `pwsh -NoProfile -File scripts/current-checkpoint.ps1` in PowerShell 7 to verify the
pinned local bytes; file verification does not launch, install or accept gameplay.
The old installer is not this current portable. Do not bypass its newer sibling's
Windows policy refusal, retry by changing identity, or publish without authority.

## Small-slice execution order

| Slice | Deliverable | Promotion gate / current state |
|---|---|---|
| W0 | Workflow and delivery truth: one queue, preserved history, explicit checkpoint pointer and exact-file verifier | Automated integration passed: 105 scope-guard and 87 checkpoint assertions, current-state integration and exact local hashes; current pointer selects the verified W5 portable |
| W1 | Material, protection and readability: bounded source-derived feedback and UI corrections | Automated slice/integration passed: clearer resource/spell/protection HUD and quieter harmless material, with paid Float/cast/protection-expiry captures; human readability/accessibility acceptance pending |
| W2 | Small -> Middle -> Large movement and style refinement | Automated slice/integration passed: shared shading and alternating arm counter-swing, independent aim/travel and fixed bones/anchors; human movement/style acceptance pending; moving-cast packed offsets remain a candidate, not live |
| W3 | Practice loop: teach one paid action, its effect and counter, then repeat | Automated slice/integration passed: Commons -> Movement -> Crucible -> Sparring floor guides, compact live practice cards and source-derived hover/F4 details; walls/map authority unchanged; human route-learning acceptance pending |
| W4 | Balance, load and networking | Measurement complete, performance gate failed: eight-player empty-obstacle simulation p95 9.868-10.606 ms exceeds 8.333 ms, plus separately measured snapshot work; paid Rapid/Bolt economy exposed a role-choice follow-up; same-export local Farflow lifecycle smoke passed, but actual rendered load and physical two-PC acceptance remain open |
| W5 | Full checkpoint, immutable export and honest handoff | Automated delivery passed: Full 94 / 537,041, 26 actual-game captures, strict export/PCK identity/raw boot and exact source/payload/evidence hashes; current pointer promoted after verified delivery; no new installer or publication |

## Mirror-first expansion (latest user priority)

The [mirror and workshop contract](../docs/MIRROR-AND-WORKSHOP-PLAN.md) defines
bounded changes authorized after W5. These are not features of the preserved W5
portable. Complete and verify one playable slice before admitting the next.

| Slice | Small deliverable | Acceptance / state |
|---|---|---|
| M0 | Shared finite reaction contract: warning, active state, expiry, ownership, geometry and counters | Automated foundation passed with M1; derived bounded movement layer, exact-tick prediction, compatibility policy; no recursive reactions or free movement resets |
| M1 | Earth + Earth Rampart: breakable cover and temporary wallrun/kick surface | Automated checkpoint passed: safe formation/escape, expiry/destruction, three sizes/eight directions, host/prediction parity, tileable masonry and actual rendered contrast; human playtest pending |
| M2a | Ice mirror: readable slow lane with a deliberate sliding opportunity | Planned; bounded actor/projectile influence, no permanent loss of control |
| M2b | Charge mirror: acceleration opportunity and a finite discharge | Planned; no stun loop, speed cap or per-airtime budget bypass |
| M3 | Fire, Water, Wind, Light and Dark mirrors, one at a time | Planned; one primary purpose, expressive opportunity, explicit counter and phase for each |
| M4 | Mirror workshop acceptance and deterministic load audit | Planned; all eight mirrors, mixed ownership, expiry, snapshots, replay, actual-map render/load; measured W4 budget miss remains open |
| R1 | Small race silhouettes over approved shared bones and gait | Planned; every assigned race visibly distinct, eight unambiguous aims and independent travel; no baked magic |
| R2 | Middle race silhouettes using the same reusable art contract | Planned; phase/anchor consistency and clear alternating feet |
| R3 | Large race silhouettes, then full cast selection coverage | Planned; size-only hurtboxes, common clearance, bounded shared texture cost; final detailed named skins still require human acceptance |
| W6 | Larger Wellspring layout and playable route pilot | Planned; Commons, Farflow dock, movement grounds, elemental workshops, sparring, roomy outer loop |
| W7 | Contextual stations plus compact access to essential menus | Planned; map actions teach and invite play, routine rebinding/session configuration must not require a long walk |
| D1 | Verified Windows test checkpoint per admitted group | M1 passed Full95/537,802, 38 captures, 3,083 frozen files, export/PCK/raw boot and same-export local Farflow; pointer promoted, no installer/publication |

Performance optimization remains a cross-cutting gate: avoid per-player copies
of map geometry, unbounded effect scans and increased asset banks. Compare
identical paid inputs and authoritative state hashes before accepting a speedup.
Rapid remains trail-free; no unrequested attack economy changes accompany M1.
Review the held packed moving-cast candidate separately before promotion.

Keep explicitly isolated ownership lanes. Follow-ups are not permission for
speculative expansion. Report passed, failed, blocked and not-run separately.
Keep evidence from failed attempts; never promote an artifact solely because a
script completed or an atlas has occupied cells. Human style/feel, actual friend
play and sustained rendered 120 FPS remain open until directly demonstrated.

## Scope and handoff rules

- Preserve dirty changes, previous exports, original art sources and historical receipts.
- Keep simulation/network authority outside presentation. Preserve collision,
  size-only hurtboxes, fixed anchors and the source-cast chemistry budget unless
  the user explicitly authorizes a bounded rule change.
- Use focused source checks first; serialize all engine/import/capture work.
  A draw test must not save fixture preferences or start network/audio services.
- Record exact files, acceptance evidence, outstanding human gates and the next
  smallest useful slice. No download, security change, installer retry or public
  release is implied by finishing this queue.

The [unaltered prior queue text](../docs/history/OVERHAUL-IMPLEMENTATION-20260909.md)
preserves earlier S/B/A/R/H waves, held candidates and checkpoint numbers. Those
records explain history; they do not compete with W0-W5 or re-open completed work.
