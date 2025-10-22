#!/bin/bash

# Advanced Backup Manager with Compression and Retention
# Cross-platform compatible (Linux, macOS, Windows with Git Bash)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
BACKUP_DIR="${BACKUP_DIR:-/tmp/backups}"
CONFIG_FILE="${HOME}/.backup-manager.conf"
LOG_FILE="/tmp/backup-manager.log"

# Default sources to backup (can be overridden via command line or config)
DEFAULT_SOURCES=(
    "${HOME}/Documents"
    "${HOME}/scripts"
    "${HOME}/.config"
)

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

# Logging function
log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] ${message}" >> "$LOG_FILE"
}

# Print with color and log
print_status() {
    local color="$1"
    local emoji="$2"
    local message="$3"
    echo -e "${color}${emoji} ${message}${NC}"
    log_message "${emoji} ${message}"
}

# Load configuration
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        print_status "$GREEN" "⚙️" "Configuration loaded from $CONFIG_FILE"
    fi
}

# Save configuration
save_config() {
    cat > "$CONFIG_FILE" << EOF
# Backup Manager Configuration
BACKUP_DIR="$BACKUP_DIR"
SOURCES=(${SOURCES[@]})
RETENTION_DAYS=$RETENTION_DAYS
COMPRESSION_LEVEL=$COMPRESSION_LEVEL
EXCLUDE_PATTERNS=("${EXCLUDE_PATTERNS[@]}")
EOF
    print_status "$GREEN" "💾" "Configuration saved to $CONFIG_FILE"
}

# Initialize default configuration
init_config() {
    RETENTION_DAYS=${RETENTION_DAYS:-30}
    COMPRESSION_LEVEL=${COMPRESSION_LEVEL:-6}
    EXCLUDE_PATTERNS=(
        "*.tmp"
        "*.log"
        "*.cache*"
        "node_modules"
        ".git"
        "__pycache__"
    )
    
    # Set sources - use command line or default
    if [[ ${#SOURCES[@]} -eq 0 ]]; then
        SOURCES=("${DEFAULT_SOURCES[@]}")
    fi
}

# Check prerequisites
check_prerequisites() {
    local missing_tools=()
    
    if ! command -v tar >/dev/null 2>&1; then
        missing_tools+=("tar")
    fi
    
    if ! command -v gzip >/dev/null 2>&1; then
        missing_tools+=("gzip")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_status "$RED" "❌" "Missing required tools: ${missing_tools[*]}"
        return 1
    fi
    
    print_status "$GREEN" "✅" "All prerequisites satisfied"
    return 0
}

# Check disk space
check_disk_space() {
    local required_space=$1
    local available_space
    
    case $OS_TYPE in
        linux)
            available_space=$(df "$BACKUP_DIR" | awk 'NR==2 {print $4}')
            available_space=$((available_space * 1024))  # Convert to bytes
            ;;
        macos)
            available_space=$(df "$BACKUP_DIR" | awk 'NR==2 {print $4}')
            ;;
        windows)
            available_space=$(df "$BACKUP_DIR" | awk 'NR==2 {print $4}')
            available_space=$((available_space * 1024))
            ;;
    esac
    
    if [[ $required_space -gt $available_space ]]; then
        print_status "$RED" "❌" "Insufficient disk space. Required: $(numfmt --to=iec $required_space), Available: $(numfmt --to=iec $available_space)"
        return 1
    fi
    
    print_status "$GREEN" "✅" "Disk space check passed. Available: $(numfmt --to=iec $available_space)"
    return 0
}

# Calculate directory size
calculate_size() {
    local dir="$1"
    local total_size=0
    
    if [[ -d "$dir" ]]; then
        case $OS_TYPE in
            linux|macos)
                total_size=$(du -sb "$dir" 2>/dev/null | cut -f1)
                ;;
            windows)
                total_size=$(du -sb "$dir" 2>/dev/null | cut -f1)
                ;;
        esac
    fi
    
    echo "${total_size:-0}"
}

