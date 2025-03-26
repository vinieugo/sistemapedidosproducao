@echo off
setlocal enabledelayedexpansion
echo Iniciando sistema de pedidos...
echo.

REM Verifica se está rodando como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Este script precisa ser executado como Administrador!
    echo Clique com o botão direito e selecione "Executar como administrador"
    pause
    exit /b 1
)

REM Define o diretório do projeto
set "PROJECT_ROOT=C:\Users\app\Documents\Sistema-Pedidos\sistemapedidosproducao-main"
cd /d "%PROJECT_ROOT%"
echo Diretório atual: %CD%

REM Verifica se as pastas existem
if not exist "backend" (
    echo Erro: Pasta backend não encontrada em %CD%
    echo Certifique-se de que o script está na pasta raiz do projeto
    pause
    exit /b 1
)

if not exist "frontend" (
    echo Erro: Pasta frontend não encontrada em %CD%
    echo Certifique-se de que o script está na pasta raiz do projeto
    pause
    exit /b 1
)

REM Configura o IP da máquina
set "IP=192.168.5.3"

REM Cria diretório de logs se não existir
if not exist "logs" mkdir "logs"

REM Cria arquivo .env para o backend
echo DATABASE_URL="mysql://root:@%IP%:3307/sistema_pedidos" > "backend\.env"
echo PORT=8081 >> "backend\.env"
echo HOST="%IP%" >> "backend\.env"
echo DEBUG="prisma:*" >> "backend\.env"
echo LOG_LEVEL="debug" >> "backend\.env"
echo CORS_ORIGIN="*" >> "backend\.env"

REM Instala dependências do backend
echo Instalando dependências do backend...
cd backend
call npm install express cors dotenv mysql2 --save
call npm install -g pm2 --force
cd ..

REM Instala dependências do frontend
echo Instalando dependências do frontend...
cd frontend
call npm install
call npm run build
cd ..

REM Configura o frontend para usar o IP correto
echo Configurando frontend...
if exist "frontend\vite.config.js" (
    powershell -Command "(Get-Content 'frontend\vite.config.js') -replace 'localhost', '%IP%' | Set-Content 'frontend\vite.config.js'"
) else (
    echo Arquivo vite.config.js não encontrado. Criando novo...
    echo import { defineConfig } from 'vite' > "frontend\vite.config.js"
    echo import react from '@vitejs/plugin-react' >> "frontend\vite.config.js"
    echo. >> "frontend\vite.config.js"
    echo export default defineConfig({ >> "frontend\vite.config.js"
    echo   plugins: [react()], >> "frontend\vite.config.js"
    echo   server: { >> "frontend\vite.config.js"
    echo     host: '%IP%', >> "frontend\vite.config.js"
    echo     port: 5173 >> "frontend\vite.config.js"
    echo   } >> "frontend\vite.config.js"
    echo }) >> "frontend\vite.config.js"
)

REM Verifica se o PM2 está instalado
where pm2 >nul 2>&1
if %errorLevel% neq 0 (
    echo Instalando PM2 globalmente...
    call npm install -g pm2 --force
)

REM Inicia os serviços com PM2
echo Iniciando serviços...
pm2 delete all
pm2 start "ecosystem.config.cjs"
pm2 save

REM Abre um novo terminal para mostrar os logs do backend
start cmd /k "cd /d %PROJECT_ROOT% && pm2 logs backend --lines 1000"

echo.
echo Sistema iniciado com sucesso!
echo Frontend: http://%IP%:5173
echo Backend: http://%IP%:8081
echo.
echo Comandos úteis:
echo pm2 logs - Visualizar logs
echo pm2 monit - Monitorar processos
echo pm2 stop all - Parar todos os serviços
echo pm2 delete all - Remover todos os serviços
echo.
pause 