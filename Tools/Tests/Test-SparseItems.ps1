$ErrorActionPreference = 'Stop'
$root = (Resolve-Path "$PSScriptRoot\..\..").Path
$outDir = Join-Path $root 'build\migration-tests'
[System.IO.Directory]::CreateDirectory($outDir) | Out-Null
$source = [System.IO.File]::ReadAllText((Join-Path $root 'WoW\Source\DB\WowClientDB.h')).Replace("`r`n", "`n")
# Compile the production lookup/injection bodies with only the storage fixture.
# This avoids linking the entire DBC loader and does not copy the algorithms.
$fixture = @'
#include <map>
#include <cstdint>
#include <cassert>
#include <cstdio>
template<class T> struct WowClientDB {
    T** m_recordsById = nullptr;
    int32_t m_minID = 1, m_maxID = 1;
    mutable std::map<int32_t, T> m_injectedRecords;
    T* GetRecord(int32_t id) const;
    void InjectRecord(int32_t id, const T& rec);
};
'@
foreach ($pattern in @('(?ms)^template <class T>\nT\* WowClientDB<T>::GetRecord\(int32_t id\) const \{.*?^}', '(?ms)^template <class T>\nvoid WowClientDB<T>::InjectRecord\(int32_t id, const T& rec\) \{.*?^}')) {
    $match = [regex]::Match($source, $pattern)
    if (!$match.Success) { throw 'Production DBC method not found; update extraction.' }
    $fixture += "`n" + $match.Value
}
$fixture += @'

int main() {
    WowClientDB<int> db;
    int native = 7; int* index[] = {&native}; db.m_recordsById = index;
    db.InjectRecord(1, 99); assert(db.GetRecord(1) == &native);
    db.InjectRecord(2000000000, 42);
    int* stable = db.GetRecord(2000000000); assert(stable && *stable == 42);
    for (int i = 2; i < 10002; ++i) db.InjectRecord(i * 1000, i);
    db.InjectRecord(2000000000, 99);
    assert(db.GetRecord(2000000000) == stable && *stable == 42);
    assert(db.m_minID == 1 && db.m_maxID == 1 && db.m_recordsById == index);
    assert(db.m_injectedRecords.size() == 10001 && db.GetRecord(-1) == nullptr);
    puts("Sparse items: large IDs, stable pointers, native precedence and no dense-range growth passed");
}
'@
$cpp = Join-Path $outDir 'sparse-items.cpp'
$exe = Join-Path $outDir 'sparse-items.exe'
[System.IO.File]::WriteAllText($cpp, $fixture, [System.Text.UTF8Encoding]::new($false))
& cl /nologo /EHsc "/Fo$outDir\sparse-items.obj" "/Fe$exe" $cpp
if ($LASTEXITCODE -ne 0) { throw 'Sparse item fixture compilation failed' }
& $exe
if ($LASTEXITCODE -ne 0) { throw 'Sparse item regression failed' }
