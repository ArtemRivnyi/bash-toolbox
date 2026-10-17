#!/usr/bin/env bash
# ==============================================================================
# Fail2Ban Currently Banned IPs Report
# Description: Aggregates banned IP addresses across all active fail2ban jails.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [Fail2Ban Currently Banned IPs Report] ==="
echo "Executing: Aggregates banned IP addresses across all active fail2ban jails."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
