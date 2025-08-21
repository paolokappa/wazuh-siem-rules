#!/bin/bash

# Wazuh Complete Deploy Script
# This script deploys all configurations from Git repo to Wazuh installation

REPO_DIR="/root/wazuh-rules-repo"
BACKUP_DIR="/var/ossec/backup/$(date +%Y%m%d_%H%M%S)"

echo "=== Deploy All Configurations from Git to Wazuh ==="
echo "Time: $(date)"

# Create backup directory
echo "Creating backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Backup current configurations
echo "Backing up current configurations..."
cp -r /var/ossec/etc/rules/local_rules.xml "$BACKUP_DIR/" 2>/dev/null
cp -r /var/ossec/etc/shared/* "$BACKUP_DIR/" 2>/dev/null

# Deploy rules
if [ -f "$REPO_DIR/rules/local_rules.xml" ]; then
    echo "Deploying local_rules.xml..."
    cp "$REPO_DIR/rules/local_rules.xml" "/var/ossec/etc/rules/"
fi

# Deploy shared agent configurations
echo "Deploying agent configurations..."
for dir in "$REPO_DIR"/shared/*/; do
    if [ -d "$dir" ]; then
        group_name=$(basename "$dir")
        if [ -f "$dir/agent.conf" ]; then
            mkdir -p "/var/ossec/etc/shared/$group_name"
            cp "$dir/agent.conf" "/var/ossec/etc/shared/$group_name/"
            echo "  - Deployed $group_name/agent.conf"
        fi
    fi
done

# Test configuration
echo "Testing Wazuh configuration..."
if /var/ossec/bin/wazuh-analysisd -t 2>&1 | grep -q ERROR; then
    echo "ERROR: Configuration test failed!"
    echo "Restoring backup..."
    cp "$WAZUH_RULES.bak.$(date +%Y%m%d_%H%M%S)" "$WAZUH_RULES"
    exit 1
fi

echo "Configuration test passed"

# Restart Wazuh Manager
read -p "Do you want to restart Wazuh Manager now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Restarting Wazuh Manager..."
    systemctl restart wazuh-manager
    echo "Wazuh Manager restarted"
fi

echo "=== Deployment completed ==="