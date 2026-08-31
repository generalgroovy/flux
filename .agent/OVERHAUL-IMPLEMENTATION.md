# FLUX 2 implementation path to first-eight playtest

Current frontier: protocol 30, snapshot 11, preferences 9, Godot 4.7.1,
`main` (with `codex/continuous-overhaul` unified to the same checkpoint). V0–V6 visual engineering, the exact
`small`/`middle`/`large` body contract, universal movement,
positive-Flux combat, three champions, Wellspring, direct-IP Farflow, and the
one-file Windows bootstrap are green foundations—not permission to claim final
art, balance, internet accessibility, or chemistry.

Active release scope is **Windows only**. Preserve portable simulation and the
existing Linux scripts, but do not spend this pass on Linux packaging, smoke,
documentation expansion, or acceptance claims.

## Slice sequence

| Slice | Engineering work | Observable exit |
|---:|---|---|
| C0 authority | Remove duplicate browser runtime; preserve recovery commit and reusable principles; reconcile README, focused docs, roster names/ancestries/affinities; validate links/assets. | A newcomer finds one runtime, one command set, one state table, and no conflicting current roster truth. |
| C1 lifecycle | Re-run clean setup/repair/update/installed boot; improve single-screen host/join address feedback; verify safe host/guest close and packaged Farflow. | Friend needs one `.exe`, one host address, and no Godot/Git/admin rights; known NAT/signing limits are visible. |
| C2 visual runtime — complete | Keep champion body/clothing pixels separate from spells, aura, shadows, equipment and world art; enforce the three-body catalog; maintain exact `S/SE/E/NE/N/NW/W/SW` movement/facing coverage over grounded/jump/cast/hit/walk/sprint/slide/roll on one shared feet pivot, including opposite walk/sprint contact frames; bind foundation spells to reusable data-driven eight-direction delivery skeletons; review characters, movement, elevation/shadows, projectiles, environment and HUD at 50/75/100%. | Integrated rubric is 4.64/5 and V10 density is green across zoom/accessibility profiles; continuous movement/aim remain unchanged and no presentation layer changes rules. |
| C2.5 first large champion — complete | Promote The Red Baron with a body/clothing-only eight-way atlas, `iron_regent` motion, equal-budget large profile, Fire Cinderbolt and shared Ice Rimewake. | The selectable roster demonstrates small/middle/large roles; all retain universal movement/shared collision, and Red Baron combat/capture tests pass at 60/120 Hz. |
| C3 burst simulation | Extend ability content with one reusable burst specification; deterministically rotate a normalized aim vector by five fixed offsets; allocate stable left-to-right projectile IDs; bound capacity/events/snapshot representation. | Repeatable 60/120 fixtures produce identical fan ordering, hits, grazes, cover stops, cost, cooldown, and cleanup. |
| C4 eight spells | Instantiate Earth/Fire/Water/Wind/Ice/Charge/Light/Dark burst entries with stable IDs, positive costs, shared geometry, element presentation, and global Loom availability. | Either champion can weave and cast every first-eight burst; all eight remain mechanically comparable and visually distinct. |
| C5 reaction catalog | Add a fail-closed runtime catalog loader requiring exactly the 36 unordered-with-repetition pairs, symmetric lookup, unique IDs, lifecycle, counters, bounds, and worldbone policy. | Missing/duplicate/asymmetric/unbounded recipe content fails tests and boot clearly. |
| C6 exposure/contact | Add fixed-capacity element exposure cells keyed to the material grid; burst impact deposits one bounded source with owner/team/tick/strength; second source resolves one canonical recipe. | Repeated contact is deterministic, rate-bounded, authority-owned, and cannot mutate immutable worldbone. |
| C7 shared reaction primitives | Implement reusable `surface`, `flow`, `cover`, `field`, `conduction`, `visibility`, `hazard`, `reveal/refraction`, and `fracture` effect families; map all recipes to bounded parameter sets. | Every pair has a live spatial effect and counter even when several recipes share safe physics primitives. |
| C8 lifecycle/presentation | Formation telegraph, active state, residue/decay, compact label/icon, reduced/high-contrast cues, reset group, replay event, snapshot state and overflow diagnostics. | A player can identify the pair, boundary, danger/benefit, remaining phase, owner, and counter without reading source. |
| C9 Crucible acceptance | Eight attunement plinths, two-source test basin, recipe codex, reset, route-safety checks, 60/120 full tests, source/import boots, packaged boot, Farflow pair, installer rebuild. | All 36 reactions are deliberately reproducible in-game; the exact green Windows build is ready for user playtest. |

## Burst contract

```text
ordered offsets = [-24°, -12°, 0°, +12°, +24°]
aim = continuous normalized simulation vector
projectile identity = cast serial + ordered child index
element = ability content, never client or renderer choice
```

The first burst family shares base range, speed class, radius, lifetime, damage
budget, startup, and fan angles so chemistry—not disguised geometry—creates the
initial difference. Tuning may later diverge only through explicit authored
variants with new stable IDs and counterplay.

## Champion presentation contract

