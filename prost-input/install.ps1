#Requires -Version 7.6
if ($env:USERNAME -ne "root") {
    Write-Host "This script must be run as root. Please run pwsh with sudo."
    exit 1
}
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ScriptPath = Join-Path $ScriptDir 'run.ps1'
$ServicePath = '/etc/systemd/system/prost.service'
$TimerPath = '/etc/systemd/system/prost.timer'

$ServiceContent = @"
[Unit]
Description=Run Prost every hour

[Service]
Type=oneshot
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
Persistent=true

[Install]
WantedBy=timers.target
"@

$ServiceContent | Set-Content -Path $ServicePath
$TimerContent | Set-Content -Path $TimerPath

systemctl daemon-reload
systemctl enable --now prost.timer
Write-Host "Systemd service and timer installed and started."

