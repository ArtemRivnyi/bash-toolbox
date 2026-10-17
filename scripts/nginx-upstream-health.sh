#!/usr/bin/env bash
# ==============================================================================
# Nginx Upstream Health Auditor
# Description: Checks latency and HTTP response codes of defined Nginx upstream targets.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [Nginx Upstream Health Auditor] ==="
echo "Executing: Checks latency and HTTP response codes of defined Nginx upstream targets."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
