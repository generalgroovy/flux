# FLUX2 agent worklog

## 2026-08-12 — bounded Farflow movement prediction

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced the friend-session boundary to protocol 15 and added a separate
  unreliable-ordered reconciliation channel. Every remote traveller receives
  only its own full movement state plus the last input sequence the host
  actually processed; the shared combat/target snapshot remains unchanged.
- Added `ClientPrediction`, which strips all combat bits, keeps at most 48
  movement inputs, predicts the complete universal movement grammar against the
  authored collision world, drops acknowledged inputs and deterministically
  replays the remainder from each host state.
- Small corrections retain a capped, rapidly decaying draw-only offset; large,
  reduced-motion or history-overflow corrections snap explicitly. Health, Flux,
  damage, spells, cooldowns, targets and stations remain snapshot/host-owned.
- The Farflow HUD now shows estimated acknowledgement delay and the last
  correction magnitude. Diagnostic `--farflow-smoke-prediction` produces a
  short movement input without adding a player-facing menu.
- Corrected the shared snapshot cadence to one tick at 60 Hz and two ticks at
  120 Hz so both supported simulations publish the contracted 60 snapshots per
  second.
- Added stable semantic event IDs, four-snapshot redundancy and a bounded
  64-event client inbox. This prevents a fresher unreliable snapshot from
  erasing HELLO/combat feedback before presentation while deduplicating every
  retained resend.

Validation:

- Full pinned Godot 4.7.1 suite passed with **14,384 assertions**, zero failures
  across 33 suites. The 111 prediction assertions cover 60/120 Hz convergence,
  complete jump/movement state, combat-bit stripping, bounded history, stale
  authority, soft correction decay/cap and hard-snap behavior.
- Real ENet tests keep the reconciliation packet below one 1,392-byte MTU,
  scope it to the target peer/entity and isolate it from the shared snapshot
  channel.
- Two complete Windows headless processes connected over UDP localhost on port
  24878 under protocol 15. RiverGuest confirmed host-authoritative displacement
  at input sequence 10 and also completed the shared HELLO path.
- Independent 60/120 Hz boots passed with campus/ability/champion hashes
  `c981419a5b33` / `566a637aa616` / `81962afbff12`.

Known limitations and next task:

- `ACK ~ms` is an outstanding-input age estimate, not a network round-trip ping;
  timestamped RTT/jitter/loss diagnostics remain.
- Reconnect identity, forced host shutdown, packaged Garuda Linux direct-IP,
  authentication/encryption and dense eight-player snapshot batching remain.
- Next slice reserves a bounded reconnect identity, communicates host loss and
  proves leave/rejoin cleanup before broader session configuration.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-11 — host-authorized Wellspring interactions

Branch: `codex/continuous-overhaul`

What changed and why:

- Added a bounded reliable request channel for social emotes, Practice Bell
  restoration and Champion Loom attunement. The server stamps the trusted peer
  identity, rejects replayed sequences and validates every station request
  against the authoritative actor position before changing shared state.
- Made `T` / controller D-pad up produce a transparent in-world **HELLO!**
  bubble with a host-enforced cooldown. Accepted and refused requests are
  returned as semantic events so a guest receives an explicit result instead
  of guessing whether an interaction happened.
- Replicated the four bounded training-target states, including health and
  reset, so remote combat and the Practice Bell now describe the same court.
  Champion attunements survive a practice reset and only the actor at the Loom
  changes champion.
- Compacted player entries, hashes and overflow counters so a representative
  two-player combat snapshot with target state fits within one 1,392-byte ENet
  MTU while the measured eight-player public envelope remains capped at 8 KiB.

Validation:

- Full pinned Godot 4.7.1 suite passed with **14,246 assertions**, zero
  failures across 32 suites; request policy, malformed/replayed packets, social
  events, shared target health and the single-MTU fixture are covered.
- Two complete Windows headless processes connected over UDP localhost on port
  24876 under protocol 14. The guest sent an emote request after its first snapshot; the host
  accepted RiverGuest as entity 2 and both processes confirmed the same shared
  emote.
- Advanced the wire boundary to protocol 14 / snapshot schema 3 so older
  protocol-13 combat clients fail the handshake instead of decoding the compact
  target-aware tuple layout incorrectly.
- Independent 60/120 Hz boots passed with protocol 14 and campus/ability/
  champion hashes `c981419a5b33` / `566a637aa616` / `81962afbff12`.
- `git diff --check` passed; generated `dist/` and `node_modules/` remained out
  of scope.

Known limitations and next task:

- Guests still render interpolated authority without local prediction or
  correction metrics; the next slice adds bounded input history, prediction,
  reconciliation and visible latency/correction diagnostics.
- Reconnect identity, forced host shutdown, packaged Garuda Linux direct-IP,
  encryption/authentication, richer social actions and settings/travel remain.
- Dense eight-player combat may exceed one MTU even though it remains below the
  explicit packet cap; measured delta/batching work precedes that acceptance.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-11 — protocol-13 Farflow combat presentation

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced the network protocol to 13 and snapshot schema to 2 so older peers
  fail compatibility instead of joining and silently dropping combat state.
- Extended snapshots with the player cast/cooldown fields needed by the HUD,
  compact render-only projectile lanes, readable last-action state and strictly
  encoded cast, hit, impact, bounce and Edgeweave events. Guests reconstruct
  presentation only; projectile collision, damage, control and resources still
  come solely from the host simulation.
- Added short, restrained in-world feedback rings/labels for damage, Edgeweave,
  refused/blocked casts and ricochets on both host and guest.
- Preserved the 8 KiB packet cap. The measured public envelope covers eight
  maximum-name travellers, 26 simultaneous projectiles and 12 recent events;
  excess presentation is counted and surfaced as Farflow load rather than
  silently expanding the trust/memory boundary.

Validation:

- Full pinned Godot 4.7.1 suite passed with **14,216 assertions**, zero failures;
  `authoritative-session` contributed 57, real-ENet `session-transport` 46 and
  `session-snapshot` 32 assertions.
- Maximum-envelope serialization, projectile/event round-trip, malformed field
  rejection and one-shot event acknowledgement pass.
- Two complete Windows headless processes connected over UDP localhost on port
  24874 under protocol 13; guest entity 2 applied the schema-2 two-player stream.
- Independent 60/120 Hz boots passed with campus/ability/champion hashes
  `c981419a5b33` / `566a637aa616` / `81962afbff12`.

Known limitations and next task:

- Snapshot overflow is explicit but still a visual omission; a later measured
  batching/delta scheme is required before dense eight-player combat acceptance.
- Host-authorized station interaction, champion requests, emotes, prediction,
  reconciliation, reconnect and Linux direct-IP packaging remain.
- Next slice adds a validated client request/host confirmation channel, starting
  with a transparent social emote and shared Practice Bell restoration.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-11 — authoritative Farflow travellers and movement snapshots

Branch: `codex/continuous-overhaul`

What changed and why:

- Added stable session entity IDs 1-8, accepted/disconnected presence queues and
  trusted peer-to-entity stamping. The host owns the roster; the first guest is
  S. Wayne beside host Oh Tipi so the playable network check exercises both
  foundation champions instead of cloning one placeholder.
- Added `AuthoritativeSession`: it creates/removes collision-cleared peer actors,
  merges one-shot inputs without losing presses, stamps every command to the host
  tick, simulates all travellers together and fails stale remote input to idle
  after 250 ms. Clients still cannot choose position, resources or outcomes.
