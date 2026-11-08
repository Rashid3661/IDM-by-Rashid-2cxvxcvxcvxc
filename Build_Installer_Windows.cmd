@echo off
setlocal
cd /d "%~dp0"
title IDM By Rashid - Developer Installer Builder
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Build_Installer_Windows.ps1"
if errorlevel 1 (
    echo.
    echo [ERROR] Installer build failed. Read the output above.
    pause
    exit /b 1
)
echo.
echo Installer created: installer\IDM-By-Rashid-Setup.exe
pause
