#!/bin/bash

# Comprehensive Internet Connectivity Check with Telegram Integration
# Cross-platform compatible (Linux, macOS, Windows, BSD)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
CONFIG_FILE="$HOME/.internet-check.conf"
LOG_FILE="/tmp/internet-check.log"
STATE_FILE="/tmp/internet-check.state"

# Logging
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
        ALERT_ON_SUCCESS=false  # Don't spam on successful checks
    fi
}

# Save configuration
save_config() {
    cat > "$CONFIG_FILE" << EOF
# Internet Check Configuration
ALERT_METHOD="$ALERT_METHOD"
TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN"
TELEGRAM_CHAT_ID="$TELEGRAM_CHAT_ID"
CHECK_INTERVAL=$CHECK_INTERVAL
ALERT_COOLDOWN=$ALERT_COOLDOWN
ALERT_ON_SUCCESS=$ALERT_ON_SUCCESS
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

# Load previous state
load_state() {
    if [ -f "$STATE_FILE" ]; then
        source "$STATE_FILE"
    else
        declare -g LAST_INTERNET_STATE="unknown"
        declare -gA LAST_ALERT_TIME
    fi
}

# Save current state
save_state() {
    {
        echo "LAST_INTERNET_STATE='$LAST_INTERNET_STATE'"
        echo "declare -gA LAST_ALERT_TIME"
        for check in "${!LAST_ALERT_TIME[@]}"; do
            echo "LAST_ALERT_TIME[$check]='${LAST_ALERT_TIME[$check]}'"
        done
    } > "$STATE_FILE"
}

# Check if alert should be sent (cooldown period)
should_alert() {
    local check_type="$1"
    local current_time=$(date +%s)
    local last_alert_time=${LAST_ALERT_TIME[$check_type]:-0}
    
    if [ $((current_time - last_alert_time)) -ge $ALERT_COOLDOWN ]; then
        LAST_ALERT_TIME[$check_type]=$current_time
        return 0
    else
        return 1
    fi
}

echo -e "${BLUE}🌐 Comprehensive Internet Connectivity Check${NC}"
echo "=========================================="

# Enhanced OS detection
detect_os() {
    local os_name
    os_name=$(uname -s)
    case "${os_name}" in
        Linux*)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                echo "linux-$ID"
            else
                echo "linux"
            fi
            ;;
        Darwin*)    echo "macos" ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        FreeBSD*)   echo "freebsd" ;;
        OpenBSD*)   echo "openbsd" ;;
        *)          echo "unknown" ;;
    esac
}

