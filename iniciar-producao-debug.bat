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

REM Ajusta o arquivo vite.config.js para usar o endereço correto da API
echo Corrigindo configuração do Vite...
echo import { defineConfig } from 'vite';> vite.config.js
echo export default defineConfig({>> vite.config.js
echo   server: {>> vite.config.js
echo     host: '0.0.0.0',>> vite.config.js
echo     port: 5173>> vite.config.js
echo   },>> vite.config.js
echo   preview: {>> vite.config.js
echo     host: '0.0.0.0',>> vite.config.js
echo     port: 5173>> vite.config.js
echo   },>> vite.config.js
echo   define: {>> vite.config.js
echo     'process.env.VITE_API_URL': JSON.stringify('http://192.168.5.3:8081/api')>> vite.config.js
echo   }>> vite.config.js
echo });>> vite.config.js
echo Arquivo vite.config.js atualizado.

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
echo         VITE_API_URL: 'http://192.168.5.3:8081/api',>> ecosystem.config.cjs
echo         DEBUG: '*'>> ecosystem.config.cjs
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

REM Instalando dependências do frontend
echo Instalando dependências do frontend...
call npm install
if %errorlevel% neq 0 (
    echo Erro ao instalar dependências do frontend
    pause
    exit /b 1
)

REM Compilando o frontend
echo Compilando o frontend para produção...
call npm run build
if %errorlevel% neq 0 (
    echo Erro ao compilar o frontend
    pause
    exit /b 1
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
echo Frontend: http://192.168.5.3:5173
echo Backend: http://192.168.5.3:8081
echo.
echo Para ver os logs em tempo real do backend: pm2 logs sistema-pedidos-backend
echo.
echo Pressione qualquer tecla para ver os logs do backend...
pause > nul
call pm2 logs sistema-pedidos-backend 