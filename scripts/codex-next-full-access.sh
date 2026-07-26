#!/usr/bin/env bash

set -Eeuo pipefail

readonly script_path="$(realpath -- "$0")"

if [[ "${DIFF_CODEX_INHIBITED:-0}" != 1 ]] &&
  command -v systemd-inhibit >/dev/null 2>&1; then
  exec systemd-inhibit \
    --what=sleep:idle:handle-lid-switch \
    --mode=block \
    --who="DIFF Codex" \
    --why="Full-access DIFF project iteration" \
    env DIFF_CODEX_INHIBITED=1 bash "${script_path}" "$@"
fi

if [[ $# -gt 1 ]]; then
  printf 'Usage: %s [repository-directory]\n' "$0" >&2
  exit 2
fi

notify_user() {
  local urgency="$1"
  local title="$2"
  local body="$3"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send --urgency="${urgency}" "${title}" "${body}" >/dev/null 2>&1 || true
  fi
}

fail() {
  local message="$1"
  printf 'ERROR: %s\n' "${message}" >&2
  notify_user critical "DIFF Codex stopped" "${message}"
  exit 1
}

for command_name in codex git realpath tee; do
  command -v "${command_name}" >/dev/null 2>&1 ||
    fail "Missing required command: ${command_name}"
done

if (( EUID == 0 )); then
  fail "Run this as your normal user, not with sudo. Full access already means every file and command your user can access."
fi

if [[ $# -eq 1 ]]; then
  repo_dir="$(realpath -m -- "$1")"
elif git -C "$PWD" rev-parse --show-toplevel >/dev/null 2>&1; then
  repo_dir="$(git -C "$PWD" rev-parse --show-toplevel)"
else
  repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
fi
readonly repo_dir

git -C "${repo_dir}" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
  fail "${repo_dir} is not a Git working tree."
[[ -f "${repo_dir}/AGENTS.md" ]] ||
  fail "${repo_dir}/AGENTS.md is missing."

readonly reasoning_effort="${DIFF_CODEX_REASONING:-xhigh}"
case "${reasoning_effort}" in
  low | medium | high | xhigh | max | ultra) ;;
  *) fail "DIFF_CODEX_REASONING must be low, medium, high, xhigh, max, or ultra." ;;
esac

codex_help="$(codex --help 2>&1 || true)"
exec_help="$(codex exec --help 2>&1 || true)"

if grep -q -- '--dangerously-bypass-approvals-and-sandbox' <<<"${codex_help}"; then
  codex_command=(codex --dangerously-bypass-approvals-and-sandbox)
  codex_exec=(exec)
elif grep -q -- '--dangerously-bypass-approvals-and-sandbox' <<<"${exec_help}"; then
  codex_command=(codex)
  codex_exec=(exec --dangerously-bypass-approvals-and-sandbox)
else
  fail "This Codex CLI does not expose the current full-access flag. Run 'codex update' or update @openai/codex, then retry."
fi

codex_command+=(--config "model_reasoning_effort=\"${reasoning_effort}\"")

if [[ -n "${DIFF_CODEX_MODEL:-}" ]]; then
  codex_command+=(--model "${DIFF_CODEX_MODEL}")
fi

if [[ -n "${DIFF_CODEX_PROFILE:-}" ]]; then
  codex_command+=(--profile "${DIFF_CODEX_PROFILE}")
fi

if [[ "${DIFF_CODEX_LIVE_SEARCH:-0}" == 1 ]]; then
  codex_command+=(--search)
fi

printf '%s\n' \
  "" \
  "DANGER: this starts Codex without its filesystem/network sandbox and without approval prompts." \
  "It can run every command and modify every file available to user '$(id -un)'." \
  "It does not grant root access, and this script refuses to run under sudo/root." \
  "Repository: ${repo_dir}" \
  ""

if [[ "${DIFF_FULL_ACCESS_CONFIRM:-0}" != 1 ]]; then
  if [[ ! -t 0 ]]; then
    fail "Interactive confirmation is required. Re-run in a terminal, or set DIFF_FULL_ACCESS_CONFIRM=1 after reviewing this script."
  fi
  read -r -p "Type FULL ACCESS to continue: " confirmation
  [[ "${confirmation}" == "FULL ACCESS" ]] || {
    printf 'Cancelled; nothing was changed.\n'
    exit 0
  }
fi

readonly run_id="$(date -u +%Y%m%dT%H%M%SZ)"
readonly state_root="${XDG_STATE_HOME:-${HOME}/.local/state}/diff-codex"
readonly run_dir="${state_root}/${run_id}"
readonly full_log="${run_dir}/session.log"
readonly final_message="${run_dir}/final.md"
mkdir -p -- "${run_dir}"

dirty_summary="$(git -C "${repo_dir}" status --short)"
if [[ -n "${dirty_summary}" ]]; then
  printf 'Existing local changes detected. Codex is instructed to preserve them:\n%s\n\n' \
    "${dirty_summary}"
fi

read -r -d '' task <<'TASK' || true
Continue the DIFF project as its principal gameplay engineer, systems designer,
technical designer, QA engineer, UX designer, and release engineer.

This is an implementation run, not a planning-only review. Full technical
access does not expand product scope or authorize unrelated machine changes.

START WITH CURRENT EVIDENCE

1. Read AGENTS.md completely and obey its gate order.
2. Inspect README.md, .agent/memory.md, .agent/backlog.md, the complete working
   tree, current Git status, recent history, package scripts, tests, launchers,
   content definitions, simulation authority, browser controller, and server.
3. Run or discover the actual baseline build, tests, syntax checks, and launch
   smoke. Do not trust stale summaries over the live checkout.
4. Determine which delivery gate is genuinely incomplete. Identify the
   highest-value player-facing deficiency inside that gate, including evidence
   and explicit acceptance checks.

IMPLEMENT THE NEXT STEP

5. Select one coherent primary outcome and implement it completely. Prefer an
   existing-loop improvement over disconnected breadth. Do not stop after
   analysis, a plan, scaffolding, TODOs, or placeholders.
6. Preserve all existing user changes. Never use destructive Git commands,
   discard work, rewrite history, expose secrets, change credentials, alter Git
   remotes, force-push, or silently replace stable behavior.
7. Keep gameplay authoritative, deterministic, data-driven, bounded, readable,
   cross-platform, and testable. Renderer state must not own game rules.
8. Validate the change with the fastest relevant deterministic tests, then the
   full suite, syntax/type/build checks, server health smoke, and real browser
   play verification when a usable browser exists. Never claim a check ran
   unless it actually ran.
9. Inspect the diff, remove generated junk and unrelated edits, fix regressions
   caused by the change, and update .agent/memory.md and .agent/backlog.md with
   exact commands, results, limitations, and the evidence-backed next task.

CONTINUE WITH DISCIPLINE

10. After one green slice, reassess the same current gate and continue with its
    next highest-value complete slice while useful work remains in this turn.
    Stop only when the gate is satisfied or a real permission, product-choice,
    physical-device/playtest, or technical blocker requires the user.

CURRENT PRIORITY SIGNALS TO VERIFY, NOT BLINDLY FOLLOW

- Hands-on acceptance on Garuda Sway and Windows remains unverified.
- A real two-device remote soak remains unverified.
- Input remapping and deterministic latency/jitter/loss diagnostics are queued.
- Gate 3 needs an objective whose reward changes route choice without increasing
  player damage or health.
- Gate 4 needs distinct enemy families only after combat tuning is credible.
- Broad roster expansion must not outrun fundamentals, clarity, and gate order.

SCOPE BOUNDARY

Work only inside this repository and task-relevant temporary directories.
Do not use sudo, modify the operating system, install global packages, message
people, deploy, publish, push, open pull requests, or mutate external services.
Do not copy protected assets or exact mechanics. If blocked by missing external
playtesting or a material product decision, leave the repository green, record
the exact evidence, and return the smallest concrete action required from the
user.
TASK

if [[ -n "${DIFF_CODEX_EXTRA_PROMPT:-}" ]]; then
  task+=$'\n\nADDITIONAL USER DIRECTION\n\n'
  task+="${DIFF_CODEX_EXTRA_PROMPT}"
fi

printf '%s\n' \
  "Starting full-access DIFF iteration..." \
  "Codex: $(codex --version 2>/dev/null || printf 'version unavailable')" \
  "Reasoning: ${reasoning_effort}" \
  "Log: ${full_log}" \
  "Final report: ${final_message}"

notify_user normal "DIFF Codex started" "Full-access iteration in ${repo_dir}"

set +e
(
  cd -- "${repo_dir}"
  "${codex_command[@]}" "${codex_exec[@]}" \
    --output-last-message "${final_message}" \
    "${task}"
) 2>&1 | tee -a "${full_log}"
codex_status="${PIPESTATUS[0]}"
set -e

if (( codex_status != 0 )); then
  notify_user critical "DIFF Codex failed" \
    "Exit ${codex_status}. Review ${full_log}"
  printf '\nCodex exited with status %d. Review: %s\n' \
    "${codex_status}" "${full_log}" >&2
  exit "${codex_status}"
fi

notify_user normal "DIFF Codex finished" "Review the result and test it in DIFF."
printf '\nCodex finished successfully.\nLog: %s\nFinal report: %s\n' \
  "${full_log}" "${final_message}"
