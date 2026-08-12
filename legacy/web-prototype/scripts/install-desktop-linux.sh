#!/usr/bin/env bash

set -Eeuo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
branch="${FLUX_BRANCH:-${DIFF_BRANCH:-$(git -C "${repo_dir}" branch --show-current)}}"
applications_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/applications"
desktop_file="${applications_dir}/flux-arena.desktop"
friends_desktop_file="${applications_dir}/flux-arena-friends.desktop"

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
    'Name=FLUX Arena' \
    'Comment=Update, verify, and launch FLUX' \
    "Exec=env FLUX_OPEN_BROWSER=1 bash \"${repo_dir}/scripts/pull-and-run.sh\" \"${repo_dir}\" \"${branch}\"" \
    "Path=${repo_dir}" \
    'Terminal=true' \
    'Categories=Game;ActionGame;' \
    'Keywords=arena;shooter;multiplayer;' \
    'StartupNotify=true'
} > "${desktop_file}"
chmod 0644 "${desktop_file}"
{
  printf '%s\n' \
    '[Desktop Entry]' \
    'Type=Application' \
    'Version=1.0' \
    'Name=FLUX Arena · Play with Friends' \
    'Comment=Update FLUX and create a private desktop invite' \
    "Exec=env FLUX_FRIENDS=1 bash \"${repo_dir}/scripts/pull-and-run.sh\" \"${repo_dir}\" \"${branch}\"" \
    "Path=${repo_dir}" \
    'Terminal=true' \
    'Categories=Game;ActionGame;' \
    'Keywords=arena;shooter;multiplayer;friends;' \
    'StartupNotify=true'
} > "${friends_desktop_file}"
chmod 0644 "${friends_desktop_file}"
if command -v desktop-file-validate >/dev/null 2>&1; then
  desktop-file-validate "${desktop_file}"
  desktop-file-validate "${friends_desktop_file}"
fi
printf 'Installed FLUX desktop launchers:\n  %s\n  %s\n' "${desktop_file}" "${friends_desktop_file}"
