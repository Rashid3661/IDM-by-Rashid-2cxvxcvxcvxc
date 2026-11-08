@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title IDM By Rashid - Windows EXE Builder

echo Building IDM By Rashid as a Windows executable...
where py >nul 2>&1
if errorlevel 1 goto missing_py
py -3.12 -c "import sys; assert sys.version_info[:2] == (3, 12)" >nul 2>&1
if errorlevel 1 goto missing_python

goto build

:missing_py
echo [ERROR] Python launcher not found.
echo Install official Python 3.12 from https://www.python.org/downloads/windows/
pause
exit /b 1

:missing_python
echo [ERROR] Python 3.12 is not installed.
echo First use Run_Source_Windows.cmd to install Python 3.12, or run: py install 3.12
pause
exit /b 1

:build
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Build_Windows.ps1"
if errorlevel 1 goto build_error
echo.
echo [OK] Windows executable: dist\IDM By Rashid\IDM By Rashid.exe
echo Copy the COMPLETE dist\IDM By Rashid folder, not just the EXE.
pause
exit /b 0

:build_error
echo.
echo [ERROR] Windows EXE build failed. See errors above.
pause
exit /b 1