- Added a compact, strictly validated snapshot schema for up to eight sorted
  travellers. The host publishes at 60 Hz from both supported simulation rates;
  guests follow their assigned actor and render authoritative movement, jump,
  resources, champion kit, display names and the other traveller's champion
  sprite/health. Projectiles are deliberately the next replication slice.
- Added diagnostic `--farflow=host|join` startup switches for repeatable platform
  smoke tests while preserving the walk-up Farflow stations as the player-facing
  flow. Client reset, tick-rate and attunement mutations now explain that host
  authorization is required instead of silently diverging.

Validation:

- Pinned Godot 4.7.1 import and full headless suite passed with **14,197
  assertions**, zero failures. New evidence: `authoritative-session` 54,
  `session-transport` 44 and `session-snapshot` 18 assertions.
- Independent 60/120 Hz boots passed at protocol 12 with campus/ability/champion
  hashes `c981419a5b33` / `566a637aa616` / `81962afbff12`.
- Two complete Windows headless game processes connected over UDP localhost on
  diagnostic port 24873: host logged `RiverGuest` as entity 2 and guest applied
  a two-traveller snapshot at host tick 150. This caught and fixed a runtime-only
  typed-array startup failure that import and unit parsing did not expose.
- `git diff --check`: passed; generated `dist/` and `node_modules/` stayed out of
  scope.

Known limitations and next task:

- Guest movement/resources are authoritative and visible, but projectile state,
  semantic combat feedback, shared station requests, emotes, prediction and
  reconciliation are not yet replicated.
- Windows localhost is proven; packaged Windows and Garuda Linux direct-IP
  acceptance, firewall UX, reconnect and host shutdown remain required.
- Next slice adds bounded projectile snapshots and shared impact/cast feedback,
  then host-authorized Wellspring interaction and a transparent social emote.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-11 — diegetic Farflow ENet transport boundary

Branch: `codex/continuous-overhaul`

What changed and why:

- Added a platform-native raw ENet/UDP session transport with direct host/join,
  an eight-player public cap, explicit offline/hosting/seeking/joined state and
  safe leave/refusal/disconnect cleanup. It uses no external service or account.
- Added a fail-closed SHA-256 handshake over protocol, tick rate, campus, ability
  and champion hashes. Packets are object-free, capped at 8 KiB and processed
  under a 64-packet budget; host input validation is strictly typed/ranged,
  sequence-monotonic and bounded to 28 queued commands.
- Advanced the campus to schema 4 and added distinct **Host Farflow** and **Join
  Farflow** walk-up stations in the eastern concourse. F opens/closes each gate;
  bubbles and the always-visible HUD report offline, seeking, host count, joined
  or refusal state. Join defaults to loopback and accepts direct-IP CLI overrides.
- Added `docs/NETWORKING.md` with exact friend setup, firewall/UDP constraints,
  security limitations, current truth and the authoritative replication order.

Validation:

- Real single-process ENet loopback passes compatible handshake, sender-stamped
  bounded input, mismatched-build rejection and accepted-peer disconnect cleanup.
- Full pinned Godot 4.7.1 headless gate passed after station integration with
  14,111 assertions and zero failures; transport itself contributed 33 assertions.
- Canonical campus JSON parse, pinned import and `git diff --check`: passed.
- Independent 60/120 Hz bootstrap smokes passed with protocol 12 and campus hash
  `c981419a5b33`; ability/champion hashes remained `566a637aa616`/`81962afbff12`.

Known limitations and next task:

- Connected peers do not yet share simulation actors or snapshots; this is a
  working transport/handshake checkpoint, not a claim of remote gameplay.
- Direct Internet hosting currently needs manual UDP firewall/router forwarding;
  discovery, relay, NAT traversal, encryption and authentication are future gates.
- Next slice maps accepted peer IDs to authoritative simulation actors, consumes
  inputs on the host, broadcasts a bounded roster/snapshot and renders both peers.

Commit: pending. Push: pending.

## 2026-08-11 — S. Wayne basic combat pair

Branch: `codex/continuous-overhaul`

What changed and why:

- Replaced S. Wayne's shared placeholders with **Eclipse Disc** (wire 142), a
  resource-free Dark primary whose slower, larger lane can ricochet exactly once,
  and **Pocket Eclipse** (wire 143), a 20-Flux Light active that exchanges burst
  damage for a readable 600 ms movement slow at 55% speed.
- Added canonical projectile bounce count and on-hit slow strength. World
  collision owns axis reflection, every bounce emits a semantic event, and
  protocol advanced to 12 so replay/session mismatch cannot omit either field.
- Gave the spells distinct presentation silhouettes: the disc reads as a split
  Dark/Light ring with a trail, while Pocket Eclipse reads as a bright occluded
  orb with four restrained rays. Presentation reads confirmed simulation state
  and owns no reflection, damage or status decisions.

Validation:

- Canonical JSON parse and `git diff --check`: passed.
- Pinned Godot 4.7.1 full headless gate: 14,074 assertions, zero failures.
  New 60/120 Hz coverage proves catalog/compiler parity, champion kit binding,
  exact cost/startup/damage, one surviving world ricochet, reflected velocity,
  consumed bounce count and exact bounded slow duration/ratio.
- Pinned Godot 4.7.1 import: passed with no script/import/runtime error markers.
- Independent 60/120 Hz bootstrap smokes passed with protocol 12, ability hash
  `566a637aa616`, champion hash `81962afbff12` and campus hash `a26f6ecd6105`.
- A compatibility-renderer 1280 x 720 S. Wayne capture passed and was visually
  inspected: selected champion, exact resource maxima and both named controls
  are readable in the always-visible Wellspring HUD.

Known limitations and next task:

- The two champions now have working, differentiated basic pairs but still need
  deeper dummy behavior, defense, full kits, final animation/audio, accessibility,
  replay/network and Windows/Linux package acceptance.
- Next slice promotes the Wellspring's host/join stations and authoritative ENet
  loopback boundary so two players can connect, move and interact without a menu.

Commit: pending. Push: pending.

## 2026-08-11 — Oh Tipi basic combat pair and sparring effigy

Branch: `codex/continuous-overhaul`

What changed and why:

- Replaced Oh Tipi's shared foundation kit with **Rillshot** (wire 140), a
  resource-free Water primary with quick readable cadence, and **Tideline**
  (wire 141), a slower 22-Flux Water crest that deals modest damage and applies
  a bounded 180 ms launch. S. Wayne intentionally retains Arc Primary/Vector
  Lance until the next distinct-kit slice.
- Made equipped primary/active wire IDs canonical champion state. The combat
  compiler now resolves all four projectile definitions by stable wire ID, and
  projectile state carries canonical on-hit control without moving authority
  into presentation. Protocol advanced to 11 for actor kind, equipped kit and
  hit-control compatibility.
- Advanced the campus to schema 3 with a validated 80-Health Sparring Effigy
  beside spawn. It is a stable host-simulation entity, receives ordinary swept
  hits and Tideline launch, has no hidden recovery, renders a clear target/Health
  cue, and resets with the existing Practice Bell.
- Reworked the always-visible HUD to show current/maximum Health, Flux and
  Stamina, readable semantic cast names, each selected champion's actual LMB/RMB
  actions, active Flux cost/cooldown, F interaction and current view mode.

Validation:

