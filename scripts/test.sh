#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
godot_bin="${GODOT_BIN:-$(command -v godot4 || command -v godot || true)}"
[[ -n "$godot_bin" ]] || {
  printf 'Godot is missing. Run scripts/install-godot.sh while connected.\n' >&2
  exit 1
}
"$repo_root/scripts/doctor.sh"
"$godot_bin" --headless --path "$repo_root" --import
"$godot_bin" --headless --path "$repo_root" --script tests/run_all.gd
for tick_rate in 60 120; do
  "$godot_bin" --headless --path "$repo_root" --quit-after 5 -- --tick-rate="$tick_rate"
done
