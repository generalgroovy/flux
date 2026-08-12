# Active implementation memory

This compact handoff complements the append-only `WORKLOG.md`; update it after
each playable slice.

## Current green frontier — 2026-08-12

- Branch: `codex/continuous-overhaul`.
- Protocol 21, snapshot schema 6, player preference schema 3.
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
- Late joins during active/result court state are input-locked observers: Tab or
  D-pad right cycles stable available participants, the HUD names the focus and
  next gathering, and Hearth return restores normal readiness/Round-2 play.
- Snapshot schema 6 uses a bounded FastLZ wire envelope; the maximum eight-player
  fixture and live three-player journeys stay within one 1,392-byte ENet MTU.
- Latest verification: 14,740 assertions passed; Windows three-process
  Round-1 spectator-to-Hearth-to-Round-2 journeys passed at 120 Hz/Open Commons
  on UDP 24937 and 60 Hz/Sparring Circle on UDP 24938 with empty stderr logs.
- Untracked `dist/` and `node_modules/` predate this slice and must remain
  untouched.

## Next acceptance-driven slice

Add host-owned per-peer visibility/relevance envelopes so limited-information
network modes omit actors, projectiles, cues, names and audio outside the legal
view while full-view Wellspring and observer behavior remain intact.