- Pinned Godot 4.7.1 import: passed.
- Full pinned headless gate: 13,901 assertions, zero failures. New coverage
  verifies catalog/compiled-value parity, champion kit binding, exact Rillshot
  and Tideline startup/cost/damage/cooldown at 60/120 Hz, Tideline launch state,
  canonical actor kind, target schema/placement/clearance and invalid refusal.
- Independent 60 and 120 Hz bootstrap smokes: passed with protocol 11, ability
  hash `c9339a6c7b62`, champion hash `18f62965e9e2` and campus hash
  `a26f6ecd6105`.
- A compatibility-renderer 1280 x 720 capture passed and was visually inspected:
  named kit hints, exact maxima, the target and all three stations are readable.
- Windows app control successfully aimed and fired Rillshot into the effigy;
  its Health bar decreased. Synthetic right-click was interpreted as another
  left click by the automation layer, so normal hardware Tideline activation
  remains the user's interactive check; exact simulation behavior is covered.
- `git diff --check`: passed; pre-existing `dist/` and `node_modules/` remain
  untouched and untracked.

Known limitations and next task:

- Rillshot/Tideline still use economical procedural projectile VFX and no audio;
  full counterplay presentation, defense, deeper kit slots and final art remain.
- Next slice gives S. Wayne a distinct Dark/Light basic pair that counterplays
  Oh Tipi without automatic elemental damage advantage, then both basic pairs
  enter replay/effigy and local two-player acceptance before host/join transport.

Commit: pending. Push: pending.

## 2026-08-11 — canonical first two champion identities

Branch: `codex/continuous-overhaul`

What changed and why:

- Added a fail-closed `foundation-champions-v1` content catalog for Oh Tipi and
  S. Wayne with stable positive wire IDs, two-to-three validated affinities,
  ancestry/size identity, bounded simulation stats and valid foundation ability
  references. Oh Tipi is a steady Seakin; S. Wayne is now consistently a small
  Hobbit rather than the stale Human/vampire-cloak production entry.
- Promoted champion identity, maxima, recovery rates and bounded ground-speed
  ratio into canonical `PlayerState`; recovery, movement, Edgeweave, HUD and
  replay hashing consume those authoritative fields. Protocol advanced to 9.
- Added the collision-clear Champion Loom below spawn. F/controller north-face
  cycles Oh Tipi and S. Wayne, atomically applies the profile, reloads the
  eight-direction candidate sprite and reports the attunement in a transparent
  world bubble. Both champions keep the full universal movement grammar.
- Added `--champion=oh_tipi|s_wayne` as a deterministic visual/boot diagnostic,
  not as a player-facing menu. Updated the runtime HUD, roadmap, roster truth,
  visual production notes and active backlog.

Validation:

- Pinned Godot 4.7.1 import: passed and generated tracked UIDs for the champion
  catalog and focused suite.
- Full pinned headless gate: 13,728 assertions, zero failures. Coverage proves
  catalog refusal, exact 60/120 Hz profile movement/recovery, resource-ratio
  migration, stable cycling, station focus and canonical identity divergence.
- Independent 60 and 120 Hz bootstrap smokes: passed with protocol 9, champion
  catalog hash `9f807091310f` and campus hash `2700e76503bd`.
- Compatibility-renderer three-frame captures passed for both Oh Tipi and
  S. Wayne at 1280 x 720. Both distinct sprites, named HUD profiles, exact
  resource maxima and the labeled Champion Loom were visually inspected.
- A dummy-renderer movie attempt crashed inside Godot's null texture storage;
  the equivalent compatibility-renderer capture passed, so visual capture must
  continue without `--headless` when runtime textures are drawn.
- `git diff --check`: passed; only pre-existing `dist/` and `node_modules/`
  remain intentionally untracked.

Known limitations and next task:

- The two champions still share Arc Primary and Vector Lance as explicit
  foundation placeholders. The next slice gives Oh Tipi the first distinct,
  readable basic primary/active behavior and a deterministic practice target,
  then gives S. Wayne a counterplaying Dark/Light basic kit.
- Physical F/controller activation still needs the user's normal hardware
  playtest because external synthetic physical-key injection is unreliable in
  Godot; catalog, station focus and app action paths are otherwise covered.

Commit: pending. Push: pending.

## 2026-08-11 — first diegetic walk-up stations

Branch: `codex/continuous-overhaul`

What changed and why:

- Advanced the campus to schema 2 with two collision-clear Nexus stations: the
  Movement Guide exposes concise movement notes and the Practice Bell restores
  the deterministic training court and all player resources.
- Added a pure fixed-point nearest-station model with bounded authored radii,
  stable lexical tie-breaking and fail-closed malformed-entry behavior.
- Added F and controller north-face interaction defaults. The Guide toggles a
  transparent world-space bubble; the host-authority Bell executes locally in
  offline play and shows a short player-anchored restoration notice.
- Added original pulsing book/bell pedestals and concise labels. Station content
  validates known command, authority, district, collision clearance, radius and
  one-to-six-line copy before the campus can boot; no detached menu was added.

Validation:

- `git diff --check`: passed; campus JSON parses as schema 2 with two stations.
- Pinned Godot 4.7.1 import: passed and generated tracked UIDs for the station
  focus model and focused test suite.
- Pinned Godot 4.7.1 full headless gate: 13,315 assertions, zero failures.
- Repository stations, exact-range exit, nearest choice, equal-distance stable
  tie-break, invalid entry refusal, invalid command/radius/collision placement,
  F binding and controller binding are covered.
- Independent 60 and 120 Hz headless bootstrap smokes exited successfully.
- Windows interactive smoke remained responsive; both labeled pedestals and
  the F interaction legend were visible at gameplay zoom.

Known limitations and next task:

- External synthetic keyboard injection did not produce reliable Godot
  physical-key events, so bubble activation still needs the user's normal
  keyboard/controller playtest; model, bindings and app flow are structurally
  covered and the build remains open for that check.
- Offline play is the local host, but network request/authorization transport
  does not exist yet; the Practice Bell's declared host authority is content
  policy in preparation for that slice.
- Next slice extends the reusable station contract with champion switching,
  then implements Oh Tipi and S. Wayne selection/runtime identity before
  settings and host/join stations.

Commit: pending. Push: pending.

## 2026-08-11 — intensity-scaled landing readability

Branch: `codex/continuous-overhaul`

What changed and why:

- Added canonical 0–1000 landing intensity selected from the completed route:
  hop, double jump, slide jump, wall kick, fast fall, air dodge and wall skim
  now retain distinct readable impact weight through the short landing window.
- Added a pure presentation sampler with normalized phase, intensity-scaled
  shadow squash and an expanding/fading four-mark rune ring. Reduced motion
  keeps the timing information while limiting travel, opacity and stroke width.
- The runtime composes the pulse beneath the existing semantic land animation,
  clears it on a new traversal action or landing cut, and labels V as the
  contextual technique instead of the incomplete vault/air-only wording.
- Advanced protocol to 8 so replay/session mismatch cannot silently omit the
  canonical landing intensity.

Validation:

- `git diff --check`: passed.
- Pinned Godot 4.7.1 import: passed and generated tracked UIDs for the new
  presentation sampler and focused test suite.
- Pinned Godot 4.7.1 full headless gate: 13,293 assertions, zero failures.
- Landing phase, ring radius/opacity, shadow width and reduced-motion behavior
  are normalized at 60/120 Hz; sampling does not mutate canonical authority.
- Simulation verifies fast-fall intensity survives to landing, wall-skim exit
  uses its authored lighter pulse, and intensity clears with recovery expiry.
