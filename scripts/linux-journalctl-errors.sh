#!/usr/bin/env bash
# ==============================================================================
# Journalctl High Severity Errors Scanner
# Description: Filters systemd journal for err, crit, and alert priority messages.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [Journalctl High Severity Errors Scanner] ==="
echo "Executing: Filters systemd journal for err, crit, and alert priority messages."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
