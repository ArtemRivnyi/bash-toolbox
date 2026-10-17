#!/usr/bin/env bash
# Quick system health audit script
set -euo pipefail
echo "=== System Health Audit ==="
uptime
df -h /
free -m
