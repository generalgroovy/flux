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
```

The match tick rate is exactly 60 or 120 Hz. It is chosen before constructing
the simulation, becomes replay compatibility metadata, and cannot change
inside a running match. F6 restarts the local debug match at the other rate; it
does not mutate a live simulation.

Controls: WASD movement, mouse aim, left click or Space Arc Primary, right click
or E Vector Lance, Alt sprint, C jump/movement-chain input, V technique, R reset,
and F6 restart at 60/120 Hz. Controller defaults use left/right sticks, right
trigger, shoulders, and west/east face buttons.

The lower-right `MATERIAL YARD F1` panel is a read-only texture generated from
the canonical 128 x 128 seed. Its labels identify the static seed/worldbone
hashes that booted; it is not yet an interactive reaction simulation.

## Architecture boundary

`src/sim/` owns canonical integer state. It has no Node, renderer, input,
audio, transport, or `CharacterBody2D` dependency. `src/app/bootstrap.gd`
samples semantic commands and interpolates confirmed positions for drawing.
Never move authoritative outcomes into the bootstrap scene.

Godot export presets are present for Linux and Windows. Export templates are a
large optional preparation artifact and are not silently downloaded by test or
run scripts. Cache the matching 4.7.1 templates before an offline release
build.
