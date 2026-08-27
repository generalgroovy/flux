# Active implementation memory

This compact handoff complements the append-only `WORKLOG.md`; update it after
each playable slice.

## Eight-direction movement plan — 2026-08-27

- Final direction coverage is now `S/SE/E/NE/N/NW/W/SW` for movement and
  facing, not character art alone. The current four-cardinal atlas remains the
  green runtime fallback until each diagonal action family passes review.
- Simulation movement/aim stay continuous; keyboard diagonals stay normalized.
  A future shared presentation resolver will classify travel and facing
  independently with stable sector hysteresis, enabling free travel-facing and
  aim-facing forward/back/strafe gait without changing rules or networking.
- Ordered slices are resolver/tests, eight-way input parity, diagonal core
  bodies, diagonal locomotion/relative gait, advanced movement, spell delivery,
  environment alignment, and full accessibility/Farflow/package acceptance.

## Semantic champion action aliases — 2026-08-26

- `foundation-champion-visuals-v5-semantic-actions` now declares every
  authoritative movement/control/cast/defeat action plus the existing
  attack/defense/interaction/taunt presentation vocabulary as an explicit alias
  to one of the eight promoted cardinal body rows. Advanced moves reuse a row
  intentionally; renderer branches no longer hide that choice.
- `CartoonChampionPresenter.semantic_action()` preserves the specific live
  action ID, while `atlas_state_for_action()` resolves validated content and
  returns no region for an unknown action. Missing, extra, and nonexistent-row
  aliases fail closed and clear stale mappings.
- Westward impact-recovery and S. Wayne cast/recovery captures passed at
  1280×720/75% under `.godot/visual-captures/semantic-v5-*`; the recovery body
  no longer snaps to idle before its authoritative recovery timer ends.
- Interaction, taunt, and defense aliases are ready for an app-local
  presentation cue, but the current `PlayerState` does not own such a timer;
  no false simulation state was added merely to trigger art.
- Full Windows source gate: 54 suites / 16,833 assertions, zero failures;
  independent 60/120 Hz boots passed with the unchanged v5 atlas hash.
- Checkpoint `06d9248` is unified on `main` and
  `codex/continuous-overhaul`. Its clean-install/repair/installed-boot test and
  packaged 120 Hz smoke passed. Installer SHA-256 is
  `ff4be85b7b0035d954c22b338d24f68f3fa4217204ce62eb078cca9691449fdb`;
  portable ZIP SHA-256 is
  `a81f49b277418eeb6454a2be2f6e332421f64b745315f948f00ba8501f9fb884`.
- Next visual slice: make projectile/beam/spray/field startup and release cues
  select their cardinal empty-hand delivery lane through validated content,
  then capture both foundation champions without changing spell rules.

## Cardinal locomotion and evasion atlas — 2026-08-26

- The active body-only atlas now adds dedicated walk contact, sprint drive, low
  slide and tucked roll rows to the four core action rows for Oh Tipi and
  S. Wayne; all eight semantic rows own south/east/north/west art and share the
  `(48,84)` feet pivot.
- `runtime_atlas_cardinal_v5.png` is 384×1536 / 159,190 bytes. PNG SHA-256 is
  `1bea3c7f8d35b331801a81cc63f54388671ec0df658ec8a16a18393ed6866680`;
  Godot-imported RGBA SHA-256 is
  `72ad872e6c5b824615a9cb348b384fd15a8e2933892828f3ca3f9633c8a9472b`.
  A clean rebuild reproduced the exact PNG hash.
- Walk/Slowed selects walk, Sprint selects sprint, Slide/Wave Dash/Wall Skim
  selects the low row, Roll selects the compact tuck, and airborne techniques
  retain the four-direction jump row. Reusable motion, shadow, wake, aura and
  invulnerability-contour layers remain separate; no simulation rule changed.
- The capture-only `--capture-direction=south|east|north|west` argument now
  produces deterministic cardinal movement evidence while preserving the old
  impact-recovery influence lane and ordinary player input.
- Full Windows gate: 54 suites / 16,760 assertions, zero failures; 60/120 Hz
  boots passed. Thirty-two direction/state runs cover walk/sprint and correctly
  timed post-tick-6 slide/roll for both champions at 75%; additional 50%, 100%,
  1920×1080, high-contrast and reduced-effects captures pass under
  `.godot/visual-captures/movement-v5-*`.
