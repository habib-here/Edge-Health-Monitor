#!/usr/bin/env bash
# Outputs CSV: timestamp,cpu_pct,mem_pct,disk_pct,top3 (PID:NAME:%CPU;PID:NAME:%CPU;PID:NAME:%CPU)
set -euo pipefail

get_cpu_pct() 
{
  # Calculate overall CPU usage using `top` (100 - idle)
  # Works with procps `top` in batch mode; parses the idle percentage field
  local idle
  idle=$(top -bn1 | awk -F',' '/Cpu\(s\)/ { for (i=1;i<=NF;i++) { if ($i ~ /id/) { gsub(/[^0-9.]/, "", $i); print $i; exit } } }')
  if [ -z "$idle" ]; then
    echo 0
    return
  fi
  awk -v id="$idle" 'BEGIN { printf "%.2f", (100 - id) }'
}

get_mem_pct() 
{
  # Use free to compute (used/total)*100
  free -m | awk '/^Mem:/ {printf "%.2f", ($3/$2)*100}'
}

get_disk_pct() 
{
  # Root filesystem usage percentage without the % sign
  df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}'
}

get_top3() 
{
  # Top 3 CPU-consuming processes: PID:NAME:%CPU;...
  ps -eo pid,comm,pcpu --sort=-pcpu | awk 'NR>1 {printf "%s:%s:%.1f;", $1, $2, $3} NR==4 {exit}' | sed 's/;$//'
}



########## execution start here ###############

NODE_ID="node-01"
OUT="/data/health_${NODE_ID}.log"

mkdir -p /data
# Ensure the log file exists but do not truncate on restart
touch "$OUT"

while true; do
  ts="$(date -Iseconds)"
  cpu="$(get_cpu_pct)"
  mem="$(get_mem_pct)"
  disk="$(get_disk_pct)"
  top3="$(get_top3)"
  line="$ts, $cpu, $mem, $disk, $top3"
  # Print to stdout and append to file so `docker logs` shows the line
  echo "$line" | tee -a "$OUT"

  # best-effort send to consumer (do not crash on failure)
  HOST="192.168.31.134"
  PORT="5000"
  echo "$line" | nc -w 1 "$HOST" "$PORT" || true
  sleep 5
done
