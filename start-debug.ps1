# start-debug.ps1 — Inicia o 57 Agents e monitora o log em tempo real
# Uso: .\start-debug.ps1

$projectRoot  = $PSScriptRoot
$logFile      = Join-Path $projectRoot "57agents-debug.log"
$interfaceDir = Join-Path $projectRoot "interface"

Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   57 Agents — Debug Launcher             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Log em tempo real: $logFile" -ForegroundColor Yellow
Write-Host "Pressione Ctrl+C para encerrar." -ForegroundColor Gray
Write-Host ""

# Remove log anterior (main.js recriará com cabeçalho de sessão)
if (Test-Path $logFile) { Remove-Item $logFile -Force }

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Iniciando app..." -ForegroundColor Green
Write-Host ""

# & npm resolve automaticamente para npm.cmd no PATH
# 2>&1 faz stderr chegar como ErrorRecord — distinguível de stdout (string)
& npm start --prefix $interfaceDir 2>&1 | ForEach-Object {
    $ts = (Get-Date).ToString("HH:mm:ss.fff")
    if ($_ -is [System.Management.Automation.ErrorRecord]) {
        $line = "[$ts] [STDERR] $($_.Exception.Message)"
        Write-Host $line -ForegroundColor Red
    } else {
        $line = "[$ts] [STDOUT] $_"
        Write-Host $line -ForegroundColor White
    }
    Add-Content -Path $logFile -Value $line -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Processo encerrado (código: $LASTEXITCODE)" -ForegroundColor Yellow
Write-Host "Log completo salvo em: $logFile" -ForegroundColor Cyan
