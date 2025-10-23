#!/bin/bash

# Telegram Ping Monitor
# Monitors host availability and sends Telegram notifications on status changes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default configuration
CONFIG_FILE="$HOME/.telegram-ping-monitor.conf"
LOG_FILE="/tmp/telegram-ping-monitor.log"
STATE_FILE="/tmp/telegram-ping-monitor.state"

# Logging function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        log_message "Configuration loaded from $CONFIG_FILE"
    else
        # Set defaults
        TELEGRAM_BOT_TOKEN=""
        TELEGRAM_CHAT_ID=""
        MONITOR_HOSTS=("8.8.8.8" "1.1.1.1")
        CHECK_INTERVAL=60
        ALERT_COOLDOWN=300
        PING_TIMEOUT=5
        PING_COUNT=3
    fi
}

# Save configuration
save_config() {
    cat > "$CONFIG_FILE" << EOF
# Telegram Ping Monitor Configuration
TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN"
TELEGRAM_CHAT_ID="$TELEGRAM_CHAT_ID"
MONITOR_HOSTS=(${MONITOR_HOSTS[@]})
CHECK_INTERVAL=$CHECK_INTERVAL
ALERT_COOLDOWN=$ALERT_COOLDOWN
PING_TIMEOUT=$PING_TIMEOUT
PING_COUNT=$PING_COUNT
EOF
    echo -e "${GREEN}Configuration saved to $CONFIG_FILE${NC}"
}

# Send Telegram message
send_telegram_message() {
    local message="$1"
    
    if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
        log_message "ERROR: Telegram bot token or chat ID not set"
        return 1
    fi
    
    local telegram_url="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"
    
    # Простое текстовое сообщение без разметки
    if command -v curl >/dev/null 2>&1; then
        curl -s -X POST "$telegram_url" \
            -d chat_id="$TELEGRAM_CHAT_ID" \
            -d text="$message" >/dev/null
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O- --post-data="chat_id=$TELEGRAM_CHAT_ID&text=$message" \
            "$telegram_url" >/dev/null
    else
        log_message "ERROR: Neither curl nor wget available for Telegram notifications"
        return 1
    fi
    
    if [ $? -eq 0 ]; then
        log_message "Telegram notification sent: ${message:0:50}..."
        return 0
    else
        log_message "ERROR: Failed to send Telegram notification"
        return 1
    fi
}

# Check host availability
check_host() {
    local host="$1"
    local success_count=0
    
    # Determine ping command based on OS
    local ping_cmd="ping"
    local ping_args=""
    
    case $(uname -s) in
        Linux*)
            ping_args="-c $PING_COUNT -W $PING_TIMEOUT"
            ;;
        Darwin*)
            ping_args="-c $PING_COUNT -t $PING_TIMEOUT"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            ping_args="-n $PING_COUNT -w $((PING_TIMEOUT * 1000))"
            ;;
        *)
            ping_args="-c $PING_COUNT -W $PING_TIMEOUT"
            ;;
    esac
    
    for i in $(seq 1 $PING_COUNT); do
        if $ping_cmd $ping_args "$host" >/dev/null 2>&1; then
            ((success_count++))
        fi
        sleep 1
    done
    
    if [ $success_count -eq $PING_COUNT ]; then
        echo "up"
    elif [ $success_count -gt 0 ]; then
        echo "degraded"
    else
        echo "down"
    fi
}

# Get host status text
get_status_text() {
    case "$1" in
        "up") echo "UP" ;;
        "degraded") echo "DEGRADED" ;;
        "down") echo "DOWN" ;;
        *) echo "UNKNOWN" ;;
    esac
}

# Load previous state
load_state() {
    if [ -f "$STATE_FILE" ]; then
        source "$STATE_FILE"
    else
        declare -gA HOST_STATE
        declare -gA LAST_ALERT_TIME
    fi
}

# Save current state
save_state() {
    {
        echo "declare -gA HOST_STATE"
        echo "declare -gA LAST_ALERT_TIME"
        for host in "${!HOST_STATE[@]}"; do
            echo "HOST_STATE[$host]='${HOST_STATE[$host]}'"
        done
        for host in "${!LAST_ALERT_TIME[@]}"; do
            echo "LAST_ALERT_TIME[$host]='${LAST_ALERT_TIME[$host]}'"
        done
    } > "$STATE_FILE"
}

# Check if alert should be sent (cooldown period)
should_alert() {
    local host="$1"
    local current_time=$(date +%s)
    local last_alert_time=${LAST_ALERT_TIME[$host]:-0}
    
    if [ $((current_time - last_alert_time)) -ge $ALERT_COOLDOWN ]; then
        LAST_ALERT_TIME[$host]=$current_time
        return 0
    else
        return 1
    fi
}

