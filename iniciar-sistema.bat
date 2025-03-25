@echo off
setlocal enabledelayedexpansion

echo =============================================================
echo      INICIANDO SISTEMA DE PEDIDOS - PRODUCAO
echo =============================================================

REM Verifica privilégios de administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo AVISO: Este script deve ser executado como Administrador
    echo       para evitar problemas de permissao.
    echo.
    echo Para executar como Administrador:
    echo 1. Clique com o botao direito no arquivo
    echo 2. Selecione "Executar como administrador"
    echo.
    pause
    exit /b 1
)

REM Define o diretório do projeto
cd /d "C:\Users\app\Documents\Sistema-Pedidos\sistemapedidosproducao-main"
echo Diretorio atual: %CD%

REM Obtém o IP da máquina
echo Detectando IP da maquina...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set "IP=%%a"
    set "IP=!IP:~1!"
    goto :found_ip
)
:found_ip
if not defined IP set "IP=192.168.5.3"
echo IP detectado: !IP!
echo.

REM Para processos anteriores
echo Parando servicos anteriores...
taskkill /f /im node.exe >nul 2>&1
call pm2 stop all 2>nul
call pm2 delete all 2>nul
timeout /t 3 >nul

REM Configuração do Backend
echo =============================================================
echo      CONFIGURANDO BACKEND
echo =============================================================
cd backend

REM Configura o arquivo .env
echo Configurando banco de dados...
echo DATABASE_URL="mysql://root:@192.168.5.3:3306/sistema_pedidos" > .env
echo PORT=8081 >> .env
echo HOST=0.0.0.0 >> .env

REM Limpa e reinstala as dependências
echo Instalando dependencias do backend...
if exist "node_modules" rmdir /s /q node_modules
if exist "package-lock.json" del package-lock.json

REM Instala primeiro os pacotes principais sem o Prisma
echo Instalando pacotes principais...
call npm install express cors dotenv mysql2 --no-save --force

REM Instala o Prisma separadamente
echo Instalando Prisma...
call npm install prisma @prisma/client --save-dev --force

REM Gera o cliente Prisma
echo Gerando cliente Prisma...
call npx prisma generate

cd ..

REM Configuração do Frontend
echo =============================================================
echo      CONFIGURANDO FRONTEND
echo =============================================================

REM Configura o Vite
echo Configurando Vite...
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
echo     'process.env.VITE_API_URL': JSON.stringify('http://!IP!:8081/api')>> vite.config.js
echo   }>> vite.config.js
echo });>> vite.config.js

REM Compila o frontend
echo Compilando frontend...
if exist "node_modules" rmdir /s /q node_modules
if exist "package-lock.json" del package-lock.json
call npm install --force
call npm run build

REM Configuração do PM2
echo =============================================================
echo      CONFIGURANDO PM2
echo =============================================================

REM Cria diretórios de logs
if not exist "logs" mkdir logs
if not exist "backend\logs" mkdir backend\logs

REM Configura o PM2
echo Configurando PM2...
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
echo         VITE_API_URL: 'http://!IP!:8081/api'>> ecosystem.config.cjs
echo       },>> ecosystem.config.cjs
echo       log_date_format: 'YYYY-MM-DD HH:mm:ss',>> ecosystem.config.cjs
echo       merge_logs: true,>> ecosystem.config.cjs
echo       log_type: 'json',>> ecosystem.config.cjs
echo       error_file: './logs/frontend-error.log',>> ecosystem.config.cjs
echo       out_file: './logs/frontend-out.log',>> ecosystem.config.cjs
echo       max_restarts: 10,>> ecosystem.config.cjs
echo       min_uptime: '10s',>> ecosystem.config.cjs
echo       watch: false,>> ecosystem.config.cjs
echo       autorestart: true>> ecosystem.config.cjs
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
echo         DATABASE_URL: 'mysql://root:@192.168.5.3:3306/sistema_pedidos'>> ecosystem.config.cjs
echo       },>> ecosystem.config.cjs
echo       log_date_format: 'YYYY-MM-DD HH:mm:ss',>> ecosystem.config.cjs
echo       merge_logs: true,>> ecosystem.config.cjs
echo       log_type: 'json',>> ecosystem.config.cjs
echo       error_file: './logs/backend-error.log',>> ecosystem.config.cjs
echo       out_file: './logs/backend-out.log',>> ecosystem.config.cjs
echo       max_restarts: 10,>> ecosystem.config.cjs
echo       min_uptime: '10s',>> ecosystem.config.cjs
echo       watch: false,>> ecosystem.config.cjs
echo       autorestart: true>> ecosystem.config.cjs
echo     }>> ecosystem.config.cjs
echo   ]>> ecosystem.config.cjs
echo };>> ecosystem.config.cjs

REM Instala o PM2 se necessário
where pm2 >nul 2>&1
if %errorlevel% neq 0 (
    echo Instalando PM2...
    call npm install -g pm2 --force
)

REM Inicia os serviços
echo =============================================================
echo      INICIANDO SERVIÇOS
echo =============================================================
call pm2 start ecosystem.config.cjs
call pm2 save

REM Resumo
echo.
echo =============================================================
echo      SISTEMA INICIADO COM SUCESSO!
echo =============================================================
echo.
echo Status dos serviços:
call pm2 status
echo.
echo Frontend: http://!IP!:5173
echo Backend:  http://!IP!:8081
echo.
echo Logs do Frontend: logs/frontend-out.log
echo Logs do Backend:  backend/logs/backend-out.log
echo.
echo Comandos úteis:
echo - Ver status:     pm2 status
echo - Ver logs:       pm2 logs
echo - Reiniciar:      pm2 restart all
echo - Parar:          pm2 stop all
echo.
echo =============================================================
echo.
pause 