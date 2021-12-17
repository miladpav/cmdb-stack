#!/bin/bash

IP=$(ip a | grep eth0 -A 100 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -1)
HOSTNAME=$(hostname)
URL=$1

curl -s -X POST -d "{\"IP\": \"$IP\", \"hostname\": \"$HOSTNAME\"}" -H "Content-Type: application/json" "$URL" | tee /tmp/tmway_status.txt
