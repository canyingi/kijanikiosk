#!/usr/bin/env bash
set -euo pipefail
name=$(jq -r .name)
ip=$(multipass info "$name" --format json | jq -r --arg n "$name" '.info[$n].ipv4[0]')
jq -n --arg ip "$ip" '{ip: $ip}'
