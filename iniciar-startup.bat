@echo off
echo ======================================================
echo  CONFIGURANDO INICIALIZACAO AUTOMATICA DO SISTEMA
echo ======================================================

:: Obtendo o diretório atual (onde o sistema está instalado)
set SISTEMA_DIR=%~dp0
set SISTEMA_DIR=%SISTEMA_DIR:~0,-1%

echo Diretorio do sistema: %SISTEMA_DIR%

:: Criando o script de inicialização
echo @echo off > "%SISTEMA_DIR%\startup-service.bat"
echo cd /d "%SISTEMA_DIR%" >> "%SISTEMA_DIR%\startup-service.bat"
echo call iniciar-pm2.bat >> "%SISTEMA_DIR%\startup-service.bat"

:: Verificando se o PM2 está instalado globalmente
where pm2 >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] PM2 nao encontrado. Instalando PM2 globalmente...
    call npm install -g pm2
)

echo.
echo [1/2] Configurando PM2 para iniciar com o sistema...
:: Configura o PM2 para iniciar automaticamente com o Windows
call pm2 startup
call pm2 save

echo.
echo [2/2] Criando tarefa agendada no Windows...
:: Cria uma tarefa agendada no Windows para iniciar o sistema no login
SCHTASKS /CREATE /F /SC ONLOGON /TN "SistemaPedidos" /TR "%SISTEMA_DIR%\startup-service.bat" /RL HIGHEST

echo.
echo ==============================================
echo  CONFIGURACAO DE INICIALIZACAO AUTOMATICA CONCLUIDA!
echo ==============================================
echo.
echo O sistema agora sera iniciado automaticamente de duas formas:
echo.
echo 1. Com o PM2 configurado para iniciar com o Windows
echo 2. Com uma tarefa agendada para iniciar na inicializacao do Windows
echo.
echo Para testar, reinicie o computador e o sistema devera iniciar automaticamente.
echo.
pause 