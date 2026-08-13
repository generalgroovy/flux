# FLUX2 development

## One-time preparation

The repository pins Godot 4.7.1 and its official Linux archive digest. Install
it without root access while connected, then retain the verified cache for
offline use:

```bash
scripts/install-godot.sh
scripts/doctor.sh
```

On Windows, use the checked-in `.cmd` wrappers. They apply an execution-policy
bypass only to their child PowerShell process and do not change machine policy:

```bat
scripts\doctor.cmd
scripts\test.cmd
scripts\run.cmd
```

## Daily commands

```bash
scripts/test.sh
scripts/run.sh
FLUX2_TICK_RATE=60 scripts/run.sh
scripts/run.sh --movement-reference=aim_relative --pov-mode=cone --pov-angle=120 --pov-range=800
```

Run the complete local friend-session journey with one command. It starts two
hidden game processes, proves host/join, shared HELLO, authoritative movement,
prediction/reconciliation, Hearth readiness, synchronized Proving Court entry
and exact-actor leave/return,
then cleans both up:

```bash
scripts/smoke-farflow.sh
```

```bat
scripts\smoke-farflow.cmd
```

The source harness is the default. After packaging, pass
`-Executable exports\windows\flux2.exe` on Windows or set
`FLUX2_EXECUTABLE=exports/linux/flux2.x86_64` on Linux. Logs remain under
`.godot/farflow-smoke/`; defaults use UDP 24892 and can be overridden without
changing player defaults.

The match tick rate is exactly 60 or 120 Hz. It is chosen before constructing
the simulation, becomes replay compatibility metadata, and cannot change
inside a running match. F6 restarts the local debug match at the other rate; it
does not mutate a live simulation.

Controls: WASD movement, mouse aim, left click Arc Primary, right click or E
Vector Lance, Shift sprint, C or wheel-down direct slide/fast-fall, Space or
wheel-up jump/movement-chain input, V technique, R reset,
and F6 restart at 60/120 Hz. Controller defaults use left/right sticks, right
trigger, shoulders, and west/east face buttons. Schema-v1 saved C-jump and
Space-primary defaults migrate automatically; explicit saved alternatives remain.

`src/presentation/jump_presentation.gd` derives a draw-only body lift and
receiving-surface shadow from the existing movement timers. The bootstrap keeps
the canonical position as the collision, camera, and POV anchor and offsets only
the drawn body. The normal apex lift is 28 whole pixels; reduced motion caps it
at seven while retaining a broader/darker shadow cue. Unit coverage compares
normalized phases at 60/120 Hz for hop, wall kick, double jump, slide jump, air
dodge, vault, and superglide. This shared sampler is not evidence that any
champion's frame-complete sprite manifest is finished.

`src/presentation/wellspring_character_sprite.gd` loads the selected Oh Tipi or
S. Wayne v2 integrated-candidate atlas and selects its semantic action,
eight-direction region, and clock-derived frame. The Champion Loom switches the
canonical champion profile and presentation together. The bootstrap draws that
region with nearest filtering, lifts only the body over the receiving-surface
shadow, and draws it before the POV mask. Invalid loading or synchronization
releases the candidate and retains the procedural fallback. This runtime
exercise does not promote either candidate to final art.

`content/champions/foundation_champions_v1.json` is the canonical first-roster
source for stable champion wire IDs, affinities, ancestry, size, bounded stats,
and foundation kit references. Oh Tipi currently binds Rillshot/Tideline while
S. Wayne binds Eclipse Disc/Pocket Eclipse; the simulation owns their costs,
timing, hit results, ricochet/slow state, applied maxima, recovery rates, and
ground-speed ratios. Use `--champion=oh_tipi` or
`--champion=s_wayne` only for deterministic launch/capture diagnostics; normal
players switch at the in-world Champion Loom.

`src/net/session_transport.gd` is the raw ENet/UDP friend-session boundary.
The eastern Host/Join Farflow stations operate it without a detached menu; use
`--join-address=IP`, `--session-port=24872` and `--player-name=Name` for direct-IP
diagnostics. Its real loopback suite covers compatibility, bounded validated
input, mismatch refusal and disconnect cleanup. Stable peer actors, host-side
movement simulation and compact 60 Hz guest snapshots are live. Protocol 21 /
snapshot schema 6 carries bounded projectile lanes, target state, compact
Hearth presence/readiness, packed Proving Court state and semantic
feedback without moving any outcome authority to clients. Reliable
social/Bell/Loom requests are validated
against host-owned station proximity and return shared confirmations; training
target health also replicates. A separate peer-scoped channel acknowledges the
last processed input and reconciles bounded movement-only guest prediction;
combat, resources and world outcomes remain snapshot-owned. See
[friend-session networking](NETWORKING.md).

The adjacent Farflow Charter cycles Open Commons (8/social), Sparring Circle
(4/player damage) and Duel Knot (2/host reset). The host seals one before
opening Farflow; its profile hash/capacity are validated during acceptance and
its team/reset rules are enforced by host simulation. Use
`--session-charter=sparring_circle` only for repeatable diagnostics. Capture-only
`--capture-spawn=X,Y` and `--capture-expanded-station=ID` support deterministic
visual inspection without changing normal spawn or interaction behavior.

