# Active implementation memory

This compact handoff complements the append-only `WORKLOG.md`; update it after
each playable slice.

## Body-only foundation slice — 2026-08-26

- Canonical character body types are now exactly `small`, `middle`, and
  `large`; legacy `tiny→small`, `medium→middle`, and `huge→large` mappings are
  explicit compatibility adapters only.
- Oh Tipi is `middle` and S. Wayne is `small` in the champion catalog and visual
  recipe. The skeleton manifest validates the same three IDs.
- The active body atlas is
  `assets/sprites/champions_v3/foundation/runtime_atlas_body_v3.png` with
  source `source_sheet_body_v3.png`, 96×96 cells, pivot `(48,84)`, front-facing
  symmetry, authored east profile, mirrored west and centered north/back.
- Body atlas pixels contain body and clothing only. Spells, elements,
  projectiles, auras, shadows, environment, tools, equipment and foci are
  independent presentation layers; the old procedural staff/orb fallback was
  removed so a missing atlas fails closed instead of drawing legacy props.
- Canonical body types use bounded render scales around the shared feet pivot:
  `small` 0.90×, `middle` 1.00×, `large` 1.10×. This changes presentation only;
  simulation radius, hitboxes and outcomes remain authoritative.
- Local and remote spell-startup drawing now uses a deterministic empty-hand
  origin above that feet pivot, with aim/side offsets bounded in the presenter;
  spell visuals no longer begin at the hitbox center.
- Atlas source SHA-256:
  `646528da4e44c5955ca918cab65aaa669d167cdefb80123790fcc93c5d4d353b`;
  runtime PNG SHA-256:
  `c250dbec8bfb2b97ca045efd311204c12fa6ae839db01ba2e65edeffa4e9f2a5`;
  imported RGBA SHA-256:
  `6cc5c31b0b9511d3cea768b088fddc356467eac68908df193e505bdc7b495bfb`.
- The exact built-in ImageGen edit prompt and provenance are recorded in
  `assets/sprites/champions_v3/foundation/README.md` and `provenance.json`.
- Superseded `source_sheet.png`, `runtime_atlas.png`, and intermediate
  hands-only PNGs were removed; tracked versions remain recoverable in Git.
- Verification after the slice: `scripts\\test.cmd` passed 53 suites,
  18,642 assertions, zero failures, with independent Windows source boots at
  60/120 Hz. The test output still contains expected editor image-load warnings
  for legacy visual archives.
- Truthful 1280×720 four-frame captures passed at 50%, 75% and 100% camera zoom
  under `.godot/visual-captures/body-v3-*`; Oh Tipi at 50%/75% and S. Wayne at
  100% were visually inspected with the new body-only atlas.
- The 24-frame `hand-cast-v2-720` capture at 75% shows the startup cue beginning
  in the empty-hand lane before projectile travel.
- `scripts\package.ps1 -Target Windows` rebuilt the export and installer; the
  current installer SHA-256 is
  `f78c0463adcf3740adab6aac58a676a3ac5c5f41f01db866ca609e21f3ed640d`.
  The exported `exports\windows\flux2.exe` boots headlessly at 120 Hz.
- `scripts\test-windows-bootstrap.ps1` was blocked when Device Guard refused
  the unsigned installer binary (also from `%TEMP%`); this host limitation is
  recorded explicitly and is not treated as a lifecycle pass.

## Consolidation frontier — 2026-08-26

- `origin/main` through `3f79847` is merged into
  `codex/continuous-overhaul` at merge commit `345d6e9`; the pre-consolidation
  movement/installer checkpoint is `79085f6`.
- The imported `legacy/web-prototype/` second runtime is retired from the
  product tree. Its final standalone checkout was clean and remote-backed at
  `origin/integration/unify-flux` commit
  `e13171473baf67b2264479467b650974a4c65290`; the Codex desktop protects that
  original task-working-directory shell from recursive deletion, so no product
  code may reference or use it.
- The root README is now the concise current player/developer front door: one
  Godot authority, honest install/host limitations, shipped-vs-planned state,
  controls, full movement and resource contracts, first-eight element matrix,
  24-character migration roster, ancestries, Wellspring/Farflow architecture,
  embedded design images, and the exact chemistry playtest sequence.
- New mainline reference inputs are present: compact archived body boards (the
  current runtime reduces them to small/middle/large),
  design-locked 36-pair reaction data, weighted 2+1 first-eight affinities, and
  the Waka Aren Si display-name compatibility contract. The imported burst-v2
  PNG streams were truncated and were replaced by the reviewed v3 pipeline.
