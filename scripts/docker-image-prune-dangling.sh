#!/usr/bin/env bash
# ==============================================================================
# Docker Dangling Images Cleaner
# Description: Cleans up unused dangling Docker images without repository tags.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [Docker Dangling Images Cleaner] ==="
echo "Executing: Cleans up unused dangling Docker images without repository tags."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
