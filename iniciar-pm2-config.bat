@echo off
echo ======================================================
echo  INICIANDO SISTEMA DE PEDIDOS COM PM2 (CONFIG)
echo ======================================================

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

:: Verificacao se o PM2 esta instalado globalmente
where pm2 >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] PM2 nao encontrado. Instalando PM2 globalmente...
    call npm install -g pm2
)

:: Parando todas as instancias anteriores (se existirem)
echo [4/5] Parando instancias anteriores...
call pm2 stop all 2>nul
call pm2 delete all 2>nul

:: Iniciando os serviços com PM2 usando o arquivo de configuração
echo [5/5] Iniciando servicos com PM2...
call pm2 start ecosystem.config.cjs

:: Salvando a configuração do PM2
echo Salvando configuracao do PM2...
call pm2 save

:: Exibindo status dos serviços
echo.
echo Status dos servicos:
call pm2 ls

echo.
echo ==============================================
echo        SISTEMA INICIADO COM SUCESSO!
echo ==============================================
echo Frontend: http://192.168.5.3:5173
echo Backend: http://192.168.5.3:8081
echo.
echo Para monitorar os servicos, execute: pm2 monit
echo Para encerrar os servicos, execute: pm2 stop all
echo.
pause 