- The user-ordered active path is repository authority → plug-and-play
  lifecycle → cohesive visual runtime → deterministic five-shot patterns →
  eight configurable elemental bursts → all 36 bounded live reactions →
  packaged playtest pause.
- User-owned `node_modules/` and `scripts/firewall.ps1` remain untracked and
  untouched.
- Windows launch text is now ASCII-only and the bootstrap lifecycle gate rejects
  regressions, preventing legacy-code-page mojibake. After 24 consecutive
  push-triggered failures were identified as the email source, the outdated
  Linux-only `Godot foundation` workflow was disabled with no queued/running
  copies; its checked-in replacement is manual, pinned and Windows-only.
- Windows lifecycle C1 is locally accepted. Player preference schema 9 stores a
  validated Farflow host/IP; the in-world Join gate accepts typing or Ctrl+V,
  confirms with Enter, cancels with Escape and keeps command-line overrides for
  diagnostics. A reviewed 1280×720 capture is under ignored `.godot` evidence.
- The setup pipeline no longer depends on the unavailable `Get-FileHash`
  command; the shared .NET SHA-256 helper is used by packaging, bundling,
  bootstrap compilation and update tests. The current one-file payload is
  `0.1.0-dev-5a59a2cf68-bc04b7b4f7`, SHA-256
  `dcdf7e45d88157164f3af1b5993ab2dc8524d08151592e130801073752d56b7a`.
- C1 verification: 52 suites / 18,560 assertions plus source 60/120 boots;
  baseline update from `0.1.0-dev-872b62227a-c08c59e8c4`, repair and installed
  boot; packaged safe quit; packaged Open Commons (8), Sparring Circle (4) and
  Duel Knot (2) Farflow journeys at 120 Hz on UDP 24914–24916. Signing,
  NAT/relay and physical two-PC proof remain future release gates.
- C2 projectile-art foundation is live. A project-bound nine-element style
  board plus deterministic generator produces nine bounded 512×256 sheets;
  the fail-closed presenter validates source/generator/asset hashes, exact
  32×32 pivots, phases, mirrored directions, budgets and presentation-only
  authority. All live projectiles use their element sheet and retain a visible
  simulation-radius ring; the corrupted v2 files remain recoverable at
  `3f79847` but are removed from the active tree.
- C2 verification frontier before the body-only slice: 53 suites / 18,626 assertions, source 60/120 boots,
  inspected 1280×720 Water travel at 75% zoom, Windows export/package, and
  packaged GPU safe quit. Current setup payload is
  `0.1.0-dev-5c21b55e49-890cf994f9`, SHA-256
  `00b2e51b2e477311102ad7c476644fd371e8c68eb8d9f1c8844988bd946291a1`.

## Current green frontier — 2026-08-26

- Branch: `codex/continuous-overhaul`.
- Protocol 29, snapshot schema 11, player preference schema 9.
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
- Latest source verification before the body-only slice was 18,626 assertions across 53 suites plus
  import/source 60/120 Hz boots and a fresh 120 Hz three-process
  spectator-to-Hearth-to-Round-2, reconnect and stewardship journey.
- Fresh Windows and Linux friend packages plus packaged Windows safe quit pass
  with the promoted runtime atlas; the large editable source sheet is excluded.
  User-owned `dist/`, `node_modules/` and `scripts/firewall.ps1` remain untouched.
- Portable release tooling installs only the official Godot 4.7.1 Windows/Linux
  templates by bounded HTTP range with ZIP CRC/size validation, excludes
  non-runtime workspace content, emits checksummed Windows ZIP/Linux tar.gz
  friend builds and preserves Linux executable modes across a Windows host.
- `scripts/package.ps1 -Target Windows` now also compiles the one-file
  `exports/release/FLUX2-Windows-Setup.exe`. Its embedded ZIP is verified before
  bounded zip-slip-safe extraction, installed per-user into a versioned staging
  tree, selected only after every inner checksum passes, and reused as the local
  launcher. `scripts/test-windows-bootstrap.ps1` passed clean install, forced
  repair and installed 120 Hz export boot for payload
  `0.1.0-dev-872b62227a-c08c59e8c4`; packaged Farflow host/guest/late-guest also
  passed at 120 Hz on UDP 24913. The tested Downloads copy SHA-256 is
  `4ea9be775c0c266b0be143af3b21da19bd67362aebae31e868059a65cc466c57`.
- Release boot exposed and fixed an editor-vs-export validation defect: runtime
  kits now validate authored source hashes/PNG bytes in source gates and imported
  32×32 Texture2D resources in exports. The selected build is no longer changed
  by source-only provenance files that Godot correctly compiles/remaps away.
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
