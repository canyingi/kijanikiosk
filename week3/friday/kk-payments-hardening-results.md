# kk-payments hardening results

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

## Final result

Final score: **1.2** (service result: ok)

```ini
[Unit]
Description=Hardening experiment (copy of kk-payments)
[Service]
User=kk-payments
Group=kijanikiosk
EnvironmentFile=/opt/kijanikiosk/config/payments-api.env
ExecStart=/usr/bin/python3 -u -m http.server 3101 --bind 127.0.0.1 --directory /opt/kijanikiosk/stub
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
IPAddressDeny=any
IPAddressAllow=localhost 10.0.1.0/24
SocketBindDeny=any
SocketBindAllow=tcp:3101
UMask=0077
```
