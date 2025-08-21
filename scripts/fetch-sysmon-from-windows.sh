#!/bin/bash

# SENTINEL-X Sysmon Configuration Fetch Script
# Fetches Sysmon config from Windows Server via SSH/WinRM or shared folder
# Run this on Wazuh Manager

WINDOWS_SERVER="${1:-your-windows-server}"
WINDOWS_USER="${2:-Administrator}"
SYSMON_REMOTE_PATH="C:/ProgramData/Sysmon/sysmon_config.xml"
REPO_DIR="/root/wazuh-rules-repo"
SYSMON_DIR="$REPO_DIR/sysmon"

echo "=== Fetching Sysmon Config from Windows Server ==="
echo "Server: $WINDOWS_SERVER"
echo "Time: $(date)"

# Create sysmon directory if it doesn't exist
mkdir -p "$SYSMON_DIR"

# Method 1: Using SSH (if OpenSSH is installed on Windows)
if command -v ssh &> /dev/null; then
    echo "Attempting to fetch via SSH..."
    scp "${WINDOWS_USER}@${WINDOWS_SERVER}:${SYSMON_REMOTE_PATH}" "$SYSMON_DIR/sysmon_config.xml" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Successfully fetched via SSH"
    else
        echo "SSH fetch failed, trying alternative methods..."
    fi
fi

# Method 2: Using SMB share (if configured)
if command -v smbclient &> /dev/null; then
    echo "Attempting to fetch via SMB..."
    # Assumes a share is configured on Windows
    smbclient "//${WINDOWS_SERVER}/C$" -U "$WINDOWS_USER" -c "get ProgramData/Sysmon/sysmon_config.xml $SYSMON_DIR/sysmon_config.xml" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Successfully fetched via SMB"
    fi
fi

# Method 3: Using PowerShell remoting (requires WinRM)
# This would need additional setup but is very reliable

# Check if file was fetched
if [ ! -f "$SYSMON_DIR/sysmon_config.xml" ]; then
    echo "ERROR: Could not fetch Sysmon configuration"
    exit 1
fi

# Add metadata
echo "Last fetched from: $WINDOWS_SERVER" > "$SYSMON_DIR/last_sync.txt"
echo "Fetch time: $(date '+%Y-%m-%d %H:%M:%S')" >> "$SYSMON_DIR/last_sync.txt"

# Change to repo directory
cd "$REPO_DIR"

# Check for changes
if git diff --quiet HEAD -- sysmon/; then
    echo "No changes in Sysmon configuration"
    exit 0
fi

# Commit and push
echo "Committing Sysmon configuration..."
git add sysmon/
git commit -m "Update Sysmon configuration from $WINDOWS_SERVER - $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main

echo "=== Sysmon config synced to GitHub ==="