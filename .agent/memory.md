# Active implementation memory

This compact handoff complements the append-only `WORKLOG.md`; update it after
each playable slice.

## Current green frontier — 2026-08-12

- Branch: `codex/continuous-overhaul`.
- Protocol 20, snapshot schema 6, player preference schema 3.
- Two basic champions, complete non-ability movement foundation, honest cone
  visibility, nine walk-up Wellspring stations, direct-IP Farflow, Charters,
  Hearth readiness and the first host-owned Proving Court round are live.
- The court supports two to eight connected travellers, authored spawns,
  distinct combat teams, visible wards, sealed bounds, first-to-three or
  90-second result, knockout/1.8-second respawn, six-second result and automatic
  Hearth return.
- Late friends receive a safely idle next-gathering state and cannot mutate
  lobby stations during a live court; HELLO remains available.
- Results return up to eight connected champions to collision-cleared positions
  around the actual Hearth; persistent countdown/rule text and reset readiness
  support serial Round 2 without reopening Farflow.
- Host stewardship uses a non-destructive Company Ledger plus a separate
  double-confirm Parting Bell; company close also requires two presses. Protocol
  reasons reach affected guests, administrative departures revoke return and
  clients cannot forge moderation.
- Latest verification: `scripts\test.cmd` passed 14,709 assertions plus 60/120
  Hz boots; Windows two-process Round-1-to-Round-2-to-stewardship source smoke
  passed at 120 Hz/Open Commons on UDP 24928 and 60 Hz/Duel Knot on UDP 24929.
  A deterministic 1280x720 Ledger capture was also visually inspected.
- Untracked `dist/` and `node_modules/` predate this slice and must remain
  untouched.

## Next acceptance-driven slice

Give late joiners a useful spectator experience without entering or influencing
the active round: replicated participant focus, safe camera cycling, clear
next-gathering status, no hidden-state leak and automatic Hearth handoff.
