#!/bin/bash

email="${1}"
username="${2}"
repo="${3}"

echo "=== Setting up SSH for GitHub ==="

# Check if SSH key already exists
if [ -f /root/.ssh/id_ed25519 ]; then
    echo "SSH key already exists at /root/.ssh/id_ed25519"
    read -p "Do you want to use the existing key? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Generating new SSH key..."
        ssh-keygen -t ed25519 -C "$email" -f /root/.ssh/id_ed25519_wazuh -N ""
        key_file="/root/.ssh/id_ed25519_wazuh"
    else
        key_file="/root/.ssh/id_ed25519"
    fi
else
    echo "Generating SSH key..."
    ssh-keygen -t ed25519 -C "$email" -f /root/.ssh/id_ed25519 -N ""
    key_file="/root/.ssh/id_ed25519"
fi

# Start SSH agent
eval "$(ssh-agent -s)"
ssh-add "$key_file"

# Display public key
echo
echo "=== Your SSH Public Key ==="
echo "Copy the following key and add it to GitHub (Settings > SSH and GPG keys):"
echo
cat "${key_file}.pub"
echo
echo "=== Instructions ==="
echo "1. Copy the above SSH key"
echo "2. Go to https://github.com/settings/keys"
echo "3. Click 'New SSH key'"
echo "4. Give it a title (e.g., 'Wazuh Server')"
echo "5. Paste the key and save"
echo

read -p "Press Enter after you've added the key to GitHub..."

# Test SSH connection
echo "Testing SSH connection to GitHub..."
ssh -T git@github.com 2>&1 | grep -q "successfully authenticated" && {
    echo "SSH authentication successful!"
    
    # Change remote to SSH
    cd /root/wazuh-rules-repo
    git remote set-url origin "git@github.com:${username}/${repo}.git"
    echo "Remote URL changed to SSH: git@github.com:${username}/${repo}.git"
    
    echo
    echo "You can now push without entering credentials:"
    echo "  cd /root/wazuh-rules-repo"
    echo "  git push -u origin master"
} || {
    echo "SSH authentication test failed. Please make sure you've added the key to GitHub."
    echo "You can test again with: ssh -T git@github.com"
}