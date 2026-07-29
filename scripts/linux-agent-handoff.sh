#!/usr/bin/env bash

# Canonical Garuda/Sway entry point for the repository-owned Odysseus and Aider
# handoff. The implementation remains in the focused scripts this dispatches.

set -Eeuo pipefail

script_path="$(realpath -- "${BASH_SOURCE[0]}")"
repo_dir="$(cd -- "$(dirname -- "${script_path}")/.." && pwd -P)"

usage() {
  cat <<'EOF'
Usage: linux-agent-handoff.sh COMMAND [options]

Commands:
  setup      Diagnose or install the Garuda/Aider/Ollama stack.
  doctor     Verify the checkout, local model, and Aider runtime.
  aider      Start the interactive, full-local-access Aider session.
  run        Execute one or more bounded Odysseus-style Aider passes.
  odysseus   Print a live Odysseus handoff; copies it on an active Sway session.
  logs       List the newest private development-audit directory.
  stop       Stop a bounded run after its current command.

Examples:
  bash scripts/linux-agent-handoff.sh setup --check
  bash scripts/linux-agent-handoff.sh setup --install --pull --model auto --backend cpu
  bash scripts/linux-agent-handoff.sh doctor --model auto
  bash scripts/linux-agent-handoff.sh aider --model auto
  bash scripts/linux-agent-handoff.sh run --model 7b --iterations 1
  bash scripts/linux-agent-handoff.sh odysseus --clipboard

Agent execution is unsandboxed for the current Linux user, auto-approves local
actions, uses only loopback Ollama, records a complete private audit, may commit
locally after verification, and never pushes.
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

case "${command_name}" in
  setup)
    exec "${repo_dir}/scripts/setup-local-agent-linux.sh" "$@"
    ;;
  doctor)
    exec "${repo_dir}/scripts/local-agent.sh" doctor "$@"
    ;;
  aider | chat)
    exec "${repo_dir}/scripts/local-agent.sh" chat "$@"
    ;;
  run)
    exec "${repo_dir}/scripts/local-agent.sh" run "$@"
    ;;
  odysseus | handoff)
    if [[ $# -eq 0 && -n "${WAYLAND_DISPLAY:-}" && -n "${SWAYSOCK:-}" ]] &&
      command -v wl-copy >/dev/null 2>&1; then
      exec "${repo_dir}/scripts/prepare-odysseus-handoff.sh" --clipboard
    fi
    exec "${repo_dir}/scripts/prepare-odysseus-handoff.sh" "$@"
    ;;
  logs | stop)
    exec "${repo_dir}/scripts/local-agent.sh" "${command_name}" "$@"
    ;;
  *)
    usage >&2
    printf 'ERROR: Unknown command: %s\n' "${command_name}" >&2
    exit 2
    ;;
esac
