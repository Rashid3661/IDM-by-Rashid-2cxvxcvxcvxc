@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title IDM By Rashid - Setup and Run

echo ====================================================
echo   IDM By Rashid - Windows launcher
echo ====================================================
echo.

rem The app currently targets Python 3.12. A Python launcher alone is not enough.
where py >nul 2>&1
if errorlevel 1 goto no_py_launcher
py -3.12 -c "import sys; assert sys.version_info[:2] == (3, 12)" >nul 2>&1
if errorlevel 1 goto python_missing
goto python_ready

:python_missing
echo [SETUP] Python 3.12 is not installed, even though the py launcher exists.
echo [SETUP] This is why the previous launcher failed.
echo.
choice /C YN /N /M "Install official Python 3.12 now? (Y/N): "
if errorlevel 2 goto manual_install
py install 3.12
if errorlevel 1 goto python_install_error
py -3.12 -c "import sys; assert sys.version_info[:2] == (3, 12)" >nul 2>&1
if errorlevel 1 goto python_install_error
goto python_ready

:no_py_launcher
echo [ERROR] The Windows Python launcher (py) is not available.
echo.
echo Install Python 3.12 from: https://www.python.org/downloads/windows/
echo Then reopen this folder and run Run_Source_Windows.cmd again.
echo You can also install with: winget install Python.Python.3.12 -e
pause
exit /b 1

:python_install_error
echo.
echo [ERROR] Automatic installation did not succeed.
echo Your py command may be an older Python launcher without the install feature.
echo Install Python 3.12 manually from https://www.python.org/downloads/windows/
echo Or use: winget install Python.Python.3.12 -e
pause
exit /b 1

:manual_install
echo.
echo Setup cancelled. Nothing was changed by this launcher.
echo To install manually, run: py install 3.12
pause
exit /b 1

:python_ready
echo [OK] Python 3.12 is available.

rem Never continue after virtual-environment creation fails.
if not exist ".venv\Scripts\python.exe" goto create_venv
".venv\Scripts\python.exe" -c "import sys; assert sys.version_info[:2] == (3, 12)" >nul 2>&1
if errorlevel 1 goto reset_venv
goto check_dependencies

:reset_venv
echo [SETUP] Recreating an incomplete or incompatible local .venv folder...
rmdir /s /q ".venv"
if exist ".venv" goto venv_error

:create_venv
echo [SETUP] Creating the app's private Python environment...
py -3.12 -m venv ".venv"
if errorlevel 1 goto venv_error
if not exist ".venv\Scripts\python.exe" goto venv_error

:check_dependencies
".venv\Scripts\python.exe" -c "import flask, requests, aria2p, yt_dlp, webview, pystray, PIL" >nul 2>&1
if errorlevel 1 goto install_dependencies
goto start_app

:install_dependencies
echo [SETUP] Installing required Python packages. An internet connection is needed.
".venv\Scripts\python.exe" -m pip install --disable-pip-version-check -r "requirements.txt"
if errorlevel 1 goto dependencies_error
".venv\Scripts\python.exe" -c "import flask, requests, aria2p, yt_dlp, webview, pystray, PIL" >nul 2>&1
if errorlevel 1 goto dependencies_error

:start_app
echo.
echo [OK] Starting IDM By Rashid...
echo Keep this window open while using the app; errors will appear here.
echo.
".venv\Scripts\python.exe" "app.py"
if errorlevel 1 goto application_error
exit /b 0

:venv_error
echo.
echo [ERROR] Python 3.12 is present, but the local .venv could not be created.
echo Check folder permissions and available disk space.
pause
exit /b 1

:dependencies_error
echo.
echo [ERROR] Package installation failed. Check the errors above and your internet connection.
echo You may rerun this launcher; completed downloads of packages will be reused by pip.
pause
exit /b 1

:application_error
echo.
echo [ERROR] The application exited with an error. Read the details above.
pause
exit /b 1