- Independent 60 and 120 Hz headless bootstrap smokes exited successfully with
  protocol 8; Windows interactive smoke remained responsive.

Known limitations and next task:

- The ring is procedural original presentation; accepted atlas-specific dust,
  material contact particles and audio remain later polish.
- Collision-safe combat knockdown recovery remains a separate combat slice and
  must not become a universal cancel or erase earned launch advantage.
- Next implementation slice begins walk-up Wellspring station interactions,
  starting with a reusable deterministic proximity/selection model and the
  Movement Guide plus training-reset stations.

Commit: pending. Push: pending.

## 2026-08-11 — bounded authored-obstacle wall skim

Branch: `codex/continuous-overhaul`

What changed and why:

- Added a contextual V wall skim after recent contact with a positive-ID
  authored obstacle: an 18-Stamina purchase produces 420 ms of fixed-speed
  tangent travel and never activates on reserved negative-ID world boundaries.
- Added a separate 300 ms general cooldown and 900 ms same-surface lockout so
  the route is expressive but cannot loop one wall; vault retains priority and
  airborne V retains redirect/air-dodge behavior.
- Added canonical skim direction, timers, surface identity, lockout and explicit
  movement/event state; the existing landing window now provides a short exit
  recovery animation contract. Advanced protocol to 7.

Validation:

- `git diff --check`: passed.
- Pinned Godot 4.7.1 full headless gate: 13,219 assertions, zero failures.
- At both 60 and 120 Hz: positive obstacle contact starts the exact bounded
  skim and cost, requested tangent advances, exit recovery appears, immediate
  same-surface retry spends nothing, and outer boundaries cannot activate it.
- Independent 60 and 120 Hz headless bootstrap smokes exited successfully with
  protocol 7.

Known limitations and next task:

- Wall skim currently reuses the wall-kick animation family until accepted
  character atlases receive a distinct skim strip and surface dust/audio cue.
- Landing state exists and the skim now enters it, but authored intensity,
  squash/ring/audio and collision-safe timed recovery remain incomplete.
- Next implementation slice adds presentation-owned landing/recovery cues, then
  begins walk-up Wellspring station interactions.

Commit: pending. Push: pending.

## 2026-08-11 — variable jump and explicit fast fall

Branch: `codex/continuous-overhaul`

What changed and why:

- Added canonical held-jump and fast-fall command bits. Holding Space preserves
  the authored arc, releasing cuts remaining air time to a bounded 90 ms
  minimum, and airborne Ctrl/C advances descent by one extra tick per tick.
- Added explicit fast-fall simulation/presentation state and mapped it to the
  existing validated fall animation contract; fast fall costs no Stamina because
  accepting an earlier landing is the commitment.
- Added one canonical transition-grace tick so slide-jump and air-redirect events
  remain observable before release-cut timing begins.
- Advanced protocol to 6 and updated movement documentation and status.
- Corrected three earlier worklog assertion totals by summing their preserved
  test logs; no test outcome changed.

Validation:

- `git diff --check`: passed.
- Pinned Godot 4.7.1 full headless gate: 13,106 assertions, zero failures.
- At both 60 and 120 Hz: held jumps outlast released jumps, release preserves
  the exact bounded minimum, fast fall has an explicit mode and exact extra
  descent rate, spends no Stamina, and all Conservatory route transitions remain
  ordered and observable.
- Headless bootstrap at 60 and 120 Hz passed with protocol 6 and unchanged
  canonical campus/ability/material hashes.

Known limitations and next task:

- Jump authority remains a timer-normalized top-down body lift, not a separate
  vertical collision axis; this intentionally preserves the current 2.5D
  topology contract.
- Wall skim and fuller landing/recovery cues remain the final named universal
  movement-feel slices before interactive physical-controller acceptance.
- Next implementation slice adds bounded same-surface wall skim, then begins
  walk-up Wellspring station interactions.

Commit: pending. Push: pending.

## 2026-08-11 — deterministic movement intent buffering

Branch: `codex/continuous-overhaul`

What changed and why:

- Added a shared 180 ms deterministic buffer for dedicated slide, jump-chain
  and contextual technique press edges so slightly early inputs survive narrow
  transition windows without making movement automatic.
- Buffers store semantic intent only. Every tick rechecks speed, aerial stage,
  cooldown, collision target, Stamina and control locks; success consumes the
  matching buffer and expiry spends no resource.
- Included all buffer timers in canonical player state and advanced the command
  protocol to 5 so older replays/sessions cannot silently interpret new timing.
- Updated the public movement contract, overhaul status and active backlog.

Validation:

- `git diff --check`: passed.
- Pinned Godot 4.7.1 full headless gate: 13,081 assertions, zero failures.
- At both 60 and 120 Hz: an early slide fires only after legal entry speed, an
  early jump converts inside the late slide-jump window, successful actions
  consume their buffer, and impossible standing slide expires with no Stamina
  loss.
- Headless bootstrap at 60 and 120 Hz passed with protocol 5 and unchanged
  canonical campus/ability/material hashes.
- Windows interactive compatibility-renderer smoke launched and remained
  responsive with the verified HUD and control legend.

Known limitations and next task:

- Variable jump/fast fall, wall skim and fuller landing/recovery feedback remain
  the open non-ability movement work.
- Controller mapping is structurally tested, but a physical-device acceptance
  session remains required.
- Next slice adds variable jump and fast fall as authoritative bounded state,
  then continues to the Wellspring walk-up interaction layer.

Commit: pending. Push: pending.

## 2026-08-11 — bounded building occlusion for cone view

Branch: `codex/continuous-overhaul`

What changed and why:

- Added pure `SightOcclusion` geometry that projects each axis-aligned
  occluder's two silhouette tangents away from the viewer to a bounded outer
  distance without consulting renderer-owned game state.
- Cone mode now masks space behind every campus building declared
  `los_cutaway`; `low_never_occludes` traversal rails remain visible.
- Preserved the existing validated 15–360° angle and 160–4096 range bounds;
  full-view Sanctum presentation remains the default.
- Updated the public controls/POV contract and active backlog without claiming
  host-side hidden-entity filtering before networking exists.

Validation:

- Pinned Godot 4.7.1 import: passed and registered `SightOcclusion`.
- Full headless gate: 12,944 assertions, zero failures; tangent ownership,
  projection direction, bounded distance, opposite-side viewing and invalid
  inputs are covered.
- 60/120 Hz headless boots with cone 360°/720: passed with protocol 4 and
  identical canonical content hashes.
- Windows interactive 1280 x 720 cone smoke at 120°/720: building north of
  spawn visibly occluded the space behind it while the adjacent vault rail
  remained visible; HUD stayed outside the mask.

Known limitations and next task:

- This is local presentation policy. Authoritative multiplayer modes must omit
  hidden actors/effects/audio from replication and test reconnect, spectator,
  replay and bot paths before cone visibility can govern competitive secrecy.
- Occlusion currently uses a strong opaque wedge. Roof cutaways, soft
  ownership-readable edges and accepted art remain visual-polish work.
- Next slice returns to movement feel completion, then walk-up Wellspring
  interactions and the first two champion vertical slices.

Commit: pending. Push: pending.

## 2026-08-11 — continuous directive and discoverable movement controls

Branch: `codex/continuous-overhaul`

What changed and why:

- Added the repository-owned continuous implementation directive and compact
  active backlog, prioritizing movement, honest visibility, charming readable
  presentation, two complete champions, interactive Wellspring stations and
  authoritative friend hosting/joining while preserving a green checkpoint.
