# FLUX system audit

Audit date: 2026-07-28
Branch: `agent/resource-hud-first-slice`

## Inspected implementation

### Content and tuning

`src/content.mjs` currently centralizes characters, races, maps, modes, ability definitions, and match tuning.

Relevant current behavior:

- Primary fire defaults to zero Flux cost.
- Tactical defaults to 34 Flux.
- Defense defaults to 18 Flux.
- Mobility defaults to 16 Flux.
- Base maximum Flux is 100.
- Base Flux recovery is 19 per second.
- Base recovery delay is 0.46 seconds.
- Race Flux multipliers currently stay within the existing bounded race-stat validator.
- Ability names and full descriptions live in character content definitions.

### Simulation

`src/match.mjs` creates server-authoritative entities with:

- current and maximum health;
- current and maximum FLOW;
- current and maximum Flux;
- cooldown state per action;
- Flux recovery delay;
- dry-cast warning lockout;
- deterministic fixed-tick state.

This is a suitable foundation for a high-capacity, delayed-recovery Flux economy. The first slice should tune and test the existing resource model rather than introduce a second resource or hidden anti-spam meter.

### Current HUD

`index.html` currently exposes:

- top score and match readout;
- roster;
- separate FLOW and Flux action-bar cards;
- primary, tactical, defense, mobility, and conditional ultimate cards;
- full detail text inside persistent ability cards;
- a large live-field information panel;
- coaching copy and persistent explanatory labels;
- a full front-end menu over the arena.

The existing DOM already has the main slots needed for a compact action bar. The first GUI slice should reduce and relocate copy before replacing its structure.

### Packaging and test entry points

`package.json` currently provides:

- Electron desktop launch;
- friend-host launch;
- local and remote server launch;
- explicit deterministic and DOM/network test suites;
- Linux AppImage packaging;
- Windows NSIS packaging;
- GitHub release publishing configuration.

## First-slice risks

1. Raising maximum Flux without raising costs would increase spam.
2. Raising costs without increasing maximum would reduce option breadth.
3. Fast recovery with a short delay would reward continuous cycling.
4. A long delay with slow recovery would make the player feel resource-starved.
5. Changing stable ability names or wire fields would break content, tests, saves, or remote peers.
6. Removing HUD text before tooltip/focus equivalents exist would reduce understandability.
7. Broad DOM changes could destabilize the current DOM test suite.

## First-slice decisions

- Keep the existing Flux resource and recovery-delay model.
- Use a larger pool, proportionally larger paid-action costs, faster recovery, and a longer post-cast delay.
- Keep primary fire free.
- Keep all current and approved future character ability names.
- Reduce persistent copy only after compact replacements and accessible descriptions exist.
- Preserve `special` as the existing network compatibility alias for tactical.
- Preserve all stable content and mode IDs during player-facing naming changes.

## Verification status

Repository files were inspected through GitHub. No local test process or desktop runtime was available in this chat environment, so no test or launch success is claimed yet. Code changes must not be merged until the branch is checked out in the configured Odysseus/FLUX workspace and the declared verification commands pass.
