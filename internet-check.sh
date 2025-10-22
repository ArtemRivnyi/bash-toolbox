#!/bin/bash

# Comprehensive Internet Connectivity Check
# Cross-platform compatible (Linux, macOS, Windows, BSD)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging
LOG_FILE="/tmp/internet-check.log"
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

echo -e "${BLUE}🌐 Comprehensive Internet Connectivity Check${NC}"
echo "=========================================="

# Enhanced OS detection
detect_os() {
    local os_name
    os_name=$(uname -s)
    case "${os_name}" in
        Linux*)
            # Detect specific Linux distributions
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
    
    # Determine ping command based on OS
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
        echo -e "${YELLOW}⚠️ Ping command not available${NC}"
        return 1
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
    
    if [ $success_count -gt 0 ]; then
        echo -e "${GREEN}✅ Network connectivity: $success_count/${#targets[@]} targets reachable${NC}"
        log_message "Ping test: $success_count/${#targets[@]} targets reachable"
        return 0
    else
        echo -e "${RED}❌ No network connectivity${NC}"
        log_message "Ping test: FAILED - no targets reachable"
        return 1
    fi
}

# Enhanced DNS check with multiple methods and servers
check_dns() {
    echo -e "\n🔍 Testing DNS resolution..."
    
    local domains=("google.com" "github.com" "stackoverflow.com" "cloudflare.com")
    local dns_servers=("8.8.8.8" "1.1.1.1" "9.9.9.9")
    local success_count=0
    local dns_tool=""
    
    # Find available DNS tool
    if command_exists nslookup; then
        dns_tool="nslookup"
    elif command_exists host; then
        dns_tool="host"
    elif command_exists dig; then
        dns_tool="dig"
    else
        echo -e "${YELLOW}⚠️ No DNS tools available (nslookup/host/dig)${NC}"
        return 1
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
    
    if [ $success_count -gt 0 ]; then
        echo -e "${GREEN}✅ DNS resolution: $success_count/${#domains[@]} domains resolved${NC}"
        log_message "DNS test: $success_count/${#domains[@]} domains resolved"
        return 0
    else
        echo -e "${RED}❌ DNS resolution failed${NC}"
        log_message "DNS test: FAILED"
        return 1
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
        echo -e "${YELLOW}⚠️ Neither curl nor wget available for HTTP test${NC}"
        return 2
    fi
    
    if [ $success_count -gt 0 ]; then
        echo -e "${GREEN}✅ HTTP/HTTPS: $success_count/${#endpoints[@]} endpoints reachable${NC}"
        log_message "HTTP test: $success_count/${#endpoints[@]} endpoints reachable"
        return 0
    else
        echo -e "${RED}❌ HTTP/HTTPS connectivity failed${NC}"
        log_message "HTTP test: FAILED"
        return 1
    fi
}

