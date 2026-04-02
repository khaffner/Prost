if (!(Get-InstalledModule -Name linuxinfo -RequiredVersion 0.0.8 -ErrorAction SilentlyContinue)) {
    Install-Module -Name linuxinfo -Force -RequiredVersion 0.0.8
}
Import-Module -Name linuxinfo -RequiredVersion 0.0.8 -Force

$info = @{}
$info.ID = $global:ID
$info.SyncthingUser = $global:Username
$info.HostName = $global:HostName
$info.Hostnamectl = try { hostnamectl --json=short | ConvertFrom-Json }catch { $null }
$info.ModelName = try { 
    if (Test-Path '/sys/devices/virtual/dmi/id/product_name') {
        (Get-Content '/sys/devices/virtual/dmi/id/product_name' -Raw).Trim()
    }
    elseif (Test-Path '/sys/firmware/devicetree/base/model') {
        (Get-Content '/sys/firmware/devicetree/base/model' -Raw).Trim([char]0).Trim()
    }
    else {
        $null
    }
}
catch { $null }
$info.Battery = try { Get-BatteryInfo } catch { $null }
$info.Computer = try { Get-ComputerInfo } catch { $null }
$info.Network = try { Get-NetworkInfo -IncludePublicIP } catch { $null }
$info.Network.PublicIP = $info.Network.PublicIP.Trim() # Remove annoying whitespace..
$info.OS = try { Get-OSInfo } catch { $null }
$info.UptimeDays = try { [int](Get-Uptime).TotalDays } catch { $null }
$info.LoadPercent = try { [int]([float](Get-Content /proc/loadavg).Split(' ')[1] / [int](nproc) * 100) } catch { $null }
$info.MemoryUsedPercent = try { $m = (free | Select-String Mem).Line -split '\s+'; [int]($m[2] / $m[1] * 100) } catch { $null }
$info.AptUpdates = try { apt-get -s upgrade 2>/dev/null | Select-String '^Inst ' | ForEach-Object { if ($_ -match '^Inst (\S+) .* \((\S+)') { "$($matches[1]) $($matches[2])" } } } catch { $null }
$info.PSVersion = $PSVersionTable.PSVersion.ToString()
$info.STVersion = $global:SyncthingVersion
$info.TimeStamp = Get-Date -Format "o"
$info | ConvertTo-Json -Depth 10 | Out-File -FilePath "$global:OutputFolder/$global:ID-nodeinfo.json" -Encoding UTF8 -Force
