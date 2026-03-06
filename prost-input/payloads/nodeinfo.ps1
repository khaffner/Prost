if (!(Get-InstalledModule -Name linuxinfo -RequiredVersion 0.0.8 -ErrorAction SilentlyContinue)) {
    Install-Module -Name linuxinfo -Force -RequiredVersion 0.0.8
}

$info = @{}
$info.Battery = Get-BatteryInfo
$info.Computer = Get-ComputerInfo
$info.Display = Get-DisplayInfo
$info.Network = Get-NetworkInfo -IncludePublicIP
$info.OS = Get-OSInfo
$info.SystemUptime = Get-SystemUptime
$info | ConvertTo-Json -Depth 10 | Out-File -FilePath "$global:OutputFolder/$global:ID-nodeinfo.json" -Encoding UTF8 -Force