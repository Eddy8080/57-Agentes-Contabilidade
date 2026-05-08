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

# ── 1. npm install ──────────────────────────────────────────
Write-Host "[1/3] Instalando dependencias..." -ForegroundColor Yellow
npm install --prefix $InterfaceDir
if ($LASTEXITCODE -ne 0) { Write-Error "npm install falhou"; exit 1 }

# ── 2. Empacotar com electron-builder --dir ─────────────────
Write-Host ""
Write-Host "[2/3] Empacotando com electron-builder (--dir)..." -ForegroundColor Yellow
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

# ── 3. Gerar 57agents.iss ───────────────────────────────────
Write-Host ""
Write-Host "[3/3] Gerando 57agents.iss..." -ForegroundColor Yellow

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
DefaultDirName={localappdata}\{#AppName}
DefaultGroupName={#AppName}
OutputDir=$DistDir
OutputBaseFilename=57AgentsContabilidade-Setup-v{#AppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=lowest
UninstallDisplayName={#AppName}

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar atalho na Area de Trabalho"; GroupDescription: "Icones adicionais:"; Flags: checkedonce

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}";           Filename: "{app}\{#AppExe}"
Name: "{group}\Desinstalar {#AppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}";     Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Description: "Iniciar {#AppName}"; Flags: nowait postinstall skipifsilent
"@

Set-Content -Path $IssFile -Value $issContent -Encoding UTF8
Write-Host "Gerado: $IssFile" -ForegroundColor Green

# ── Compilar com Inno Setup se instalado ────────────────────
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
    Write-Host "Inno Setup encontrado. Compilando instalador..." -ForegroundColor Yellow
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
