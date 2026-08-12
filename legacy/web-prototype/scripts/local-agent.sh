#!/usr/bin/env bash

# Safe-by-default local Qwen coding handoff for FLUX. Odysseus can use the same
# prompt and state files; Aider provides the repository-editing execution layer.

set -Eeuo pipefail

script_path="$(realpath -- "${BASH_SOURCE[0]}")"
repo_dir="$(cd -- "$(dirname -- "${script_path}")/.." && pwd -P)"
# shellcheck source=./local-agent-common.sh
source "${repo_dir}/scripts/local-agent-common.sh"

usage() {
  cat <<'EOF'
Usage: local-agent.sh COMMAND [options] [-- aider-options]

Commands:
  doctor   Verify repository, Ollama, Aider, and selected model readiness.
  chat     Start an interactive Aider session with FLUX context.
  run      Run bounded Odysseus-style implementation/test iterations.
  stop     Ask a running bounded loop to stop after its current iteration.
  logs     Show the latest session's private audit directory and files.

Options:
  --model auto|3b|7b      Select local Qwen2.5-Coder model (default: auto).
  --iterations N          Maximum run iterations (default: 1, maximum: 20).
  --timeout DURATION      Per-iteration GNU timeout value (default: 30m).
  --task FILE             Task prompt (default: .agent/odysseus-task.md).
  --no-commit             Leave a bounded run uncommitted (commits by default).
  -h, --help              Show this help.

The runtime auto-approves local tools and shell commands, uses only loopback
Ollama, and never pushes. It remains interactive in chat mode.
EOF
}

command_name="${1:-doctor}"
if [[ "${command_name}" == -h || "${command_name}" == --help ]]; then
  usage
  exit 0
fi
if [[ $# -gt 0 ]]; then
  shift
fi
model_request="${FLUX_AGENT_MODEL:-auto}"
iterations="${FLUX_AGENT_ITERATIONS:-1}"
iteration_timeout="${FLUX_AGENT_TIMEOUT:-30m}"
task_file="${FLUX_AGENT_TASK:-.agent/odysseus-task.md}"
commit_changes=true
aider_options=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --model)
      [[ $# -ge 2 ]] || flux_agent_fail '--model requires a value.'
      model_request="$2"
      shift
      ;;
    --iterations)
      [[ $# -ge 2 ]] || flux_agent_fail '--iterations requires a value.'
      iterations="$2"
      shift
      ;;
    --timeout)
      [[ $# -ge 2 ]] || flux_agent_fail '--timeout requires a value.'
      iteration_timeout="$2"
      shift
      ;;
    --task)
      [[ $# -ge 2 ]] || flux_agent_fail '--task requires a value.'
      task_file="$2"
      shift
      ;;
    --no-commit) commit_changes=false ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      aider_options+=("$@")
      break
      ;;
    *) flux_agent_fail "Unknown option: $1" ;;
  esac
  shift
done

cd -- "${repo_dir}"
flux_agent_require_repo "${repo_dir}"

state_root="${XDG_STATE_HOME:-${HOME}/.local/state}/flux-local-agent"
if [[ "${command_name}" == logs ]]; then
  latest_file="${state_root}/latest"
  [[ -r "${latest_file}" ]] || flux_agent_fail 'No local-agent audit session has been recorded yet.'
  latest_dir="$(<"${latest_file}")"
  [[ -d "${latest_dir}" ]] || flux_agent_fail "Latest audit directory is missing: ${latest_dir}"
  printf 'Latest FLUX local-agent audit: %s\n' "${latest_dir}"
  find "${latest_dir}" -maxdepth 1 -type f -printf '  %f\n' | sort
  exit 0
fi

model_tag="$(flux_agent_model_tag "${model_request}")"
aider_model="ollama_chat/${model_tag}"
flux_agent_enable_local_runtime

doctor() {
  local failed=0
  local aider_path='MISSING'
  if resolved_aider="$(flux_agent_aider_command 2>/dev/null)"; then
    aider_path="${resolved_aider}"
  else
    failed=1
  fi

  printf 'FLUX local-agent status\n'
  printf '  repository: %s\n' "${repo_dir}"
  printf '  branch: %s\n' "$(git branch --show-current)"
  printf '  head: %s\n' "$(git rev-parse --short=12 HEAD)"
  printf '  worktree: %s\n' "$(git status --porcelain | wc -l | tr -d ' ') changed paths"
  printf '  session: %s\n' "${XDG_CURRENT_DESKTOP:-${XDG_SESSION_DESKTOP:-unknown}}"
  printf '  model: %s\n' "${model_tag}"
  printf '  aider: %s\n' "${aider_path}"

  for command_required in curl find flock git node npm ollama tee timeout; do
    if ! command -v "${command_required}" >/dev/null 2>&1; then
      printf '  missing: %s\n' "${command_required}" >&2
      failed=1
    fi
  done
  if command -v node >/dev/null 2>&1 &&
    ! node -e 'const [a,b]=process.versions.node.split(".").map(Number); process.exit(a>20 || (a===20 && b>=19) ? 0 : 1)'; then
    printf '  node version: %s is below required 20.19\n' "$(node -p 'process.versions.node')" >&2
    failed=1
  fi
  if ! flux_agent_ollama_ready; then
    printf '  ollama API: unavailable at %s\n' "${OLLAMA_API_BASE}" >&2
    failed=1
  elif ! flux_agent_model_present "${model_tag}"; then
    printf '  model state: not pulled\n' >&2
    failed=1
  else
    printf '  model state: ready\n'
  fi

  (( failed == 0 )) || return 1
}

case "${command_name}" in
  doctor)
    doctor
    exit
    ;;
  stop)
    : > .agent/STOP
    printf 'Stop requested. The loop will exit after its current command.\n'
    exit
    ;;
  chat | run) ;;
  *)
    usage >&2
    flux_agent_fail "Unknown command: ${command_name}"
    ;;
