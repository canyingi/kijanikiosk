#!/usr/bin/env bash
# post-deploy-monitor.sh [WINDOW_SECONDS]
# Polls the public health endpoint (through nginx) every 5 s.
# 3 consecutive failures -> automatic rollback, no human involved.
# Passes when WINDOW seconds elapse with no failures in progress.
set -uo pipefail

WINDOW=${1:-60}
INTERVAL=5
THRESHOLD=3
URL=http://127.0.0.1:80/health
BASE=/opt/kijanikiosk

[[ $EUID -eq 0 ]] || { echo "run with sudo"; exit 1; }
now() { date -u +%H:%M:%SZ; }

START=$(date +%s)
FAILS=0
echo "[MONITOR START] $(now) window=${WINDOW}s interval=${INTERVAL}s threshold=${THRESHOLD} url=$URL"

while true; do
  ELAPSED=$(( $(date +%s) - START ))
  if BODY=$(curl -fsS --max-time 2 "$URL" 2>/dev/null); then
    FAILS=0
    echo "[MONITOR OK] $(now) t+${ELAPSED}s active=$(cat $BASE/.active-env 2>/dev/null) $BODY"
  else
    FAILS=$((FAILS + 1))
    echo "[MONITOR WARN] $(now) t+${ELAPSED}s health check failed ($FAILS/$THRESHOLD)"
    if (( FAILS >= THRESHOLD )); then
      echo "[MONITOR FAIL] ROLLBACK TRIGGERED $(now) after $FAILS consecutive failures"
      if bash "$BASE/scripts/rollback.sh"; then
        BODY=$(curl -fsS --max-time 2 "$URL" 2>/dev/null || echo "unreachable")
        echo "[MONITOR ROLLBACK COMPLETE] $(now) active=$(cat $BASE/.active-env) previous=$(cat $BASE/.previous-env) proxy=$BODY"
        exit 1   # deployment failed, but service restored
      else
        echo "[MONITOR ROLLBACK FAILED] $(now) manual intervention required"
        exit 2
      fi
    fi
  fi
  if (( ELAPSED >= WINDOW && FAILS == 0 )); then
    echo "[MONITOR PASS] $(now) ${WINDOW}s confidence window passed with no failures"
    exit 0
  fi
  sleep "$INTERVAL"
done
