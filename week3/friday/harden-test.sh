#!/usr/bin/env bash
set -uo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo" >&2; exit 1; }

UNIT=kk-hardtest
FILE=/etc/systemd/system/$UNIT.service
PORT=3101
OUT=kk-payments-hardening-results.md

STEPS=(
  "NoNewPrivileges=true"
  "PrivateTmp=true"
  "PrivateDevices=true"
  "PrivateUsers=true"
  "ProtectSystem=strict"
  "ProtectHome=true"
  "ProtectKernelTunables=true"
  "ProtectKernelModules=true"
  "ProtectKernelLogs=true"
  "ProtectControlGroups=true"
  "ProtectClock=true"
  "ProtectHostname=true"
  "ProtectProc=invisible"
  "ProcSubset=pid"
  "RestrictNamespaces=true"
  "RestrictRealtime=true"
  "RestrictSUIDSGID=true"
  "LockPersonality=true"
  "RemoveIPC=true"
  "KeyringMode=private"
  "CapabilityBoundingSet="
  "AmbientCapabilities="
  "SystemCallArchitectures=native"
  "SystemCallFilter=@system-service"
  "SystemCallErrorNumber=EPERM"
  "RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX"
  $'IPAddressDeny=any\nIPAddressAllow=localhost 10.0.1.0/24'
  $'SocketBindDeny=any\nSocketBindAllow=tcp:3101'
  "UMask=0077"
)
EXPERIMENTS=(
  "MemoryDenyWriteExecute=true"
  "PrivateNetwork=true"
  "SystemCallFilter=~@privileged @resources"
)
KEPT=()

write_unit() {
  {
    printf '%s\n' '[Unit]' 'Description=Hardening experiment (copy of kk-payments)' \
      '[Service]' 'User=kk-payments' 'Group=kijanikiosk' \
      'EnvironmentFile=/opt/kijanikiosk/config/payments-api.env' \
      'ExecStart=/usr/bin/python3 -u -m http.server 3101 --bind 127.0.0.1 --directory /opt/kijanikiosk/stub'
    printf '%s\n' "$@"
  } > "$FILE"
}

score() {
  systemd-analyze security --no-pager "$UNIT.service" 2>/dev/null \
    | sed -nE 's/.*[Oo]verall exposure level for [^:]*: ([0-9]+\.[0-9]+).*/\1/p' | head -1
}
port_up() { timeout 2 bash -c "echo >/dev/tcp/127.0.0.1/$PORT" 2>/dev/null; }

measure() {
  systemctl daemon-reload
  systemctl stop "$UNIT" 2>/dev/null
  systemctl reset-failed "$UNIT" 2>/dev/null
  M_SCORE=$(score)
  systemctl start "$UNIT" 2>/dev/null
  local i
  for i in 1 2 3 4 5; do port_up && break; sleep 1; done
  if ! systemctl is-active --quiet "$UNIT"; then
    M_STATE="failed to start"
    journalctl -u "$UNIT" -n 4 --no-pager -o cat 2>/dev/null | sed 's/^/      /'
  elif ! port_up; then
    M_STATE="running but port closed"
  else
    M_STATE="ok"
  fi
  systemctl stop "$UNIT" 2>/dev/null
}

row() {
  printf '| %s | %s | %s | %s |\n' "$1" "${2//$'\n'/ + }" "$3" "$4" | tee -a "$OUT"
}

{
  echo "# kk-payments hardening results"
  echo
  echo "Generated $(date -Is) on $(hostname); $(systemctl --version | head -1)"
  echo
  echo "## Directives added one at a time (cumulative)"
  echo
  echo "| # | Directive | Score after | Result |"
  echo "|---|---|---|---|"
} > "$OUT"

write_unit
measure
row 0 "(none: bare unit, starting score)" "$M_SCORE" "$M_STATE"

n=0
for d in "${STEPS[@]}"; do
  n=$((n + 1))
  KEPT+=("$d")
  write_unit "${KEPT[@]}"
  measure
  if [[ $M_STATE == ok ]]; then
    row "$n" "$d" "$M_SCORE" "ok, kept"
  else
    row "$n" "$d" "$M_SCORE" "REJECTED: $M_STATE"
    unset 'KEPT[${#KEPT[@]}-1]'
  fi
done

{
  echo
  echo "## Directives investigated on top of the final set (not kept)"
  echo
  echo "| Directive | Score if applied | Result |"
  echo "|---|---|---|"
} | tee -a "$OUT"
for e in "${EXPERIMENTS[@]}"; do
  write_unit "${KEPT[@]}" "$e"
  measure
  printf '| %s | %s | %s |\n' "$e" "$M_SCORE" "$M_STATE" | tee -a "$OUT"
done

write_unit "${KEPT[@]}"
measure
{
  echo
  echo "## Final result"
  echo
  echo "Final score: **$M_SCORE** (service result: $M_STATE)"
  echo
  echo '```ini'
  cat "$FILE"
  echo '```'
} | tee -a "$OUT"

rm -f "$FILE"
systemctl daemon-reload
echo
echo "Done. Results saved in $OUT"
