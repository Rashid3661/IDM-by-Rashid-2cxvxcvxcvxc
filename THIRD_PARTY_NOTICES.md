# Third-party components and licensing

This project invokes or bundles existing software. The original user-supplied source archive included third-party Windows executables for aria2, FFmpeg, and FFprobe, which were not independently audited. The new automated installer build instead downloads the aria2 1.37.0 Windows ZIP and FFmpeg 9.0.2 Essentials ZIP from their documented distribution sites and checks pinned SHA-256 values. It also bundles Microsoft-signed WebView2 Evergreen Standalone installer for the app window. The hashes and code signing check help detect unexpected build artifacts but are not a full software security audit.

- **aria2** — download engine — https://github.com/aria2/aria2 — commonly GPLv2 licensing; check the binary distributor's terms and required notices/source offer.
- **FFmpeg and FFprobe** — media processing — https://ffmpeg.org/legal.html — licensing depends on build configuration (LGPL or GPL and possibly external components). Check `ffmpeg.exe -version` for configuration and distribute required notices/source as applicable.
- **yt-dlp** — video extractor — https://github.com/yt-dlp/yt-dlp — see upstream license.
- **Flask / Werkzeug**, **aria2p**, **pywebview**, **pystray**, **Pillow**, **requests**, **PyInstaller** — Python packages installed at build time with each upstream project's license.

Before publicly redistributing a compiled application, confirm the exact third-party binary builds you ship, their license requirements, any patent constraints in your jurisdiction, and that their source and notices are handled correctly. For personal use, keep a trustworthy copy of each binary and avoid running unknown executables with elevated privileges.

- **Microsoft WebView2 Evergreen Runtime** — native window engine; the installer bundles the Microsoft-signed x64 standalone redistributable. https://developer.microsoft.com/microsoft-edge/webview2/ . Redistribute under Microsoft's WebView2 terms.
