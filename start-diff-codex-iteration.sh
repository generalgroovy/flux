#!/usr/bin/env bash
# Start a fresh, autonomous-but-auditable Codex iteration for the DIFF project.
# Run from Fish with: bash ./start-diff-codex-iteration.sh /path/to/diff

set -Eeuo pipefail

PROJECT_DIR="${1:-$PWD}"
if ! command -v codex >/dev/null 2>&1; then
  printf 'Codex CLI is not installed or is not on PATH. Install/login first, then retry.\n' >&2
  exit 1
fi
if ! PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"; then
  printf 'Project directory does not exist: %s\n' "$PROJECT_DIR" >&2
  exit 1
fi
if [[ ! -d "$PROJECT_DIR/.git" ]]; then
  printf 'Refusing to run outside a Git repository: %s\n' "$PROJECT_DIR" >&2
  exit 1
fi

cd "$PROJECT_DIR"
mkdir -p .agent/logs
LOG_FILE=".agent/logs/codex-iteration-$(date +%Y%m%d-%H%M%S).log"
PROGRESS_FILE=".agent/PROGRESS.md"

if [[ ! -f "$PROGRESS_FILE" ]]; then
  cat >"$PROGRESS_FILE" <<'EOF'
# DIFF Codex Iteration Progress

The active Codex agent records:
- inspected state and current objective
- changes made
- validation commands and outcomes
- remaining risks and the next recommended step
EOF
fi

read -r -d '' TASK <<'PROMPT' || true
You are the principal gameplay engineer for this repository. Work iteratively on DIFF: a fast, readable, top-down skill arena action game where movement, reaction, prediction, spacing, and elemental magic create outplay potential.

First inspect the repository, current branch, existing uncommitted changes, game architecture, test commands, and the current playable state. Preserve unrelated work. If the tree is dirty, treat it as intentional user work: do not revert, reset, overwrite broadly, or commit it unless it is clearly part of your own narrowly scoped changes.

Then execute a focused implementation-and-verification loop. The desired milestone is a polished, fully playable vertical slice that improves fundamentals and visual clarity, makes menus and play modes actionable, includes a toggleable readable information overlay, and adds one complete fitting new race/faction with ten distinctive characters. That race must introduce a genuinely different gameplay style rather than merely reskinning existing characters. Each character needs a clear silhouette, understandable role, unique mechanics, balanced counterplay, and implementation that is consistent with the project architecture.

Prioritize fun, clarity, responsiveness, and meaningful player choice over feature count. Make small reversible changes. Keep controls, HUD, ability feedback, collision, dash visibility, character selection, and game start flow reliable. Do not fabricate completed work: run the relevant tests, typechecks, build, and/or local smoke checks after each coherent slice; diagnose and fix failures you introduce. Add or update automated tests where practical. Inspect the final diff carefully.

Work autonomously, but be transparent: keep a concise progress log in .agent/PROGRESS.md describing inspected state, decisions, validation commands and outcomes, remaining risks, and the next best step. Commit only your own verified cohesive changes with clear messages; never force-push, change Git remotes, publish, install global packages, or use destructive Git commands. At a real blocker, stop and report the exact blocker plus the safest next action.

Begin now: inspect before editing, then implement the highest-value coherent slice you can verify.
PROMPT

printf 'Starting Codex in: %s\nLog: %s\nProgress: %s\n\n' \
  "$PROJECT_DIR" "$PROJECT_DIR/$LOG_FILE" "$PROJECT_DIR/$PROGRESS_FILE"

# Current Codex CLI automation uses `exec`; `--full-auto` is not a valid
# top-level option. `tee` keeps the live output visible and records it without
# replacing the calling terminal process.
set +e
codex exec --sandbox workspace-write --ask-for-approval never "$TASK" 2>&1 | tee -a "$LOG_FILE"
CODEX_STATUS=${PIPESTATUS[0]}
set -e

printf '\nCodex ended with status %s.\nLog: %s\nProgress: %s\n' \
  "$CODEX_STATUS" "$PROJECT_DIR/$LOG_FILE" "$PROJECT_DIR/$PROGRESS_FILE"
exit "$CODEX_STATUS"
