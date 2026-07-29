#!/usr/bin/env bash

# Render a compact, live FLUX task handoff for pasting into Odysseus. On Sway,
# --clipboard sends it to wl-copy without creating a generated repository file.

set -Eeuo pipefail

script_path="$(realpath -- "${BASH_SOURCE[0]}")"
repo_dir="$(cd -- "$(dirname -- "${script_path}")/.." && pwd -P)"
clipboard=false

usage() {
  cat <<'EOF'
Usage: prepare-odysseus-handoff.sh [--clipboard]

  --clipboard   Copy the generated handoff with wl-copy (ideal on Sway).
  -h, --help    Show this help.

Without --clipboard, the handoff is printed to stdout.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --clipboard) clipboard=true ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      printf 'ERROR: Unknown option: %s\n' "$1" >&2
      exit 2
      ;;
  esac
  shift
done

git -C "${repo_dir}" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  printf 'ERROR: %s is not a Git working tree.\n' "${repo_dir}" >&2
  exit 1
}

render_handoff() {
  local branch
  local head
  local status
  branch="$(git -C "${repo_dir}" branch --show-current)"
  head="$(git -C "${repo_dir}" rev-parse HEAD)"
  status="$(git -C "${repo_dir}" status --short)"

  printf '# FLUX live Odysseus handoff\n\n'
  printf 'Repository: `%s`\n\n' "${repo_dir}"
  printf 'Branch: `%s`\n\n' "${branch:-DETACHED}"
  printf 'Commit: `%s`\n\n' "${head}"
  if [[ -z "${status}" ]]; then
    printf 'Working tree: `clean`\n\n'
  else
    printf 'Working tree: `DIRTY`\n\n'
    printf '```text\n%s\n```\n\n' "${status}"
  fi
  printf 'Recent history:\n\n```text\n'
  git -C "${repo_dir}" log -5 --oneline --decorate
  printf '```\n\n'
  printf 'Use the repository files directly; do not ask for or ingest an archive.\n'
  printf 'Read `.agent/ODYSSEUS_PROMPT.md` as the system contract and '
  printf '`.agent/odysseus-task.md` as the current task. Run '
  printf '`bash scripts/local-agent.sh doctor` before editing.\n'
}

if [[ "${clipboard}" == true ]]; then
  command -v wl-copy >/dev/null 2>&1 || {
    printf 'ERROR: wl-copy is missing; install the Garuda package wl-clipboard.\n' >&2
    exit 1
  }
  render_handoff | wl-copy
  printf 'Copied the live FLUX handoff to the Sway clipboard.\n'
else
  render_handoff
fi
