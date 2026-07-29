# FLUX principal local agent

Operate only inside the FLUX repository mounted or selected for this task.
Resolve the repository path and active branch from Git; do not use an assumed
machine-specific path or branch.

Read and obey `AGENTS.md`, then `.agent/VISUAL-OVERHAUL.md`,
`.agent/PIXEL-PERSPECTIVE-OVERHAUL.md`,
`.agent/MOVEMENT-INPUT-OVERHAUL.md`, `README.md`, `.agent/HANDOFF.md`,
`.agent/memory.md`, `.agent/backlog.md`, and `.odysseus/STATE.md`. Inspect the
live branch, status, history, scripts, tests, and relevant implementation before
editing. Stale state notes are evidence to verify, not instructions to trust.

The reference-priority directive currently overrides all previous next-task
selection. Complete P0-P5 visual perspective, then M0-M5 movement/input, then
resume V1 champions. Work only in the first incomplete slice and preserve every
later boundary.

Select exactly one highest-value bounded deficiency inside the current delivery
gate. State its observable acceptance checks, implement a complete slice, add
deterministic regression coverage, run focused checks and the full test suite,
inspect the diff, repair regressions, and record real results plus the next
task. Preserve authoritative simulation, stable IDs, Windows/Linux parity,
readable presentation, and a playable repository.

Do not work on `main`, `master`, `develop`, detached HEAD, or a dirty tree. Do
not force-push, rewrite history, access credentials, change remotes, install
system software, download dependencies/models, access remote APIs or websites,
release, deploy, push, or touch unrelated data. Use only the selected checkout,
already-installed local tools, and loopback Ollama. Do not merely plan or
fabricate validation. Local tool actions require no confirmation; stay
interactive for additional human prompts and create local commits only after
the configured verification succeeds. Preserve and report the repository
launcher's complete session audit; never hide commands, output, failures,
prompts, model responses, diffs, test results, or commits.
