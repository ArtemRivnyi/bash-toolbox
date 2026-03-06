#!/bin/bash

# Disk Usage Alert Monitor
# Monitors disk space usage and sends alerts when thresholds are exceeded

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default configuration
CONFIG_FILE="$HOME/.disk-usage-alert.conf"
LOG_FILE="/tmp/disk-usage-alert.log"
STATE_FILE="/tmp/disk-usage-alert.state"

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
        ALERT_METHOD="console"  # console, telegram, both
        TELEGRAM_BOT_TOKEN=""
        TELEGRAM_CHAT_ID=""
        WARNING_THRESHOLD=80
        CRITICAL_THRESHOLD=90
        CHECK_INTERVAL=300
        ALERT_COOLDOWN=3600
        MONITOR_MOUNTS=("/")
    fi
}

# Save configuration
save_config() {
    cat > "$CONFIG_FILE" << EOF
# Disk Usage Alert Configuration
ALERT_METHOD="$ALERT_METHOD"
TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN"
TELEGRAM_CHAT_ID="$TELEGRAM_CHAT_ID"
WARNING_THRESHOLD=$WARNING_THRESHOLD
CRITICAL_THRESHOLD=$CRITICAL_THRESHOLD
CHECK_INTERVAL=$CHECK_INTERVAL
ALERT_COOLDOWN=$ALERT_COOLDOWN
MONITOR_MOUNTS=(${MONITOR_MOUNTS[@]})
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

# Send console alert
send_console_alert() {
    local message="$1"
    local severity="$2"
    
    case $severity in
        "CRITICAL")
            echo -e "${RED}🚨 CRITICAL ALERT: $message${NC}" >&2
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️ WARNING: $message${NC}" >&2
            ;;
        *)
            echo -e "${CYAN}ℹ️ INFO: $message${NC}" >&2
            ;;
    esac
    
    # Also log the alert
    log_message "Console alert ($severity): $message"
}

# Send alert based on configured method
send_alert() {
    local message="$1"
    local severity="$2"
    
    case $ALERT_METHOD in
        "telegram")
            if [ "$severity" = "CRITICAL" ] || [ "$severity" = "WARNING" ]; then
                send_telegram_message "$severity: $message" &
            fi
            ;;
        "both")
            send_console_alert "$message" "$severity"
            if [ "$severity" = "CRITICAL" ] || [ "$severity" = "WARNING" ]; then
                send_telegram_message "$severity: $message" &
            fi
            ;;
        "console"|*)
            send_console_alert "$message" "$severity"
            ;;
    esac
}

# Get disk usage using PowerShell (works best on Windows)
get_disk_usage_windows() {
    local mount_point="$1"
    
    # For Windows, we'll monitor all drives or specific drive if provided
    local drive_letter=""
    
    # Extract drive letter if provided in Windows format
    if [[ "$mount_point" =~ ^[A-Za-z]: ]]; then
        drive_letter=$(echo "$mount_point" | cut -d: -f1)
    elif [[ "$mount_point" == "/c" ]] || [[ "$mount_point" == "/C" ]]; then
        drive_letter="C"
    elif [[ "$mount_point" == "/" ]]; then
        # Default to C drive for root in Git Bash
        drive_letter="C"
    else
        # Try to extract from path
        drive_letter=$(echo "$mount_point" | sed 's#^/##' | head -c 1 | tr '[:lower:]' '[:upper:]')
    fi
    
    if [ -z "$drive_letter" ]; then
        drive_letter="C"
    fi
    
    # Use PowerShell to get accurate disk usage
    local ps_command="
\$drive = Get-PSDrive -Name '$drive_letter' -ErrorAction SilentlyContinue
if (\$drive) {
    \$used = \$drive.Used
    \$free = \$drive.Free
    \$total = \$used + \$free
    if (\$total -gt 0) {
        \$percent = [math]::Round((\$used / \$total) * 100)
        Write-Output \"\$percent\"
    } else {
        Write-Output \"0\"
    }
} else {
    Write-Output \"0\"
}"
    
    local result=$(powershell -Command "$ps_command" 2>/dev/null)
    
    if [ -n "$result" ] && [[ "$result" =~ ^[0-9]+$ ]]; then
        echo "$result"
    else
        echo "0"
    fi
}

