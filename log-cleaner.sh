#!/bin/bash

# Simple Log Cleaner for Windows/Linux/macOS
# No colors, no emojis, just pure functionality

# Configuration
CONFIG_FILE="${HOME}/.log-cleaner.conf"
LOG_FILE="/tmp/log-cleaner.log"
DRY_RUN=false

# Default settings
LOG_PATHS=("/tmp" "/var/log" "${HOME}/.cache")
CLEAN_PATTERNS=("*.log" "*.log.*" "*.tmp" "*.cache")
EXCLUDE_PATTERNS=("*.important" "*.critical")

# Initialize configuration
init_config() {
    RETENTION_DAYS=${RETENTION_DAYS:-30}
    MAX_LOG_SIZE_MB=${MAX_LOG_SIZE_MB:-100}
    KEEP_LAST_FILES=${KEEP_LAST_FILES:-10}
}

# Simple logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Simple print
print_msg() {
    echo "$1"
    log_message "$1"
}

# Find and clean old files
clean_old_files() {
    local cleaned_count=0
    
    for path in "${LOG_PATHS[@]}"; do
        if [[ -d "$path" ]]; then
            print_msg "Checking $path for files older than $RETENTION_DAYS days..."
            
            # Find files matching patterns
            for pattern in "${CLEAN_PATTERNS[@]}"; do
                while IFS= read -r file; do
                    if [[ -n "$file" && -f "$file" ]]; then
                        # Check if file should be excluded
                        local exclude=0
                        for exclude_pattern in "${EXCLUDE_PATTERNS[@]}"; do
                            if [[ "$(basename "$file")" == $exclude_pattern ]]; then
                                exclude=1
                                break
                            fi
                        done
                        
                        if [[ $exclude -eq 0 ]]; then
                            if $DRY_RUN; then
                                print_msg "WOULD DELETE: $file"
                            else
                                if rm -f "$file"; then
                                    print_msg "DELETED: $file"
                                    ((cleaned_count++))
                                else
                                    print_msg "FAILED: $file"
                                fi
                            fi
                        fi
                    fi
                done < <(find "$path" -name "$pattern" -type f -mtime "+$RETENTION_DAYS" 2>/dev/null || true)
            done
        fi
    done
    
    return $cleaned_count
}

# Rotate files
rotate_files() {
    local rotated_count=0
    
    for path in "${LOG_PATHS[@]}"; do
        if [[ -d "$path" ]]; then
            for pattern in "${CLEAN_PATTERNS[@]}"; do
                while IFS= read -r file; do
                    if [[ -n "$file" && -f "$file" ]]; then
                        if $DRY_RUN; then
                            print_msg "WOULD ROTATE: $file"
                        else
                            if rm -f "$file"; then
                                print_msg "ROTATED: $file"
                                ((rotated_count++))
                            fi
                        fi
                    fi
                done < <(find "$path" -name "$pattern" -type f 2>/dev/null | sort -r | tail -n +$((KEEP_LAST_FILES + 1)) || true)
            done
        fi
    done
    
    return $rotated_count
}

# Show usage
show_usage() {
    cat << EOF
Simple Log Cleaner

Usage:
  $0 [OPTIONS]

Options:
  -a, --age DAYS    Set retention days (default: 30)
  -k, --keep COUNT  Keep last N files (default: 10)
  --dry-run         Show what would be deleted
  -h, --help        Show this help

Examples:
  $0 --dry-run
  $0 --age 7
  $0 --age 7 --keep 5

Log file: $LOG_FILE
EOF
}

# Main function
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--age)
                RETENTION_DAYS="$2"
                shift 2
                ;;
            -k|--keep)
                KEEP_LAST_FILES="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Initialize
    init_config
    
    echo "Starting Log Cleaner"
    echo "==================="
    
    if $DRY_RUN; then
        echo "DRY RUN MODE - No files will be deleted"
        echo "======================================="
    fi
    
    # Clean old files
    print_msg "Cleaning files older than $RETENTION_DAYS days..."
    clean_old_files
    cleaned=$?
    
    # Rotate files
    print_msg "Rotating files (keeping last $KEEP_LAST_FILES)..."
    rotate_files
    rotated=$?
    
    # Summary
    echo "==================="
    if $DRY_RUN; then
        echo "DRY RUN COMPLETED"
        echo "Would delete: $cleaned files"
        echo "Would rotate: $rotated files"
    else
        echo "CLEANING COMPLETED"
        echo "Deleted: $cleaned files"
        echo "Rotated: $rotated files"
    fi
    
    echo "Log: $LOG_FILE"
}

# Run
main "$@"