| Contract | Required implementation |
|---|---|
| Body taxonomy | Exactly `small`, `middle`, `large`; legacy tiny/medium/huge inputs migrate once and never enter new authored data. |
| Direction grammar | Fixed order is `S/SE/E/NE/N/NW/W/SW`; south/front is camera-facing, north is centered back, sides are profiles, and diagonals are authored or reviewed mirrors with asymmetric ancestry/clothing corrections. |
| Movement grammar | Digital input supports normalized eight-way movement and analog input remains continuous; jump launch latches accepted movement, ordinary airborne input bends momentum and immediately owns body facing, while spell aim stays independent; paid redirect/dodge remain stronger commitments. Presentation uses stable sectors/hysteresis without quantizing simulation aim. |
| Atlas contents | Body and clothing pixels only; no spells, elements, particles, aura, shadow, world art, tool, weapon, equipment or detached focus. |
| Composition | Runtime composes body, receiving-surface shadow, status/aura, cast effect, projectile and environment as separately editable presentation layers; the body layer uses a bounded `small` 0.90×, `middle` 1.00×, `large` 1.10× scale around the shared feet pivot, cast startup is anchored to a forward hand lane, and `atlas_row` is authored per champion in the visual recipe. |
| Authority | Body type constrains validated tuning/presentation ranges; hitboxes, movement, casts and outcomes remain simulation-owned. |
| Semantic reuse | Every live movement/control/cast/recovery/defeat action resolves to an atlas row through validated content; future attack/defense/interaction/taunt cues have explicit aliases and unknown IDs fail closed. |

## Eight-direction movement/presentation expansion

| Slice | Work | Observable exit |
|---:|---|---|
| D0 — complete | One validated direction resolver and fixed direction order now serve travel, facing, hand origins, effects and captures. | Boundary, zero-vector, hysteresis and repeated 60/120-equivalent tests resolve identically without touching simulation vectors; the four-cardinal body fallback remains explicit. |
| D1 — complete | Keyboard, controller, prediction, replay and Farflow movement now share all eight command sectors; digital diagonals are normalized, controller magnitude survives quantization, and radial acceleration removes diagonal startup advantage. | Equal authored heading speed/cost/collision behavior in every direction at 60/120 Hz; all components survive prediction/replay/real ENet loopback without drift, under protocol 30. |
| D2 — complete | Added diagonal grounded/cast/hit body columns for Oh Tipi and S. Wayne on the existing pivot, with validated state-scoped coverage and fail-closed cardinal fallback for every other row. | Both identities read at native scale in all eight facings before locomotion expansion; deterministic captures cover both champions and all three promoted state families. |
| D3 — complete | Added normalized diagonal walk/sprint source sheets, width-safe source normalization, and presentation-only travel-versus-aim facing with forward/backward/strafe gait cues. | Eight-way travel looks intentional during free movement, strafing, reversing and mouse/controller aiming; diagonal captures cover both champions and both locomotion states. |
| D4 — complete | Added reviewed native diagonal jump/slide/roll art for both foundation champions, retained the presentation-only invulnerability cues, and added opposite walk/sprint contacts in every direction. | Every current evasion state and both locomotion contacts preserve direction, shadow and pivot without changing simulation; fail-closed cells and 60/120 cadence tests are green. |
| D5 — complete | One fail-closed delivery contract now serves projectile/beam/spray/field anticipation, release hand origin, projectile/trail art and cast recovery in all eight facing sectors. Body and discrete art use nearest-eight presentation while simulation aim, continuous hand offsets and beam/spray geometry remain exact. | Truthful Oh Tipi south-east spray and S. Wayne north-west beam captures align empty-hand startup/release with geometry; both presenters share one validated content hash and never shift body collision. |
| D6 — complete | One validated presentation profile now exposes exact building-collision corner marks, exterior thresholds and bounded cutaway margins; near architecture becomes a warm cardinal floor plan, and local/remote actor shadows derive material tint and bounded opacity from receiving surface plus authored elevation. | Truthful diagonal Routekeeper and diagnostic Attunement Hall captures align actor contact, building art, threshold, low vault cover and simulation collision without changing topology, movement or spell geometry. |
| D7 — complete | The current non-overwriting 27-cell matrix covers all three champions, eight directions/action states, 50/75/100% zoom, all accessibility review profiles, 720p/1080p and a real mixed-champion Farflow pair; V10 adds dense spell-pattern review. | Reviewed rubric is 4.64/5 and every category is at least 4.5; V10 preserves ownership and escape lanes in all 1,080 sampled frames. New roster entries extend rather than reopen this gate. |

## Chemistry model

```text
element source A + element source B
  -> canonical symmetric recipe
  -> formation threshold/telegraph
  -> one or more bounded shared spatial primitives
  -> active window with public counter
  -> residue or deterministic decay/reset
```

The reaction catalog is authored truth. The runtime compiles recipes into safe
shared primitives rather than evaluating scripts from data. Hard bounds cover
area, propagation depth, lifetime, per-tick work, ownership, active reaction
count, event count, snapshot size, and residue count.

World structure remains three-layered:

| Layer | Chemistry permission |
|---|---|
| Worldbone | Immutable bounds, connectivity, spawns, objectives, portals, reset machinery |
| Authored structure | Typed/staged heat, cool, wet, charge, fracture, support, damage and repair |
| Transient matter | Fixed-capacity liquid/gas/loose solid/field/residue cells with deterministic cleanup |

## Verification ladder

1. Content/schema tests and exact catalog closure.
2. Fixed-tick unit fixtures at 60 and 120 Hz.
3. Simulation integration: cost, cooldown, collision, cover, reset, overflow.
4. Network serialization and hostile-input refusal.
5. Windows source boots at 60/120, then imported-resource boots.
6. Visual capture at 50/75/100%, high contrast, reduced effects, and multiplayer.
7. Packaged Windows boot, clean install/repair/update, and 2/4/8 Farflow journeys.
8. Diff/provenance/docs/memory review, then one reversible commit and push.

Begin the next slice immediately after a green checkpoint, but never mix an
unproven half-system into the last known playable commit. Pause for the user
only after C9 or a real permission/product/technical blocker.