# Show backup contents without extracting
show_backup_contents() {
    local backup_file="$1"
    local max_files="${2:-50}"
    
    if [[ ! -f "$backup_file" ]]; then
        print_status "$RED" "❌" "Backup file not found: $backup_file"
        return 1
    fi
    
    print_status "$BLUE" "📂" "Contents of backup: $(basename "$backup_file")"
    echo "=========================================="
    
    # Show first N files
    if tar -tzf "$backup_file" 2>/dev/null | head -n "$max_files"; then
        local total_files=$(tar -tzf "$backup_file" 2>/dev/null | wc -l)
        echo "=========================================="
        print_status "$CYAN" "📊" "Total files in backup: $total_files"
        
        if [[ $total_files -gt $max_files ]]; then
            print_status "$YELLOW" "ℹ️" "Showing first $max_files files. Use '--inspect-all' to see all files"
        fi
    else
        print_status "$RED" "❌" "Failed to read backup contents"
        return 1
    fi
}

# Extract backup to temporary directory for inspection
inspect_backup() {
    local backup_file="$1"
    local temp_dir="/tmp/backup-inspect-$$"
    
    if [[ ! -f "$backup_file" ]]; then
        print_status "$RED" "❌" "Backup file not found: $backup_file"
        return 1
    fi
    
    print_status "$BLUE" "🔍" "Inspecting backup: $(basename "$backup_file")"
    
    # Create temp directory
    mkdir -p "$temp_dir"
    
    # Extract backup
    if tar -xzf "$backup_file" -C "$temp_dir" 2>/dev/null; then
        print_status "$GREEN" "✅" "Backup extracted to: $temp_dir"
        
        # Show directory structure
        echo -e "\n${CYAN}📁 Directory structure:${NC}"
        find "$temp_dir" -type f | head -30
        
        echo -e "\n${CYAN}💾 File sizes:${NC}"
        du -ah "$temp_dir" | sort -hr | head -15 | while read size file; do
            echo -e "  ${GREEN}$size${NC} - $file"
        done
        
        print_status "$YELLOW" "⚠️" "Temporary files will be deleted automatically"
        print_status "$CYAN" "💡" "To keep files, copy them from: $temp_dir"
        
        # Ask user if they want to keep files
        echo -e -n "\n${YELLOW}Delete temporary files? [y/N]: ${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            rm -rf "$temp_dir"
            print_status "$GREEN" "✅" "Temporary files deleted"
        else
            print_status "$YELLOW" "💾" "Files preserved in: $temp_dir"
        fi
    else
        print_status "$RED" "❌" "Failed to extract backup"
        rm -rf "$temp_dir"
        return 1
    fi
}

