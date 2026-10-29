param(
    [string]$ClientRoot = (Resolve-Path "$PSScriptRoot\..\..").Path,
    [string]$ServerRoot = 'E:\wowdecomp\xs-wow\azerothcore-wotlk-xs',
    [switch]$RequireServer
)
$ErrorActionPreference = 'Stop'

if (!(Test-Path -LiteralPath $ServerRoot)) {
    if ($RequireServer) { throw "Server checkout not found: $ServerRoot" }
    Write-Output "Tooltip payload sync: skipped, no server checkout at $ServerRoot"
    exit 0
}

# The item tooltip payload travels over CMSG_NATIVE_UI_TOOLTIP_QUERY (0x524) and
# back on SMSG_NATIVE_UI_TOOLTIP_DATA (0x525). It is one colon-separated string:
#
#   ALL_MODULE_DATA:[bag:slot:]itemId:guid:<7 fixed sections>[:<set>][:<huanjing>]
#                   [:PENDID|...][:TPL64|...]
#
# The client reads the fixed sections positionally and finds the tail sections by
# marker, so adding, dropping or reordering a section server-side silently
# truncates the tooltip.

$ClientLua = Join-Path $ClientRoot 'Interface\NativeUI\BundledAddOns\____Function\ItemGlobalTooltip.lua'
$ServerFile = Join-Path $ServerRoot 'modules\mod-item-identification-system\src\ItemIdentificationSystem.cpp'

foreach ($path in @($ClientLua, $ServerFile)) {
    if (!(Test-Path -LiteralPath $path)) { throw "Missing file: $path" }
}

$script:failures = New-Object System.Collections.Generic.List[string]
$clientText = [System.IO.File]::ReadAllText($ClientLua).Replace("`r`n", "`n")
$serverText = [System.IO.File]::ReadAllText($ServerFile).Replace("`r`n", "`n")

# --- server side -----------------------------------------------------------
$sendBody = [regex]::Match($serverText, '(?ms)^void ItemIdentificationSystem::SendAllModuleDataAddon\(.*?^\}').Value
if (!$sendBody) { throw 'SendAllModuleDataAddon body not found; update extraction' }

$serverSections = @([regex]::Matches($sendBody, '<<\s*data\.(\w+)') | ForEach-Object { $_.Groups[1].Value })
if ($serverSections.Count -eq 0) { throw 'no data.<section> stream operators found; update extraction' }

$templateBody = [regex]::Match($serverText, '(?ms)^void FrozenCoreSendItemTemplateDataNative\(.*?^\}').Value
if (!$templateBody) { throw 'FrozenCoreSendItemTemplateDataNative body not found; update extraction' }
$templateEmptyMatch = [regex]::Match($templateBody, 'index\s*<\s*(\d+)\s*;\s*\+\+index')
if (!$templateEmptyMatch.Success) { throw 'template-only empty section loop not found; update extraction' }
$templateEmptyCount = [int]$templateEmptyMatch.Groups[1].Value

$serverPrefix = if ($sendBody -match '"([A-Z_]+):"') { $Matches[1] } else { '' }
if (!$serverPrefix) { throw 'payload prefix literal not found on the server' }

$serverMarkers = @('TPL64|', 'PENDID|') | Where-Object { $serverText.Contains('"' + $_ + '"') }
$serverFixed = $serverSections.Count
if ($serverSections -contains 'setData') { $serverFixed = $serverSections.IndexOf('setData') }

# --- client side -----------------------------------------------------------
$parseBody = [regex]::Match($clientText, '(?ms)^local function Dream_ParseAllModuleData\(Msg\).*?^end').Value
if (!$parseBody) { throw 'Dream_ParseAllModuleData body not found; update extraction' }

if ($parseBody -notmatch 'Parts\[1\]\s*~=\s*"([A-Z_]+)"') { throw 'client prefix check not found; update extraction' }
$clientPrefix = $Matches[1]

if ($parseBody -notmatch '#Parts\s*>=\s*(\d+)') { throw 'client location-variant threshold not found; update extraction' }
$clientThreshold = [int]$Matches[1]

$indexOffsets = @([regex]::Matches($parseBody, 'Parts\[Index\s*\+\s*(\d+)\]') | ForEach-Object { [int]$_.Groups[1].Value })
if ($indexOffsets.Count -eq 0) { throw 'client positional section reads not found; update extraction' }
$clientFixed = ($indexOffsets | Measure-Object -Maximum).Maximum + 1

$clientMarkers = @('TPL64|', 'PENDID|') | Where-Object { $parseBody.Contains('^' + $_) }
if ($parseBody -notmatch 'Parts\[Index\]') { throw 'client base section read not found; update extraction' }

Write-Output "Tooltip payload sync: client=$ClientLua"
Write-Output "Tooltip payload sync: server=$ServerFile"
Write-Output ("  prefix: server='{0}:' client='{1}'" -f $serverPrefix, $clientPrefix)
Write-Output ("  server sections: {0} positional, then {1}" -f $serverFixed, (($serverSections | Select-Object -Skip $serverFixed) -join ', '))
Write-Output ("  client reads: {0} positional, markers {1}" -f $clientFixed, ($clientMarkers -join ', '))

# --- 1. header literal -----------------------------------------------------
if ($serverPrefix -ne $clientPrefix) {
    $script:failures.Add("prefix: server sends '${serverPrefix}:' but the client matches '$clientPrefix'")
}

# --- 2. positional section count ------------------------------------------
if ($serverFixed -ne $clientFixed) {
    $script:failures.Add("sections: server streams $serverFixed positional sections, the client reads $clientFixed")
}

# --- 3. tail markers -------------------------------------------------------
foreach ($marker in $clientMarkers) {
    if ($serverMarkers -notcontains $marker) {
        $script:failures.Add("marker: the client looks for '$marker' but the server never emits it")
    }
}
foreach ($marker in $serverMarkers) {
    if ($clientMarkers -notcontains $marker) {
        $script:failures.Add("marker: the server emits '$marker' but the client never looks for it")
    }
}

# --- 4. part count versus the client threshold ----------------------------
# prefix + bag + slot + itemId + guid + every unconditional section + template
# payload; pendingIdentifyData is the only optional section.
$serverUnconditional = @($serverSections | Where-Object { $_ -ne 'pendingIdentifyData' -and $_ -ne 'templateStatsData' })
$serverMinParts = 1 + 4 + $serverUnconditional.Count + 1
$templateParts = 1 + 2 + $templateEmptyCount + 1
if ($serverMinParts -ne $clientThreshold) {
    $script:failures.Add((
        "part count: a located payload has $serverMinParts parts but the client switches layout at $clientThreshold"))
}
if ($templateParts -ge $clientThreshold) {
    $script:failures.Add((
        "part count: the template-only payload has $templateParts parts and would be parsed as a located payload " +
        "(threshold $clientThreshold)"))
}
Write-Output ("  payload parts: located={0} template={1} (client threshold {2})" -f $serverMinParts, $templateParts, $clientThreshold)

if ($script:failures.Count -gt 0) {
    foreach ($failure in $script:failures) { Write-Output "FAIL $failure" }
    Write-Output ("Tooltip payload sync failed: {0} mismatch(es)" -f $script:failures.Count)
    exit 1
}

Write-Output "Tooltip payload sync: prefix, section order, markers and part counts match"
exit 0
