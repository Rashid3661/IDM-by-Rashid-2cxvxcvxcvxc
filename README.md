# IDM By Rashid — Windows installer release project

**Application version:** 2.1.0 (installer build preparation)  
**Target:** Windows 10/11 x64  
**App:** Desktop downloader based on the existing Python/Flask, aria2, yt-dlp and FFmpeg code

## For someone installing the application

1. Download the finished **`IDM-By-Rashid-Setup.exe`** produced by the Windows build workflow.
2. Double-click it. The installer provides a **Choose installation folder** page.
3. Click **Install**. You can optionally create a desktop shortcut.
4. Open **IDM By Rashid** from the Start Menu or desktop. Uninstall it from **Windows Settings → Installed apps** or the Start Menu.

**No separate Python installation, pip, terminal commands, or manual download-engine setup.** The finished installer bundles the Python runtime/modules, aria2c, FFmpeg, FFprobe, and an offline Microsoft WebView2 runtime installer. WebView2 is installed silently only if missing; systems with it already installed skip that step. The installer runs as a normal Windows user by default and installs to `%LOCALAPPDATA%\Programs\IDM By Rashid` unless the user chooses a different writable location. Download history and settings are stored separately under `%LOCALAPPDATA%\IDMByRashid` and are not erased on uninstall.

**Current artifact status:** This source package contains the Windows installer recipe and a workflow to compile it, **not** a compiled setup EXE. The compile and install smoke test must run on Windows before making a release claim. The full source package is for developers/builders; it is **not** what ordinary users should receive.

## How to generate the installer (one-time build process)

**Recommended: GitHub Actions, no Python installation on your own computer.** Upload the project source (excluding the large original `bin/*.exe` files) into a GitHub repository and go to **Actions → Build installable Windows EXE → Run workflow**. The workflow runs in a Windows build machine, installs the compiler/build-only dependencies there, downloads verified download engines and Microsoft's offline WebView2 runtime, packages the self-contained app with PyInstaller, compiles `IDM-By-Rashid-Setup.exe` using Inno Setup, tests install/uninstall and uploads **IDM-By-Rashid-Windows-Installer** containing the setup EXE. The resulting EXE is the only file you need to distribute to end users.

**On a developer Windows machine:** Install Python 3.12 and Inno Setup 6 on the **build machine only**, and run `Build_Installer_Windows.cmd` to produce `installer\IDM-By-Rashid-Setup.exe`. Python is only needed to build, **not** to install or run the final application.

The project deliberately does not try to install a Chrome extension silently. Browsers require user consent or managed extension policies; the built-in extension can be installed manually. An unsigned EXE may show an unknown-publisher/SmartScreen warning; a signed release requires an actual code-signing certificate. This is not a claim of Microsoft certification or verification of the original download binaries.

Read `INSTALLER_README.md` for the exact build workflow, component checks, and release limitations.

## Daily use

**Direct downloads:** Paste an HTTP(S), FTP, or SFTP link in the main field and select **Add Download**. For HTTP(S), the app checks the server's available metadata and offers 1/4/8/16 connections when range support is reported. aria2 handles retries, multiple connections, and resume if the source server supports it.

**Torrents:** Select **Open .torrent**, review the actual file list, uncheck files you do not want, and select **Apply File Selection**. Files that appear optional may be labeled based on their names; verify these suggestions yourself. You cannot deselect every file. For magnets, paste the magnet link and wait for metadata from peers, then select the files. Magnets can take longer when peers are unavailable.

**Edit running torrents:** Choose **Select Files** on a torrent task. The app pauses the torrent, asks aria2 to update `select-file`, verifies the selection, and resumes it if it was already running. It does **not** remove/re-add the torrent or delete existing files. On some torrents, shared pieces can still create data for files the user has deselected; aria2 controls piece allocation.

**Videos:** Paste a supported video page URL, select **Add Download**, and inspect available formats. The app lists resolutions returned by yt-dlp rather than fixed 4K/1080p promises. Choose an available video or audio format and start the transfer. Video segments/streams may require FFmpeg to merge or convert. A site's access restrictions, account requirements, DRM, or changes to its player may prevent downloading. Only download content you are allowed to save.

**Chrome/Chromium browser helper:** In the app, select **Browser Extension → Open Extension Folder**. In Chrome, open `chrome://extensions`, enable **Developer mode**, and select **Load unpacked**; choose the displayed `extension` folder. On pages with visible playing HTML5 video, a small **Choose video download** control appears. The browser helper submits the page URL to your running desktop app for inspection; it does **not** guarantee downloading every stream, handle DRM, or intercept every browser download.

**Queue and settings:** The app supports pause/resume for aria2 items, pause/resume all, batch URL submission (up to 200), search, sort, completed history, cancel for yt-dlp tasks, and `Settings` for total aria2 speed cap and simultaneous downloads. Removing a queue entry does not delete downloaded files. Settings/history/aria2 sessions are kept in `%LOCALAPPDATA%\IDMByRashid`.

