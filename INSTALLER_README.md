# Windows installer — packaging and release

The end-user deliverable is **`IDM-By-Rashid-Setup.exe`**. It is one installer containing the Windows Python runtime, application, download engines, and offline WebView2 setup. **Users only double-click this file.** Python and PowerShell are *build tools*, not prerequisites on their computers.

## User installation

The finished installer provides **Choose install location → Install → Finish**. It defaults to the current user's app folder, works without administrator privileges on a normal machine, creates a Start Menu entry and optional desktop shortcut, and registers uninstall in Windows Settings. It does not remove downloaded files or personal settings on uninstall. If WebView2 is absent, the installer uses Microsoft's official signed **offline** runtime installer without requiring a separate download.

WebView2 is a shared Windows runtime (like a standard Windows component), not a system-wide Python installation. It is only installed if absent.

## Generate the real EXE (Windows build required)

1. Create a GitHub repository with this project's source files and folders (`.github`, `core`, `extension`, `gui`, `icons`, `tests`, `bin/.gitkeep`, `installer_assets/.gitkeep`, and all root `.py`, `.ps1`, `.cmd`, `.iss`, `.spec`, `.txt`, `.md` files). **Do not push the original `bin/*.exe` files:** both original 100+ MiB FFmpeg executables exceed GitHub's file-size limit. The workflow downloads verified Windows engines itself.
2. In GitHub, choose **Actions → Build installable Windows EXE → Run workflow**. No Python is needed on your PC: GitHub's Windows runner builds the release.
3. On success, download the **IDM-By-Rashid-Windows-Installer** artifact. Extract it to get `IDM-By-Rashid-Setup.exe`. Distribute the EXE to ordinary users, not the source ZIP.

Alternatively, on a developer Windows PC with Python 3.12, Git, and Inno Setup 6 installed, double-click `Build_Installer_Windows.cmd`. It fetches pinned vendor download engines, validates them, bundles Python using PyInstaller, and produces `installer/IDM-By-Rashid-Setup.exe`.

## Release QA

The Windows workflow must pass the original Python tests and JavaScript syntax checks, and then:

- launch the frozen app with `--self-test` to check the bundled libraries, UI assets, aria2 and FFmpeg executables;
- compile Inno Setup into one setup EXE;
- silently install it into a **custom directory containing spaces**;
- verify that the app EXE and download engines are present and pass the self-test;
- silently uninstall and confirm that the app executable was removed;
- upload the installer artifact only if all steps pass.

The built-in self-test is not an end-to-end GUI, YouTube, torrent, large-file, or 1 Gbps network test. Those must be performed on actual consumer Windows PCs. Windows SmartScreen may warn about an *unsigned* release; do not claim the installer is signed unless you sign it using your own certificate. The original Chrome extension is installed separately, with user consent, rather than silently modifying browsers.

## External components used for the Windows build

- aria2 1.37.0 — official 64-bit GitHub binary archive, SHA-256 pinned.
- FFmpeg release Essentials — Gyan Doshi Windows ZIP, validated against the matching publisher SHA-256 downloaded during the build. The exact release may advance.
- Microsoft Edge WebView2 Evergreen — Microsoft x64 standalone installer, Authenticode signature checked in the build.
- Python 3.12 and pip packages — installed **only on the Windows build machine** and copied into the frozen app bundle.
- PyInstaller and Inno Setup — used **only on the build machine**.

The standalone WebView2 installer can make the final setup EXE considerably larger. This is intentional for offline installation. If a vendor download fails or its calculated SHA-256 does not match the required checksum, the build **fails** rather than silently shipping an unverified binary. FFmpeg uses its matching current release checksum; aria2 uses a pinned version and SHA-256. Review the third-party notices before public redistribution.

## Status of this deliverable

This ZIP is a complete **installer build project**, not an already-built Windows EXE. It was prepared on Linux, where PyInstaller cannot cross-compile a Windows application. The source checks that can run on Linux have been applied; the Windows build and install/uninstall workflow remain to be executed by a Windows runner.
