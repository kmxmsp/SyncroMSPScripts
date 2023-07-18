function Get-SyncroVars {
    [CmdletBinding()]
    param (
        $File = $MyInvocation.MyCommand.Path,
        [string]$BreakString = '#- Start of Script -#',
        [switch]$WrapOutput
    )

    begin {
        [regex]$GuidRx = '([0-9A-F]{3})[0-9A-F]{5}-(?:[0-9A-F]{4}-){3}[0-9A-F]{8}([0-9A-F]{4})'
    }

    process {
        $SyncroVars = foreach ($line in (Get-Content -Path $File -ErrorAction SilentlyContinue)){
            if ($line -like $BreakString) {
                break
            } else {
                # Mask Guid in log
                $line -replace $GuidRx, '$1*****-****-****-****-********$2'
                if ($l -lt $line.Length){$l = $line.Length}
            }
        }

        if ($SyncroVars.Count -ge 1){
            $padding = {
                if ($l -gt $HeadTxt.Length){
                    ('='* [math]::Ceiling(($l - $HeadTxt.Length) / 2))
                } else {
                    '='
                }
            }
            $HeadTxt = ' Start Head Content '
            $HeadPad = & $padding
            $FootTxt = ' END Content Block ='
            $FootPad = & $padding

            '{0}{1}{0}' -f $HeadPad,$HeadTxt
            $SyncroVars
            '{0}{1}{0}' -f $FootPad,$FootTxt
            ''
        } else {
            $SyncroVars
        }
    }
}

<# Non Function Version
$SyncroVars = foreach ($line in (Get-Content -Path $MyInvocation.MyCommand.Path -ErrorAction SilentlyContinue)){
    if ($line -like '#- Start of Script -#') {
        break
    } else {
        # Mask Guid in log
        $line -replace '([0-9A-F]{3})[0-9A-F]{5}-(?:[0-9A-F]{4}-){3}[0-9A-F]{8}([0-9A-F]{4})', '$1*****-****-****-****-********$2'
        if ($l -lt $line.Length){$l = $line.Length}
    }
}
if ($SyncroVars.Count -ge 1){
    $padding = {
        if ($l -gt $HeadTxt.Length){
            ('='* [math]::Ceiling(($l - $HeadTxt.Length) / 2))
        } else {
            '='
        }
    }
    $HeadTxt = ' Start Head Content '
    $HeadPad = & $padding
    $FootTxt = ' END Content Block ='
    $FootPad = & $padding

    '{0}{1}{0}' -f $HeadPad,$HeadTxt
    $SyncroVars
    '{0}{1}{0}' -f $FootPad,$FootTxt
    ''
}
#>