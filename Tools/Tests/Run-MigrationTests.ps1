param([string]$BuildDirectory = 'build\x64')
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path "$PSScriptRoot\..\..").Path
Push-Location $root
try {
    if (!(Get-Command cl -ErrorAction SilentlyContinue)) { throw 'Run from a VS 2022 x64 Developer PowerShell.' }
    $outDir = Join-Path $root 'build\migration-tests'
    [System.IO.Directory]::CreateDirectory($outDir) | Out-Null
    $luaLibrary = Join-Path $BuildDirectory 'lib\Release\lua.lib'
    if (!(Test-Path $luaLibrary)) { throw "Build the Release lua target first: $luaLibrary" }
    & cl /nologo /MD /EHsc /I. /IEngine\Source\lua-5.1\src Tools\Tests\LuaRunner.cpp Engine\Source\Base\ConvertUTF.cpp "/Fo$outDir\" "/Fe$outDir\LuaRunner.exe" $luaLibrary
    if ($LASTEXITCODE -ne 0) { throw 'Lua test runner compilation failed' }
    $luaFiles = @(Get-ChildItem Interface -Filter '*.lua' -Recurse | ForEach-Object { $_.FullName })
    & "$outDir\LuaRunner.exe" --syntax @luaFiles
    if ($LASTEXITCODE -ne 0) { throw 'Lua syntax check failed' }
    Write-Output "Lua syntax: $($luaFiles.Count) files passed"
    foreach ($test in @('NativeUiRefresh.lua', 'EventUiRefresh.lua', 'LuaAmounts.lua')) {
        & "$outDir\LuaRunner.exe" "Tools/Tests/$test"
        if ($LASTEXITCODE -ne 0) { throw "$test failed" }
    }
    & cl /nologo /EHsc /I. Tools\Tests\NativeProtocol.cpp "/Fo$outDir\NativeProtocol.obj" "/Fe$outDir\NativeProtocol.exe"
    if ($LASTEXITCODE -ne 0) { throw 'Protocol test compilation failed' }
    & "$outDir\NativeProtocol.exe"
    if ($LASTEXITCODE -ne 0) { throw 'Protocol regression failed' }
    & "$PSScriptRoot\Test-SparseItems.ps1"
    & powershell -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot\Test-NativeLifecycle.ps1"
    if ($LASTEXITCODE -ne 0) { throw 'Lifecycle regression failed' }
    & powershell -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot\Test-NativeProtocolSync.ps1"
    if ($LASTEXITCODE -ne 0) { throw 'Native protocol sync failed' }
    Write-Output 'All migration source/fixture checks passed; live game acceptance is separate.'
} finally { Pop-Location }
