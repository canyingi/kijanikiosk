#!/usr/bin/env bash
# setup-bluegreen.sh — one-time install of the local blue/green staging environment.
# Run from inside the kit folder:  sudo bash setup-bluegreen.sh
set -euo pipefail
cd "$(dirname "$0")"
BASE=/opt/kijanikiosk
log() { echo "[SETUP] $*"; }
[[ $EUID -eq 0 ]] || { echo "run with sudo"; exit 1; }

# 0. Free port 3000 (Week 3 kk-api.service stub)
if systemctl is-active --quiet kk-api.service; then
  log "stopping and disabling old kk-api.service (frees port 3000; re-enable with: systemctl enable --now kk-api.service)"
  systemctl disable --now kk-api.service
fi
if ss -ltn | grep -q '127.0.0.1:3000 '; then
  log "port 3000 still in use:"; ss -ltnp | grep ':3000 '; exit 1
fi

# 1. Service user
getent group kijanikiosk >/dev/null || groupadd --system kijanikiosk
if ! id kk-api &>/dev/null; then
  useradd --system --no-create-home --shell /usr/sbin/nologin -g kijanikiosk kk-api
fi
usermod -aG kijanikiosk kk-api

# 2. Files
install -d -o root -g kijanikiosk -m 750 "$BASE/app" "$BASE/scripts" "$BASE/config"
install -o root -g kijanikiosk -m 640 app/server.py "$BASE/app/server.py"
for s in switch-env.sh rollback.sh post-deploy-monitor.sh deploy-app.sh; do
  install -o root -g kijanikiosk -m 750 "scripts/$s" "$BASE/scripts/$s"
done
echo 'APP_VERSION=v1.3.0' > "$BASE/config/blue.env"
echo 'APP_VERSION=v1.4.0' > "$BASE/config/green.env"
chown root:kijanikiosk "$BASE"/config/{blue,green}.env; chmod 640 "$BASE"/config/{blue,green}.env

# 3. systemd units
for pair in blue:3000 green:3001; do
  env=${pair%%:*}; port=${pair##*:}
  sed "s/__ENV__/$env/g; s/__PORT__/$port/g" systemd/kk-api@.service.template \
    > "/etc/systemd/system/kk-api-$env.service"
done
systemctl daemon-reload
systemctl enable --now kk-api-blue.service kk-api-green.service
sleep 2
curl -fsS http://127.0.0.1:3000/health; echo
curl -fsS http://127.0.0.1:3001/health; echo

# 4. nginx
install -m 644 nginx/kijanikiosk.conf /etc/nginx/sites-available/kijanikiosk
ln -sf /etc/nginx/sites-available/kijanikiosk /etc/nginx/sites-enabled/kijanikiosk
rm -f /etc/nginx/sites-enabled/default   # file remains in sites-available
echo 'proxy_pass http://kk-api-blue;' > /etc/nginx/kijanikiosk-active-env.conf
nginx -t
systemctl reload nginx

# 5. Initial state
echo blue > "$BASE/.active-env"
echo none > "$BASE/.previous-env"
chmod 644 "$BASE/.active-env" "$BASE/.previous-env"

log "done. Proxy says: $(curl -fsS http://127.0.0.1:80/health)"
