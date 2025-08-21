#!/bin/bash

# SENTINEL-X Sysmon Configuration Sync from Domain Controller
# Fetches Sysmon config from BUSE005 DC NETLOGON share
# Author: GOLINE SA Security Team

# Configuration
DC_NAME="BUSE005.buonvicini.local"
DC_IP="${DC_IP:-192.168.1.10}"  # Set DC_IP environment variable or update this
NETLOGON_PATH="//NETLOGON/Tools/Sysmon/sysmon_config.xml"
REPO_DIR="/root/wazuh-rules-repo"
SYSMON_DIR="$REPO_DIR/sysmon"
LOG_FILE="/var/log/sysmon-sync.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=== SENTINEL-X Sysmon Config Sync from DC ===${NC}"
echo "DC: $DC_NAME"
echo "Time: $(date)"
echo "---" | tee -a "$LOG_FILE"
echo "Sync started at $(date)" >> "$LOG_FILE"

# Create sysmon directory if it doesn't exist
mkdir -p "$SYSMON_DIR"

# Method 1: Using smbclient (anonymous access to NETLOGON)
echo -e "${YELLOW}Attempting to fetch from NETLOGON share...${NC}"
if command -v smbclient &> /dev/null; then
    # Try with anonymous access first (NETLOGON is usually readable)
    smbclient "//$DC_NAME/NETLOGON" -N -c "get Tools/Sysmon/sysmon_config.xml $SYSMON_DIR/sysmon_config.xml" 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Anonymous access failed, trying with credentials...${NC}"
        # If you need credentials, uncomment and set these
        # DOMAIN="BUONVICINI"
        # USERNAME="your-username"
        # read -s -p "Enter password for $DOMAIN\\$USERNAME: " PASSWORD
        # echo
        # smbclient "//$DC_NAME/NETLOGON" -U "$DOMAIN\\$USERNAME%$PASSWORD" -c "get Tools/Sysmon/sysmon_config.xml $SYSMON_DIR/sysmon_config.xml"
    fi
    
    if [ -f "$SYSMON_DIR/sysmon_config.xml" ]; then
        echo -e "${GREEN}Successfully fetched via SMB${NC}"
        echo "Fetched successfully via SMB at $(date)" >> "$LOG_FILE"
    fi
else
    echo -e "${RED}smbclient not found. Installing...${NC}"
    apt-get update && apt-get install -y smbclient
fi

# Method 2: Using mount.cifs (if smbclient fails)
if [ ! -f "$SYSMON_DIR/sysmon_config.xml" ]; then
    echo -e "${YELLOW}Trying CIFS mount method...${NC}"
    MOUNT_POINT="/mnt/dc-netlogon"
    mkdir -p "$MOUNT_POINT"
    
    # Try mounting NETLOGON share
    mount -t cifs "//$DC_NAME/NETLOGON" "$MOUNT_POINT" -o guest,vers=2.0 2>/dev/null
    
    if [ $? -eq 0 ]; then
        if [ -f "$MOUNT_POINT/Tools/Sysmon/sysmon_config.xml" ]; then
            cp "$MOUNT_POINT/Tools/Sysmon/sysmon_config.xml" "$SYSMON_DIR/"
            echo -e "${GREEN}Successfully fetched via CIFS mount${NC}"
            echo "Fetched successfully via CIFS at $(date)" >> "$LOG_FILE"
        fi
        umount "$MOUNT_POINT"
    fi
fi

# Method 3: Using curl with SMB (if supported)
if [ ! -f "$SYSMON_DIR/sysmon_config.xml" ]; then
    echo -e "${YELLOW}Trying curl SMB method...${NC}"
    curl -s "smb://$DC_NAME/NETLOGON/Tools/Sysmon/sysmon_config.xml" -o "$SYSMON_DIR/sysmon_config.xml" 2>/dev/null
    
    if [ -f "$SYSMON_DIR/sysmon_config.xml" ] && [ -s "$SYSMON_DIR/sysmon_config.xml" ]; then
        echo -e "${GREEN}Successfully fetched via curl${NC}"
        echo "Fetched successfully via curl at $(date)" >> "$LOG_FILE"
    else
        rm -f "$SYSMON_DIR/sysmon_config.xml" 2>/dev/null
    fi
fi

# Check if file was successfully fetched
if [ ! -f "$SYSMON_DIR/sysmon_config.xml" ]; then
    echo -e "${RED}ERROR: Could not fetch Sysmon configuration from $DC_NAME${NC}"
    echo "Fetch failed at $(date)" >> "$LOG_FILE"
    exit 1
fi

# Validate XML
if command -v xmllint &> /dev/null; then
    xmllint --noout "$SYSMON_DIR/sysmon_config.xml" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "${RED}WARNING: Sysmon config XML validation failed${NC}"
        echo "XML validation failed at $(date)" >> "$LOG_FILE"
    else
        echo -e "${GREEN}XML validation passed${NC}"
    fi
fi

# Add metadata
cat > "$SYSMON_DIR/last_sync.txt" << EOF
Last fetched from: $DC_NAME
Source path: \\NETLOGON\Tools\Sysmon\sysmon_config.xml
Fetch time: $(date '+%Y-%m-%d %H:%M:%S')
Fetched by: $(hostname)
EOF

# Get file info
if [ -f "$SYSMON_DIR/sysmon_config.xml" ]; then
    FILE_SIZE=$(du -h "$SYSMON_DIR/sysmon_config.xml" | cut -f1)
    FILE_LINES=$(wc -l < "$SYSMON_DIR/sysmon_config.xml")
    echo "File size: $FILE_SIZE" >> "$SYSMON_DIR/last_sync.txt"
    echo "Total lines: $FILE_LINES" >> "$SYSMON_DIR/last_sync.txt"
fi

# Change to repo directory
cd "$REPO_DIR"

# Check for changes
if git diff --quiet HEAD -- sysmon/; then
    echo -e "${YELLOW}No changes in Sysmon configuration${NC}"
    echo "No changes detected at $(date)" >> "$LOG_FILE"
    exit 0
fi

# Show what changed
echo -e "${CYAN}Changes detected:${NC}"
git diff --stat sysmon/

# Commit and push
echo -e "${YELLOW}Committing Sysmon configuration...${NC}"
git add sysmon/
git commit -m "Update Sysmon configuration from $DC_NAME - $(date '+%Y-%m-%d %H:%M:%S')

Source: \\\\$DC_NAME\\NETLOGON\\Tools\\Sysmon\\sysmon_config.xml
Fetched via: $(hostname)"

# Push to GitHub
echo -e "${YELLOW}Pushing to GitHub...${NC}"
git push origin main

if [ $? -eq 0 ]; then
    echo -e "${GREEN}=== Sysmon config synced to GitHub ===${NC}"
    echo "Successfully synced to GitHub at $(date)" >> "$LOG_FILE"
else
    echo -e "${RED}Failed to push to GitHub${NC}"
    echo "GitHub push failed at $(date)" >> "$LOG_FILE"
    exit 1
fi