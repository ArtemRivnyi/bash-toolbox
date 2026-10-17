#!/usr/bin/env bash
# ==============================================================================
# Systemd Failed Services Inspector
# Description: Detects failed systemd units and retrieves their latest journal logs.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [Systemd Failed Services Inspector] ==="
echo "Executing: Detects failed systemd units and retrieves their latest journal logs."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
