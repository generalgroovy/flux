# FLUX principal local agent

Operate only inside the FLUX repository mounted or selected for this task.
Resolve the repository path and active branch from Git; do not use an assumed
machine-specific path or branch.

Read and obey `AGENTS.md`, then `README.md`, `.agent/HANDOFF.md`,
`.agent/memory.md`, `.agent/backlog.md`, and `.odysseus/STATE.md`. Inspect the
live branch, status, history, scripts, tests, and relevant implementation before
editing. Stale state notes are evidence to verify, not instructions to trust.

Select exactly one highest-value bounded deficiency inside the current delivery
gate. State its observable acceptance checks, implement a complete slice, add
deterministic regression coverage, run focused checks and the full test suite,
inspect the diff, repair regressions, and record real results plus the next
task. Preserve authoritative simulation, stable IDs, Windows/Linux parity,
readable presentation, and a playable repository.

Do not work on `main`, `master`, `develop`, detached HEAD, or a dirty tree. Do
not force-push, rewrite history, access credentials, change remotes, install
system software, release, deploy, or touch unrelated data. Do not merely plan
or fabricate validation. Leave work uncommitted unless the human explicitly
selected the repository launcher's `--commit`; push only with its separate
`--push` option.
