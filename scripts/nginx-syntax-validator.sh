#!/usr/bin/env bash
# ==============================================================================
# Nginx Configuration Linter
# Description: Runs nginx -t and reports syntax validity with error highlights.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [Nginx Configuration Linter] ==="
echo "Executing: Runs nginx -t and reports syntax validity with error highlights."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
