# Active implementation memory

This compact handoff complements the append-only `WORKLOG.md`; update it after
each playable slice.

## Current green frontier — 2026-08-21

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
- Latest source verification is 15,909 assertions plus import/source 60/120 Hz
  boots and a fresh 120 Hz three-process spectator-to-Hearth-to-Round-2,
  reconnect and stewardship journey. Diagnostic captures verify the compact
  active-layer HUD, wider 75% navigation view, Rimewake feedback and 3x4 Loom.
- Fresh Windows and Linux friend packages plus packaged Windows safe quit pass
  with the promoted runtime atlas; the large editable source sheet is excluded.
  User-owned `dist/`, `node_modules/` and `scripts/firewall.ps1` remain untouched.
- Portable release tooling installs only the official Godot 4.7.1 Windows/Linux
  templates by bounded HTTP range with ZIP CRC/size validation, excludes
  non-runtime workspace content, emits checksummed Windows ZIP/Linux tar.gz
  friend builds and preserves Linux executable modes across a Windows host.
- Window close disables automatic quit, flushes preferences, gives hosted
  guests a bounded semantic reason, closes ENet and then exits. Source 60/120 Hz
  and real packaged Windows `PLAY-FLUX.cmd` safe-quit smokes pass.
- The original v3 gameplay-scale Wellspring specimen is documented as a visual
  target only; runtime art/collision and visual acceptance remain separate.
- A fail-closed Wellspring architecture kit now gives every live building style,
  station kind and landmark kind a reusable profile. The warm-stone source court,
  faceted/textured roofs, modular facades, station furniture and landmark frames
  reuse the approved runtime pixel kit while leaving collision, routes, elevation,
  commands, interaction radii and cutaway authority unchanged.
- Untracked `dist/`, `node_modules/` and `scripts/firewall.ps1` are user-owned
  and must remain untouched.

## Next acceptance-driven slice

Mechanics remain frozen. V0–V2 are complete. Oh Tipi and S. Wayne use a pinned,
quantized compact-cartoon atlas with all critical directional/action states;
their editable minimal-motion profiles cover the complete movement grammar,
add bounded advanced-technique accents, normalize presentation at 60/120 Hz
and damp under reduced motion. V3 is active: an editable fail-closed
NaturalMapKit now seeds quiet ground variation, natural edge props, curved
visual routes and surface-aware movement contact without changing topology or
collision. Open-Conservatory captures cover walk, sprint, slide, jump, air
dodge and contextual technique. The new data-driven compact HUD keeps only
moment-to-moment champion/location, session state, Health, Flux, Stamina,
active layer and four spell cells on screen; existing stations retain detailed
guidance. An equally data-driven eight-point wayfinding kit gives the wide
campus distinct movement, recovery, archive, loom, settings, Farflow, duel and
elemental trial destinations without changing authority. The modular architecture
candidate now covers the source court, every live building style, all station
furniture and every landmark frame. Next: finish V3 three-district, cutaway and
50/75/100% capture review, fix failed readability/charm checks, then begin V4's
existing spell visuals; mechanics remain frozen through V6.

<!-- Historical V1 handoff below is retained only as prior evidence. -->
Mechanics remain frozen. V0 and V1 are complete: the validated visual language
now fail-closed binds the actual Wellspring; shared material ramps, quiet
cardinal floor cells, route seams, visible building footprints/thresholds,
whole-output-pixel camera placement and deterministic near-actor cutaways are
live at 60/120 Hz. 720p/1080p 75% captures and a fresh source Farflow journey
pass, but the map remains schematic and the v2 character atlases remain crude.
Proceed with V2 compact cartoon production candidates for Oh Tipi and S. Wayne,
then continue V3–V6 until the environment, existing spells and compact
four-cell/layered GUI meet the readability, accessibility, alignment and charm
rubric. Only after integrated visual acceptance may work continue in
the order crisp/slightly slower movement → universal chaining → positive-Flux
offense and shorter cooldown economy → globally selectable four-role catalogs
for all twelve elements. Preserve the published protocol-26 green point and the
user-owned untracked paths throughout.
