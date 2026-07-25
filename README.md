# DIFF

**Dodging Instinct. Fighting Finesse.**

DIFF is an original 2D top-down skill arena shooter/fighter targeting AAA-grade
responsiveness through a deliberately minimal visual language. The current
fundamentals slice puts **KITE**, a mobility duelist, into **BREAKLINE**, a
cover-based training arena.

## Play

Requirements:

- a current desktop browser
- Node.js 20 or newer

```bash
npm start
```

Open <http://127.0.0.1:8000>.

| Action | Input |
| --- | --- |
| Move | `WASD` or arrow keys |
| Aim | Mouse |
| Primary fire | Left click or `Space` |
| Dash | `Shift` |
| Restart | `R` |

No package installation or build step is required. The dependency-free local
server and game use identical source on Linux and Windows.

## Current foundation

- fixed-tick acceleration, deceleration, bounds, and cover collision
- pointer aim and cooldown-bounded projectile primary
- swept projectile/target collision and cover interception
- directional dash with readable cooldown feedback
- KITE character identity and BREAKLINE map identity
- reactive targets with health, hit confirmation, destruction, and screen feedback
- behavior-driven onboarding that teaches without pausing play
- clear completion, time, progress, and instant restart loop
- centralized, validated, deeply frozen gameplay configuration
- deterministic tests for mechanics, collision, combat, progression, and timing

## Verify

```bash
npm test
node --check src/config.mjs
node --check src/simulation.mjs
node --check src/game.mjs
node --check scripts/serve.mjs
```

Simulation and presentation are separated: deterministic gameplay lives in
[`src/simulation.mjs`](src/simulation.mjs), data and safe defaults in
[`src/config.mjs`](src/config.mjs), and browser input/rendering/feedback in
[`src/game.mjs`](src/game.mjs).

## Delivery order

1. fundamentals: mechanics, first character, first map, readable combat
2. PvP: duel rules, roster/map counterplay, then authoritative host/join
3. PvPvE: shared objectives and neutral threats built on proven PvP rules
4. PvE: expanded enemy families, encounters, progression, and bosses

Future autonomous iterations follow [`AGENTS.md`](AGENTS.md), record results in
[`.agent/memory.md`](.agent/memory.md), and pull the next verified task from
[`.agent/backlog.md`](.agent/backlog.md).
