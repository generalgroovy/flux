#!/usr/bin/env bash

# Prepare a Garuda/Arch workstation for the repository-owned local-agent flow.
# Nothing is installed unless --install is explicitly supplied.

set -Eeuo pipefail

script_path="$(realpath -- "${BASH_SOURCE[0]}")"
repo_dir="$(cd -- "$(dirname -- "${script_path}")/.." && pwd -P)"
# shellcheck source=./local-agent-common.sh
source "${repo_dir}/scripts/local-agent-common.sh"

install=false
pull_model=false
model_request=auto
backend=cpu
aider_version="${FLUX_AIDER_VERSION:-}"

usage() {
  cat <<'EOF'
Usage: setup-local-agent-linux.sh [options]

  --check                 Diagnose only; make no changes (default).
  --install               Install missing Garuda/Arch packages and local Aider.
  --pull                  Pull the selected Ollama model.
  --model auto|3b|7b      Select model; auto uses 7B with sufficient RAM/VRAM.
  --backend cpu|cuda|rocm Select the Ollama package backend for --install.
  --aider-version VERSION Install a specific aider-chat version.
  -h, --help              Show this help.

Examples:
  bash scripts/setup-local-agent-linux.sh --check
  bash scripts/setup-local-agent-linux.sh --install --pull --model auto --backend cuda
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check) install=false ;;
    --install) install=true ;;
    --pull) pull_model=true ;;
    --model)
      [[ $# -ge 2 ]] || flux_agent_fail '--model requires a value.'
      model_request="$2"
      shift
      ;;
    --backend)
      [[ $# -ge 2 ]] || flux_agent_fail '--backend requires a value.'
      backend="$2"
      shift
      ;;
    --aider-version)
      [[ $# -ge 2 ]] || flux_agent_fail '--aider-version requires a value.'
      aider_version="$2"
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      flux_agent_fail "Unknown option: $1"
      ;;
  esac
  shift
done

[[ "$(uname -s)" == Linux ]] || flux_agent_fail 'This setup script supports Linux only.'
command -v pacman >/dev/null 2>&1 || flux_agent_fail 'Garuda/Arch pacman was not found.'
case "${backend}" in
  cpu | cuda | rocm) ;;
  *) flux_agent_fail '--backend must be cpu, cuda, or rocm.' ;;
esac

model_tag="$(flux_agent_model_tag "${model_request}")"
tools_root="$(flux_agent_tools_root)"
managed_aider="${tools_root}/aider-venv/bin/aider"

if [[ "${install}" == true ]]; then
  packages=(git nodejs npm python python-pip curl libnotify wl-clipboard ollama)
  case "${backend}" in
    cuda) packages+=(ollama-cuda) ;;
    rocm) packages+=(ollama-rocm) ;;
  esac

  printf 'Installing Garuda/Arch prerequisites: %s\n' "${packages[*]}"
  sudo pacman -S --needed --noconfirm "${packages[@]}"

  mkdir -p -- "${tools_root}"
  if [[ ! -x "${managed_aider}" ]]; then
    python -m venv "${tools_root}/aider-venv"
  fi
  aider_requirement='aider-chat'
  if [[ -n "${aider_version}" ]]; then
    aider_requirement+="==${aider_version}"
  fi
  "${tools_root}/aider-venv/bin/python" -m pip install --upgrade pip "${aider_requirement}"

  if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl enable --now ollama.service
  fi

  printf 'Installing FLUX locked dependencies...\n'
  (cd -- "${repo_dir}" && npm ci)
fi

printf 'FLUX local-agent doctor\n'
printf '  session: %s\n' "${XDG_CURRENT_DESKTOP:-${XDG_SESSION_DESKTOP:-unknown}}"
printf '  repository: %s\n' "${repo_dir}"
printf '  branch: %s\n' "$(git -C "${repo_dir}" branch --show-current)"
printf '  selected model: %s\n' "${model_tag}"
printf '  model policy: auto selects 7B at >=16 GiB RAM or >=7 GiB VRAM, otherwise 3B\n'

missing=0
for command_name in git node npm curl flock timeout ollama; do
  if command -v "${command_name}" >/dev/null 2>&1; then
    printf '  %-10s %s\n' "${command_name}:" "$(command -v "${command_name}")"
  else
    printf '  %-10s MISSING\n' "${command_name}:"
    missing=1
  fi
done
if aider_path="$(flux_agent_aider_command 2>/dev/null)"; then
  printf '  %-10s %s\n' 'aider:' "${aider_path}"
else
  printf '  %-10s MISSING\n' 'aider:'
  missing=1
fi

if (( missing != 0 )); then
  printf '\nMissing tools remain. Re-run with --install after reviewing this script.\n' >&2
  exit 1
fi

node_version="$(node -p 'process.versions.node')"
node_ok="$(node -e 'const [a,b]=process.versions.node.split(".").map(Number); process.exit(a>20 || (a===20 && b>=19) ? 0 : 1)' && printf yes || printf no)"
printf '  node: %s (>=20.19 required: %s)\n' "${node_version}" "${node_ok}"
[[ "${node_ok}" == yes ]] || flux_agent_fail 'Upgrade Node.js before running FLUX.'

if ! flux_agent_ollama_ready; then
  printf '\nOllama is installed but its local API is unavailable. Start it with:\n' >&2
  printf '  sudo systemctl enable --now ollama.service\n' >&2
  exit 1
fi

if [[ "${pull_model}" == true ]] && ! flux_agent_model_present "${model_tag}"; then
  ollama pull "${model_tag}"
fi
if flux_agent_model_present "${model_tag}"; then
  printf '  model: installed\n'
else
  printf '  model: not installed (run with --pull)\n' >&2
  exit 1
fi

printf '\nReady. Create or switch to a non-protected branch, then run:\n'
printf '  bash scripts/local-agent.sh chat --model %s\n' "${model_request}"
printf 'or one bounded implementation pass:\n'
printf '  bash scripts/local-agent.sh run --model %s --iterations 1\n' "${model_request}"
