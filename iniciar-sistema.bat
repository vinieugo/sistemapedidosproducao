@echo off
echo Iniciando sistema de pedidos...
echo.

REM Verifica se está rodando como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Este script precisa ser executado como Administrador!
    echo Clique com o botao direito e selecione "Executar como administrador"
    pause
    exit /b 1
)

REM Define o diretório do projeto
cd /d "%~dp0"

REM Configura o IP da máquina
set IP=192.168.5.3

REM Cria arquivo .env para o backend
echo DATABASE_URL="mysql://root:@%IP%:3306/sistema_pedidos" > backend\.env
echo PORT=8081 >> backend\.env

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
powershell -Command "(Get-Content frontend\vite.config.js) -replace 'localhost', '%IP%' | Set-Content frontend\vite.config.js"

REM Inicia os serviços com PM2
echo Iniciando serviços...
pm2 delete all
pm2 start backend/src/server.js --name "backend" --time
pm2 start "npm run preview" --name "frontend" --cwd frontend --time
pm2 save

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