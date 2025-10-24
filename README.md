# ⚙️ Bash Toolkit: Essential System Administration Scripts

**Bash Toolkit** is a collection of cross-platform Bash scripts designed to automate key tasks in system administration, monitoring, and diagnostics. The scripts feature minimal dependencies, high compatibility (Linux, macOS, Windows via Git Bash/PowerShell), and are integrated with Telegram for instant notifications.

## 📋 Table of Contents

*   [✨ Overview](#-overview)
*   [📂 Project Structure](#-project-structure)
*   [🚀 Current Script Status](#-current-script-status)
    *   [✅ Scripts with Telegram Integration](#-scripts-with-telegram-integration)
    *   [⚙️ Core Utility Scripts](#️-core-utility-scripts)
*   [🎯 Detailed Description and Capabilities](#-detailed-description-and-capabilities)
    *   [📡 telegram-ping-monitor.sh](#-telegram-ping-monitorsh---host-availability-monitoring)
    *   [💾 disk-usage-alert.sh](#-disk-usage-alertsh---disk-space-monitoring)
    *   [💚 service-health-check.sh](#-service-health-checksh---system-service-monitoring)
    *   [🌐 internet-check.sh](#-internet-checksh---comprehensive-internet-connectivity-check)
    *   [🖥️ system-monitor.sh](#️-system-monitorsh---system-resource-monitoring)
    *   [📦 backup-manager.sh](#-backup-managersh---backup-management)
    *   [🧹 log-cleaner.sh](#-log-cleanersh---log-cleanup-and-rotation)
*   [🆕 Future Innovations and Roadmap](#-future-innovations-and-roadmap)
*   [🧰 Maintainer](#-maintainer)

---

## ✨ Overview

This toolkit provides seven powerful scripts for maintaining the health and stability of your infrastructure. All scripts are designed with cross-platform compatibility in mind (Linux, macOS, Windows via Git Bash) and use a unified approach to Telegram configuration for alerts where applicable.

**Key Features:**
- 🌍 Cross-platform compatibility (Linux, macOS, Windows)
- 📱 Telegram notification support for critical scripts
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

---

## 🚀 Current Script Status

### ✅ Scripts with Telegram Integration

These scripts include full Telegram notification support with configurable alert methods:

| Script | Description | Alert Methods | Key Features |
|:-------|:------------|:--------------|:-------------|
| **telegram-ping-monitor.sh** | Host availability monitoring | Telegram only | Multi-host monitoring, status transitions, cooldown protection |
| **disk-usage-alert.sh** | Disk space monitoring | Console / Telegram / Both | Warning & critical thresholds, cross-platform disk checks |
| **service-health-check.sh** | System service monitoring | Telegram only | Multi-init system support (systemd/launchctl/sc), failure alerts |

### ⚙️ Core Utility Scripts

These scripts are fully functional diagnostic and utility tools without Telegram integration:

| Script | Description | Key Features |
|:-------|:------------|:-------------|
| **internet-check.sh** | Comprehensive network check | Multi-stage diagnostics: Ping, DNS, HTTP/HTTPS, Speed Test |
| **system-monitor.sh** | CPU, RAM, Disk monitoring | Color-coded thresholds, cross-platform metrics, detailed logging |
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
ALERT - Host Down

google.com is down
Time: 2025-10-24 14:30:00
Previous state: up
```

**Recovery Notification:**
```
RECOVERY - Host Back Online

google.com is back online
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

#### 🎨 Console Output Example

```bash
Disk Usage Check - 2025-10-24 14:30:00
======================================
  /: 45% used - NORMAL
  /mnt/data: 85% used - WARNING
  C:: 92% used - CRITICAL

Alert Method: both
Warning Threshold: 80%
Critical Threshold: 90%
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
# MONITOR_SERVICES=(Spooler BITS Themes)           # Windows examples
```

#### 💬 Example Service Alerts

**Service Failure:**
```
SERVICE ALERT - Service Stopped

Service: nginx
Status: stopped
Time: 2025-10-24 14:30:00
Previous state: running
```

**Service Recovery:**
```
SERVICE RECOVERY - Service Running

Service: nginx
Status: running
Time: 2025-10-24 14:35:00
Previous state: stopped
```

---

### 🌐 `internet-check.sh` - Comprehensive Internet Connectivity Check

Performs multi-stage network diagnostics to verify internet connectivity and identify issues.

#### 🔧 Core Capabilities

| Feature | Implementation |
|:--------|:---------------|
| **Multi-Stage Testing** | Ping → DNS → HTTP/HTTPS → Speed Test (4 stages) |
| **OS Detection** | Enhanced detection with Linux distribution identification |
| **Network Info** | Displays IP address, gateway, DNS servers, hostname |
| **Multiple Targets** | Tests against multiple servers for reliability (3 DNS, 4 domains, 3 HTTP endpoints) |
| **Tool Detection** | Automatically uses available tools (curl/wget, nslookup/host/dig) |
| **Speed Testing** | Supports speedtest-cli, speedtest, or fallback curl-based test |
| **Comprehensive Logging** | Detailed logs of all checks with timestamps |

#### 🔍 Test Stages

| Stage | Purpose | Targets |
|:------|:--------|:--------|
| **1. Ping Check** | Verify network layer connectivity | 8.8.8.8, 1.1.1.1, 208.67.222.222 |
| **2. DNS Resolution** | Verify name resolution works | google.com, github.com, stackoverflow.com, cloudflare.com |
| **3. HTTP/HTTPS Check** | Verify application layer connectivity | google.com, cloudflare.com, httpbin.org |
| **4. Speed Test** | Measure connection speed | Uses speedtest-cli or curl download test |

#### 📋 Usage

```bash
# Run complete diagnostic
./internet-check.sh

# View recent logs
tail -f /tmp/internet-check.log
```

#### 🎨 Sample Output

```bash
🌐 Comprehensive Internet Connectivity Check
==========================================
Detected OS: linux-ubuntu
Kernel: Linux 5.15.0-91-generic x86_64

📡 Checking network connectivity...
  Testing 8.8.8.8... ✓
  Testing 1.1.1.1... ✓
  Testing 208.67.222.222... ✓
✅ Network connectivity: 3/3 targets reachable

🔍 Testing DNS resolution...
Using DNS tool: nslookup
  google.com... ✓
  github.com... ✓
  stackoverflow.com... ✓
  cloudflare.com... ✓
✅ DNS resolution: 4/4 domains resolved

🌐 Testing HTTP/HTTPS connectivity...
Using: curl
  https://www.google.com... ✓
  https://www.cloudflare.com... ✓
  https://httpbin.org/get... ✓
✅ HTTP/HTTPS: 3/3 endpoints reachable

📊 Network Information:
----------------------
Hostname: my-laptop
IP Address: 192.168.1.100
Default Gateway: 192.168.1.1

🚀 Testing internet speed...
Running official speedtest-cli...
Ping: 15 ms
Download: 95.3 Mbit/s
Upload: 45.2 Mbit/s

==========================================
✅ Internet check completed successfully!
📝 Detailed log: /tmp/internet-check.log
```

#### 🪟 Windows-Specific Features

The script includes enhanced Windows support:
- Multiple methods to detect IP and gateway (ipconfig, PowerShell, netstat, route)
- Proper handling of Git Bash/MinGW environment
- PowerShell integration for DNS server detection
- Fallback methods when primary detection fails

---

### 🖥️ `system-monitor.sh` - System Resource Monitoring

Monitors CPU, RAM, and disk usage with color-coded output and comprehensive logging.

#### 🔧 Core Capabilities

| Feature | Implementation |
|:--------|:---------------|
| **CPU Monitoring** | Uses top/PowerShell, color-coded by thresholds (60%/85%) |
| **RAM Monitoring** | Memory usage with color coding (70%/90%) |
| **Disk Monitoring** | Root filesystem usage (75%/90%) |
| **Load Average** | System load metrics (Unix systems only) |
| **Cross-Platform** | Full support for Linux, macOS, Windows via PowerShell |
| **Enhanced Windows** | Uses CIM/WMI for accurate CPU/RAM/Disk readings |
| **Color Coding** | Green (normal), Yellow (warning), Red (critical) |
| **Detailed Logging** | All metrics saved with timestamps |

#### 📊 Monitored Metrics

| Metric | Thresholds | Platform Support |
|:-------|:-----------|:-----------------|
| **CPU Usage** | Warning: 60%, Critical: 85% | Linux, macOS, Windows |
| **RAM Usage** | Warning: 70%, Critical: 90% | Linux, macOS, Windows |
| **Disk Usage** | Warning: 75%, Critical: 90% | Linux, macOS, Windows |
| **Load Average** | Informational only | Linux, macOS only |
| **Uptime** | Informational | All platforms |

#### 📋 Usage

```bash
# Run single check
./system-monitor.sh

# View logs
tail -f /tmp/system-monitor.log

# Continuous monitoring (every 5 minutes)
watch -n 300 ./system-monitor.sh
```

#### 🎨 Sample Output

```bash
🖥️ System Monitor
====================

📊 System Metrics - windows
==================================
CPU Usage:    15%  (Normal)
RAM Usage:    62%  (Normal)
Disk Usage:   78%  (Warning)

🖥️ System Information:
----------------------
OS: windows
Kernel: MINGW64_NT-10.0-22621 3.4.10-87d57229 x86_64
Hostname: DESKTOP-ABC123
Uptime: 2 days 14h 35m

📝 Log written to: /tmp/system-monitor.log

Last 3 entries:
[2025-10-24 14:30:00] OS: windows | CPU: 15% | RAM: 62% | Disk: 78%
[2025-10-24 14:25:00] OS: windows | CPU: 18% | RAM: 65% | Disk: 78%
[2025-10-24 14:20:00] OS: windows | CPU: 12% | RAM: 60% | Disk: 77%
```

---

### 📦 `backup-manager.sh` - Backup Management

Advanced backup solution with compression, retention, inspection, and restoration capabilities.

#### 🔧 Core Capabilities

| Feature | Implementation |
|:--------|:---------------|
| **Compression** | Creates tar.gz archives with configurable compression level (default: 6) |
| **Exclusion Patterns** | Filters out unwanted files (*.tmp, *.log, .git, node_modules, etc.) |
| **Retention Policy** | Auto-deletes backups older than specified days (default: 30) |
| **Disk Space Check** | Verifies sufficient space before backup (estimates 50% compression) |
| **Backup Inspection** | View contents without extraction (`-i`, `-I`, `--extract-view`) |
| **Configuration** | Persistent settings via config file |
| **Cross-Platform** | Full compatibility with Linux, macOS, Windows (Git Bash) |

#### 📋 Commands

| Option | Description | Example |
|:-------|:------------|:--------|
| `-c, --create` | Create new backup (optionally specify sources) | `./backup-manager.sh -c ~/Documents ~/Projects` |
| `-l, --list` | List all existing backups with sizes and dates | `./backup-manager.sh -l` |
| `-r, --restore FILE` | Restore from specified backup file | `./backup-manager.sh -r backup_20251024_143022.tar.gz` |
| `--restore-dir DIR` | Set custom restoration directory | `./backup-manager.sh -r file.tar.gz --restore-dir /tmp/restore` |
| `-d, --dir DIR` | Set backup directory | `./backup-manager.sh -c -d /mnt/backups` |
| `--retention DAYS` | Set retention period in days | `./backup-manager.sh --retention 7` |
| `--clean` | Clean old backups based on retention | `./backup-manager.sh --clean` |
| `--config` | Show current configuration | `./backup-manager.sh --config` |
| `--save-config` | Save current settings to config file | `./backup-manager.sh --save-config` |
| `-i, --inspect FILE` | Show backup contents (first 50 files) | `./backup-manager.sh -i backup.tar.gz` |
| `-I, --inspect-all FILE` | Show all backup contents | `./backup-manager.sh -I backup.tar.gz` |
| `--extract-view FILE` | Extract to temp directory for inspection | `./backup-manager.sh --extract-view backup.tar.gz` |
| `-h, --help` | Show usage information | `./backup-manager.sh -h` |

#### 📝 Configuration File

Located at: `~/.backup-manager.conf`

```bash
# Backup Manager Configuration
BACKUP_DIR="/tmp/backups"
SOURCES=(~/Documents ~/scripts ~/.config)
RETENTION_DAYS=30
COMPRESSION_LEVEL=6
EXCLUDE_PATTERNS=(*.tmp *.log *.cache* node_modules .git __pycache__)
```

#### 🎨 Sample Output

**Creating Backup:**
```bash
💾 Starting Backup Creation
============================
⚙️ Configuration loaded from /home/user/.backup-manager.conf
✅ All prerequisites satisfied
📊 Estimated backup size: 250M
✅ Disk space check passed. Available: 15G
📦 Starting backup: backup_20251024_143022.tar.gz
✅ Backup created successfully: /tmp/backups/backup_20251024_143022.tar.gz
💾 Backup size: 125M, Duration: 8s

📝 Detailed log: /tmp/backup-manager.log
```

**Listing Backups:**
```bash
📋 Backup Listing
=================
📋 Existing backups in /tmp/backups:
  📄 /tmp/backups/backup_20251024_143022.tar.gz
     Size: 125M, Date: 2025-10-24 14:30:22
  📄 /tmp/backups/backup_20251023_091533.tar.gz
     Size: 118M, Date: 2025-10-23 09:15:33
```

**Inspecting Backup:**
```bash
📂 Contents of backup: backup_20251024_143022.tar.gz
==========================================
home/user/Documents/project/README.md
home/user/Documents/project/src/main.py
home/user/Documents/notes.txt
...
==========================================
📊 Total files in backup: 1247
```

---

### 🧹 `log-cleaner.sh` - Log Cleanup and Rotation

Simple and effective log file cleanup and rotation utility.

#### 🔧 Core Capabilities

| Feature | Implementation |
|:--------|:---------------|
| **Age-Based Cleanup** | Delete files older than specified days (default: 30) |
| **Count-Based Rotation** | Keep only last N files (default: 10) |
| **Pattern Matching** | Supports multiple file patterns (*.log, *.tmp, *.cache) |
| **Exclusion Support** | Protect important files with exclusion patterns |
| **Dry-Run Mode** | Preview changes without actual deletion |
| **Multiple Paths** | Clean multiple directories in one run |
| **Simple Output** | No colors or emojis, pure functionality |

#### 📋 Commands

| Option | Description | Example |
|:-------|:------------|:--------|
| `-a, --age DAYS` | Set retention age in days (default: 30) | `./log-cleaner.sh --age 7` |
| `-k, --keep COUNT` | Keep last N files (default: 10) | `./log-cleaner.sh --keep 5` |
| `--dry-run` | Show what would be deleted without deleting | `./log-cleaner.sh --dry-run` |
| `-h, --help` | Show usage information | `./log-cleaner.sh -h` |

#### 📝 Configuration

Default settings (modifiable in script):

```bash
LOG_PATHS=(/tmp /var/log ~/.cache)
CLEAN_PATTERNS=(*.log *.log.* *.tmp *.cache)
EXCLUDE_PATTERNS=(*.important *.critical)
RETENTION_DAYS=30
KEEP_LAST_FILES=10
```

#### 🎨 Sample Output

**Dry Run Mode:**
```bash
Starting Log Cleaner
===================
DRY RUN MODE - No files will be deleted
=======================================

[2025-10-24 14:30:00] Cleaning files older than 30 days...
Checking /tmp for files older than 30 days...
WOULD DELETE: /tmp/old_script.log
WOULD DELETE: /tmp/debug_20250924.tmp
Checking /var/log for files older than 30 days...
WOULD DELETE: /var/log/nginx/access.log.2.gz

[2025-10-24 14:30:05] Rotating files (keeping last 10)...
WOULD ROTATE: /tmp/test_11.log

===================
DRY RUN COMPLETED
Would delete: 3 files
Would rotate: 1 files
Log: /tmp/log-cleaner.log
```

**Actual Cleanup:**
```bash
Starting Log Cleaner
===================

[2025-10-24 14:30:00] Cleaning files older than 7 days...
Checking /tmp for files older than 7 days...
DELETED: /tmp/old_script.log
DELETED: /tmp/debug_20251017.tmp

[2025-10-24 14:30:05] Rotating files (keeping last 5)...
ROTATED: /tmp/test_6.log

===================
CLEANING COMPLETED
Deleted: 2 files
Rotated: 1 files
Log: /tmp/log-cleaner.log
```

---

## 🆕 Future Innovations and Roadmap

### 🎯 Planned Enhancements

| Enhancement | Target Scripts | Description | Priority |
|:------------|:---------------|:------------|:---------|
| **Unified Config** | All Telegram scripts | Single config file for all Telegram settings | High |
| **JSON Logging** | All scripts | Structured logs for ELK/Grafana integration | Medium |
| **Email Alerts** | Monitoring scripts | Alternative to Telegram notifications | Medium |
| **Web Dashboard** | All scripts | Real-time status and metrics viewing | Low |
| **REST API** | All scripts | Remote script management and integration | Low |

### 📈 Development Roadmap

| Version | Focus | Status |
|:--------|:------|:-------|
| **v1.0** | Core functionality with selective Telegram integration | ✅ Completed |
| **v1.1** | Unified configuration, improved Windows support | 🚧 In Progress |
| **v1.2** | Web interface, additional alert channels (email, SMS) | 📋 Planned |
| **v2.0** | Plugin architecture, modular design | 🔮 Future |

### 💡 Additional Features Under Consideration

- **Automated Remediation**: Automatic service restart on failure detection
- **Grafana Integration**: Direct metrics export for visualization
- **SMS Notifications**: Fallback alert channel for critical failures
- **Voice Alerts**: Text-to-speech for critical incidents
- **Multi-Language Support**: Localized messages and documentation
- **Container Support**: Docker images for easy deployment
- **Ansible Playbooks**: Automated installation and configuration

---

## 📄 License

This project is currently unlicensed. License information will be added in future releases.

## 🤝 Contributing

Contributions are welcome! Please ensure cross-platform compatibility when submitting changes.

## 📧 Support

For issues and feature requests, please open an issue in the project repository.

---

## 🧰 Maintainer

**Artem Rivnyi** — Junior Technical Support / DevOps Enthusiast

* 📧 [artemrivnyi@outlook.com](mailto:artemrivnyi@outlook.com)  
* 🔗 [LinkedIn](https://www.linkedin.com/in/artem-rivnyi/)  
* 🌐 [Personal Projects](https://personal-page-devops.onrender.com/)  
* 💻 [GitHub](https://github.com/ArtemRivnyi)