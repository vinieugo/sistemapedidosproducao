@echo off
echo ======================================================
echo  CONFIGURANDO SISTEMA COMO SERVICO DO WINDOWS
echo ======================================================

echo [1/4] Baixando NSSM (Non-Sucking Service Manager)...
:: Verifica se o diretório tools existe
if not exist tools mkdir tools

:: Baixa o NSSM usando PowerShell
powershell -Command "& {Invoke-WebRequest -Uri 'https://nssm.cc/release/nssm-2.24.zip' -OutFile 'tools\nssm-2.24.zip'}"

:: Extrai o arquivo ZIP
powershell -Command "& {Expand-Archive -Path 'tools\nssm-2.24.zip' -DestinationPath 'tools' -Force}"

:: Determina a arquitetura do sistema (32 ou 64 bits)
if exist "%PROGRAMFILES(X86)%" (
    set ARCH=win64
) else (
    set ARCH=win32
)

:: Define o caminho para o executável do NSSM
set NSSM_PATH=tools\nssm-2.24\%ARCH%\nssm.exe

:: Obtendo o diretório atual (onde o sistema está instalado)
set SISTEMA_DIR=%~dp0
set SISTEMA_DIR=%SISTEMA_DIR:~0,-1%

echo.
echo [2/4] Criando servico para o frontend...
:: Remove o serviço se já existir
"%NSSM_PATH%" stop "SistemaPedidos-Frontend" 2>nul
"%NSSM_PATH%" remove "SistemaPedidos-Frontend" confirm 2>nul

:: Cria o serviço para o frontend
"%NSSM_PATH%" install "SistemaPedidos-Frontend" "%ProgramFiles%\nodejs\npm.cmd"
"%NSSM_PATH%" set "SistemaPedidos-Frontend" AppParameters "run preview -- --host 0.0.0.0"
"%NSSM_PATH%" set "SistemaPedidos-Frontend" AppDirectory "%SISTEMA_DIR%"
"%NSSM_PATH%" set "SistemaPedidos-Frontend" DisplayName "Sistema de Pedidos - Frontend"
"%NSSM_PATH%" set "SistemaPedidos-Frontend" Description "Servico do frontend do Sistema de Pedidos"
"%NSSM_PATH%" set "SistemaPedidos-Frontend" Start SERVICE_AUTO_START
"%NSSM_PATH%" set "SistemaPedidos-Frontend" AppStdout "%SISTEMA_DIR%\logs\frontend-stdout.log"
"%NSSM_PATH%" set "SistemaPedidos-Frontend" AppStderr "%SISTEMA_DIR%\logs\frontend-stderr.log"
"%NSSM_PATH%" set "SistemaPedidos-Frontend" AppRotateFiles 1
"%NSSM_PATH%" set "SistemaPedidos-Frontend" AppRotateBytes 1048576

echo.
echo [3/4] Criando servico para o backend...
:: Remove o serviço se já existir
"%NSSM_PATH%" stop "SistemaPedidos-Backend" 2>nul
"%NSSM_PATH%" remove "SistemaPedidos-Backend" confirm 2>nul

:: Cria o serviço para o backend
"%NSSM_PATH%" install "SistemaPedidos-Backend" "%ProgramFiles%\nodejs\npm.cmd"
"%NSSM_PATH%" set "SistemaPedidos-Backend" AppParameters "run start"
"%NSSM_PATH%" set "SistemaPedidos-Backend" AppDirectory "%SISTEMA_DIR%\backend"
"%NSSM_PATH%" set "SistemaPedidos-Backend" DisplayName "Sistema de Pedidos - Backend"
"%NSSM_PATH%" set "SistemaPedidos-Backend" Description "Servico do backend do Sistema de Pedidos"
"%NSSM_PATH%" set "SistemaPedidos-Backend" Start SERVICE_AUTO_START
"%NSSM_PATH%" set "SistemaPedidos-Backend" AppStdout "%SISTEMA_DIR%\logs\backend-stdout.log"
"%NSSM_PATH%" set "SistemaPedidos-Backend" AppStderr "%SISTEMA_DIR%\logs\backend-stderr.log"
"%NSSM_PATH%" set "SistemaPedidos-Backend" AppRotateFiles 1
"%NSSM_PATH%" set "SistemaPedidos-Backend" AppRotateBytes 1048576

echo.
echo [4/4] Criando diretorio de logs e iniciando servicos...
:: Cria diretório para logs
if not exist logs mkdir logs

:: Inicia os serviços
"%NSSM_PATH%" start "SistemaPedidos-Frontend"
"%NSSM_PATH%" start "SistemaPedidos-Backend"

echo.
echo ==============================================
echo  SERVICOS CONFIGURADOS COM SUCESSO!
echo ==============================================
echo.
echo Os servicos foram criados e estao sendo executados:
echo.
echo - SistemaPedidos-Frontend: Sistema de Pedidos - Frontend
echo - SistemaPedidos-Backend: Sistema de Pedidos - Backend
echo.
echo Estes servicos irão iniciar automaticamente quando o Windows for iniciado.
echo.
echo Para gerenciar os servicos, use o Gerenciador de Servicos do Windows:
echo services.msc
echo.
echo Os logs dos servicos estao disponiveis na pasta logs.
echo.
pause 