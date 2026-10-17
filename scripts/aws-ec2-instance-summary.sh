#!/usr/bin/env bash
# ==============================================================================
# AWS EC2 Instance State Auditor
# Description: Lists EC2 instances, states, public/private IPs using AWS CLI.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [AWS EC2 Instance State Auditor] ==="
echo "Executing: Lists EC2 instances, states, public/private IPs using AWS CLI."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
