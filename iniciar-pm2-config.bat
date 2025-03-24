@echo off
setlocal enabledelayedexpansion

echo Iniciando configuracao do sistema...

REM Detectando a estrutura de diretórios
if exist "frontend" (
    set "FRONTEND_DIR=frontend"
) else if exist "sistemapedidosproducao-main\frontend" (
    set "FRONTEND_DIR=sistemapedidosproducao-main\frontend"
    set "BACKEND_DIR=sistemapedidosproducao-main\backend"
) else (
    echo Estrutura de diretórios não reconhecida!
    echo Por favor, execute este script no diretório raiz do projeto.
    echo Diretórios esperados:
    echo - frontend/
    echo - backend/
    echo ou
    echo - sistemapedidosproducao-main/frontend/
    echo - sistemapedidosproducao-main/backend/
    pause
    exit /b 1
)

REM Se BACKEND_DIR não foi definido, assume-se que estamos na raiz
if not defined BACKEND_DIR (
    set "BACKEND_DIR=backend"
)

echo Estrutura detectada:
echo Frontend: !FRONTEND_DIR!
echo Backend: !BACKEND_DIR!

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
cd !FRONTEND_DIR!
if not exist "package.json" (
    echo Arquivo package.json nao encontrado em !FRONTEND_DIR!
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
cd ..\!BACKEND_DIR!
if not exist "package.json" (
    echo Arquivo package.json nao encontrado em !BACKEND_DIR!
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

REM Atualiza o arquivo ecosystem.config.cjs com os caminhos corretos
echo Atualizando configuracoes do PM2...
echo module.exports = {> ecosystem.config.cjs
echo   apps: [>> ecosystem.config.cjs
echo     {>> ecosystem.config.cjs
echo       name: 'sistema-pedidos-frontend',>> ecosystem.config.cjs
echo       script: 'node',>> ecosystem.config.cjs
echo       args: 'node_modules/vite/bin/vite.js preview',>> ecosystem.config.cjs
echo       cwd: './!FRONTEND_DIR!',>> ecosystem.config.cjs
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
echo       cwd: './!BACKEND_DIR!',>> ecosystem.config.cjs
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
if not exist "!FRONTEND_DIR!\logs" mkdir "!FRONTEND_DIR!\logs"
if not exist "!BACKEND_DIR!\logs" mkdir "!BACKEND_DIR!\logs"

REM Para instancias anteriores do PM2
echo Parando instancias anteriores...
call pm2 stop all 2>nul
call pm2 delete all 2>nul

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

REM Obtém o endereço IP da máquina
echo Detectando endereco IP da maquina...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set "IP=%%a"
    set "IP=!IP:~1!"
    goto :found_ip
)
:found_ip
if not defined IP set "IP=localhost"

REM Mostra o status dos servicos
echo.
echo Status dos servicos:
call pm2 status

echo.
echo Logs em tempo real (pressione Ctrl+C para parar):
call pm2 logs

echo.
echo Sistema iniciado com sucesso!
echo Frontend: http://!IP!:5173
echo Backend: http://!IP!:8081
echo.
echo Para parar os servicos, execute: pm2 stop all
echo Para reiniciar os servicos, execute: pm2 restart all
echo Para ver os logs, execute: pm2 logs
echo.
pause 