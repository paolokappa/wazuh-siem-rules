# SENTINEL-X Sysmon Configuration Sync Script
# Run this on your Windows Server to sync Sysmon config to GitHub
# Author: GOLINE SA Security Team

param(
    [string]$SysmonConfigPath = "C:\ProgramData\Sysmon\sysmon_config.xml",
    [string]$RepoPath = "C:\GitRepos\wazuh-siem-rules",
    [string]$GitHubRepo = "git@github.com:paolokappa/wazuh-siem-rules.git"
)

Write-Host "=== SENTINEL-X Sysmon Config Sync ===" -ForegroundColor Cyan
Write-Host "Time: $(Get-Date)" -ForegroundColor Gray

# Check if Sysmon config exists
if (-not (Test-Path $SysmonConfigPath)) {
    Write-Host "ERROR: Sysmon config not found at $SysmonConfigPath" -ForegroundColor Red
    exit 1
}

# Clone repo if it doesn't exist
if (-not (Test-Path $RepoPath)) {
    Write-Host "Cloning repository..." -ForegroundColor Yellow
    git clone $GitHubRepo $RepoPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to clone repository" -ForegroundColor Red
        exit 1
    }
}

# Change to repo directory
Set-Location $RepoPath

# Pull latest changes
Write-Host "Pulling latest changes..." -ForegroundColor Yellow
git pull origin main

# Create sysmon directory if it doesn't exist
$SysmonDir = Join-Path $RepoPath "sysmon"
if (-not (Test-Path $SysmonDir)) {
    New-Item -ItemType Directory -Path $SysmonDir | Out-Null
    Write-Host "Created sysmon directory" -ForegroundColor Green
}

# Copy Sysmon config
Write-Host "Copying Sysmon configuration..." -ForegroundColor Yellow
Copy-Item -Path $SysmonConfigPath -Destination "$SysmonDir\sysmon_config.xml" -Force

# Get Sysmon version info
$SysmonVersion = (Get-WmiObject -Class Win32_Service -Filter "Name='Sysmon64'" -ErrorAction SilentlyContinue).PathName
if ($SysmonVersion) {
    $Version = [regex]::Match($SysmonVersion, 'Sysmon64-(\d+\.\d+)').Groups[1].Value
    if ($Version) {
        "Sysmon Version: $Version" | Out-File "$SysmonDir\version.txt"
    }
}

# Add hostname info
"Last synced from: $env:COMPUTERNAME" | Out-File "$SysmonDir\last_sync.txt"
"Sync time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content "$SysmonDir\last_sync.txt"

# Check for changes
$GitStatus = git status --porcelain
if ([string]::IsNullOrWhiteSpace($GitStatus)) {
    Write-Host "No changes detected" -ForegroundColor Green
    exit 0
}

# Show changes
Write-Host "Changes detected:" -ForegroundColor Yellow
git status --short

# Commit changes
git add sysmon/*
$CommitMessage = "Update Sysmon configuration from $env:COMPUTERNAME - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -m $CommitMessage

# Push to GitHub
Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully synced Sysmon config to GitHub!" -ForegroundColor Green
} else {
    Write-Host "ERROR: Failed to push to GitHub" -ForegroundColor Red
    exit 1
}

Write-Host "=== Sync completed ===" -ForegroundColor Cyan