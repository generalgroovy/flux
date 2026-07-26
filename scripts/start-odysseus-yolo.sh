#!/usr/bin/env bash

set -Eeuo pipefail

script_path="$(realpath -- "${BASH_SOURCE[0]}")"
repo_dir="$(cd -- "$(dirname -- "${script_path}")/.." && pwd -P)"
cd -- "${repo_dir}"

for command_name in aider flock git timeout; do
  command -v "${command_name}" >/dev/null 2>&1 || {
    printf 'Missing required command: %s\n' "${command_name}" >&2
    exit 1
  }
done

branch="$(git branch --show-current)"
if [[ -z "${branch}" || "${branch}" == "main" ]]; then
  printf 'Refusing autonomous work on protected or detached branch: %s\n' "${branch:-detached}" >&2
  exit 1
fi
if [[ -n "$(git status --porcelain)" ]]; then
  printf 'Refusing to absorb an existing dirty worktree. Commit or preserve it first.\n' >&2
  exit 1
fi

exec 9>"${repo_dir}/.agent/agent.lock"
flock --nonblock 9 || {
  printf 'Another FLUX local agent already holds .agent/agent.lock.\n' >&2
  exit 1
}

if [[ "${1:-}" == "--check" ]]; then
  printf 'FLUX Odysseus supervisor is ready on %s.\n' "${branch}"
  exit 0
fi

rm -f "${repo_dir}/.agent/STOP"
iteration=0
printf 'Odysseus supervisor started on %s. Create .agent/STOP or press Ctrl+C to stop.\n' "${branch}"

while [[ ! -e "${repo_dir}/.agent/STOP" ]]; do
  iteration=$((iteration + 1))
  printf '\n[FLUX] autonomous iteration %d\n' "${iteration}"
  timeout --signal=TERM --kill-after=2m "${FLUX_AGENT_TIMEOUT:-45m}" \
    aider \
      --model "${FLUX_AIDER_MODEL:-ollama_chat/qwen2.5-coder:7b-instruct}" \
      --architect \
      --auto-accept-architect \
      --yes-always \
      --no-auto-commits \
      --no-dirty-commits \
      --no-attribute-author \
      --no-attribute-committer \
      --auto-test \
      --test-cmd "npm test" \
      --read AGENTS.md \
      --read README.md \
      --read .agent/HANDOFF.md \
      --read .agent/memory.md \
      --read .agent/backlog.md \
      --read .odysseus/STATE.md \
      --message-file .agent/odysseus-task.md

  npm test
  bash -n scripts/*.sh
  git diff --check

  git add -A
  if git diff --cached --quiet; then
    printf '[FLUX] iteration %d produced no changes; stopping.\n' "${iteration}"
    break
  fi
  git commit -m "Continue FLUX local-agent iteration ${iteration}"
  if [[ "${FLUX_AGENT_PUSH:-1}" == 1 ]]; then
    git push origin "${branch}"
  fi
  sleep "${FLUX_AGENT_PAUSE:-10}"
done
