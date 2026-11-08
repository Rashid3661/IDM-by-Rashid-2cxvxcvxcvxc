# -*- mode: python ; coding: utf-8 -*-
# Run only on Windows: PyInstaller cannot cross-compile from Linux.
from pathlib import Path
from PyInstaller.utils.hooks import collect_all

root = Path(SPECPATH)
datas = [(str(root / 'gui' / 'web'), 'gui/web'),
         (str(root / 'extension'), 'extension'),
         (str(root / 'icons'), 'icons')]
binaries = [(str(root / 'bin' / n), 'bin')
            for n in ('aria2c.exe', 'ffmpeg.exe', 'ffprobe.exe')]
hidden = []
for pkg in ('webview', 'aria2p', 'yt_dlp', 'pystray'):
    p_datas, p_bins, p_hidden = collect_all(pkg)
    datas += p_datas
    binaries += p_bins
    hidden += p_hidden

a = Analysis([str(root / 'app.py')], pathex=[str(root)], binaries=binaries,
             datas=datas, hiddenimports=hidden, hookspath=[],
             hooksconfig={}, runtime_hooks=[], excludes=['customtkinter'], noarchive=False)
pyz = PYZ(a.pure)
exe = EXE(pyz, a.scripts, [], exclude_binaries=True,
          name='IDM By Rashid', debug=False, bootloader_ignore_signals=False,
          strip=False, upx=False, console=False,
          icon=str(root / 'icons' / 'app_icon.ico'))
coll = COLLECT(exe, a.binaries, a.datas, strip=False, upx=False,
               name='IDM By Rashid')
