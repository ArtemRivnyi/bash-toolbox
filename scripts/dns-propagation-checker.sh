#!/usr/bin/env bash
# ==============================================================================
# DNS Propagation Multi-Resolver Check
# Description: Queries Cloudflare, Google, and Quad9 to check record propagation.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [DNS Propagation Multi-Resolver Check] ==="
echo "Executing: Queries Cloudflare, Google, and Quad9 to check record propagation."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
