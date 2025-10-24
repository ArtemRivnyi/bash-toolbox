# ⚙️ Bash Toolkit: Essential System Administration Scripts

[![Shell](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Collection of lightweight, cross-platform **Bash scripts** for developers, sysadmins, and DevOps. This toolbox is designed to **automate routine system monitoring, service checks, backups, log cleanup, and network tasks** with minimal dependencies, making it ideal for quick deployment in any Linux or macOS environment.

## 📋 Table of Contents

*   [✨ Overview](#-overview)
*   [📂 Project Structure](#-project-structure)
*   [🚀 Quick Start](#-quick-start)
*   [🚀 Current Script Status](#-current-script-status)
    *   [✅ Scripts with Smart Telegram Integration](#-scripts-with-smart-telegram-integration)
    *   [⚙️ Core Utility Scripts](#️-core-utility-scripts)
*   [🎯 Detailed Description and Capabilities](#-detailed-description-and-capabilities)
    *   [📡 telegram-ping-monitor.sh](#-telegram-ping-monitorsh---host-availability-monitoring)
    *   [💾 disk-usage-alert.sh](#-disk-usage-alertsh---disk-space-monitoring)
    *   [💚 service-health-check.sh](#-service-health-checksh---system-service-monitoring)
    *   [🌐 internet-check.sh](#-internet-checksh---comprehensive-internet-connectivity-check)
    *   [🖥️ system-monitor.sh](#️-system-monitorsh---system-resource-monitoring)
    *   [📦 backup-manager.sh](#-backup-managersh---backup-management)
    *   [🧹 log-cleaner.sh](#-log-cleanersh---log-cleanup-and-rotation)
*   [💡 Notification Philosophy and Best Practices](#-notification-philosophy-and-best-practices)
*   [🆕 Future Innovations and Roadmap](#-future-innovations-and-roadmap)
*   [🧰 Maintainer](#-maintainer)

---

## ✨ Overview

This toolkit provides seven powerful scripts for maintaining the health and stability of your infrastructure. All scripts are designed with cross-platform compatibility in mind (Linux, macOS, Windows via Git Bash) and use a unified approach to configuration for alerts where applicable.

**Key Features:**
- 🌍 Cross-platform compatibility (Linux, macOS, Windows)
- 📱 **Smart Telegram notification support** for critical and recovery events
- 🚨 **Severity Levels:** Alerts classified as CRITICAL, WARNING, or RECOVERY
- 🎨 Color-coded console output for better readability
- 📊 Comprehensive logging for all operations
- ⚡ Minimal dependencies (bash, tar, gzip, curl/wget)
- 🔧 Easy configuration via interactive setup or config files

---

## 📂 Project Structure

The project maintains a simple, flat structure for ease of use and portability.

```
.
├── backup-manager.sh              # Backup creation and management
├── disk-usage-alert.sh           # Disk space monitoring with alerts
├── internet-check.sh             # Internet connectivity diagnostics
├── log-cleaner.sh                # Log file cleanup and rotation
├── service-health-check.sh       # System service monitoring
├── system-monitor.sh             # CPU/RAM/Disk monitoring
├── telegram-ping-monitor.sh      # Host availability monitoring
├── .gitignore                    # Git ignore patterns
└── README.md                     # This file
```
## 🚀 Quick Start

To use any script, simply clone the repository and make the script executable:

```bash
git clone https://github.com/ArtemRivnyi/bash-toolbox.git
cd bash-toolbox
chmod +x <script_name>.sh
./<script_name>.sh
```

---

## 🚀 Current Script Status

### ✅ Scripts with Smart Telegram Integration

These scripts include full Telegram notification support with configurable alert methods (console, telegram, or both), incorporating severity levels (CRITICAL/WARNING/RECOVERY) and alert cooldowns.

| Script | Description | Alert Methods | Key Features |
|:-------|:------------|:--------------|:-------------|
| **telegram-ping-monitor.sh** | Host availability monitoring | Telegram only | Multi-host monitoring, status transitions, cooldown protection |
| **disk-usage-alert.sh** | Disk space monitoring | Console / Telegram / Both | Warning & critical thresholds, cross-platform disk checks |
| **service-health-check.sh** | System service monitoring | Telegram only | Multi-init system support (systemd/launchctl/sc), failure alerts |
| **internet-check.sh** | **Comprehensive Internet Connectivity Check** | Console / Telegram / Both | Multi-stage diagnostics (Ping, DNS, HTTP/HTTPS), **Recovery Alerts** |
| **system-monitor.sh** | **System Resource Monitoring** | Console / Telegram / Both | CPU, RAM, Disk usage monitoring, **Recovery Alerts** |

### ⚙️ Core Utility Scripts

These scripts are fully functional diagnostic and utility tools, currently without real-time Telegram integration, following the project's notification philosophy.

| Script | Description | Key Features |
|:-------|:------------|:-------------|
| **backup-manager.sh** | Backup creation and management | Compression, retention, inspection, restoration |
| **log-cleaner.sh** | Log cleanup and rotation | Age-based cleanup, count-based rotation, dry-run mode |

---

## 🎯 Detailed Description and Capabilities

### 📡 `telegram-ping-monitor.sh` - Host Availability Monitoring

Monitors the availability of specified hosts using ping and sends Telegram notifications when status changes occur.

#### 🔧 Core Capabilities

| Feature | Implementation |
|:--------|:---------------|
| **Status Detection** | Tracks three states: `up`, `degraded` (partial packet loss), `down` |
| **Multi-Host Support** | Monitors multiple hosts simultaneously from a configurable list |
| **Smart Alerts** | Only sends notifications on status changes (not on every check) |
| **Cooldown Protection** | Prevents alert spam with configurable cooldown period (default: 300s) |
| **Cross-Platform** | Adapts ping syntax for Linux (`-c -W`), macOS (`-c -t`), Windows (`-n -w`) |
| **Persistent State** | Saves host states between runs for accurate change detection |

#### 📋 Commands

| Command | Description | Example |
|:--------|:------------|:--------|
| `config` | Interactive configuration (bot token, chat ID, hosts, intervals) | `./telegram-ping-monitor.sh config` |
| `start` | Start continuous monitoring loop | `./telegram-ping-monitor.sh start` |
| `status` | Show current status of all monitored hosts | `./telegram-ping-monitor.sh status` |
| `test` | Send test notification to verify Telegram setup | `./telegram-ping-monitor.sh test` |
| `log` | Display recent log entries (last 20 lines) | `./telegram-ping-monitor.sh log` |
| `help` | Show usage information | `./telegram-ping-monitor.sh help` |

#### 📝 Configuration File

Located at: `~/.telegram-ping-monitor.conf`

```bash
TELEGRAM_BOT_TOKEN="your_bot_token_here"
TELEGRAM_CHAT_ID="your_chat_id_here"
MONITOR_HOSTS=(8.8.8.8 1.1.1.1 google.com)
CHECK_INTERVAL=60           # Check every 60 seconds
ALERT_COOLDOWN=300          # Wait 5 minutes between duplicate alerts
PING_TIMEOUT=5              # Ping timeout in seconds
PING_COUNT=3                # Number of ping packets per check
```

#### 💬 Example Telegram Messages

**Host Down Alert:**
```
🚨 CRITICAL - Host Down
Host: google.com
Time: 2025-10-24 14:30:00
Previous state: up
```

**Recovery Notification:**
```
✅ RECOVERY - Host Back Online
Host: google.com
Time: 2025-10-24 14:35:00
Previous state: down
```

---

### 💾 `disk-usage-alert.sh` - Disk Space Monitoring

Monitors disk space usage for specified mount points and sends alerts when thresholds are exceeded.

#### 🔧 Core Capabilities

| Feature | Implementation |
|:--------|:---------------|
| **Flexible Alert Methods** | Choose between: console only, Telegram only, or both |
| **Dual Thresholds** | Warning (default: 80%) and Critical (default: 90%) levels |
| **Cross-Platform** | Uses `df` on Unix systems, PowerShell on Windows |
| **Color-Coded Output** | Green (normal), Yellow (warning), Red (critical) |
| **Multi-Mount Support** | Monitor multiple filesystems/drives simultaneously |
| **Smart Cooldown** | Prevents alert spam with per-mount cooldown tracking |

#### 📋 Commands

| Command | Description | Example |
|:--------|:------------|:--------|
| `config` | Interactive setup (alert method, thresholds, mounts) | `./disk-usage-alert.sh config` |
| `start` | Start continuous monitoring loop | `./disk-usage-alert.sh start` |
| `status` | Show current disk usage for all monitored mounts | `./disk-usage-alert.sh status` |
| `test` | Test notification system (method-dependent) | `./disk-usage-alert.sh test` |
| `log` | Display recent log entries | `./disk-usage-alert.sh log` |
| `showcfg` | Display current configuration | `./disk-usage-alert.sh showcfg` |
| `help` | Show usage information | `./disk-usage-alert.sh help` |

#### 📝 Configuration File

Located at: `~/.disk-usage-alert.conf`

```bash
ALERT_METHOD="both"              # console, telegram, or both
TELEGRAM_BOT_TOKEN="your_token"
TELEGRAM_CHAT_ID="your_chat_id"
WARNING_THRESHOLD=80             # Warning at 80% usage
CRITICAL_THRESHOLD=90            # Critical at 90% usage
CHECK_INTERVAL=300               # Check every 5 minutes
ALERT_COOLDOWN=3600              # Alert cooldown: 1 hour
MONITOR_MOUNTS=(/ /mnt/data)     # Unix: /, Windows: C:
```

#### 🎨 Console Output Example (Critical)

```bash
Disk Usage Check - 2025-10-24 14:30:00
======================================
  /: 45% used - NORMAL
  /mnt/data: 85% used - WARNING
  C:: 92% used - 🚨 CRITICAL

🚨 CRITICAL: Disk usage for C: is 92% (threshold: 90%)
```

---

### 💚 `service-health-check.sh` - System Service Monitoring

Monitors the status of critical system services and sends Telegram notifications on failures and recoveries.

#### 🔧 Core Capabilities

| Feature | Implementation |
|:--------|:---------------|
| **Multi-Init Support** | Supports systemd (Linux), launchctl (macOS), sc (Windows) |
| **Status Tracking** | Detects: running, stopped, unknown states |
| **Change Detection** | Only alerts on status transitions (running→stopped or stopped→running) |
| **Service Discovery** | Automatically detects appropriate init system |
| **Persistent State** | Tracks service states between runs |
| **Configurable Services** | Monitor any services via configuration |

#### 📋 Commands

| Command | Description | Example |
|:--------|:------------|:--------|
| `config` | Interactive setup (services list, check interval) | `./service-health-check.sh config` |
| `start` | Start continuous monitoring loop | `./service-health-check.sh start` |
| `status` | Show current status of all monitored services | `./service-health-check.sh status` |
| `test` | Send test Telegram notification | `./service-health-check.sh test` |
| `log` | Display recent log entries | `./service-health-check.sh log` |
| `help` | Show usage information | `./service-health-check.sh help` |

#### 📝 Configuration File

Located at: `~/.service-health-check.conf`

```bash
TELEGRAM_BOT_TOKEN="your_token"
TELEGRAM_CHAT_ID="your_chat_id"
CHECK_INTERVAL=60               # Check every minute
ALERT_COOLDOWN=300              # 5-minute cooldown
MONITOR_SERVICES=(docker nginx ssh apache2 mysql)  # Linux examples
```

#### 💬 Example Service Alerts

**Service Failure:**
```
🚨 CRITICAL - Service Stopped
Service: nginx
Status: stopped
Time: 2025-10-24 14:30:00
Previous state: running
```

**Service Recovery:**
```
✅ RECOVERY - Service Running
Service: nginx
Status: running
Time: 2025-10-24 14:35:00
Previous state: stopped
```

---

### 🌐 `internet-check.sh` - Comprehensive Internet Connectivity Check

Performs a multi-stage diagnostic check of internet connectivity (Ping, DNS resolution, HTTP/HTTPS access) and alerts on failures and subsequent recovery.

#### 🔧 Core Capabilities

| Feature | Implementation |
|:--------|:---------------|
| **Multi-Stage Check** | Sequential checks for Ping, DNS, and HTTP/HTTPS to pinpoint failure source |
| **Smart Alerting** | Uses `CRITICAL` for failures, `RECOVERY` for restoration of service |
| **Severity Levels** | Alerts are categorized as CRITICAL (full failure) or WARNING (degraded service) |
| **Configurable Alerts** | Choose between: console only, Telegram only, or both |
| **Cooldown Protection** | Prevents alert spam with a configurable cooldown period |
| **Cross-Platform** | Adapts network commands for Linux, macOS, and Windows environments |
| **Persistent State** | Tracks last known state to prevent duplicate alerts and enable recovery notifications |

#### 📋 Commands

| Command | Description | Example |
|:--------|:------------|:--------|
| `config` | Interactive configuration (Telegram, intervals, cooldowns) | `./internet-check.sh config` |
| `start` | Start continuous monitoring loop | `./internet-check.sh start` |
| `status` | Show the result of the last check | `./internet-check.sh status` |
| `test` | Send test notification to verify Telegram setup | `./internet-check.sh test` |
| `log` | Display recent log entries | `./internet-check.sh log` |
| `help` | Show usage information | `./internet-check.sh help` |

#### 📝 Configuration File

Located at: `~/.internet-check.conf`

```bash
ALERT_METHOD="both"              # console, telegram, or both
TELEGRAM_BOT_TOKEN="your_token"
TELEGRAM_CHAT_ID="your_chat_id"
CHECK_INTERVAL=300               # Check every 5 minutes
ALERT_COOLDOWN=900               # Alert cooldown: 15 minutes
ALERT_ON_SUCCESS=false           # Only alert on failure/recovery
```

#### 🎨 Console Output Example (Failure)

```bash
==========================================
🌐 Comprehensive Internet Connectivity Check
==========================================
Detected OS: linux-ubuntu
Kernel: Linux 6.5.0-1018-oem x86_64

📡 Checking network connectivity...
  Testing 8.8.8.8... ✓
  Testing 1.1.1.1... ✗
  Testing 208.67.222.222... ✗
⚠️  Network connectivity: DEGRADED - 1/3 targets reachable

🔍 Testing DNS resolution...
  google.com... ✓
  github.com... ✗
  cloudflare.com... ✗
⚠️  DNS resolution: DEGRADED - 1/3 domains resolved

🚨 CRITICAL: Internet connectivity is severely degraded. Ping/DNS checks failed.
```

---

### 🖥️ `system-monitor.sh` - System Resource Monitoring

Monitors CPU, RAM, and Disk usage with configurable warning and critical thresholds, sending alerts on breach and recovery.

#### 🔧 Core Capabilities

| Feature | Implementation |
|:--------|:---------------|
| **Multi-Metric Monitoring** | Tracks CPU usage, RAM usage, and Disk usage simultaneously |
| **Dual Thresholds** | Configurable `WARNING` and `CRITICAL` thresholds for each metric |
| **Stateful Alerting** | Tracks state (normal, warning, critical) to send alerts only on transition |
| **Recovery Alerts** | Sends `RECOVERY` notifications when a metric drops back to the `normal` state |
| **Configurable Alerts** | Choose between: console only, Telegram only, or both |
| **Cross-Platform** | Uses OS-specific commands (`top`, `free`, `df` on Unix; PowerShell on Windows) |
| **Cooldown Protection** | Prevents alert spam with a configurable cooldown period per metric |

#### 📋 Commands

| Command | Description | Example |
|:--------|:------------|:--------|
| `config` | Interactive configuration (Telegram, thresholds, intervals) | `./system-monitor.sh config` |
| `start` | Start continuous monitoring loop | `./system-monitor.sh start` |
| `status` | Show the result of the last check | `./system-monitor.sh status` |
| `test` | Send test notification to verify Telegram setup | `./system-monitor.sh test` |
| `log` | Display recent log entries | `./system-monitor.sh log` |
| `showcfg` | Display current configuration and thresholds | `./system-monitor.sh showcfg` |
| `help` | Show usage information | `./system-monitor.sh help` |

#### 📝 Configuration File

Located at: `~/.system-monitor.conf`

```bash
ALERT_METHOD="both"              # console, telegram, or both
TELEGRAM_BOT_TOKEN="your_token"
TELEGRAM_CHAT_ID="your_chat_id"
CHECK_INTERVAL=300               # Check every 5 minutes
ALERT_COOLDOWN=900               # Alert cooldown: 15 minutes
CPU_WARNING=60                   # CPU Warning at 60%
CPU_CRITICAL=85                  # CPU Critical at 85%
RAM_WARNING=70                   # RAM Warning at 70%
RAM_CRITICAL=90                  # RAM Critical at 90%
DISK_WARNING=75                  # Disk Warning at 75%
DISK_CRITICAL=90                 # Disk Critical at 90%
```

#### 🎨 Console Output Example (Warning)

```bash
==========================================
🖥️ System Resource Monitor
==========================================
Timestamp: 2025-10-24 14:30:00
OS: linux

CPU Usage: 65.2%
RAM Usage: 72.8%
Disk Usage: 45%

⚠️  WARNING: RAM usage is HIGH: 72.8% (threshold: 70%)
```

---

### 📦 `backup-manager.sh` - Backup Management

A comprehensive script for creating, inspecting, and managing system backups.

#### 🔧 Core Capabilities

| Feature | Implementation |
|:--------|:---------------|
| **Backup Creation** | Creates compressed archives (`.tar.gz`) of specified directories |
| **Retention Policy** | Deletes old backups based on a configurable retention count |
| **Cross-Platform** | Uses standard `tar` and `gzip` commands available on most systems |
| **Configurable Sources** | Allows specifying multiple source directories for backup |
| **Inspection Mode** | Provides functionality to list the contents of a backup archive |
| **Restoration** | Includes a command to safely extract a backup to a specified location |

#### 📋 Commands

| Command | Description | Example |
|:--------|:------------|:--------|
| `config` | Interactive configuration (backup directory, sources, retention) | `./backup-manager.sh config` |
| `create` | Creates a new timestamped backup archive | `./backup-manager.sh create` |
| `clean` | Applies the retention policy to delete old backups | `./backup-manager.sh clean` |
| `list` | Lists all existing backups in the backup directory | `./backup-manager.sh list` |
| `inspect <file>` | Lists the contents of a specific backup file | `./backup-manager.sh inspect backup_20251024.tar.gz` |
| `restore <file> <target>` | Extracts a backup to a target directory | `./backup-manager.sh restore backup_20251024.tar.gz /tmp/restore` |
| `help` | Show usage information | `./backup-manager.sh help` |

#### 📝 Configuration File

Located at: `~/.backup-manager.conf`

```bash
BACKUP_DIR="/tmp/backups"             # Directory where backups are stored
BACKUP_SOURCES=("/home/user/Documents" "/home/user/scripts")
RETENTION_COUNT=7                     # Keep the last 7 backups
```

---

### 🧹 `log-cleaner.sh` - Log Cleanup and Rotation

Automates the cleanup and rotation of log files based on age and count, with a safe dry-run mode.

#### 🔧 Core Capabilities

| Feature | Implementation |
|:--------|:---------------|
| **Age-Based Cleanup** | Deletes files older than a specified number of days (e.g., `+30`) |
| **Count-Based Rotation** | Keeps only the specified number of newest files |
| **Dry-Run Mode** | Safely simulates deletion without modifying any files |
| **Target Flexibility** | Works on any specified directory and file pattern |
| **Minimal Dependencies** | Relies only on standard Bash and `find` utility |

#### 📋 Commands

| Command | Description | Example |
|:--------|:------------|:--------|
| `clean <path> <days>` | Deletes files in `<path>` older than `<days>` | `./log-cleaner.sh clean /var/log/app +30` |
| `rotate <path> <count>` | Keeps the `<count>` newest files in `<path>`, deletes the rest | `./log-cleaner.sh rotate /var/log/app/archive 10` |
| `dry-run clean <path> <days>` | Simulates age-based cleanup | `./log-cleaner.sh dry-run clean /var/log/app +30` |
| `dry-run rotate <path> <count>` | Simulates count-based rotation | `./log-cleaner.sh dry-run rotate /var/log/app/archive 10` |
| `help` | Show usage information | `./log-cleaner.sh help` |

#### 🎨 Console Output Example (Dry-Run)

```bash
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

## 💡 Notification Philosophy and Best Practices

The project follows a philosophy of **smart, non-spammy alerting** to ensure that notifications are only sent when they are truly actionable or represent a significant state change.

This is why not all utility scripts are integrated with real-time Telegram notifications:

| Script | Recommendation | Rationale |
|:-------|:---------------|:----------|
| **backup-manager.sh** | **❌ NOT a priority** | Backup is a scheduled task that does not require real-time, instant notification. Telegram would be cluttered with daily "Backup completed" messages. **Better Approach:** Daily summary report (1 message per day) or only notifications for **ERRORS** (e.g., backup failed, disk full). |
| **log-cleaner.sh** | **❌ NOT needed** | This is a routine, maintenance operation that requires no notification upon success. If the cleanup is successful, the user does not need to be informed. **Exception:** Notification is required if the cleanup **FAILS** (e.g., permission denied, disk is full). |

This approach ensures that when a Telegram notification is received, it carries high importance and requires attention.

---

## 🆕 Future Innovations and Roadmap

The following features are planned for future releases. Items marked with `✅` have been implemented in the current version.

| Priority | Feature | Status | Notes |
|:---------|:--------|:-------|:------|
| **P1 (v1.1)** | Add "smart" Telegram notifications to `system-monitor` + `internet-check` | **✅ DONE** | Implemented with state tracking and recovery alerts. |
| **P1 (v1.1)** | Implement severity levels (critical/warning/info) | **✅ DONE** | Integrated into `system-monitor` and `internet-check`. |
| **P1 (v1.1)** | Implement daily summary for `backup-manager` | ❌ PENDING | The current `backup-manager.sh` does not include this yet. |
| **P2 (v1.2)** | Email notifications (fallback) | ❌ PENDING | For environments where Telegram is not accessible. |
| **P2 (v1.2)** | Webhook support (for Slack, Discord, MS Teams) | ❌ PENDING | To integrate with corporate communication tools. |
| **P3 (v2.0)** | Prometheus exporter | ❌ PENDING | For advanced time-series monitoring. |
| **P3 (v2.0)** | Grafana dashboard templates | ❌ PENDING | To provide immediate visualization of metrics. |
| **P3 (v2.0)** | Docker compose for deployment | ❌ PENDING | For easy, containerized deployment. |

---

## 🧰 Maintainer

**Artem Rivnyi** — Junior Technical Support / DevOps Enthusiast

* 📧 [artemrivnyi@outlook.com](mailto:artemrivnyi@outlook.com)  
* 🔗 [LinkedIn](https://www.linkedin.com/in/artem-rivnyi/)  
* 🌐 [Personal Projects](https://personal-page-devops.onrender.com/)  
* 💻 [GitHub](https://github.com/ArtemRivnyi)
