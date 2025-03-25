@echo off
setlocal enabledelayedexpansion

echo =============================================================
echo      INICIANDO SISTEMA DE PEDIDOS - PRODUCAO
echo      (Execute como administrador para evitar erros)
echo =============================================================

REM Verifica privilégios de administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo AVISO: Este script deveria ser executado como Administrador
    echo       para evitar problemas de permissao.
    echo.
    echo Para executar como Administrador:
    echo 1. Clique com o botao direito no arquivo
    echo 2. Selecione "Executar como administrador"
    echo.
    echo Deseja continuar mesmo assim? (S/N)
    set /p continuar=
    if /i "!continuar!" neq "S" exit /b 1
)

REM Define diretamente o caminho onde o projeto está
cd /d "C:\Users\app\Documents\Sistema-Pedidos\sistemapedidosproducao-main"

echo Diretorio atual: %CD%

REM Obtém o endereço IP da máquina
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

REM Para instâncias anteriores do PM2
echo Parando servicos anteriores...
call pm2 stop all 2>nul
call pm2 delete all 2>nul
taskkill /f /im node.exe >nul 2>&1

echo Aguardando liberacao de recursos...
timeout /t 3 >nul

REM Configurando o backend
echo =============================================================
echo      CONFIGURANDO BACKEND
echo =============================================================
cd backend

REM Configurando o arquivo .env do backend
echo Configurando banco de dados...
echo DATABASE_URL="mysql://root:@192.168.5.3:3306/sistema_pedidos" > .env
echo PORT=8081 >> .env
echo HOST=0.0.0.0 >> .env
echo Arquivo .env criado com sucesso.

REM Verifica se o node_modules existe mas sem tentar removê-lo
if not exist "node_modules" (
    mkdir node_modules 2>nul
) else (
    echo Node modules ja existe, sera utilizado.
)

REM Instala os pacotes principais diretamente
echo Instalando pacotes essenciais do backend...
call npm install express cors dotenv mysql2 @prisma/client --no-save
if %errorlevel% neq 0 (
    echo AVISO: Alguns pacotes podem nao ter sido instalados corretamente.
    echo        O sistema tentara funcionar com os pacotes existentes.
)

cd ..

REM Configurando o frontend
echo =============================================================
echo      CONFIGURANDO FRONTEND
echo =============================================================

REM Ajusta o arquivo vite.config.js para usar o endereço correto da API
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
echo Arquivo vite.config.js configurado com sucesso.

REM Verifica se já existe uma build, se sim, pula a compilação
if exist "dist" (
    echo Build do frontend encontrada, pulando compilacao...
) else (
    REM Verifica se o node_modules existe
    if not exist "node_modules" (
        echo Instalando dependencias do frontend...
        call npm install
        if %errorlevel% neq 0 (
            echo Erro ao instalar dependencias do frontend.
            echo Tentando com os modulos existentes...
        )
    )

    REM Compilando o frontend
    echo Compilando frontend para producao...
    call npm run build
    if %errorlevel% neq 0 (
        echo Erro ao compilar o frontend.
        pause
        exit /b 1
    )
)

REM Configurando PM2
echo =============================================================
echo      CONFIGURANDO PM2
echo =============================================================

REM Atualiza o arquivo ecosystem.config.cjs
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
echo Arquivo ecosystem.config.cjs configurado com sucesso.

REM Cria diretórios de logs
if not exist "logs" mkdir logs
if not exist "backend\logs" mkdir backend\logs

REM Verifica se o PM2 está instalado
where pm2 >nul 2>&1
if %errorlevel% neq 0 (
    echo Instalando PM2...
    call npm install -g pm2
    if %errorlevel% neq 0 (
        echo Erro ao instalar PM2.
        pause
        exit /b 1
    )
)

REM Inicia os serviços
echo =============================================================
echo      INICIANDO SERVIÇOS
echo =============================================================
call pm2 start ecosystem.config.cjs
if %errorlevel% neq 0 (
    echo Erro ao iniciar os serviços.
    pause
    exit /b 1
)

REM Salva a configuração do PM2
echo Salvando configuração do PM2...
call pm2 save
if %errorlevel% neq 0 (
    echo Aviso: Não foi possível salvar a configuração do PM2.
)

REM Tenta configurar o startup (silenciosamente)
call pm2-startup install >nul 2>&1

REM Resumo do sistema
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