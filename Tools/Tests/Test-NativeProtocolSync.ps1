param(
    [string]$ClientRoot = (Resolve-Path "$PSScriptRoot\..\..").Path,
    [string]$ServerRoot = 'E:\wowdecomp\xs-wow\azerothcore-wotlk-xs',
    [switch]$RequireServer
)
$ErrorActionPreference = 'Stop'

if (!(Test-Path -LiteralPath $ServerRoot)) {
    if ($RequireServer) { throw "Server checkout not found: $ServerRoot" }
    Write-Output "Native protocol sync: skipped, no server checkout at $ServerRoot"
    exit 0
}

# The NativeUI protocol lives in two hand-copied headers plus two opcode enums.
# This check fails when the copies drift, so a field or opcode rename cannot
# silently disable a feature on one side only.

$ClientHeader = Join-Path $ClientRoot 'WoW\Source\NativeUIProtocol.h'
$ClientOpcodes = Join-Path $ClientRoot 'WoW\Source\Net\Types.h'
$ClientLua = Join-Path $ClientRoot 'Interface\NativeUI\NativeUI.lua'
$ServerHeader = Join-Path $ServerRoot 'src\common\Utilities\NativeUIProtocol.h'
$ServerOpcodes = Join-Path $ServerRoot 'src\server\game\Server\Protocol\Opcodes.h'
$ServerOpcodesCpp = Join-Path $ServerRoot 'src\server\game\Server\Protocol\Opcodes.cpp'
$ServerFields = Join-Path $ServerRoot 'src\server\game\Handlers\ChatHandler.cpp'

$script:failures = New-Object System.Collections.Generic.List[string]

function Read-ProductionFile([string]$path) {
    if (!(Test-Path -LiteralPath $path)) { throw "Missing file: $path" }
    return [System.IO.File]::ReadAllText($path).Replace("`r`n", "`n")
}

function Get-Constants([string]$text) {
    $map = @{}
    $pattern = 'constexpr\s+[A-Za-z0-9_]+\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*([^;]+);'
    foreach ($match in [regex]::Matches($text, $pattern)) {
        $map[$match.Groups[1].Value] = $match.Groups[2].Value.Trim()
    }
    return $map
}

function Get-EnumValues([string]$text, [string]$nameFilter) {
    $map = @{}
    $pattern = '(?m)^\s*([A-Z][A-Z0-9_]*)\s*=\s*(0x[0-9A-Fa-f]+)\s*,?'
    foreach ($match in [regex]::Matches($text, $pattern)) {
        $name = $match.Groups[1].Value
        if ($nameFilter -and $name -notmatch $nameFilter) { continue }
        $map[$name] = [Convert]::ToInt64($match.Groups[2].Value, 16)
    }
    return $map
}

function Get-ServerFieldContract([string]$text) {
    $exact = @{}
    $prefixes = New-Object System.Collections.Generic.List[string]

    foreach ($match in [regex]::Matches($text, 'PattrAddField\(\s*fields\s*,\s*"([A-Z][A-Z0-9_]*)"')) {
        $exact[$match.Groups[1].Value] = $true
    }
    foreach ($match in [regex]::Matches($text, '"([A-Z][A-Z0-9_]*)="\s*\+')) {
        $exact[$match.Groups[1].Value] = $true
    }
    # ATTR_<ItemModType> and RATING_<n> are generated with a suffix, so only the
    # family name is static.
    if ($text -match 'PattrAddAttrField\(') { $prefixes.Add('ATTR_') }
    if ($text -match '"RATING_"') { $prefixes.Add('RATING_') }

    return @{ Exact = $exact; Prefixes = @($prefixes) }
}

function Get-ClientFieldReads([string]$text) {
    $exact = @{}
    $prefixes = New-Object System.Collections.Generic.List[string]

    foreach ($match in [regex]::Matches($text, '\bvalue\(\s*[^,()]+,\s*"([A-Z][A-Z0-9_]*)"\s*\)')) {
        $exact[$match.Groups[1].Value] = $true
    }
    foreach ($match in [regex]::Matches($text, '\bvalue\(\s*[^,()]+,\s*"([A-Z][A-Z0-9_]*)"\s*\.\.')) {
        $prefixes.Add($match.Groups[1].Value)
    }

    return @{ Exact = $exact; Prefixes = @($prefixes) }
}

