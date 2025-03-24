@echo off
echo ======================================================
echo  INICIANDO SISTEMA DE PEDIDOS COM PM2 (CONFIG)
echo ======================================================

:: Obtendo o IP da máquina
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set "IP=%%a"
    set "IP=!IP:~1!"
    goto :found_ip
)
:found_ip

:: Verificacao do Node.js
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Node.js nao encontrado. Por favor, instale o Node.js primeiro.
    pause
    exit /b 1
)

:: Verificacao do npm
where npm >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] npm nao encontrado. Por favor, instale o npm primeiro.
    pause
    exit /b 1
)

:: Instalacao de dependencias do frontend
echo [1/5] Instalando dependencias do frontend...
call npm install

:: Construcao do frontend para producao
echo [2/5] Construindo frontend para producao...
call npm run build

:: Instalacao de dependencias do backend
echo [3/5] Instalando dependencias do backend...
cd backend
call npm install
cd ..

:: Verificacao e instalacao do PM2
echo [4/5] Verificando instalacao do PM2...
call npm install -g pm2
call pm2 install pm2-windows-startup
call pm2-startup install

:: Criando pasta de logs se nao existir
if not exist "logs" mkdir logs
if not exist "backend\logs" mkdir backend\logs

:: Parando todas as instancias anteriores (se existirem)
echo [5/5] Parando instancias anteriores...
call pm2 stop all 2>nul
call pm2 delete all 2>nul
call pm2 flush

:: Iniciando os serviços com PM2 usando o arquivo de configuração
echo Iniciando servicos com PM2...
call pm2 start ecosystem.config.cjs

:: Salvando a configuração do PM2
echo Salvando configuracao do PM2...
call pm2 save

:: Exibindo status dos serviços
echo.
echo Status dos servicos:
call pm2 ls

:: Exibindo logs em tempo real
echo.
echo Exibindo logs em tempo real (pressione Ctrl+C para parar):
call pm2 logs --lines 100

echo.
echo ==============================================
echo        SISTEMA INICIADO COM SUCESSO!
echo ==============================================
echo Frontend: http://%IP%:5173
echo Backend: http://%IP%:8081
echo.
echo Para monitorar os servicos, execute: pm2 monit
echo Para encerrar os servicos, execute: pm2 stop all
echo.
echo Logs disponiveis em:
echo - Frontend: ./logs/frontend-error.log e ./logs/frontend-out.log
echo - Backend: ./logs/backend-error.log e ./logs/backend-out.log
echo.
pause 