# Chemistry agency W1 — local verified slice

2026-09-09. Existing optional trails can fund a successful whole-cast admission without permanently occupying its material budget. No spell cost, damage, projectile/field cap, material cap, wire schema or protocol number changed in this slice. No claim of human balance acceptance, multiplayer playtesting or release acceptance.

## Transaction and authority boundary

- `available_cast_capacity(owner_id)` remains physical capacity: live projectiles, deposits and existing paid pending casts still occupy their original slots.
- `available_cast_offer(owner_id)` is a read-only `Vector2i` preview of the exact virtual projectile/material capacity and independent Field capacity passed to ordinary combat admission. It neither edits candidates nor reserves anything. Cooldown, control, kit and affordability remain separate checks; an offer is not a promise that every cast is legal.
- Only the requesting owner's live optional trails are candidates. Terminal matter, other owners' trails, and every linked anchor of every non-expired reaction are protected, including formation and decay. Existing paid reservations always remain counted.
- Candidate ordering is oldest `created_tick`, then lowest `entity_id`, independent of array storage order. Admission uses the unchanged CombatSystem check/payment/startup path; only a newly accepted paid cast commits the smallest required candidate prefix. Instant spells, Fields, already-pending casts and fitting projectile casts do not reclaim anything.
- Reclamation commits before the next owner's sequential admission. It emits an internal `cast_trails_reclaimed` event with owner, wire, exact IDs and count. No network field was added; guest UI proof is not implied.
- Rejected casts do not reclaim ingredients. Ordinary tick processing can still expire material independently. Accepted paid startup has the existing possibility of later death or blocked release; the transaction is successful admission, not a guarantee of later impact.

Production edits for this slice are the SimWorld capacity/transaction helpers and callsite, plus `trail_policy()` version 4/fingerprint only in ElementChemistrySystem. CombatSystem was inspected but not modified by this lane.

## Automated evidence

All runs used the existing strict checked wrapper and Godot 4.7.1, isolated from other engine work. All three `.err` files are empty.

| Evidence | Result |
| --- | --- |
| `import-v1.log` | Checked headless import passed |
| `focused-v1.log` | Combat 25,418; element-trails 16,262; core 47; session-snapshot 1,456 — **43,183 assertions, zero failures** |
| `rapid-bolt-v1.log` | **1,776 assertions, zero failures**, eight cases repeated twice |
| `rapid-bolt-comparison.json` | Exact scenario metrics, final hashes, all-tick state-trace digests, source hashes |

Coverage includes the requested 10 live projectiles + 4 trails + 5-lane Wave: exactly 3 oldest eligible trails disappear, 5 paid lanes remain reserved, then all 5 release. The remaining trail can fund the final Bolt up to the unchanged 16-projectile owner limit. Tests also cover fitting Bolt/Field no-op, unmodified offers/state hashes, reversed storage order, exact events, cooldown/Flux/control/invalid-command no-reclaim, non-expired conductor protection, terminal/other-owner exclusion, and competing same-tick global reservations. In the global fixture, 119 live shots + 8 trails start below the 128 shared cap; the first owner reclaims exactly 4 and reserves 5, while the second owner's Wave refuses with its four trails and Flux unchanged.

Focused rerun (root handles Full and final export separately):

```powershell
. ./scripts/flux2-common.ps1
$agencyGodot = Get-FluxGodot
Invoke-FluxGodotChecked $agencyGodot @('--headless','--path',(Get-FluxRepoRoot),'--script','res://tests/run_all.gd','--','--suite=element-trails,combat,core,session-snapshot') (Join-Path (Get-FluxRepoRoot) 'docs/evidence/chemistry-agency-v1/focused-rerun.log') -RejectWarnings
Invoke-FluxGodotChecked $agencyGodot @('--headless','--path',(Get-FluxRepoRoot),'--script','res://tests/scenarios/rapid_bolt_economy_probe.gd') (Join-Path (Get-FluxRepoRoot) 'docs/evidence/chemistry-agency-v1/rapid-bolt-rerun.log') -RejectWarnings
```

