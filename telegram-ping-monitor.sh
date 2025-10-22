#!/bin/bash

# Telegram Bot Configuration
TELEGRAM_BOT_TOKEN="YOUR_BOT_TOKEN"
TELEGRAM_CHAT_ID="YOUR_CHAT_ID"
HOST_TO_PING="8.8.8.8"
CHECK_INTERVAL=60
FAILURE_THRESHOLD=3

# Counters
failure_count=0

send_telegram_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$message" \
        -d parse_mode="Markdown" > /dev/null
}

check_connectivity() {
    if ping -c 2 -W 3 "$HOST_TO_PING" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Initial setup message
send_telegram_message "🔍 *Ping Monitor Started* 
Monitoring: \`$HOST_TO_PING\`
Interval: ${CHECK_INTERVAL}s"

echo "🔍 Starting ping monitor for $HOST_TO_PING..."

while true; do
    if ! check_connectivity; then
        ((failure_count++))
        echo "❌ Ping failed ($failure_count/$FAILURE_THRESHOLD)"
        
        if [ $failure_count -ge $FAILURE_THRESHOLD ]; then
            echo "🚨 Sending Telegram alert..."
            send_telegram_message "🚨 *Connectivity Alert* 
Host: \`$HOST_TO_PING\` is unreachable!
Failures: $failure_count consecutive
Time: $(date '+%Y-%m-%d %H:%M:%S')"
            
            # Reset counter after alert
            failure_count=0
        fi
    else
        if [ $failure_count -gt 0 ]; then
            echo "✅ Connectivity restored"
            send_telegram_message "✅ *Connectivity Restored* 
Host: \`$HOST_TO_PING\` is now reachable
Time: $(date '+%Y-%m-%d %H:%M:%S')"
            failure_count=0
        fi
    fi
    
    sleep $CHECK_INTERVAL
done