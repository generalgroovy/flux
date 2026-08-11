# FLUX2 development

## One-time preparation

The repository pins Godot 4.7.1 and its official Linux archive digest. Install
it without root access while connected, then retain the verified cache for
offline use:

```bash
scripts/install-godot.sh
scripts/doctor.sh
```

## Daily commands

```bash
scripts/test.sh
scripts/run.sh
FLUX2_TICK_RATE=60 scripts/run.sh
scripts/run.sh --movement-reference=aim_relative --pov-mode=cone --pov-angle=120 --pov-range=800
```

The match tick rate is exactly 60 or 120 Hz. It is chosen before constructing
the simulation, becomes replay compatibility metadata, and cannot change
inside a running match. F6 restarts the local debug match at the other rate; it
does not mutate a live simulation.

Controls: WASD movement, mouse aim, left click Arc Primary, right click or E
Vector Lance, Shift sprint, Ctrl/C direct slide, Space jump/movement-chain input, V technique, R reset,
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
movement simulation and compact 60 Hz guest snapshots are live. Protocol 13
adds bounded projectile lanes and semantic combat feedback without moving any
outcome authority to clients; shared station requests remain gated. See
[friend-session networking](NETWORKING.md).

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

Godot export presets are present for Linux and Windows. Export templates are a
large optional preparation artifact and are not silently downloaded by test or
run scripts. Cache the matching 4.7.1 templates before an offline release
build.
