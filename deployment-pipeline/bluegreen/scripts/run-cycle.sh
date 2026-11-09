#!/usr/bin/env bash
# Terminal 2 driver: reset -> wait for monitor -> switch -> verify -> fault -> confirm -> summary
set -uo pipefail
cd ~/evidence
LOG=switch-cycle.log; R=rollback-evidence.txt
ts(){ while IFS= read -r l; do printf '[%s] %s\n' "$(date -u +%H:%M:%S)" "$l"; done; }
S=/opt/kijanikiosk/scripts

rm -f "$LOG" "$R" monitor.log
sudo -v
sudo systemctl start kk-api-green.service; sleep 2

{ echo "=== ENVIRONMENT: local staging on HP EliteBook (nginx proxy = 127.0.0.1:80) ==="
  echo "=== CLEAN STARTING STATE CONFIRMATION ==="
  echo "blue:  $(systemctl is-active kk-api-blue.service)"
  echo "green: $(systemctl is-active kk-api-green.service)"
  echo "blue  health: $(curl -s http://127.0.0.1:3000/health)"
  echo "green health: $(curl -s http://127.0.0.1:3001/health)"; } 2>&1 | ts | tee "$LOG"
sudo bash $S/switch-env.sh blue 2>&1 | ts | tee -a "$LOG"
{ echo "proxy: $(curl -s http://127.0.0.1:80/health)"
  echo ".active-env:   $(cat /opt/kijanikiosk/.active-env)"
  echo ".previous-env: $(cat /opt/kijanikiosk/.previous-env)"; } | ts | tee -a "$LOG"

echo
echo ">>> Waiting for the monitor in Terminal 1..."; until grep -q "MONITOR START" monitor.log 2>/dev/null; do sleep 0.5; done
echo "Monitor started in separate terminal" | ts | tee -a "$LOG"
sudo -v

echo "=== SWITCH blue -> green ===" | ts | tee -a "$LOG"
sudo bash $S/switch-env.sh green 2>&1 | ts | tee -a "$LOG"
{ echo "=== POST-SWITCH VERIFICATION ==="
  echo "proxy: $(curl -s http://127.0.0.1:80/health)"
  echo ".active-env:   $(cat /opt/kijanikiosk/.active-env)"
  echo ".previous-env: $(cat /opt/kijanikiosk/.previous-env)"
  echo "--- /etc/nginx/kijanikiosk-active-env.conf ---"
  cat /etc/nginx/kijanikiosk-active-env.conf; } 2>&1 | ts | tee -a "$LOG"

echo "Waiting 12s for healthy green polls..."; sleep 12

echo "T0 FAULT INTRODUCED: systemctl stop kk-api-green.service" | ts | tee "$R"
sudo systemctl stop kk-api-green.service
until curl -s --max-time 2 http://127.0.0.1:80/health | grep -q 'v1.3.0'; do sleep 1; done
echo "T2 ROLLBACK CONFIRMED: blue healthy through proxy" | ts | tee -a "$R"
{ echo ".active-env:   $(cat /opt/kijanikiosk/.active-env)"
  echo ".previous-env: $(cat /opt/kijanikiosk/.previous-env)"
  echo "proxy: $(curl -s http://127.0.0.1:80/health)"; } | ts | tee -a "$R"

sleep 2   # let the monitor finish writing
T0=$(grep 'T0 FAULT' "$R" | grep -o '[0-9:]\{8\}' | head -1)
T1=$(grep '^\[MONITOR FAIL\] ROLLBACK TRIGGERED' monitor.log | grep -o '[0-9:]\{8\}' | head -1)
T2=$(grep 'T2 ROLLBACK' "$R" | grep -o '[0-9:]\{8\}' | head -1)
s(){ date -u -d "$1" +%s; }
{ echo; echo "=== SUMMARY ==="
  echo "T0 (fault introduced):        $T0"
  echo "T1 (ROLLBACK TRIGGERED):      $T1"
  echo "T2 (blue healthy via proxy):  $T2"
  echo "Detection  T0->T1: $(( $(s $T1) - $(s $T0) ))s"
  echo "Total      T0->T2: $(( $(s $T2) - $(s $T0) ))s   (target < 90s)"
  echo "Human interaction with monitor terminal: none"
  echo; echo "=== FULL MONITOR OUTPUT ==="; cat monitor.log; } >> "$R"
cat "$R"
sudo systemctl start kk-api-green.service
