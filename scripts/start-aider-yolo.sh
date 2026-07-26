#!/usr/bin/env bash

set -Eeuo pipefail

script_path="$(realpath -- "${BASH_SOURCE[0]}")"
repo_dir="$(cd -- "$(dirname -- "${script_path}")/.." && pwd -P)"
cd -- "${repo_dir}"

command -v aider >/dev/null 2>&1 || {
  printf 'Aider is not installed or unavailable on PATH.\n' >&2
  exit 1
}
command -v flock >/dev/null 2>&1 || {
  printf 'flock is required to prevent concurrent local agents.\n' >&2
  exit 1
}

branch="$(git branch --show-current)"
if [[ -z "${branch}" || "${branch}" == "main" ]]; then
  printf 'Refusing unrestricted Aider on protected or detached branch: %s\n' "${branch:-detached}" >&2
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
  printf 'FLUX Aider YOLO launcher is ready on %s.\n' "${branch}"
  exit 0
fi

printf 'Starting unrestricted Aider in %s on %s. Ctrl+C stops it.\n' "${repo_dir}" "${branch}"
exec aider \
  --model "${FLUX_AIDER_MODEL:-ollama_chat/qwen2.5-coder:7b-instruct}" \
  --architect \
  --auto-accept-architect \
  --yes-always \
  --auto-commits \
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
  "$@"
