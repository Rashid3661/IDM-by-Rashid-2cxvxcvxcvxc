# Build-machine smoke test. Does not open the GUI or make network downloads.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$setup = (Resolve-Path 'installer\IDM-By-Rashid-Setup.exe').Path
# RUNNER_TEMP is only defined in CI; also support a local Windows developer build.
$testRoot = if ($env:RUNNER_TEMP) { $env:RUNNER_TEMP } else { $env:TEMP }
$destination = Join-Path $testRoot 'IDM By Rashid Custom Location'
if (Test-Path $destination) { Remove-Item -Path $destination -Force -Recurse }

# Use an alternate install folder to check that custom paths work.
$arguments = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /DIR=`"$destination`""
$process = Start-Process -FilePath $setup -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) { throw "Setup failed with exit code $($process.ExitCode)" }

$exe = Join-Path $destination 'IDM By Rashid.exe'
if (!(Test-Path $exe)) { throw "Installed launcher not found: $exe" }
$binDirectory = Join-Path $destination '_internal\bin'
foreach ($binary in @('aria2c.exe', 'ffmpeg.exe', 'ffprobe.exe')) {
    if (!(Test-Path (Join-Path $binDirectory $binary))) {
        throw "Bundled engine missing after install: $binary"
    }
}

$test = Start-Process -FilePath $exe -ArgumentList '--self-test' -Wait -PassThru
if ($test.ExitCode -ne 0) { throw "Installed application failed its self-test: $($test.ExitCode)" }

$uninstaller = Get-ChildItem -Path $destination -Filter 'unins*.exe' | Select-Object -First 1
if (-not $uninstaller) { throw 'The installer did not create an uninstaller' }
$process = Start-Process -FilePath $uninstaller.FullName -ArgumentList '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART' -Wait -PassThru
if ($process.ExitCode -ne 0) { throw "Uninstall failed with exit code $($process.ExitCode)" }
if (Test-Path $exe) { throw 'The application executable remains after uninstall' }
Write-Host '[OK] Setup installed to a custom folder; bundled files and self-test passed; uninstall succeeded.'
