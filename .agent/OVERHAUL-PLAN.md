# FLUX overhaul plan

Branch: `agent/resource-hud-first-slice`

## Current constraints

- Keep all existing playable paths operational while replacement systems are introduced.
- Keep the seven approved character names and all approved passive, active, and ultimate names unchanged.
- Simplify system, mode, race, element, location, and interface labels where clarity improves.
- Keep live gameplay text minimal and decision-relevant.
- Move full explanations to tooltips, setup panels, the guide, and freeplay diagnostics.
- Move the HUD toward a compact action-RTS/MOBA information hierarchy.
- Make Flux feel abundant but strategically exhaustible.
- Preserve deterministic server authority, stable IDs, reconnect, spectators, host migration, Linux, Windows, and safe updating.

## Slice 1 — Flux economy and HUD copy

### Scope

1. Introduce a high-capacity Flux tuning profile.
2. Increase tactical, defense, and mobility costs so the larger pool creates choices rather than free spam.
3. Increase post-cast recovery delay so repeated casting postpones recovery.
4. Keep deliberate disengagement recovery useful.
5. Keep primary fire and universal movement fundamentals available at zero Flux.
6. Reduce persistent HUD prose.
7. Display name, binding, cooldown, cost, resource state, and immediate unavailable reason.
8. Keep full ability descriptions on hover/focus and in menus.
9. Keep existing ability names unchanged.
10. Add deterministic resource tests before merging.

### Initial tuning hypothesis

This is a test target, not a balance promise:

- Base maximum Flux: 180
- Tactical default cost: 48
- Defense default cost: 30
- Mobility default cost: 24
- Recovery: 28 per second
- Recovery delay after a paid cast: 0.85 seconds
- Dry-cast notification lockout: 0.75 seconds

Expected rhythm:

- A full player can open with several different actions.
- Repeating only the most expensive action empties the pool quickly.
- Constant casting prevents recovery from beginning.
- A short deliberate reset restores meaningful options.
- Zero Flux removes paid abilities, not aim, primary fire, ordinary movement, or counterplay.

### Tests

- Every paid ability remains affordable from full base Flux.
- No paid ability has zero or negative cost.
- Three default tactical casts cannot be repeated indefinitely without recovery.
- Mixed tactical, defense, and mobility sequences are possible from full Flux.
- Repeated paid casts reset recovery delay.
- Recovery starts only after the delay.
- Race modifiers remain within validated bounds.
- Dry casts create no projectile, field, mine, movement, defense, or refund.
- Remote commands resolve the same resource result as local commands.

### Non-goals

- No new ability catalog yet.
- No character power-budget rewrite yet.
- No freeplay sanctuary replacement yet.
- No broad visual asset replacement yet.
- No element migration yet.
- No race migration yet.

## Slice 2 — Semantic compact HUD

- Compact lower action bar.
- Dominant health and Flux bars; secondary FLOW meter.
- Primary, three active slots, and ultimate layout compatible with the future loadout system.
- Cooldown masks, costs, semantic bindings, and short status markers.
- Minimal objective strip and event feed.
- Full descriptions only on hover, focus, pause, setup, or guide.
- Keyboard, mouse, controller, and accessibility parity.

## Slice 3 — Freeplay shell

- Boot into a playable practice map while retaining the current menu as an overlay.
- Add reset, unlimited resources, god mode, cooldown control, dummy spawn, and field cleanup.
- Keep current mode launching, hosting, joining, reconnecting, and settings operational.
- Move functions into world stations only after the overlay path is verified.

## Slice 4 — Movement foundation

- Explicit movement state and transition model.
- Input buffering, double jump, directional air dodge, authored wavedash conversion, wall jump, slide jump, and bounded air redirect.
- Deterministic speed ceiling and collision stress tests.
- No character movement ability rewrite until universal movement is stable.

## Slice 5 — Elements and materials

- Stable aliases from current IDs to Earth, Fire, Water, Wind, Ice, Charge, Light, and Void.
- Data-driven material and field tags.
- One interaction-rich vertical-slice arena.
- No passive elemental hard counters.

## Slice 6 — Race, size, affinity, and ability budget

- Simple race labels.
- Size 1–5 with race ranges and bounded tradeoffs.
- One to five weighted affinities.
- Validated character power budget.
- Universal ability catalog with skillpoint costs and signature discounts.

## Slice 7 — Required characters

Implement, without renaming any approved character or ability:

- Der Rote Baron
- Treevor
- Samwise DeWayne
- Steezo
- Oh Tipi
- Oll'I
- Fluup

Each requires complete data, visuals, bots, local and remote behavior, prediction, reconnect, spectators, tooltips, freeplay demonstration, and tests.

## Slice 8 — Destruction, levels, modes, and releases

- Bounded authored destruction.
- One multi-level map.
- Existing modes adapted before new modes proliferate.
- Small Battle Royale vertical slice before scaling.
- Cross-platform update verification, atomic activation, retained playable version, and rollback.

## Loop exit condition

A slice is complete only when relevant tests pass, launch behavior is verified, the diff is reviewed, compatibility is recorded, and `.agent/PLAYABLE-STATE.md` describes the exact known-playable state.
