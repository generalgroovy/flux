# Active implementation memory

This compact handoff complements the append-only `WORKLOG.md`; update it after
each playable slice.

## Current green frontier — 2026-08-13

- Branch: `codex/continuous-overhaul`.
- Protocol 25, snapshot schema 9, player preference schema 6.
- Two basic champions, the non-ability movement foundation, cone occlusion,
  eleven walk-up Wellspring stations, direct-IP Farflow, Charters, Hearth,
  Proving Court, reconnect, stewardship and late-join observation are live.
- Up to eight players have authored court spawns, teams, wards, bounds,
  knockout/respawn, results, Hearth return and same-roster Round 2.
- Snapshot schema 9 uses a bounded FastLZ envelope; maximum fixtures and live
  three-player journeys remain inside one 1,392-byte ENet MTU.
- Five stable spell-slot command edges now fit the existing bounded command
  packet. Number keys 1–5 are migration-safe, conflict-editable inputs. The
  in-world Spell Loom repositions the current champion's primary/active among
  five host-owned canonical slots; three honest empties refuse without spending
  Flux, guest requests wait for snapshot confirmation, and champion changes
  reset to the safe 1/2 layout. Schema-v2 loadouts validate five unique IDs.
- Ability schema 2 validates shape, delivery, impact, residue, planned material
  operation and separate runtime gates. Only six proven spells enter the
  playable selector; every material mutation remains explicitly disabled.
- Pocket Eclipse is the first non-projectile runtime shape: a 520-unit Light
  beam resolved after actor movement, stopped by cover, limited to the first
  legal target, replicated by semantic endpoint and never stored as a projectile.
- Tideline is the first spray: a 280-unit Water fan with stable multi-target
  hits, per-target cover, exact launches, explicit affected cues and no
  projectile state/material mutation.
- Latest verification is 14,948 assertions plus import/source 60/120 Hz boots,
  a fresh 60 Hz three-process spectator-to-Hearth-to-Round-2/reconnect/
  stewardship journey, both portable packages and packaged Windows safe quit.
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

Promote the next representative spell shape—field—through deterministic
simulation, Flux/cooldown/refusal, cues, snapshot representation, lifetime and
training read while remaining host-owned. Keep material
operations sealed until reset ownership and route-safety fixtures exist. Preserve
the packaged Windows green point; physical Garuda and real remote-friend proof
remain explicit external acceptance gaps.
