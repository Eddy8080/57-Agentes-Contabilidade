<#
.SYNOPSIS
    Build — 57 Agents Contabilidade
    Empacota o app Electron (--dir) e gera 57agents.iss para Inno Setup
.USAGE
    .\build.ps1
#>

$ErrorActionPreference = "Stop"

$Root         = $PSScriptRoot
$InterfaceDir = Join-Path $Root "interface"
$DistDir      = Join-Path $Root "dist"
$IssFile      = Join-Path $Root "57agents.iss"

$AppName      = "57 Agents Contabilidade"
$AppVersion   = "1.0.0"
$AppPublisher = "Anagma"
$AppExe       = "$AppName.exe"

Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  57 Agents Contabilidade - Build               " -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# ── 0. Gerar icone se nao existir ───────────────────────────
$IconIco      = Join-Path $Root "build\assets\icon.ico"
$IconScript   = Join-Path $Root "build\generate-icon.py"
if (-not (Test-Path $IconIco)) {
    if (Test-Path $IconScript) {
        Write-Host "[0/4] Gerando icone (build\assets\icon.ico)..." -ForegroundColor Yellow
        python $IconScript
        if ($LASTEXITCODE -ne 0) { Write-Warning "Falha ao gerar icone — build continua sem ele." }
    } else {
        Write-Warning "icon.ico nao encontrado e generate-icon.py ausente — build continua sem icone."
    }
}

# ── 1. npm install ──────────────────────────────────────────
Write-Host "[1/4] Instalando dependencias..." -ForegroundColor Yellow
npm install --prefix $InterfaceDir
if ($LASTEXITCODE -ne 0) { Write-Error "npm install falhou"; exit 1 }

# Verifica binario nativo do node-pty (deve ser compilado antes do build)
$PtyBinary = Join-Path $InterfaceDir "node_modules\@homebridge\node-pty-prebuilt-multiarch\build\Release\pty.node"
if (-not (Test-Path $PtyBinary)) {
    Write-Host ""
    Write-Host "ERRO: pty.node nao encontrado." -ForegroundColor Red
    Write-Host "Execute primeiro:" -ForegroundColor Yellow
    Write-Host "  interface\rebuild-native.bat" -ForegroundColor White
    Write-Host "Depois rode .\build.ps1 novamente." -ForegroundColor Yellow
    exit 1
}
Write-Host "Binario nativo pty.node: OK" -ForegroundColor Green

# ── 2. Empacotar com electron-builder --dir ─────────────────
Write-Host ""
Write-Host "[2/4] Empacotando com electron-builder (--dir)..." -ForegroundColor Yellow
npm run build:dir --prefix $InterfaceDir
if ($LASTEXITCODE -ne 0) { Write-Error "electron-builder falhou"; exit 1 }

# Localiza o diretorio desempacotado (win-unpacked ou win-x64-unpacked)
$UnpackedDir = @(
    (Join-Path $DistDir "win-unpacked"),
    (Join-Path $DistDir "win-x64-unpacked")
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $UnpackedDir) {
    Write-Error "Diretorio desempacotado nao encontrado em $DistDir apos o build"
    exit 1
}
Write-Host "App empacotado em: $UnpackedDir" -ForegroundColor Green

# ── Assets visuais do Inno Setup ────────────────────────────
$BannerBmp    = Join-Path $Root "build\assets\banner.bmp"
$LogoSmallBmp = Join-Path $Root "build\assets\logo_small.bmp"
if (-not (Test-Path $BannerBmp))    { Write-Warning "banner.bmp nao encontrado em build\assets\ — WizardImageFile sera omitido do .iss" }
if (-not (Test-Path $LogoSmallBmp)) { Write-Warning "logo_small.bmp nao encontrado em build\assets\ — WizardSmallImageFile sera omitido do .iss" }

$wizardImageLine      = if (Test-Path $BannerBmp)    { "WizardImageFile=$BannerBmp" }       else { "" }
$wizardSmallImageLine = if (Test-Path $LogoSmallBmp) { "WizardSmallImageFile=$LogoSmallBmp" } else { "" }
$setupIconLine        = if (Test-Path $IconIco)       { "SetupIconFile=$IconIco" }            else { "" }

# ── 3. Gerar 57agents.iss ───────────────────────────────────
Write-Host ""
Write-Host "[3/4] Gerando 57agents.iss..." -ForegroundColor Yellow

$issContent = @"
; ================================================================
;  57 Agents Contabilidade — Inno Setup Script
;  Gerado por build.ps1
; ================================================================

#define AppName      "$AppName"
#define AppVersion   "$AppVersion"
#define AppPublisher "$AppPublisher"
#define AppExe       "$AppExe"
#define SourceDir    "$UnpackedDir"

[Setup]
AppId={{9F3A1B7C-4E2D-4A8F-B6C5-1D3E7F9A2B4C}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL=https://anagma.com.br
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
OutputDir=$DistDir
OutputBaseFilename=57AgentsContabilidade-Setup-v{#AppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
$wizardImageLine
$wizardSmallImageLine
$setupIconLine
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
"@

Set-Content -Path $IssFile -Value $issContent -Encoding UTF8
Write-Host "Gerado: $IssFile" -ForegroundColor Green

# ── 4. Compilar com Inno Setup se instalado ─────────────────
$iscc = (Get-Command iscc -ErrorAction SilentlyContinue)?.Source
$isccPaths = @(
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe",
    "C:\Program Files (x86)\Inno Setup 5\ISCC.exe",
    "C:\Program Files\Inno Setup 5\ISCC.exe"
)
foreach ($p in $isccPaths) {
    if (-not $iscc -and (Test-Path $p)) { $iscc = $p; break }
}

Write-Host ""
if ($iscc) {
    Write-Host "[4/4] Compilando instalador com Inno Setup..." -ForegroundColor Yellow
    & $iscc $IssFile
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "Instalador gerado em: $DistDir" -ForegroundColor Green
    } else {
        Write-Warning "ISCC retornou erro — verifique o .iss manualmente."
    }
} else {
    Write-Host "Inno Setup nao instalado. Para gerar o .exe instalador:" -ForegroundColor Yellow
    Write-Host "  1. Baixe: https://jrsoftware.org/isdl.php" -ForegroundColor White
    Write-Host "  2. Execute no terminal:" -ForegroundColor White
    Write-Host "       ISCC.exe `"$IssFile`"" -ForegroundColor Gray
    Write-Host "     ou abra 57agents.iss no Inno Setup IDE e pressione F9." -ForegroundColor White
}

Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  Concluido!" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""
