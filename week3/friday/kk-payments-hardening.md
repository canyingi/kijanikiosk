# kk-payments hardening log

Goal: score below 2.5 on systemd-analyze security while the service still starts and listens.

**Starting score: 9.2** (bare unit). **Final score: 1.2.** For comparison: kk-api 1.5, kk-logs 1.2.

Method: a throwaway copy of the payments unit (kk-hardtest, port 3101, same stub program and same service account) was built from a bare unit. Directives were added one at a time. After each one, the script measured the score and checked that the service started and its port opened. A directive that broke the service would have been dropped. None had to be dropped. The tables below are the raw output of that run.


Generated 2026-11-02T13:22:16+03:00 on canyingi-HP-EliteBook-840-G5; systemd 259 (259.5-0ubuntu3.4)

## Directives added one at a time (cumulative)

| # | Directive | Score after | Result |
|---|---|---|---|
| 0 | (none: bare unit, starting score) | 9.2 | ok |
| 1 | NoNewPrivileges=true | 9.0 | ok, kept |
| 2 | PrivateTmp=true | 8.7 | ok, kept |
| 3 | PrivateDevices=true | 8.0 | ok, kept |
| 4 | PrivateUsers=true | 7.9 | ok, kept |
| 5 | ProtectSystem=strict | 7.7 | ok, kept |
| 6 | ProtectHome=true | 7.5 | ok, kept |
| 7 | ProtectKernelTunables=true | 7.3 | ok, kept |
| 8 | ProtectKernelModules=true | 7.0 | ok, kept |
| 9 | ProtectKernelLogs=true | 6.7 | ok, kept |
| 10 | ProtectControlGroups=true | 6.5 | ok, kept |
| 11 | ProtectClock=true | 6.3 | ok, kept |
| 12 | ProtectHostname=true | 6.3 | ok, kept |
| 13 | ProtectProc=invisible | 6.1 | ok, kept |
| 14 | ProcSubset=pid | 6.1 | ok, kept |
| 15 | RestrictNamespaces=true | 5.4 | ok, kept |
| 16 | RestrictRealtime=true | 5.3 | ok, kept |
| 17 | RestrictSUIDSGID=true | 5.1 | ok, kept |
| 18 | LockPersonality=true | 5.1 | ok, kept |
| 19 | RemoveIPC=true | 5.0 | ok, kept |
| 20 | KeyringMode=private | 5.0 | ok, kept |
| 21 | CapabilityBoundingSet= | 3.3 | ok, kept |
| 22 | AmbientCapabilities= | 3.3 | ok, kept |
| 23 | SystemCallArchitectures=native | 3.1 | ok, kept |
| 24 | SystemCallFilter=@system-service | 1.7 | ok, kept |
| 25 | SystemCallErrorNumber=EPERM | 1.7 | ok, kept |
| 26 | RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX | 1.3 | ok, kept |
| 27 | IPAddressDeny=any + IPAddressAllow=localhost 10.0.1.0/24 | 1.2 | ok, kept |
| 28 | SocketBindDeny=any + SocketBindAllow=tcp:3101 | 1.2 | ok, kept |
| 29 | UMask=0077 | 1.2 | ok, kept |

## Directives investigated on top of the final set (not kept)

| Directive | Score if applied | Result |
|---|---|---|
| MemoryDenyWriteExecute=true | 1.2 | ok |
| PrivateNetwork=true | 0.8 | running but port closed |
| SystemCallFilter=~@privileged @resources | 1.0 | ok |

## Directives investigated and not applied

The table above shows what each one scored on the stand-in program. The decision does not rest on that alone, because the real payments program is not deployed yet.

**MemoryDenyWriteExecute=true (not applied).** It blocks memory that is both writable and runnable. Runtimes with a just-in-time compiler, including Node.js, need exactly that, so on a Node payments service it would crash at start-up or under load. On this machine it gave no score gain at all (1.2 with and without it), so there is no measured benefit to set against a real risk of a service that does not run. It can be revisited once the real runtime is known.

**PrivateNetwork=true (not applied).** It gives the best score of any experiment (0.8) and the service started, but its port was closed to everyone. The brief warns about this exact trap: a payments service that cannot accept connections is useless, and a good number would hide that. The network is already narrowed by the address allow-list and the socket-bind rule, which keep the service reachable only by the places it should talk to.

**SystemCallFilter=~@privileged @resources (not applied).** A stricter list of allowed system calls. It scored 1.0 and the stand-in ran, but the stand-in only proves start-up. The real application may need calls in those groups on code paths that run only under certain conditions, and a failure there would appear in production, not at start-up. I kept the broader @system-service list. This is the first directive to try again once the real program is deployed and can be tested.

## Decisions that need the real application

- **ReadWritePaths is empty on purpose.** The payments unit only reads its settings and the shared logs. If the real application must write somewhere, add only that folder.
- **PrivateUsers=true** hides other accounts from the service. If the real application checks file ownership by name, test it first.
- **The program listed in ExecStart is a stand-in.** The scores here were measured on the stand-in. After the real program is deployed, run the security analysis again and record the new score, because a different runtime can change which directives are safe.

## Final unit file and score

This is the unit installed by the provisioning script. Its score is the last line below.

```ini
[Unit]
Description=KijaniKiosk payments service
After=network.target kk-api.service
Wants=kk-api.service

[Service]
Type=simple
User=kk-payments
Group=kijanikiosk
EnvironmentFile=/opt/kijanikiosk/config/payments-api.env
# STUB listener: replace with the real application when it is deployed.
ExecStart=/usr/bin/python3 -u -m http.server 3001 --bind 0.0.0.0 --directory /opt/kijanikiosk/stub
Restart=on-failure
RestartSec=5

# --- hardening (payments handles financial data: strictest unit) ---
NoNewPrivileges=true
PrivateTmp=true
PrivateDevices=true
PrivateUsers=true
ProtectSystem=strict
ProtectHome=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectKernelLogs=true
ProtectControlGroups=true
ProtectClock=true
ProtectHostname=true
ProtectProc=invisible
ProcSubset=pid
RestrictNamespaces=true
RestrictRealtime=true
RestrictSUIDSGID=true
LockPersonality=true
RemoveIPC=true
KeyringMode=private
CapabilityBoundingSet=
AmbientCapabilities=
SystemCallArchitectures=native
SystemCallFilter=@system-service
SystemCallErrorNumber=EPERM
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
# Network allow-list: loopback (nginx) and the monitoring subnet only.
IPAddressDeny=any
IPAddressAllow=localhost 10.0.1.0/24
# The service may only listen on its own port.
SocketBindDeny=any
SocketBindAllow=tcp:3001
UMask=0077
# No ReadWritePaths: payments only reads (config and logs).

[Install]
WantedBy=multi-user.target
```

```
→ Overall exposure level for kk-payments.service: 1.2 OK 🙂
```