esac

doctor
flux_agent_require_safe_tree "${repo_dir}"
[[ -f "${task_file}" ]] || flux_agent_fail "Task file not found: ${task_file}"

aider_command="$(flux_agent_aider_command)"
exec 9>"${repo_dir}/.agent/agent.lock"
flock --nonblock 9 || flux_agent_fail 'Another FLUX local agent holds .agent/agent.lock.'

umask 077
run_id="$(date -u +%Y%m%dT%H%M%SZ)-$$"
audit_dir="${state_root}/${run_id}"
session_log="${audit_dir}/session.log"
chat_history="${audit_dir}/chat-history.md"
input_history="${audit_dir}/input-history.txt"
llm_history="${audit_dir}/llm-history.log"
events_file="${audit_dir}/events.tsv"
start_head="$(git rev-parse HEAD)"
mkdir -p -- "${audit_dir}"
printf '%s\n' "${audit_dir}" > "${state_root}/latest"
printf 'timestamp_utc\tevent\tdetail\n' > "${events_file}"

audit_event() {
  printf '%s\t%s\t%s\n' "$(date -u --iso-8601=seconds)" "$1" "${2:-}" >> "${events_file}"
}
audit_event session_start "mode=${command_name};model=${model_tag};commit=${commit_changes}"

{
  printf 'FLUX local-agent audit manifest\n'
  printf 'started_utc=%s\n' "$(date -u --iso-8601=seconds)"
  printf 'repository=%s\n' "${repo_dir}"
  printf 'mode=%s\n' "${command_name}"
  printf 'model=%s\n' "${model_tag}"
  printf 'ollama=%s\n' "${OLLAMA_API_BASE}"
  printf 'branch=%s\n' "$(git branch --show-current)"
  printf 'start_commit=%s\n' "${start_head}"
  printf 'iterations=%s\n' "${iterations}"
  printf 'timeout=%s\n' "${iteration_timeout}"
  printf 'auto_approve=true\n'
  printf 'local_commit=%s\n' "${commit_changes}"
  printf 'push=false\n'
  printf 'runtime_network=loopback-model-and-local-tests-only\n'
  printf '\nInitial status\n'
  git status --short --branch
  printf '\nRecent history\n'
  git log -5 --oneline --decorate
} > "${audit_dir}/manifest.txt"

audit_finalize() {
  local final_status="$1"
  local end_head
  trap - EXIT
  audit_event session_end "exit_status=${final_status}"
  end_head="$(git rev-parse HEAD 2>/dev/null || printf unavailable)"
  {
    printf 'finished_utc=%s\n' "$(date -u --iso-8601=seconds)"
    printf 'exit_status=%s\n' "${final_status}"
    printf 'start_commit=%s\n' "${start_head}"
    printf 'end_commit=%s\n' "${end_head}"
    printf '\nFinal status\n'
    git status --short --branch || true
    printf '\nSession commits\n'
    git log --oneline --decorate "${start_head}..${end_head}" || true
    printf '\nCommitted diff statistics\n'
    git diff --stat "${start_head}..${end_head}" || true
  } > "${audit_dir}/final-state.txt"
  git diff --binary "${start_head}..${end_head}" > "${audit_dir}/committed-changes.patch" 2>/dev/null || true
  git diff --binary > "${audit_dir}/uncommitted-changes.patch" 2>/dev/null || true
  git diff --cached --binary > "${audit_dir}/staged-changes.patch" 2>/dev/null || true
  printf '\nAudit directory: %s\n' "${audit_dir}"
}
trap 'audit_finalize "$?"' EXIT

