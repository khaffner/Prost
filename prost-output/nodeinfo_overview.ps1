Get-ChildItem -Path "$PSScriptRoot/*-nodeinfo.json" | 
ForEach-Object { 
    Get-Content $_ | 
    ConvertFrom-Json 
} | Select-Object `
@{Name = 'MinutesAgo'; Expression = { [int]((Get-Date) - [DateTime]$_.TimeStamp).TotalMinutes } }, `
    ID, `
    HostName, `
    PSVersion, `
    UptimeDays, `
@{Name = 'DistName'; Expression = { if ($_.OS) { $_.OS.DistName } else { $null } } }, `
@{Name = 'Bat%'; Expression = { if ($_.Battery) { $_.Battery.Percentage } else { $null } } }, `
@{Name = 'Load%'; Expression = { if ($_.LoadPercent) { $_.LoadPercent } else { $null } } }, `
@{Name = 'MemoryUsed%'; Expression = { if ($_.MemoryUsedPercent) { $_.MemoryUsedPercent } else { $null } } }, `
@{Name = 'AptUpdCount'; Expression = { if ($_.AptUpdates) { $_.AptUpdates.Count } else { $null } } } `
| Format-Table -AutoSize