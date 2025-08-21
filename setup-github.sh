#!/bin/bash

echo "=== GitHub Repository Setup for Wazuh Rules ==="
echo

# Get GitHub username
read -p "Enter your GitHub username: " github_username
if [ -z "$github_username" ]; then
    echo "Username cannot be empty!"
    exit 1
fi

# Get GitHub email
read -p "Enter your GitHub email: " github_email
if [ -z "$github_email" ]; then
    echo "Email cannot be empty!"
    exit 1
fi

# Get repository name
read -p "Enter your GitHub repository name (e.g., wazuh-rules): " repo_name
if [ -z "$repo_name" ]; then
    echo "Repository name cannot be empty!"
    exit 1
fi

# Configure git
echo "Configuring git..."
git config --global user.name "$github_username"
git config --global user.email "$github_email"

# Change to repo directory
cd /root/wazuh-rules-repo

# Remove existing origin if it exists
git remote remove origin 2>/dev/null

# Add GitHub remote
echo "Adding GitHub remote..."
git remote add origin "https://github.com/${github_username}/${repo_name}.git"

echo
echo "=== Configuration Complete ==="
echo "Git user: $github_username"
echo "Git email: $github_email"
echo "Repository URL: https://github.com/${github_username}/${repo_name}.git"
echo

echo "To push your rules to GitHub, you have two options:"
echo
echo "Option 1: Using Personal Access Token (Recommended)"
echo "  1. Go to GitHub Settings > Developer Settings > Personal Access Tokens"
echo "  2. Generate a new token with 'repo' permissions"
echo "  3. Run: git push -u origin master"
echo "  4. Use your GitHub username and the token as password"
echo
echo "Option 2: Using SSH key"
echo "  1. Generate SSH key: ssh-keygen -t ed25519 -C \"$github_email\""
echo "  2. Add the public key to GitHub Settings > SSH and GPG keys"
echo "  3. Change remote to SSH: git remote set-url origin git@github.com:${github_username}/${repo_name}.git"
echo "  4. Run: git push -u origin master"
echo
read -p "Would you like to set up SSH authentication now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./setup-ssh-github.sh "$github_email" "$github_username" "$repo_name"
fi