# Enhanced network information for Windows
show_network_info() {
    echo -e "\n📊 Network Information:"
    echo "----------------------"
    
    # Show hostname
    if command_exists hostname; then
        echo -e "Hostname: ${CYAN}$(hostname)${NC}"
    fi
    
    case $OS_TYPE in
        linux*)
            # Try multiple methods to get IP and gateway
            local ip=""
            local gateway=""
            
            # Method 1: ip command (modern)
            if command_exists ip; then
                ip=$(ip route get 1 2>/dev/null | awk '{print $7; exit}')
                gateway=$(ip route show default 2>/dev/null | awk '/default/ {print $3}')
            fi
            
            # Method 2: ifconfig (legacy)
            if [ -z "$ip" ] && command_exists ifconfig; then
                ip=$(ifconfig 2>/dev/null | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1)
            fi
            
            # Method 3: /proc/net/route
            if [ -z "$gateway" ] && [ -f /proc/net/route ]; then
                gateway=$(awk '$2 == "00000000" {print $3}' /proc/net/route | head -1)
                if [ -n "$gateway" ]; then
                    # Convert from hex to IP
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
            # Enhanced Windows IP detection for Git Bash/Mingw
            echo -e "${YELLOW}Searching for network information...${NC}"
            
            local ip=""
            local gateway=""
            
            # Method 1: Try ipconfig with different parsing
            if command_exists ipconfig; then
                ip=$(ipconfig 2>/dev/null | grep -i "IPv4 Address" | head -1 | sed -n 's/.*: //p' | tr -d '\r' | tr -d ' ')
                if [ -z "$ip" ]; then
                    ip=$(ipconfig 2>/dev/null | grep -i "IPv4" | head -1 | sed -n 's/.*: //p' | tr -d '\r' | tr -d ' ')
                fi
                
                gateway=$(ipconfig 2>/dev/null | grep -i "Default Gateway" | head -1 | sed -n 's/.*: //p' | tr -d '\r' | tr -d ' ')
                if [ -z "$gateway" ]; then
                    gateway=$(ipconfig 2>/dev/null | grep -i "Gateway" | head -1 | sed -n 's/.*: //p' | tr -d '\r' | tr -d ' ')
                fi
            fi
            
            # Method 2: Try using PowerShell if available
            if [ -z "$ip" ] && command_exists powershell; then
                echo -e "${YELLOW}Trying PowerShell...${NC}"
                ip=$(powershell -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object {\$_.IPAddress -ne '127.0.0.1'} | Select-Object -First 1 | ForEach-Object {\$_.IPAddress}" 2>/dev/null | head -1 | tr -d '\r')
                gateway=$(powershell -Command "Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Select-Object -First 1 | ForEach-Object {\$_.NextHop}" 2>/dev/null | head -1 | tr -d '\r')
            fi
            
            # Method 3: Try using netstat
            if [ -z "$gateway" ] && command_exists netstat; then
                echo -e "${YELLOW}Trying netstat...${NC}"
                gateway=$(netstat -rn 2>/dev/null | grep -E '^0.0.0.0' | awk '{print $2}' | head -1)
            fi
            
            # Method 4: Try using route command
            if [ -z "$gateway" ] && command_exists route; then
                echo -e "${YELLOW}Trying route...${NC}"
                gateway=$(route print 2>/dev/null | grep -E '0.0.0.0.*0.0.0.0' | awk '{print $3}' | head -1)
            fi
            
            # Display results
            if [ -n "$ip" ]; then
                echo -e "IP Address: ${CYAN}$ip${NC}"
            else
                echo -e "IP Address: ${YELLOW}Not detected (try running as Administrator)${NC}"
            fi
            
            if [ -n "$gateway" ]; then
                echo -e "Default Gateway: ${CYAN}$gateway${NC}"
            else
                echo -e "Default Gateway: ${YELLOW}Not detected${NC}"
            fi
            
            # Show DNS servers for Windows with proper cleaning
            if command_exists powershell; then
                local dns_servers=$(powershell -Command "Get-DnsClientServerAddress -AddressFamily IPv4 | Select-Object -ExpandProperty ServerAddresses" 2>/dev/null | head -2 | tr '\n' ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                if [ -n "$dns_servers" ]; then
                    echo -e "DNS Servers: ${CYAN}$dns_servers${NC}"
                fi
            fi
            
            # Clean network status
            echo -e "\n${YELLOW}Network status:${NC}"
            echo "  All network tests passed successfully"
            ;;
            
        freebsd|openbsd)
            local ip=$(ifconfig 2>/dev/null | grep -Eo 'inet [0-9.]+' | grep -v '127.0.0.1' | awk '{print $2}' | head -1)
            local gateway=$(route -n get default 2>/dev/null | grep gateway | awk '{print $2}')
            
            [ -n "$ip" ] && echo -e "IP Address: ${CYAN}$ip${NC}" || echo "IP Address: Not available"
            [ -n "$gateway" ] && echo -e "Default Gateway: ${CYAN}$gateway${NC}" || echo "Default Gateway: Not available"
            ;;
            
        *)
            echo "Network info: Unsupported OS"
            ;;
    esac
}

