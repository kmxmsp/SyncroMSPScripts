$path = "C:\Users"

$child_path = "AppData\Local\Temp"

$files_filter = "dbutil_*_*.sys"

if ($env:SyncroModule){
    Import-Module $env:SyncroModule -WarningAction SilentlyContinue
} else {
    # Set up $env: Variables and import the syncro module
    try {
        $syncroReg = Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\RepairTech\Syncro' -Name shop_subdomain,uuid -ErrorAction Stop
        $env:RepairTechApiBaseURL       = 'syncromsp.com'
        $env:RepairTechApiSubDomain     = $syncroReg.shop_subdomain
        $env:RepairTechFilePusherPath   = 'C:\ProgramData\Syncro\bin\FilePusher.exe'
        $env:RepairTechUUID             = $syncroReg.uuid
        $env:SyncroModule               = "$env:ProgramData\Syncro\bin\module.psm1"
        Import-Module $env:SyncroModule -WarningAction SilentlyContinue
    }
    catch {
        'Could not find Syncro Module info'
    }
}

$paths = @("C:\Windows\Temp")
[array]$paths += Get-ChildItem $path -Directory -Exclude Default*,Public | ForEach-Object {
    Join-Path -Path $_.FullName -ChildPath $child_path
}

Get-ChildItem -Path $paths -Filter $files_filter | ForEach-Object {
    $filePath = $_.FullName
    If (test-path $filePath) {
        try {
            Remove-Item $filePath -Force -Verbose -ErrorAction Stop
            Log-Activity -Message "Removed $filePath" -EventName PowershellScript
        }
        catch {
            Rmm-Alert -Category Script_Error -Body "Could not remove $filePath. Remove Manually"
        }
    } else {
        "NO File `"$filePath`""
    }
}
