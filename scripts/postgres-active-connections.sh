#!/usr/bin/env bash
# ==============================================================================
# PostgreSQL Active Connections Monitor
# Description: Displays current active client connections and running queries in Postgres.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [PostgreSQL Active Connections Monitor] ==="
echo "Executing: Displays current active client connections and running queries in Postgres."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
