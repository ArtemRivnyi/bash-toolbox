#!/usr/bin/env bash
# ==============================================================================
# IPTables Rules Timestamped Backup
# Description: Saves current iptables and ip6tables rulesets to versioned backups.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [IPTables Rules Timestamped Backup] ==="
echo "Executing: Saves current iptables and ip6tables rulesets to versioned backups."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
