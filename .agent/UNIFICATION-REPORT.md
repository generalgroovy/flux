# FLUX repository unification report

Date: 2026-07-28
Status: integration assembled locally; publication awaits packaged smoke

## Outcome so far

`integration/unify-flux` is the single reviewed candidate for the future
`develop` branch. It is based on the verified cross-platform runtime commit and
contains only attributable real commits plus manual reconciliation. `main` has
not been changed or merged.

## Safety and recovery

Annotated `archive/pre-unify-*-20260728-1220` tags were pushed for `main` and
every remote work branch before integration. No branch was force-pushed or
deleted. The exact tags and branch classifications are listed in
`.agent/BRANCH-AUDIT.md`.

The checkpoint transport was rejected. All eight declared parts exist, but part
07 is duplicated inside part 06. Declared concatenation and the standalone
payload are invalid Base64. Although a non-declared 00–06 sequence decompresses
to bytes matching the advertised SHA-256, it does not satisfy the manifest's
deterministic reconstruction contract and was not applied.

After the initial audit, the resource and full-overhaul branches advanced. New
12:41 recovery tags preserve their exact tips. The latter contains an applied
gameplay checkpoint but fails the same DOM reset contract on all four CI lanes;
it is explicitly deferred from this stable unification candidate. A subsequent
test-contract revision advanced that branch again at 12:46 and received its own
exact recovery tag; its replacement CI was pending and does not enter this
candidate.

## Reconciliation decisions

- `d77c0b2` supplies Windows/Linux launch reliability and graceful authenticated
  server shutdown.
- Current `main` remains authoritative for live content, simulation, UI,
  networking, saves, and packaged desktop behavior.
- Real overhaul documents and the isolated `src/overhaul-content.mjs` foundation
  were preserved without connecting them to live gameplay.
- Forced-shutdown and earlier transport variants were not reintroduced because
  the runtime baseline has the stronger lifecycle contract.
- CI was consolidated manually into one source-verification and packaging
  workflow for Windows and Ubuntu; checkpoint assembly is not part of CI.
- Packaging now emits a commit-bound SHA-256 manifest and uploads installable
  Windows/Linux artifacts for direct PR-head verification.
- A fail-closed preflight compares every cleanup branch to its expected remote
  head and pushed recovery tag before any deletion is considered.
- Future display labels were aligned to the approved simple vocabulary while
  retaining stable data IDs.

## Current verification

- Clean install: passed.
- Complete test command: 108/108 passed on Windows.
- Consolidated CI helper and recursive JavaScript syntax: passed.
- PowerShell parsing and workflow YAML parsing: passed.
- Production dependency audit: zero vulnerabilities.
- Windows package: passed at `3a02958`; rebuild and interactive smoke on current
  HEAD remain pending.
- Linux package: reserved for the canonical GitHub Actions Ubuntu job.

## Remaining publication sequence

1. Complete the scheduled current-HEAD Windows package/play/close smoke.
2. Commit any resulting ledger-only update or narrowly scoped repair.
3. Push the candidate as `develop` without rewriting history.
4. Open a draft pull request targeting `main` and wait for every Windows/Ubuntu
   test and packaging job.
5. Archive and close superseded pull requests; delete obsolete branches only
   after their recovery tags and the green candidate are confirmed remotely.
6. Stop before merging `develop` into `main` for explicit approval.

No green claim is made for a pending platform, package, or interactive gate.
