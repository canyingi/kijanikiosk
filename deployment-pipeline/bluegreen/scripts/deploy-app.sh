#!/usr/bin/env bash
# deploy-app.sh — deploy APP_VERSION to DEPLOY_ENV (the idle side only).
#   APP_VERSION=v1.4.0 DEPLOY_ENV=green sudo -E bash deploy-app.sh
# ARTIFACT_BASE_URL is accepted for compatibility with the course brief; this
# local simulator has no artifact server, so the version is set via the env file.
set -euo pipefail
BASE=/opt/kijanikiosk
log() { echo "[DEPLOY] $(date -u +%H:%M:%SZ) $*"; }
die() { log "ERROR: $*"; exit 1; }

[[ $EUID -eq 0 ]] || die "run with sudo -E"
: "${APP_VERSION:?set APP_VERSION}"; : "${DEPLOY_ENV:?set DEPLOY_ENV}"
case "$DEPLOY_ENV" in blue) PORT=3000 ;; green) PORT=3001 ;; *) die "DEPLOY_ENV must be blue or green" ;; esac

# Guard: never deploy over the environment that is serving live traffic
ACTIVE=$(cat "$BASE/.active-env" 2>/dev/null || echo none)
[[ "$DEPLOY_ENV" != "$ACTIVE" ]] || die "$DEPLOY_ENV is the ACTIVE environment; refusing to deploy over live traffic"

log "deploying $APP_VERSION to $DEPLOY_ENV (active is $ACTIVE)"
printf 'APP_VERSION=%s\n' "$APP_VERSION" > "$BASE/config/$DEPLOY_ENV.env"
systemctl restart "kk-api-$DEPLOY_ENV.service"

for i in $(seq 1 15); do
  if BODY=$(curl -fsS --max-time 2 "http://127.0.0.1:$PORT/health" 2>/dev/null) && grep -q "\"$APP_VERSION\"" <<<"$BODY"; then
    log "healthy: $BODY"; exit 0
  fi
  sleep 1
done
die "$DEPLOY_ENV did not become healthy on $APP_VERSION within 15s"
