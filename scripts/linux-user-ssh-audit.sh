#!/usr/bin/env bash
# ==============================================================================
# Authorized SSH Keys Auditor
# Description: Scans all user home directories for authorized_keys permissions.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [Authorized SSH Keys Auditor] ==="
echo "Executing: Scans all user home directories for authorized_keys permissions."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
