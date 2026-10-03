#!/usr/bin/env bash
# Network latency and DNS check utility
set -euo pipefail

TARGET="${1:-1.1.1.1}"
echo "Checking network connectivity to $TARGET..."
ping -c 3 "$TARGET"
echo "DNS lookup check for google.com..."
nslookup google.com || dig google.com +short
echo "Network check completed successfully."
