# FLUX overhaul implementation ledger

Date: 2026-07-28
Branch: `integration/unify-flux`

## Safety boundary

The shipped 0.34.3 roster remains the default and the only roster accepted by
the menu and live lobby service. Overhaul runtime characters resolve only when a
match is created programmatically with `contentProfile: "overhaul-preview"`.
Unknown or preview IDs requested through a normal match or remote lobby fail
closed to the existing live fallback character.

Preview code must not contain or display draft lore. A mechanics gate cannot
promote narrative copy.

## Character promotion matrix

| Character | Prototype | Deterministic tests | Bot use | Remote authority | Readability/accessibility | Packaged smoke | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Hara | Pass | Pass | Pass | Pending | Pending | Pending | Local preview only |
| Remaining roster | Pending | Pending | Pending | Pending | Pending | Pending | Design only |

## Hara preview slice

- Stable future ID: `mara`.
- Default primary: **Ray**, a fast, narrow, low-impact projectile.
- Alternate primary: **Stone Shot**, a slower heavy projectile with greater
  impact and recovery.
- **SECOND PLAN**: once per round, Hara may swap Ray and Stone Shot only inside
  the personal sanctuary at her spawn. Every preview map receives one sanctuary
  per spawn without changing live map geometry.
- **Gust Ring**: bounded radial control with a real 28-unit safe center, visible
  range commitment, Flux cost, cooldown, and low damage.
- **Sun Grid**: a 0.72-second tell followed by three parallel Light lanes. Each
  target resolves at most once even if its collision body touches multiple lanes.
- Bot behavior uses the same command sanitizer and swaps at its sanctuary when
  facing a heavy target or a long engagement.

## Next safe sequence

1. Add preview-only rendering for personal sanctuaries, active-primary state,
   Gust Ring's safe center, and Sun Grid's complete windup/resolve geometry.
2. Add keyboard/controller bindings and accessible labels behind a developer
   preview switch; leave the normal character selector unchanged.
3. Exercise Hara through the authoritative lobby path in a private preview-only
   protocol lane, including reconnect, spectators, and host migration.
4. Complete Windows and Linux packaged preview smokes.
5. Review playtest telemetry and adjust one axis at a time.
6. Only then begin the next low-risk character adapter.

No preview character may enter the live selector merely because its headless
simulation tests pass.