Write-Output "Native protocol sync: client=$ClientRoot"
Write-Output "Native protocol sync: server=$ServerRoot"

# --- 1. Shared header constants -------------------------------------------
$clientConstants = Get-Constants (Read-ProductionFile $ClientHeader)
$serverConstants = Get-Constants (Read-ProductionFile $ServerHeader)
if ($clientConstants.Count -eq 0) { $script:failures.Add("no constants parsed from $ClientHeader") }
if ($serverConstants.Count -eq 0) { $script:failures.Add("no constants parsed from $ServerHeader") }

foreach ($name in ($clientConstants.Keys | Sort-Object)) {
    if (!$serverConstants.ContainsKey($name)) {
        $script:failures.Add("NativeUIProtocol.h: '$name' missing on the server")
    } elseif ($serverConstants[$name] -ne $clientConstants[$name]) {
        $script:failures.Add("NativeUIProtocol.h: '$name' client=$($clientConstants[$name]) server=$($serverConstants[$name])")
    }
}
foreach ($name in ($serverConstants.Keys | Sort-Object)) {
    if (!$clientConstants.ContainsKey($name)) {
        $script:failures.Add("NativeUIProtocol.h: '$name' missing on the client")
    }
}
Write-Output ("  header constants: client={0} server={1}" -f $clientConstants.Count, $serverConstants.Count)

# --- 2. NativeUI opcodes ---------------------------------------------------
$clientOpcodeMap = Get-EnumValues (Read-ProductionFile $ClientOpcodes) 'NATIVE_UI|^NUM_MSG_TYPES$'
$serverOpcodeMap = Get-EnumValues (Read-ProductionFile $ServerOpcodes) 'NATIVE_UI|^NUM_MSG_TYPES$'
if ($clientOpcodeMap.Count -eq 0) { $script:failures.Add("no NATIVE_UI opcodes parsed from $ClientOpcodes") }
if ($serverOpcodeMap.Count -eq 0) { $script:failures.Add("no NATIVE_UI opcodes parsed from $ServerOpcodes") }

foreach ($name in ($clientOpcodeMap.Keys | Sort-Object)) {
    if (!$serverOpcodeMap.ContainsKey($name)) {
        $script:failures.Add("opcode: '$name' missing on the server")
    } elseif ($serverOpcodeMap[$name] -ne $clientOpcodeMap[$name]) {
        $script:failures.Add(("opcode: '{0}' client=0x{1:X} server=0x{2:X}" -f $name, $clientOpcodeMap[$name], $serverOpcodeMap[$name]))
    }
}
foreach ($name in ($serverOpcodeMap.Keys | Sort-Object)) {
    if (!$clientOpcodeMap.ContainsKey($name)) {
        $script:failures.Add("opcode: '$name' missing on the client")
    }
}
if ($clientOpcodeMap.ContainsKey('NUM_MSG_TYPES') -and $serverOpcodeMap.ContainsKey('NUM_MSG_TYPES')) {
    # Adding a custom opcode means raising the table bound on both sides.
    if ($clientOpcodeMap['NUM_MSG_TYPES'] -ne $serverOpcodeMap['NUM_MSG_TYPES']) {
        $script:failures.Add("opcode: NUM_MSG_TYPES client=0x{0:X} server=0x{1:X}" -f $clientOpcodeMap['NUM_MSG_TYPES'], $serverOpcodeMap['NUM_MSG_TYPES'])
    }
}
Write-Output ("  native opcodes: {0} on both sides, NUM_MSG_TYPES={1}" -f `
    (($clientOpcodeMap.Keys | Where-Object { $_ -ne 'NUM_MSG_TYPES' }).Count, `
    $(if ($clientOpcodeMap.ContainsKey('NUM_MSG_TYPES')) { "0x{0:X}" -f $clientOpcodeMap['NUM_MSG_TYPES'] } else { 'missing' })))

