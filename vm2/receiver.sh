#!/usr/bin/env bash
set -euo pipefail

NODE_ID="node-01"
PORT="5000"
OUT="/data/received_${NODE_ID}.log"
mkdir -p /data
: > "$OUT"

echo "Listening on port $PORT..."
# Use a simple loop with nc -lk: each connection one line. Append safely.
while true; do
  nc -lk -p "$PORT" | while IFS= read -r line; do
    [ -n "$line" ] && echo "$line" >> "$OUT"
  done
  sleep 1
done
