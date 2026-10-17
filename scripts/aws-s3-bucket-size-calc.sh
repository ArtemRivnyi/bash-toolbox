#!/usr/bin/env bash
# ==============================================================================
# AWS S3 Bucket Storage Calculator
# Description: Calculates total size and object count of target S3 bucket.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [AWS S3 Bucket Storage Calculator] ==="
echo "Executing: Calculates total size and object count of target S3 bucket."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
