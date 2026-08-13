# Active implementation memory

This compact handoff complements the append-only `WORKLOG.md`; update it after
each playable slice.

## Current green frontier — 2026-08-13

- Branch: `codex/continuous-overhaul`.
- Protocol 26, snapshot schema 10, player preference schema 7.
- Two basic champions, the non-ability movement foundation, cone occlusion,
  eleven walk-up Wellspring stations, direct-IP Farflow, Charters, Hearth,
  Proving Court, reconnect, stewardship and late-join observation are live.
- Up to eight players have authored court spawns, teams, wards, bounds,
  knockout/respawn, results, Hearth return and same-roster Round 2.
- Snapshot schema 10 uses a bounded FastLZ envelope; maximum fixtures and live
  three-player journeys remain inside one 1,392-byte ENet MTU.
- Twelve stable spell-position command edges fit the existing bounded command
  packet. Plain, Ctrl and Alt layers combine with four remappable spell buttons;
  Alt wins a dual-modifier chord deterministically. The in-world 3×4 Spell Loom
  repositions every proven kit spell, honest empties refuse without spending
  Flux, guests wait for snapshot confirmation, and champion changes reset to
  the safe Plain 1/2/3 layout. Schema-v3 loadouts validate twelve positions.
- Ability schema 2 validates shape, delivery, impact, residue, planned material
  operation and separate runtime gates. Only six proven spells enter the
  playable selector; every material mutation remains explicitly disabled.
- Pocket Eclipse is the first non-projectile runtime shape: a 520-unit Light
  beam resolved after actor movement, stopped by cover, limited to the first
  legal target, replicated by semantic endpoint and never stored as a projectile.
- Tideline is the first spray: a 280-unit Water fan with stable multi-target
  hits, per-target cover, exact launches, explicit affected cues and no
  projectile state/material mutation.
- Rimewake is the first persistent field: collision-safe aimed placement, 2.2 s
  lifetime, stable hostile order, one slow per actor, compact snapshot state and
  trigger cues; its planned material cooling remains sealed.
- Camera presentation now defaults to a wider 75% scale and persists a bounded
  50/75/100% choice. Pointer aim, cone range and building occlusion transform
  with the same scale; F11 and `--camera-zoom=` expose it without changing rules.
- Latest source verification is 15,613 assertions plus import/source 60/120 Hz
  boots and a fresh 60 Hz three-process spectator-to-Hearth-to-Round-2,
  reconnect and stewardship journey. Diagnostic captures verify the compact
  active-layer HUD, wider 75% navigation view, Rimewake feedback and 3x4 Loom.
- Both portable packages and packaged Windows safe quit passed at the preceding
  green checkpoint; this slice did not overwrite the user-owned build folders.
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

Mechanics are frozen. Execute V0, the live visual baseline and token specimen,
then proceed through the strict V1–V6 order in `.agent/VISUAL-OVERHAUL.md` until
the actual Wellspring, two foundation champions, existing spells and compact
four-cell/layered GUI meet the 720p/1080p readability, accessibility, alignment
and charm rubric. Only after integrated visual acceptance may work continue in
the order crisp/slightly slower movement → universal chaining → positive-Flux
offense and shorter cooldown economy → globally selectable four-role catalogs
for all twelve elements. Preserve the published protocol-26 green point and the
user-owned untracked paths throughout.