# --- 3. Server dispatch registration --------------------------------------
# Every custom opcode the client knows about must have a server side table
# entry. WorldSession::Update dereferences opcodeTable[opcode] without a null
# check, so a missing entry is a crash path, not just a missing feature.
$serverDispatch = Read-ProductionFile $ServerOpcodesCpp
$clientAllOpcodes = Get-EnumValues (Read-ProductionFile $ClientOpcodes) $null
$customOpcodes = @($clientAllOpcodes.Keys | Where-Object {
    $_ -ne 'NUM_MSG_TYPES' -and $clientAllOpcodes[$_] -ge 0x520
} | Sort-Object)
$dispatchChecked = 0
foreach ($name in $customOpcodes) {
    if ($name -like 'CMSG_*') {
        $dispatchChecked++
        if ($serverDispatch -notmatch [regex]::Escape("DEFINE_HANDLER($name,")) {
            $script:failures.Add("dispatch: $name has no DEFINE_HANDLER entry")
        }
    } elseif ($name -like 'SMSG_*' -or $name -like 'MSG_*') {
        $dispatchChecked++
        if ($serverDispatch -notmatch [regex]::Escape("DEFINE_SERVER_OPCODE_HANDLER($name,")) {
            $script:failures.Add("dispatch: $name has no DEFINE_SERVER_OPCODE_HANDLER entry")
        }
    }
}
if ($dispatchChecked -eq 0) {
    $script:failures.Add('dispatch: no custom opcode parsed from the client enum; update extraction')
}
Write-Output ("  server dispatch: {0} custom opcodes above 0x51F checked" -f $dispatchChecked)

# --- 4. Snapshot field contract -------------------------------------------
$serverContract = Get-ServerFieldContract (Read-ProductionFile $ServerFields)
$clientReads = Get-ClientFieldReads (Read-ProductionFile $ClientLua)

function Test-FieldKnown($key) {
    if ($serverContract.Exact.ContainsKey($key)) { return $true }
    foreach ($prefix in $serverContract.Prefixes) {
        if ($key.StartsWith($prefix)) { return $true }
    }
    return $false
}

# A concatenated family such as "CUR_" .. resource resolves against any server
# key that shares the prefix, not against a literal key of that name.
function Test-FieldFamily($prefix) {
    foreach ($key in $serverContract.Exact.Keys) {
        if ($key.StartsWith($prefix)) { return $true }
    }
    return $false
}

$checked = 0
foreach ($key in ($clientReads.Exact.Keys | Sort-Object)) {
    $checked++
    if (!(Test-FieldKnown $key)) {
        $script:failures.Add("field: client reads '$key' but the server never emits it")
    }
}
foreach ($prefix in $clientReads.Prefixes) {
    $checked++
    if (!(Test-FieldFamily $prefix) -and $serverContract.Prefixes -notcontains $prefix) {
        $script:failures.Add("field: client reads the '$prefix' family but the server never emits a '$prefix*' field")
    }
}
if ($checked -eq 0) {
    $script:failures.Add('field: no client literal field reads parsed; update extraction')
}
Write-Output ("  snapshot fields: {0} client reads checked, server exact={1} prefixes={2}" -f `
    $checked, $serverContract.Exact.Count, ($serverContract.Prefixes -join ','))

$unused = @($serverContract.Exact.Keys | Where-Object { !$clientReads.Exact.ContainsKey($_) } | Sort-Object)
if ($unused.Count -gt 0) {
    Write-Output ("  note: {0} server fields are not read by NativeUI.lua itself (addon or dynamic readers)" -f $unused.Count)
}

# --- Result ----------------------------------------------------------------
if ($script:failures.Count -gt 0) {
    foreach ($failure in $script:failures) { Write-Output "FAIL $failure" }
    Write-Output ("Native protocol sync failed: {0} mismatch(es)" -f $script:failures.Count)
    exit 1
}

Write-Output "Native protocol sync: headers, opcodes, dispatch and snapshot fields match"
exit 0
