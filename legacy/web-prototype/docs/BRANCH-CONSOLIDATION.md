# Legacy FLUX branch consolidation

Date: 2026-08-09

This branch is the audited legacy-browser lineage prepared for import beneath
the canonical Godot FLUX repository. No remote branch was deleted or rewritten.
Complete pre-consolidation refs are recoverable from the verified repository
bundle recorded by the parent unification run.

## Tree-preserving history joins

The following tips are retained as merge parents while the current tree wins:

- `origin/agent/character-animation-skeletons`: an earlier animation-skeleton
  implementation superseded by `origin/agent/roster-animation-skeletons` on
  current main;
- `origin/agent/full-overhaul-implementation`: an archived 48-commit overhaul
  whose normal trial merge produced 14 conflicts and would restore older large
  runtime files over later movement, Sanctum, roster, pixel, and animation work;
- `origin/agent/prototype-loop`: two older prototype-loop documentation commits;
- `origin/agent/resource-hud-first-slice`: an older checkpoint/CI-heavy slice
  superseded by later mainline state.

The join uses Git's `ours` merge strategy. This is deliberate history
preservation, not a claim that every historical implementation was replayed.
The pre-join and post-join source trees are identical except for this audit
document.

## Normally merged work

`origin/integration/unify-flux` was merged normally. Its four later pixel
prototype commits add the pixel-perspective foundation, Sanctum renderer,
cardinal Nico runtime sprite, and initial spell language without removing the
newer roster-animation skeleton work.

## Validation and limitation

The combined tree reports 152 Node tests: 149 pass. Three test files cannot run
in this prepared checkout because dependencies declared and locked by the
project are not installed:

- `tests/game-dom.test.mjs`: missing `linkedom`;
- `tests/network.test.mjs`: missing `ws`;
- `tests/server-control.test.mjs`: the server cannot become ready because
  `scripts/serve.mjs` imports missing `ws`.

No package was downloaded or installed during consolidation. A fully prepared
dependency cache must run the repository's exact `npm test` gate before this
legacy subtree is promoted as independently release-green. This limitation does
not affect the Godot runtime, where the legacy project is archival/reference
material only.
