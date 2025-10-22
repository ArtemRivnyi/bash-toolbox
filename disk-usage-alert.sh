#!/bin/bash

# Disk usage monitor
THRESHOLD=80
ALERT_FILE="/tmp/disk_alert_sent"

check_disk_usage() {
    df -h | awk 'NR>1 {print $5 " " $6}' | while read output; do
        usage=$(echo $output | awk '{print $1}' | sed 's/%//g')
        mount=$(echo $output | awk '{print $2}')
        
        if [ $usage -ge $THRESHOLD ]; then
            echo "🚨 High disk usage on $mount: $usage%"
            
            # Send alert only once
            if [ ! -f "$ALERT_FILE" ]; then
                send_alert "$mount" "$usage"
                touch "$ALERT_FILE"
            fi
        else
            # Clear alert if usage drops below threshold
            if [ -f "$ALERT_FILE" ] && [ $usage -lt $((THRESHOLD-5)) ]; then
                echo "✅ Disk usage normalized on $mount: $usage%"
                rm -f "$ALERT_FILE"
            fi
        fi
    done
}

send_alert() {
    local mount=$1 usage=$2
    echo "ALERT: High disk usage on $mount - $usage%" | \
    mail -s "Disk Usage Alert on $(hostname)" root
    
    # Could also integrate with Telegram script
    echo "📧 Alert sent for $mount ($usage%)"
}

# Main
echo "💾 Checking disk usage (Threshold: ${THRESHOLD}%)..."
check_disk_usage