## Rapid / Bolt setup economy: observation, not a nerf

Seed 609913, 120 Hz, same empty 4000px-square world, same stationary caster and explicit eastward endpoint. Real Fire then Water catalog spells, one paid press each; second cast starts on the tick after the first terminal appears. No enemy, artificial ingredients, cooldown reset, free cast or Flux regeneration. Every case repeats from a fresh world and compares every sampled state hash plus all reported metrics. Raw Flux is thousandths; the table converts it to displayed units. Tick numbers are zero-based simulation event ticks, not wall-clock performance timings.

| Endpoint | First → second | Flux paid | First terminal tick | Steam formed tick | Active duration | Peak trails |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 120px | Rapid → Rapid | 4 | 21 | 43 | 315 ticks / 2.625s | 0 |
| 120px | Bolt → Bolt | 12 | 27 | 53 | 189 ticks / 1.575s | 4 |
| 120px | Rapid → Bolt | 8 | 21 | 47 | 315 ticks / 2.625s | 2 |
| 120px | Bolt → Rapid | 8 | 27 | 49 | 189 ticks / 1.575s | 3 |
| 400px | Rapid → Rapid | 4 | 76 | 153 | 315 ticks / 2.625s | 0 |
| 400px | Bolt → Bolt | 12 | 89 | 173 | 315 ticks / 2.625s | 4 |
| 400px | Rapid → Bolt | 8 | 76 | 160 | 315 ticks / 2.625s | 4 |
| 400px | Bolt → Rapid | 8 | 89 | 166 | 315 ticks / 2.625s | 4 |

All cases paid exactly their two authored positive costs, had no refusal, and formed real Steam (wire 310). Every first terminal was strength 1000/radius 32px. Rapid remains terminal-only and cannot seed a flight trail. At the near endpoint, Bolt's earlier trail can be reached by the new terminal before the prior full terminal is selected, producing the existing 60%-duration trail-assisted result. That outcome is not a capacity-reclamation effect: these cases never approached the owner limit. At 400px the full terminal pairing yields equal duration, while Rapid buys the setup more cheaply and sooner. This is a concrete tuning question, not sufficient evidence that Rapid is globally stronger: damage, aim tolerance, opponent reaction, cover, moving targets and tactical trail utility were not compared. No arbitrary balance adjustment was made.

## Source freeze

SHA-256 at verification (raw checkout bytes; subsequent root edits require a new receipt):

| Path | SHA-256 |
| --- | --- |
| `src/sim/core/sim_world.gd` | `8f315419323a8d5cbbd945671c1666eacb1bd3bb96419270bf23ea80dca5a7e5` |
| `src/sim/chemistry/element_chemistry_system.gd` | `c878856ac0e2b59c7887916a5b2f200a079fb0fef1b8c37ce63c3b4d8839a80e` |
| `src/sim/combat/combat_system.gd` | `8a0e632a072b93178dd2567c5b69d216ad4bc18a0e384eb15d581543e667606c` |
| `tests/unit/test_element_trails.gd` | `6efb2f8407300c74ae642df3e662ac1c15ae7660ba88d51e3f235b19345415f0` |
| `tests/unit/test_combat.gd` | `fec2628af8f0174d81a6d2545047fe59d41f1a9fcc0775a03b847604fb4c4b5f` |
| `tests/scenarios/rapid_bolt_economy_probe.gd` | `401b0f120cacadd863be3ed639d592fa08a46986752d3c8d2b720d8e8eaae1b8` |
| `content/abilities/foundation_abilities_v1.json` | `60c3f233ba996776b4ebbbb5089632d8376e9bc1d1da517ba4c139f5533cd835` |

Root owns reaction-definition fingerprint / magic authority refresh and final Full/export gates. This lane did not refresh those artifacts or change existing numerical trail policy constants.
