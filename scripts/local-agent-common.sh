#!/usr/bin/env bash

# Shared helpers for the FLUX local-model handoff. This file is sourced by the
# launchers and is not intended to be run directly.

flux_agent_fail() {
  printf 'ERROR: %s\n' "$1" >&2
  return 1
}

flux_agent_repo_dir() {
  local source_path
  source_path="$(realpath -- "${BASH_SOURCE[0]}")"
  cd -- "$(dirname -- "${source_path}")/.." && pwd -P
}

flux_agent_tools_root() {
  printf '%s\n' "${XDG_DATA_HOME:-${HOME}/.local/share}/flux-local-agent"
}

flux_agent_aider_command() {
  local managed_aider
  if command -v aider >/dev/null 2>&1; then
    command -v aider
    return
  fi

  managed_aider="$(flux_agent_tools_root)/aider-venv/bin/aider"
  if [[ -x "${managed_aider}" ]]; then
    printf '%s\n' "${managed_aider}"
    return
  fi

  return 1
}

flux_agent_model_tag() {
  local requested="${1:-${FLUX_AGENT_MODEL:-auto}}"
  local memory_kib=0
  local vram_bytes=0
  local vram_mib=0
  local candidate_vram=0

  case "${requested}" in
    3 | 3b | qwen2.5-coder:3b | ollama_chat/qwen2.5-coder:3b)
      printf '%s\n' 'qwen2.5-coder:3b'
      ;;
    7 | 7b | qwen2.5-coder:7b | ollama_chat/qwen2.5-coder:7b)
      printf '%s\n' 'qwen2.5-coder:7b'
      ;;
    auto)
      if [[ -r /proc/meminfo ]]; then
        memory_kib="$(awk '/^MemTotal:/ { print $2; exit }' /proc/meminfo)"
      fi
      if command -v nvidia-smi >/dev/null 2>&1; then
        vram_mib="$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | sort -nr | head -n 1 | tr -d ' ' || true)"
      fi
      for vram_file in /sys/class/drm/card*/device/mem_info_vram_total; do
        [[ -r "${vram_file}" ]] || continue
        candidate_vram="$(<"${vram_file}")"
        if [[ "${candidate_vram}" =~ ^[0-9]+$ ]] && (( candidate_vram > vram_bytes )); then
          vram_bytes="${candidate_vram}"
        fi
      done
      if { [[ "${memory_kib:-0}" =~ ^[0-9]+$ ]] && (( memory_kib >= 16777216 )); } ||
        { [[ "${vram_mib:-0}" =~ ^[0-9]+$ ]] && (( vram_mib >= 7168 )); } ||
        (( vram_bytes >= 7516192768 )); then
        printf '%s\n' 'qwen2.5-coder:7b'
      else
        printf '%s\n' 'qwen2.5-coder:3b'
      fi
      ;;
    *)
      flux_agent_fail "Unsupported model '${requested}'. Choose auto, 3b, or 7b."
      ;;
  esac
}

flux_agent_require_repo() {
  local repo_dir="$1"
  git -C "${repo_dir}" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
    flux_agent_fail "${repo_dir} is not a Git working tree."
}

flux_agent_require_safe_tree() {
  local repo_dir="$1"
  local branch
  branch="$(git -C "${repo_dir}" branch --show-current)"

  if [[ -z "${branch}" ]]; then
    flux_agent_fail 'Refusing local-agent work on a detached HEAD.'
    return
  fi
  case "${branch}" in
    main | master | develop)
      flux_agent_fail "Refusing local-agent work on protected branch '${branch}'. Create an agent/* or codex/* branch first."
      return
      ;;
  esac
  if [[ -n "$(git -C "${repo_dir}" status --porcelain)" ]]; then
    flux_agent_fail 'Refusing to absorb an existing dirty worktree. Commit or preserve it first.'
    return
  fi
}

flux_agent_ollama_ready() {
  local api_base="${FLUX_OLLAMA_URL:-${OLLAMA_API_BASE:-http://127.0.0.1:11434}}"
  curl --silent --show-error --fail --max-time 2 \
    "${api_base%/}/api/tags" >/dev/null 2>&1
}

flux_agent_model_present() {
  local model_tag="$1"
  local api_base="${FLUX_OLLAMA_URL:-${OLLAMA_API_BASE:-http://127.0.0.1:11434}}"
  env OLLAMA_HOST="${api_base}" ollama list 2>/dev/null |
    awk 'NR > 1 { print $1 }' |
    grep -Fxq -- "${model_tag}"
}

flux_agent_notify() {
  local urgency="$1"
  local title="$2"
  local body="$3"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send --urgency="${urgency}" "${title}" "${body}" >/dev/null 2>&1 || true
  fi
}
