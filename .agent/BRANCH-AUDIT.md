# FLUX branch audit

Audit date: 2026-07-28

Stable reference: `main` at `78805f17af3e453603264689cd8f60a45e578eba`

Integration baseline: `agent/windows-linux-runtime` at
`d77c0b281802aad29946bbe8d5abecf0e3284062`

All branch heads below were preserved in pushed `archive/pre-unify-*` annotated
tags before integration began.

## Branch inventory

| Branch | Head | Main behind/ahead | PR / CI | Classification | Decision |
| --- | --- | ---: | --- | --- | --- |
| `main` | `78805f1` | 0 / 0 | PRs #1–#4 merged | REQUIRED | Stable release baseline; never rewritten. |
| `agent/windows-linux-runtime` | `d77c0b2` | 0 / 1 | PR #6; Windows and Ubuntu checks passed | REQUIRED | Strongest verified baseline. Preserve the complete commit. |
| `agent/resource-hud-first-slice` | `a687938` | 0 / 13 | PR #7; head has no checks | PARTIALLY RELEVANT | Preserve planning/audit material and useful verification intent. Exclude one-shot checkpoint jobs and branch-specific workflow architecture. |
| `agent/full-overhaul-implementation` | `459edc2` | 0 / 25 | PR #8; checkpoint apply failed | PARTIALLY RELEVANT | Preserve real data-foundation code/tests and useful documentation. Exclude transport payloads and inferior Windows termination workaround. |
| `agent/prototype-loop` | `7ec3062` | main 4 / branch 2 | PR #5 open; no checks | PARTIALLY RELEVANT | Code through `cb1f014` is already represented by merged main history. Reconcile useful distribution limitations into final ledgers; do not import stale branch-specific handoff state wholesale. |
| `agent/odysseus-aider` | `78805f1` | 0 / 0 | none | SUPERSEDED | Exact `main` head; no unique files or commits. |
| `agent/odysseus-last-good` | `78805f1` | 0 / 0 | none | SUPERSEDED | Exact `main` head; no unique files or commits. |
| `agent/diff-0.9.1-actionable-ui-20260725` | `83637cb` | main 48 / branch 0 | none | SUPERSEDED | Ancestor of `main`; fully contained. |
| `agent/diff-0-8-release-20260725` | `42859c3` | main 64 / branch 0 | none | SUPERSEDED | Ancestor of `main`; fully contained. |

## Unique commit classification

### `agent/windows-linux-runtime`

- `d77c0b2` — REQUIRED. Native Windows `npm.cmd`, authenticated loopback
  shutdown, cross-platform lifecycle tests, Windows/Ubuntu CI, line-ending
  policy, and 0.34.3 release metadata. Both CI lanes passed.

### `agent/resource-hud-first-slice`

- `52f25a4` through `13f37c0` — PARTIALLY RELEVANT documentation: focused
  overhaul constraints, plan, system audit, playable ledger, and compatibility
  matrix.
- `becebeb`, `d3ff65a`, `13d918a` — PARTIALLY RELEVANT CI design. Preserve
  multi-version/platform verification and diagnostic intent in the canonical
  workflow, not the obsolete base-branch topology.
- `27dbc24`, `1bdbeb7`, `9c98d59`, `84b3419`, `a687938` — TRANSPORT/CI ONLY.
  These locate paths, publish snapshots, or reconstruct/apply the failed
  checkpoint. They are not product source.

### `agent/full-overhaul-implementation`

- `14cdc97` — PARTIALLY RELEVANT implementation-loop documentation.
- `894f677`, `412b22e`, `addc876` — REQUIRED future-system foundation:
  validated element/race/ability/loadout/movement/destruction data plus
  deterministic tests and standard-suite registration. The module is not the
  authoritative live simulation until later vertical slices integrate it.
- `5dc9a0f` — SUPERSEDED by `d77c0b2`'s stronger IPC and authenticated
  loopback shutdown implementation.
- `de8eea1` — SUPERSEDED workaround accepting Windows forced termination;
  intentionally rejected because graceful shutdown is available.
- `686721f` — PARTIALLY RELEVANT verification evidence, reconciled into the
  unified playable-state ledger rather than copied with stale branch claims.
- `d107156`, `49c2467`, `4b06a02`, `ae69c64`, `3ba1dc7`, `1cffe7a`,
  `7da5674`, `025c208`, `e9b65ba`, `459edc2` — TRANSPORT/CI ONLY checkpoint
  file/chunk/application commits.

## Checkpoint integrity finding

Expected decompressed SHA-256:
`195fc3aba15b1400e679a87e89eae85e1880a64ced98080f540fc142c7fe7239`.

- Eight declared part files and the readiness marker exist.
- Declared concatenation of parts 00–07 is invalid Base64.
- Part 07 is duplicated verbatim at offset 9000 inside part 06.
- The standalone `.patch.gz.b64` file is also invalid Base64.
- A non-declared concatenation of parts 00–06 decompresses to 228,793 bytes
  and matches the recorded hash, but this is not the manifest's deterministic
  eight-part reconstruction and has not been applied or tested.

Therefore the checkpoint is archived only. Its payload, readiness marker, and
one-shot application workflow are GENERATED / TRANSPORT artifacts and must not
enter `develop`.

## Post-audit branch movement

The first recovery snapshot did not freeze remote writers. A refresh at 12:41
found two advanced tips:

- `agent/resource-hud-first-slice` advanced from `a687938` to `2ffa373` through
  three additional checkpoint-blob CI commits. These are transport-only and are
  excluded from `develop`.
- `agent/full-overhaul-implementation` advanced from `459edc2` to `36f09b5`.
  It now contains a 3,800-line applied gameplay checkpoint plus a DOM repair.
  The source is preserved for later review, but all four Linux/Windows Node
  lanes fail the browser-shell lifecycle check at `tests/game-dom.test.mjs:224`:
  reset leaves `data-screen="game"` where the contract expects `menu`.

Fresh annotated recovery tags were pushed for the exact new tips:

- `archive/pre-unify-resource-hud-20260728-1241` -> `2ffa373`
- `archive/pre-unify-full-overhaul-20260728-1241` -> `36f09b5`

At 12:46, the full-overhaul branch advanced again to `292eb57` with a staged
Sanctum DOM contract and revised browser-shell test. The exact new tip is
preserved as `archive/pre-unify-full-overhaul-20260728-1246`; its replacement CI
run was still pending when this audit entry was written. This does not alter the
defer decision: it is outside the stable candidate until independently green and
reviewed as a later vertical slice.

The failing overhaul is DEFERRED, not discarded. It must not expand the current
unification diff or replace the known-playable live simulation. The executable
preflight now verifies every candidate branch still matches its pushed archive
tag before cleanup can proceed.

## Pull requests

| PR | State | Classification | Disposition after unified PR exists |
| --- | --- | --- | --- |
| #5 `prototype-loop -> main` | open draft | documentation only, stale branch | Close as superseded after relevant limitations are recorded. |
| #6 `windows-linux-runtime -> main` | open draft, green | required | Close as incorporated by `develop`. |
| #7 `resource-hud-first-slice -> main` | open draft | partial docs/CI plus transport infrastructure | Close as superseded after selective integration. |
| #8 `full-overhaul-implementation -> resource-hud-first-slice` | open draft, failing | valid foundation plus invalid transport | Close only after real commits are present and green on `develop`. |
