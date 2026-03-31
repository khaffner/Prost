if (!(Get-InstalledModule -Name linuxinfo -RequiredVersion 0.0.8 -ErrorAction SilentlyContinue)) {
    Install-Module -Name linuxinfo -Force -RequiredVersion 0.0.8
}
Import-Module -Name linuxinfo -RequiredVersion 0.0.8 -Force

$ErrorActionPreference = "SilentlyContinue"
$info = @{}
$info.Battery = Get-BatteryInfo
$info.Computer = Get-ComputerInfo
$info.Display = Get-DisplayInfo
$info.Network = Get-NetworkInfo -IncludePublicIP
$info.OS = Get-OSInfo
$info.UptimeDays = [int](Get-Uptime).TotalDays
$info.LoadPercent = [int]([float](Get-Content /proc/loadavg).Split(' ')[1] / [int](nproc) * 100)
$info.MemoryUsedPercent = & { $m = (free | sls Mem).Line -split '\s+'; [int]($m[2] / $m[1] * 100) }
$info.AptUpdates = apt list --upgradable 2>/dev/null | Select-Object -Skip 1
$info.PSVersion = $PSVersionTable.PSVersion.ToString()
$info.TimeStamp = Get-Date -Format "o"
$ErrorActionPreference = "Stop"
$info | ConvertTo-Json -Depth 10 | Out-File -FilePath "$global:OutputFolder/$global:ID-nodeinfo.json" -Encoding UTF8 -Force
