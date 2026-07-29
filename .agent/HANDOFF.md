# FLUX local-agent handoff

This handoff is path- and branch-independent. Derive the repository path,
active branch, commit, remote, test count, and playable status from the live
checkout; never trust a stale absolute path or an old test total.

## Required context

Read, in order, before editing:

1. `AGENTS.md`
2. `.agent/VISUAL-OVERHAUL.md`
3. `README.md`
4. `.agent/memory.md`
5. `.agent/backlog.md`
6. `.odysseus/STATE.md`
7. Git status, current branch, recent history, package scripts, and relevant code

FLUX is a deterministic browser/desktop arena game. Preserve authoritative
simulation, stable identifiers, Linux/Windows parity, old-world pixel
readability, and small implementation -> test -> review cycles.

## Operating contract

- Work only on the currently selected non-protected branch; `main`, `master`,
  `develop`, and detached HEAD are refused by the repository launcher.
- Start only from a clean tree so existing user changes cannot be mistaken for
  agent output.
- Choose one bounded player-facing outcome inside the current gate, define
  observable acceptance checks, implement it fully, and add deterministic
  coverage where practical.
- Run focused checks, `npm test`, shell syntax checks, and `git diff --check`;
  perform a real gameplay smoke when the change affects play or presentation.
- Update `.agent/memory.md`, `.agent/backlog.md`, and `.odysseus/STATE.md` with
  real results and limitations. Never report a check that did not run.
- The interactive agent auto-approves local shell/file actions, runs the full
  test command after edits, and creates local Git commits without confirmation.
  A bounded run also commits verified changes unless launched with
  `--no-commit`; no local-agent mode may push.
- Never force-push, rewrite history, access credentials, change remotes,
  publish releases, install system software, use non-local model/services, or
  touch unrelated data.
- Preserve the private per-session audit under the user's XDG state directory:
  manifest, terminal output, input/chat history, raw LLM request/response log,
  final state, commits, and committed/staged/uncommitted patches. Do not edit,
  suppress, or delete audit evidence from inside an agent session.

## Local model contract

Use Ollama through Aider's recommended `ollama_chat/` adapter. Supported models
are `qwen2.5-coder:3b` and `qwen2.5-coder:7b`; both use a bounded 16K context.
The 3B model is for narrow edits, tests, documentation, and diagnosis. Prefer
7B for cross-file implementation, but still constrain each run to one slice.

Odysseus is an optional workspace and scheduling surface, not a hidden second
implementation path. Give it `.agent/ODYSSEUS_PROMPT.md` and the repository
checkout; its shell agent must call the same `scripts/local-agent.sh` workflow
and the same test gates. Runtime inference is accepted only from loopback
Ollama; telemetry, update checks, URL ingestion, package downloads, and Git
network protocols are disabled after setup.
