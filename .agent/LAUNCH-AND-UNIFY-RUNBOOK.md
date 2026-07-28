# FLUX launch and unification runbook

Date: 2026-07-28
Target: publish a green `develop` candidate; stop before merging to `main`

## 1. Freeze and preflight

Run from the repository root on a clean `integration/unify-flux` checkout:

```powershell
git fetch origin --prune --tags
npm.cmd run preflight:unify
npm.cmd test
npm.cmd audit --omit=dev
```

The preflight must fail if any cleanup candidate moved after its recorded archive
tag. A moved branch requires a new audit and pushed recovery tag; never update the
manifest just to make the check green.

## 2. Build the exact launch candidate

```powershell
npm.cmd run package:windows:verified
Get-Content -Raw dist/build-manifest.json
```

The wrapper refuses a dirty worktree, requires a fresh installer, and records the
exact commit, size, and SHA-256. Launch only the artifact named in that manifest.

## 3. Interactive Windows smoke

1. Open the manifest's installer or packaged application.
2. Confirm the FLUX window reaches the home screen in fullscreen.
3. Open **Play**, choose a normal duel, and press **Enter arena**.
4. Confirm two valid fighters appear, movement responds, one paid ability spends
   Flux, pause/resume works, and reset returns to a valid match.
5. Close through the normal window control.
6. Run `npm.cmd stop`; it must report no unrelated process termination.
7. Confirm no `FLUX Arena`, owned Electron renderer, or registered FLUX server
   remains. Do not kill similarly named unrelated Node processes.
8. Record the commit, artifact hash, observations, and cleanup result in
   `.agent/PLAYABLE-STATE.md`.

Any renderer error, stuck server, forced kill, or mismatch between HEAD and the
build manifest stops publication.

## 4. Publish `develop`

Only after the smoke passes:

```powershell
git branch develop HEAD
git push --set-upstream origin develop
gh pr create --repo generalgroovy/flux --base main --head develop --draft --title "Unify FLUX runtime, verification, and future foundation" --body-file .agent/UNIFICATION-REPORT.md
```

Wait for every Windows/Ubuntu test and package job. Download both package
artifacts and verify their `build-manifest.json` commit equals the PR head.

## 5. Close and clean superseded work

Run `npm.cmd run preflight:unify` again immediately before cleanup. Then:

1. Comment on PRs #5–#8 with the unified PR and exact recovery tag for each head.
2. Close those PRs as superseded; do not merge them.
3. Delete only branches still matching `.agent/unification-manifest.json` and
   only after the unified PR is green.
4. Keep every `archive/pre-unify-*` tag.
5. Fetch with prune and rerun the preflight. Missing deleted branches are expected
   only after the report records their deletion; update the manifest disposition
   in the same cleanup commit.

Never delete `main` or `develop`, never force-push, and stop before merging the
unified pull request into `main`.
