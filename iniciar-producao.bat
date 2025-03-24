@echo off
setlocal enabledelayedexpansion

echo Iniciando sistema de pedidos em producao...

REM Define diretamente o caminho onde o projeto está na outra máquina
cd /d "C:\Users\app\Documents\Sistema-Pedidos\sistemapedidosproducao-main"

echo Diretorio atual: %CD%

REM Verifica se a estrutura do projeto é válida
if not exist "src" (
    echo Pasta src nao encontrada!
    pause
    exit /b 1
)

if not exist "backend" (
    echo Pasta backend nao encontrada!
    pause
    exit /b 1
)

REM Instala dependencias do frontend (que está na raiz)
echo Instalando dependencias do frontend...
if not exist "package.json" (
    echo Arquivo package.json nao encontrado para o frontend
    pause
    exit /b 1
)
call npm install
if %errorlevel% neq 0 (
    echo Erro ao instalar dependencias do frontend
    pause
    exit /b 1
)

REM Constrói o frontend para produção
echo Construindo frontend para producao...
call npm run build
if %errorlevel% neq 0 (
    echo Erro ao construir frontend
    pause
    exit /b 1
)

REM Instala dependencias do backend
echo Instalando dependencias do backend...
cd backend
if not exist "package.json" (
    echo Arquivo package.json nao encontrado no backend
    cd ..
    pause
    exit /b 1
)
call npm install
if %errorlevel% neq 0 (
    echo Erro ao instalar dependencias do backend
    cd ..
    pause
    exit /b 1
)

REM Volta para a raiz do projeto
cd ..

REM Cria o arquivo de configuração do PM2
echo Criando arquivo de configuracao do PM2...
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

REM Verifica se o PM2 está instalado
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

REM Instala o PM2 Windows Startup
echo Instalando PM2 Windows Startup...
call npm install -g pm2-windows-startup
if %errorlevel% neq 0 (
    echo Erro ao instalar pm2-windows-startup
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
echo Iniciando servicos...
call pm2 start ecosystem.config.cjs
if %errorlevel% neq 0 (
    echo Erro ao iniciar servicos com PM2
    pause
    exit /b 1
)

REM Salva a configuração
echo Salvando configuracao do PM2...
call pm2 save
if %errorlevel% neq 0 (
    echo Erro ao salvar configuracao do PM2
    pause
    exit /b 1
)

REM Configura o PM2 para iniciar com o Windows
echo Configurando PM2 para iniciar com Windows...
call pm2-startup install
if %errorlevel% neq 0 (
    echo Erro ao configurar inicializacao automatica
    echo Este erro pode ser ignorado se ja estiver configurado
)

REM Obtém o IP da máquina
echo Detectando IP da maquina...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set "IP=%%a"
    set "IP=!IP:~1!"
    goto :found_ip
)
:found_ip
if not defined IP set "IP=localhost"

echo.
echo Status dos servicos:
call pm2 status

echo.
echo Sistema iniciado com sucesso!
echo Frontend: http://!IP!:5173
echo Backend: http://!IP!:8081
echo.
echo Para ver os logs em tempo real: pm2 logs
echo Para parar os servicos: pm2 stop all
echo Para reiniciar os servicos: pm2 restart all
echo.
pause 