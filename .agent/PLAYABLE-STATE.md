# FLUX playable-state ledger

Branch: `agent/resource-hud-first-slice`

## Baseline

The branch was created from `main` before overhaul code changes.

## Current branch changes

Documentation only:

- `.agent/OVERHAUL-PROMPT.md`
- `.agent/OVERHAUL-PLAN.md`
- `.agent/SYSTEM-AUDIT.md`
- `.agent/PLAYABLE-STATE.md`

No simulation, content, UI, networking, launcher, package, or test file has been changed yet.

## Claimed verification

- GitHub branch creation succeeded.
- Documentation commits succeeded.
- Relevant current source files were inspected.

## Not yet verified

The following have not been executed in this chat environment and must not be treated as passing:

```bash
npm ci
npm test
node --check src/content.mjs
node --check src/match.mjs
node --check src/game.mjs
npm start
npm run start:server
```

## Next code step

Implement Slice 1 as one small patch:

1. tune maximum Flux, recovery, recovery delay, and default paid-action costs;
2. extend content validation with burst/recovery invariants;
3. extend deterministic match tests for cast payment and recovery delay;
4. update compact HUD resource copy without renaming abilities;
5. run the full declared verification set;
6. record exact results here before committing the code slice as playable.
