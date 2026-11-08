; Normal per-user Windows installer. Compile after PyInstaller produces dist\IDM By Rashid\.
; The Python runtime and modules are bundled in that directory; end users do not install Python.
#define AppTitle "IDM By Rashid"
#define AppVersion "2.1.0"
#define AppExe "IDM By Rashid.exe"

[Setup]
AppId={{B5AE91F7-6302-4C1D-A8C3-C4D96D7135B0}
AppName={#AppTitle}
AppVersion={#AppVersion}
AppVerName={#AppTitle} {#AppVersion}
DefaultDirName={localappdata}\Programs\{#AppTitle}
DefaultGroupName={#AppTitle}
DisableDirPage=no
DisableProgramGroupPage=yes
UsePreviousAppDir=yes
UninstallDisplayIcon={app}\{#AppExe}
OutputDir=installer
OutputBaseFilename=IDM-By-Rashid-Setup
SetupIconFile=icons\app_icon.ico
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
WizardStyle=modern
CloseApplications=yes
RestartApplications=no
VersionInfoVersion=2.1.0.0
VersionInfoDescription=IDM By Rashid Windows Installer

[Tasks]
Name: "desktopicon"; Description: "Create desktop shortcut"; GroupDescription: "Shortcuts:"; Flags: unchecked

[Files]
; PyInstaller onedir output includes the internal Python interpreter and packages.
Source: "dist\IDM By Rashid\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion
; Microsoft official offline WebView2 Evergreen runtime; unpacked only for setup, not stored in app folder.
Source: "installer_assets\MicrosoftEdgeWebView2RuntimeInstallerX64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Icons]
Name: "{group}\{#AppTitle}"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"
Name: "{group}\Uninstall {#AppTitle}"; Filename: "{uninstallexe}"
Name: "{userdesktop}\{#AppTitle}"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
; Check both machine and user WebView2 registration. Skip on systems where it is already installed.
Filename: "{tmp}\MicrosoftEdgeWebView2RuntimeInstallerX64.exe"; Parameters: "/silent /install"; StatusMsg: "Setting up Microsoft WebView2 (only if missing)..."; Flags: runhidden waituntilterminated; Check: WebView2IsMissing
Filename: "{app}\{#AppExe}"; Description: "Launch {#AppTitle}"; Flags: postinstall nowait skipifsilent

[Code]
function WebView2IsMissing: Boolean;
var
  Version: String;
  Key: String;
  ExistsInUser: Boolean;
  ExistsInMachine: Boolean;
begin
  Key := 'Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}';
  ExistsInUser := RegQueryStringValue(HKCU, Key, 'pv', Version) and
    (Version <> '') and (Version <> '0.0.0.0');
  ExistsInMachine := RegQueryStringValue(HKLM32, Key, 'pv', Version) and
    (Version <> '') and (Version <> '0.0.0.0');
  Result := not (ExistsInUser or ExistsInMachine);
end;
