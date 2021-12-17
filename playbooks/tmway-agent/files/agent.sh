#!/bin/bash

IP=$(ip a | grep $(ip link | awk -F: '$0 !~ "lo|vir|tun|docker|wl|br|^[^0-9]"{print $2;getline}') -A 5 | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -1)
HOSTNAME=$(hostname)
URL=$1

curl -s -X POST -d "{\"IP\": \"$IP\", \"hostname\": \"$HOSTNAME\"}" -H "Content-Type: application/json" "$URL" | tee /tmp/tmway_status.txt