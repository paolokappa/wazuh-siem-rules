# Sysmon Configuration for SENTINEL-X

This directory contains the Sysmon configuration used across Windows endpoints in the GOLINE SA infrastructure.

## 📁 Files

- `sysmon_config.xml` - Main Sysmon configuration file

## 🔄 Synchronization Methods

### Method 1: Manual Copy and Sync
1. Copy Sysmon config from your Windows environment
2. Place it in `/root/wazuh-rules-repo/sysmon/sysmon_config.xml`
3. Run the sync script:
```bash
cd /root/wazuh-rules-repo
./sync-rules.sh
```

### Method 2: Internal Scripts (Not Published)
Internal synchronization scripts are maintained separately for security reasons.
Contact your system administrator for access to automated sync scripts.

### Method 3: Automated Sync
Automated synchronization is configured separately for security reasons.
Contact your system administrator for internal sync procedures.

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