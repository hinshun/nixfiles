#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-minecraft}"

echo ">>> Deploy"
nix run .#deploy 2>&1 | grep -E "(All done|error|Error)" || true

echo ">>> Restart & warmup (quick)"
ssh "$HOST" "systemctl restart zerofs.service && sleep 2 && sync && echo 3 > /proc/sys/vm/drop_caches && python3 iops_benchmark.py /mnt/zerofs --quick" > /dev/null

echo ">>> Benchmark"
ssh "$HOST" "sync && echo 3 > /proc/sys/vm/drop_caches && python3 iops_benchmark.py /mnt/zerofs" | grep -E "(Random 4K|Sequential|Performance tier)"