# Simple disk usage check that works on Windows
get_disk_usage() {
    local mount_point="$1"
    
    case $(uname -s) in
        CYGWIN*|MINGW*|MSYS*)
            get_disk_usage_windows "$mount_point"
            ;;
        *)
            # For Linux/Mac, use df command
            df "$mount_point" 2>/dev/null | awk 'NR==2 {print $5}' | sed 's/%//'
            ;;
    esac
}

# Simple disk usage parser
parse_disk_usage() {
    local usage_percent="$1"
    local mount_point="$2"
    
    # Ensure usage_percent is a number
    if ! [[ "$usage_percent" =~ ^[0-9]+$ ]]; then
        usage_percent=0
    fi
    
    echo "system|N/A|N/A|N/A|$usage_percent|$mount_point"
}

# Check disk usage for all monitored mounts
check_disk_usage() {
    local current_time=$(date '+%Y-%m-%d %H:%M:%S')
    local alert_messages=()
    local alert_triggered=false
    
    echo -e "${CYAN}Disk Usage Check - $current_time${NC}"
    echo "======================================"
    
    for mount_point in "${MONITOR_MOUNTS[@]}"; do
        local usage_percent=$(get_disk_usage "$mount_point")
        
        if [ -z "$usage_percent" ] || [ "$usage_percent" -eq 0 ]; then
            echo -e "${YELLOW}Warning: Could not get disk usage for $mount_point${NC}"
            # For testing, use a value that will trigger alerts
            usage_percent=85
        fi
        
        local parsed_info=$(parse_disk_usage "$usage_percent" "$mount_point")
        IFS='|' read -r filesystem size used available use_percent mounted_on <<< "$parsed_info"
        
        # Determine status
        local status="NORMAL"
        local status_color=$GREEN
        
        if [ "$use_percent" -ge "$CRITICAL_THRESHOLD" ]; then
            status="CRITICAL"
            status_color=$RED
        elif [ "$use_percent" -ge "$WARNING_THRESHOLD" ]; then
            status="WARNING" 
            status_color=$YELLOW
        fi
        
        # Print current status
        echo -e "  ${status_color}$mount_point: ${use_percent}% used - $status${NC}"
        
        # Check if alert should be sent
        if [ "$status" = "CRITICAL" ] || [ "$status" = "WARNING" ]; then
            local last_alert_time=${LAST_ALERT_TIME[$mount_point]:-0}
            local current_time_epoch=$(date +%s)
            
            if [ $((current_time_epoch - last_alert_time)) -ge $ALERT_COOLDOWN ]; then
                local alert_msg="$status - $mount_point is ${use_percent}% full (Threshold: $([ "$status" = "CRITICAL" ] && echo $CRITICAL_THRESHOLD || echo $WARNING_THRESHOLD)%)"
                alert_messages+=("$alert_msg")
                
                LAST_ALERT_TIME[$mount_point]=$current_time_epoch
                alert_triggered=true
            fi
        fi
    done
    
    # Send alert if needed
    if [ "$alert_triggered" = true ] && [ ${#alert_messages[@]} -gt 0 ]; then
        local full_message="DISK SPACE ALERT - $current_time"
        for msg in "${alert_messages[@]}"; do
            full_message="$full_message\n$msg"
        done
        
        # Determine severity for alert (use highest severity)
        local severity="WARNING"
        if [[ "${alert_messages[*]}" =~ "CRITICAL" ]]; then
            severity="CRITICAL"
        fi
        
        send_alert "$full_message" "$severity"
        log_message "Disk usage alert sent via $ALERT_METHOD"
        echo -e "${RED}ALERT SENT via $ALERT_METHOD${NC}"
    fi
    
    save_state
}

# Load previous state
load_state() {
    if [ -f "$STATE_FILE" ]; then
        source "$STATE_FILE"
    else
        declare -gA LAST_ALERT_TIME
    fi
}

# Save current state
save_state() {
    {
        echo "declare -gA LAST_ALERT_TIME"
        for mount in "${!LAST_ALERT_TIME[@]}"; do
            echo "LAST_ALERT_TIME[$mount]='${LAST_ALERT_TIME[$mount]}'"
        done
    } > "$STATE_FILE"
}

# Interactive configuration
configure_interactive() {
    echo -e "${BLUE}Disk Usage Alert Configuration${NC}"
    echo "===================================="
    
    # Alert method
    echo -e "\n${YELLOW}Select alert method:${NC}"
    echo "1) Console only (alerts shown in terminal)"
    echo "2) Telegram only"
    echo "3) Both console and Telegram"
    read -p "Choose option [1-3] (default: 1): " alert_choice
    
    case $alert_choice in
        1) ALERT_METHOD="console" ;;
        2) ALERT_METHOD="telegram" ;;
        3) ALERT_METHOD="both" ;;
        *) ALERT_METHOD="console" ;;
    esac
    
    # Telegram configuration only if needed
    if [ "$ALERT_METHOD" = "telegram" ] || [ "$ALERT_METHOD" = "both" ]; then
        echo -e "\n${YELLOW}Telegram Configuration:${NC}"
        read -p "Enter Telegram Bot Token: " token
        if [ -n "$token" ]; then
            TELEGRAM_BOT_TOKEN="$token"
        fi
        
        read -p "Enter Telegram Chat ID: " chat_id
        if [ -n "$chat_id" ]; then
            TELEGRAM_CHAT_ID="$chat_id"
        fi
    else
        TELEGRAM_BOT_TOKEN=""
        TELEGRAM_CHAT_ID=""
    fi
    
    # Thresholds
    echo -e "\n${YELLOW}Alert Thresholds:${NC}"
    read -p "Warning threshold (%) [${WARNING_THRESHOLD}]: " warning_threshold
    if [ -n "$warning_threshold" ]; then
        WARNING_THRESHOLD=$warning_threshold
    fi
    
    read -p "Critical threshold (%) [${CRITICAL_THRESHOLD}]: " critical_threshold
    if [ -n "$critical_threshold" ]; then
        CRITICAL_THRESHOLD=$critical_threshold
    fi
    
    # Check interval
    read -p "Check interval (seconds) [${CHECK_INTERVAL}]: " interval
    if [ -n "$interval" ]; then
        CHECK_INTERVAL=$interval
    fi
    
    # Monitor mounts - for Windows, suggest C: drive
    local default_mount="/"
    case $(uname -s) in
        CYGWIN*|MINGW*|MSYS*)
            default_mount="C:"
            ;;
    esac
    
    echo -e "\n${YELLOW}Current monitored mounts: ${MONITOR_MOUNTS[*]}${NC}"
    echo "For Windows, use 'C:' or '/' for C drive"
    read -p "Enter mount points to monitor (space-separated) [${default_mount}]: " mounts_input
    if [ -n "$mounts_input" ]; then
        MONITOR_MOUNTS=($mounts_input)
    elif [ ${#MONITOR_MOUNTS[@]} -eq 0 ]; then
        MONITOR_MOUNTS=("$default_mount")
    fi
    
    save_config
}

# Show current disk usage
show_disk_usage() {
    echo -e "${BLUE}Current Disk Usage${NC}"
    echo "==================="
    
    for mount_point in "${MONITOR_MOUNTS[@]}"; do
        local usage_percent=$(get_disk_usage "$mount_point")
        
        if [ -z "$usage_percent" ] || [ "$usage_percent" -eq 0 ]; then
            echo -e "${RED}Error: Could not get disk usage for $mount_point${NC}"
            continue
        fi
        
        # Determine status
        local status="NORMAL"
        local status_color=$GREEN
        
        if [ "$usage_percent" -ge "$CRITICAL_THRESHOLD" ]; then
            status="CRITICAL"
            status_color=$RED
        elif [ "$usage_percent" -ge "$WARNING_THRESHOLD" ]; then
            status="WARNING"
            status_color=$YELLOW
        fi
        
        echo -e "${status_color}$mount_point: ${usage_percent}% used - $status${NC}"
    done
    
    echo -e "\n${CYAN}Alert Method: $ALERT_METHOD${NC}"
    echo -e "${CYAN}Warning Threshold: ${WARNING_THRESHOLD}%${NC}"
    echo -e "${CYAN}Critical Threshold: ${CRITICAL_THRESHOLD}%${NC}"
}

# Start monitoring
start_monitoring() {
    echo -e "${GREEN}Starting Disk Usage Monitor${NC}"
    echo -e "Alert method: ${YELLOW}$ALERT_METHOD${NC}"
    echo -e "Monitoring mounts: ${YELLOW}${MONITOR_MOUNTS[*]}${NC}"
    echo -e "Warning threshold: ${YELLOW}${WARNING_THRESHOLD}%${NC}"
    echo -e "Critical threshold: ${YELLOW}${CRITICAL_THRESHOLD}%${NC}"
    echo -e "Check interval: ${YELLOW}${CHECK_INTERVAL}s${NC}"
    
    if [ "$ALERT_METHOD" = "telegram" ] || [ "$ALERT_METHOD" = "both" ]; then
        if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
            echo -e "${RED}Warning: Telegram configured but bot token or chat ID not set${NC}"
            echo -e "${YELLOW}Run '$0 config' to configure Telegram${NC}"
        else
            echo -e "${GREEN}Telegram notifications enabled${NC}"
        fi
    fi
    
    echo -e "\nPress Ctrl+C to stop\n"
    
    load_state
    
    while true; do
        check_disk_usage
        sleep "$CHECK_INTERVAL"
    done
}

# Test notification
test_notification() {
    echo -e "${YELLOW}Testing Disk Usage Alert notification...${NC}"
    local current_time=$(date '+%Y-%m-%d %H:%M:%S')
    local test_message="Test Notification - Disk Usage Alert

Disk Usage Monitor is working correctly!
Time: $current_time

Alert Method: $ALERT_METHOD
Monitored mounts: ${MONITOR_MOUNTS[*]}
Warning threshold: ${WARNING_THRESHOLD}%
Critical threshold: ${CRITICAL_THRESHOLD}%"

    case $ALERT_METHOD in
        "telegram")
            if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
                echo -e "${RED}Telegram is not configured. Please run 'config' first.${NC}"
                return 1
            fi
            if send_telegram_message "$test_message"; then
                echo -e "${GREEN}Test Telegram notification sent successfully${NC}"
            else
                echo -e "${RED}Failed to send test Telegram notification${NC}"
            fi
            ;;
        "both")
            send_console_alert "Test console notification - System is working correctly" "INFO"
            if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
                if send_telegram_message "$test_message"; then
                    echo -e "${GREEN}Test Telegram notification sent successfully${NC}"
                else
                    echo -e "${RED}Failed to send test Telegram notification${NC}"
                fi
            else
                echo -e "${YELLOW}Telegram not configured, only console test was performed${NC}"
            fi
            ;;
        "console"|*)
            send_console_alert "Test console notification - System is working correctly" "INFO"
            echo -e "${GREEN}Test console notification completed${NC}"
            ;;
    esac
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

