#!/bin/bash

# System Monitoring Script - Cross-platform compatible with Telegram Integration
# Monitors CPU, RAM, and Disk usage with flexible alert methods

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
CONFIG_FILE="$HOME/.system-monitor.conf"
LOG_FILE="/tmp/system-monitor.log"
STATE_FILE="/tmp/system-monitor.state"

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux" ;;
        Darwin*)    echo "macos" ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

OS_TYPE=$(detect_os)

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

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
        CHECK_INTERVAL=300
        ALERT_COOLDOWN=900
        # Thresholds
        CPU_WARNING=60
        CPU_CRITICAL=85
        RAM_WARNING=70
        RAM_CRITICAL=90
        DISK_WARNING=75
        DISK_CRITICAL=90
    fi
}

# Save configuration
save_config() {
    cat > "$CONFIG_FILE" << EOF
# System Monitor Configuration
ALERT_METHOD="$ALERT_METHOD"
TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN"
TELEGRAM_CHAT_ID="$TELEGRAM_CHAT_ID"
CHECK_INTERVAL=$CHECK_INTERVAL
ALERT_COOLDOWN=$ALERT_COOLDOWN
CPU_WARNING=$CPU_WARNING
CPU_CRITICAL=$CPU_CRITICAL
RAM_WARNING=$RAM_WARNING
RAM_CRITICAL=$RAM_CRITICAL
DISK_WARNING=$DISK_WARNING
DISK_CRITICAL=$DISK_CRITICAL
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
    
    if command_exists curl; then
        curl -s -X POST "$telegram_url" \
            -d chat_id="$TELEGRAM_CHAT_ID" \
            -d text="$message" >/dev/null
    elif command_exists wget; then
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
            echo -e "${RED}🚨 CRITICAL: $message${NC}" >&2
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  WARNING: $message${NC}" >&2
            ;;
        "RECOVERY")
            echo -e "${GREEN}✅ RECOVERY: $message${NC}" >&2
            ;;
        *)
            echo -e "${CYAN}ℹ️  INFO: $message${NC}" >&2
            ;;
    esac
    
    log_message "Console alert ($severity): $message"
}

# Send alert based on configured method
send_alert() {
    local message="$1"
    local severity="$2"
    
    case $ALERT_METHOD in
        "telegram")
            if [ "$severity" = "CRITICAL" ] || [ "$severity" = "WARNING" ] || [ "$severity" = "RECOVERY" ]; then
                send_telegram_message "$severity: $message" &
            fi
            ;;
        "both")
            send_console_alert "$message" "$severity"
            if [ "$severity" = "CRITICAL" ] || [ "$severity" = "WARNING" ] || [ "$severity" = "RECOVERY" ]; then
                send_telegram_message "$severity: $message" &
            fi
            ;;
        "console"|*)
            send_console_alert "$message" "$severity"
            ;;
    esac
}

# Compare floats (for alerts)
float_compare() {
    local value=$1
    local threshold=$2
    value=$(echo "$value" | tr ',' '.')
    threshold=$(echo "$threshold" | tr ',' '.')
    if command_exists awk; then
        echo $(awk -v a="$value" -v b="$threshold" 'BEGIN {print (a > b) ? 1 : 0}')
    else
        [ "${value%.*}" -gt "${threshold%.*}" ] && echo 1 || echo 0
    fi
}

