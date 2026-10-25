param([string]$ClientRoot = 'D:\wow_cn_3.3.5')
$ErrorActionPreference = 'Stop'
$sourceRoot = (Resolve-Path "$PSScriptRoot\..").Path
$clientPath = (Resolve-Path -LiteralPath $ClientRoot).Path.TrimEnd('\')
$running = @(Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $_.ProcessName -in @('Wow', 'Wow64', 'WowClient64', 'Wow32', 'WowClient32')
})
if ($running.Count) { throw 'Close the game client before deployment; no process was stopped.' }
$files = @()
foreach ($name in @('Wow64.exe', 'WowClient64.exe', 'XvidDecoder.dll')) {
    $files += [pscustomobject]@{ Source = Join-Path $sourceRoot "bin\Win\$name"; Relative = $name }
}
Get-ChildItem -LiteralPath (Join-Path $sourceRoot 'Interface\NativeUI') -File -Recurse | ForEach-Object {
    $files += [pscustomobject]@{ Source = $_.FullName; Relative = $_.FullName.Substring($sourceRoot.Length + 1) }
}
$records = foreach ($file in $files) {
    if (!(Test-Path -LiteralPath $file.Source -PathType Leaf)) { throw "Missing build output: $($file.Source)" }
    $destination = Join-Path $clientPath $file.Relative
    $exists = Test-Path -LiteralPath $destination -PathType Leaf
    [pscustomobject]@{
        Source = $file.Source; Relative = $file.Relative; Existed = $exists
        OldSHA256 = $(if ($exists) { (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash } else { $null })
        NewSHA256 = (Get-FileHash -LiteralPath $file.Source -Algorithm SHA256).Hash
    }
}
$backupRoot = Join-Path $clientPath ('CodexBackups\native-ui-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
if (Test-Path -LiteralPath $backupRoot) { throw 'Backup directory already exists; retry with a new timestamp.' }
[System.IO.Directory]::CreateDirectory($backupRoot) | Out-Null
# Complete and verify every backup before writing any live file.
foreach ($record in $records) {
    if ($record.Existed) {
        $backup = Join-Path $backupRoot $record.Relative
        [System.IO.Directory]::CreateDirectory((Split-Path -Parent $backup)) | Out-Null
        Copy-Item -LiteralPath (Join-Path $clientPath $record.Relative) -Destination $backup
        if ((Get-FileHash -LiteralPath $backup -Algorithm SHA256).Hash -ne $record.OldSHA256) { throw "Backup hash mismatch: $backup" }
    }
}
$manifest = [pscustomobject]@{ ClientRoot = $clientPath; Created = (Get-Date -Format o); Files = @($records) }
[System.IO.File]::WriteAllText((Join-Path $backupRoot 'manifest.json'), ($manifest | ConvertTo-Json -Depth 5), [System.Text.UTF8Encoding]::new($false))
foreach ($record in $records) {
    $destination = Join-Path $clientPath $record.Relative
    [System.IO.Directory]::CreateDirectory((Split-Path -Parent $destination)) | Out-Null
    Copy-Item -LiteralPath $record.Source -Destination $destination -Force
    if ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -ne $record.NewSHA256) { throw "Deployment hash mismatch: $destination; backup: $backupRoot" }
}
Write-Output "Backup: $backupRoot"
Write-Output "Deployed and SHA256 verified: $($records.Count) files"
Write-Output "Launch: $clientPath\WowClient64.exe"