OS_TYPE=$(detect_os)
echo -e "Detected OS: ${CYAN}$OS_TYPE${NC}"
echo -e "Kernel: ${CYAN}$(uname -srm)${NC}"
log_message "Starting internet check on $OS_TYPE - $(uname -srm)"

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Enhanced ping check with multiple targets and fallbacks
check_ping() {
    echo -e "\n📡 Checking network connectivity..."
    
    local targets=("8.8.8.8" "1.1.1.1" "208.67.222.222")
    local success_count=0
    local ping_cmd=""
    local ping_args=""
    
    case $OS_TYPE in
        linux*|freebsd|openbsd)
            ping_cmd="ping"
            ping_args="-c 2 -W 3"
            ;;
        macos)
            ping_cmd="ping"
            ping_args="-c 2 -t 3"
            ;;
        windows)
            ping_cmd="ping"
            ping_args="-n 2 -w 3000"
            ;;
        *)
            ping_cmd="ping"
            ping_args="-c 2 -W 3"
            ;;
    esac
    
    if ! command_exists "$ping_cmd"; then
        echo -e "${YELLOW}⚠️  Ping command not available${NC}"
        log_message "Ping check: SKIPPED - command not available"
        return 2
    fi
    
    for target in "${targets[@]}"; do
        echo -n "  Testing $target... "
        if $ping_cmd $ping_args "$target" &> /dev/null; then
            echo -e "${GREEN}✓${NC}"
            ((success_count++))
        else
            echo -e "${RED}✗${NC}"
        fi
    done
    
    if [ $success_count -eq 0 ]; then
        echo -e "${RED}❌ Network connectivity: FAILED - All targets unreachable${NC}"
        log_message "Ping test: FAILED - no targets reachable"
        return 1
    elif [ $success_count -lt ${#targets[@]} ]; then
        echo -e "${YELLOW}⚠️  Network connectivity: DEGRADED - $success_count/${#targets[@]} targets reachable${NC}"
        log_message "Ping test: DEGRADED - $success_count/${#targets[@]} targets reachable"
        return 2
    else
        echo -e "${GREEN}✅ Network connectivity: $success_count/${#targets[@]} targets reachable${NC}"
        log_message "Ping test: $success_count/${#targets[@]} targets reachable"
        return 0
    fi
}

# Enhanced DNS check with multiple methods and servers
check_dns() {
    echo -e "\n🔍 Testing DNS resolution..."
    
    local domains=("google.com" "github.com" "stackoverflow.com" "cloudflare.com")
    local dns_servers=("8.8.8.8" "1.1.1.1" "9.9.9.9")
    local success_count=0
    local dns_tool=""
    
    if command_exists nslookup; then
        dns_tool="nslookup"
    elif command_exists host; then
        dns_tool="host"
    elif command_exists dig; then
        dns_tool="dig"
    else
        echo -e "${YELLOW}⚠️  No DNS tools available (nslookup/host/dig)${NC}"
        log_message "DNS check: SKIPPED - no tools available"
        return 2
    fi
    
    echo -e "Using DNS tool: ${CYAN}$dns_tool${NC}"
    
    for domain in "${domains[@]}"; do
        echo -n "  $domain... "
        
        local dns_success=0
        for dns_server in "${dns_servers[@]}"; do
            case $dns_tool in
                nslookup)
                    if nslookup "$domain" "$dns_server" &> /dev/null; then
                        dns_success=1
                        break
                    fi
                    ;;
                host)
                    if host "$domain" "$dns_server" &> /dev/null; then
                        dns_success=1
                        break
                    fi
                    ;;
                dig)
                    if dig "@$dns_server" "$domain" +short +time=3 &> /dev/null; then
                        dns_success=1
                        break
                    fi
                    ;;
            esac
        done
        
        if [ $dns_success -eq 1 ]; then
            echo -e "${GREEN}✓${NC}"
            ((success_count++))
        else
            echo -e "${RED}✗${NC}"
        fi
    done
    
    if [ $success_count -eq 0 ]; then
        echo -e "${RED}❌ DNS resolution: FAILED${NC}"
        log_message "DNS test: FAILED"
        return 1
    elif [ $success_count -lt ${#domains[@]} ]; then
        echo -e "${YELLOW}⚠️  DNS resolution: DEGRADED - $success_count/${#domains[@]} domains resolved${NC}"
        log_message "DNS test: DEGRADED - $success_count/${#domains[@]} domains resolved"
        return 2
    else
        echo -e "${GREEN}✅ DNS resolution: $success_count/${#domains[@]} domains resolved${NC}"
        log_message "DNS test: $success_count/${#domains[@]} domains resolved"
        return 0
    fi
}

# Enhanced HTTP/HTTPS check with multiple endpoints
check_http() {
    echo -e "\n🌐 Testing HTTP/HTTPS connectivity..."
    
    local endpoints=(
        "https://www.google.com"
        "https://www.cloudflare.com"
        "https://httpbin.org/get"
    )
    local success_count=0
    
    if command_exists curl; then
        echo -e "Using: ${CYAN}curl${NC}"
        for endpoint in "${endpoints[@]}"; do
            echo -n "  $endpoint... "
            if curl -s --max-time 10 --head "$endpoint" &> /dev/null; then
                echo -e "${GREEN}✓${NC}"
                ((success_count++))
            else
                echo -e "${RED}✗${NC}"
            fi
        done
    elif command_exists wget; then
        echo -e "Using: ${CYAN}wget${NC}"
        for endpoint in "${endpoints[@]}"; do
            echo -n "  $endpoint... "
            if wget -q --spider --timeout=10 "$endpoint" &> /dev/null; then
                echo -e "${GREEN}✓${NC}"
                ((success_count++))
            else
                echo -e "${RED}✗${NC}"
            fi
        done
    else
        echo -e "${YELLOW}⚠️  Neither curl nor wget available for HTTP test${NC}"
        log_message "HTTP check: SKIPPED - no tools available"
        return 2
    fi
    
    if [ $success_count -eq 0 ]; then
        echo -e "${RED}❌ HTTP/HTTPS connectivity: FAILED${NC}"
        log_message "HTTP test: FAILED"
        return 1
    elif [ $success_count -lt ${#endpoints[@]} ]; then
        echo -e "${YELLOW}⚠️  HTTP/HTTPS: DEGRADED - $success_count/${#endpoints[@]} endpoints reachable${NC}"
        log_message "HTTP test: DEGRADED - $success_count/${#endpoints[@]} endpoints reachable"
        return 2
    else
        echo -e "${GREEN}✅ HTTP/HTTPS: $success_count/${#endpoints[@]} endpoints reachable${NC}"
        log_message "HTTP test: $success_count/${#endpoints[@]} endpoints reachable"
        return 0
    fi
}

# Enhanced network information
show_network_info() {
    echo -e "\n📊 Network Information:"
    echo "----------------------"
    
    if command_exists hostname; then
        echo -e "Hostname: ${CYAN}$(hostname)${NC}"
    fi
    
    case $OS_TYPE in
        linux*)
            local ip=""
            local gateway=""
            
            if command_exists ip; then
                ip=$(ip route get 1 2>/dev/null | awk '{print $7; exit}')
                gateway=$(ip route show default 2>/dev/null | awk '/default/ {print $3}')
            fi
            
            if [ -z "$ip" ] && command_exists ifconfig; then
                ip=$(ifconfig 2>/dev/null | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1)
            fi
            
            if [ -z "$gateway" ] && [ -f /proc/net/route ]; then
                gateway=$(awk '$2 == "00000000" {print $3}' /proc/net/route | head -1)
                if [ -n "$gateway" ]; then
                    gateway=$(printf "%d.%d.%d.%d" \
                        $((0x${gateway:6:2})) \
                        $((0x${gateway:4:2})) \
                        $((0x${gateway:2:2})) \
                        $((0x${gateway:0:2})) )
                fi
            fi
            
            [ -n "$ip" ] && echo -e "IP Address: ${CYAN}$ip${NC}" || echo "IP Address: Not available"
            [ -n "$gateway" ] && echo -e "Default Gateway: ${CYAN}$gateway${NC}" || echo "Default Gateway: Not available"
            ;;
            
        macos)
            local ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)
            local gateway=$(route -n get default 2>/dev/null | grep gateway | awk '{print $2}')
            
            [ -n "$ip" ] && echo -e "IP Address: ${CYAN}$ip${NC}" || echo "IP Address: Not available"
            [ -n "$gateway" ] && echo -e "Default Gateway: ${CYAN}$gateway${NC}" || echo "Default Gateway: Not available"
            ;;
            
        windows)
            local ip=""
            local gateway=""
            
            if command_exists ipconfig; then
                ip=$(ipconfig 2>/dev/null | grep -i "IPv4 Address" | head -1 | sed -n 's/.*: //p' | tr -d '\r' | tr -d ' ')
                gateway=$(ipconfig 2>/dev/null | grep -i "Default Gateway" | head -1 | sed -n 's/.*: //p' | tr -d '\r' | tr -d ' ')
            fi
            
            if [ -z "$ip" ] && command_exists powershell; then
                ip=$(powershell -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object {\$_.IPAddress -ne '127.0.0.1'} | Select-Object -First 1 | ForEach-Object {\$_.IPAddress}" 2>/dev/null | head -1 | tr -d '\r')
                gateway=$(powershell -Command "Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Select-Object -First 1 | ForEach-Object {\$_.NextHop}" 2>/dev/null | head -1 | tr -d '\r')
            fi
            
            [ -n "$ip" ] && echo -e "IP Address: ${CYAN}$ip${NC}" || echo "IP Address: Not detected"
            [ -n "$gateway" ] && echo -e "Default Gateway: ${CYAN}$gateway${NC}" || echo "Default Gateway: Not detected"
            ;;
            
        *)
            echo "Network info: Unsupported OS"
            ;;
    esac
}