run_logged() {
  local command_status
  printf '\n$' | tee -a "${session_log}"
  printf ' %q' "$@" | tee -a "${session_log}"
  printf '\n' | tee -a "${session_log}"
  audit_event command_start "$*"
  set +e
  "$@" 2>&1 | tee -a "${session_log}"
  command_status="${PIPESTATUS[0]}"
  set -e
  audit_event command_end "status=${command_status};command=$*"
  return "${command_status}"
}

common_aider_options=(
  --model "${aider_model}"
  --no-dirty-commits
  --no-attribute-author
  --no-attribute-committer
  --auto-test
  --test-cmd "npm test"
  --yes-always
  --analytics-disable
  --no-check-update
  --disable-playwright
  --show-diffs
  --verbose
  --chat-history-file "${chat_history}"
  --input-history-file "${input_history}"
  --llm-history-file "${llm_history}"
  --read AGENTS.md
  --read .agent/VISUAL-OVERHAUL.md
  --read .agent/PIXEL-PERSPECTIVE-OVERHAUL.md
  --read .agent/MOVEMENT-INPUT-OVERHAUL.md
  --read README.md
  --read .agent/HANDOFF.md
  --read .agent/memory.md
  --read .agent/backlog.md
  --read .odysseus/STATE.md
)

if [[ "${command_name}" == chat ]]; then
  printf 'Starting full-access interactive FLUX Aider with %s. Ctrl+C exits.\n' "${model_tag}"
  printf 'Local runtime: loopback Ollama only; confirmations and telemetry are disabled.\n'
  printf 'Audit directory: %s\n' "${audit_dir}"
  audit_event aider_start interactive
  set +e
  "${aider_command}" "${common_aider_options[@]}" --auto-commits "${aider_options[@]}" 2>&1 |
    tee -a "${session_log}"
  chat_status="${PIPESTATUS[0]}"
  set -e
  audit_event aider_end "status=${chat_status};mode=interactive"
  exit "${chat_status}"
fi

[[ "${iterations}" =~ ^[0-9]+$ ]] || flux_agent_fail '--iterations must be an integer.'
(( iterations >= 1 && iterations <= 20 )) || flux_agent_fail '--iterations must be from 1 through 20.'
command -v systemd-inhibit >/dev/null 2>&1 && inhibit_prefix=(systemd-inhibit --what=sleep:idle --mode=block --who='FLUX local agent' --why='Bounded code and test iteration') || inhibit_prefix=()

rm -f -- .agent/STOP
printf 'Starting %d bounded FLUX iteration(s) with %s.\n' "${iterations}" "${model_tag}"
printf 'Local commits: %s; network/push: disabled. Use Ctrl+C or scripts/local-agent.sh stop.\n' "${commit_changes}"
printf 'Audit directory: %s\n' "${audit_dir}"

for (( iteration = 1; iteration <= iterations; iteration += 1 )); do
  [[ ! -e .agent/STOP ]] || break
  printf '\n[FLUX] local-agent iteration %d/%d\n' "${iteration}" "${iterations}"

  printf '\n[command] aider bounded iteration %d\n' "${iteration}" | tee -a "${session_log}"
  audit_event aider_start "bounded_iteration=${iteration}"
  set +e
  "${inhibit_prefix[@]}" timeout --signal=TERM --kill-after=2m "${iteration_timeout}" \
    "${aider_command}" \
      "${common_aider_options[@]}" \
      --no-auto-commits \
      --message-file "${task_file}" \
      "${aider_options[@]}" 2>&1 | tee -a "${session_log}"
  agent_status="${PIPESTATUS[0]}"
  set -e
  audit_event aider_end "status=${agent_status};bounded_iteration=${iteration}"

  if (( agent_status != 0 )); then
    flux_agent_notify critical 'FLUX local agent stopped' "Iteration ${iteration} exited ${agent_status}; review the worktree."
    flux_agent_fail "Iteration ${iteration} exited ${agent_status}; changes were not committed."
  fi

  if [[ -z "$(git status --porcelain)" ]]; then
    printf '[FLUX] iteration %d produced no changes; stopping.\n' "${iteration}"
    break
  fi

  run_logged npm test
  for shell_file in scripts/*.sh; do
    run_logged bash -n "${shell_file}"
  done
  run_logged git diff --check

  if [[ "${commit_changes}" == true ]]; then
    run_logged git add -A
    run_logged git -c commit.gpgsign=false commit -m "Continue FLUX local-agent iteration ${iteration}"
  else
    printf '[FLUX] verified changes remain uncommitted for human review; stopping.\n'
    break
  fi
done

flux_agent_notify normal 'FLUX local agent finished' "Review ${repo_dir} and test the game."
printf '\nFLUX local-agent run finished. Review git status and the actual game before merging.\n'
