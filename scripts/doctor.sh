#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$repo_root/toolchains/godot.env"
godot_bin="${GODOT_BIN:-$(command -v godot4 || command -v godot || true)}"

[[ -n "$godot_bin" ]] || {
  printf 'FAIL: Godot is missing. Run scripts/install-godot.sh while connected.\n' >&2
  exit 1
}
actual="$($godot_bin --version)"
[[ "$actual" == "$GODOT_BUILD" ]] || {
  printf 'FAIL: expected Godot %s, found %s\n' "$GODOT_BUILD" "$actual" >&2
  exit 1
}
for required in project.godot scenes/bootstrap/bootstrap.tscn tests/run_all.gd; do
  [[ -f "$repo_root/$required" ]] || {
    printf 'FAIL: missing %s\n' "$required" >&2
    exit 1
  }
done
printf 'OK: Godot %s and FLUX2 foundation are present.\n' "$actual"
