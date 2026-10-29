param(
    [string]$ClientRoot = (Resolve-Path "$PSScriptRoot\..\..").Path,
    [string]$ServerRoot = 'E:\wowdecomp\xs-wow\azerothcore-wotlk-xs',
    [switch]$RequireServer
)
$ErrorActionPreference = 'Stop'

if (!(Test-Path -LiteralPath $ServerRoot)) {
    if ($RequireServer) { throw "Server checkout not found: $ServerRoot" }
    Write-Output "Addon command sync: skipped, no server checkout at $ServerRoot"
    exit 0
}

# The ____Function add-ons talk to the server over addon messages: the client
# sends "Command\tpayload" through Dream_SendData and the server answers with
# SendPacketToClient. A command name that exists on one side only is a dead
# button: nothing errors, the request just goes nowhere.

$ClientAddOnRoot = Join-Path $ClientRoot 'Interface\NativeUI\BundledAddOns'
$ClientLua = Join-Path $ClientRoot 'Interface\NativeUI\NativeUI.lua'
$ServerScriptRoot = Join-Path $ServerRoot 'src\server\scripts\Custom'
$ServerGameRoot = Join-Path $ServerRoot 'src\server\game'

# Requests the bundled UI still sends although the server side is gone by
# design. Keep this list short and justified:
# - SecretPlace: the client UI survived the migration, the server manager did
#   not (AsCreature.cpp still carries "//sSecretPlaceMgr->AddSecretCreCast(Me);"
#   commented out).
# - UITQ: the legacy addon whisper tooltip query. The server answers tooltips
#   over CMSG_NATIVE_UI_TOOLTIP_QUERY (0x524) now and no longer reads or sends
#   the UITQ header (see NativeUITooltipHandler.cpp).
$KnownUnhandled = @(
    'CheckSecretPlaceGuid',
    'GetKeySecretPlace',
    'GoNowSecretPlace',
    'UITQ'
)

$script:failures = New-Object System.Collections.Generic.List[string]

$clientFiles = @()
if (Test-Path -LiteralPath $ClientAddOnRoot) {
    $clientFiles += Get-ChildItem -LiteralPath $ClientAddOnRoot -Recurse -Filter '*.lua' -File
} else {
    throw "Missing client add-on directory: $ClientAddOnRoot"
}
if (Test-Path -LiteralPath $ClientLua) { $clientFiles += Get-Item -LiteralPath $ClientLua }

$clientSendPatterns = @(
    'Dream_SendData\(\s*"([A-Za-z0-9_]+)"',
    '(?<![\w.])SendAddonMessage\(\s*"([A-Za-z0-9_]+)"',
    'C_ChatInfo\.SendAddonMessage\(\s*"([A-Za-z0-9_]+)"'
)

$clientCommands = @{}
foreach ($file in $clientFiles) {
    $text = [System.IO.File]::ReadAllText($file.FullName)
    foreach ($pattern in $clientSendPatterns) {
        foreach ($match in [regex]::Matches($text, $pattern)) {
            $clientCommands[$match.Groups[1].Value] = $file.Name
        }
    }
}

$serverHandlerPatterns = @(
    'IsPacket\(\s*\w+\s*,\s*"([A-Za-z0-9_]+)"\s*\)',
    'header\s*==\s*"([A-Za-z0-9_]+)"'
)

$serverCommands = @{}
foreach ($root in @($ServerScriptRoot, $ServerGameRoot)) {
    if (!(Test-Path -LiteralPath $root)) { continue }
    foreach ($file in Get-ChildItem -LiteralPath $root -Recurse -Include '*.cpp' -File) {
        $text = [System.IO.File]::ReadAllText($file.FullName)
        foreach ($pattern in $serverHandlerPatterns) {
            foreach ($match in [regex]::Matches($text, $pattern)) {
                $serverCommands[$match.Groups[1].Value] = $file.Name
            }
        }
    }
}

Write-Output "Addon command sync: client=$ClientRoot"
Write-Output "Addon command sync: server=$ServerRoot"
Write-Output ("  client requests: {0} ({1} lua files)" -f $clientCommands.Count, $clientFiles.Count)
Write-Output ("  server handlers: {0}" -f $serverCommands.Count)

if ($clientCommands.Count -eq 0) { $script:failures.Add('client: no addon request names parsed; update extraction') }
if ($serverCommands.Count -eq 0) { $script:failures.Add('server: no addon handlers parsed; update extraction') }

foreach ($name in ($clientCommands.Keys | Sort-Object)) {
    if ($serverCommands.ContainsKey($name)) { continue }
    if ($KnownUnhandled -contains $name) { continue }
    $script:failures.Add("request: '$name' ({0}) has no server handler" -f $clientCommands[$name])
}

foreach ($name in ($KnownUnhandled | Sort-Object)) {
    if ($serverCommands.ContainsKey($name)) {
        $script:failures.Add("allowlist: '$name' is handled again; drop it from KnownUnhandled")
    }
}

$handledOnly = @($serverCommands.Keys | Where-Object { !$clientCommands.ContainsKey($_) } | Sort-Object)
if ($handledOnly.Count -gt 0) {
    Write-Output ("  note: {0} handlers are not requested by the bundled add-ons: {1}" -f $handledOnly.Count, ($handledOnly -join ', '))
}
Write-Output ("  known unhandled (retired client UI): {0}" -f ($KnownUnhandled -join ', '))

if ($script:failures.Count -gt 0) {
    foreach ($failure in $script:failures) { Write-Output "FAIL $failure" }
    Write-Output ("Addon command sync failed: {0} mismatch(es)" -f $script:failures.Count)
    exit 1
}

Write-Output "Addon command sync: every bundled request has a server handler"
exit 0
