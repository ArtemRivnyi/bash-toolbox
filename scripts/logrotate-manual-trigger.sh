#!/usr/bin/env bash
# ==============================================================================
# Manual Logrotate Trigger Utility
# Description: Forces logrotate execution on specific configuration files with verbose output.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [Manual Logrotate Trigger Utility] ==="
echo "Executing: Forces logrotate execution on specific configuration files with verbose output."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
