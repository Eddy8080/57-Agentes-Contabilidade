@echo off
:: ============================================================
:: rebuild-native.bat — Recompila node-pty para Windows
:: Necessário quando: trocar versão do Electron, trocar de máquina,
:: ou após npm install em ambiente sem prebuild Windows.
::
:: Pré-requisitos: VS2026 BuildTools + Windows SDK 10.0.26100.0
:: ============================================================

set SCRIPT_DIR=%~dp0
set MODULE_DIR=%SCRIPT_DIR%node_modules\@homebridge\node-pty-prebuilt-multiarch
set NODE_GYPO=%SCRIPT_DIR%node_modules\@electron\node-gyp\bin\node-gyp.js
set NODE_MODULES=%SCRIPT_DIR%node_modules

:: Cria diretório temporário sem espaço para o build
set TMP_BUILD=C:\57tmp-pty-build

if exist "%TMP_BUILD%" rmdir /s /q "%TMP_BUILD%"
xcopy /E /I /Q "%MODULE_DIR%" "%TMP_BUILD%" >nul 2>&1
if errorlevel 1 (
    echo ERRO: Nao foi possivel copiar o modulo para %TMP_BUILD%
    exit /b 1
)

:: Copia binding.gyp com correção para VS2026
copy /Y "%MODULE_DIR%\binding.gyp" "%TMP_BUILD%\binding.gyp" >nul

:: Aplica patch no winpty.gyp (GetCommitHash.bat precisa de .\)
powershell -Command "(Get-Content '%TMP_BUILD%\deps\winpty\src\winpty.gyp') -replace 'GetCommitHash.bat', '.\GetCommitHash.bat' -replace 'UpdateGenVersion.bat', '.\UpdateGenVersion.bat' | Set-Content '%TMP_BUILD%\deps\winpty\src\winpty.gyp'"

:: Configura o ambiente VS2026
call "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64 >nul 2>&1
if errorlevel 1 (
    echo ERRO: VS2026 BuildTools nao encontrado
    echo Instale: https://aka.ms/vs/18/release/vs_buildtools.exe
    exit /b 1
)

:: Compila
set NODE_PATH=%NODE_MODULES%
cd /d "%TMP_BUILD%"
node "%NODE_GYPO%" rebuild --target=28.3.3 --arch=x64 --dist-url=https://www.electronjs.org/headers
if errorlevel 1 (
    echo ERRO: Compilacao falhou
    cd /d "%SCRIPT_DIR%"
    exit /b 1
)

:: Copia resultado para o projeto
set DEST=%MODULE_DIR%\build\Release
if not exist "%DEST%" mkdir "%DEST%"
copy /Y "%TMP_BUILD%\build\Release\*.node" "%DEST%" >nul
copy /Y "%TMP_BUILD%\build\Release\winpty.dll" "%DEST%" >nul
copy /Y "%TMP_BUILD%\build\Release\winpty-agent.exe" "%DEST%" >nul

cd /d "%SCRIPT_DIR%"
echo.
echo Compilacao concluida com sucesso!
echo Binarios em: %DEST%
