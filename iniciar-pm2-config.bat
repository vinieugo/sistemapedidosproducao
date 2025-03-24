@echo off
echo Iniciando configuracao do sistema...

REM Verifica se o Node.js esta instalado
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo Node.js nao encontrado. Por favor, instale o Node.js primeiro.
    pause
    exit /b 1
)

REM Verifica se o npm esta instalado
where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo npm nao encontrado. Por favor, instale o npm primeiro.
    pause
    exit /b 1
)

REM Instala dependencias do frontend
echo Instalando dependencias do frontend...
cd frontend
call npm install
if %errorlevel% neq 0 (
    echo Erro ao instalar dependencias do frontend
    pause
    exit /b 1
)

REM Instala dependencias do backend
echo Instalando dependencias do backend...
cd ../backend
call npm install
if %errorlevel% neq 0 (
    echo Erro ao instalar dependencias do backend
    pause
    exit /b 1
)

REM Volta para a raiz do projeto
cd ..

REM Verifica se o PM2 esta instalado globalmente
echo Verificando instalacao do PM2...
call npm list -g pm2 >nul 2>nul
if %errorlevel% neq 0 (
    echo Instalando PM2 globalmente...
    call npm install -g pm2
    if %errorlevel% neq 0 (
        echo Erro ao instalar PM2
        pause
        exit /b 1
    )
)

REM Instala e configura o PM2-windows-startup
echo Configurando PM2 para iniciar com Windows...
call npm install -g pm2-windows-startup
if %errorlevel% neq 0 (
    echo Erro ao instalar pm2-windows-startup
    pause
    exit /b 1
)

REM Cria diretorio de logs se nao existir
if not exist "logs" mkdir logs
if not exist "frontend\logs" mkdir frontend\logs
if not exist "backend\logs" mkdir backend\logs

REM Para instancias anteriores do PM2
echo Parando instancias anteriores...
call pm2 stop all
call pm2 delete all

REM Inicia os servicos com PM2
echo Iniciando servicos...
call pm2 start ecosystem.config.cjs
if %errorlevel% neq 0 (
    echo Erro ao iniciar servicos com PM2
    pause
    exit /b 1
)

REM Salva a configuracao do PM2
echo Salvando configuracao do PM2...
call pm2 save
if %errorlevel% neq 0 (
    echo Erro ao salvar configuracao do PM2
    pause
    exit /b 1
)

REM Configura o PM2 para iniciar com Windows
echo Configurando PM2 para iniciar com Windows...
call pm2-startup install
if %errorlevel% neq 0 (
    echo Erro ao configurar PM2 para iniciar com Windows
    pause
    exit /b 1
)

REM Mostra o status dos servicos
echo.
echo Status dos servicos:
call pm2 status

echo.
echo Logs em tempo real (pressione Ctrl+C para parar):
call pm2 logs

echo.
echo Sistema iniciado com sucesso!
echo Frontend: http://192.168.5.3:5173
echo Backend: http://192.168.5.3:8081
echo.
echo Para parar os servicos, execute: pm2 stop all
echo Para reiniciar os servicos, execute: pm2 restart all
echo Para ver os logs, execute: pm2 logs
echo.
pause 