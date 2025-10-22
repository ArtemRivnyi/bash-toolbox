#!/bin/bash

# Services to monitor
SERVICES=("nginx" "mysql" "ssh" "cron")

check_service() {
    local service=$1
    if systemctl is-active --quiet "$service"; then
        echo "✅ $service is running"
        return 0
    else
        echo "❌ $service is not running"
        return 1
    fi
}

restart_service() {
    local service=$1
    echo "🔄 Attempting to restart $service..."
    if sudo systemctl restart "$service"; then
        echo "✅ $service restarted successfully"
        return 0
    else
        echo "❌ Failed to restart $service"
        return 1
    fi
}

# Main execution
echo "🔍 Service Health Check - $(date)"

for service in "${SERVICES[@]}"; do
    if ! check_service "$service"; then
        echo "⚠️ $service is down, attempting recovery..."
        restart_service "$service"
    fi
done