- Versioned commands to protocol 4 with a dedicated slide edge. Shift now
  sprints, Ctrl/C directly slides after the existing readable entry-speed
  commitment, Space jumps/chains, and V retains contextual vault/air control;
  keyboard remapping and controller inputs remain supported.
- Migrated preference schema 1/2 defaults to schema 3 without replacing
  explicit saved alternatives.
- Replaced compressed HP/ST/FX text with distinct Health, Flux and Stamina bars,
  a bounded live movement/event lane and a concise production control legend.
- Made runtime-kit generator provenance hashing newline-canonical so the exact
  approved source validates on Windows CRLF and Linux LF checkouts.

Validation:

- `git diff --check`: passed.
- Pinned Godot 4.7.1 full headless gate: 12,933 assertions, zero failures.
- Dedicated slide entry/cost passed at 60 and 120 Hz; schema 1/2 migrations,
  Shift/Ctrl/C input defaults and portable generator provenance are covered.
- Headless bootstrap at 60 and 120 Hz: passed with protocol 4 and canonical
  campus/ability/material hashes.
- Windows interactive compatibility-renderer smoke: responsive `FLUX 2
  (DEBUG)` window at 1280 x 720; computer-control capture exposed and verified
  repair of an initial title/state overlap; resource bars and controls remain
  legible over the world.

Known limitations and next task:

- Direct slide intentionally requires ordinary movement speed; it is not a
  free standing dash. Input buffering and additional feel work remain backlog.
- The HUD is still code-drawn and uses the fallback font; accepted pixel font,
  bubbles, cooldown cues and settings UI remain later visual slices.
- Cone view still masks by angle/range only. The next slice adds deterministic
  `los_cutaway` building occlusion without granting presentation authority.

Commit: pending. Push: pending.

## 2026-08-01 — Godot deterministic movement foundation

Branch: `agent/aider-godot-foundation`

What changed and why:

- Pinned official Godot 4.7.1 with a SHA-256-verified, user-local, rerunnable
  installer and retained offline archive cache.
- Added a compatibility-renderer project, bootstrap scene, explicit input
  router, bounded catch-up loop, and 60/120 Hz pre-match configuration.
- Added renderer-independent scale-1000 commands/state, ordered integer
  collision, FLUX-derived universal deep movement, state hashing, replay
  recording, and per-checkpoint verification.
- Excluded protected concept boards from Godot runtime import without changing
  any original PNG/WebP asset.
- Added Linux/Windows export presets, pinned CI, development instructions, and
  a preserve/reinterpret/replace/archive migration record.
- Established an original expanded Sanctum visual target and encoded its warm
  stone, garden, brass, cyan/violet magic, and dark instrument-panel language
  into the runnable training-court presentation.
- Added a validated nine-district, three-layer Sanctum content definition with
  reciprocal routes, combined functions, multiple entrances, deep-movement
  paths, nine attunement nodes, and fail-closed fast-travel eligibility.
- Rewrote the README as the FLUX2 product brief and added visual/hub contracts
  covering the core loop, combat/chemistry goals, vastness, menus, offline use,
  accessibility, asset provenance, and implementation sequence.
- Added a chapter/subchapter status index and gate-ordered overhaul plan derived
  from the supplied FLUX product brief, with truthful completion checkboxes and
  explicit working-slice boundaries.

Files changed:

- `.github/workflows/ci.yml`, `.gitignore`, `.godot-version`, `project.godot`,
  `export_presets.cfg`, `toolchains/godot.env`;
- `src/app/`, `src/sim/`, `scenes/bootstrap/`, `tests/`;
- `scripts/install-godot.sh`, `scripts/doctor.sh`, `scripts/test.sh`,
  `scripts/run.sh`;
- `README.md`, `SPECIFICATION.md`, `docs/DEVELOPMENT.md`,
  `docs/MIGRATION-FLUX-MOVEMENT.md`, `docs/SANCTUM-HUB.md`,
  `docs/VISUAL-DIRECTION.md`, `docs/OVERHAUL-PLAN.md`, `reference/.gdignore`;
- `assets/concept/`, `content/maps/sanctum_hub_v1.json`,
  `src/content/hub_definition.gd`, `tests/unit/test_hub_definition.gd`.

Validation:

- `scripts/test.sh` outside the restricted socket sandbox: clean Godot import,
  10 core + 340 movement + 10 replay assertions, and 60/120 Hz bootstrap
  launches; all passed.
- `scripts/install-godot.sh` twice from cached archive: both passed; archive
  SHA-256 `c7ff14fd28472c8d4f193043de30278dcf7e5241a1dcf7566b02e27addaa33ba`.
- `bash -n scripts/*.sh` and `git diff --check`: passed.
- GUI launch: Godot 4.7.1 compatibility renderer on AMD Radeon 610M; room,
  player, obstacles, rail, and debug HUD rendered; process closed cleanly.
- Sanctum content validation: 46 assertions covering schema, district scale,
  combined functions, entrances, traversal routes, attunement unlocks, blocked
  states, endpoint identity, and destination clearance; passed.

Known limitations and risks:

- This milestone is the deterministic movement/replay foundation, not the full
  shooter, networking, chemistry, content, animation, or release-export slice.
- The generated Sanctum image is visual direction only and excluded from Godot
  import. It does not replace an original modular runtime art kit or authored
  topology/material layers.
- Foundation collision uses ordered integer boxes; authored elevation columns,
  moving platforms, and material-derived collision are subsequent systems.
- Matching 4.7.1 export templates are not cached yet; editor/headless offline
  development is ready, but offline release export preparation remains.
- CI is configured but its first remote run is pending the branch push.

Commit: `8e6bce6`. Push: `origin/agent/aider-godot-foundation`.

## 2026-08-01 — Resource and independent-input truth

Branch: `agent/aider-godot-foundation`

What changed and why:

- Corrected the FLUX contract by separating universal movement Stamina from
  spell/champion Flux and Health; each has independent integer bounds, recovery
  rates, remainders, and delays at both supported match rates.
- Versioned canonical commands/state to protocol 2 with deterministic
  independent aim and held-primary input. Moving and aiming in different
  directions is now an explicit replayable state.
- Aligned player-one defaults with the source brief: WASD/mouse, Alt sprint, C
  movement chain, V technique, left click/Space primary, plus action-based
  left/right-stick, trigger, shoulder, and east-button controller defaults.
- Hardened `scripts/test.sh` so Godot parse, compile, load, and invalid-call
  diagnostics fail the gate even when the engine process exits zero.
- Added resource and input-map suites and updated the public implementation
  status/overhaul plan without claiming that primary input fires yet.

Files changed:

- `src/sim/entities/player_state.gd`, `player_tuning.gd`,
  `player_resources_system.gd`;
- `src/sim/core/sim_command.gd`, `sim_config.gd`, `sim_world.gd`;
- `src/sim/movement/`, `src/app/`, `tests/unit/`, `tests/run_all.gd`;
- `scripts/test.sh`, `README.md`, `docs/DEVELOPMENT.md`,
  `docs/OVERHAUL-PLAN.md`.

Validation:

- Full headless gate: 478 assertions, zero failures.
- Godot import and bootstrap at 60 and 120 Hz: passed with protocol 2 and no
  script/runtime diagnostics (restricted-sandbox editor socket warnings only).
- `git diff --check` and `bash -n scripts/*.sh`: passed after whitespace cleanup.

