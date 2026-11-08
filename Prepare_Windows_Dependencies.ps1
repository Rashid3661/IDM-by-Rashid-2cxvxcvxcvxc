# Build-machine only; used in GitHub Actions / developer Windows PC.
# End users receive a compiled installer and never run this file.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Set-Location $PSScriptRoot

$staging = Join-Path $env:TEMP 'IDMByRashid-Engine-Download'
New-Item -ItemType Directory -Force -Path $staging, 'bin', 'installer_assets' | Out-Null

function Download-Checked([string]$Uri, [string]$Path, [string]$Sha256 = '') {
    Write-Host "Downloading: $Uri"
    Invoke-WebRequest -Uri $Uri -OutFile $Path -MaximumRedirection 10 -UseBasicParsing
    $file = Get-Item $Path
    if ($file.Length -lt 1024) { throw "Downloaded file is unexpectedly small: $Path" }
    if ($Sha256) {
        $actual = (Get-FileHash $Path -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actual -ne $Sha256.ToLowerInvariant()) {
            Remove-Item -Force $Path
            throw "SHA-256 verification failed for $Uri; expected $Sha256 got $actual"
        }
        Write-Host "Verified SHA-256: $actual"
    }
}

# aria2 official GitHub release; hash verified against Scoop's signed package manifest.
$ariaZip = Join-Path $staging 'aria2-1.37.0-win-64bit-build1.zip'
Download-Checked 'https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip' $ariaZip '67d015301eef0b612191212d564c5bb0a14b5b9c4796b76454276a4d28d9b288'
$ariaFolder = Join-Path $staging 'aria2-expanded'
if (Test-Path $ariaFolder) { Remove-Item -Recurse -Force $ariaFolder }
Expand-Archive -Path $ariaZip -DestinationPath $ariaFolder
$ariaExe = Get-ChildItem -Path $ariaFolder -Filter 'aria2c.exe' -Recurse -File | Select-Object -First 1
if (-not $ariaExe) { throw 'The aria2 archive did not contain aria2c.exe.' }
Copy-Item $ariaExe.FullName 'bin\aria2c.exe' -Force

# FFmpeg Essentials ZIP (ffmpeg + ffprobe) from Gyan Doshi's official HTTPS site.
# Match the build to its publisher-provided SHA-256. The unversioned release link can
# advance, so fetch the checksum at build time and fail closed on any mismatch.
$ffZipUri = 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip'
$ffChecksumUri = "$ffZipUri.sha256"
$ffChecksumFile = Join-Path $staging 'ffmpeg-release-essentials.zip.sha256'
Invoke-WebRequest -Uri $ffChecksumUri -OutFile $ffChecksumFile -MaximumRedirection 10 -UseBasicParsing
$checksumText = Get-Content -LiteralPath $ffChecksumFile -Raw
$checksumMatch = [regex]::Match($checksumText, '(?im)^\s*([0-9a-f]{64})\b')
if (-not $checksumMatch.Success) {
    throw 'Official FFmpeg SHA-256 file did not contain a valid checksum.'
}
$ffZip = Join-Path $staging 'ffmpeg-release-essentials.zip'
Download-Checked $ffZipUri $ffZip $checksumMatch.Groups[1].Value
$ffFolder = Join-Path $staging 'ffmpeg-expanded'
if (Test-Path $ffFolder) { Remove-Item -Recurse -Force $ffFolder }
Expand-Archive -Path $ffZip -DestinationPath $ffFolder
foreach ($name in @('ffmpeg.exe', 'ffprobe.exe')) {
    $file = Get-ChildItem -Path $ffFolder -Filter $name -Recurse -File | Select-Object -First 1
    if (-not $file) { throw "FFmpeg archive did not contain $name" }
    Copy-Item $file.FullName (Join-Path 'bin' $name) -Force
}

# Official Microsoft WebView2 Evergreen standalone x64 installer, for offline first-run setup.
$webviewPath = Join-Path 'installer_assets' 'MicrosoftEdgeWebView2RuntimeInstallerX64.exe'
Download-Checked 'https://go.microsoft.com/fwlink/?linkid=2124701' $webviewPath
$webviewFile = Get-Item $webviewPath
if ($webviewFile.Length -lt 30000000) { throw 'WebView2 standalone installer is smaller than expected.' }
$signature = Get-AuthenticodeSignature $webviewPath
if ($signature.Status -ne 'Valid' -or
    -not $signature.SignerCertificate -or
    $signature.SignerCertificate.Subject -notmatch 'Microsoft Corporation') {
    throw "WebView2 installer signature is not a valid Microsoft signature: $($signature.Status)"
}

# Check that the engines really start on the Windows build machine.
foreach ($name in @('aria2c.exe', 'ffmpeg.exe', 'ffprobe.exe')) {
    $binPath = (Resolve-Path (Join-Path 'bin' $name)).Path
    $versionFlag = if ($name -eq 'aria2c.exe') { '--version' } else { '-version' }
    & $binPath $versionFlag | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Binary health check failed: $name" }
}
Write-Host '[OK] Bundled Windows engines and offline WebView2 runtime are ready.'