- The follow-on semantic-alias slice now closes live movement, control, cast,
  recovery and defeat coverage; interaction/taunt/defense have explicit future
  aliases without pretending the simulation currently owns their timers.
- Runtime/content checkpoint `649e0d8` is unified on `main` and
  `codex/continuous-overhaul`. Installer SHA-256 is
  `c265f5019b8f92db0a0c012d513e5b0952f81547f5cef0e8f152cb5e31566dc9`;
  portable ZIP SHA-256 is
  `55b53c3bbb43c3d83817c33fd5cdec81ddc6e66e8e08c991e0fa3dd6388ae2a8`.
  The export log includes v5 only—no editable source or superseded v3/v4
  atlas—and the packaged executable booted headlessly at 120 Hz.

## Dedicated cardinal action atlas — 2026-08-26

- Oh Tipi and S. Wayne now use separate repository-owned 4×4 matte sources with
  dedicated south/east/north/west columns and grounded/jump/empty-hand-cast/
  hit-recovery rows. Both profiles are authored; the runtime no longer reuses a
  grounded pose for east/north/west actions.
- `scripts/build_cardinal_champion_atlas.py` proportionally slices the 1254px
  sources, removes only edge-connected matte, preserves one scale per champion,
  aligns pivot `(48,84)`, and deterministically packs the 384×768 body-only
  `runtime_atlas_cardinal_v4.png`.
- Runtime PNG SHA-256 is
  `b7620ebfb896c99ac21b956ac08ed6d6a5c2e0c7b15fcdb3de048960cd849de5`;
  Godot-imported RGBA SHA-256 is
  `103b30737ff6b68a0ca449e6acde873e930f1242ede865511103c950a7ebfbea`.
  Exact source hashes, ImageGen prompts, layout and build command are beside the
  assets in `foundation/provenance.json` and `foundation/README.md`.
- Full Windows source gate: 54 suites / 16,735 assertions, zero failures;
  independent 60/120 Hz boots passed. A second build reproduced the exact PNG
  hash. Eight-directional cast runs (four per champion) and four targeted
  jump/hit runs produced 96 truthful 1280×720/75% frames under
  `.godot/visual-captures/cardinal-v4-*`; representative cast, back-jump and
  hit/recovery frames were visually inspected.
- The next C2 slice is dedicated direction-complete locomotion/evasion body art
  and live 50/75/100% accessibility capture. Walk/sprint/slide/roll currently
  retain the grounded body cell and use reusable motion/accent layers, so V2 is
  not yet claimed complete.
- Runtime/content checkpoint `c4c4bce` is unified on `main` and
  `codex/continuous-overhaul`. Its Windows installer SHA-256 is
  `75a45940f906f8a81df0d60f7dfc3fa310d265873129f0caafcefaa49b7605c0`;
  portable ZIP SHA-256 is
  `f2bf73e21daeb3bceb345dfd9391e28f5526d190afc2970e9d0180d42d31133c`.
  The packaged executable booted headlessly at 120 Hz with atlas hash
  `b7620ebfb896`; editable sources and the superseded atlas are excluded from
  the export.

## Four-cardinal animation contract — 2026-08-26

- Character animation data now explicitly requires `south`, `east`, `north`,
  and `west` coverage for every skeleton animation and all three canonical body
  types; diagonals remain authored-or-derived presentation rows.
- The live foundation cartoon presenter validates a data-driven cardinal pose
  table and preserves facing through grounded, jump, cast and hit states. South
  retains the dedicated action silhouettes; east/north/west retain their body
  orientation while separate motion, hand-cast, shadow and feedback layers
  communicate the action.
- Full Windows source gate: 54 suites / 16,730 assertions, zero failures;
  independent 60/120 Hz boots passed. Eight three-frame 1280×720/75% captures
  cover both champions in south/east/north/west under
  `.godot/visual-captures/cardinal-v1-*`.
- This is the fail-closed direction/facing foundation, not final authored
  action art. Next C2 slice: replace east/north/west action fallbacks with
  reviewed body-only directional action frames while retaining the same data
  contract and pivots.

## Shared hand-cast phase cue — 2026-08-26

- `FoundationSpellPresenter.draw_startup` now resolves the central skeleton's
  phase and draws a shared origin ring for `startup` plus a directional release
  flash for `release` at the empty hand; shape-specific visuals remain layered
  and simulation still owns timing, cost, collision and outcomes.
