#!/usr/bin/env bash

set -Eeuo pipefail

readonly REPOSITORY="${DIFF_REPOSITORY:-https://github.com/generalgroovy/diff.git}"
readonly PROJECTS_DIR="${HOME}/Projects"
readonly DEFAULT_DIR="${PROJECTS_DIR}/diff"

if [[ $# -gt 1 ]]; then
  printf 'Usage: %s [repository-directory]\n' "$0" >&2
  exit 2
fi

if [[ $# -eq 1 ]]; then
  repo_dir="$(realpath -m -- "$1")"
else
  repo_dir="${DEFAULT_DIR}"
fi

if [[ -n "${DIFF_PORT+x}" ]]; then
  port_was_explicit=true
  port="${DIFF_PORT}"
else
  port_was_explicit=false
  port=8000
fi

if [[ ! "${port}" =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
  printf 'DIFF_PORT must be an integer from 1 to 65535; received %s\n' "${port}" >&2
  exit 2
fi

port_is_in_use() {
  node -e '
    const net = require("node:net");
    const socket = net.connect({
      host: "127.0.0.1",
      port: Number(process.argv[1]),
    });
    socket.once("connect", () => {
      socket.destroy();
      process.exit(0);
    });
    socket.once("error", () => process.exit(1));
  ' "$1"
}

diff_is_ready() {
  node -e '
    fetch(`${process.argv[1]}/__diff_health`)
      .then(async (response) => {
        const body = await response.json();
        process.exit(
          response.ok &&
            body.product === "DIFF" &&
            body.status === "ready" &&
            body.version === "0.8.0" &&
            body.protocol === 1
            ? 0
            : 1
        );
      })
      .catch(() => process.exit(1));
  ' "$1"
}

for command_name in git node npm; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "${command_name}" >&2
    exit 1
  fi
done

node_compatible="$(node -p '
  const [major, minor] = process.versions.node.split(".").map(Number);
  Number(major > 20 || (major === 20 && minor >= 19));
')"
if [[ "${node_compatible}" != 1 ]]; then
  printf 'DIFF requires Node.js 20.19 or newer; found %s\n' "$(node --version)" >&2
  exit 1
fi

if [[ "${REPOSITORY}" == https://github.com/* ]] && ! command -v gh >/dev/null 2>&1; then
  printf '%s\n' \
    'GitHub CLI is required for this private repository.' \
    'Install it on Garuda with: sudo pacman -S --needed github-cli' >&2
  exit 1
fi

if [[ "${REPOSITORY}" == https://github.com/* ]]; then
  if ! gh auth status --hostname github.com >/dev/null 2>&1; then
    printf '%s\n' \
      'GitHub authentication is required for this private repository.' \
      'Run: gh auth login --hostname github.com --git-protocol https --web'
    exit 1
  fi
  gh auth setup-git
fi

export GIT_TERMINAL_PROMPT=0

if [[ ! -e "${repo_dir}" ]]; then
  mkdir -p -- "$(dirname -- "${repo_dir}")"
  printf 'Cloning DIFF into %s\n' "${repo_dir}"
  if ! git clone --origin origin --branch main "${REPOSITORY}" "${repo_dir}"; then
    printf '%s\n' \
      'Clone failed. Authenticate first with:' \
      'gh auth login --hostname github.com --git-protocol https --web' >&2
    exit 1
  fi
elif [[ ! -d "${repo_dir}/.git" ]]; then
  printf 'Refusing to overwrite non-repository directory: %s\n' "${repo_dir}" >&2
  exit 1
fi

cd -- "${repo_dir}"

if [[ -n "$(git status --porcelain=v1)" ]]; then
  printf '%s\n' \
    "Update stopped: ${repo_dir} has uncommitted changes." \
    'Commit or stash them, then run this script again. Nothing was modified.' >&2
  exit 1
fi

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "${REPOSITORY}"
else
  git remote add origin "${REPOSITORY}"
fi

printf 'Fetching DIFF main...\n'
if ! git fetch --prune origin main; then
  printf '%s\n' \
    'Fetch failed. Authenticate first with:' \
    'gh auth login --hostname github.com --git-protocol https --web' >&2
  exit 1
fi

if git show-ref --verify --quiet refs/heads/main; then
  git switch main
else
  git switch --create main --track origin/main
fi

git branch --set-upstream-to=origin/main main
git pull --ff-only origin main

if [[ ! -f package.json ]]; then
  printf 'Update completed, but package.json is missing from %s\n' "${repo_dir}" >&2
  exit 1
fi

printf 'Installing locked dependencies...\n'
npm ci --ignore-scripts

printf 'Running deterministic tests...\n'
npm test

url="http://127.0.0.1:${port}"
if port_is_in_use "${port}"; then
  if diff_is_ready "${url}"; then
    printf '\nDIFF is already running at %s\n' "${url}"
    printf 'Open that address in your browser.\n'
    exit 0
  fi

  if [[ "${port_was_explicit}" == true ]]; then
    printf 'DIFF_PORT %s is already in use by another process.\n' "${port}" >&2
    exit 1
  fi

  available_port=
  for (( candidate = 8001; candidate <= 8100; candidate += 1 )); do
    if ! port_is_in_use "${candidate}"; then
      available_port="${candidate}"
      break
    fi
  done

  if [[ -z "${available_port}" ]]; then
    printf 'No free DIFF port was found from 8000 through 8100.\n' >&2
    exit 1
  fi

  printf 'Port %s is busy; using port %s instead.\n' "${port}" "${available_port}"
  port="${available_port}"
  url="http://127.0.0.1:${port}"
fi

printf 'Starting DIFF at %s\n' "${url}"
HOST="${DIFF_HOST:-127.0.0.1}" PORT="${port}" npm start &
server_pid=$!

cleanup() {
  if kill -0 "${server_pid}" >/dev/null 2>&1; then
    kill "${server_pid}" >/dev/null 2>&1 || true
    wait "${server_pid}" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

ready=false
for _ in {1..50}; do
  if ! kill -0 "${server_pid}" >/dev/null 2>&1; then
    wait "${server_pid}"
  fi
  if diff_is_ready "${url}"; then
    ready=true
    break
  fi
  sleep 0.1
done

if [[ "${ready}" != true ]]; then
  printf 'DIFF did not become ready at %s\n' "${url}" >&2
  exit 1
fi

printf '\nDIFF is ready at %s\n' "${url}"
printf 'Open that address in your browser. Press Ctrl+C here to stop DIFF.\n'
wait "${server_pid}"
