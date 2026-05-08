# setup.ps1 — Prepara o ambiente de compilação do 57 Agents
# Uso: .\setup.ps1  (PowerShell comum, sem necessidade de Admin)

$projectRoot  = $PSScriptRoot
$interfaceDir = Join-Path $projectRoot "interface"
$findVSFile   = Join-Path $interfaceDir "node_modules\@electron\node-gyp\lib\find-visualstudio.js"

Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   57 Agents — Setup                      ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── 1. Verificar Node.js / npm ──────────────────────────────────
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "[ERRO] npm não encontrado." -ForegroundColor Red
    Write-Host "       Instale o Node.js LTS em: https://nodejs.org" -ForegroundColor Gray
    exit 1
}
$nodeVer = node --version
$npmVer  = npm --version
Write-Host "Node.js $nodeVer  |  npm $npmVer" -ForegroundColor Gray

# ── 2. npm install (se node_modules ainda não existe) ───────────
$nodeModulesDir = Join-Path $interfaceDir "node_modules"
if (-not (Test-Path $nodeModulesDir)) {
    Write-Host ""
    Write-Host "Instalando dependências (npm install)..." -ForegroundColor Yellow
    Push-Location $interfaceDir
    npm install
    $installExit = $LASTEXITCODE
    Pop-Location
    if ($installExit -ne 0) {
        Write-Host "[ERRO] npm install falhou (código: $installExit)." -ForegroundColor Red
        exit 1
    }
}

# ── 3. Patch do node-gyp para suportar Visual Studio 2026 (v18) ─
# O node-gyp só reconhece VS até versão 17 (2022). O VS2026 tem
# versionMajor=18 e toolset v145 — adicionamos esses mapeamentos.
if (-not (Test-Path $findVSFile)) {
    Write-Host "[ERRO] $findVSFile não encontrado." -ForegroundColor Red
    Write-Host "       Execute 'npm install' em '$interfaceDir' e tente novamente." -ForegroundColor Gray
    exit 1
}

$content = Get-Content $findVSFile -Raw

if ($content -match 'versionMajor === 18') {
    Write-Host "Compatibilidade VS2026 já configurada. (patch anterior)" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "Aplicando compatibilidade com Visual Studio 2026..." -ForegroundColor Yellow

    # Detecta line ending do arquivo original (CRLF ou LF)
    $nl = if ($content -match "\r\n") { "`r`n" } else { "`n" }

    # Patch A: adicionar 2026 às listas [2019, 2022] usadas na detecção de VS
    $content = $content.Replace('[2019, 2022]', '[2019, 2022, 2026]')

    # Patch B: mapear versionMajor 18 → versionYear 2026 em getVersionInfo()
    $oldB = "    if (ret.versionMajor === 17) {${nl}      ret.versionYear = 2022${nl}      return ret${nl}    }"
    $newB = $oldB + "${nl}    if (ret.versionMajor === 18) {${nl}      ret.versionYear = 2026${nl}      return ret${nl}    }"
    $content = $content.Replace($oldB, $newB)

    # Patch C: retornar toolset v145 para versionYear 2026 em getToolset()
    $oldC = "    } else if (versionYear === 2022) {${nl}      return 'v143'${nl}    }"
    $newC = "    } else if (versionYear === 2022) {${nl}      return 'v143'${nl}    } else if (versionYear === 2026) {${nl}      return 'v145'${nl}    }"
    $content = $content.Replace($oldC, $newC)

    # Grava sem BOM (Node.js exige UTF-8 sem BOM)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($findVSFile, $content, $utf8NoBom)

    # Valida se os patches foram aplicados
    $verify = Get-Content $findVSFile -Raw
    if ($verify -match 'versionMajor === 18' -and $verify -match 'versionYear === 2026') {
        Write-Host "Patch aplicado com sucesso." -ForegroundColor Green
    } else {
        Write-Host "[AVISO] Patch pode não ter sido aplicado corretamente." -ForegroundColor Yellow
        Write-Host "        Verifique manualmente: $findVSFile" -ForegroundColor Gray
    }
}

