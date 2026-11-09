#!/usr/bin/env bash
# switch-env.sh <blue|green>
# Moves nginx traffic to the target environment, only if the target is healthy.
# Updates state files: .previous-env <- old active, .active-env <- target.
set -euo pipefail

BASE=/opt/kijanikiosk
CONF=/etc/nginx/kijanikiosk-active-env.conf
PROXY=http://127.0.0.1:80/health

log() { echo "[SWITCH] $(date -u +%H:%M:%SZ) $*"; }
die() { log "ERROR: $*"; exit 1; }

[[ $EUID -eq 0 ]] || die "run with sudo"
TARGET=${1:-}
case "$TARGET" in
  blue)  PORT=3000 ;;
  green) PORT=3001 ;;
  *) echo "usage: $0 <blue|green>" >&2; exit 2 ;;
esac

CURRENT=$(cat "$BASE/.active-env" 2>/dev/null || echo none)
log "current=$CURRENT target=$TARGET (port $PORT)"

# 1. Pre-flight: never send traffic to an unhealthy environment
EXPECTED=""
for i in 1 2 3 4 5; do
  if BODY=$(curl -fsS --max-time 2 "http://127.0.0.1:$PORT/health"); then
    EXPECTED=$(python3 -c 'import json,sys;print(json.load(sys.stdin)["version"])' <<<"$BODY")
    log "pre-flight OK: $BODY"
    break
  fi
  log "pre-flight attempt $i/5 failed"; sleep 1
done
[[ -n "$EXPECTED" ]] || die "$TARGET is not healthy; nginx NOT changed"

# 2. Point nginx at the target (atomic write, validate, roll back config on error)
[[ -f "$CONF" ]] && cp "$CONF" "$CONF.bak"
printf 'proxy_pass http://kk-api-%s;\n' "$TARGET" > "$CONF.tmp"
mv "$CONF.tmp" "$CONF"
if ! nginx -t 2>/dev/null; then
  [[ -f "$CONF.bak" ]] && mv "$CONF.bak" "$CONF"
  die "nginx -t failed; previous config restored"
fi
systemctl reload nginx
log "nginx reloaded -> $(cat "$CONF")"

# 3. Verify through the proxy that the expected version is now served
OK=0
for i in $(seq 1 10); do
  GOT=$(curl -fsS --max-time 2 "$PROXY" 2>/dev/null \
        | python3 -c 'import json,sys;print(json.load(sys.stdin)["version"])' 2>/dev/null || true)
  if [[ "$GOT" == "$EXPECTED" ]]; then OK=1; break; fi
  sleep 0.5
done
[[ $OK -eq 1 ]] || die "proxy not serving $EXPECTED after switch"
log "proxy verified: serving $EXPECTED from $TARGET"

# 4. State files (only after a verified switch)
if [[ "$CURRENT" != "$TARGET" ]]; then
  echo "$CURRENT" > "$BASE/.previous-env.tmp" && mv "$BASE/.previous-env.tmp" "$BASE/.previous-env"
fi
[[ -f "$BASE/.previous-env" ]] || echo none > "$BASE/.previous-env"
echo "$TARGET" > "$BASE/.active-env.tmp" && mv "$BASE/.active-env.tmp" "$BASE/.active-env"
log "state: active=$(cat "$BASE/.active-env") previous=$(cat "$BASE/.previous-env")"
log "switch complete"
