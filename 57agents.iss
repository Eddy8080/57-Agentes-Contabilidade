; ================================================================
;  57 Agents Contabilidade — Inno Setup Script
;  Gerado por build.ps1
; ================================================================

#define AppName      "57 Agents Contabilidade"
#define AppVersion   "1.0.0"
#define AppPublisher "Anagma"
#define AppExe       "57 Agents Contabilidade.exe"
#define SourceDir    "C:\Users\edilson.monteiro\Documents\projetos\57 Agents\dist\win-unpacked"

[Setup]
AppId={{9F3A1B7C-4E2D-4A8F-B6C5-1D3E7F9A2B4C}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL=https://anagma.com.br
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
OutputDir=C:\Users\edilson.monteiro\Documents\projetos\57 Agents\dist
OutputBaseFilename=57AgentsContabilidade-Setup-v{#AppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
WizardImageFile=C:\Users\edilson.monteiro\Documents\projetos\57 Agents\build\assets\banner.bmp
WizardSmallImageFile=C:\Users\edilson.monteiro\Documents\projetos\57 Agents\build\assets\logo_small.bmp
SetupIconFile=C:\Users\edilson.monteiro\Documents\projetos\57 Agents\build\assets\icon.ico
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
PrivilegesRequired=admin
UninstallDisplayName={#AppName}

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar atalho na Area de Trabalho"; GroupDescription: "Icones adicionais:"; Flags: checkedonce

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}";             Filename: "{app}\{#AppExe}"; IconFilename: "{app}\{#AppExe}"
Name: "{group}\Desinstalar {#AppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}";       Filename: "{app}\{#AppExe}"; IconFilename: "{app}\{#AppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Description: "Iniciar {#AppName}"; Flags: nowait postinstall skipifsilent