# Get Windows CPU usage
get_windows_cpu_usage() {
    local cpu_usage="N/A"
    local pwsh_path="/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

    if [ -x "$pwsh_path" ]; then
        cpu_usage=$("$pwsh_path" -Command "
            try {
                \$cpu = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
                if (\$cpu -gt 0) { [math]::Round(\$cpu) } else { 0 }
            } catch {
                try {
                    \$wmi = (Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
                    if (\$wmi -gt 0) { [math]::Round(\$wmi) } else { 0 }
                } catch { 0 }
            }
        " 2>/dev/null | tr -d '\r' | tr -d ' ')
    fi

    if [ -z "$cpu_usage" ] || [ "$cpu_usage" = "0" ]; then
        cpu_usage="N/A"
    fi

    echo "$cpu_usage"
}

# Get system metrics
get_metrics() {
    case $OS_TYPE in
        "linux")
            CPU_USAGE=$(top -bn1 | awk '/Cpu/ {print 100 - $8}' | head -n 1)
            MEM_USAGE=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
            DISK_USAGE=$(df / | awk 'NR==2{print $5}' | sed 's/%//')
            LOAD_AVG=$(awk '{print $1}' /proc/loadavg)
            ;;
        "macos")
            CPU_USAGE=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
            MEM_USAGE="N/A"
            DISK_USAGE=$(df / | awk 'NR==2{print $5}' | sed 's/%//')
            LOAD_AVG=$(sysctl -n vm.loadavg | awk '{print $2}')
            ;;
        "windows")
            CPU_USAGE=$(get_windows_cpu_usage)
            local pwsh="/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

            if [ -x "$pwsh" ]; then
                MEM_USAGE=$("$pwsh" -Command "
                    [System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::InvariantCulture;
                    \$os = Get-WmiObject Win32_OperatingSystem;
                    \$t = \$os.TotalVisibleMemorySize; \$f = \$os.FreePhysicalMemory;
                    if (\$t -gt 0) { [math]::Round((\$t - \$f) * 100 / \$t, 1) }
                " 2>/dev/null | tr -d '\r')

                DISK_USAGE=$("$pwsh" -Command "
                    [System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::InvariantCulture;
                    \$disk = Get-WmiObject Win32_LogicalDisk -Filter \"DeviceID='C:'\";
                    if (\$disk.Size -gt 0) { [math]::Round((\$disk.Size - \$disk.FreeSpace) * 100 / \$disk.Size) }
                " 2>/dev/null | tr -d '\r')
            fi

            [ -z "$MEM_USAGE" ] && MEM_USAGE="N/A"
            [ -z "$DISK_USAGE" ] && DISK_USAGE="N/A"
            LOAD_AVG=""
            ;;
        *)
            CPU_USAGE="N/A"; MEM_USAGE="N/A"; DISK_USAGE="N/A"; LOAD_AVG="N/A"
            ;;
    esac

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
}

# Load previous state
load_state() {
    if [ -f "$STATE_FILE" ]; then
        source "$STATE_FILE"
    else
        declare -gA LAST_ALERT_TIME
        declare -g LAST_CPU_STATE="normal"
        declare -g LAST_RAM_STATE="normal"
        declare -g LAST_DISK_STATE="normal"
    fi
}

# Save current state
save_state() {
    {
        echo "declare -gA LAST_ALERT_TIME"
        for metric in "${!LAST_ALERT_TIME[@]}"; do
            echo "LAST_ALERT_TIME[$metric]='${LAST_ALERT_TIME[$metric]}'"
        done
        echo "LAST_CPU_STATE='$LAST_CPU_STATE'"
        echo "LAST_RAM_STATE='$LAST_RAM_STATE'"
        echo "LAST_DISK_STATE='$LAST_DISK_STATE'"
    } > "$STATE_FILE"
}

# Check if alert should be sent (cooldown period)
should_alert() {
    local metric="$1"
    local current_time=$(date +%s)
    local last_alert_time=${LAST_ALERT_TIME[$metric]:-0}
    
    if [ $((current_time - last_alert_time)) -ge $ALERT_COOLDOWN ]; then
        LAST_ALERT_TIME[$metric]=$current_time
        return 0
    else
        return 1
    fi
}

# Determine metric state
get_metric_state() {
    local value="$1"
    local warning="$2"
    local critical="$3"
    
    if [[ ! "$value" =~ ^[0-9.]+$ ]]; then
        echo "unknown"
        return
    fi
    
    if [ $(float_compare "$value" "$critical") -eq 1 ]; then
        echo "critical"
    elif [ $(float_compare "$value" "$warning") -eq 1 ]; then
        echo "warning"
    else
        echo "normal"
    fi
}

# Check metrics and send alerts if needed
check_and_alert() {
    local current_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Check CPU
    if [[ "$CPU_USAGE" =~ ^[0-9.]+$ ]]; then
        local cpu_state=$(get_metric_state "$CPU_USAGE" "$CPU_WARNING" "$CPU_CRITICAL")
        
        if [ "$cpu_state" = "critical" ] && [ "$LAST_CPU_STATE" != "critical" ]; then
            if should_alert "cpu"; then
                send_alert "CPU usage is CRITICAL: ${CPU_USAGE}% (threshold: ${CPU_CRITICAL}%)" "CRITICAL"
            fi
        elif [ "$cpu_state" = "warning" ] && [ "$LAST_CPU_STATE" = "normal" ]; then
            if should_alert "cpu"; then
                send_alert "CPU usage is HIGH: ${CPU_USAGE}% (threshold: ${CPU_WARNING}%)" "WARNING"
            fi
        elif [ "$cpu_state" = "normal" ] && [ "$LAST_CPU_STATE" != "normal" ]; then
            send_alert "CPU usage returned to normal: ${CPU_USAGE}%" "RECOVERY"
        fi
        
        LAST_CPU_STATE="$cpu_state"
    fi
    
    # Check RAM
    if [[ "$MEM_USAGE" =~ ^[0-9.]+$ ]]; then
        local ram_state=$(get_metric_state "$MEM_USAGE" "$RAM_WARNING" "$RAM_CRITICAL")
        
        if [ "$ram_state" = "critical" ] && [ "$LAST_RAM_STATE" != "critical" ]; then
            if should_alert "ram"; then
                send_alert "RAM usage is CRITICAL: ${MEM_USAGE}% (threshold: ${RAM_CRITICAL}%)" "CRITICAL"
            fi
        elif [ "$ram_state" = "warning" ] && [ "$LAST_RAM_STATE" = "normal" ]; then
            if should_alert "ram"; then
                send_alert "RAM usage is HIGH: ${MEM_USAGE}% (threshold: ${RAM_WARNING}%)" "WARNING"
            fi
        elif [ "$ram_state" = "normal" ] && [ "$LAST_RAM_STATE" != "normal" ]; then
            send_alert "RAM usage returned to normal: ${MEM_USAGE}%" "RECOVERY"
        fi
        
        LAST_RAM_STATE="$ram_state"
    fi
    
    # Check Disk
    if [[ "$DISK_USAGE" =~ ^[0-9.]+$ ]]; then
        local disk_state=$(get_metric_state "$DISK_USAGE" "$DISK_WARNING" "$DISK_CRITICAL")
        
        if [ "$disk_state" = "critical" ] && [ "$LAST_DISK_STATE" != "critical" ]; then
            if should_alert "disk"; then
                send_alert "Disk usage is CRITICAL: ${DISK_USAGE}% (threshold: ${DISK_CRITICAL}%)" "CRITICAL"
            fi
        elif [ "$disk_state" = "warning" ] && [ "$LAST_DISK_STATE" = "normal" ]; then
            if should_alert "disk"; then
                send_alert "Disk usage is HIGH: ${DISK_USAGE}% (threshold: ${DISK_WARNING}%)" "WARNING"
            fi
        elif [ "$disk_state" = "normal" ] && [ "$LAST_DISK_STATE" != "normal" ]; then
            send_alert "Disk usage returned to normal: ${DISK_USAGE}%" "RECOVERY"
        fi
        
        LAST_DISK_STATE="$disk_state"
    fi
    
    save_state
}

# Log metrics
log_metrics() {
    mkdir -p "$(dirname "$LOG_FILE")"
    if [ "$OS_TYPE" = "windows" ]; then
        echo "[$TIMESTAMP] OS: $OS_TYPE | CPU: ${CPU_USAGE}% | RAM: ${MEM_USAGE}% | Disk: ${DISK_USAGE}%" >> "$LOG_FILE"
    else
        echo "[$TIMESTAMP] OS: $OS_TYPE | CPU: ${CPU_USAGE}% | RAM: ${MEM_USAGE}% | Disk: ${DISK_USAGE}% | Load: ${LOAD_AVG}" >> "$LOG_FILE"
    fi
}

# Colorize based on thresholds
colorize_value() {
    local value=$1
    local warning=$2
    local critical=$3
    
    if [[ "$value" =~ ^[0-9.]+$ ]]; then
        if [ $(float_compare "$value" "$critical") -eq 1 ]; then
            echo -e "${RED}${value}%${NC}"
        elif [ $(float_compare "$value" "$warning") -eq 1 ]; then
            echo -e "${YELLOW}${value}%${NC}"
        else
            echo -e "${GREEN}${value}%${NC}"
        fi
    else
        echo -e "${YELLOW}N/A${NC}"
    fi
}

# Display metrics
display_metrics() {
    echo -e "\n${BLUE}📊 System Metrics - $OS_TYPE${NC}"
    echo "=================================="
    echo -e "CPU Usage:    $(colorize_value "$CPU_USAGE" "$CPU_WARNING" "$CPU_CRITICAL")"
    echo -e "RAM Usage:    $(colorize_value "$MEM_USAGE" "$RAM_WARNING" "$RAM_CRITICAL")"
    echo -e "Disk Usage:   $(colorize_value "$DISK_USAGE" "$DISK_WARNING" "$DISK_CRITICAL")"
    
    if [ "$OS_TYPE" != "windows" ]; then
        echo -e "Load Average: ${GREEN}${LOAD_AVG}${NC}"
    fi
}

# Show system info
show_system_info() {
    echo -e "\n${CYAN}🖥️ System Information:${NC}"
    echo "----------------------"
    echo -e "OS: ${GREEN}$OS_TYPE${NC}"
    echo -e "Kernel: ${GREEN}$(uname -srm)${NC}"
    echo -e "Hostname: ${GREEN}$(hostname)${NC}"

    if [ "$OS_TYPE" = "windows" ]; then
        local pwsh="/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
        if [ -x "$pwsh" ]; then
            uptime_info=$("$pwsh" -Command "
                \$boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
                \$up = (Get-Date) - \$boot
                \"\$([int]\$up.Days) days \$([int]\$up.Hours)h \$([int]\$up.Minutes)m\"
            " 2>/dev/null | tr -d '\r')
            echo -e "Uptime: ${GREEN}${uptime_info}${NC}"
        fi
    fi
}

# Interactive configuration
configure_interactive() {
    echo -e "${BLUE}System Monitor Configuration${NC}"
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
    fi
    
    # Thresholds
    echo -e "\n${YELLOW}CPU Thresholds:${NC}"
    read -p "CPU Warning threshold (%) [${CPU_WARNING}]: " cpu_warn
    [ -n "$cpu_warn" ] && CPU_WARNING=$cpu_warn
    read -p "CPU Critical threshold (%) [${CPU_CRITICAL}]: " cpu_crit
    [ -n "$cpu_crit" ] && CPU_CRITICAL=$cpu_crit
    
    echo -e "\n${YELLOW}RAM Thresholds:${NC}"
    read -p "RAM Warning threshold (%) [${RAM_WARNING}]: " ram_warn
    [ -n "$ram_warn" ] && RAM_WARNING=$ram_warn
    read -p "RAM Critical threshold (%) [${RAM_CRITICAL}]: " ram_crit
    [ -n "$ram_crit" ] && RAM_CRITICAL=$ram_crit
    
    echo -e "\n${YELLOW}Disk Thresholds:${NC}"
    read -p "Disk Warning threshold (%) [${DISK_WARNING}]: " disk_warn
    [ -n "$disk_warn" ] && DISK_WARNING=$disk_warn
    read -p "Disk Critical threshold (%) [${DISK_CRITICAL}]: " disk_crit
    [ -n "$disk_crit" ] && DISK_CRITICAL=$disk_crit
    
    # Check interval
    read -p "Check interval (seconds) [${CHECK_INTERVAL}]: " interval
    [ -n "$interval" ] && CHECK_INTERVAL=$interval
    
    save_config
}

# Show current status
show_status() {
    get_metrics
    display_metrics
    show_system_info
    
    echo -e "\n${CYAN}⚙️  Configuration:${NC}"
    echo "Alert Method: ${CYAN}$ALERT_METHOD${NC}"
    echo "CPU Thresholds: Warning ${CPU_WARNING}%, Critical ${CPU_CRITICAL}%"
    echo "RAM Thresholds: Warning ${RAM_WARNING}%, Critical ${RAM_CRITICAL}%"
    echo "Disk Thresholds: Warning ${DISK_WARNING}%, Critical ${DISK_CRITICAL}%"
}

# Start monitoring
start_monitoring() {
    echo -e "${GREEN}Starting System Monitor${NC}"
    echo -e "Alert method: ${YELLOW}$ALERT_METHOD${NC}"
    echo -e "Check interval: ${YELLOW}${CHECK_INTERVAL}s${NC}"
    echo -e "Press Ctrl+C to stop\n"
    
    load_state
    
    while true; do
        get_metrics
        check_and_alert
        log_metrics
        sleep "$CHECK_INTERVAL"
    done
}

# Test notification
test_notification() {
    echo -e "${YELLOW}Testing System Monitor notification...${NC}"
    
    get_metrics
    
    local test_message="Test Notification - System Monitor

System Monitor is working correctly!
Time: $TIMESTAMP

Current Metrics:
- CPU: ${CPU_USAGE}%
- RAM: ${MEM_USAGE}%
- Disk: ${DISK_USAGE}%

Alert Method: $ALERT_METHOD
Thresholds: CPU ${CPU_CRITICAL}% / RAM ${RAM_CRITICAL}% / Disk ${DISK_CRITICAL}%"

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

# Show help
show_help() {
    echo -e "${BLUE}System Monitor${NC}"
    echo "==============="
    echo "Cross-platform system resource monitoring with flexible alerts"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  config    - Interactive configuration setup"
    echo "  start     - Start continuous monitoring"
    echo "  status    - Show current system metrics and configuration"
    echo "  test      - Test notification system"
    echo "  log       - Show recent logs"
    echo "  once      - Run single check (default if no command given)"
    echo "  help      - Show this help message"
    echo ""
    echo "Alert Methods:"
    echo "  - console: Alerts shown in terminal"
    echo "  - telegram: Alerts sent via Telegram"
    echo "  - both: Alerts shown in terminal and sent via Telegram"
    echo ""
    echo "Examples:"
    echo "  $0              # Run single check"
    echo "  $0 config       # Set up monitoring"
    echo "  $0 start        # Start continuous monitoring"
    echo "  $0 status       # Check current status"
}

# Main execution
main() {
    load_config
    
    case "${1:-once}" in
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
        "once"|"")
            echo -e "${BLUE}🖥️ System Monitor${NC}"
            echo "===================="
            get_metrics
            display_metrics
            show_system_info
            log_metrics
            echo -e "\n${CYAN}📝 Log written to: $LOG_FILE${NC}"
            if [ -f "$LOG_FILE" ]; then
                echo -e "\n${YELLOW}Last 3 entries:${NC}"
                tail -3 "$LOG_FILE"
            fi
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