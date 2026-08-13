# Active implementation memory

This compact handoff complements the append-only `WORKLOG.md`; update it after
each playable slice.

## Current green frontier — 2026-08-13

- Branch: `codex/continuous-overhaul`.
- Protocol 22, snapshot schema 6, player preference schema 6.
- Two basic champions, the non-ability movement foundation, cone occlusion,
  ten walk-up Wellspring stations, direct-IP Farflow, Charters, Hearth,
  Proving Court, reconnect, stewardship and late-join observation are live.
- Up to eight players have authored court spawns, teams, wards, bounds,
  knockout/respawn, results, Hearth return and same-roster Round 2.
- Snapshot schema 6 uses a bounded FastLZ envelope; maximum fixtures and live
  three-player journeys remain inside one 1,392-byte ENet MTU.
- Five stable spell-slot command edges now fit the existing bounded command
  packet. Number keys 1–5 are migration-safe, conflict-editable inputs; slots
  1/2 adapt to each champion's proven primary/active and slots 3–5 refuse
  visibly without spending Flux. Schema-v2 loadouts validate five unique IDs.
- Latest verification is 14,849 assertions plus Windows 60/120 Hz
  three-process spectator-to-Hearth-to-Round-2 journeys with empty stderr.
- Portable release tooling installs only the official Godot 4.7.1 Windows/Linux
  templates by bounded HTTP range with ZIP CRC/size validation, excludes
  non-runtime workspace content, emits checksummed Windows ZIP/Linux tar.gz
  friend builds and preserves Linux executable modes across a Windows host.
- Window close disables automatic quit, flushes preferences, gives hosted
  guests a bounded semantic reason, closes ENet and then exits. Source 60/120 Hz
  and real packaged Windows `PLAY-FLUX.cmd` safe-quit smokes pass.
- The original v3 gameplay-scale Wellspring specimen is documented as a visual
  target only; runtime art/collision and visual acceptance remain separate.
- Untracked `dist/`, `node_modules/` and `scripts/firewall.ps1` are user-owned
  and must remain untouched.

## Next acceptance-driven slice

Build the Wellspring Spell Loom editor over the five-slot foundation: expose
legal catalog entries with truthful element/shape/Flux/cooldown metadata, keep
champion kit compatibility explicit, and promote one representative spell
shape at a time through deterministic simulation, cues and tests. Preserve the
packaged Windows green point; physical Garuda and real remote-friend proof
remain explicit external acceptance gaps.
