#Requires -Version 7.4
$ErrorActionPreference = "Stop"
$ProstVersion = "0.3.0" #x-release-please-version

$SyncthingHome = Get-ChildItem -Path "/home/*/.local/state" -Directory -Recurse -Filter "syncthing" -Force | Select-Object -ExpandProperty FullName
$SyncthingSystem = & "syncthing" "cli" "-H" "$SyncthingHome" "show" "system" | ConvertFrom-Json
$global:ID = $SyncthingSystem.myID.Split("-")[0]
$global:HostName = & hostname
$global:Username = $SyncthingHome.Split("/")[2]

$global:SyncthingVersion = (& "syncthing" "cli" "-H" "$SyncthingHome" "show" "version" | ConvertFrom-Json).Version.Trimstart('v')
$SyncthingConfig = & "syncthing" "cli" "-H" "$SyncthingHome" "config" "dump-json" | ConvertFrom-Json
$global:OutputFolder = $SyncthingConfig.folders | Where-Object path -like '*prost-output' | Select-Object -ExpandProperty path
$global:OutputFolder = $global:OutputFolder.Replace('~', $SyncthingSystem.tilde) # Resolve tilde if present

$global:InputFolder = $SyncthingConfig.folders | Where-Object path -like '*prost-input' | Select-Object -ExpandProperty path
$global:InputFolder = $global:InputFolder.Replace('~', $SyncthingSystem.tilde) # Resolve tilde if present

function Write-ProstLog {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$Timestamp] [$ProstVersion] [$global:ID] [$global:HostName] $Message" | Out-File -FilePath "$global:OutputFolder/$global:ID.log" -Append -Encoding UTF8 -Force
}

# Make sure there is enough free space on the drive to write logs and output. Say 1GB.
$FreeSpaceGB = (Get-PSDrive -Name $PWD.Drive.Name).Free / 1GB
if ($FreeSpaceGB -lt 1) {
    Write-ProstLog "Not enough free space on drive $($PWD.Drive.Name)."
    exit 1
}

try {
    Write-ProstLog "Reading assignments from CSV..."
    $csv = Import-Csv -Path "$InputFolder/assignments.csv"
    $row = $csv | Where-Object SyncthingID -eq $global:ID
    $scripts = $row.PSObject.Properties | Where-Object { $_.Value -eq "X" } | Select-Object -ExpandProperty Name
    Write-ProstLog "Assigned scripts: $($scripts -join ",")"

    $scripts | ForEach-Object {
        if ($_.EndsWith(".ps1")) {
            Write-ProstLog "Executing PowerShell script: $_"
            & "$InputFolder/payloads/$_" | Out-Null
        }
        elseif ($_.EndsWith(".sh")) {
            Write-ProstLog "Executing shell script: $_"
            & "bash" "$InputFolder/payloads/$_" | Out-Null
        }
        else {
            Write-ProstLog "Unknown script type: $_. Skipping."
        }
    }
    
    Write-ProstLog "Fixing file ownership and permissions in output folder..."
    & chown -R "${global:Username}:${global:Username}" $global:OutputFolder
    & chmod -R u+w $global:OutputFolder
}
catch {
    Write-ProstLog "Error: $($_.Exception.GetType().FullName)"
    Write-ProstLog "Message: $($_.Exception.Message)"
    Write-ProstLog "Script: $($_.InvocationInfo.ScriptName)"
    Write-ProstLog "Line: $($_.InvocationInfo.ScriptLineNumber)"
    Write-ProstLog "Command: $($_.InvocationInfo.Line.Trim())"
    Write-ProstLog "Stack trace: $($_.ScriptStackTrace)"
    exit 1
}