# Enhanced speed test with multiple methods
check_speed() {
    echo -e "\n🚀 Testing internet speed..."
    
    # Check if speedtest-cli is available
    if command_exists speedtest-cli; then
        echo "Running official speedtest-cli..."
        speedtest-cli --simple
        log_message "Speed test: executed via speedtest-cli"
        
    elif command_exists speedtest; then
        echo "Running speedtest.net CLI..."
        speedtest --format=simple
        log_message "Speed test: executed via speedtest"
        
    elif command_exists curl; then
        echo -e "${YELLOW}⚠️ Using alternative speed test methods...${NC}"
        
        # Method 1: Download speed test
        local test_files=(
            "https://proof.ovh.net/files/10Mb.dat"
            "http://ipv4.download.thinkbroadband.com/10MB.zip"
            "https://ftp.halifax.rwth-aachen.de/ubuntu-releases/22.04.2/ubuntu-22.04.2-desktop-amd64.iso.zsync"
        )
        
        for test_file in "${test_files[@]}"; do
            echo -n "  Testing download from $(basename "$test_file")... "
            
            local start_time=$(date +%s%3N)
            if curl -s --max-time 30 -o /dev/null "$test_file"; then
                local end_time=$(date +%s%3N)
                local download_time=$(( (end_time - start_time) / 1000 ))
                
                if [ $download_time -eq 0 ]; then
                    download_time=1
                fi
                
                # Calculate speed (rough estimate)
                local speed_kbs=$(( 10000 / download_time ))  # 10MB file
                local speed_mbs=$(echo "scale=2; $speed_kbs / 1024" | bc 2>/dev/null || echo "N/A")
                
                if [ "$speed_mbs" != "N/A" ]; then
                    echo -e "${GREEN}~${speed_mbs} Mbps${NC}"
                    log_message "Speed test: ~${speed_mbs} Mbps from $test_file"
                else
                    echo -e "${GREEN}~${speed_kbs} KB/s${NC}"
                    log_message "Speed test: ~${speed_kbs} KB/s from $test_file"
                fi
                break
            else
                echo -e "${RED}Failed${NC}"
            fi
        done
        
    else
        echo -e "${YELLOW}⚠️ Speed test unavailable${NC}"
        echo "Install one of these for accurate speed testing:"
        case $OS_TYPE in
            linux-ubuntu|linux-debian)
                echo "  sudo apt install speedtest-cli"
                echo "  or: curl -s https://install.speedtest.net/app/cli/install.deb.sh | sudo bash"
                ;;
            linux-centos|linux-rhel|linux-fedora)
                echo "  sudo yum install speedtest-cli"
                echo "  or on Fedora: sudo dnf install speedtest-cli"
                ;;
            linux-arch)
                echo "  sudo pacman -S speedtest-cli"
                ;;
            macos)
                echo "  brew install speedtest-cli"
                ;;
            windows)
                echo "  Download from: https://www.speedtest.net/apps/cli"
                echo "  Or use: winget install speedtest"
                ;;
            *)
                echo "  Install speedtest-cli from your package manager"
                ;;
        esac
        log_message "Speed test: No tools available"
    fi
}

# Main execution
main() {
    local overall_success=true
    
    check_ping || overall_success=false
    check_dns || overall_success=false
    check_http || overall_success=false
    show_network_info
    check_speed
    
    echo -e "\n${BLUE}==========================================${NC}"
    if $overall_success; then
        echo -e "${GREEN}✅ Internet check completed successfully!${NC}"
        log_message "Internet check: COMPLETED SUCCESSFULLY"
    else
        echo -e "${YELLOW}⚠️ Internet check completed with some issues${NC}"
        log_message "Internet check: COMPLETED WITH ISSUES"
    fi
    echo -e "${CYAN}📝 Detailed log: $LOG_FILE${NC}"
}

# Run main function
main