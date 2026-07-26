# FLUX local-agent handoff

Repository: `/home/otp/Projects/flux`
Remote: `https://github.com/generalgroovy/flux.git`
Working branch: `agent/prototype-loop`
Protected branch: `main` — never modify, merge, rebase, or push it.

## Required context

Read, in order, before editing:

1. `AGENTS.md`
2. `README.md`
3. `.agent/memory.md`
4. `.agent/backlog.md`
5. `.odysseus/STATE.md`
6. Git status, current branch, and recent history

FLUX is a deterministic browser arena game. Preserve simulation authority,
stable identifiers, Linux/Windows parity, old-world pixel readability, and
small implementation → test → review → commit cycles.

## Current verified state

- Product and repository are named FLUX.
- Canonical checkout and remote paths use `flux`; DIFF names are compatibility
  aliases only.
- Keyboard/gamepad menu traversal, neutral Tide–Ember vapor, neutral
  Stone–Ember magma, and the `src/network/` boundary are implemented.
- Verification command: `npm test` (82 tests at handoff).
- Launch command: `npm start`; health: `/__flux_health`.
- Highest-value next slice: extract growing chemistry resolution from
  `src/match.mjs`, then introduce one deterministic destructible prop family.

## Operating contract

- Work only on `agent/prototype-loop` unless the user explicitly chooses a new
  non-main branch.
- Never force-push, rewrite history, expose secrets, or modify unrelated user
  work. Never claim tests passed unless they ran.
- Inspect first. Select one bounded player-facing outcome with acceptance checks.
- Implement it fully, add deterministic regression coverage, run focused checks,
  then `npm test`, inspect the diff, update memory/backlog, and commit.
- Push only after the commit and full verification succeed.
- Continue iterating until `.agent/STOP` exists or a real blocker requires the
  user. Do not replace implementation with planning.

The launchers intentionally use unrestricted/always-yes operation. That grants
the local model permission to execute shell commands and modify this workspace;
it does not authorize destructive system changes, credentials access, changes
to `main`, force-pushes, releases, or unrelated external actions.
