#!/bin/bash

echo "=== Setting up Automatic Sync to GitHub ==="
echo

echo "Choose sync frequency:"
echo "1) Every hour"
echo "2) Every 6 hours"
echo "3) Every 12 hours"
echo "4) Daily at midnight"
echo "5) Daily at custom time"
echo "6) Custom cron expression"

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        cron_schedule="0 * * * *"
        desc="every hour"
        ;;
    2)
        cron_schedule="0 */6 * * *"
        desc="every 6 hours"
        ;;
    3)
        cron_schedule="0 */12 * * *"
        desc="every 12 hours"
        ;;
    4)
        cron_schedule="0 0 * * *"
        desc="daily at midnight"
        ;;
    5)
        read -p "Enter hour (0-23): " hour
        read -p "Enter minute (0-59): " minute
        cron_schedule="$minute $hour * * *"
        desc="daily at ${hour}:${minute}"
        ;;
    6)
        read -p "Enter custom cron expression: " cron_schedule
        desc="custom schedule"
        ;;
    *)
        echo "Invalid choice!"
        exit 1
        ;;
esac

# Create cron entry
cron_entry="$cron_schedule /root/wazuh-rules-repo/sync-rules.sh >> /var/log/wazuh-rules-sync.log 2>&1"

# Check if cron entry already exists
if crontab -l 2>/dev/null | grep -q "sync-rules.sh"; then
    echo "Removing existing sync-rules.sh cron job..."
    (crontab -l 2>/dev/null | grep -v "sync-rules.sh") | crontab -
fi

# Add new cron entry
(crontab -l 2>/dev/null; echo "$cron_entry") | crontab -

echo
echo "=== Cron Job Created ==="
echo "Schedule: $desc"
echo "Cron expression: $cron_schedule"
echo "Log file: /var/log/wazuh-rules-sync.log"
echo
echo "Current crontab:"
crontab -l | grep sync-rules.sh
echo
echo "To view sync logs: tail -f /var/log/wazuh-rules-sync.log"
echo "To remove automatic sync: crontab -e (and delete the sync-rules.sh line)"