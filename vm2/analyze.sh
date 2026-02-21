#!/usr/bin/env bash
# CSV: timestamp,cpu_pct,mem_pct,disk_pct,top3
set -euo pipefail
NODE_ID="node-01"
IN="/data/received_${NODE_ID}.log"
OUT="/data/summary_${NODE_ID}.txt"
mkdir -p /data
: > /tmp/analyze.out

if [ ! -s "$IN" ]; then
  echo "No data yet" | tee -a "$OUT"
  exit 0
fi

# Compute means and max using awk
awk -F, '
  BEGIN { cnt=0; sumc=0; summ=0; maxd=0 }
  NF>=4 {
    c=$2+0; m=$3+0; d=$4+0;
    sumc+=c; summ+=m; cnt++;
    if (d>maxd) maxd=d;
    if (c>40 || m>40) alert=1;
  }
  END {
    if (cnt==0) { printf("No rows\n"); exit }
    ac=sumc/cnt; am=summ/cnt;
    printf("avg_cpu=%.2f avg_mem=%.2f max_disk=%.2f ", ac, am, maxd);
    if (alert==1) printf("ALERT\n"); else printf("OK\n");
  }
' "$IN" | tee -a "$OUT"
