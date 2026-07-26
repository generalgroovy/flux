#!/usr/bin/env bash

set -Eeuo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd -- "${repo_dir}"

for command_name in node npm; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "${command_name}" >&2
    exit 1
  fi
done

printf 'Installing locked dependencies...\n'
env npm_config_cache="${TMPDIR:-/tmp}/diff-npm-cache" npm ci --ignore-scripts

printf 'Checking source syntax...\n'
for source_file in src/*.mjs scripts/*.mjs; do
  node --check "${source_file}"
done
bash -n scripts/pull-and-run.sh
bash -n scripts/install-desktop-linux.sh
bash -n scripts/test-changes.sh

printf 'Running the full DIFF regression suite...\n'
npm test

if [[ -n "${DIFF_PORT:-}" ]]; then
  port="${DIFF_PORT}"
else
  port="$(
    node <<'NODE'
const net = require("node:net");

const tryPort = (port) =>
  new Promise((resolve) => {
    const server = net.createServer();
    server.unref();
    server.once("error", () => resolve(false));
    server.listen(port, "127.0.0.1", () => {
      server.close(() => resolve(true));
    });
  });

(async () => {
  for (let port = 8000; port <= 8100; port += 1) {
    if (await tryPort(port)) {
      process.stdout.write(String(port));
      return;
    }
  }
  process.exitCode = 1;
})();
NODE
  )"
fi

if [[ -z "${port}" ]]; then
  printf 'No free DIFF port was found from 8000 through 8100.\n' >&2
  exit 1
fi

printf '\nHEX 0.15.0 passed verification.\n'
printf 'Open http://127.0.0.1:%s and test every mode shortcut plus F1 field info.\n' "${port}"
printf 'Press Ctrl+C here to stop the server.\n'

exec env HOST="${DIFF_HOST:-127.0.0.1}" PORT="${port}" node scripts/serve.mjs
