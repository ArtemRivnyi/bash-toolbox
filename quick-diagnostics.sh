#!/usr/bin/env bash
# ==============================================================================
# quick-diagnostics.sh - Rapid System Health Assessment Utility
# ==============================================================================
# Part of bash-toolbox (https://github.com/ArtemRivnyi/bash-toolbox)
# Lightweight diagnostics tool reporting CPU, RAM, Disk, and Network health.
# ==============================================================================

set -euo pipefail

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

log_info() {
    printf "${GREEN}[OK]${RESET} %s\n" "$1"
}

log_warn() {
    printf "${YELLOW}[WARN]${RESET} %s\n" "$1"
}

log_error() {
    printf "${RED}[FAIL]${RESET} %s\n" "$1"
}

print_header() {
    echo -e "\n${BOLD}=== $1 ===${RESET}"
}

print_header "System Overview"
echo "Hostname: $(hostname)"
echo "Kernel:   $(uname -r)"
echo "Uptime:   $(uptime -p 2>/dev/null || uptime)"

print_header "Memory Health"
if command -v free >/dev/null 2>&1; then
    free -h
    MEM_AVAIL=$(free | awk '/Mem:/ { printf("%.0f"), ($7/$2) * 100 }')
    if [ "$MEM_AVAIL" -lt 10 ]; then
        log_warn "Available memory is low (<10% available: ${MEM_AVAIL}%)"
    else
        log_info "Memory availability healthy (${MEM_AVAIL}% available)"
    fi
else
    echo "free command not available"
fi

print_header "Disk Space"
df -h --output=source,pcent,target -x tmpfs -x devtmpfs 2>/dev/null || df -h

print_header "Network Connectivity"
if ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
    log_info "External IP connectivity verified (1.1.1.1 reachable)"
else
    log_warn "Cannot reach external DNS/IP"
fi

echo -e "\n${GREEN}Diagnostics completed successfully.${RESET}"
