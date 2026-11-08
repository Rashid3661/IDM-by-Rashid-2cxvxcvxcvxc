"""IDM By Rashid desktop entry point (Windows PyInstaller / Python source)."""
from __future__ import annotations
import os
import sys
import threading
import time
import urllib.request
import json
import webbrowser
import importlib
import subprocess
import traceback

from core.paths import RESOURCE_DIR, user_data_dir, binary_path
from core.server import DownloadManagerRouter, start_background_server

API = 'http://127.0.0.1:6800'


def _call_running(path, payload=None):
    try:
        data = json.dumps(payload).encode() if payload is not None else None
        req = urllib.request.Request(API + path, data=data,
               headers={'Content-Type': 'application/json'} if data else {})
        with urllib.request.urlopen(req, timeout=0.8) as response:
            return response.status == 200
    except Exception:
        return False


def _tray(router):
    try:
        import pystray
        from PIL import Image
        icon = Image.open(RESOURCE_DIR / 'icons' / 'app_icon.ico').convert('RGBA')

        def show(_icon, _item):
            if router.window_ref.get('win'):
                try:
                    router.window_ref['win'].show()
                    router.window_ref['win'].restore()
                    return
                except Exception:
                    pass
            webbrowser.open(API)

        def open_downloads(_icon, _item):
            from core.server import _open_folder
            _open_folder(router.download_dir)

        def close(_icon, _item):
            _icon.stop()
            router.aria2.shutdown()
            os._exit(0)

        tray_icon = pystray.Icon('IDMByRashid', icon, 'IDM By Rashid',
              pystray.Menu(pystray.MenuItem('Show downloads', show, default=True),
                           pystray.MenuItem('Open downloads folder', open_downloads),
                           pystray.MenuItem('Exit', close)))
        threading.Thread(target=tray_icon.run, daemon=True, name='System Tray').start()
        return tray_icon
    except Exception:
        return None


def main():
    argument = sys.argv[1].strip() if len(sys.argv) > 1 else ''
    if argument and _call_running('/api/prompt_download', {'url': argument, 'kind': 'external'}):
        return
    if not argument and _call_running('/api/focus', {}):
        return

    router = DownloadManagerRouter()
    start_background_server(router)
    for _ in range(55):
        if _call_running('/api/health'):
            break
        time.sleep(.1)
    else:
        router.aria2.shutdown()
        raise RuntimeError('Desktop API failed to start. Another application may be using port 6800.')

    if argument:
        _call_running('/api/prompt_download', {'url': argument, 'kind': 'external'})
    tray_icon = _tray(router)
    try:
        import webview
        window = webview.create_window('IDM By Rashid', API,
                 width=1260, height=780, min_size=(900, 590),
                 background_color='#F4F7F9')
        router.window_ref['win'] = window
        webview.start(debug=False)
    except Exception as exc:
        print(f'Embedded window unavailable: {exc}. Using default browser.', file=sys.stderr)
        webbrowser.open(API)
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            pass
    finally:
        if tray_icon:
            try:
                tray_icon.stop()
            except Exception:
                pass
        router.aria2.shutdown()


def packaged_self_test() -> int:
    """Noninteractive packaged-dependency check for installer QA.

    Checks bundled files and executable launch; not a full GUI/network test.
    """
    try:
        for module in ('flask', 'requests', 'aria2p', 'yt_dlp',
                       'webview', 'pystray', 'PIL'):
            importlib.import_module(module)
        for rel in ('gui/web/index.html', 'icons/app_icon.ico'):
            if not (RESOURCE_DIR / rel).is_file():
                raise FileNotFoundError(f'Missing packaged resource: {rel}')
        for engine in ('aria2c', 'ffmpeg', 'ffprobe'):
            executable = binary_path(engine)
            if not executable.is_file():
                raise FileNotFoundError(f'Missing bundled engine: {executable}')
            version_flag = '--version' if engine == 'aria2c' else '-version'
            result = subprocess.run([str(executable), version_flag],
                                    capture_output=True, timeout=20, check=False)
            if result.returncode != 0:
                raise RuntimeError(f'{engine} failed to start: {result.returncode}')
        return 0
    except Exception:
        path = user_data_dir() / 'package_self_test_error.log'
        path.write_text(traceback.format_exc(), encoding='utf-8')
        return 1


def _report_startup_crash():
    """Give packaged users a visible error and a diagnostic log."""
    try:
        log_path = user_data_dir() / 'startup_error.log'
        log_path.write_text(traceback.format_exc(), encoding='utf-8')
        if os.name == 'nt':
            import ctypes
            ctypes.windll.user32.MessageBoxW(
                0,
                'IDM By Rashid could not start.\n\nDiagnostic log saved at:\n' + str(log_path),
                'IDM By Rashid - Startup error', 0x10)
        else:
            print('IDM By Rashid failed to start; see ' + str(log_path), file=sys.stderr)
    except Exception:
        pass


if __name__ == '__main__':
    if len(sys.argv) == 2 and sys.argv[1] == '--self-test':
        sys.exit(packaged_self_test())
    try:
        main()
    except Exception:
        _report_startup_crash()
        sys.exit(1)

