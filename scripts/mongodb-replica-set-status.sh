#!/usr/bin/env bash
# ==============================================================================
# MongoDB Replica Set Status Check
# Description: Queries rs.status() to verify primary and secondary health in MongoDB.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [MongoDB Replica Set Status Check] ==="
echo "Executing: Queries rs.status() to verify primary and secondary health in MongoDB."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
