#!/usr/bin/env bash

set -Eeuo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
branch="${DIFF_BRANCH:-$(git -C "${repo_dir}" branch --show-current)}"
applications_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/applications"
desktop_file="${applications_dir}/diff-arena.desktop"

if [[ -z "${branch}" ]] || [[ "${branch}" == -* ]] || [[ "${branch}" == *..* ]]; then
  printf 'Cannot install launcher for unsafe or detached branch: %s\n' "${branch}" >&2
  exit 2
fi
if [[ "${repo_dir}" == *$'\n'* || "${repo_dir}" == *'"'* ]]; then
  printf 'Repository path contains characters unsupported by desktop launchers.\n' >&2
  exit 2
fi

mkdir -p -- "${applications_dir}"
{
  printf '%s\n' \
    '[Desktop Entry]' \
    'Type=Application' \
    'Version=1.0' \
    'Name=DIFF Arena' \
    'Comment=Update, verify, and launch DIFF' \
    "Exec=env DIFF_OPEN_BROWSER=1 bash \"${repo_dir}/scripts/pull-and-run.sh\" \"${repo_dir}\" \"${branch}\"" \
    "Path=${repo_dir}" \
    'Terminal=true' \
    'Categories=Game;ActionGame;' \
    'Keywords=arena;shooter;multiplayer;' \
    'StartupNotify=true'
} > "${desktop_file}"
chmod 0644 "${desktop_file}"
if command -v desktop-file-validate >/dev/null 2>&1; then
  desktop-file-validate "${desktop_file}"
fi
printf 'Installed DIFF desktop launcher: %s\n' "${desktop_file}"
