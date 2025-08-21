# Sysmon Configuration for SENTINEL-X

This directory contains the Sysmon configuration used across Windows endpoints in the GOLINE SA infrastructure.

## 📁 Files

- `sysmon_config.xml` - Main Sysmon configuration file
- `version.txt` - Current Sysmon version
- `last_sync.txt` - Last synchronization metadata

## 🔄 Synchronization Methods

### Method 1: Direct from Windows Server
Run on Windows Server with Git installed:
```powershell
# One-time setup
cd C:\GitRepos
git clone git@github.com:paolokappa/wazuh-siem-rules.git

# Regular sync (add to Task Scheduler)
C:\GitRepos\wazuh-siem-rules\scripts\windows-sync-sysmon.ps1
```

### Method 2: Via Wazuh Manager
Run on Wazuh Manager:
```bash
/root/wazuh-rules-repo/scripts/fetch-sysmon-from-windows.sh <server-ip> <username>
```

### Method 3: Manual Copy
1. Copy `C:\ProgramData\Sysmon\sysmon_config.xml` from Windows
2. Place in `/root/wazuh-rules-repo/sysmon/` on Wazuh Manager
3. Run sync script: `/root/wazuh-rules-repo/sync-rules.sh`

## 📅 Automated Sync Setup

### Windows Task Scheduler (Recommended)
Create a scheduled task on your Windows Server:

1. Open Task Scheduler
2. Create Basic Task
3. Name: "Sysmon Config GitHub Sync"
4. Trigger: Daily at 02:00 AM (or your preference)
5. Action: Start a program
6. Program: `powershell.exe`
7. Arguments: `-ExecutionPolicy Bypass -File "C:\GitRepos\wazuh-siem-rules\scripts\windows-sync-sysmon.ps1"`

### Linux Cron (Alternative)
Add to Wazuh Manager crontab:
```bash
0 2 * * * /root/wazuh-rules-repo/scripts/fetch-sysmon-from-windows.sh server-ip username
```

## 🔧 Configuration Management

### Deploy Sysmon Config to Endpoints
```powershell
# Update Sysmon with new configuration
sysmon64 -c "C:\ProgramData\Sysmon\sysmon_config.xml"

# Verify configuration
sysmon64 -c
```

### Version Control Benefits
- Track all Sysmon configuration changes
- Rollback capability to previous versions
- Audit trail of who changed what and when
- Centralized configuration management
- Disaster recovery documentation

## 📊 Integration with Wazuh

Sysmon events are collected by Wazuh agent and processed using rules in:
- `/var/ossec/ruleset/rules/0595-win-sysmon_rules.xml` (default)
- `/var/ossec/etc/rules/local_rules.xml` (custom)

## 🔒 Security Notes

- Never commit credentials in Sysmon config
- Review all changes before syncing
- Use SSH keys for GitHub authentication
- Encrypt sensitive configuration sections if needed

---
*Part of SENTINEL-X Security Framework by GOLINE SA*