#Requires -Version 7.4
if ($(whoami) -ne "root") {
    Write-Host "This script must be run as root. Please run pwsh with sudo."
    exit 1
}
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ScriptPath = Join-Path $ScriptDir 'run.ps1'
$ServicePath = '/etc/systemd/system/prost.service'
$TimerPath = '/etc/systemd/system/prost.timer'

# Detect the user who has syncthing installed
$SyncthingHome = Get-ChildItem -Path "/home/*/.local/state" -Directory -Recurse -Filter "syncthing" -Force | Select-Object -First 1 -ExpandProperty FullName
if (-not $SyncthingHome) {
    Write-Host "Could not find syncthing installation in /home/*/.local/state/syncthing"
    exit 1
}
$Username = $SyncthingHome -replace '^/home/([^/]+)/.*$', '$1'
$UserHome = "/home/$Username"
Write-Host "Detected syncthing user: $Username"

$ServiceContent = @"
[Unit]
Description=Run Prost every hour

[Service]
Type=oneshot
WorkingDirectory=$ScriptDir
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="HOME=$UserHome"
ExecStart=/usr/bin/pwsh -File $ScriptPath
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
"@

$TimerContent = @"
[Unit]
Description=Timer for prost.service

[Timer]
OnCalendar=hourly
RandomizedDelaySec=5min
Persistent=true

[Install]
WantedBy=timers.target
"@

$ServiceContent | Set-Content -Path $ServicePath
$TimerContent | Set-Content -Path $TimerPath

systemctl daemon-reload
systemctl enable --now prost.timer
Write-Host "Systemd service and timer installed and started."

