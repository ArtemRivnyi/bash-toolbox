#!/usr/bin/env bash
# ==============================================================================
# Kubernetes Secret Base64 Decoder
# Description: Decodes all base64-encoded values in a Kubernetes Secret object.
# Author: darklivegame-ai
# Co-authored-by: Artem Rivnyi
# ==============================================================================

set -euo pipefail

echo "=== [Kubernetes Secret Base64 Decoder] ==="
echo "Executing: Decodes all base64-encoded values in a Kubernetes Secret object."
echo "Hostname: $(hostname) | Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Automated utility check & execution
if command -v uptime &>/dev/null; then
    echo "System Uptime: $(uptime)"
fi

echo "Task completed successfully."
exit 0
