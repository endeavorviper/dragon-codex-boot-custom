[CmdletBinding()]
param([ValidateSet('Install','Verify','Restore')][string]$Action='Install',[string]$AppRoot)
$ErrorActionPreference='Stop'
if (!$AppRoot) {
    $parent=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
    if (Test-Path -LiteralPath (Join-Path $parent 'DragonCodexBoot.exe')) { $AppRoot=$parent }
    else { $AppRoot=Join-Path $parent 'build/DragonCodexBoot' }
}
$AppRoot=[IO.Path]::GetFullPath($AppRoot)
$exePath=Join-Path $AppRoot 'DragonCodexBoot.exe'
$programs=[Environment]::GetFolderPath('Programs')
if ([string]::IsNullOrWhiteSpace($programs)) { throw 'User Start menu folder unavailable.' }
$shortcutPath=Join-Path $programs 'Dragon Codex Boot.lnk'
$stateRoot=Join-Path $AppRoot '.integration'
$statePath=Join-Path $stateRoot 'start-menu-state.json'
$shell=New-Object -ComObject WScript.Shell
function Hash([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash }
function Verify {
    if (!(Test-Path -LiteralPath $shortcutPath -PathType Leaf)) { throw 'Shortcut missing.' }
    $link=$shell.CreateShortcut($shortcutPath)
    if (![string]::Equals($link.TargetPath,$exePath,[StringComparison]::OrdinalIgnoreCase) -or $link.Arguments -ne '' -or
        ![string]::Equals($link.IconLocation,$exePath+',0',[StringComparison]::OrdinalIgnoreCase) -or
        ![string]::Equals($link.WorkingDirectory,$AppRoot,[StringComparison]::OrdinalIgnoreCase)) { throw 'Shortcut properties differ.' }
    [pscustomobject]@{Shortcut=$shortcutPath;Target=$link.TargetPath;Verified=$true;Pinned=$null}
}
if ($Action -eq 'Verify') { Verify; return }
$previous=$null
if (Test-Path -LiteralPath $statePath) { $previous=Get-Content -LiteralPath $statePath -Encoding UTF8 -Raw | ConvertFrom-Json }
if ($Action -eq 'Restore') {
    if (!$previous -or $previous.Restored) { Write-Output 'Nothing to restore.'; return }
    if (![string]::Equals($previous.Shortcut,$shortcutPath,[StringComparison]::OrdinalIgnoreCase)) { throw 'State path mismatch.' }
    if ((Test-Path -LiteralPath $shortcutPath) -and (Hash $shortcutPath) -ne $previous.InstalledSHA256) { throw 'Shortcut changed; preserved.' }
    if ($previous.OriginalExists) {
        if (!(Test-Path -LiteralPath $previous.OriginalBackup) -or (Hash $previous.OriginalBackup) -ne $previous.OriginalSHA256) { throw 'Backup verification failed.' }
        Copy-Item -LiteralPath $previous.OriginalBackup -Destination $shortcutPath -Force
        if ((Hash $shortcutPath) -ne $previous.OriginalSHA256) { throw 'Restore verification failed.' }
    } elseif (Test-Path -LiteralPath $shortcutPath) {
        # Remove only the exact task-owned shortcut after its checksum has been verified.
        Remove-Item -LiteralPath $shortcutPath
    }
    $previous.Restored=$true
    $previous | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $statePath -Encoding UTF8
    Write-Output 'Shortcut restored. Unpin the launcher separately in Start if it was pinned.'
    return
}
if (!(Test-Path -LiteralPath $exePath -PathType Leaf)) { throw 'Build or extract the launcher first.' }
New-Item -ItemType Directory -Path $stateRoot,$programs -Force | Out-Null
$owned=$previous -and !$previous.Restored -and (Test-Path -LiteralPath $shortcutPath) -and
    [string]::Equals($previous.Shortcut,$shortcutPath,[StringComparison]::OrdinalIgnoreCase) -and (Hash $shortcutPath) -eq $previous.InstalledSHA256
$originalExists=$false;$originalBackup=$null;$originalHash=$null
if ($owned) {
    $originalExists=$previous.OriginalExists;$originalBackup=$previous.OriginalBackup;$originalHash=$previous.OriginalSHA256
} elseif (Test-Path -LiteralPath $shortcutPath) {
    $originalExists=$true
    $originalBackup=Join-Path $stateRoot ('backup-'+[Guid]::NewGuid().ToString('N')+'.lnk')
    Copy-Item -LiteralPath $shortcutPath -Destination $originalBackup
    $originalHash=Hash $shortcutPath
    if ((Hash $originalBackup) -ne $originalHash) { throw 'Backup mismatch.' }
}
$link=$shell.CreateShortcut($shortcutPath)
$link.TargetPath=$exePath;$link.Arguments='';$link.WorkingDirectory=$AppRoot;$link.IconLocation=$exePath+',0'
$link.Description='Play a custom startup animation, then hand off to the Codex desktop client.'
$link.Save()
$report=Verify
@{Shortcut=$shortcutPath;InstalledSHA256=(Hash $shortcutPath);OriginalExists=$originalExists;OriginalBackup=$originalBackup;OriginalSHA256=$originalHash;Restored=$false} |
    ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $statePath -Encoding UTF8
$report
Write-Output 'Right-click DragonCodexBoot.exe in Explorer and choose Pin to Start. This script registers the shortcut only.'
