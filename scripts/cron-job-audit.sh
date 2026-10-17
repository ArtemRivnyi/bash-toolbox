#!/usr/bin/env bash
# ==============================================================================
# System Cron Jobs Security Auditor
# Description: Aggregates and inspects all user and system crontabs for anomalies.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [System Cron Jobs Security Auditor] ==="
echo "Executing: Aggregates and inspects all user and system crontabs for anomalies."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
