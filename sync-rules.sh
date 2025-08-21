#!/bin/bash

# Wazuh Complete Sync Script
# This script syncs all Wazuh configurations from installation to Git repo

REPO_DIR="/root/wazuh-rules-repo"

echo "=== Wazuh Complete Configuration Sync to GitHub ==="
echo "Time: $(date)"

# Change to repo directory
cd "$REPO_DIR" || exit 1

# Sync rules
echo "Syncing rules..."
cp /var/ossec/etc/rules/local_rules.xml "$REPO_DIR/rules/" 2>/dev/null || echo "  - local_rules.xml not found"

# Sync shared agent configurations
echo "Syncing agent configurations..."
for group in Linux Windows_PC Windows_DC_Servers Windows_Servers; do
    if [ -f "/var/ossec/etc/shared/$group/agent.conf" ]; then
        cp "/var/ossec/etc/shared/$group/agent.conf" "$REPO_DIR/shared/$group/"
        echo "  - $group/agent.conf synced"
    fi
done

# Check for other shared groups
echo "Checking for additional shared groups..."
for dir in /var/ossec/etc/shared/*/; do
    if [ -d "$dir" ]; then
        group_name=$(basename "$dir")
        # Skip default group
        if [ "$group_name" != "default" ]; then
            # Create directory if it doesn't exist
            if [ ! -d "$REPO_DIR/shared/$group_name" ]; then
                mkdir -p "$REPO_DIR/shared/$group_name"
                echo "  - Created new group: $group_name"
            fi
            # Copy agent.conf if it exists
            if [ -f "$dir/agent.conf" ]; then
                cp "$dir/agent.conf" "$REPO_DIR/shared/$group_name/"
                echo "  - $group_name/agent.conf synced"
            fi
        fi
    fi
done

# Check if there are changes
if git diff --quiet HEAD; then
    echo "No changes detected"
    exit 0
fi

# Show changes
echo "Changes detected:"
git status --short
git diff --stat

# Add and commit all changes
git add -A
git commit -m "Update Wazuh configurations - $(date '+%Y-%m-%d %H:%M:%S')

Automated sync from Wazuh installation
Source: $WAZUH_RULES"

# Push to GitHub if remote exists
if git remote | grep -q origin; then
    echo "Pushing to GitHub..."
    git push origin main
    echo "Successfully pushed to GitHub"
else
    echo "No remote origin configured. To push to GitHub, run:"
    echo "  git remote add origin <your-github-repo-url>"
    echo "  git push -u origin main"
fi

echo "=== Sync completed ==="