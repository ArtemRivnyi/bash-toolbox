#!/bin/bash

# System Monitoring Script - Cross-platform compatible
LOG_FILE="/tmp/system-monitor.log"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

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

# Get Windows CPU usage — fixed for Git Bash
get_windows_cpu_usage() {
    local cpu_usage="N/A"
    local pwsh_path="/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

    if [ -x "$pwsh_path" ]; then
        cpu_usage=$("$pwsh_path" -Command "
            try {
                # Используем CIM — работает стабильно даже в ограниченных средах
                \$cpu = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
                if (\$cpu -gt 0) { [math]::Round(\$cpu) } else { 0 }
            } catch {
                try {
                    # Резервный метод через WMI
                    \$wmi = (Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
                    if (\$wmi -gt 0) { [math]::Round(\$wmi) } else { 0 }
                } catch { 0 }
            }
        " 2>/dev/null | tr -d '\r' | tr -d ' ')
    fi

    # Проверка результата
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
                # RAM
                MEM_USAGE=$("$pwsh" -Command "
                    [System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::InvariantCulture;
                    \$os = Get-WmiObject Win32_OperatingSystem;
                    \$t = \$os.TotalVisibleMemorySize; \$f = \$os.FreePhysicalMemory;
                    if (\$t -gt 0) { [math]::Round((\$t - \$f) * 100 / \$t, 1) }
                " 2>/dev/null | tr -d '\r')

                # Disk
                DISK_USAGE=$("$pwsh" -Command "
                    [System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::InvariantCulture;
                    \$disk = Get-WmiObject Win32_LogicalDisk -Filter \"DeviceID='C:'\";
                    if (\$disk.Size -gt 0) { [math]::Round((\$disk.Size - \$disk.FreeSpace) * 100 / \$disk.Size) }
                " 2>/dev/null | tr -d '\r')
            fi

            [ -z "$MEM_USAGE" ] && MEM_USAGE="N/A"
            [ -z "$DISK_USAGE" ] && DISK_USAGE="N/A"
            LOAD_AVG=""  # Пустая строка для Windows
            ;;
        *)
            CPU_USAGE="N/A"; MEM_USAGE="N/A"; DISK_USAGE="N/A"; LOAD_AVG="N/A"
            ;;
    esac

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
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

# Colorize based on load
colorize_value() {
    local value=$1
    local threshold1=$2
    local threshold2=$3
    if [[ "$value" =~ ^[0-9.]+$ ]]; then
        if [ $(float_compare "$value" "$threshold2") -eq 1 ]; then
            echo -e "${RED}${value}%${NC}"
        elif [ $(float_compare "$value" "$threshold1") -eq 1 ]; then
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
    echo -e "CPU Usage:    $(colorize_value "$CPU_USAGE" 60 85)"
    echo -e "RAM Usage:    $(colorize_value "$MEM_USAGE" 70 90)"
    echo -e "Disk Usage:   $(colorize_value "$DISK_USAGE" 75 90)"
    
    # Load Average только для Unix-систем
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
        uptime_info=$("$pwsh" -Command "
            \$boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
            \$up = (Get-Date) - \$boot
            \"\$([int]\$up.Days) days \$([int]\$up.Hours)h \$([int]\$up.Minutes)m\"
        " 2>/dev/null | tr -d '\r')
        echo -e "Uptime: ${GREEN}${uptime_info}${NC}"
    fi
}

# Main
main() {
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
}

main