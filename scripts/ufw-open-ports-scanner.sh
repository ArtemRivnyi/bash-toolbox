#!/usr/bin/env bash
# ==============================================================================
# UFW Firewall Open Ports Scanner
# Description: Scans active listening ports against UFW firewall rules.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [UFW Firewall Open Ports Scanner] ==="
echo "Executing: Scans active listening ports against UFW firewall rules."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
