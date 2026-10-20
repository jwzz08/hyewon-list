; Inno Setup script for hyewon_list — turns the plain `flutter build windows
; --release` output into a normal Windows installer (Start Menu shortcut,
; optional desktop shortcut, uninstaller registered in "Add or remove
; programs"), so friends/testers don't need Flutter installed and don't have
; to deal with a bare folder of exe+dlls.
;
; Requires Inno Setup (free): https://jrsoftware.org/isinfo.php
;
; Build steps:
;   1. flutter build windows --release
;      (must be run first — this script just packages whatever is already
;      in build\windows\x64\runner\Release)
;   2. Open this file in Inno Setup Compiler and click Compile,
;      OR from a command prompt with Inno Setup on PATH:
;        iscc windows\installer\hyewon_list.iss
;   3. The installer .exe is written to installer_output\ at the repo root
;      (gitignored — see .gitignore) — that file is what you upload to the
;      GitHub Release, not this script.
;
; AppId is a fixed GUID (generated once for this project) — it must stay
; the same across versions so a v1.0.1 installer recognizes and cleanly
; upgrades an existing v1.0.0 install (same install directory, same
; uninstall entry) instead of creating a second, parallel one.

#define MyAppName "hyewon_list"
#define MyAppVersion "1.0.2"
#define MyAppExeName "hyewon_list.exe"
#define MyAppPublisher "hyewon_list"

[Setup]
AppId={{B7E2B6B0-6E7A-4A3E-9E1B-5B7C3B7A9C21}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
; No admin rights required — installs to the current user's Program Files
; equivalent (autopf resolves per-user when elevation isn't available), so
; a friend who isn't a Windows admin on their own PC can still install it.
PrivilegesRequired=lowest
OutputDir=..\..\installer_output
OutputBaseFilename=hyewon_list_setup_{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupIconFile=..\runner\resources\app_icon.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional shortcuts:"

[Files]
; Everything flutter build windows produces — exe, the Flutter engine dll,
; plugin dlls (sqlite3, screen_retriever, etc.), and the data\ folder of
; bundled assets/ICU data. The whole folder is required; the exe alone
; will not launch.
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent

; Deliberately no [UninstallDelete] entry for the user's data folder
; (%LOCALAPPDATA%\hyewon_list) — uninstalling the program must never
; silently delete someone's tasks/events/settings. See database.dart's
; _resolveDbFile doc comment for where that data actually lives.
