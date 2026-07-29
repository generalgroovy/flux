#!/usr/bin/env bash

set -Eeuo pipefail

script_path="$(realpath -- "${BASH_SOURCE[0]}")"
repo_dir="$(cd -- "$(dirname -- "${script_path}")/.." && pwd -P)"

printf 'Deprecated launcher name: using the safe interactive local-agent flow.\n' >&2
if [[ "${1:-}" == --check ]]; then
  shift
  exec "${repo_dir}/scripts/local-agent.sh" doctor "$@"
fi
exec "${repo_dir}/scripts/local-agent.sh" chat "$@"
