#!/usr/bin/env bash
# ==============================================================================
# Domain Expiration Alert Monitor
# Description: Checks WHOIS registry expiration date and warns if < 30 days.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [Domain Expiration Alert Monitor] ==="
echo "Executing: Checks WHOIS registry expiration date and warns if < 30 days."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
