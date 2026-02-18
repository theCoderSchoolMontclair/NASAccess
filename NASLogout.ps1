# TCSNAS Manager
# Always map M: -> \\192.168.0.2\Home

$DriveLetter = "M:"
$ServerName  = "192.168.0.2"
$ShareName   = "Home"
$UNC         = "\\$ServerName\$ShareName"

function Show-Menu {
    Clear-Host
    Write-Host "==============================="
    Write-Host "   Network Drive Manager"
    Write-Host "==============================="
    Write-Host "1. Login (Map $DriveLetter -> $UNC)"
    Write-Host "2. Logout (Unmap $DriveLetter)"
    Write-Host "3. Exit"
    Write-Host "==============================="
}

function Clear-ConnectionsToIP {
    param([string]$Server)
    net use $DriveLetter /delete /y *> $null
    net use "\\$Server\*" /delete /y *> $null

    try {
        $conns = Get-SmbConnection -ErrorAction SilentlyContinue | Where-Object { $_.ServerName -ieq $Server }
        foreach ($c in $conns) {
            try { net use "\\$($c.ServerName)\$($c.ShareName)" /delete /y *> $null } catch {}
        }
    } catch {}

    cmdkey /delete:$Server               *> $null
    cmdkey /delete:LegacyGeneric:$Server *> $null
}

function Login-Drive {
    $cred = Get-Credential -Message "Enter credentials for $UNC"
    $username = $cred.UserName
    $password = $cred.GetNetworkCredential().Password

    Clear-ConnectionsToIP -Server $ServerName

    $args = @("use", $DriveLetter, $UNC, $password, "/user:$username", "/persistent:yes")
    $p = Start-Process -FilePath "net.exe" -ArgumentList $args -NoNewWindow -PassThru -Wait `

    if ($p.ExitCode -eq 0) {
        Write-Host " Drive $DriveLetter mapped to $UNC"
    } else {
        if ($p.ExitCode -eq 1219) {
            Write-Host " Error 1219: conflicting credentials detected for '\\$ServerName'."
            Write-Host "   Close any Explorer windows to \\$ServerName and try again."
        } else {
            Write-Host " Failed to map $DriveLetter (exit code $($p.ExitCode))."
        }
    }
    Pause
}

function Logout-Drive {
    net use $DriveLetter /delete /y *> $null
    net use "\\$ServerName\*" /delete /y *> $null

    try {
        $conns = Get-SmbConnection -ErrorAction SilentlyContinue | Where-Object { $_.ServerName -ieq $ServerName }
        foreach ($c in $conns) {
            try { net use "\\$($c.ServerName)\$($c.ShareName)" /delete /y *> $null } catch {}
        }
    } catch {}

    cmdkey /delete:$ServerName               *> $null
    cmdkey /delete:LegacyGeneric:$ServerName *> $null

    Write-Host " Disconnected and cleared credentials for \\$ServerName."
    Pause
}

do {
    Show-Menu
    $choice = Read-Host "Select an option (1-3)"

    switch ($choice) {
        "1" { Login-Drive }
        "2" { Logout-Drive }
        "3" { Write-Host "Exiting..."; Start-Sleep -Seconds 1; exit }
        default { Write-Host "Invalid choice, please try again."; Pause }
    }
} while ($true)
