# Active implementation memory

This compact handoff complements the append-only `WORKLOG.md`; update it after
each playable slice.

## Current green frontier — 2026-08-23

- Branch: `codex/continuous-overhaul`.
- Protocol 28, snapshot schema 11, player preference schema 8.
- Two basic champions, the non-ability movement foundation, cone occlusion,
  twelve walk-up Wellspring stations, direct-IP Farflow, Charters, Hearth,
  Proving Court, reconnect, stewardship and late-join observation are live.
- Up to eight players have authored court spawns, teams, wards, bounds,
  knockout/respawn, results, Hearth return and same-roster Round 2.
- Snapshot schema 11 uses a bounded FastLZ envelope; maximum fixtures and live
  three-player journeys remain inside one 1,392-byte ENet MTU.
- Twelve stable spell-position command edges fit the existing bounded command
  packet. Plain, Ctrl and Alt layers combine with four remappable spell buttons;
  Alt wins a dual-modifier chord deterministically. The in-world 3×4 Spell Loom
  repositions all seven globally runtime-proven spells for every champion; five
  honest empties refuse without spending Flux, each spell owns its cooldown
  through swaps, guests wait for schema-11 snapshot confirmation, and champion
  changes lead with that kit before the stable global remainder. Its host request
  lane reserves 48 bounded library entries. Schema-v3 loadouts validate twelve positions.
- Ability schema 3 validates shape, delivery, impact, residue, planned material
  operation, runtime gates and a canonical Flux economy. Seven proven spells
  enter the playable selector; every material mutation remains disabled.
- Every runtime spell has positive cost and a bounded pressure/tempo/control
  cadence. Arc/Rillshot/Eclipse cost 7/6/8 Flux; active costs are 24/20/24/18,
  recovery waits 700 ms, and the HUD visibly separates WAIT from RISING.
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
- Ordinary movement now uses the `movement-tuning-v3-impact-agency` profile:
  324 px/s top speed, 1,980 px/s² acceleration, 3,000 px/s² braking and 1.9×
  counter-strafe response. One-second travel is 300.15/298.825 px, release drift
  14.9/16.15 px and reversal drift 11.33/12.63 px at 60/120 Hz.
- Movement animation follows residual velocity through braking, scales its body
  response with speed and owns an editable reduced-effects heel-plant accent.
  The complete movement tuning hash is part of Farflow compatibility.
- A fail-closed action transition policy covers all twenty-one live movement/control
  modes and projectile/beam/spray/field spells. Movement remains live through
  startup/recovery; unrelated spells may start during recovery; one startup
  channel, physical control, own cooldown, Flux, kit and empty-slot refusals are
  visible and resource-safe. Hash `29cd46fd167e` is part of state and Farflow
  compatibility.
- Authored launches now accept bounded directional influence. Natural expiry or
  cover impact enters a 220 ms recovery brace at 42% retained speed; buffered V
  plus direction spends exactly 18 Stamina to tech at 360 px/s, while ordinary
  movement cannot erase the decision. The host-authoritative Momentum Chime
  teaches that loop, refuses repeat requests during launch/recovery and uses a
  reusable reduced-effects-aware brace accent as the next visual slice seed.
- Latest source verification is 18,428 assertions across 52 suites plus
  import/source 60/120 Hz boots and a fresh 120 Hz three-process
  spectator-to-Hearth-to-Round-2, reconnect and stewardship journey.
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
- A fail-closed foundation spell presenter now validates and renders all five
  live spells from authoritative state: distinct startup silhouettes, projectile/
  beam/spray/field action language, actor impacts, Rimewake residue and
  source-specific refusal feedback. Default-75% 720p captures cover all five.
- A fail-closed Wellspring interaction presenter now unifies all ten live
  station kinds, localized key prompts, expanded station sheets, named social
  bubbles and top-center notices. The compact HUD has stepped frames, champion
  portraits, element-shape glyphs, resource ticks and exactly four spell cells.
- `scripts/capture-visual.ps1` creates a bounded temporary project and verifies
  every captured PNG, enabling truthful reviewed 1280×720 and 1920×1080 V5
  evidence without mutating the authored project viewport.
- V6 adds a fail-closed standard/high-contrast/review-simulation visual filter,
  schema-8 high-contrast persistence, reduced-effects parity and in-world
  Controls Lectern toggles. Standard play skips the full-screen pass.
- Capture-only preference overrides are transient and cannot rewrite the normal
  profile. The harness also supports a truthful visual-host Farflow pair and
  requires real join/shared-emote evidence before accepting its frames.
- Untracked `dist/`, `node_modules/` and `scripts/firewall.ps1` are user-owned
  and must remain untouched.

## Next acceptance-driven slice

V0–V6, crisp ordinary movement, universal action transitions, the positive-Flux
cadence candidate and global Loom/cooldown authority are engineering-complete.
Impact agency/recovery is live and the animation overlap seed has begun. Finish
hands-on authored Conservatory route acceptance plus controller sensitivity and
deadzone tuning first; then complete natural action phases/environmental routes,
promote one bounded live chemistry reaction, and only afterward expand Water's
spell roles through that chemistry.

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
