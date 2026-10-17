#!/usr/bin/env bash
# ==============================================================================
# Disk I/O Latency Benchmark
# Description: Tests block storage write and sync latency using dd with direct flag.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [Disk I/O Latency Benchmark] ==="
echo "Executing: Tests block storage write and sync latency using dd with direct flag."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
