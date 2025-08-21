# 🛡️ SENTINEL-X: Enterprise Security Rules Engine
### Advanced Wazuh SIEM Detection & Response Framework

[![Wazuh](https://img.shields.io/badge/Wazuh-4.12-blue)](https://wazuh.com/)
[![Rules](https://img.shields.io/badge/Rules-270%2B-orange)](https://github.com/paolokappa/wazuh-siem-rules)
[![MITRE ATT&CK](https://img.shields.io/badge/MITRE-ATT%26CK-red)](https://attack.mitre.org/)
[![License](https://img.shields.io/badge/License-Private-darkred)](LICENSE)
[![Sync Status](https://img.shields.io/badge/Sync-Automated-green)](https://github.com/paolokappa/wazuh-siem-rules)
[![Security](https://img.shields.io/badge/Security-Enterprise-purple)](https://goline.ch)

---

**SENTINEL-X** is a comprehensive enterprise security rules engine built on Wazuh SIEM, featuring 270+ custom detection and response rules optimized for modern threat landscapes. Developed and maintained by GOLINE SA's Security Operations Center.

## 📋 Table of Contents
- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Rules Documentation](#rules-documentation)
- [Agent Configurations](#agent-configurations)
- [Sysmon Integration](#sysmon-integration)
- [Automation](#automation)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Security Considerations](#security-considerations)

## 🎯 Overview

**SENTINEL-X** is GOLINE SA's proprietary security detection framework, engineered to provide enterprise-grade threat detection, incident response, and compliance monitoring. This repository serves as the central nervous system for our security operations, containing battle-tested rules refined through real-world incident response.

### ⚡ Core Capabilities
- 🎯 **270+ Custom Rules**: Fine-tuned detection logic for enterprise threats
- 🤖 **Automated Response**: Active countermeasures against identified threats
- 🌐 **Threat Intelligence**: Integration with MISP, VirusTotal, and Suricata IDS
- 🔬 **Advanced Detection**: YARA scanning, DLL hijacking, DNS tunneling
- 🏢 **Enterprise Ready**: Optimized for Windows AD, Linux servers, and cloud workloads
- 📊 **MITRE ATT&CK**: Full framework mapping for threat hunting
- 🚀 **GitOps Workflow**: Infrastructure-as-code security management
- 🔐 **Zero Trust Architecture**: Granular whitelisting and verification

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
├── sysmon/                          # Sysmon configuration and documentation
│   └── sysmon_config.xml            # Enterprise Sysmon configuration (424KB, 5773 lines)
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

| Range | Category | Description | Count |
|-------|----------|-------------|-------|
| 100200-100999 | Initial Access & System Monitoring | Base security rules, file integrity monitoring | 19 rules |
| 110001-110999 | Threat Detection | Suricata IDS, malware, exploits, network threats | 71 rules |
| 111000-111999 | Critical Alerts | High-priority security events | 19 rules |
| 120000-120999 | Cisco FTD | Cisco Firepower Threat Defense rules | 5 rules |
| 130000-130999 | FortiGate | FortiGate firewall rules | 4 rules |
| 140000-140999 | CSF/LFD | ConfigServer Security & Firewall rules | 4 rules |
| 150000-150999 | Process Monitoring | Process creation and manipulation | 5 rules |
| 160000-160999 | YARA Integration | YARA malware scanning rules | 3 rules |
| 170000-170999 | DLL Hijacking | T1574 DLL side-loading detection | 3 rules |
| 180000-180999 | DNS Monitoring | T1071 DNS query analysis | 3 rules |
| 190000-190999 | MISP Integration | Threat intelligence from MISP | 12 rules |
| 200000-209999 | System Monitoring & FIM | File integrity and system monitoring | 27 rules |
| 210000-219999 | Whitelisting | False positive reduction | 21 rules |
| 220000-220299 | Custom Security Rules | Application-specific detection and whitelist | 76 rules |

### Complete Rule Categories

#### 🛡️ Core Security Monitoring (100xxx)
- **File Integrity Monitoring**: Ignore logs, temp files, cache
- **Linux Audit**: System call monitoring
- **Windows Audit**: Security event correlation
- **Authentication**: Failed login tracking

#### 🔍 Threat Detection (110xxx)
- **Suricata IDS Integration**:
  - ET TROJAN detection (110240)
  - ET MALWARE detection (110241)
  - ET EXPLOIT attempts (110242)
  - ET CNC communication (110243)
  - ET SCAN detection (110244)
  - ET POLICY violations (110245)
- **Network Threats**: Port scans, suspicious connections
- **Web Application Attacks**: SQL injection, XSS attempts

#### 🚨 Critical Security Events (111xxx)
- **Military/NATO Domain Detection**: Critical infrastructure monitoring
- **Data Exfiltration**: Large-scale data transfers
- **Advanced Persistent Threats**: Long-term compromise indicators

#### 🔥 Firewall Integration (120xxx-140xxx)
- **Cisco FTD Rules**: Threat detection from Cisco Firepower
- **FortiGate Rules**: FortiGate security events
- **CSF/LFD Rules**: Linux firewall and login failure daemon

#### 🔬 Advanced Detection (150xxx-180xxx)
- **Process Monitoring**: Suspicious process creation
- **YARA Scanning**: Malware signature matching
- **DLL Hijacking Detection**: T1574 technique monitoring
- **DNS Query Analysis**: T1071 application layer protocol

#### 🌐 Threat Intelligence (190xxx)
- **MISP Integration**: External threat feed correlation
- **VirusTotal Monitoring**: File reputation checking
- **IOC Matching**: Indicators of compromise detection

#### 📁 System & File Monitoring (200xxx)
- **Critical System Files**: OS file modifications
- **Configuration Changes**: System setting alterations
- **Registry Monitoring**: Windows registry changes
- **Service Modifications**: Service creation/modification

#### ✅ Whitelisting & False Positive Reduction (210xxx)
- **Intel Software**: Intel driver and management tools
- **Common Software**: Legitimate application behaviors
- **System Processes**: Normal OS operations

#### 🎯 Custom Application Rules (220xxx)

##### Detection Rules (220000-220099)
- **PowerShell Audit Log Reconnaissance** (220040-220044)
- **Admin Audit Log Extraction** (220041, 220120-220124)
- **Software Deployment from TEMP** (220050-220055)
- **Exchange AD Management** (220060-220064)
- **Process Access Monitoring** (220070-220074)

##### Application Whitelist Rules (220100-220199)
- **PrintNightmare Detection** (220100-220102)
- **VS Code Server** (220110-220114)
- **Admin Audit Extraction** (220120-220124)
- **NinjaOne RMM** (220130-220135)
- **Firefox Installation** (220140-220145)
- **IIS Components** (220160-220165)
- **Process Access Whitelist** (220170-220174)

##### System Whitelist Rules (220200-220299)
- **Rootcheck False Positives** (220200)
- **PsShutdown Scheduled Tasks** (220210-220211)
- **NinjaOne Deployment Scripts** (220220-220223)
- **ADAudit Plus Operations** (220037-220039, 220080-220083)

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

## 🕵️ Sysmon Integration

### Overview
**Sysmon (System Monitor)** is a Windows system service that logs system activity to the Windows Event Log, providing detailed information about process creations, network connections, and file/registry changes. Our enterprise configuration (`sysmon_config.xml`) is specifically tuned for **Wazuh SIEM integration** and represents **422KB of advanced threat detection rules** across **5,773 lines**.

### Why Sysmon + Wazuh?
- 🎯 **Enhanced Visibility**: Capture events Windows doesn't log by default
- 🔍 **Process Genealogy**: Complete parent-child process relationships
- 🌐 **Network Monitoring**: All network connections with process context
- 📁 **File Activity**: Comprehensive file system monitoring
- 🛡️ **Attack Detection**: Advanced techniques like DLL injection, hollowing
- 📊 **MITRE ATT&CK Mapping**: Direct correlation with attack techniques

### Sysmon Configuration Details

Our `sysmon_config.xml` includes:

#### 📋 Event Types Monitored (17 Categories)

| Event ID | Category | Description | Security Value |
|----------|----------|-------------|----------------|
| **1** | Process Creation | Command lines, hashes, parent processes | Malware execution, living-off-the-land |
| **2** | File Creation Time | File timestamp modifications | Anti-forensics, timestomping (T1070.006) |
| **3** | Network Connection | Outbound connections with process context | C2 communication, data exfiltration |
| **4** | Sysmon Service State | Service start/stop events | Service manipulation detection |
| **5** | Process Termination | Process end with termination codes | Process hiding, defensive evasion |
| **6** | Driver Load | Kernel driver loading events | Rootkit installation, privilege escalation |
| **7** | Image/DLL Load | Dynamic library loading | DLL injection (T1055), side-loading (T1574) |
| **8** | CreateRemoteThread | Remote thread creation | Process injection, code injection |
| **9** | RawAccessRead | Direct disk/volume access | Volume shadow copy attacks, disk forensics |
| **10** | ProcessAccess | Process memory access | Credential dumping (T1003), LSASS access |
| **11** | FileCreate | File creation events | Malware drops, lateral movement artifacts |
| **12-14** | Registry Events | Registry modifications | Persistence mechanisms, configuration changes |
| **15** | FileCreateStreamHash | Alternate Data Stream creation | ADS hiding techniques (T1564.004) |
| **17-18** | Pipe Events | Named pipe creation/connection | Inter-process communication, privilege escalation |
| **19-21** | WMI Events | WMI activity monitoring | WMI persistence (T1546.003), lateral movement |
| **22** | DNS Query | DNS resolution requests | DNS tunneling (T1071.004), C2 domains |
| **23,26** | File Delete | File deletion tracking | Evidence destruction, log clearing |

#### 🎯 Advanced Detection Features

##### Process Monitoring (Event ID 1)
```xml
<!-- Example: Detect PowerShell with suspicious parameters -->
<ProcessCreate onmatch="include">
  <CommandLine condition="contains all">powershell;-enc;-nop</CommandLine>
  <CommandLine condition="contains all">powershell;-w hidden;-noni</CommandLine>
</ProcessCreate>
```

**Detection Capabilities:**
- Encoded PowerShell commands (`-EncodedCommand`)
- Hidden window execution (`-WindowStyle Hidden`)
- Bypass execution policy (`-ExecutionPolicy Bypass`)
- Living-off-the-land binaries (LOLBins) usage
- Suspicious parent-child relationships

##### Network Monitoring (Event ID 3)
```xml
<!-- Example: Monitor suspicious network destinations -->
<NetworkConnect onmatch="include">
  <DestinationPort condition="is">4444</DestinationPort>
  <DestinationPort condition="is">5555</DestinationPort>
  <DestinationHostname condition="end with">.onion</DestinationHostname>
</NetworkConnect>
```

**Detection Capabilities:**
- Command and Control (C2) connections
- Tor network usage (.onion domains)
- Uncommon ports for common processes
- Lateral movement network patterns
- Data exfiltration to cloud services

##### DLL Injection Detection (Event ID 7)
```xml
<!-- Example: Detect unsigned DLLs in critical processes -->
<ImageLoad onmatch="include">
  <Image condition="end with">lsass.exe</Image>
  <Signed condition="is">false</Signed>
</ImageLoad>
```

**Detection Capabilities:**
- Unsigned DLL loading in critical processes
- DLL side-loading attacks (T1574.002)
- Process hollowing detection
- Reflective DLL loading
- Import address table (IAT) hooking

### Deployment Guide

#### Prerequisites
- Windows 10/11 or Windows Server 2016+
- Administrative privileges
- 100MB free disk space (for Sysmon)
- Wazuh agent installed and configured

#### Installation Steps

##### 1. Download Sysmon
```powershell
# Download Sysmon from Microsoft Sysinternals
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile "C:\temp\Sysmon.zip"
Expand-Archive -Path "C:\temp\Sysmon.zip" -DestinationPath "C:\Program Files\Sysmon"
```

##### 2. Deploy Configuration
```powershell
# Copy our enterprise configuration
Copy-Item "sysmon_config.xml" -Destination "C:\Program Files\Sysmon\"

# Install Sysmon with configuration
cd "C:\Program Files\Sysmon"
.\sysmon64.exe -accepteula -i sysmon_config.xml
```

##### 3. Verify Installation
```powershell
# Check Sysmon service status
Get-Service Sysmon64

# Verify event logging
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5
```

##### 4. Configure Wazuh Agent
Add to `ossec.conf` on Windows agents:
```xml
<localfile>
  <location>Microsoft-Windows-Sysmon/Operational</location>
  <log_format>eventchannel</log_format>
</localfile>
```

#### Group Policy Deployment (Enterprise)
```powershell
# Create GPO for Sysmon deployment
New-GPO -Name "SENTINEL-X Sysmon Deployment" -Comment "Enterprise Sysmon configuration"

# Configure startup script
Set-GPPrefRegistryValue -Name "SENTINEL-X Sysmon Deployment" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ValueName "Sysmon" -Value "C:\Program Files\Sysmon\sysmon64.exe" -Type String
```

### Performance Optimization

#### Resource Impact
- **CPU Usage**: 1-3% average on modern systems
- **Memory Usage**: 10-20MB resident memory
- **Disk I/O**: 50-200 events/second (varies by activity)
- **Log Volume**: 10-100MB per day per endpoint

#### Tuning Recommendations
```xml
<!-- Reduce noise from common processes -->
<ProcessCreate onmatch="exclude">
  <Image condition="end with">chrome.exe</Image>
  <Image condition="end with">firefox.exe</Image>
  <ParentImage condition="end with">explorer.exe</ParentImage>
</ProcessCreate>
```

#### Log Rotation Configuration
```xml
<!-- Configure Windows Event Log limits -->
<Configuration>
  <LogSettings>
    <MaxLogSize>100MB</MaxLogSize>
    <RetentionDays>30</RetentionDays>
  </LogSettings>
</Configuration>
```

### Integration with Wazuh Rules

Our Sysmon configuration works seamlessly with **220+ custom Wazuh rules** for:

#### Automated Threat Detection
- **Process Creation Anomalies**: Rules 220040-220044
- **Network Connection Monitoring**: Rules 110240-110245  
- **DLL Injection Detection**: Rules 170000-170999
- **Registry Persistence**: Rules 200000-209999

#### Example Integration
```xml
<!-- Wazuh rule detecting Sysmon Event ID 1 with suspicious PowerShell -->
<rule id="220041" level="15">
  <if_sid>61603</if_sid>
  <field name="win.eventdata.commandLine" type="pcre2">(?i)powershell.*-enc.*</field>
  <description>CRITICAL: Encoded PowerShell command detected via Sysmon</description>
  <mitre>
    <id>T1059.001</id>
    <id>T1027</id>
  </mitre>
</rule>
```

### Maintenance and Updates

#### Regular Tasks
```powershell
# Check Sysmon version
sysmon64.exe -c

# Update configuration (without restart)
sysmon64.exe -c sysmon_config.xml

# View current configuration
sysmon64.exe -c | Out-File current_config.xml
```

#### Configuration Management
- **Version Control**: All changes tracked in this Git repository
- **Automated Sync**: Configuration updated every 6 hours from domain controller
- **Testing**: New rules tested in lab environment first
- **Rollback**: Previous configurations maintained in Git history

#### Troubleshooting Common Issues
```powershell
# Sysmon not logging events
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 1

# Service not starting
Get-EventLog -LogName System -Source "Service Control Manager" | Where-Object {$_.Message -like "*Sysmon*"}

# Configuration syntax errors
sysmon64.exe -c sysmon_config.xml -v
```

### Security Considerations

#### Configuration Security
- **Schema Validation**: XML configuration validated against Sysmon schema
- **Access Control**: Configuration files protected with NTFS permissions
- **Tamper Detection**: File integrity monitoring on Sysmon configuration
- **Event Forwarding**: Secure transport to Wazuh Manager via TLS

#### Evasion Resistance
- **Multiple Detection Layers**: Process, network, and file system monitoring
- **Behavioral Analysis**: Pattern detection across multiple event types
- **Anti-Tampering**: Sysmon self-protection mechanisms
- **Log Integrity**: Windows Event Log security and audit trails

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

**SENTINEL-X** is proprietary software of GOLINE SA.  
© 2025 GOLINE SA, Switzerland. All rights reserved.  
Unauthorized use, reproduction, or distribution is strictly prohibited.

## 🏆 Acknowledgments

- **Wazuh Project** - For the powerful open-source SIEM foundation
- **MITRE Corporation** - For the ATT&CK framework
- **Suricata Team** - For the exceptional IDS engine
- **Security Community** - For shared threat intelligence

---

<div align="center">

### 🛡️ SENTINEL-X
**Enterprise Security Rules Engine**

*Version 2.0 | August 2025*  
*Engineered by GOLINE SA Security Operations Center*  
*Stabio, Switzerland* 🇨🇭

[![GOLINE SA](https://img.shields.io/badge/GOLINE-Security-blue?style=for-the-badge)](https://goline.ch)

</div>