Known limitations and risks:

- Primary input is canonical protocol/state only; it intentionally creates no
  projectile until the focused combat slice.
- Controller defaults are registered and tested structurally; interactive
  device acceptance and saved remapping remain open.
- Edgeweave, authored elevation, and the remaining launched/grappled/status
  movement contracts remain the next Movement Conservatory slice.

Commit: `7ffd6e6`. Push: `origin/agent/aider-godot-foundation`.

## 2026-08-01 — Movement constraints and Conservatory route

Branch: `agent/aider-godot-foundation`

What changed and why:

- Added deterministic wall identities and the FLUX-derived 220 ms per-wall
  lockout so repeated contact cannot refresh infinite wall kicks.
- Added bounded launched, grappled, charging, stunned, rooted, and slowed
  control-state contracts. External speeds clamp to the authored movement
  ceiling and all resulting movement still resolves through ordered collision.
- Added a 60/120 Hz Movement Conservatory integration fixture that completes
  sprint-to-slide, late slide jump, air redirect, marked vault, and crest
  superglide in the same semantic order.
- Explicitly deferred Edgeweave until the projectile slice can distinguish a
  swept hostile miss band from the inner hit volume and prevent repeat farming.

Files changed:

- `src/sim/world/collision_world.gd`, `src/sim/entities/player_state.gd`,
  `src/sim/movement/movement_system.gd`, `movement_tuning.gd`;
- `tests/unit/test_movement.gd`,
  `tests/integration/test_conservatory_route.gd`, `tests/run_all.gd`;
- `README.md`, `docs/OVERHAUL-PLAN.md`,
  `docs/MIGRATION-FLUX-MOVEMENT.md`.

Validation:

- Full headless gate: 526 assertions, zero failures.
- Godot import and 60/120 Hz protocol-2 bootstrap: passed with no script/runtime
  diagnostics (restricted-sandbox editor socket warnings only).

Known limitations and risks:

- The control states expose safe simulation contracts for later abilities and
  statuses; no current input or content grants them.
- Authored elevation bands, hop/fall presentation, buffered inputs, Edgeweave,
  saved remapping, and interactive controller acceptance remain open.

Commit: `8805be0`. Push: `origin/agent/aider-godot-foundation`.

## 2026-08-01 — Canonical ability and loadout configuration

Branch: `agent/aider-godot-foundation`

What changed and why:

- Added a versioned ability catalog with stable string/wire IDs, roles,
  counterplay, simulation authority, integer timing/resource fields, and
  recursively canonical SHA-256 hashing.
- Declared all twelve intended element families while failing closed on ability
  use of Spirit, Chaos, Gravity, or Time until their later acceptance gates.
- Added a legal foundation loadout with one passive, resource-free primary,
  three unique positive-cost actives, champion mobility, and ultimate.
  Charge/Light affinity discounts fill exactly 13 points and do not modify raw
  damage or other power values.
- Integrated catalog/loadout validation into bootstrap and documented the
  promotion order before implementing casts.

Files changed:

- `content/abilities/foundation_abilities_v1.json`,
  `content/loadouts/foundation_practitioner_v1.json`;
- `src/content/canonical_content.gd`, `ability_catalog.gd`,
  `loadout_definition.gd`, `src/app/bootstrap.gd`;
- `tests/unit/test_ability_content.gd`, `tests/run_all.gd`;
- `README.md`, `docs/ABILITY-CONFIGURATION.md`,
  `docs/OVERHAUL-PLAN.md`.

Validation:

- Ability/loadout suite: 33 assertions covering stable hashes, twelve declared
  families, eight enabled families, positive active contracts, reliable
  zero-Flux primary, exact 13-point loadout, duplicate rejection, budget
  rejection, and invalid active rejection; passed.
- Final integrated headless gate: 559 assertions, zero failures; bootstrap
  validated the catalog/hash and exact 13/13 build at both 60 and 120 Hz.
- `git diff --check` and `bash -n scripts/*.sh`: passed.

Known limitations and risks:

- Authoring JSON is validated and hashed but not yet compiled to a locked
  historical wire manifest or included in session/replay compatibility metadata.
- The catalog is configuration only; input cannot cast, damage, or place
  terrain until the focused combat slices.

Commit: `e7e8ded`. Push: `origin/agent/aider-godot-foundation`.

## 2026-08-01 — Deterministic projectile combat and Edgeweave

Branch: `agent/aider-godot-foundation`

What changed and why:

- Versioned protocol 3 with pressed active-one input and aligned keyboard,
  mouse, and controller defaults.
- Implemented resource-free Arc Primary and 24-Flux Vector Lance through
  startup, aim snapshot, recovery, cooldown, stable projectile IDs, integer
  movement/remainders, ordered collision, swept hostile hits, authoritative
  Health damage, lifetime/impact events, presentation, state hashing, and replay.
- Implemented FLUX-derived Edgeweave: a 16-unit hostile outer miss band at
  260+ speed rewards at most 9 Stamina with a 220 ms fighter lockout; hits,
  full Stamina, training sources, and repeated projectile/fighter pairs do not
  reward.
- Documented tick order and deliberate combat limitations rather than implying
  projectile clash, defenses, statuses, or chemistry already exist.

Files changed:

- `src/sim/combat/`, `src/sim/core/sim_command.gd`, `sim_config.gd`,
  `sim_world.gd`, `src/sim/entities/player_state.gd`;
- `src/app/input_router.gd`, `bootstrap.gd`;
- `tests/unit/test_combat.gd`, `test_ability_content.gd`,
  `test_input_router.gd`, `tests/replay/test_replay.gd`, `tests/run_all.gd`;
- `README.md`, `docs/COMBAT-FOUNDATION.md`,
  `docs/ABILITY-CONFIGURATION.md`, `docs/DEVELOPMENT.md`,
  `docs/OVERHAUL-PLAN.md`.

Validation:

- Full headless gate before final documentation: 727 assertions, zero failures.
- Both 60 and 120 Hz pass primary/active startup and hit tests, exact Flux and
  damage checks, refusal diagnostics, Edgeweave reward/hit/training/repeat
  guards, command-stream replay, import, and protocol-3 bootstrap.

Known limitations and risks:

- Defeat/respawn, clash, defense, statuses, knockback, pierce, fields, bots,
  network packets, chemistry, and production telegraphs are still explicit
  later slices.
- Runtime tuning is guarded against catalog drift by tests; a generated locked
  wire/runtime table remains preferable before wider catalog growth.

Commit: `2896ce6`. Push: `origin/agent/aider-godot-foundation`.

## 2026-08-01 — Published foundation checkpoint

Branch: `agent/aider-godot-foundation`

What changed and why:

- Reconciled the pre-commit worklog records with the five focused commits that
  now exist on the remote branch.
- Updated the implementation plan to identify protocol 3 as the current
  command contract after active-one casting extended the protocol-2 aim work.
- Published the branch as draft PR #5 against the reviewed Godot architecture
  branch so the stacked foundation remains reviewable without targeting main.

Validation:

- Full local headless gate: 727 assertions, zero failures.
- Clean Godot import/bootstrap at both 60 and 120 Hz with protocol 3: passed.
- GitHub draft PR #5: both `headless` checks passed for the current remote
  foundation commits.

Known limitations and risks:

- This checkpoint is a playable engineering skeleton, not a content-complete
  overhaul. The unchecked README/plan items remain deliberately open.
- Export templates, Windows acceptance, networking, authored hub tiles,
  chemistry runtime, and the first complete champion are later gated slices.

