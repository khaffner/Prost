if (!(Get-InstalledModule -Name linuxinfo -RequiredVersion 0.0.8 -ErrorAction SilentlyContinue)) {
    Install-Module -Name linuxinfo -Force -RequiredVersion 0.0.8
}
Import-Module -Name linuxinfo -RequiredVersion 0.0.8 -Force

$info = @{}
$info.ID = $global:ID
$info.HostName = $global:HostName
$info.Battery = try { Get-BatteryInfo } catch { $null }
$info.Computer = try { Get-ComputerInfo } catch { $null }
$info.Network = try { Get-NetworkInfo -IncludePublicIP } catch { $null }
$info.Network.PublicIP = $info.Network.PublicIP.Trim() # Remove annoying whitespace..
$info.OS = try { Get-OSInfo } catch { $null }
$info.UptimeDays = try { [int](Get-Uptime).TotalDays } catch { $null }
$info.LoadPercent = try { [int]([float](Get-Content /proc/loadavg).Split(' ')[1] / [int](nproc) * 100) } catch { $null }
$info.MemoryUsedPercent = try { $m = (free | sls Mem).Line -split '\s+'; [int]($m[2] / $m[1] * 100) } catch { $null }
$info.AptUpdates = try { apt list --upgradable 2>/dev/null | Select-Object -Skip 1 } catch { $null }
$info.PSVersion = $PSVersionTable.PSVersion.ToString()
$info.TimeStamp = Get-Date -Format "o"
$info | ConvertTo-Json -Depth 10 | Out-File -FilePath "$global:OutputFolder/$global:ID-nodeinfo.json" -Encoding UTF8 -Force
