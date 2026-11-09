#!/usr/bin/env bash
# rollback.sh — switch traffic back to the environment recorded in .previous-env
set -euo pipefail
BASE=/opt/kijanikiosk
log() { echo "[ROLLBACK] $(date -u +%H:%M:%SZ) $*"; }

[[ $EUID -eq 0 ]] || { log "run with sudo"; exit 1; }
ACTIVE=$(cat "$BASE/.active-env" 2>/dev/null || echo none)
PREV=$(cat "$BASE/.previous-env" 2>/dev/null || echo none)
log "active=$ACTIVE previous=$PREV"

case "$PREV" in blue|green) ;; *) log "no valid previous environment ($PREV)"; exit 1 ;; esac
[[ "$PREV" != "$ACTIVE" ]] || { log "previous equals active; nothing to roll back to"; exit 1; }

log "rolling back $ACTIVE -> $PREV"
bash "$BASE/scripts/switch-env.sh" "$PREV"
log "rollback complete"
