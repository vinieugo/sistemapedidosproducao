@echo off
echo ======================================================
echo  INICIANDO SISTEMA DE PEDIDOS EM MODO DE PRODUCAO
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

:: Iniciando frontend e backend separadamente
echo [5/5] Iniciando servicos...
echo.

:: Iniciando frontend
echo Iniciando frontend...
start cmd /k "call npm run preview"

:: Iniciando backend
echo Iniciando backend...
start cmd /k "cd backend && call npm run start"

echo.
echo ==============================================
echo        SISTEMA INICIADO COM SUCESSO!
echo ==============================================
echo Frontend: http://localhost:5173
echo Backend: http://localhost:8081
echo.
echo Pressione qualquer tecla para ENCERRAR todos os servicos...
pause

:: Quando o usuario pressionar uma tecla, encerramos todos os processos
echo Encerrando servicos...
taskkill /F /FI "WINDOWTITLE eq npm run preview*" 2>nul
taskkill /F /FI "WINDOWTITLE eq npm run start*" 2>nul
echo Servicos encerrados! 