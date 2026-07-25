# Outskilled

Outskilled is an original 2D top-down skill arena shooter/fighter in active
prototyping. The current build is a movement trial: accelerate through four
signals, learn the arena's handling, finish the route, and immediately run it
again for a better time.

## Play

Requirements:

- a current desktop browser
- Python 3 (only for the local static server)

```bash
npm start
```

Open <http://localhost:8000>. Move with **WASD** or the **arrow keys** and press
**R** to restart at any time.

No package installation or build step is required. The game runs from the same
source on Linux and Windows.

## Verify

The simulation tests require Node.js 20 or newer:

```bash
npm test
```

Core movement uses a fixed simulation tick. Gameplay values live in
[`src/config.mjs`](src/config.mjs); rendering and browser input are kept in
[`src/game.mjs`](src/game.mjs), while deterministic movement, bounds, progression,
and time formatting live in [`src/simulation.mjs`](src/simulation.mjs).

## Current thin slice

- responsive acceleration and deceleration with normalized diagonal input
- mouse-facing player indicator
- ordered, readable movement signals
- contextual first-use prompt
- completion timer and one-button restart flow
- responsive canvas presentation with reduced-motion support
- deterministic tests for movement, bounds, progression, and timer formatting

See [`.agent/backlog.md`](.agent/backlog.md) for the next prioritized iteration.
