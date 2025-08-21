# Wazuh Rules Repository

This repository contains custom Wazuh rules and agent configurations for the buonvicini.local domain.

## Structure

```
.
├── rules/
│   └── local_rules.xml        # Custom detection and whitelist rules
└── shared/
    ├── Linux/
    │   └── agent.conf          # Linux agents configuration
    ├── Windows_PC/
    │   └── agent.conf          # Windows workstations configuration
    ├── Windows_DC_Servers/
    │   └── agent.conf          # Domain Controllers configuration
    └── Windows_Servers/
        └── agent.conf          # Windows Servers configuration
```

## Deployment

To deploy these configurations to your Wazuh Manager:

```bash
# Copy rules
cp rules/local_rules.xml /var/ossec/etc/rules/

# Copy shared agent configurations
cp -r shared/* /var/ossec/etc/shared/

# Test configuration
/var/ossec/bin/wazuh-analysisd -t

# Restart Wazuh Manager
systemctl restart wazuh-manager
```

## Rule ID Ranges

- 220000-220099: General security rules
- 220100-220199: Application-specific whitelist rules  
- 220200-220299: System and utility whitelist rules

## Recent Changes

- Added NinjaOne RMM whitelist rules (220220-220223)
- Added PsShutdown scheduled shutdown whitelist (220210-220211)
- Added ADAudit Plus whitelist for all domain controllers
- Fixed buffer overflow issues in Linux agent configuration
- Added PrintNightmare vulnerability detection rules