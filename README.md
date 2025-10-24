# 🧰 Bash Toolbox

Collection of lightweight, cross-platform Bash scripts for developers, sysadmins, and DevOps. Automate system monitoring, service checks, backups, log cleanup, and network tasks with minimal dependencies. Works on Linux, macOS, and hybrid environments.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/bash-4.0%2B-brightgreen.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macOS-blue.svg)](https://github.com/ArtemRivnyi/bash-toolbox)

---

## 📑 Table of Contents

- [✨ Overview](#-overview)
- [📂 Project Structure](#-project-structure)
- [🚀 Quick Start](#-quick-start)
- [🚀 Script Status](#-script-status)
- [🎯 Detailed Scripts](#-detailed-scripts)
  - [Monitoring Scripts (with Telegram)](#monitoring-scripts-with-telegram)
  - [Utility Scripts](#utility-scripts)
- [💡 Notification Philosophy](#-notification-philosophy)
- [🆕 Roadmap](#-roadmap)
- [🤝 Contributing](#-contributing)
- [🧰 Maintainer](#-maintainer)

---

## ✨ Overview

This toolkit provides seven powerful scripts for maintaining infrastructure health and stability. All scripts are designed with cross-platform compatibility in mind and use a unified approach to configuration.

### Key Features

- 🌍 **Cross-Platform**: Works on Linux and macOS (Windows support via Git Bash - experimental)
- ⚡ **Minimal Dependencies**: Uses standard utilities (bash, tar, gzip, curl/wget, grep, awk)
- 📱 **Smart Telegram Notifications**: Critical, Warning, and Recovery alerts with cooldown protection
- 🎨 **Color-Coded Output**: Enhanced console readability
- 📊 **Comprehensive Logging**: Detailed logs for all operations
- 🔧 **Easy Configuration**: Interactive setup or direct config file editing
- 🤖 **Automation-Focused**: Designed for cron jobs and CI/CD pipelines
- 🧩 **Modular Design**: Self-contained scripts for easy integration

---

## 📂 Project Structure

```
bash-toolbox/
├── backup-manager.sh          # Backup creation and management
├── disk-usage-alert.sh        # Disk space monitoring with alerts
├── internet-check.sh          # Internet connectivity diagnostics
├── log-cleaner.sh             # Log file cleanup and rotation
├── service-health-check.sh    # System service monitoring
├── system-monitor.sh          # CPU/RAM/Disk monitoring
├── telegram-ping-monitor.sh   # Host availability monitoring
├── .gitignore                 # Git ignore patterns
└── README.md                  # This file
```

---

## 🚀 Quick Start

### Installation

```bash
git clone https://github.com/ArtemRivnyi/bash-toolbox.git
cd bash-toolbox
chmod +x *.sh
```

### Usage Example

```bash
# Configure script interactively
./telegram-ping-monitor.sh config

# Start monitoring
./telegram-ping-monitor.sh start

# Check status
./telegram-ping-monitor.sh status
```

---

## 🚀 Script Status

### Monitoring Scripts (with Telegram)

These scripts support full Telegram integration with severity levels (CRITICAL/WARNING/RECOVERY) and alert cooldowns.

| Script | Description | Alert Methods | Features |
|--------|-------------|---------------|----------|
| `telegram-ping-monitor.sh` | Host availability monitoring | Telegram only | Multi-host, status transitions, cooldown |
| `disk-usage-alert.sh` | Disk space monitoring | Console / Telegram / Both | Dual thresholds, cross-platform |
| `service-health-check.sh` | Service health monitoring | Telegram only | Multi-init support (systemd/launchctl) |
| `internet-check.sh` | Internet connectivity check | Console / Telegram / Both | Ping/DNS/HTTP diagnostics, recovery alerts |
| `system-monitor.sh` | Resource monitoring | Console / Telegram / Both | CPU/RAM/Disk, recovery alerts |

### Utility Scripts

Diagnostic and maintenance tools without real-time Telegram integration (following notification philosophy).

| Script | Description | Features |
|--------|-------------|----------|
| `backup-manager.sh` | Backup management | Compression, retention, inspection, restoration |
| `log-cleaner.sh` | Log cleanup & rotation | Age-based cleanup, count-based rotation, dry-run |

---

## 🎯 Detailed Scripts

### Monitoring Scripts (with Telegram)

---

#### 📡 telegram-ping-monitor.sh

**Host Availability Monitoring** - Monitors specified hosts using ping and sends Telegram notifications on status changes.

##### Features

| Feature | Details |
|---------|---------|
| Status Detection | Tracks: up, degraded (packet loss), down |
| Multi-Host | Monitors multiple hosts from configurable list |
| Smart Alerts | Only sends notifications on status changes |
| Cooldown | Prevents spam (default: 300s) |
| Cross-Platform | Adapts ping syntax for Linux/macOS/Windows |
| Persistent State | Saves states between runs |

##### Commands

```bash
./telegram-ping-monitor.sh config   # Interactive configuration
./telegram-ping-monitor.sh start    # Start monitoring loop
./telegram-ping-monitor.sh status   # Show current host status
./telegram-ping-monitor.sh test     # Test Telegram notifications
./telegram-ping-monitor.sh log      # Display recent logs
./telegram-ping-monitor.sh help     # Show usage info
```

##### Configuration

**Location**: `~/.telegram-ping-monitor.conf`

```bash
TELEGRAM_BOT_TOKEN="your_bot_token_here"
TELEGRAM_CHAT_ID="your_chat_id_here"
MONITOR_HOSTS=(8.8.8.8 1.1.1.1 google.com)
CHECK_INTERVAL=60        # Check every 60 seconds
ALERT_COOLDOWN=300       # Wait 5 minutes between duplicate alerts
PING_TIMEOUT=5           # Ping timeout in seconds
PING_COUNT=3             # Number of ping packets per check
```

##### Example Alerts

**Host Down:**
```
🚨 CRITICAL - Host Down
Host: google.com
Time: 2025-10-24 14:30:00
Previous state: up
```

**Recovery:**
```
✅ RECOVERY - Host Back Online
Host: google.com
Time: 2025-10-24 14:35:00
Previous state: down
```

---

#### 💾 disk-usage-alert.sh

**Disk Space Monitoring** - Monitors disk usage for specified mount points with configurable thresholds.

##### Features

- Flexible alert methods (console, Telegram, or both)
- Dual thresholds (Warning: 80%, Critical: 90%)
- Cross-platform support (Linux/macOS/Windows)
- Color-coded console output (Green/Yellow/Red)
- Multi-mount support
- Per-mount cooldown tracking

##### Commands

```bash
./disk-usage-alert.sh config    # Interactive setup
./disk-usage-alert.sh start     # Start monitoring
./disk-usage-alert.sh status    # Show current disk usage
./disk-usage-alert.sh test      # Test notifications
./disk-usage-alert.sh log       # Display logs
./disk-usage-alert.sh showcfg   # Display configuration
./disk-usage-alert.sh help      # Show usage
```

##### Configuration

**Location**: `~/.disk-usage-alert.conf`

```bash
ALERT_METHOD="both"              # console, telegram, or both
TELEGRAM_BOT_TOKEN="your_token"
TELEGRAM_CHAT_ID="your_chat_id"
WARNING_THRESHOLD=80             # Warning at 80%
CRITICAL_THRESHOLD=90            # Critical at 90%
CHECK_INTERVAL=300               # Check every 5 minutes
ALERT_COOLDOWN=3600              # Cooldown: 1 hour
MONITOR_MOUNTS=(/ /mnt/data)     # Unix: /, Windows: C:
```

##### Example Output

```
Disk Usage Check - 2025-10-24 14:30:00
======================================
/: 45% used - NORMAL
/mnt/data: 85% used - WARNING
C:: 92% used - 🚨 CRITICAL

🚨 CRITICAL: Disk usage for C: is 92% (threshold: 90%)
```

---

#### 🔧 service-health-check.sh

**Service Monitoring** - Monitors critical system services and alerts on failures and recoveries.

##### Features

- Multi-init support (systemd, launchctl, Windows sc)
- Status tracking (running, stopped, unknown)
- Change-based alerts only
- Automatic init system detection
- Persistent state tracking
- Configurable service list

##### Commands

```bash
./service-health-check.sh config   # Interactive setup
./service-health-check.sh start    # Start monitoring
./service-health-check.sh status   # Show service status
./service-health-check.sh test     # Test Telegram
./service-health-check.sh log      # Display logs
./service-health-check.sh help     # Show usage
```

##### Configuration

**Location**: `~/.service-health-check.conf`

```bash
TELEGRAM_BOT_TOKEN="your_token"
TELEGRAM_CHAT_ID="your_chat_id"
CHECK_INTERVAL=60                           # Check every minute
ALERT_COOLDOWN=300                          # 5-minute cooldown
MONITOR_SERVICES=(docker nginx ssh mysql)   # Services to monitor
```

---

#### 🌐 internet-check.sh

**Internet Connectivity Diagnostics** - Multi-stage diagnostics (Ping, DNS, HTTP/HTTPS) with failure and recovery alerts.

##### Features

- Multi-stage checks (Ping → DNS → HTTP/HTTPS)
- CRITICAL/WARNING severity levels
- Configurable alert methods
- Cooldown protection
- Cross-platform network commands
- Persistent state for recovery detection

##### Commands

```bash
./internet-check.sh config   # Interactive configuration
./internet-check.sh start    # Start monitoring
./internet-check.sh status   # Show last check result
./internet-check.sh test     # Test notifications
./internet-check.sh log      # Display logs
./internet-check.sh help     # Show usage
```

##### Configuration

**Location**: `~/.internet-check.conf`

```bash
ALERT_METHOD="both"              # console, telegram, or both
TELEGRAM_BOT_TOKEN="your_token"
TELEGRAM_CHAT_ID="your_chat_id"
CHECK_INTERVAL=300               # Check every 5 minutes
ALERT_COOLDOWN=900               # Cooldown: 15 minutes
ALERT_ON_SUCCESS=false           # Only alert on failure/recovery
```

##### Example Output

```
==========================================
🌐 Comprehensive Internet Connectivity Check
==========================================
Detected OS: linux-ubuntu
Kernel: Linux 6.5.0-1018-oem x86_64

📡 Checking network connectivity...
Testing 8.8.8.8... ✓
Testing 1.1.1.1... ✗
Testing 208.67.222.222... ✗
⚠️ Network connectivity: DEGRADED - 1/3 targets reachable

🔍 Testing DNS resolution...
google.com... ✓
github.com... ✗
cloudflare.com... ✗
⚠️ DNS resolution: DEGRADED - 1/3 domains resolved

🚨 CRITICAL: Internet connectivity is severely degraded
```

---

#### 🖥️ system-monitor.sh

**System Resource Monitoring** - Tracks CPU, RAM, and Disk usage with dual thresholds and recovery alerts.

##### Features

- Multi-metric monitoring (CPU/RAM/Disk)
- Dual thresholds (WARNING/CRITICAL)
- Stateful alerting (alerts only on state change)
- Recovery notifications
- Configurable alert methods
- Cross-platform commands
- Per-metric cooldown

##### Commands

```bash
./system-monitor.sh config    # Interactive configuration
./system-monitor.sh start     # Start monitoring
./system-monitor.sh status    # Show last check
./system-monitor.sh test      # Test notifications
./system-monitor.sh log       # Display logs
./system-monitor.sh showcfg   # Display configuration
./system-monitor.sh help      # Show usage
```

##### Configuration

**Location**: `~/.system-monitor.conf`

```bash
ALERT_METHOD="both"              # console, telegram, or both
TELEGRAM_BOT_TOKEN="your_token"
TELEGRAM_CHAT_ID="your_chat_id"
CHECK_INTERVAL=300               # Check every 5 minutes
ALERT_COOLDOWN=900               # Cooldown: 15 minutes
CPU_WARNING=60                   # CPU Warning at 60%
CPU_CRITICAL=85                  # CPU Critical at 85%
RAM_WARNING=70                   # RAM Warning at 70%
RAM_CRITICAL=90                  # RAM Critical at 90%
DISK_WARNING=75                  # Disk Warning at 75%
DISK_CRITICAL=90                 # Disk Critical at 90%
```

##### Example Output

```
==========================================
🖥️ System Resource Monitor
==========================================
Timestamp: 2025-10-24 14:30:00
OS: linux

CPU Usage: 65.2%
RAM Usage: 72.8%
Disk Usage: 45%

⚠️ WARNING: RAM usage is HIGH: 72.8% (threshold: 70%)
```

---

### Utility Scripts

---

#### 💾 backup-manager.sh

**Backup Creation and Management** - Comprehensive backup solution with compression and retention policies.

##### Features

- Creates compressed archives (.tar.gz)
- Retention policy (auto-delete old backups)
- Cross-platform (uses tar/gzip)
- Multiple source directories
- Inspection mode (list archive contents)
- Safe restoration

##### Commands

```bash
./backup-manager.sh config                    # Interactive configuration
./backup-manager.sh create                    # Create timestamped backup
./backup-manager.sh clean                     # Apply retention policy
./backup-manager.sh list                      # List existing backups
./backup-manager.sh inspect <file>            # List backup contents
./backup-manager.sh restore <file> <target>   # Extract backup
./backup-manager.sh help                      # Show usage
```

##### Configuration

**Location**: `~/.backup-manager.conf`

```bash
BACKUP_DIR="/tmp/backups"                    # Backup storage directory
BACKUP_SOURCES=("/home/user/Documents" "/home/user/scripts")
RETENTION_COUNT=7                            # Keep last 7 backups
```

---

#### 🧹 log-cleaner.sh

**Log Cleanup and Rotation** - Automates log file cleanup with age-based and count-based strategies.

##### Features

- Age-based cleanup (delete files older than X days)
- Count-based rotation (keep only N newest files)
- Dry-run mode (safe simulation)
- Flexible target directories
- Minimal dependencies (bash + find)

##### Commands

```bash
./log-cleaner.sh clean <path> <days>          # Delete files older than <days>
./log-cleaner.sh rotate <path> <count>        # Keep <count> newest files
./log-cleaner.sh dry-run clean <path> <days>  # Simulate cleanup
./log-cleaner.sh dry-run rotate <path> <count> # Simulate rotation
./log-cleaner.sh help                         # Show usage
```

##### Example Usage

```bash
# Delete logs older than 30 days
./log-cleaner.sh clean /var/log/app +30

# Keep only 10 newest archive files
./log-cleaner.sh rotate /var/log/app/archive 10

# Dry-run to see what would be deleted
./log-cleaner.sh dry-run clean /var/log/app +30
```

##### Example Output

```
==========================================
🧹 Log Cleaner - Dry Run Mode
==========================================
Action: Clean (Older than 30 days)
Target Directory: /var/log/app

[DRY-RUN] Would delete: /var/log/app/log_2025-09-01.log (35 days old)
[DRY-RUN] Would delete: /var/log/app/log_2025-09-15.log (21 days old)
[DRY-RUN] Would keep: /var/log/app/log_2025-10-01.log
[DRY-RUN] Would keep: /var/log/app/log_2025-10-24.log

Dry run complete. 2 files would be deleted.
```

---

## 💡 Notification Philosophy

The project follows a **smart, non-spammy alerting** approach to ensure notifications are actionable and represent significant state changes.

### Why Not All Scripts Have Telegram Integration

| Script | Recommendation | Rationale |
|--------|----------------|-----------|
| `backup-manager.sh` | ❌ NOT a priority | Scheduled task; daily "Backup completed" messages would clutter Telegram. **Better**: Daily summary or only ERROR notifications (backup failed, disk full). |
| `log-cleaner.sh` | ❌ NOT needed | Routine maintenance; success requires no notification. **Exception**: Alert only on FAILURE (permission denied, disk full). |

### When to Send Notifications

✅ **DO send alerts for:**
- State changes (service stopped → running)
- Threshold breaches (disk usage: normal → warning → critical)
- Recovery events (host down → host up)
- Errors and failures

❌ **DON'T send alerts for:**
- Routine successful operations
- Every periodic check (use state tracking instead)
- Redundant information

---

## 🆕 Roadmap

Future enhancements planned for upcoming releases.

| Priority | Feature | Status | Notes |
|----------|---------|--------|-------|
| **P1 (v1.1)** | Smart Telegram for system-monitor + internet-check | ✅ **DONE** | State tracking and recovery alerts implemented |
| **P1 (v1.1)** | Severity levels (CRITICAL/WARNING/INFO) | ✅ **DONE** | Integrated into monitoring scripts |
| **P1 (v1.1)** | Daily summary for backup-manager | ⏳ **PENDING** | Planned for v1.1 release |
| **P2 (v1.2)** | Email notifications (fallback) | ⏳ **PENDING** | For non-Telegram environments |
| **P2 (v1.2)** | Webhook support (Slack, Discord, Teams) | ⏳ **PENDING** | Corporate communication integration |
| **P3 (v2.0)** | Prometheus exporter | ⏳ **PENDING** | Time-series monitoring |
| **P3 (v2.0)** | Grafana dashboard templates | ⏳ **PENDING** | Metrics visualization |
| **P3 (v2.0)** | Docker Compose deployment | ⏳ **PENDING** | Containerized deployment |

---

## 🤝 Contributing

Contributions are welcome! If you have improvements or useful scripts:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Contribution Guidelines

- Follow existing code style and structure
- Include documentation and examples
- Test on multiple platforms (Linux/macOS)
- Update README if adding new features

---

## 🧰 Maintainer

**Artem Rivnyi**  
Junior Technical Support / DevOps Enthusiast

- GitHub: [@ArtemRivnyi](https://github.com/ArtemRivnyi)
- Repository: [bash-toolbox](https://github.com/ArtemRivnyi/bash-toolbox)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 🙏 Acknowledgments

- Thanks to the open-source community for inspiration
- Built with standard Unix/Linux tools for maximum compatibility
- Designed with DevOps best practices in mind

---

**⭐ If you find this toolbox useful, please consider giving it a star on GitHub!**
