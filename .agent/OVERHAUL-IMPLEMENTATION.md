# FLUX 2 implementation path to first-eight playtest

Current frontier: protocol 29, snapshot 11, preferences 8, Godot 4.7.1,
`codex/continuous-overhaul`. V0–V6 visual engineering, universal movement,
positive-Flux combat, two champions, Wellspring, direct-IP Farflow, and the
one-file Windows bootstrap are green foundations—not permission to claim final
art, balance, internet accessibility, or chemistry.

## Slice sequence

| Slice | Engineering work | Observable exit |
|---:|---|---|
| C0 authority | Remove duplicate browser runtime; preserve recovery commit and reusable principles; reconcile README, focused docs, roster names/ancestries/affinities; validate links/assets. | A newcomer finds one runtime, one command set, one state table, and no conflicting current roster truth. |
| C1 lifecycle | Re-run clean setup/repair/update/installed boot; improve single-screen host/join address feedback; verify safe host/guest close and packaged Farflow. | Friend needs one `.exe`, one host address, and no Godot/Git/admin rights; known NAT/signing limits are visible. |
| C2 visual runtime | Validate/split the burst reference atlas; add a data-driven burst presenter; reconcile canonical champion display metadata; review characters, elevation/shadows, environment and HUD at 50/75/100%. | Five simultaneous lanes and both champions read instantly in standard/high-contrast/reduced modes without effects changing rules. |
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
5. Source boots at 60/120, then imported-resource boots.
6. Visual capture at 50/75/100%, high contrast, reduced effects, and multiplayer.
7. Packaged Windows boot, clean install/repair/update, and 2/4/8 Farflow journeys.
8. Diff/provenance/docs/memory review, then one reversible commit and push.

Begin the next slice immediately after a green checkpoint, but never mix an
unproven half-system into the last known playable commit. Pause for the user
only after C9 or a real permission/product/technical blocker.
