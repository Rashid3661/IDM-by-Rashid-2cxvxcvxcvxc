# Build on Windows 10/11 with Python 3.12. No cross-compilation is performed here.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

function Invoke-Checked([string]$Program, [string[]]$Arguments) {
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed (exit $LASTEXITCODE): $Program $($Arguments -join ' ')"
    }
}

foreach ($name in 'aria2c.exe', 'ffmpeg.exe', 'ffprobe.exe') {
    if (!(Test-Path (Join-Path 'bin' $name))) {
        throw "Required Windows download engine is missing: bin/$name"
    }
}

# Reuse the build virtual environment only if it is a functional Python 3.12 installation.
$buildPython = Join-Path $PSScriptRoot '.build-venv\Scripts\python.exe'
if (Test-Path $buildPython) {
    & $buildPython -c 'import sys; assert sys.version_info[:2] == (3,12)'
    if ($LASTEXITCODE -ne 0) {
        Remove-Item '.build-venv' -Recurse -Force
    }
}
if (!(Test-Path $buildPython)) {
    # GitHub's setup-python makes Python 3.12 available as `python` but does not
    # guarantee that the optional `py` launcher has registered that interpreter.
    $buildBase = $null
    $baseArgs = @()
    foreach ($candidate in @('python', 'py')) {
        if (-not (Get-Command $candidate -ErrorAction SilentlyContinue)) { continue }
        $candidateArgs = if ($candidate -eq 'py') { @('-3.12') } else { @() }
        & $candidate @candidateArgs -c 'import sys; assert sys.version_info[:2] == (3,12)'
        if ($LASTEXITCODE -eq 0) {
            $buildBase = $candidate
            $baseArgs = $candidateArgs
            break
        }
    }
    if (-not $buildBase) {
        throw 'Python 3.12 is missing from the Windows BUILD machine. The distributed installer does not require Python.'
    }
    Invoke-Checked $buildBase ($baseArgs + @('-m', 'venv', '.build-venv'))
}
Invoke-Checked $buildPython @('-m', 'pip', 'install', '--disable-pip-version-check', '-r', 'requirements.txt', 'pyinstaller>=6.5,<7')
Invoke-Checked $buildPython @('-m', 'PyInstaller', '--clean', '--noconfirm', 'windows.spec')
$builtExe = Join-Path $PSScriptRoot 'dist\IDM By Rashid\IDM By Rashid.exe'
if (!(Test-Path $builtExe)) {
    throw "Build returned success but did not create the expected executable: $builtExe"
}
Write-Host "[OK] Windows app: $builtExe"
