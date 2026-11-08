# IDM By Rashid — Revision notes

## Installer release preparation (2026-11-09)

- Replaced the ordinary-user Python launcher workflow with a Windows installable EXE release workflow (PyInstaller + Inno Setup).
- The finished installer includes a private bundled Python runtime and modules, aria2, FFmpeg, and FFprobe; it does not install system Python.
- Added per-user installation with an editable destination folder, Start Menu and optional desktop shortcuts, and normal uninstall support.
- Added offline WebView2 deployment that checks for an existing runtime and installs the Microsoft-signed x64 package only if missing.
- Added GitHub Actions Windows build, pinned aria2 archive hash, publisher-matched FFmpeg checksum, Authenticode verification for WebView2, packaged self-test, and install/uninstall smoke test.
- This current archive is **build source**; a Windows setup EXE has **not** been compiled or tested in this Linux environment.

## Launcher repair (2026-11-09)

- Fixed the Windows source launcher incorrectly continuing after a missing Python 3.12 runtime.
- Added an opt-in `py install 3.12` step when the Windows Python install manager is present.
- Check the integrity of `.venv` and install required packages before starting the application.
- Keep application errors visible in the launching Command Prompt.
- Added exit-code checks to the Windows PyInstaller build script.
- This does not produce a precompiled EXE; building still requires Windows.

## Version 2.0 source revision (2026-11-08)

### Fixed or improved in source

- Replaced destructive torrent re-add fallback with pause → change options → confirm → resume; no file unlinking.
- Added persistent torrent selection preferences, aria2 session save/recovery options, bounded retries and user feedback.
- Replaced incorrect custom multi-part assembly with verified HTTP streaming/resume fallback; aria2 remains the accelerated transfer engine.
- Added real format discovery via yt-dlp, with video cancellation and better error display.
- Added Chrome Manifest V3 page helper and playing HTML5 video prompt.
- Added persistent settings, SQLite history, scoped localhost API access, safer downloaded-file reveal behavior.
- Reworked app navigation into a compact Windows download-manager interface; removed fake marketing counters, false quality choices, and dead extension-install claims.
- Created new matching ICO/PNG icons, Windows PyInstaller spec, click-to-build command, GitHub Actions workflow, optional Inno Setup script.

### Validated

- 17 offline Python tests; JS source syntax checks; main interface screenshot from headless Chromium.

### Unverified / future work

- Live end-to-end runs of aria2 + Chrome/YouTube + PyInstaller on Windows.
- Measured 1 Gbps throughput and TB-size download reliability.
- Date/time scheduler, site grabber, full browser interception, and commercial-IDM feature parity.

This is a buildable source release, not an already compiled Windows EXE or a certified production binary.
