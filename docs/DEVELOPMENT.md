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
Vector Lance, Alt sprint, Space jump/movement-chain input, V technique, R reset,
and F6 restart at 60/120 Hz. Controller defaults use left/right sticks, right
trigger, shoulders, and west/east face buttons. Schema-v1 saved C-jump and
Space-primary defaults migrate automatically; explicit saved alternatives remain.

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

Godot export presets are present for Linux and Windows. Export templates are a
large optional preparation artifact and are not silently downloaded by test or
run scripts. Cache the matching 4.7.1 templates before an offline release
build.