The Session Hearth beside the Farflow gates is the diegetic lobby boundary. Its
bubble lists connected/returning names and readiness; each connected traveller
presses F there, then the host presses F to begin the sealed three-second start.
The company enters the authored Proving Court after that countdown. Host-owned
rules assign safe spawns and individual combat teams, ward each spawn, seal the
court, score knockouts to three or 90 seconds, respawn after 1.8 seconds, show a
six-second result and return everyone to the Hearth. The maintained process
journey includes `--farflow-smoke-hearth` and `--farflow-smoke-round`; both are
strictly diagnostic and use the same proximity/request/authority path as player
input. `--farflow-smoke-rematch` is combined by the maintained wrapper to prove
the returned roster occupies the real Hearth, readies again and receives active
Round 2; it is not a player-facing shortcut.

The host reviews connected guests at the Company Ledger, which only changes a
selection. Releasing that guest requires two Parting Bell presses within three
seconds. Closing the entire company likewise requires two Host Farflow presses;
both actions deliver a bounded reason, revoke the affected return path and
create no 15-second reservation. The maintained journey finishes with
`--farflow-smoke-steward`, proving that behavior after Round 2.

A third process joining an active Open Commons or Sparring Circle court becomes
an input-locked next-gathering observer. Tab or controller D-pad right cycles
the stable replicated participant focus, the HUD names the watched champion,
and the client sends neither commands nor movement prediction while observing.
The synchronized return restores the observer's own Hearth actor; the maintained
`--farflow-smoke-spectator` path then readies normally and proves participation
in Round 2. The observer uses the existing public state only; per-peer host LOS
filtering remains required before limited-information network modes.

Both 60 and 120 Hz simulations publish shared state at 60 snapshots per second.
Semantic events are retained for four snapshots and deduplicated by stable ID;
do not clear an event after only one unreliable send. Protocol 21 validates and
FastLZ-packs snapshot schema 6 into a bounded wire envelope; both the maximum
eight-player fixture and live three-player journeys must remain within the
1,392-byte ENet MTU before the unreliable-ordered send.

Protocol 21 reserves a normally disconnected guest's exact actor for 15 seconds and
binds return to a random in-memory capability plus the original name. A normal
player uses Join Farflow again; `--farflow-smoke-reconnect` is test-only. Do not
print, persist or add that capability to snapshots/diagnostics.

F7 switches world-relative/aim-relative movement, F8 switches full/cone view,
and F9/F10 increase angle/range; hold Shift with F9/F10 to reduce them. Changes
persist offline in `user://player_preferences_v1.json`. Physical keyboard
keycodes can be remapped in that validated file without removing mouse or
controller defaults. See [player controls and POV](PLAYER-CONTROLS-AND-POV.md).

The lower-right `MATERIAL YARD F1` panel is a read-only texture generated from
the canonical 128 x 128 seed. Its labels identify the static seed/worldbone
hashes that booted; it is not yet an interactive reaction simulation.

## Deterministic presentation capture

Visual regression capture must not inherit the host cursor position. Use an
explicit bounded world pointer together with Godot's fixed-rate movie writer:

```bash
mkdir -p /tmp/flux2-g2-capture
godot --path "$PWD" \
  --write-movie /tmp/flux2-g2-capture/frame.png \
  --quit-after 3 --fixed-fps 60 --resolution 1280x720 \
  -- --tick-rate=60 --capture-pointer=1600,720
```

`--capture-pointer=X,Y` is a testing-only user argument. It accepts an integer
point inside the authored campus and replaces mouse sampling only when present;
normal input remains unchanged. Independent fixed-pointer 60 Hz captures must
be byte-identical. At equal frame count, the world region below the HUD must
also match between 60 and 120 Hz; only intentional rate text may differ.

## Architecture boundary

`src/sim/` owns canonical integer state. It has no Node, renderer, input,
audio, transport, or `CharacterBody2D` dependency. `src/app/bootstrap.gd`
samples semantic commands and interpolates confirmed positions for drawing.
Never move authoritative outcomes into the bootstrap scene.

## AUTOCODE specialist contracts

Project-local specialist roles are declared in `.autocode/roles.toml` for the
FLUX director, simulation, movement, combat, chemistry, networking, map,
champion, asset-pipeline, performance, and adversarial-QA boundaries. The file
is tracked; all other `.autocode` run state, logs, caches, task graphs, and
checkpoint archives remain ignored. Roles propose bounded work, while the
repository's deterministic tests, manifests, replay hashes, runtime checks, and
acceptance contracts decide whether a slice advances.

Godot export presets and release commands are present for Linux and Windows.
Export templates are a large optional preparation artifact and are never
silently downloaded by test, run or package scripts. Install/cache the matching
official 4.7.1 templates once, then build both platforms and their SHA-256
manifest with:

```bash
scripts/package.sh all
```

```bat
scripts\package.cmd -Target All
```

`GODOT_EXPORT_TEMPLATE_ROOT` may point at an offline template cache. Packaging
fails before export with the exact missing platform template; source run/test
and Farflow acceptance remain available.
