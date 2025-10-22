# ⚙️ Bash Toolkit: Essential System Administration Scripts

**Bash Toolkit** is a collection of essential shell scripts designed to streamline common system administration tasks across various operating systems. These scripts provide robust solutions for network diagnostics, system monitoring, backup management, log cleaning, and more, empowering users with efficient command-line utilities.

## 📝 Table of Contents

*   [✨ Overview](#-overview)
*   [🗂️ Project Structure](#-project-structure)
*   [🚀 Current Scripts](#-current-scripts)
    *   [🌐 `internet-check.sh` - Comprehensive Internet Connectivity Monitor](#-internet-checksh---comprehensive-internet-connectivity-monitor)
    *   [🖥️ `system-monitor.sh` - Cross-Platform System Resource Monitor](#-system-monitorsh---cross-platform-system-resource-monitor)
    *   [📦 `backup-manager.sh` - Advanced Backup and Retention System](#-backup-managersh---advanced-backup-and-retention-system)
    *   [🧹 `log-cleaner.sh` - Simple and Efficient Log File Management](#-log-cleanersh---simple-and-efficient-log-file-management)
*   [🔮 Future Scripts (Under Development)](#-future-scripts-under-development)
    *   [📡 `telegram-ping-monitor.sh` - Telegram Ping Monitor](#-telegram-ping-monitorsh---telegram-ping-monitor)
    *   [💾 `disk-usage-alert.sh` - Disk Space Monitoring and Alerting](#-disk-usage-alertsh---disk-space-monitoring-and-alerting)
    *   [💚 `service-health-check.sh` - Service Health and Status Monitor](#-service-health-checksh---service-health-and-status-monitor)
*   [🤝 Contribution](#-contribution)
*   [📄 License](#-license)

## ✨ Overview

This repository houses a growing collection of versatile Bash scripts aimed at simplifying routine system administration and monitoring tasks. Each script is designed for ease of use, cross-platform compatibility where possible, and provides clear, actionable insights or automated solutions. Whether you need to diagnose network issues, keep an eye on system resources, manage backups, or clean up old logs, this toolkit offers a robust command-line utility for the job.

## 🗂️ Project Structure

```
bash-toolkit/
├── README.md
├── internet-check.sh
├── system-monitor.sh
├── backup-manager.sh
├── log-cleaner.sh
├── telegram-ping-monitor.sh
├── disk-usage-alert.sh
└── service-health-check.sh
```

## 🚀 Current Scripts

### 🌐 `internet-check.sh` - Comprehensive Internet Connectivity Monitor

This robust bash script provides a multi-faceted approach to diagnosing internet connectivity issues. It performs sequential checks for network reachability (ping), DNS resolution, and HTTP/HTTPS access to various public endpoints. Designed for cross-platform compatibility (Linux, macOS, and Windows via Git Bash), it offers clear, color-coded output and detailed logging for easy troubleshooting.

**Key Features:**

**Cross-Platform Support**: This script works seamlessly across Linux, macOS, and Windows (Git Bash).
**Multi-Stage Diagnostics**: It verifies connectivity through ping to multiple IP addresses, DNS resolution for various domains, and HTTP/HTTPS reachability to popular websites.
**Dynamic Command Detection**: The script intelligently uses available tools such as `ping`, `nslookup`/`host`/`dig`, and `curl`/`wget` based on the detected operating system.
**Detailed Output**: It provides color-coded status messages for a quick visual assessment of connectivity health.
**Comprehensive Logging**: All checks and their outcomes are recorded to a dedicated log file (`/tmp/internet-check.log`) for historical analysis.
**Network Information**: It displays essential network details, including OS type, kernel version, hostname, IP address, and default gateway.

**Usage:**

```bash
bash internet-check.sh
```

**Example Output:**

```text
🌐 Comprehensive Internet Connectivity Check
==========================================
Detected OS: linux-ubuntu
Kernel: Linux 5.15.0-101-generic x86_64
Starting internet check on linux-ubuntu - Linux 5.15.0-101-generic x86_64

📡 Checking network connectivity...
  Testing 8.8.8.8... ✓
  Testing 1.1.1.1... ✓
  Testing 208.67.222.222... ✓
✅ Network connectivity: 3/3 targets reachable

🔍 Testing DNS resolution...
Using DNS tool: dig
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
Hostname: my-server
IP Address: 192.168.1.100
Default Gateway: 192.168.1.1
```

### 🖥️ `system-monitor.sh` - Cross-Platform System Resource Monitor

This versatile bash script provides real-time monitoring of key system resources, including CPU usage, RAM utilization, disk space, and load average. It is designed to be cross-platform compatible (Linux, macOS, and Windows via Git Bash), offering a unified way to observe system health. The script features color-coded output for quick status identification and logs all metrics for historical tracking and analysis.

**Key Features:**

**Cross-Platform Compatibility**: This script supports Linux, macOS, and Windows (Git Bash), adapting its commands based on the detected operating system.
**Comprehensive Metrics**: It monitors CPU usage, RAM usage, disk usage (for the root partition), and system load average (on Unix-like systems).
**Color-Coded Alerts**: Resource usage is color-coded (green for normal, yellow for warning, red for critical) based on configurable thresholds, allowing for immediate visual alerts.
**Persistent Logging**: All collected metrics are logged to `/tmp/system-monitor.log`, enabling long-term performance tracking and post-mortem analysis.
**System Information**: It displays basic system details such as OS type, kernel version, hostname, and uptime (on Windows).
**PowerShell Integration for Windows**: For Windows environments, it utilizes PowerShell for reliable metric collection, ensuring accurate data.

**Usage:**

```bash
bash system-monitor.sh
```

**Example Output (Linux):**

```text
🖥️ System Monitor
====================

📊 System Metrics - linux
==================================
CPU Usage:    25.3%
RAM Usage:    45.7%
Disk Usage:   68%
Load Average: 0.75

🖥️ System Information:
----------------------
OS: linux
Kernel: Linux 5.15.0-101-generic x86_64
Hostname: my-linux-server

📝 Log written to: /tmp/system-monitor.log

Last 3 entries:
[2025-10-22 10:00:01] OS: linux | CPU: 24.5% | RAM: 45.1% | Disk: 67% | Load: 0.72
[2025-10-22 10:00:02] OS: linux | CPU: 25.0% | RAM: 45.5% | Disk: 68% | Load: 0.74
[2025-10-22 10:00:03] OS: linux | CPU: 25.3% | RAM: 45.7% | Disk: 68% | Load: 0.75
```

### 📦 `backup-manager.sh` - Advanced Backup and Retention System

This script offers a robust solution for managing system backups, featuring compression, configurable retention policies, and cross-platform compatibility. It intelligently handles various backup sources, excludes specified patterns, and performs disk space checks to ensure successful operations. The script provides detailed logging and allows for easy inspection of backup archives without full extraction.

**Key Features:**

**Cross-Platform Support**: This script is designed to work on Linux, macOS, and Windows (via Git Bash).
**Configurable Backup Sources**: It allows specifying multiple directories or files to be backed up, with defaults provided for common user data.
**Smart Exclusions**: It supports excluding specific files or directories based on patterns (e.g., `node_modules`, `.git`, temporary files) to optimize backup size.
**Compression and Retention**: The script creates compressed `tar.gz` archives and automatically cleans up old backups based on a configurable retention period (default 30 days).
**Disk Space Pre-check**: It estimates backup size and verifies sufficient disk space before initiating the backup process.
**Backup Inspection**: The script provides options to list the contents of a backup archive or extract it to a temporary directory for detailed inspection.
**Detailed Logging**: All backup operations, successes, and failures are recorded to a log file (`/tmp/backup-manager.log`).
**Configuration Management**: It supports loading and saving configuration parameters from `${HOME}/.backup-manager.conf`.

**Usage:**

```bash
bash backup-manager.sh [OPTIONS]
```

**Options:**

*   `-c, --create`: Create a new backup.
*   `-l, --list`: List existing backups.
*   `-d, --delete <backup_file>`: Delete a specific backup file.
*   `-C, --clean`: Clean old backups based on retention policy.
*   `-i, --inspect <backup_file>`: Inspect contents of a backup file without full extraction.
*   `-s, --source <path>`: Add a source directory/file to backup (can be used multiple times).
*   `-D, --backup-dir <path>`: Set the backup destination directory.
*   `-R, --retention <days>`: Set retention period in days.
*   `-h, --help`: Show help message.

**Example:**

```bash
bash backup-manager.sh --create --source "${HOME}/my_project" --retention 7
bash backup-manager.sh --list
bash backup-manager.sh --clean
```

### 🧹 `log-cleaner.sh` - Simple and Efficient Log File Management

This script provides a straightforward solution for managing log files and temporary data across various operating systems (Linux, macOS, and Windows via Git Bash). It focuses on essential functionality: cleaning old files based on retention policies and rotating files to maintain a manageable number of recent logs. Designed to be lightweight and efficient, it operates without complex graphical interfaces or extensive dependencies.

**Key Features:**

**Cross-Platform Compatibility**: This script functions on Linux, macOS, and Windows (Git Bash).
**Configurable Paths**: It allows specifying multiple directories where log files and temporary data should be cleaned.
**Pattern-Based Cleaning**: The script targets files matching specific patterns (e.g., `*.log`, `*.tmp`, `*.cache`) for deletion.
**Exclusion Patterns**: It prevents accidental deletion of important files by allowing exclusion patterns.
**Retention Policy**: The script deletes files older than a specified number of days (default 30 days).
**File Rotation**: It keeps only a defined number of the most recent files for each pattern, rotating out older ones (default 10 files).
**Dry Run Mode**: It offers a `--dry-run` option to simulate the cleaning process without actually deleting any files, allowing for safe testing.
**Simple Logging**: All actions are recorded to a dedicated log file (`/tmp/log-cleaner.log`) for auditing.

**Usage:**

```bash
bash log-cleaner.sh [OPTIONS]
```

**Options:**

*   `-a, --age DAYS`: Set the retention period in days (default: 30).
*   `-k, --keep COUNT`: Specify the number of most recent files to keep (default: 10).
*   `--dry-run`: Execute a dry run to see what would be deleted without making actual changes.
*   `-h, --help`: Display the usage information and available options.

**Example:**

```bash
bash log-cleaner.sh --dry-run
bash log-cleaner.sh --age 7 --keep 5
```

## 🔮 Future Scripts (Under Development)

### 📡 `telegram-ping-monitor.sh` - Telegram Ping Monitor (Coming Soon)

This upcoming script will provide continuous monitoring of network connectivity to a specified host. Upon detecting a ping failure, it will automatically dispatch an alert message to a configured Telegram chat, ensuring prompt notification of network disruptions. This script will be essential for proactive monitoring of critical services and infrastructure.

**Key Features (Planned):**

**Continuous Host Monitoring**: This script will periodically ping a user-defined target host (e.g., `8.8.8.8`).
**Telegram Notifications**: It will send instant alerts to a specified Telegram chat upon detecting connectivity issues.
**Configurable Parameters**: It will allow easy setup of the target host, Telegram Bot Token, and Chat ID.
**Failure Detection**: It will identify and report network outages based on ping response.
**Cross-Platform Compatibility**: This script is designed for use across various Linux distributions.

**Usage (Planned):**

```bash
bash telegram-ping-monitor.sh
```

**Configuration (Planned):**

Users will need to provide their Telegram Bot Token and Chat ID to enable notifications.

**Status:** *This script is currently under development. Details and implementation will be provided soon.*

### 💾 `disk-usage-alert.sh` - Disk Space Monitoring and Alerting (Coming Soon)

This forthcoming script will proactively monitor disk space utilization on your system. It will be configured to check specified partitions and trigger alerts if the usage surpasses a predefined threshold. This is crucial for preventing system instability and ensuring continuous operation due to full disks.

**Key Features (Planned):**

**Disk Space Monitoring**: This script will regularly check the disk usage of specified file systems.
**Threshold-Based Alerts**: It will send notifications when disk usage exceeds a configurable percentage.
**Customizable Targets**: It will allow the selection of specific disks or partitions to monitor.
**Notification Integration**: Future integration with alerting systems (e.g., Telegram, email) for critical warnings is planned.
**Cross-Platform Compatibility**: This script is designed for use across various Linux distributions.

**Usage (Planned):**

```bash
bash disk-usage-alert.sh
```

**Configuration (Planned):**

Users will be able to set the monitoring threshold and target partitions.

**Status:** *This script is currently under development. Details and implementation will be provided soon.*

### 💚 `service-health-check.sh` - Service Health and Status Monitor (Coming Soon)

This upcoming script will be designed to monitor the operational status of critical system services. It will periodically check if specified services are running and respond appropriately if a service is found to be down or unhealthy. This tool will be invaluable for maintaining system stability and ensuring the continuous availability of essential applications.

**Key Features (Planned):**

**Service Monitoring**: This script will check the status of configured system services (e.g., Apache, Nginx, Docker).
**Automated Actions**: It will have the ability to restart services or trigger alerts upon detecting a failure.
**Configurable Services**: It will allow users to easily add or remove services to be monitored.
**Notification Integration**: Future integration with various alerting mechanisms (e.g., Telegram, email) is planned.
**Cross-Platform Compatibility**: This script is designed for use across various Linux distributions.

**Usage (Planned):**

```bash
bash service-health-check.sh
```

**Configuration (Planned):**

Users will define the services to monitor and the desired actions upon failure.

**Status:** *This script is currently under development. Details and implementation will be provided soon.*

## 🤝 Contribution

Contributions are welcome! If you have ideas for new scripts, improvements to existing ones, or bug fixes, please feel free to open an issue or submit a pull request.

## 📄 License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## 🧰 Maintainer

**Artem Rivnyi** — Junior Technical Support / DevOps Enthusiast

* **Email:** [artemrivnyi@outlook.com](mailto:artemrivnyi@outlook.com)  
* 🔗 [LinkedIn](https://www.linkedin.com/in/artem-rivnyi/)  
* 🌐 [Personal Projects](https://personal-page-devops.onrender.com/)  
* 💻 [GitHub](https://github.com/ArtemRivnyi)