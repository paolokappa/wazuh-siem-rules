# Wazuh SIEM Rules Repository

[![Wazuh](https://img.shields.io/badge/Wazuh-4.12-blue)](https://wazuh.com/)
[![License](https://img.shields.io/badge/License-Private-red)](LICENSE)
[![Sync Status](https://img.shields.io/badge/Sync-Automated-green)](https://github.com/paolokappa/wazuh-siem-rules)

## 📋 Table of Contents
- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Rules Documentation](#rules-documentation)
- [Agent Configurations](#agent-configurations)
- [Automation](#automation)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Security Considerations](#security-considerations)

## 🎯 Overview

This repository contains custom Wazuh SIEM rules and agent configurations for enterprise infrastructure. It provides centralized management, version control, and automated synchronization for all Wazuh security configurations.

### Key Features
- 🛡️ **Custom Security Rules**: Detection and whitelist rules for various threats and legitimate software
- 🔄 **Automated Synchronization**: Hourly backup to GitHub
- 📦 **Complete Configuration Management**: Rules, agent groups, and deployment scripts
- 🚀 **Easy Deployment**: One-command deployment from Git to production
- 📊 **Version Control**: Track all changes with Git history
- 🔐 **Security-First Design**: Separate detection and whitelist rules

## 📁 Repository Structure

```
wazuh-siem-rules/
├── rules/
│   └── local_rules.xml              # Custom detection and whitelist rules
├── shared/                          # Agent group configurations
│   ├── Linux/
│   │   └── agent.conf               # Linux agents configuration
│   ├── Windows_PC/
│   │   └── agent.conf               # Windows workstations configuration
│   ├── Windows_DC_Servers/
│   │   └── agent.conf               # Domain Controllers configuration
│   ├── Windows_Servers/
│   │   └── agent.conf               # Windows Servers configuration
│   └── MacOS/
│       └── agent.conf               # MacOS agents configuration
├── scripts/                         # Management scripts
│   ├── sync-rules.sh               # Sync from Wazuh to Git
│   ├── deploy-rules.sh             # Deploy from Git to Wazuh
│   ├── setup-github.sh             # GitHub repository setup
│   ├── setup-ssh-github.sh        # SSH authentication setup
│   └── setup-cron.sh               # Automatic sync setup
├── .gitignore                       # Git ignore rules
└── README.md                        # This documentation
```

## 🚀 Installation

### Prerequisites
- Wazuh Manager 4.12+ installed
- Git installed on Wazuh Manager server
- GitHub account with repository access
- Root or sudo access on Wazuh Manager

### Initial Setup

1. **Clone the repository**:
```bash
cd /root
git clone git@github.com:paolokappa/wazuh-siem-rules.git wazuh-rules-repo
cd wazuh-rules-repo
```

2. **Configure GitHub authentication**:
```bash
./setup-github.sh
# Follow the prompts to set up SSH keys
```

3. **Set up automatic synchronization**:
```bash
./setup-cron.sh
# Choose your preferred sync frequency
```

## ⚙️ Configuration

### Environment Variables
The scripts use the following paths (can be modified in scripts):
- **Wazuh Installation**: `/var/ossec`
- **Rules Directory**: `/var/ossec/etc/rules`
- **Shared Configs**: `/var/ossec/etc/shared`
- **Repository**: `/root/wazuh-rules-repo`
- **Backup Directory**: `/var/ossec/backup`
- **Sync Log**: `/var/log/wazuh-rules-sync.log`

### Git Configuration
```bash
git config --global user.name "your-username"
git config --global user.email "your-email@example.com"
```

## 📖 Usage

### Manual Synchronization

#### Push changes to GitHub:
```bash
cd /root/wazuh-rules-repo
./sync-rules.sh
```

#### Pull and deploy from GitHub:
```bash
cd /root/wazuh-rules-repo
git pull origin main
./deploy-rules.sh
```

### Automatic Synchronization
The system is configured to automatically sync every hour. To check the status:
```bash
# View sync logs
tail -f /var/log/wazuh-rules-sync.log

# Check cron job
crontab -l | grep sync-rules

# Last sync time
ls -la /root/wazuh-rules-repo/.git/FETCH_HEAD
```

## 📚 Rules Documentation

### Rule ID Ranges

| Range | Category | Description |
|-------|----------|-------------|
| 220000-220099 | General Security | Base security detection rules |
| 220100-220199 | Application Whitelist | Legitimate software whitelist rules |
| 220200-220299 | System Whitelist | System utilities and OS component whitelist |

### Current Rule Categories

#### 🔍 Detection Rules
- **PrintNightmare Detection** (220100-220102): Detects PrintNightmare vulnerability exploitation
- **Admin Audit Log Extraction** (220120-220124): Monitors suspicious audit log exports
- **Software Deployment Monitoring** (220130-220135): Tracks software installation from TEMP
- **PowerShell Reconnaissance** (220040-220044): Detects PowerShell-based enumeration

#### ✅ Whitelist Rules
- **VS Code Server** (220110-220114): Legitimate VS Code remote development
- **NinjaOne RMM** (220131-220135, 220220-220223): RMM tool operations
- **Firefox Installation** (220140-220145): Browser deployment
- **IIS Components** (220160-220165): Web server management
- **ADAudit Plus** (220037-220039, 220080-220083): Audit tool operations
- **PsShutdown** (220210-220211): Scheduled shutdown operations
- **System Utilities** (220200): diff command false positives

### Rule Examples

#### Detection Rule Example:
```xml
<rule id="220041" level="15">
  <if_sid>220040</if_sid>
  <field name="win.eventdata.scriptBlockText" type="pcre2">ResultSize\s*\d{5,}</field>
  <description>CRITICAL: Large-scale admin audit log extraction detected</description>
  <mitre>
    <id>T1530</id>
    <id>T1005</id>
  </mitre>
</rule>
```

#### Whitelist Rule Example:
```xml
<rule id="220220" level="0">
  <if_sid>220051</if_sid>
  <field name="win.eventdata.image" type="pcre2">(?i)powershell\.exe</field>
  <field name="win.eventdata.commandLine" type="pcre2">(?i)NinjaRMMAgent</field>
  <description>Whitelist: NinjaOne RMM software deployment</description>
</rule>
```

## 🖥️ Agent Configurations

### Linux Agents
- **File Integrity Monitoring**: Optimized for performance (3600s frequency)
- **Log Collection**: System logs, Apache, Suricata IDS, Audit
- **Security Checks**: CIS benchmarks for Ubuntu 22.04/24.04
- **Resource Monitoring**: Memory and disk usage alerts
- **Active Response**: Yara scanning, host-deny for attacks

### Windows Workstations (Windows_PC)
- **Sysmon Integration**: Full event monitoring
- **Security Monitoring**: PowerShell, RDP, authentication
- **Application Control**: Track software installations
- **USB Monitoring**: Removable device tracking
- **Buffer Optimization**: 50000 queue size, 200 events/sec

### Domain Controllers (Windows_DC_Servers)
- **Enhanced Auditing**: AD changes, DNS, DHCP monitoring
- **Critical Service Monitoring**: AD DS, DNS, CA services
- **Security Focus**: Kerberos, LDAP, authentication events
- **Performance Tuning**: 100000 queue size, 500 events/sec
- **Special Whitelisting**: ADAudit Plus operations

### Windows Servers
- **Service Monitoring**: IIS, SQL, Exchange tracking
- **Security Hardening**: AppLocker, Windows Firewall
- **Performance Monitoring**: Resource utilization
- **Backup Monitoring**: Windows Backup status
- **Vulnerability Detection**: Enabled with 5m intervals

### MacOS Agents
- **System Integrity**: macOS-specific file monitoring
- **Security Framework**: XProtect, Gatekeeper monitoring
- **Log Collection**: Unified logs, security logs
- **Application Monitoring**: App installations and updates

## 🤖 Automation

### Hourly Sync (Active)
```bash
# Cron job running every hour
0 * * * * /root/wazuh-rules-repo/sync-rules.sh >> /var/log/wazuh-rules-sync.log 2>&1
```

### Sync Process Flow
1. **Detection**: Script checks for changes in Wazuh configs
2. **Copy**: Updates repository with latest configurations
3. **Commit**: Creates timestamped commit if changes exist
4. **Push**: Automatically pushes to GitHub
5. **Log**: Records all actions in sync log

### Manual Sync Options
```bash
# Sync only rules
cp /var/ossec/etc/rules/local_rules.xml /root/wazuh-rules-repo/rules/

# Sync specific agent group
cp /var/ossec/etc/shared/Linux/agent.conf /root/wazuh-rules-repo/shared/Linux/

# Force sync all
./sync-rules.sh
```

## 🔧 Troubleshooting

### Common Issues

#### Sync Not Working
```bash
# Check cron service
systemctl status cron

# Verify script permissions
ls -la /root/wazuh-rules-repo/*.sh

# Check sync log for errors
tail -50 /var/log/wazuh-rules-sync.log
```

#### Git Push Failures
```bash
# Test SSH connection
ssh -T git@github.com

# Check remote URL
git remote -v

# Verify SSH key
cat ~/.ssh/github_wazuh.pub
```

#### Rule Syntax Errors
```bash
# Test configuration
/var/ossec/bin/wazuh-analysisd -t

# Check specific rule
grep "rule_id" /var/ossec/etc/rules/local_rules.xml
```

### Log Locations
- **Wazuh Manager**: `/var/ossec/logs/ossec.log`
- **Sync Operations**: `/var/log/wazuh-rules-sync.log`
- **Active Responses**: `/var/ossec/logs/active-responses.log`

## 🤝 Contributing

### Workflow
1. **Local Changes**: Make changes to Wazuh configuration
2. **Test**: Verify with `wazuh-analysisd -t`
3. **Sync**: Run `./sync-rules.sh` or wait for automatic sync
4. **Review**: Check changes on GitHub
5. **Deploy**: Use `./deploy-rules.sh` on other Wazuh instances

### Best Practices
- ✅ Always test rules before committing
- ✅ Use descriptive commit messages
- ✅ Document new rule IDs in this README
- ✅ Follow existing rule ID ranges
- ✅ Include MITRE ATT&CK mappings
- ✅ Test on non-production first

## 🔐 Security Considerations

### Repository Security
- 🔒 Repository is private by default
- 🔑 SSH authentication required
- 📝 No sensitive data (passwords, keys) in configs
- 🛡️ Whitelist rules use level="0" to prevent alerts

### Deployment Security
- ✅ Automatic backup before deployment
- ✅ Configuration validation before restart
- ✅ Rollback capability with backups
- ✅ Audit trail via Git history

### Access Control
```bash
# Restrict repository access
chmod 700 /root/wazuh-rules-repo
chmod 600 /root/.ssh/github_wazuh

# Verify file permissions
ls -la /var/ossec/etc/rules/local_rules.xml
```

## 📊 Monitoring

### Health Checks
```bash
# Check last sync
grep "Sync completed" /var/log/wazuh-rules-sync.log | tail -1

# Verify rule count
grep -c "<rule id" /var/ossec/etc/rules/local_rules.xml

# Active agent groups
ls -d /var/ossec/etc/shared/*/ | wc -l
```

### Performance Metrics
- **Sync Duration**: Typically < 5 seconds
- **Repository Size**: ~500KB
- **Commit Frequency**: Hourly (if changes detected)
- **Rule Processing**: < 100ms per rule

## 📅 Maintenance

### Regular Tasks
- **Weekly**: Review sync logs for errors
- **Monthly**: Audit and optimize rules
- **Quarterly**: Review agent configurations
- **Yearly**: Archive old backups

### Backup Strategy
```bash
# Local backups created on each deployment
ls -la /var/ossec/backup/

# GitHub serves as remote backup
# History preserved in Git commits
```

## 📞 Support

### Resources
- **Wazuh Documentation**: https://documentation.wazuh.com/
- **Repository**: https://github.com/paolokappa/wazuh-siem-rules
- **Wazuh Manager**: Your SOC platform

### Contact
- **Administrator**: Security Team
- **Organization**: GOLINE SA

---

## 📝 License

This repository contains proprietary security configurations for buonvicini.local infrastructure. 
All rights reserved. Not for public distribution.

## 🏆 Acknowledgments

- Wazuh Project for the excellent SIEM platform
- MITRE ATT&CK for threat framework
- Security community for threat intelligence

---

*Last Updated: August 2025*
*Version: 1.0.0*
*Maintained by: SOC Team - GOLINE SA*