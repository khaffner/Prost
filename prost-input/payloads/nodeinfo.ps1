if (!(Get-InstalledModule -Name linuxinfo -RequiredVersion 0.0.8 -ErrorAction SilentlyContinue)) {
    Install-Module -Name linuxinfo -Force -RequiredVersion 0.0.8
}
Import-Module -Name linuxinfo -RequiredVersion 0.0.8 -Force

$info = @{}

try {
    $info.Battery = Get-BatteryInfo
}
catch {

}

try {
    $info.Computer = Get-ComputerInfo
}
catch {

}

try {
    $info.Display = Get-DisplayInfo
}
catch {

}

try {
    $info.Network = Get-NetworkInfo -IncludePublicIP
}
catch {

}

try {
    $info.OS = Get-OSInfo
}
catch {

}

try {
    $info.SystemUptime = Get-SystemUptime
}
catch {

}

$info | ConvertTo-Json -Depth 10 | Out-File -FilePath "$global:OutputFolder/$global:ID-nodeinfo.json" -Encoding UTF8 -Force