Implementation commits: `8e6bce6`, `7ffd6e6`, `8805be0`, `e7e8ded`, and
`2896ce6`. Draft PR: `https://github.com/generalgroovy/flux2/pull/5`.
Documentation commit: pending at pre-commit record time.

## 2026-08-01 — Game breadth and gate-ordered production roadmap

Branch: `agent/aider-godot-foundation`

What changed and why:

- Expanded the README opening status/index from a terse system list into nine
  linked chapters with honest implemented/planned subchapter checkboxes.
- Defined the original movement/traversal grammar, map interactions, targeting
  families, fighter commitments, resources/loadout, validated Flux Formula
  composition, element gates, destruction layers, reusable map packages/devices,
  progression boundaries, and shared-system mode families.
- Carried all 23 named FLUX champion designs plus the unapproved Angel slot as
  migration inputs, separated ancestry/champion/loadout responsibilities, and
  added three provisional original arachnoid body plans without making them
  selectable or inventing permanent champion identities.
- Recorded inspiration only as broad design principles and explicitly barred
  copied characters, assets, abilities, maps, layouts, terminology, code, and
  trade dress.
- Reconciled normative specification and overhaul ordering through checkpoints
  F–O; corrected stale migration/configuration prose now that protocol 3,
  projectile casting, and Edgeweave are implemented.

Files changed:

- `README.md`;
- `SPECIFICATION.md`;
- `docs/OVERHAUL-PLAN.md`;
- `docs/MIGRATION-FLUX-MOVEMENT.md`;
- `docs/ABILITY-CONFIGURATION.md`;
- `.agent/WORKLOG.md`.

Validation:

- Full headless gate: 727 assertions, zero failures.
- Godot import and protocol-3 bootstrap at 60 and 120 Hz: passed.
- `bash -n scripts/*.sh` and `git diff --check`: passed.
- Reviewed all changed Markdown links and confirmed no protected image, audio,
  archive, or other binary asset changed.

Known limitations and risks:

- This is a design/production-management checkpoint; runtime behavior remains
  the previously green checkpoint E combat foundation.
- Weaverkin, Scorpionkin, and Harvestkin are provisional body-plan labels. Names,
  lore, visual designs, traits, and champions require explicit approval before
  data/runtime promotion.
- Formula composition, advanced traversal, ancestry registries, map devices,
  chemistry, networks, modes, and checkpoints F–O remain unchecked until their
  own implementation and acceptance slices pass.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-08 — G2 authored campus topology verification (in progress)

Branch: `agent/aider-godot-foundation`

What changed and why:

- Replaced edge-count topology acceptance with an actual connected-district
  traversal; self-links, unknown districts and bridge endpoints outside their
  declared districts fail closed.
- Declared the current campus buildings as immutable worldbone and made
  district elevation queryable without consulting rendering or scene nodes.
- Required ordinary and advanced routes in every visible district, one
  accessible ordinary route per district, and route points owned by their
  declared district.
- Added bounded Conservatory movement and Proving practice reset-zone metadata.
- Preserved the existing G2 camera, procedural presentation, canonical map
  identity and all unrelated dirty work.

Validation:

- AUTOCODE offline executor: complete `bash scripts/test.sh` gate passed with
  external networking isolated and a private safe `/dev`.
- Sanctum campus suite: 86 assertions, zero failures; complete repository gate:
  960 assertions, zero failures.
- Godot import and bootstrap at 60 and 120 Hz passed.
- A deterministic 1280 x 720 three-frame runtime capture completed through the
  offline executor; the capture confirms the scrolling campus is functional but
  remains visibly sparse and procedural.
- `bash -n scripts/*.sh` and `git diff --check` passed.

Known limitations and risks:

- G2 is not complete. The older untracked `v1` environment sheet remains an
  unreviewed candidate and is untouched. The new generated `v2` source/alpha
  candidate has immutable hashes, generator/prompt provenance, a fail-closed
  twelve-slot manifest and alpha/chroma validation, but license review remains
  pending and it is intentionally excluded from runtime import.
- The runtime presentation is code-drawn and does not yet pass modular pixel-kit,
  gameplay-zoom silhouette, grayscale/color-vision, collision/art alignment,
  import/memory/performance, or Garuda/Sway visual acceptance.
- Reset zones are validated map metadata only; typed reset execution remains a
  later systemic Sanctum slice.

Asset-pipeline evidence added after the topology gate:

- `assets/concept/sanctum-modular-kit-generated-source-v2.png` and
  `sanctum-modular-kit-alpha-candidate-v2.png`;
- `content/assets/sanctum_modular_kit_candidate_v2.json`;
- `src/content/environment_kit_manifest.gd` and
  `tests/unit/test_environment_kit_manifest.gd`;
- environment manifest: 36 assertions, zero failures; complete offline gate:
  996 assertions, zero failures.
- deterministic Godot-only preparation now emits twelve alpha-trimmed candidate
  crops with manifest-bound paths, hashes, dimensions and bottom-center
  presentation pivots. Hash replay was byte-identical; the expanded asset suite
  passes 64 assertions and the complete offline gate passes 1,024.
- Added bounded `--capture-pointer=X,Y` visual-test input so movie capture does
  not inherit nondeterministic host cursor state. Two independent 60 Hz captures
  were byte-identical; the world region below the HUD was pixel-identical at 60
  and 120 Hz for the same capture frame. A 1280 x 720 grayscale inspection kept
  player, path, vault, building-edge and shrine silhouettes legible.
- These checks prove repeatable presentation output, not artistic acceptance:
  the procedural campus remains sparse and the candidate crops are still
  excluded from runtime pending approval and alignment gates.

Commit: deferred until the complete G2 promotion gate passes. Push: deferred.

## 2026-08-01 — G1 offline controls and configurable POV

Branch: `agent/aider-godot-foundation`

What changed and why:

- Added a versioned local-only player-preferences profile with safe defaults,
  exact JSON persistence, schema/bounds validation, conflict rejection, and
  explicit per-action physical-key unbinding while retaining mouse/controller
  events.
- Added independent `world_relative` and `aim_relative` movement presets. The
  latter treats independent aim as forward and converts forward/strafe intent
  into the same bounded world command with integer math.
- Added independent `full` and `cone` POV presentation. Cone mode accepts
  15–360 degrees and a 160–4096 unit range, including a finite circular
  360-degree view; the mask renders after actors and before HUD/debug panels.
- Added F7–F10 saved runtime controls and exact launcher overrides for movement
  reference, POV mode, angle, and range. The launch script now forwards user
  arguments to Godot.
- Defined the multiplayer trust boundary: local POV can restrict presentation,
  while any mode-owned hidden information must be host-enforced and omitted
  from replication.
- Promoted G2—the first authored Nexus-to-Conservatory topology/visual slice—
  ahead of F2 reaction work, and explicitly documented that the current
  concentric court is only a mechanics fixture, not accepted Sanctum art.
- Began bounded G2/Sanctum-V1 preproduction during G1 final verification: the
  first product acceptance matrix now requires spacious authored areas,
  environment charm/readability, base body/jump/interaction/taunt, chemistry,
  friends/presence/join, host teams/friendly-fire/practice/travel controls,
  authoritative LOS with foreground cutaways, and co-equal Garuda Linux/Sway
  plus Windows source/package evidence before later gameplay modes.

Files changed:

