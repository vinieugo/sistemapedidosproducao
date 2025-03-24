@echo off
setlocal enabledelayedexpansion

echo Iniciando sistema de pedidos em modo DEBUG...

REM Define diretamente o caminho onde o projeto está
cd /d "C:\Users\app\Documents\Sistema-Pedidos\sistemapedidosproducao-main"

echo Diretorio atual: %CD%

REM Verifica problemas com o backend
echo Verificando logs do backend...
if exist "logs\backend-error.log" (
    echo --- Últimas 50 linhas do log de erro do backend ---
    type logs\backend-error.log | findstr /n "." | findstr /r "^[1-9][0-9][0-9]:" > nul 2>&1
    if !errorlevel! equ 0 (
        for /f "skip=100 delims=" %%i in (logs\backend-error.log) do echo %%i
    ) else (
        type logs\backend-error.log
    )
)

REM Verifica se o .env do backend existe
cd backend
echo.
echo Verificando arquivo .env do backend...
if exist ".env" (
    echo Arquivo .env encontrado:
    type .env
) else (
    echo AVISO: Arquivo .env não encontrado no backend!
    echo Criando arquivo .env básico...
    echo DATABASE_URL="mysql://root:@localhost:3306/sistema_pedidos" > .env
    echo PORT=8081 >> .env
    echo HOST=0.0.0.0 >> .env
)
cd ..

REM Atualiza o arquivo ecosystem.config.cjs para incluir mais logs
echo Criando arquivo de configuracao do PM2 com mais logs...
echo module.exports = {> ecosystem.config.cjs
echo   apps: [>> ecosystem.config.cjs
echo     {>> ecosystem.config.cjs
echo       name: 'sistema-pedidos-frontend',>> ecosystem.config.cjs
echo       script: 'node',>> ecosystem.config.cjs
echo       args: 'node_modules/vite/bin/vite.js preview',>> ecosystem.config.cjs
echo       cwd: './',>> ecosystem.config.cjs
echo       env: {>> ecosystem.config.cjs
echo         NODE_ENV: 'production',>> ecosystem.config.cjs
echo         HOST: '0.0.0.0',>> ecosystem.config.cjs
echo         PORT: 5173,>> ecosystem.config.cjs
echo         DEBUG: '*',>> ecosystem.config.cjs
echo         VITE_API_URL: 'http://192.168.5.3:8081/api'>> ecosystem.config.cjs
echo       },>> ecosystem.config.cjs
echo       log_date_format: 'YYYY-MM-DD HH:mm:ss',>> ecosystem.config.cjs
echo       merge_logs: true,>> ecosystem.config.cjs
echo       log_type: 'json',>> ecosystem.config.cjs
echo       error_file: './logs/frontend-error.log',>> ecosystem.config.cjs
echo       out_file: './logs/frontend-out.log',>> ecosystem.config.cjs
echo       max_restarts: 5,>> ecosystem.config.cjs
echo       min_uptime: '5s',>> ecosystem.config.cjs
echo       watch: false,>> ecosystem.config.cjs
echo       autorestart: true,>> ecosystem.config.cjs
echo       exp_backoff_restart_delay: 100>> ecosystem.config.cjs
echo     },>> ecosystem.config.cjs
echo     {>> ecosystem.config.cjs
echo       name: 'sistema-pedidos-backend',>> ecosystem.config.cjs
echo       script: 'node',>> ecosystem.config.cjs
echo       args: 'src/server.js',>> ecosystem.config.cjs
echo       cwd: './backend',>> ecosystem.config.cjs
echo       env: {>> ecosystem.config.cjs
echo         NODE_ENV: 'production',>> ecosystem.config.cjs
echo         HOST: '0.0.0.0',>> ecosystem.config.cjs
echo         PORT: 8081,>> ecosystem.config.cjs
echo         DATABASE_URL: 'mysql://root:@localhost:3306/sistema_pedidos',>> ecosystem.config.cjs
echo         DEBUG: '*'>> ecosystem.config.cjs
echo       },>> ecosystem.config.cjs
echo       log_date_format: 'YYYY-MM-DD HH:mm:ss',>> ecosystem.config.cjs
echo       merge_logs: true,>> ecosystem.config.cjs
echo       log_type: 'json',>> ecosystem.config.cjs
echo       error_file: './logs/backend-error.log',>> ecosystem.config.cjs
echo       out_file: './logs/backend-out.log',>> ecosystem.config.cjs
echo       max_restarts: 5,>> ecosystem.config.cjs
echo       min_uptime: '5s',>> ecosystem.config.cjs
echo       watch: false,>> ecosystem.config.cjs
echo       autorestart: true,>> ecosystem.config.cjs
echo       exp_backoff_restart_delay: 100>> ecosystem.config.cjs
echo     }>> ecosystem.config.cjs
echo   ]>> ecosystem.config.cjs
echo };>> ecosystem.config.cjs

REM Ajusta o arquivo vite.config.js para usar o endereço correto da API
echo Verificando configuração do Vite...
if exist "vite.config.js" (
    echo // Arquivo de configuração do Vite> vite.config.temp.js
    echo import { defineConfig } from 'vite';>> vite.config.temp.js
    echo export default defineConfig({>> vite.config.temp.js
    echo   server: {>> vite.config.temp.js
    echo     host: '0.0.0.0',>> vite.config.temp.js
    echo     port: 5173,>> vite.config.temp.js
    echo   },>> vite.config.temp.js
    echo   preview: {>> vite.config.temp.js
    echo     host: '0.0.0.0',>> vite.config.temp.js
    echo     port: 5173,>> vite.config.temp.js
    echo   },>> vite.config.temp.js
    echo   define: {>> vite.config.temp.js
    echo     'process.env.VITE_API_URL': JSON.stringify('http://192.168.5.3:8081/api'),>> vite.config.temp.js
    echo   }>> vite.config.temp.js
    echo });>> vite.config.temp.js
    move /y vite.config.temp.js vite.config.js
    echo Arquivo vite.config.js atualizado.
)

REM Cria diretório de logs se não existir
if not exist "logs" mkdir logs
if not exist "backend\logs" mkdir backend\logs

REM Para instâncias anteriores do PM2
echo Parando instancias anteriores...
call pm2 stop all 2>nul
call pm2 delete all 2>nul

REM Inicia os serviços
echo Iniciando servicos em modo DEBUG...
call pm2 start ecosystem.config.cjs
if %errorlevel% neq 0 (
    echo Erro ao iniciar servicos com PM2
    pause
    exit /b 1
)

echo.
echo Sistema iniciado em modo DEBUG
echo.
echo Para ver os logs em tempo real do backend: pm2 logs sistema-pedidos-backend
echo.
echo Pressione qualquer tecla para ver os logs do backend...
pause > nul
call pm2 logs sistema-pedidos-backend 