# Create backup
create_backup() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_name="backup_${timestamp}.tar.gz"
    local backup_path="${BACKUP_DIR}/${backup_name}"
    
    print_status "$BLUE" "📦" "Starting backup: $backup_name"
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Build tar command with excludes
    local tar_cmd=("tar")
    local exclude_args=()
    
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        exclude_args+=(--exclude="$pattern")
    done
    
    # Add sources that exist
    local valid_sources=()
    local total_size=0
    
    for source in "${SOURCES[@]}"; do
        if [[ -e "$source" ]]; then
            valid_sources+=("$source")
            total_size=$((total_size + $(calculate_size "$source")))
        else
            print_status "$YELLOW" "⚠️" "Source not found: $source"
        fi
    done
    
    if [[ ${#valid_sources[@]} -eq 0 ]]; then
        print_status "$RED" "❌" "No valid sources found for backup"
        return 1
    fi
    
    # Check disk space (estimate 50% compression)
    local estimated_size=$((total_size / 2))
    if ! check_disk_space $estimated_size; then
        return 1
    fi
    
    print_status "$CYAN" "📊" "Estimated backup size: $(numfmt --to=iec $total_size)"
    
    # Create backup
    local start_time=$(date +%s)
    
    if tar -czf "$backup_path" \
        --exclude-backups \
        "${exclude_args[@]}" \
        "${valid_sources[@]}" 2>> "$LOG_FILE"; then
        
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local backup_size=$(stat -f%z "$backup_path" 2>/dev/null || stat -c%s "$backup_path" 2>/dev/null || echo "0")
        
        print_status "$GREEN" "✅" "Backup created successfully: $backup_path"
        print_status "$GREEN" "💾" "Backup size: $(numfmt --to=iec $backup_size), Duration: ${duration}s"
        
        echo "$backup_path"
        return 0
    else
        print_status "$RED" "❌" "Backup creation failed"
        # Clean up failed backup
        [[ -f "$backup_path" ]] && rm -f "$backup_path"
        return 1
    fi
}

# List existing backups
list_backups() {
    print_status "$BLUE" "📋" "Existing backups in $BACKUP_DIR:"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        print_status "$YELLOW" "ℹ️" "Backup directory does not exist"
        return
    fi
    
    local backups=("$BACKUP_DIR"/backup_*.tar.gz)
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        print_status "$YELLOW" "ℹ️" "No backups found"
        return
    fi
    
    for backup in "${backups[@]}"; do
        if [[ -f "$backup" ]]; then
            local size=$(stat -f%z "$backup" 2>/dev/null || stat -c%s "$backup" 2>/dev/null || echo "0")
            local date_str=$(basename "$backup" | sed 's/backup_\([0-9]\{8\}\)_\([0-9]\{6\}\)\.tar\.gz/\1 \2/' | sed 's/\(....\)\(..\)\(..\) \(..\)\(..\)\(..\)/\1-\2-\3 \4:\5:\6/')
            echo -e "  ${GREEN}📁 ${backup}${NC}"
            echo -e "     Size: ${CYAN}$(numfmt --to=iec $size)${NC}, Date: ${CYAN}${date_str}${NC}"
        fi
    done
}

# Clean old backups
clean_old_backups() {
    print_status "$YELLOW" "🧹" "Cleaning backups older than $RETENTION_DAYS days..."
    
    local deleted_count=0
    local current_time=$(date +%s)
    
    for backup in "$BACKUP_DIR"/backup_*.tar.gz; do
        if [[ -f "$backup" ]]; then
            local backup_time
            case $OS_TYPE in
                linux)
                    backup_time=$(stat -c %Y "$backup")
                    ;;
                macos)
                    backup_time=$(stat -f %m "$backup")
                    ;;
                windows)
                    backup_time=$(stat -c %Y "$backup" 2>/dev/null || echo "0")
                    ;;
            esac
            
            local backup_age=$(( (current_time - backup_time) / 86400 ))  # Convert to days
            
            if [[ $backup_age -gt $RETENTION_DAYS ]]; then
                print_status "$CYAN" "🗑️" "Deleting old backup: $(basename "$backup") (${backup_age} days old)"
                rm -f "$backup"
                ((deleted_count++))
            fi
        fi
    done
    
    print_status "$GREEN" "✅" "Cleaning completed. Deleted $deleted_count old backups"
}

# Restore backup
restore_backup() {
    local backup_file="$1"
    local restore_dir="${2:-./restored}"
    
    if [[ ! -f "$backup_file" ]]; then
        print_status "$RED" "❌" "Backup file not found: $backup_file"
        return 1
    fi
    
    print_status "$BLUE" "🔄" "Restoring backup: $backup_file to $restore_dir"
    
    mkdir -p "$restore_dir"
    
    if tar -xzf "$backup_file" -C "$restore_dir" 2>> "$LOG_FILE"; then
        print_status "$GREEN" "✅" "Backup restored successfully to $restore_dir"
        return 0
    else
        print_status "$RED" "❌" "Backup restoration failed"
        return 1
    fi
}

# Show usage information
show_usage() {
    cat << EOF
${BLUE}💾 Advanced Backup Manager${NC}

${GREEN}Usage:${NC}
  $0 [OPTIONS] [SOURCES...]

${GREEN}Options:${NC}
  -c, --create              Create a new backup
  -l, --list                List existing backups
  -r, --restore FILE        Restore from backup file
  -d, --dir DIR             Set backup directory (default: $BACKUP_DIR)
  --retention DAYS          Set retention days (default: 30)
  --clean                   Clean old backups
  --config                  Show current configuration
  --save-config             Save current configuration
  -i, --inspect FILE        Show contents of backup file (first 50 files)
  -I, --inspect-all FILE    Show all contents of backup file
  --extract-view FILE       Extract and view backup contents in temp directory
  -h, --help                Show this help message

${GREEN}Examples:${NC}
  $0 -c ~/Documents ~/Projects
  $0 -l
  $0 -r /tmp/backups/backup_20231022_143022.tar.gz
  $0 --clean
  $0 --config
  $0 -i /c/MyBackups/backup_20251022_202738.tar.gz
  $0 --extract-view /c/MyBackups/backup_20251022_202738.tar.gz

${GREEN}Configuration file:${NC} $CONFIG_FILE
${GREEN}Log file:${NC} $LOG_FILE
EOF
}