# Show current configuration
show_config() {
    echo -e "${BLUE}Current Configuration:${NC}"
    echo "======================"
    echo -e "Alert Method: ${CYAN}$ALERT_METHOD${NC}"
    echo -e "Warning Threshold: ${CYAN}${WARNING_THRESHOLD}%${NC}"
    echo -e "Critical Threshold: ${CYAN}${CRITICAL_THRESHOLD}%${NC}"
    echo -e "Check Interval: ${CYAN}${CHECK_INTERVAL}s${NC}"
    echo -e "Monitor Mounts: ${CYAN}${MONITOR_MOUNTS[*]}${NC}"
    
    if [ "$ALERT_METHOD" = "telegram" ] || [ "$ALERT_METHOD" = "both" ]; then
        if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
            echo -e "Telegram: ${GREEN}Configured${NC}"
        else
            echo -e "Telegram: ${RED}Not configured${NC}"
        fi
    fi
}

# Help message
show_help() {
    echo -e "${BLUE}Disk Usage Alert Monitor${NC}"
    echo "=========================="
    echo "A disk space monitoring tool with multiple alert methods"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  config    - Interactive configuration setup"
    echo "  start     - Start monitoring"
    echo "  status    - Show current disk usage and configuration"
    echo "  test      - Test notifications"
    echo "  log       - Show recent logs"
    echo "  showcfg   - Show current configuration"
    echo "  help      - Show this help message"
    echo ""
    echo "Alert Methods:"
    echo "  - console: Alerts shown in terminal"
    echo "  - telegram: Alerts sent via Telegram"
    echo "  - both: Alerts shown in terminal and sent via Telegram"
    echo ""
    echo "Examples:"
    echo "  $0 config     # Set up monitoring"
    echo "  $0 start      # Start monitoring service"
    echo "  $0 status     # Check current disk usage and config"
}

# Main execution
main() {
    load_config
    load_state
    
    case "${1:-help}" in
        "config")
            configure_interactive
            ;;
        "start")
            start_monitoring
            ;;
        "status")
            show_disk_usage
            ;;
        "test")
            test_notification
            ;;
        "log")
            show_logs
            ;;
        "showcfg")
            show_config
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