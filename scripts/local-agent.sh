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

Options:
  --model auto|3b|7b      Select local Qwen2.5-Coder model (default: auto).
  --iterations N          Maximum run iterations (default: 1, maximum: 20).
  --timeout DURATION      Per-iteration GNU timeout value (default: 30m).
  --task FILE             Task prompt (default: .agent/odysseus-task.md).
  --commit                Commit a verified run result (off by default).
  --push                  Push that commit; implies --commit (off by default).
  -h, --help              Show this help.

The loop refuses main/master/develop, detached HEAD, dirty trees, concurrent
FLUX agents, failed tests, and implicit commits or pushes.
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
commit_changes=false
push_changes=false
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
    --commit) commit_changes=true ;;
    --push)
      push_changes=true
      commit_changes=true
      ;;
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
model_tag="$(flux_agent_model_tag "${model_request}")"
aider_model="ollama_chat/${model_tag}"
export OLLAMA_API_BASE="${FLUX_OLLAMA_URL:-${OLLAMA_API_BASE:-http://127.0.0.1:11434}}"

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

  for command_required in curl flock git node npm ollama timeout; do
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

common_aider_options=(
  --model "${aider_model}"
  --no-auto-commits
  --no-dirty-commits
  --no-attribute-author
  --no-attribute-committer
  --auto-test
  --test-cmd "npm test"
  --read AGENTS.md
  --read README.md
  --read .agent/HANDOFF.md
  --read .agent/memory.md
  --read .agent/backlog.md
  --read .odysseus/STATE.md
)

if [[ "${command_name}" == chat ]]; then
  printf 'Starting interactive FLUX Aider with %s. Ctrl+C exits.\n' "${model_tag}"
  exec "${aider_command}" "${common_aider_options[@]}" "${aider_options[@]}"
fi

[[ "${iterations}" =~ ^[0-9]+$ ]] || flux_agent_fail '--iterations must be an integer.'
(( iterations >= 1 && iterations <= 20 )) || flux_agent_fail '--iterations must be from 1 through 20.'
command -v systemd-inhibit >/dev/null 2>&1 && inhibit_prefix=(systemd-inhibit --what=sleep:idle --mode=block --who='FLUX local agent' --why='Bounded code and test iteration') || inhibit_prefix=()

rm -f -- .agent/STOP
printf 'Starting %d bounded FLUX iteration(s) with %s.\n' "${iterations}" "${model_tag}"
printf 'Commits: %s; push: %s. Use Ctrl+C or scripts/local-agent.sh stop.\n' "${commit_changes}" "${push_changes}"

for (( iteration = 1; iteration <= iterations; iteration += 1 )); do
  [[ ! -e .agent/STOP ]] || break
  printf '\n[FLUX] local-agent iteration %d/%d\n' "${iteration}" "${iterations}"

  set +e
  "${inhibit_prefix[@]}" timeout --signal=TERM --kill-after=2m "${iteration_timeout}" \
    "${aider_command}" \
      "${common_aider_options[@]}" \
      --yes-always \
      --message-file "${task_file}" \
      "${aider_options[@]}"
  agent_status=$?
  set -e

  if (( agent_status != 0 )); then
    flux_agent_notify critical 'FLUX local agent stopped' "Iteration ${iteration} exited ${agent_status}; review the worktree."
    flux_agent_fail "Iteration ${iteration} exited ${agent_status}; changes were not committed or pushed."
  fi

  if [[ -z "$(git status --porcelain)" ]]; then
    printf '[FLUX] iteration %d produced no changes; stopping.\n' "${iteration}"
    break
  fi

  npm test
  for shell_file in scripts/*.sh; do
    bash -n "${shell_file}"
  done
  git diff --check

  if [[ "${commit_changes}" == true ]]; then
    git add -A
    git commit -m "Continue FLUX local-agent iteration ${iteration}"
    if [[ "${push_changes}" == true ]]; then
      active_branch="$(git branch --show-current)"
      git push origin "${active_branch}"
    fi
  else
    printf '[FLUX] verified changes remain uncommitted for human review; stopping.\n'
    break
  fi
done

flux_agent_notify normal 'FLUX local agent finished' "Review ${repo_dir} and test the game."
printf '\nFLUX local-agent run finished. Review git status and the actual game before merging.\n'