# Main function
main() {
    local action="create"
    local restore_file=""
    local restore_dir=""
    local backup_file=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--create)
                action="create"
                shift
                ;;
            -l|--list)
                action="list"
                shift
                ;;
            -r|--restore)
                action="restore"
                restore_file="$2"
                shift 2
                ;;
            --restore-dir)
                restore_dir="$2"
                shift 2
                ;;
            -d|--dir)
                BACKUP_DIR="$2"
                shift 2
                ;;
            --retention)
                RETENTION_DAYS="$2"
                shift 2
                ;;
            --clean)
                action="clean"
                shift
                ;;
            --config)
                action="config"
                shift
                ;;
            --save-config)
                action="save_config"
                shift
                ;;
            -i|--inspect)
                action="inspect"
                backup_file="$2"
                shift 2
                ;;
            -I|--inspect-all)
                action="inspect_all"
                backup_file="$2"
                shift 2
                ;;
            --extract-view)
                action="extract_view"
                backup_file="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                echo -e "${RED}Unknown option: $1${NC}"
                show_usage
                exit 1
                ;;
            *)
                SOURCES+=("$1")
                shift
                ;;
        esac
    done
    
    # Initialize
    load_config
    init_config
    
    case $action in
        create)
            echo -e "${BLUE}💾 Starting Backup Creation${NC}"
            echo "============================"
            if check_prerequisites; then
                create_backup
            fi
            ;;
        list)
            echo -e "${BLUE}📋 Backup Listing${NC}"
            echo "================="
            list_backups
            ;;
        restore)
            echo -e "${BLUE}🔄 Backup Restoration${NC}"
            echo "===================="
            if [[ -n "$restore_file" ]]; then
                restore_backup "$restore_file" "$restore_dir"
            else
                print_status "$RED" "❌" "No backup file specified for restoration"
            fi
            ;;
        clean)
            echo -e "${BLUE}🧹 Cleaning Old Backups${NC}"
            echo "========================"
            clean_old_backups
            ;;
        config)
            echo -e "${BLUE}⚙️ Current Configuration${NC}"
            echo "========================"
            echo -e "Backup Directory: ${GREEN}$BACKUP_DIR${NC}"
            echo -e "Retention Days: ${GREEN}$RETENTION_DAYS${NC}"
            echo -e "Compression Level: ${GREEN}$COMPRESSION_LEVEL${NC}"
            echo -e "Sources:"
            for source in "${SOURCES[@]}"; do
                echo -e "  - ${GREEN}$source${NC}"
            done
            echo -e "Exclude Patterns:"
            for pattern in "${EXCLUDE_PATTERNS[@]}"; do
                echo -e "  - ${YELLOW}$pattern${NC}"
            done
            ;;
        save_config)
            save_config
            ;;
        inspect)
            if [[ -n "$backup_file" ]]; then
                show_backup_contents "$backup_file" 50
            else
                print_status "$RED" "❌" "No backup file specified for inspection"
            fi
            ;;
        inspect_all)
            if [[ -n "$backup_file" ]]; then
                show_backup_contents "$backup_file" 1000000
            else
                print_status "$RED" "❌" "No backup file specified for inspection"
            fi
            ;;
        extract_view)
            if [[ -n "$backup_file" ]]; then
                inspect_backup "$backup_file"
            else
                print_status "$RED" "❌" "No backup file specified for extraction view"
            fi
            ;;
    esac
    
    echo -e "\n${CYAN}📝 Detailed log: $LOG_FILE${NC}"
}

# Run main function
main "$@"