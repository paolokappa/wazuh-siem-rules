# SENTINEL-X Sysmon Configuration Sync Script for Domain Controller
# Run this directly on BUSE005 DC to sync Sysmon config to GitHub
# Author: GOLINE SA Security Team
# Location: Can be placed in NETLOGON\Tools\Scripts for easy access

param(
    [string]$SysmonConfigPath = "C:\Windows\SYSVOL\domain\scripts\Tools\Sysmon\sysmon_config.xml",
    [string]$RepoPath = "C:\GitRepos\wazuh-siem-rules",
    [string]$GitHubRepo = "git@github.com:paolokappa/wazuh-siem-rules.git",
    [switch]$AutoInstallGit
)

# Running as Administrator check
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator on the Domain Controller" -ForegroundColor Red
    exit 1
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   SENTINEL-X Sysmon Config Sync" -ForegroundColor Cyan
Write-Host "   Domain Controller: $env:COMPUTERNAME" -ForegroundColor Gray
Write-Host "   Time: $(Get-Date)" -ForegroundColor Gray
Write-Host "==========================================" -ForegroundColor Cyan

# Check if Git is installed
$GitPath = Get-Command git -ErrorAction SilentlyContinue
if (-not $GitPath) {
    if ($AutoInstallGit) {
        Write-Host "Installing Git..." -ForegroundColor Yellow
        # Download and install Git silently
        $GitInstaller = "$env:TEMP\Git-Latest.exe"
        Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe" -OutFile $GitInstaller
        Start-Process -FilePath $GitInstaller -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } else {
        Write-Host "ERROR: Git is not installed. Run with -AutoInstallGit to install automatically" -ForegroundColor Red
        exit 1
    }
}

# Alternative path if running from NETLOGON
if (-not (Test-Path $SysmonConfigPath)) {
    $AlternativePath = "\\$env:COMPUTERNAME\NETLOGON\Tools\Sysmon\sysmon_config.xml"
    if (Test-Path $AlternativePath) {
        $SysmonConfigPath = $AlternativePath
        Write-Host "Using NETLOGON path: $SysmonConfigPath" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Sysmon config not found at $SysmonConfigPath" -ForegroundColor Red
        Write-Host "Searched also at: $AlternativePath" -ForegroundColor Yellow
        exit 1
    }
}

# Clone repo if it doesn't exist
if (-not (Test-Path $RepoPath)) {
    Write-Host "Cloning repository to $RepoPath..." -ForegroundColor Yellow
    $ParentDir = Split-Path $RepoPath -Parent
    if (-not (Test-Path $ParentDir)) {
        New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
    }
    
    Set-Location $ParentDir
    git clone $GitHubRepo
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to clone repository" -ForegroundColor Red
        Write-Host "Please ensure SSH key is configured for GitHub" -ForegroundColor Yellow
        exit 1
    }
}

# Change to repo directory
Set-Location $RepoPath

# Configure Git if needed
$GitUser = git config user.name
if ([string]::IsNullOrWhiteSpace($GitUser)) {
    git config user.name "DC-BUSE005"
    git config user.email "sysmon-sync@buonvicini.local"
}

# Pull latest changes
Write-Host "Pulling latest changes from GitHub..." -ForegroundColor Yellow
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

# Get Sysmon service info from DC
$SysmonService = Get-Service -Name "Sysmon*" -ErrorAction SilentlyContinue
if ($SysmonService) {
    $SysmonInfo = Get-WmiObject Win32_Service -Filter "Name LIKE 'Sysmon%'"
    $SysmonExePath = $SysmonInfo.PathName
    
    # Extract version if possible
    if ($SysmonExePath -match 'Sysmon(64)?\.exe') {
        $SysmonExe = $Matches[0]
        $SysmonVersion = & where.exe $SysmonExe -c 2>$null
        if ($SysmonVersion) {
            @"
Sysmon Service: $($SysmonService.Name)
Status: $($SysmonService.Status)
Version Info: $SysmonVersion
Domain Controller: $env:COMPUTERNAME
"@ | Out-File "$SysmonDir\dc_info.txt"
        }
    }
}

# Add synchronization metadata
@"
Last synced from: $env:COMPUTERNAME (BUSE005)
Domain: $env:USERDNSDOMAIN
Source path: $SysmonConfigPath
Sync time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Synced by: $env:USERNAME
"@ | Out-File "$SysmonDir\last_sync.txt"

# Get config statistics
$ConfigContent = Get-Content "$SysmonDir\sysmon_config.xml"
$RuleCount = ($ConfigContent | Select-String -Pattern "<Rule" -AllMatches).Matches.Count
$EventFilterCount = ($ConfigContent | Select-String -Pattern "<EventFiltering" -AllMatches).Matches.Count

Write-Host "Configuration Statistics:" -ForegroundColor Cyan
Write-Host "  - Total Rules: $RuleCount" -ForegroundColor Gray
Write-Host "  - Event Filters: $EventFilterCount" -ForegroundColor Gray
Write-Host "  - File Size: $((Get-Item "$SysmonDir\sysmon_config.xml").Length / 1KB) KB" -ForegroundColor Gray

# Check for changes
$GitStatus = git status --porcelain
if ([string]::IsNullOrWhiteSpace($GitStatus)) {
    Write-Host "No changes detected in Sysmon configuration" -ForegroundColor Green
    exit 0
}

# Show changes
Write-Host "`nChanges detected:" -ForegroundColor Yellow
git status --short

# Commit changes
git add sysmon/*
$CommitMessage = @"
Update Sysmon configuration from DC BUSE005 - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Domain Controller: $env:COMPUTERNAME
Domain: $env:USERDNSDOMAIN
Source: \\NETLOGON\Tools\Sysmon\sysmon_config.xml
Rules: $RuleCount
"@

git commit -m $CommitMessage

# Push to GitHub
Write-Host "`nPushing to GitHub..." -ForegroundColor Yellow
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n==========================================" -ForegroundColor Green
    Write-Host "   Successfully synced to GitHub!" -ForegroundColor Green
    Write-Host "   Repository: $GitHubRepo" -ForegroundColor Gray
    Write-Host "==========================================" -ForegroundColor Green
    
    # Log success to Windows Event Log
    if (Get-Command Write-EventLog -ErrorAction SilentlyContinue) {
        Write-EventLog -LogName Application -Source "SysmonSync" -EventId 1000 -EntryType Information -Message "Sysmon configuration successfully synced to GitHub repository" -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "ERROR: Failed to push to GitHub" -ForegroundColor Red
    Write-Host "Please check your SSH key configuration" -ForegroundColor Yellow
    exit 1
}