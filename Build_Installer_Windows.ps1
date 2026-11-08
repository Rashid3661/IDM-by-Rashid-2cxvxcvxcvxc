# Developer/CI build helper; end users only run the generated .exe installer.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

& (Join-Path $PSScriptRoot 'Prepare_Windows_Dependencies.ps1')
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw "Dependency preparation returned $LASTEXITCODE" }
& (Join-Path $PSScriptRoot 'Build_Windows.ps1')
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw "PyInstaller build returned $LASTEXITCODE" }

$iscc = (Get-Command 'ISCC.exe' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source)
if (-not $iscc) {
    foreach ($candidate in @(
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 6\ISCC.exe")) {
        if (Test-Path $candidate) { $iscc = $candidate; break }
    }
}
if (-not $iscc) {
    throw 'Inno Setup 6 compiler was not found. On a Windows build PC install Inno Setup 6; for normal users, distribute the generated setup EXE.'
}
& $iscc (Join-Path $PSScriptRoot 'IDMByRashid.iss')
if ($LASTEXITCODE -ne 0) { throw "Inno Setup compiler failed with exit code $LASTEXITCODE" }
$setup = Join-Path $PSScriptRoot 'installer\IDM-By-Rashid-Setup.exe'
if (!(Test-Path $setup)) { throw "Installer was not generated: $setup" }
$sizeMB = [math]::Round((Get-Item $setup).Length / 1MB, 1)
Write-Host "[OK] Full installer: $setup ($sizeMB MB)"
