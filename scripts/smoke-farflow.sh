#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tick_rate="${FLUX2_TICK_RATE:-120}"
port="${FLUX2_SESSION_PORT:-24892}"
timeout_seconds="${FLUX2_SMOKE_TIMEOUT:-20}"
charter="${FLUX2_SESSION_CHARTER:-open_commons}"
log_root="$repo_root/.godot/farflow-smoke"
host_log="$log_root/host.log"
guest_log="$log_root/guest.log"
mkdir -p -- "$log_root"
: >"$host_log"
: >"$guest_log"

[[ "$tick_rate" == 60 || "$tick_rate" == 120 ]] || { printf 'FLUX2_TICK_RATE must be 60 or 120.\n' >&2; exit 2; }
[[ "$port" =~ ^[0-9]+$ ]] && (( port >= 1024 && port <= 65535 )) || { printf 'FLUX2_SESSION_PORT must be 1024..65535.\n' >&2; exit 2; }
[[ "$timeout_seconds" =~ ^[0-9]+$ ]] && (( timeout_seconds >= 5 && timeout_seconds <= 60 )) || { printf 'FLUX2_SMOKE_TIMEOUT must be 5..60 seconds.\n' >&2; exit 2; }
[[ "$charter" == open_commons || "$charter" == sparring_circle || "$charter" == duel_knot ]] || { printf 'FLUX2_SESSION_CHARTER must be open_commons, sparring_circle or duel_knot.\n' >&2; exit 2; }

if [[ -n "${FLUX2_EXECUTABLE:-}" ]]; then
  program="$FLUX2_EXECUTABLE"
  [[ -x "$program" ]] || { printf 'Packaged executable is missing or not executable: %s\n' "$program" >&2; exit 1; }
  base_args=(--headless --fixed-fps "$tick_rate" --)
  printf 'Farflow acceptance target: package %s\n' "$program"
else
  "$repo_root/scripts/doctor.sh"
  program="${GODOT_BIN:-$(command -v godot4 || command -v godot || true)}"
  base_args=(--headless --path "$repo_root" --fixed-fps "$tick_rate" --)
  printf 'Farflow acceptance target: source via %s\n' "$program"
fi

host_pid=''
guest_pid=''
cleanup() {
  for pid in "$guest_pid" "$host_pid"; do
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
    fi
  done
}
trap cleanup EXIT INT TERM

wait_patterns() {
  local pid="$1"
  local log="$2"
  shift 2
  local deadline=$((SECONDS + timeout_seconds))
  while (( SECONDS < deadline )); do
    local complete=true
    local pattern
    for pattern in "$@"; do
      if ! grep -Fq -- "$pattern" "$log"; then complete=false; break; fi
    done
    [[ "$complete" == true ]] && return 0
    kill -0 "$pid" 2>/dev/null || { printf 'Farflow process exited before acceptance. See %s\n' "$log" >&2; return 1; }
    sleep 0.1
  done
  printf 'Farflow smoke timed out. See %s\n' "$log" >&2
  return 1
}

"$program" "${base_args[@]}" --tick-rate="$tick_rate" --farflow=host --session-port="$port" --session-charter="$charter" '--player-name=Lantern Host' --farflow-smoke-hearth >"$host_log" 2>&1 &
host_pid=$!
wait_patterns "$host_pid" "$host_log" "FLUX2 farflow host: listening on UDP $port"

"$program" "${base_args[@]}" --tick-rate="$tick_rate" --farflow=join --join-address=127.0.0.1 --session-port="$port" '--player-name=River Guest' --farflow-smoke-emote --farflow-smoke-prediction --farflow-smoke-hearth --farflow-smoke-reconnect >"$guest_log" 2>&1 &
guest_pid=$!
wait_patterns "$guest_pid" "$guest_log" \
  'FLUX2 farflow replica: local entity 2' \
  'FLUX2 farflow social: guest emote request sent' \
  'FLUX2 farflow prediction smoke: authoritative movement confirmed' \
  'FLUX2 farflow hearth smoke: guest readiness sent' \
  'FLUX2 farflow hearth smoke: guest received shared practice start' \
  'FLUX2 farflow reconnect smoke: left entity 2' \
  'FLUX2 farflow reconnect smoke: returned entity 2'
wait_patterns "$host_pid" "$host_log" \
  'FLUX2 farflow host: joined entity 2 (River Guest)' \
  'FLUX2 farflow social: shared emote entity 2' \
  'FLUX2 farflow hearth smoke: roster gathered and host ready' \
  'FLUX2 farflow hearth smoke: all ready; countdown started' \
  'FLUX2 farflow hearth: shared practice started' \
  'FLUX2 farflow host: return reserved for entity 2 (River Guest)' \
  'FLUX2 farflow host: returned entity 2 (River Guest)'

printf 'PASS: Farflow host/join, shared HELLO, movement reconciliation, Hearth start and exact-actor return passed at %s Hz on UDP %s.\n' "$tick_rate" "$port"
printf 'Logs: %s\n' "$log_root"
