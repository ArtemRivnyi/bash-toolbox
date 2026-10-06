#!/usr/bin/env bash
# Nginx access log parser for top client IPs and status codes
set -euo pipefail
LOG_FILE="${1:-/var/log/nginx/access.log}"
echo "Analyzing $LOG_FILE..."
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 10
