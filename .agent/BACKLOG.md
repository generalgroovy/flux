# FLUX 2 active backlog

This queue is intentionally short. Completed evidence belongs in `WORKLOG.md`;
the full gate order remains in `docs/OVERHAUL-PLAN.md`.

| Order | Playable outcome | Acceptance |
| --- | --- | --- |
| 1 | Discoverable movement controls and resource HUD | Shift sprint, Ctrl/C slide, Space jump and V technique work on keyboard; controller remains intact; direct slide is deterministic at 60/120 Hz; Health/Flux/Stamina and current movement state are legible |
| 2 | Honest cone visibility (presentation complete) | Angle never exceeds 360 degrees; every `los_cutaway` building casts a tested occlusion shadow; host-side hidden-entity filtering remains required with networking |
| 3 | Movement feel foundation (presentation complete) | Buffers, variable jump, fast fall, wall skim and intensity-scaled landing cues pass deterministic 60/120 Hz and replay checks; physical-controller acceptance remains |
| 4 | Interactive Wellspring stations (five live) | Guide, Bell, Loom and diegetic Host/Join Farflow gates have fixed-point focus, F/controller interaction and transparent bubbles; settings and travel remain |
| 5 | First two champion vertical slices (both basic pairs live) | Both identities/stats/sprites and basic pairs pass 60/120 Hz; deeper dummy, defense, replay, accessibility, audio/final-art and platform acceptance remain |
| 6 | Friend-play vertical slice (shared interactions live) | Stable actors, host input, 60 Hz movement/combat/target snapshots, host-authorized emote/Bell/Loom requests and Windows localhost pass; prediction is now live, reconnect and Linux direct-IP remain |
| 7 | Responsive remote traveller (complete foundation) | Bounded movement-only history, peer-scoped host acknowledgement, deterministic 60/120 Hz replay, capped soft correction, hard-snap safety and visible ACK/correction diagnostics pass real Windows ENet |
| 8 | Session continuity | A disconnected guest leaves cleanly, can reclaim an authenticated reserved identity inside a bounded window, and receives explicit host-loss/reconnect status on Windows and Garuda Linux |