# Monitor all hosts
monitor_hosts() {
    local current_time=$(date '+%Y-%m-%d %H:%M:%S')
    local status_message="Monitoring Report - $current_time

"
    local alert_triggered=false
    
    for host in "${MONITOR_HOSTS[@]}"; do
        local previous_state="${HOST_STATE[$host]:-unknown}"
        local current_state=$(check_host "$host")
        local status_text=$(get_status_text "$current_state")
        
        HOST_STATE[$host]="$current_state"
        
        # Build status message
        status_message="$status_message$status_text - $host"
        if [ "$previous_state" != "unknown" ] && [ "$previous_state" != "$current_state" ]; then
            status_message="$status_message (was: $previous_state)"
        fi
        status_message="$status_message
"
        
        # Check if alert should be sent
        if [ "$current_state" != "up" ] && [ "$previous_state" = "up" ]; then
            if should_alert "$host"; then
                local alert_message="ALERT - Host Down

$host is $current_state
Time: $current_time
Previous state: $previous_state"
                send_telegram_message "$alert_message" &
                alert_triggered=true
            fi
        elif [ "$current_state" = "up" ] && [ "$previous_state" != "up" ] && [ "$previous_state" != "unknown" ]; then
            if should_alert "$host"; then
                local recovery_message="RECOVERY - Host Back Online

$host is back online
Time: $current_time
Previous state: $previous_state"
                send_telegram_message "$recovery_message" &
                alert_triggered=true
            fi
        fi
    done
    
    # Send status summary (only if there are changes or first run)
    if [ $alert_triggered = true ] || [ "${FIRST_RUN:-true}" = "true" ]; then
        send_telegram_message "$status_message" &
        FIRST_RUN=false
    fi
    
    save_state
}

# Interactive configuration
configure_interactive() {
    echo -e "${BLUE}Telegram Ping Monitor Configuration${NC}"
    echo "========================================"
    
    # Telegram Bot Token
    read -p "Enter Telegram Bot Token: " token
    if [ -n "$token" ]; then
        TELEGRAM_BOT_TOKEN="$token"
    fi
    
    # Telegram Chat ID
    read -p "Enter Telegram Chat ID: " chat_id
    if [ -n "$chat_id" ]; then
        TELEGRAM_CHAT_ID="$chat_id"
    fi
    
    # Monitor Hosts
    echo -e "\n${YELLOW}Current monitored hosts: ${MONITOR_HOSTS[*]}${NC}"
    read -p "Enter hosts to monitor (space-separated, empty to keep current): " hosts_input
    if [ -n "$hosts_input" ]; then
        MONITOR_HOSTS=($hosts_input)
    fi
    
    # Check Interval
    read -p "Check interval in seconds [${CHECK_INTERVAL}]: " interval
    if [ -n "$interval" ]; then
        CHECK_INTERVAL=$interval
    fi
    
    save_config
}

# Show status
show_status() {
    echo -e "${BLUE}Telegram Ping Monitor Status${NC}"
    echo "=================================="
    
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${GREEN}Configuration: $CONFIG_FILE${NC}"
    else
        echo -e "${YELLOW}Configuration: Not set up${NC}"
    fi
    
    if [ -f "$STATE_FILE" ]; then
        echo -e "${GREEN}State file: $STATE_FILE${NC}"
        load_state
        echo -e "\n${CYAN}Current Host Status:${NC}"
        for host in "${MONITOR_HOSTS[@]}"; do
            local state="${HOST_STATE[$host]:-unknown}"
            local status_text=$(get_status_text "$state")
            echo -e "  $status_text - $host"
        done
    else
        echo -e "${YELLOW}State file: Not found${NC}"
    fi
    
    echo -e "\n${CYAN}Log file: $LOG_FILE${NC}"
    if [ -f "$LOG_FILE" ]; then
        tail -5 "$LOG_FILE" | while read line; do
            echo "  $line"
        done
    fi
}

# Start monitoring
start_monitoring() {
    echo -e "${GREEN}Starting Telegram Ping Monitor${NC}"
    echo -e "Monitoring hosts: ${YELLOW}${MONITOR_HOSTS[*]}${NC}"
    echo -e "Check interval: ${YELLOW}${CHECK_INTERVAL}s${NC}"
    echo -e "Press Ctrl+C to stop\n"
    
    load_state
    FIRST_RUN=true
    
    while true; do
        monitor_hosts
        sleep "$CHECK_INTERVAL"
    done
}

# Help message
show_help() {
    echo -e "${BLUE}Telegram Ping Monitor${NC}"
    echo "========================"
    echo "A host monitoring tool with Telegram notifications"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  config    - Interactive configuration setup"
    echo "  start     - Start monitoring"
    echo "  status    - Show current status"
    echo "  test      - Test Telegram notification"
    echo "  log       - Show recent logs"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 config     # Set up monitoring"
    echo "  $0 start      # Start monitoring service"
    echo "  $0 status     # Check current status"
}

# Test notification
test_notification() {
    echo -e "${YELLOW}Testing Telegram notification...${NC}"
    local current_time=$(date '+%Y-%m-%d %H:%M:%S')
    local test_message="Test Notification

Telegram Ping Monitor is working correctly!
Time: $current_time

Hosts: ${MONITOR_HOSTS[*]}
Interval: ${CHECK_INTERVAL}s"

    if send_telegram_message "$test_message"; then
        echo -e "${GREEN}Test notification sent successfully${NC}"
    else
        echo -e "${RED}Failed to send test notification${NC}"
    fi
}

# Show logs
show_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo -e "${BLUE}Recent logs:${NC}"
        tail -20 "$LOG_FILE"
    else
        echo -e "${YELLOW}No log file found${NC}"
    fi
}

# Main execution
main() {
    load_config
    
    case "${1:-help}" in
        "config")
            configure_interactive
            ;;
        "start")
            start_monitoring
            ;;
        "status")
            show_status
            ;;
        "test")
            test_notification
            ;;
        "log")
            show_logs
            ;;
        "help")
            show_help
            ;;
        *)
            echo -e "${RED}Unknown command: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"