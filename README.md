# ⚙️ Bash Toolkit: Essential System Administration Scripts

**Bash Toolkit** is a collection of cross-platform Bash scripts designed to automate key tasks in system administration, monitoring, and diagnostics. The scripts feature minimal dependencies, high compatibility (Linux, macOS, Windows via Git Bash/PowerShell), and are integrated with Telegram for instant notifications.

## 📝 Table of Contents

*   [✨ Overview](#-overview)
*   [📂 Project Structure](#-project-structure)
*   [🚀 Current Script Status](#-current-script-status)
    *   [✅ Scripts with Telegram Integration (v1.0)](#-scripts-with-telegram-integration-v10)
    *   [⚙️ Core Scripts (No Telegram Integration in v1.0)](#-core-scripts-no-telegram-integration-in-v10)
    *   [🔄 Planned Telegram Integration (v1.1)](#-planned-telegram-integration-v11)
*   [🎯 Detailed Description and Capabilities](#-detailed-description-and-capabilities)
    *   [📡 `telegram-ping-monitor.sh` - Host Availability Monitoring](#-telegram-ping-monitor-sh---host-availability-monitoring)
    *   [💾 `disk-usage-alert.sh` - Disk Space Monitoring](#-disk-usage-alert-sh---disk-space-monitoring)
    *   [💚 `service-health-check.sh` - System Service Monitoring](#-service-health-check-sh---system-service-monitoring)
    *   [🌐 `internet-check.sh` - Comprehensive Internet Connectivity Check](#-internet-check-sh---comprehensive-internet-connectivity-check)
    *   [🖥️ `system-monitor.sh` - System Resource Monitoring](#-system-monitor-sh---system-resource-monitoring)
    *   [📦 `backup-manager.sh` - Backup Management](#-backup-manager-sh---backup-management)
    *   [🧹 `log-cleaner.sh` - Log Cleanup and Rotation](#-log-cleaner-sh---log-cleanup-and-rotation)
*   [🆕 Future Innovations and Roadmap](#-future-innovations-and-roadmap)
    *   [🎯 Update Plans for All Scripts](#-update-plans-for-all-scripts)
    *   [📈 Development Roadmap](#-development-roadmap)
    *   [💡 Additional Capabilities (Perspective)](#-additional-capabilities-perspective)

---

## ✨ Overview

This toolkit provides seven powerful scripts for maintaining the health and stability of your infrastructure. All scripts are designed with cross-platform compatibility in mind and use a unified approach to Telegram configuration for alerts.

## 📂 Project Structure

The project maintains a simple, flat structure for ease of use and portability.

```
.
├── backup-manager.sh
├── disk-usage-alert.sh
├── internet-check.sh
├── log-cleaner.sh
├── service-health-check.sh
├── system-monitor.sh
├── telegram-ping-monitor.sh
├── README.md
└── LICENSE (Planned)
```

## 🚀 Current Script Status

### ✅ Scripts with Telegram Integration (v1.0)

| Script | Description | Key Features |
| :--- | :--- | :--- |
| `telegram-ping-monitor.sh` | Host availability monitoring. | Notifications on status change (up/down/degraded). Configurable check intervals and spam protection. |
| `disk-usage-alert.sh` | Disk space monitoring. | **Multiple alert methods** (console/telegram/both). Threshold notifications. Cross-platform support. |
| `service-health-check.sh` | System service monitoring. | Tracks service status (systemd/init/Windows services). Notifications on failures and recoveries. |

### ⚙️ Core Scripts (No Telegram Integration in v1.0)

| Script | Description | Key Features |
| :--- | :--- | :--- |
| `internet-check.sh` | Comprehensive network check. | Multi-stage diagnostics (Ping, DNS, HTTP/HTTPS, Speed Test). |
| `system-monitor.sh` | CPU, RAM, Disk monitoring. | Cross-platform metric collection with color-coded thresholds. |
| `backup-manager.sh` | Backup creation and management. | Retention, inspection, and restoration features. |
| `log-cleaner.sh` | Log cleanup and rotation. | Cleanup by age, rotation by count, and dry-run mode. |

**Note:** The four scripts listed under "Core Scripts" are fully functional but do not include Telegram notification support in the current version. Integration is planned for v1.1.

### 🔄 Planned Alert System Enhancement (v1.1)

The following scripts are planned to be enhanced in **v1.1** to include **flexible alert methods (console, telegram, or both)** similar to `disk-usage-alert.sh`:

| Script | Planned Alert Feature |
| :--- | :--- | :--- |
| `internet-check.sh` | Console/Telegram alerts for internet outages and speed issues. |
| `system-monitor.sh` | Console/Telegram alerts for high resource usage. |
| `backup-manager.sh` | Console/Telegram reports on backup operations. |
| `log-cleaner.sh` | Console/Telegram reports on cleanup results. |

---

## 🎯 Detailed Description and Capabilities

### 📡 `telegram-ping-monitor.sh` - Host Availability Monitoring

The script checks the availability of a list of hosts using `ping` and sends Telegram notifications when their status changes.

| Capability | Implementation Details |
| :--- | :--- |
| **Status Monitoring** | Tracks transitions between `up`, `degraded` (partial packet loss), and `down`. |
| **Cross-Platform** | Adapts `ping` commands (`-c`, `-W` for Linux/macOS, `-n`, `-w` for Windows) for correct operation. |
| **Spam Protection** | Uses a configurable cooldown (`ALERT_COOLDOWN`) to prevent multiple alerts for the same failure. |
| **Configuration** | Configurable via interactive mode and the `.telegram-ping-monitor.conf` file. |

#### Usage and Commands

| Command | Description | Example |
| :--- | :--- | :--- |
| `config` | Interactive configuration setup (Telegram tokens, hosts, intervals). | `./telegram-ping-monitor.sh config` |
| `start` | Starts the continuous monitoring loop. | `./telegram-ping-monitor.sh start` |
| `status` | Shows the current status of monitored hosts and recent log entries. | `./telegram-ping-monitor.sh status` |
| `test` | Sends a test Telegram notification. | `./telegram-ping-monitor.sh test` |
| `log` | Shows the recent log file entries. | `./telegram-ping-monitor.sh log` |

#### Example Output (Status)

```bash
$ ./telegram-ping-monitor.sh status
[2025-10-25 10:00:00] Monitoring Status Report
--------------------------------------------------
Host: google.com (8.8.8.8)
  Status: UP (Last check: 10:00:00)
  Latency: 15.2 ms
Host: local-server (192.168.1.10)
  Status: DEGRADED (Last check: 09:59:30)
  Packet Loss: 15%
Host: external-api (10.0.0.5)
  Status: DOWN (Since: 09:55:00)
  Last Alert: DOWN (Sent to Telegram)
--------------------------------------------------
```

### 💾 `disk-usage-alert.sh` - Disk Space Monitoring

The script monitors the percentage of disk usage for specified mount points and alerts when set thresholds are exceeded.

| Capability | Implementation Details |
| :--- | :--- |
| **Multiple Alert Methods** | Supports **console**, **telegram**, or **both** notification methods. Configurable via `ALERT_METHOD` setting. |
| **Console Alerts** | Color-coded terminal notifications with emojis for different severity levels. |
| **Threshold Notifications** | Supports `WARNING` (default 80%) and `CRITICAL` (default 90%) levels. |
| **Cross-Platform** | Uses `df` on Linux/macOS, and `PowerShell` on Windows for reliable disk data retrieval (e.g., `C:`). |
| **Configuration** | Configurable via interactive mode, including `WARNING_THRESHOLD`, `CRITICAL_THRESHOLD`, and the list of monitored mount points. |
| **Anti-Spam** | Uses an alert cooldown (`ALERT_COOLDOWN`). |

#### Usage and Commands

| Command | Description | Example |
| :--- | :--- | :--- |
| `config` | Interactive configuration setup (Telegram tokens, thresholds, mounts). | `./disk-usage-alert.sh config` |},{find:
| `start` | Starts the continuous monitoring loop. | `./disk-usage-alert.sh start` |
| `status` | Shows the current disk usage for monitored mounts. | `./disk-usage-alert.sh status` |
| `test` | Sends a test Telegram notification. | `./disk-usage-alert.sh test` |
| `log` | Shows the recent log file entries. | `./disk-usage-alert.sh log` |
| `showcfg` | Shows current configuration including alert method. | `./disk-usage-alert.sh showcfg` |

#### Example Output (Status)

```bash
$ ./disk-usage-alert.sh status
Current Disk Usage
===================
/: 45% used - NORMAL
/mnt/data: 85% used - WARNING

Alert Method: console
Warning Threshold: 80%
Critical Threshold: 90%
```

### 💚 `service-health-check.sh` - System Service Monitoring

The script checks the status of critical system services and notifies of any status changes.

| Capability | Implementation Details |
| :--- | :--- |
| **Init System Support** | Automatically detects and uses `systemctl` (Linux), `launchctl` (macOS), or `sc` (Windows) to check service status. |
| **Failure Notifications** | Sends alerts when a service transitions from `running` to `stopped` and vice versa. |
| **Configuration** | Configurable list of monitored services (`MONITOR_SERVICES`) and check interval. |

#### Usage and Commands

| Command | Description | Example |
| :--- | :--- | :--- |
| `config` | Interactive configuration setup (Telegram tokens, services, interval). | `./service-health-check.sh config` |
| `start` | Starts the continuous monitoring loop. | `./service-health-check.sh start` |
| `status` | Shows the current status of monitored services. | `./service-health-check.sh status` |
| `test` | Sends a test Telegram notification. | `./service-health-check.sh test` |
| `log` | Shows the recent log file entries. | `./service-health-check.sh log` |

#### Example Output (Status)

```bash
$ ./service-health-check.sh status
[2025-10-25 10:10:00] Service Health Report
--------------------------------------------------
Service: sshd (systemd)
  Status: running
  Uptime: 5 days 12 hours
Service: nginx (systemd)
  Status: stopped (Since: 10:08:00)
  Last Alert: FAILURE (Sent to Telegram)
Service: Windows Update (Windows)
  Status: running
  Last Check: 10:09:00
--------------------------------------------------
```

### 🌐 `internet-check.sh` - Comprehensive Internet Connectivity Check

The script performs a multi-stage network diagnostic, checking physical reachability, name resolution, and HTTP connectivity.

| Capability | Implementation Details |
| :--- | :--- |
| **Multi-Stage Diagnostics** | Includes Ping check (up to 3 DNS servers), DNS resolution (up to 4 domains), and HTTP availability (up to 3 URLs). |
| **Cross-Platform** | Adapts to Linux, macOS, and Windows (Git Bash), using available utilities (`ipconfig`/`ip`/`ifconfig`, `curl`/`wget`). |
| **Speed Test** | Includes an attempt to run `speedtest-cli` or an alternative download speed test via `curl`. |
| **Logging** | Detailed log of all checks is saved for later analysis. |

#### Usage and Commands

| Command | Description | Example |
| :--- | :--- | :--- |
| (None) | Runs the comprehensive check and displays results. | `./internet-check.sh` |
| `-h`, `--help` | Shows the help message (not implemented in script, but standard for Bash). | `./internet-check.sh -h` |

#### Example Output

```bash
$ ./internet-check.sh
[2025-10-25 10:15:00] Comprehensive Internet Check
--------------------------------------------------
1. Ping Check (google.com):
   Status: OK (Avg Latency: 12.5 ms)
2. DNS Resolution Check (cloudflare.com):
   Status: OK (Resolved to: 104.16.123.96)
3. HTTP/HTTPS Check (https://github.com):
   Status: OK (HTTP Code: 200)
4. Speed Test (Download):
   Status: OK (Download Speed: 95.7 Mbps)
--------------------------------------------------
Overall Status: Internet is fully functional.
```

### 🖥️ `system-monitor.sh` - System Resource Monitoring

The script collects and displays key resource usage metrics with color-coded threshold indication.

| Capability | Implementation Details |
| :--- | :--- |
| **Cross-Platform Metric Collection** | Collects CPU, RAM, and Disk Usage. Uses PowerShell for accurate data on Windows. |
| **Color-Coded Indication** | Uses thresholds (e.g., 60%/85% for CPU) to highlight normal, warning, and critical states. |
| **Logging** | All metrics are recorded to a log file with a timestamp. |
| **System Information** | Displays OS, kernel, hostname, and uptime information. |

#### Usage and Commands

| Command | Description | Example |
| :--- | :--- | :--- |
| (None) | Runs the check, displays metrics, and logs the results. | `./system-monitor.sh` |
| `-h`, `--help` | Shows the help message (not implemented in script, but standard for Bash). | `./system-monitor.sh -h` |

#### Example Output

```bash
$ ./system-monitor.sh
[2025-10-25 10:20:00] System Resource Report (Ubuntu 22.04)
--------------------------------------------------
Hostname: my-server-01
Uptime: 2 days, 4 hours, 15 minutes
--------------------------------------------------
CPU Usage: 5% (OK)
  Load Avg (1/5/15): 0.15 / 0.22 / 0.30
RAM Usage: 65% (WARNING)
  Total: 16 GB, Used: 10.4 GB, Free: 5.6 GB
Disk Usage (/): 78% (OK)
  Total: 250 GB, Used: 195 GB, Free: 55 GB
--------------------------------------------------
```

### 📦 `backup-manager.sh` - Backup Management

A powerful script for creating, rotating, and restoring backups.

| Capability | Implementation Details |
| :--- | :--- |
| **Backup Creation** | Creates compressed `tar.gz` archives from specified sources. |
| **Exclusions** | Supports a list of excluded files/folders (e.g., `.git`, `node_modules`). |
| **Retention** | Automatically deletes old backups based on a configurable retention period (`RETENTION_DAYS`). |
| **Inspection** | Allows viewing archive contents without full restoration (`--inspect`, `--extract-view`). |
| **Space Check** | Estimates backup size and checks for sufficient free space before starting. |

#### Usage and Commands

| Option | Description | Example |
| :--- | :--- | :--- |
| `-c`, `--create` | Creates a new backup. Accepts sources as arguments. | `./backup-manager.sh -c ~/Documents ~/Projects` |
| `-l`, `--list` | Lists existing backups in the backup directory. | `./backup-manager.sh -l` |
| `-r`, `--restore FILE` | Restores from the specified backup file. | `./backup-manager.sh -r /tmp/backups/backup_...tar.gz` |
| `-d`, `--dir DIR` | Sets the backup directory. | `./backup-manager.sh -c -d /mnt/external/backups` |
| `--retention DAYS` | Sets the retention period in days (default: 30). | `./backup-manager.sh --clean --retention 7` |
| `--clean` | Cleans old backups based on the retention policy. | `./backup-manager.sh --clean` |
| `--config` | Shows the current configuration. | `./backup-manager.sh --config` |
| `--save-config` | Saves the current configuration to file. | `./backup-manager.sh --save-config` |
| `-i`, `--inspect FILE` | Shows contents of the backup file (first 50 files). | `./backup-manager.sh -i /path/to/backup.tar.gz` |
| `--extract-view FILE` | Extracts and views backup contents in a temporary directory. | `./backup-manager.sh --extract-view /path/to/backup.tar.gz` |

#### Example Output (Create and Clean)

```bash
$ ./backup-manager.sh -c /etc/nginx --clean --retention 7
[2025-10-25 10:25:00] Starting Backup...
  Source: /etc/nginx
  Destination: /var/backups/nginx_20251025_102500.tar.gz
  Size: 1.2 MB
  Status: SUCCESS
[2025-10-25 10:25:05] Starting Retention Cleanup...
  Policy: Keep backups newer than 7 days.
  Found 5 old backups to delete.
  Deleted: backup_20251015_080000.tar.gz (1.1 MB)
  Cleanup Status: SUCCESS
```

### 🧹 `log-cleaner.sh` - Log Cleanup and Rotation

A script for automatic log file cleanup and rotation based on defined policies.

| Capability | Implementation Details |
| :--- | :--- |
| **Cleanup by Age** | Deletes files matching patterns (`*.log`, `*.tmp`) that are older than a specified number of days (`RETENTION_DAYS`). |
| **Rotation by Count** | Deletes the oldest files, keeping a specified number of the latest files (`KEEP_LAST_FILES`). |
| **Dry Run Mode** | Supports a `--dry-run` mode to check actions without actual deletion. |
| **Reporting** | Outputs and logs the number of deleted/rotated files. |

#### Usage and Commands

| Option | Description | Example |
| :--- | :--- | :--- |
| (None) | Runs the cleanup and rotation with default settings (age 30 days, keep last 10). | `./log-cleaner.sh` |
| `-a`, `--age DAYS` | Sets the retention age in days. | `./log-cleaner.sh --age 7` |
| `-k`, `--keep COUNT` | Sets the number of latest files to keep for rotation. | `./log-cleaner.sh --keep 5` |
| `--dry-run` | Shows what would be deleted without performing the action. | `./log-cleaner.sh --dry-run` |
| `-h`, `--help` | Shows the help message. | `./log-cleaner.sh -h` |

#### Example Output (Dry Run)

```bash
$ ./log-cleaner.sh --dry-run -a 30
[2025-10-25 10:30:00] Starting Log Cleanup (Dry Run)...
  Target Directory: /var/log/
  Retention Age: 30 days
  Files to be deleted (Older than 30 days):
    - /var/log/nginx/access.log.2025-09-01.gz
    - /var/log/syslog.1.gz
  Total files to be deleted: 2
  Total space to be recovered: 150 MB
  No changes were made (Dry Run mode).
```

---

## 🆕 Future Innovations and Roadmap

In addition to the completed modernization, the project has a clear development plan aimed at improving usability and expanding functionality.

### 🎯 Update Plans for All Scripts

| Area | Description |
| :--- | :--- |
| **Unified Telegram Configuration** | Transition to a single configuration file for all scripts to avoid duplicating `BOT_TOKEN` and `CHAT_ID`. |
| **Extended Logging** | Implementation of structured logging in **JSON** format to simplify integration with external systems (e.g., ELK Stack or Grafana). |
| **REST API** | Development of a simple REST API for integration with other systems and remote script management. |

### 📈 Development Roadmap

| Version | Focus | Status |
| :--- | :--- | :--- |
| **v1.0** | Initial version (3 scripts with Telegram, 4 without) | Completed |
| **v1.1** | **Telegram Integration** for the remaining 4 scripts. Improved cross-platform compatibility. | Planned (In Development) |
| **v1.2** | Web Interface and REST API. Unified Telegram configuration. | Planned (Future) |
| **v2.0** | Full refactoring with plugin support and modular architecture. | Planned |

### 💡 Additional Capabilities (Perspective)

*   **Web Dashboard** for real-time status and metrics viewing.
*   **Graphs and Metrics** through Grafana integration.
*   **SMS Notifications** as a fallback alert channel.
*   **Voice Alerts** for critical failures.
*   **Automated Actions** (e.g., service restart) upon problem detection.

All scripts maintain **cross-platform compatibility** and **backward compatibility** for current features.

---
*Author: Manus AI, based on provided data.*