# ── 4. Desativar exigência de Spectre-mitigated libraries ───────
# O VS18 BuildTools não inclui as libs Spectre por padrão.
#
# MSB8040 checa **item metadata** ClCompile->SpectreMitigation, não apenas
# a propriedade $(SpectreMitigation). Por isso precisamos de DOIS arquivos:
#   • Directory.Build.props  — importado ANTES do conteúdo do projeto
#   • Directory.Build.targets — importado DEPOIS; sobrescreve ItemDefinitionGroup
# Ambos são descobertos automaticamente pelo MSBuild ao subir de diretório.
$pkgDir        = Join-Path $interfaceDir "node_modules\@homebridge\node-pty-prebuilt-multiarch"
$spectreProp   = Join-Path $pkgDir "Directory.Build.props"
$spectreTarget = Join-Path $pkgDir "Directory.Build.targets"

$utf8NoBom = New-Object System.Text.UTF8Encoding $false

if (-not (Test-Path $spectreProp)) {
    Write-Host "Criando Directory.Build.props (desativa Spectre mitigation)..." -ForegroundColor Yellow
    $propsXml = @'
<Project>
  <PropertyGroup>
    <SpectreMitigation>false</SpectreMitigation>
  </PropertyGroup>
</Project>
'@
    [System.IO.File]::WriteAllText($spectreProp, $propsXml, $utf8NoBom)
    Write-Host "Directory.Build.props criado." -ForegroundColor Green
} else {
    Write-Host "Directory.Build.props ja existe." -ForegroundColor Gray
}

if (-not (Test-Path $spectreTarget)) {
    Write-Host "Criando Directory.Build.targets (sobrescreve item metadata)..." -ForegroundColor Yellow
    # ItemDefinitionGroup aqui sobrescreve qualquer <SpectreMitigation>Spectre</SpectreMitigation>
    # definido no proprio .vcxproj, pois .targets e importado APOS o conteudo do projeto.
    $targetsXml = @'
<Project>
  <PropertyGroup>
    <SpectreMitigation>false</SpectreMitigation>
  </PropertyGroup>
  <ItemDefinitionGroup>
    <ClCompile>
      <SpectreMitigation>false</SpectreMitigation>
    </ClCompile>
  </ItemDefinitionGroup>
</Project>
'@
    [System.IO.File]::WriteAllText($spectreTarget, $targetsXml, $utf8NoBom)
    Write-Host "Directory.Build.targets criado." -ForegroundColor Green
} else {
    Write-Host "Directory.Build.targets ja existe." -ForegroundColor Gray
}

# ── 5. Compilar módulo nativo (node-pty para Electron 28) ───────
Write-Host ""
Write-Host "Compilando módulo nativo (node-pty)..." -ForegroundColor Yellow
Write-Host ""

Push-Location $interfaceDir
npm run rebuild
$rebuildExit = $LASTEXITCODE
Pop-Location

# ── 6. Resultado ─────────────────────────────────────────────────
Write-Host ""
if ($rebuildExit -eq 0) {
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║   Setup concluído com sucesso!           ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximo passo: .\start-debug.ps1" -ForegroundColor Cyan
} else {
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║   Compilação falhou (código: $rebuildExit)  ║" -ForegroundColor Red
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possíveis causas:" -ForegroundColor Yellow
    Write-Host "  1. Nenhum Visual Studio Build Tools instalado" -ForegroundColor White
    Write-Host "     → https://visualstudio.microsoft.com/pt-br/visual-cpp-build-tools/" -ForegroundColor Gray
    Write-Host "  2. VS2022 sem componente 'Windows SDK'" -ForegroundColor White
    Write-Host "     → Abra 'Visual Studio Installer' › Modificar › adicionar Windows 11 SDK" -ForegroundColor Gray
    Write-Host "  3. VS2019 sem VC++ toolset" -ForegroundColor White
    Write-Host "     → Abra 'Visual Studio Installer' › Modificar › adicionar 'Desenvolvimento para desktop com C++'" -ForegroundColor Gray
    exit $rebuildExit
}