- Verification: 54 suites / 18,676 assertions, zero failures; source boots at
  60/120 Hz. Eight truthful 1280×720/75% startup-and-chain cast frames captured
  in `.godot/visual-captures/post-unify-v9-hand-cue-v2`.
- Four-frame 1280×720/75% high-contrast and reduced-effects captures pass;
  HUD, routes, actors, stations and court accents remain legible.
- The next package rebuild must include this slice; keep mechanics frozen until
  the V0–V6 visual gate is accepted.

## Source-court approach accents — 2026-08-26

- Added six validated, presentation-only decorations to
  `court_profile.decorations`: two light lanterns, two wind planters, and two
  charge/water runes. Their offsets stay inside the court interior and their
  0.75–1.25 scale range is bounded.
- The renderer draws these after pavers with shared ramps and lower opacity in
  reduced-effects mode. They cannot change topology, collision, route data,
  station radii, or simulation state.
- Verification: 54 suites / 18,674 assertions, zero failures; source boots at
  60/120 Hz. Four truthful 1280×720 frames captured at 75% zoom in
  `.godot/visual-captures/post-unify-v9-720`.
- Windows package rebuilt from runtime/content commit `08cacfb` (the later
  handoff-only metadata commit changes no payload files); installer SHA-256
  `1bb4eee646ff49f9725784b61dad29cbd0208a8b1d8534641e98a5eebcd41bea`,
  portable ZIP SHA-256
  `e88869ebb321dd48ea61f9d9fa31c8c559c30b599b2c55dab7e4b412ea0f6a4e`.
- Packaged `exports\\windows\\flux2.exe` headless smoke exited 0; `main` and
  `codex/continuous-overhaul` remain unified at the same commit.

## Visual registry/hash slice — 2026-08-26

- `VisualAssetRegistry` now binds and validates the spell-animation skeleton
  manifest, keeping visual content discoverable from one registry.
- `FoundationSpellPresenter.animation_skeleton_hash` and the bootstrap line
  expose the manifest version beside the profile hash for reproducible captures.
- Verification: 54 suites / 18,671 assertions, zero failures; Windows source
  boots at 60/120 Hz. Legacy archive image-load warnings remain expected.
- Windows package rebuilt from unified `main` at `c124cec`: installer SHA-256
  `dbd1a6253473b3f0a345209c71651318cbbccadb9f6d2073cb5bf780237e2d78`, portable
  ZIP SHA-256 `7fbbf6d445a1b7361a1e8245ced2a0bb4b5099f63c32238fe556cfe596c80b81`.
- `exports\\windows\\flux2.exe` boots headlessly at 120 Hz; share only the
  matching ZIP/installer and checksum file with trusted Windows testers.

## Spell delivery skeleton slice — 2026-08-26

- `content/visual/spell_animation_skeletons_v1.json` and
  `src/presentation/spell_animation_skeleton_library.gd` define four reusable
  shape families (projectile, beam, spray, field) and five ordered phases
  (startup, release, travel, impact, residue).
- Foundation spell profiles now carry `skeleton_id`; the presenter validates
  shape agreement and refuses missing/mismatched delivery skeletons.
- The skeleton contract is presentation-only. Simulation still owns every
  authoritative timer, geometry, collision, resource, damage and outcome.
- Verification: 54 suites / 18,669 assertions, zero failures; Windows source
  boots at 60/120 Hz. Expected legacy image-load warnings remain in archive
  validation.
- Rebuild the Windows package after this commit; the previous installer hash
  describes the body/hand-origin package and is not the new release artifact.

## Data-driven body atlas rows — 2026-08-26

- Body-only champion recipes now own `atlas_row` (`oh_tipi=0`, `s_wayne=1`);
  the presenter no longer contains champion-specific row branches.
- Missing/out-of-range rows fail closed during recipe validation and produce an
  empty source region, keeping future champion additions data-only and safe.
- Verification: `scripts\\test.cmd` passed 53 suites / 18,644 assertions with
  zero failures and independent Windows source boots at 60/120 Hz.
- Rebuild the packaged Windows installer after this commit; the prior package
  hash in this file describes the preceding hand-origin slice.

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
- High-contrast and reduced-effects 1280×720 captures at 75% passed under
  `.godot/visual-captures/body-v3-high-contrast-720` and
  `.godot/visual-captures/body-v3-reduced-720`; both were inspected for
  silhouette, HUD and spell-cell readability.
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
