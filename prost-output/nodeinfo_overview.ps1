$Header = @"
<style>
body {background-color: #1e1e1e; color: #d4d4d4; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;}
TABLE {border-width: 1px; border-style: solid; border-color: #3e3e42; border-collapse: collapse; background-color: #252526;}
TH {border-width: 1px; padding: 8px; border-style: solid; border-color: #3e3e42; background-color: #2d2d30; color: #cccccc; font-weight: 600;}
TD {border-width: 1px; padding: 6px; border-style: solid; border-color: #3e3e42; color: #d4d4d4; white-space: pre-line;}
TR:hover {background-color: #2a2d2e;}
</style>
"@

Get-ChildItem -Path "$PSScriptRoot/*-nodeinfo.json" | 
ForEach-Object { 
    Get-Content $_ | 
    ConvertFrom-Json 
} | Select-Object `
@{Name = 'MinutesAgo'; Expression = { [int]((Get-Date) - [DateTime]$_.TimeStamp).TotalMinutes } }, `
    ID, `
    HostName, `
    ModelName, `
    PSVersion, `
    STVersion, `
    DaysUp, `
@{Name = 'Chassis'; Expression = { if ($_.Hostnamectl.Chassis) { $_.Hostnamectl.Chassis } else { "sbc" } } }, `
@{Name = "LocalIP"; Expression = { if ($_.Network.LocalIP) { $_.Network.LocalIP } else { $null } } }, `
@{Name = "PublicIP"; Expression = { if ($_.Network.PublicIP) { $_.Network.PublicIP } else { $null } } }, `
@{Name = 'DistName'; Expression = { if ($_.OS) { $_.OS.DistName } else { $null } } }, `
@{Name = 'Bat%'; Expression = { if ($_.Battery) { $_.Battery.Percentage } else { $null } } }, `
@{Name = 'Load%'; Expression = { if ($_.LoadPercent) { $_.LoadPercent } else { $null } } }, `
@{Name = 'RAM%'; Expression = { if ($_.RAMUsedPercent) { $_.RAMUsedPercent } else { $null } } }, `
@{Name = 'Disk%'; Expression = { if ($_.DiskUsedPercent) { $_.DiskUsedPercent } else { $null } } }, `
@{Name = 'Ports'; Expression = { if ($_.ListeningPorts) { ($_.ListeningPorts | Sort-Object -Unique) -join "`n" } else { $null } } }, `
@{Name = 'AptUpd'; Expression = { if ($_.AptUpdates) { ($_.AptUpdates | Sort-Object) -join "`n" } else { $null } } } `
| ConvertTo-Html -Head $Header | Out-File -FilePath "$PSScriptRoot/nodeinfo_overview.html" -Encoding UTF8 -Force