# Speed test (optional, not used for critical alerts)
check_speed() {
    echo -e "\n🚀 Testing internet speed..."
    
    if command_exists speedtest-cli; then
        speedtest-cli --simple 2>/dev/null
        log_message "Speed test: executed via speedtest-cli"
    elif command_exists speedtest; then
        speedtest --format=simple 2>/dev/null
        log_message "Speed test: executed via speedtest"
    else
        echo -e "${YELLOW}⚠️  Speed test unavailable (install speedtest-cli)${NC}"
        log_message "Speed test: SKIPPED - no tools available"
    fi
}

# Comprehensive check with alerting
run_comprehensive_check() {
    local ping_result=0
    local dns_result=0
    local http_result=0
    local overall_status="up"
    
    check_ping
    ping_result=$?
    
    check_dns
    dns_result=$?
    
    check_http
    http_result=$?
    
    show_network_info
    
    # Determine overall status
    if [ $ping_result -eq 1 ] && [ $dns_result -eq 1 ]; then
        overall_status="down"
    elif [ $ping_result -eq 1 ] || [ $dns_result -eq 1 ] || [ $http_result -eq 1 ]; then
        overall_status="degraded"
    elif [ $ping_result -eq 2 ] || [ $dns_result -eq 2 ] || [ $http_result -eq 2 ]; then
        overall_status="degraded"
    else
        overall_status="up"
    fi
    
    # Check if we should alert
    if [ "$overall_status" = "down" ]; then
        if [ "$LAST_INTERNET_STATE" != "down" ]; then
            if should_alert "internet"; then
                local alert_msg="Internet connection is DOWN

Ping Check: FAILED
DNS Check: FAILED
HTTP Check: $([ $http_result -eq 1 ] && echo 'FAILED' || echo 'Unknown')

Time: $(date '+%Y-%m-%d %H:%M:%S')"
                send_alert "$alert_msg" "CRITICAL"
            fi
        fi
    elif [ "$overall_status" = "degraded" ]; then
        if [ "$LAST_INTERNET_STATE" = "up" ]; then
            if should_alert "internet"; then
                local alert_msg="Internet connection is DEGRADED

Ping: $([ $ping_result -eq 0 ] && echo 'OK' || echo 'FAILED/DEGRADED')
DNS: $([ $dns_result -eq 0 ] && echo 'OK' || echo 'FAILED/DEGRADED')
HTTP: $([ $http_result -eq 0 ] && echo 'OK' || echo 'FAILED/DEGRADED')

Time: $(date '+%Y-%m-%d %H:%M:%S')"
                send_alert "$alert_msg" "WARNING"
            fi
        fi
    elif [ "$overall_status" = "up" ]; then
        if [ "$LAST_INTERNET_STATE" = "down" ] || [ "$LAST_INTERNET_STATE" = "degraded" ]; then
            local recovery_msg="Internet connection RECOVERED

All checks are now passing.
Time: $(date '+%Y-%m-%d %H:%M:%S')"
            send_alert "$recovery_msg" "RECOVERY"
        elif [ "$ALERT_ON_SUCCESS" = true ]; then
            send_alert "Internet check completed successfully" "INFO"
        fi
    fi
    
    LAST_INTERNET_STATE="$overall_status"
    save_state
    
    echo -e "\n${BLUE}==========================================${NC}"
    case $overall_status in
        "up")
            echo -e "${GREEN}✅ Internet check completed successfully!${NC}"
            log_message "Internet check: COMPLETED SUCCESSFULLY"
            ;;
        "degraded")
            echo -e "${YELLOW}⚠️  Internet check completed with degraded performance${NC}"
            log_message "Internet check: DEGRADED"
            ;;
        "down")
            echo -e "${RED}❌ Internet connection is DOWN${NC}"
            log_message "Internet check: FAILED - Connection DOWN"
            ;;
    esac
    echo -e "${CYAN}📝 Detailed log: $LOG_FILE${NC}"
    
    return $([ "$overall_status" = "up" ] && echo 0 || echo 1)
}

