# Movement controls and learning: continuous height / fivefold reserves

Status: **continuous-height guide and fivefold reserves pass focused checks; full integration and human acceptance pending**.

Final suite, visual review and player acceptance are
recorded by the integration lead in `MOVEMENT-M1-M5-ACCEPTANCE.md`.

## Current resource and air-action contract

All five playable champions receive exactly five times their previous Stamina
maximum. Health, Flux, role speed ratios, action costs and absolute recovery
rates remain unchanged; more reserve is not faster recovery. The generic
movement fallback is 560 Stamina, but the HUD and compendium use the selected
champion's actual values.

| Champion | Size | Stamina before -> now | Recovery / second, unchanged |
|---|---|---:|---:|
| S. Wayne | Small | 118.8 -> 594 | 28 |
| Grace Riva | Small | 123.2 -> 616 | 29 |
| Wa Bidi | Small | 127.6 -> 638 | 32 |
| Oh Tipi | Middle | 132 -> 660 | 30 |
| The Red Baron | Large | 158.4 -> 792 | 32 |

| Action | Current rule | Readable practice check |
|---|---|---|
| Ordinary travel | Base speed 372.6 units/s; champion ratio and 1.28 sprint multiplier still apply | Compare actual speed with the optional practice trace |
| Tap / held jump | Continuous height; release caps upward speed at 410 units/s; held ground jump reaches about 90 units with a nominal 500 ms flight; landing refreshes readiness | Compare taps with a full hold; only ascent pays the 80 Stamina/s sustain |
| Second jump | Fresh release and press; adds upward lift from current height, capped at 180 units | Re-jump before the apex and see height continue, without a ground reset |
| Air dodge | One per real airtime; 180 ms decaying directional burst, then steerable flight; landing refills it without a cooldown wait | Turn or coast after the burst, then land and start a new jump/dodge chain |
| Wall route | Wall contact never replenishes spent air-dodge or second-jump budgets | Touch a wall during the same flight and verify no bonus charge |
| Fast fall | Fresh airborne Slide press sets at least 1,000 units/s downward speed; gravity continues until landing | Carrying C through takeoff does nothing; release and re-press to descend |
| Protection | Jump opening 90 ms; air-dodge opening 120 ms, ending immediately on landing | Height and hold duration never represent full-flight immunity |

The guide labels airborne durations as nominal lift cycles, not hard landing
timers. Runtime tuning owns these values; guide tests detect obsolete remaining-
flight limits, shared-cooldown air-dodge claims and frame-counter fast falls.
Shared body envelopes are scaled exactly fivefold with an 800-Stamina global
ceiling; oversized authored resources still fail closed. Network resource
bounds already support these values without an additional resource-cap change.

## Current verification

On 2026-09-06, the canonical deferred headless runner executed the isolated
`champion-catalog` (977 assertions), `body-type-profile-catalog` (49),
`movement-guide-model` (327), `character-overview-model` (388) and
`player-compendium` (875) suites: **2,616 assertions, zero failures**, clean
stderr. Evidence: `.godot/compendium-audit/fivefold-reserves-guide-final.log`.
This checks exact fivefold reserves, unchanged absolute recovery over a real
120-tick second, finite rejection bounds, current UI resource values and revised
guide/page behavior. It is not the integrated mechanics/network/visual gate.
The earlier M1/M5 receipt below is historical, not proof of this revision.

## Intent before extra inputs

Current defaults remain **WASD**, **Shift** sprint, **Space** jump, **C** slide,
**Q** evade and **V** Technique. Ctrl / Alt remain the twelve-slot spell layers;
this slice does not change saved bindings, preference schemas or those layers.

| Input | One deliberate meaning | Safety rule |
|---|---|---|
| Space / jump button | Jump; hold for paid height, press again for a second jump | Wheel cannot fabricate a held jump |
| C / slide button | Ground slide; deliberate second press brakes | Carrying C through takeoff does not immediately fast-fall |
| Fresh airborne C | Commit to an earlier landing | Release a previously held C, then press it again |
| Wheel up | One short Jump intent | Same-direction notches group until 120 ms of quiet |
| Wheel down | One short Slide intent, or explicit airborne Fast Fall | Same scrolling gesture does not immediately brake its own slide |
| Q / Evade | Roll on ground, air-dodge in air; late air-dodge can wavedash | No angle threshold for the late landing conversion |
| V / Technique | Contact/direction-specific wallrun, turn or impact recovery | Always subject to the authoritative movement state and cost |

Wheel grouping is a local input filter, not an automatic action or macro. Each
accepted gesture produces at most one pressed edge, no held flag and no
scheduled repetitions. A new notch extends the quiet-time window. Jump and
Slide gestures are independent, so opposite wheel directions remain usable in
deliberate chains. Keyboard/controller presses bypass wheel grouping, including
a button press in the same render frame as a wheel event.

An accepted short pulse survives a render frame with no fixed simulation tick,
but expires after 120 ms if not sampled. Opening a modal discards pending wheel
pulses; wheel releases neither rearm a gesture nor erase an unsampled pulse.
The normal no-wheel polling path remains unchanged.

## Learn a small grammar, then combine it

| Group | Skills | First useful drill |
|---|---|---|
| Travel | Move / brake, sprint, jump / hold, slide / hold | Run one lane, slide, release C, jump, steer and land deliberately |
| Escape | Roll, air dodge, fast fall, impact recovery | Cross one threat lane with the protected opening, then finish outside danger |
| Expression | Double jump, slide brake, slide jump, wavedash, air turn, wallrun, wall jump, landing reversal | Choose two different exits from the same approach without changing the opening |

The live compendium marks each skill's group and derives bindings, base cost,
hold drain, duration, cooldown and protection from current source tuning.
Shared rules distinguish ground release-to-brake from airborne
release-to-coast, held drain from the paid-start chain premium, and visible
airtime from the shorter protection window. The newest movement intent replaces
older buffered intent; the simulation still checks legality and affordability.

Use the optional practice trace (F2 by default) and restart it (F3 by default)
to compare routes. It exposes actual movement mode, speed, current/maximum
Stamina and the next chain premium. The in-game guide resolves these shortcuts
from saved bindings, not hard-coded letters.

No new deadzone setting or ergonomic preset is introduced here: those require
their own saved-preference migration and physical controller acceptance. The
existing Controls Lectern remains the supported rebinding path. No material
grip/drift, vault or extra automatic movement is added.

## Evidence boundary

Focused tests exercise the real InputMap and InputRouter sampling path, gesture
quiet gaps, release-before-sample, deliberate keyboard override, simultaneous
holds, catch-up ticks and modal discard. Existing eight-direction chord tests
remain in the same suite. Guide tests verify source-derived instructions and
costs; real controller feel and player learning still require human playtest.

Focused verification on 2026-09-06: the canonical deferred headless runner
executed `input-router` (457 assertions), `movement-guide-model` (298) and
`player-compendium` (870), all with zero failures and clean stderr. Evidence:
`.godot/compendium-audit/input-canonical-final.log`. The fixture explicitly
flushes synthetic engine events before feeding the production observer,
matching normal event delivery; immediate startup-only input tests are not
used as the final evidence. Full integration, captures and human acceptance
remain the lead's delivery gate.
