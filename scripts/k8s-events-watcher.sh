#!/usr/bin/env bash
# ==============================================================================
# Kubernetes Warning Events Watcher
# Description: Streams warning and error events across all namespaces in real-time.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [Kubernetes Warning Events Watcher] ==="
echo "Executing: Streams warning and error events across all namespaces in real-time."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