# Interactive configuration
configure_interactive() {
    echo -e "${BLUE}Internet Check Configuration${NC}"
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
    
    # Telegram configuration
    if [ "$ALERT_METHOD" = "telegram" ] || [ "$ALERT_METHOD" = "both" ]; then
        echo -e "\n${YELLOW}Telegram Configuration:${NC}"
        read -p "Enter Telegram Bot Token: " token
        [ -n "$token" ] && TELEGRAM_BOT_TOKEN="$token"
        
        read -p "Enter Telegram Chat ID: " chat_id
        [ -n "$chat_id" ] && TELEGRAM_CHAT_ID="$chat_id"
    fi
    
    # Check interval
    read -p "Check interval (seconds) [${CHECK_INTERVAL}]: " interval
    [ -n "$interval" ] && CHECK_INTERVAL=$interval
    
    # Alert on success
    echo -e "\n${YELLOW}Alert on successful checks?${NC}"
    read -p "Send notifications when everything is OK? [y/N]: " alert_success
    [[ "$alert_success" =~ ^[Yy]$ ]] && ALERT_ON_SUCCESS=true || ALERT_ON_SUCCESS=false
    
    save_config
}

# Start monitoring
start_monitoring() {
    echo -e "${GREEN}Starting Internet Connection Monitor${NC}"
    echo -e "Alert method: ${YELLOW}$ALERT_METHOD${NC}"
    echo -e "Check interval: ${YELLOW}${CHECK_INTERVAL}s${NC}"
    echo -e "Press Ctrl+C to stop\n"
    
    load_state
    
    while true; do
        run_comprehensive_check
        sleep "$CHECK_INTERVAL"
    done
}

# Test notification
test_notification() {
    echo -e "${YELLOW}Testing Internet Check notification...${NC}"
    
    local test_message="Test Notification - Internet Check

Internet Check Monitor is working correctly!
Time: $(date '+%Y-%m-%d %H:%M:%S')

Alert Method: $ALERT_METHOD
Check Interval: ${CHECK_INTERVAL}s"

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
    echo -e "${BLUE}Internet Connection Check${NC}"
    echo "=========================="
    echo "Comprehensive network diagnostics with flexible alerts"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  config    - Interactive configuration setup"
    echo "  start     - Start continuous monitoring"
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
}

# Main execution
main() {
    load_config
    load_state
    
    case "${1:-once}" in
        "config")
            configure_interactive
            ;;
        "start")
            start_monitoring
            ;;
        "test")
            test_notification
            ;;
        "log")
            show_logs
            ;;
        "once"|"")
            run_comprehensive_check
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