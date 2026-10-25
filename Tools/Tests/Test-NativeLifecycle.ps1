param([string]$SourceRoot = (Resolve-Path "$PSScriptRoot\..\..").Path)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path "$PSScriptRoot\..\..").Path
$outDir = Join-Path $root 'build\native-lifecycle-test'
[System.IO.Directory]::CreateDirectory($outDir) | Out-Null
$source = [System.IO.File]::ReadAllText((Join-Path $SourceRoot 'WoW\Source\Client.cpp')).Replace("`r`n", "`n")
$match = [regex]::Match($source, '(?ms)^static int32_t ClientIdle\(const void\* data, void\* param\) \{.*?^}')
if (!$match.Success) { throw 'ClientIdle was not found; update the fixture extraction.' }
$fixture = @'
#include <cstdint>
#include <cstdio>
// Simulate returning to character selection: the world flag survived but the
// Glue Lua context has no game UI marker. No addon may load in ClientIdle.
static bool s_nativeUIWorldLoaded = true;
static bool s_nativeUIBridgeReloadPending = false;
static int reloads = 0;
static void ClientGameTimeTickHandler(const void*, void*) {}
static void Player_C_ZoneUpdateHandler(const void*, void*) {}
static int FrameScript_GetVariable(const char*, const char*&) { return 0; }
static void NativeUIOnFramesRebuilt() { ++reloads; }
'@
$fixture += "`n" + $match.Value + "`n"
$fixture += @'
int main() {
    for (int i = 0; i < 6000; ++i) ClientIdle(nullptr, nullptr);
    printf("Character-selection idle: %d bundled UI reloads in 6000 ticks\n", reloads);
    return reloads ? 1 : 0;
}
'@
$cpp = Join-Path $outDir 'lifecycle.cpp'
$exe = Join-Path $outDir 'lifecycle.exe'
[System.IO.File]::WriteAllText($cpp, $fixture, [System.Text.UTF8Encoding]::new($false))
& cl /nologo /EHsc "/Fo$outDir\lifecycle.obj" "/Fe$exe" $cpp
if ($LASTEXITCODE -ne 0) { throw 'Lifecycle fixture compilation failed' }
& $exe
exit $LASTEXITCODE