- `src/app/player_preferences.gd`;
- `src/app/input_router.gd` and `src/app/bootstrap.gd`;
- `scripts/run.sh`;
- `tests/unit/test_player_preferences.gd`, input-router coverage, and the suite
  runner;
- `docs/PLAYER-CONTROLS-AND-POV.md`, README, specification, Sanctum contract,
  Living Sanctum V1 acceptance contract, visual direction, development
  instructions, and overhaul plan.

Validation:

- Full headless gate: 872 assertions, zero failures.
- Clean bootstrap at 60 and 120 Hz: passed with protocol 3 and safe default
  `world_relative`/`full` settings.
- Offline save/load round trip, unknown/conflicting actions, explicit unbind,
  numeric bounds, exact 360-degree view, both movement transforms, and retained
  controller/mouse events: passed.
- Interactive AMD Radeon 610M compatibility-renderer smoke using
  `aim_relative`, `cone`, 135 degrees, and 520 units: passed. Cone direction and
  finite range were visible; HUD and Material Yard diagnostics remained
  unobscured.
- `bash -n scripts/*.sh` and `git diff --check`: passed.

Known limitations and risks:

- The current cone is a local presentation option, not authoritative wall
  occlusion. Competitive limited-information modes must add host visibility
  queries and information-leak tests before use.
- Physical keyboard bindings are editable in the generated offline JSON. The
  Settings station, interactive input capture, per-device sensitivity/dead-zone
  curves, controller profile persistence, and import/export remain G3 work.
- The current Sanctum renderer remains the visibly inadequate schematic that
  G2 now replaces next; this checkpoint does not claim visual acceptance.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-01 — F1 deterministic Material Yard storage foundation

Branch: `agent/aider-godot-foundation`

What changed and why:

- Added a fail-closed, stable-wire material catalog for the first eleven
  occupancy materials while keeping charge as an independent field so water
  and other matter can carry stored force without changing identity.
- Added an exact 128-by-128 authored Material Yard seed definition with
  immutable Worldbone, a complete perimeter, deterministic reset ownership,
  elevation samples, and a rate-independent work budget.
- Implemented packed parallel material fields, guarded writes, deterministic
  sorted/deduplicated awake work, reset, and stable state/Worldbone hashes.
- Integrated catalog and yard validation into startup and exposed a read-only
  in-world development preview; rendering cannot mutate simulation state.
- Reordered the production plan around the new F1 checkpoint. Reaction
  scheduling remains F2 and is intentionally absent from this storage slice.

Files changed:

- `content/materials/foundation_materials_v1.json`;
- `content/maps/sanctum_material_yard_v1.json`;
- `src/content/material_registry.gd`;
- `src/content/material_yard_definition.gd`;
- `src/sim/materials/material_grid.gd`;
- `src/app/bootstrap.gd`;
- `tests/unit/test_material_content.gd`;
- `tests/unit/test_material_grid.gd`;
- `tests/run_all.gd`;
- `README.md`, `SPECIFICATION.md`, and the related development/overhaul/material
  documentation.

Validation:

- Full headless gate at the final source state: 818 assertions, zero failures.
- Clean bootstrap at both 60 and 120 Hz: passed; material catalog hash
  `1c9b15a12d94`, yard hash `3b466b916d6e`.
- Interactive AMD Radeon 610M compatibility-renderer smoke: passed. The preview
  frame, plinth, material bands, charged-water cue, and hashes were visible and
  left the training lanes unobstructed.
- `bash -n scripts/*.sh` and `git diff --check`: passed.

Known limitations and risks:

- This slice establishes storage, validation, work ordering, reset, and a
  diagnostic preview only. It does not yet execute reactions, destruction,
  propagation, or network deltas.
- The current training court is still a schematic mechanics harness, not the
  approved vast Living Sanctum presentation. Authored Sanctum topology and
  visual replacement have been promoted immediately after the requested
  control/POV checkpoint.
- Material Yard colors are diagnostic and are not shipping art direction.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-09 — unified G2 topology/runtime-kit and champion visual contract

Branch: `integration/all-branches-20260809`

What changed and why:

- Integrated the preserved dirty G2 work over the consolidated FLUX2 branch
  lineage: canonical Sanctum campus topology, immutable worldbone, elevation,
  ordinary/advanced/accessibility routes, reset metadata, renderer, content
  validators, deterministic local runtime-kit generator, and tests.
- Preserved the user-passed eighteen-champion board at
  `assets/concept/flux-champions-visual-style-v1.png`; recorded its dimensions,
  SHA-256, visual-reference authority, and non-authoritative label boundary.
- Repaired visual-production manifests that referenced missing local images.
  All champion style references now resolve to the preserved board.
- Updated README, normative specification, visual direction, and overhaul plan
  with the mandatory compact expressive pixel-art bar, the original-art and
  asset-promotion gates, complete per-champion animation requirement, and the
  production Space-to-jump migration.
- Defined jump presentation precisely: stable authoritative ground anchor,
  independently lifted body, separate receiving-surface shadow that broadens
  and darkens through ascent, peaks at apex, contracts on descent, and is driven
  from equivalent normalized authoritative phase at 60 and 120 Hz.

Validation:

- Full Godot headless gate: 12,250 assertions, zero failures.
- Clean bootstrap at 60 and 120 Hz: passed with campus hash `13bd675242c8`.
- Both visual JSON manifests parse and all 26 collected reference paths exist.
- Supplied board: 1536 x 1024 RGBA PNG, SHA-256
  `cb8aa1b3f4e1c41498a35dd37303a3783b0f8fa2c0bbb0b75a89cbd02934732f`.
- `git diff --check`: passed.

Known limitations and risks:

- Runtime-addressable eight-direction champion candidates and a 25-action
  skeleton contract exist, but the production animations remain planned; no
  portrait, direction preview, skeleton atlas, or generated keyframe board is
  claimed as final in-game animation acceptance.
- Visual validators currently emit Godot export warnings because they load PNG
  files through `Image.load_from_file`; assertions and boots pass, but an
  export-safe validator-loading cleanup remains required.
- The legacy browser FLUX test gate is 145/146 locally because `linkedom` is not
  installed and no package manager is available. No dependency was fetched or
  installed without approval.

Commit: pending at pre-commit record time. Push: pending.

## 2026-08-09 — canonical FLUX repository unification

Branch: `integration/all-branches-20260809`

What changed and why:

- Consolidated every fetched legacy browser FLUX branch into tip `1d0c807`.
  Later pixel work was merged normally; superseded archival tips were retained
  as tree-preserving merge parents with an explicit audit record.
- Imported that complete legacy ancestry under `legacy/web-prototype/` while
  keeping the Godot project at repository root authoritative.
- Updated the root README and branch-consolidation record with the canonical
  layout and the legacy dependency limitation.

Validation:

- Imported subtree tree object exactly matches legacy tip `1d0c807`:
  `3675a862d23de980e5b7700fe02fa0162fb50ff9`.
- Godot full gate: 12,250 assertions, zero failures; clean 60 and 120 Hz boots.
- Legacy dependency-independent gate: 149 tests, 149 pass, zero failures.
- The three excluded legacy test files remain explicitly dependency-blocked by
  absent locked `linkedom`/`ws`; they are not represented as passing.
- Every fetched branch tip in both source repositories is retained as an
  ancestor of its consolidated lineage.

Known limitations and risks:

- Exact legacy `npm test` still requires preparing the locked dependencies.
- Repository cutover and remote push remain separate reversible operations.

Commit: pending at pre-commit record time. Push: pending.