## Performance notes

- Main file transfers use **aria2**, with up to 16 connections per server, 16-way splitting, 64 MiB disk cache, retries, and persistent aria2 sessions. These are defaults, not a fixed speed multiplier.
- Higher throughput requires a capable remote server or sufficient torrent peers, adequate disk write speed, and an unrestricted network route. A 1 Gbps connection does **not** guarantee that a particular file will reach 1 Gbps. Some servers throttle or disallow parallel ranges.
- Multi-gigabyte file support depends on aria2, the filesystem, free disk space, source behavior, and correct resume metadata. The offline tests used an 8 MiB local transfer, **not** a real 1 TB transfer or a 1 Gbps benchmark.
- If a download fails repeatedly at high connection counts, choose fewer connections or check the error details. Some servers reject segmented requests.

## Test results and boundaries

Run the test suite after installing requirements and pytest:

```powershell
py -3.12 -m pip install -r requirements.txt pytest
py -3.12 -m pytest -q tests
```

The source revision passed **17 tests** in a Linux test environment using controlled HTTP responses and mocked aria2/yt-dlp operations. Tests cover torrent file parsing, changing selections while running/paused, preservation of existing files, invalid selections, resumable HTTP streaming, settings persistence and failure handling, API authorization, FTP analysis, batch reporting, and resolution detection. The JavaScript files passed Node's syntax checker and the main UI was rendered in a headless Chromium snapshot.

**Not verified in this environment:** standalone Windows EXE creation and launch, real torrent swarm performance, real YouTube/other websites, antivirus acceptance, long-running sessions, large (TB-scale) files, 1 Gbps throughput, native window/tray interaction, and Chrome extension operation against live pages. These must be tested on Windows before describing this as a production-ready release. A real installed extension is not provided automatically; Chrome requires a manual installation step.

**Not implemented from commercial IDM:** universal browser download interception and replacement, site-wide crawler/site grabber, scheduled downloads by date/time, protected-stream DRM bypass, automatic browser installation, and an installer built in this environment. The browser integration is a manual helper with playback detection, not a one-to-one replacement for IDM's native browser integration.

## Common problems

- **`No runtime installed that matches 3.12`:** The `py` launcher is installed, but Python 3.12 is not. Run `py install 3.12` from Command Prompt or rerun the updated `Run_Source_Windows.cmd` and approve the installation prompt. If the legacy `py` launcher does not support `install`, use the official installer or `winget install Python.Python.3.12 -e`.
- **`Dependency installation failed`:** If Python was missing, the old launcher produced this misleading second error. The updated launcher does not attempt to install packages until it verifies Python 3.12 and successfully creates its local `.venv`.
- **Window never opens:** Check Python 3.12, WebView2 availability, firewall/antivirus events, and whether another process already uses desktop port 6800. The updated launcher keeps errors visible. PyInstaller builds depend on bundled runtime files.
- **`aria2 exited during startup`:** Inspect `bin\aria2c.exe`; try running it from PowerShell with `--version` to see whether the binary itself starts. An incompatible or blocked binary will stop the engine from starting. Application errors are not bypassed or reported as successful.
- **`ffmpeg` errors:** Confirm `bin\ffmpeg.exe` and `bin\ffprobe.exe` are available, then retry after verifying the video formats.
- **Torrent file list unavailable:** Magnet metadata requires peers. Wait and choose **Select Files** on its queue entry once metadata appears. If a file change cannot be confirmed, the torrent stays in the queue and the app reports an error.
- **Downloads stop after a few seconds:** Check the source link, server range support, disk space, antivirus activity, and whether the remote server limits connections. Select fewer connections if necessary.
- **YouTube page detected, but cannot download:** The browser only detects playback. yt-dlp needs access to the media URL and currently supported formats; account restrictions, DRM, and site changes may prevent access.

## Project layout

```text
app.py                     Windows desktop launcher
core/server.py             Local API, settings, queue and actions
core/torrent_engine.py     aria2 downloads, magnets and file selection
core/video_grabber.py      Video probing, yt-dlp transfers
core/chunk_downloader.py   HTTP stream fallback and probe
core/database.py           SQLite completed/deleted download history
core/paths.py              Resource paths and persistent Windows user storage
gui/web/index.html         Desktop app interface
extension/                 Chrome/Chromium Manifest V3 helper
icons/                     App and file-category icons
bin/                       User-provided aria2/FFmpeg Windows executables
tests/                     Offline regression tests
Build_Windows.cmd          Double-click Windows EXE build wrapper
Build_Windows.ps1          Creates Python runtime and PyInstaller onedir app
windows.spec               PyInstaller resources, app icon and native dependencies
IDMByRashid.iss            Optional Inno Setup installer script
.github/workflows/         GitHub Actions Windows build workflow
```

For third-party tool attribution and redistribution precautions, see `THIRD_PARTY_NOTICES.md`.
