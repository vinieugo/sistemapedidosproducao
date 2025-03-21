@echo off
echo ======================================================
echo  INICIALIZACAO COMPLETA DO SISTEMA DE PEDIDOS
echo ======================================================

:: Verificando se está sendo executado como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Este script deve ser executado como Administrador!
    echo Por favor, clique com o botao direito e selecione "Executar como administrador".
    pause
    exit /b 1
)

:: Obtendo o diretório atual (onde o sistema está instalado)
set SISTEMA_DIR=%~dp0
set SISTEMA_DIR=%SISTEMA_DIR:~0,-1%
set IP=192.168.5.3

echo Diretorio do sistema: %SISTEMA_DIR%
echo IP configurado: %IP%

echo.
echo [1/7] Instalando dependencias do frontend...
call npm install

echo.
echo [2/7] Construindo frontend para producao...
call npm run build

echo.
echo [3/7] Instalando dependencias do backend...
cd backend
call npm install
cd ..

echo.
echo [4/7] Configurando banco de dados...
echo DATABASE_URL="mysql://root:root@localhost:3307/sistema_pedidos" > backend\.env
echo CORS_ORIGIN="*" >> backend\.env
echo PORT=8081 >> backend\.env
echo HOST="0.0.0.0" >> backend\.env

echo.
echo [5/7] Executando migracao do Prisma...
cd backend
call npx prisma db push --accept-data-loss
cd ..

echo.
echo [6/7] Atualizando API do frontend...
echo import axios from 'axios'; > src\services\api.js
echo. >> src\services\api.js
echo const api = axios.create({ >> src\services\api.js
echo   baseURL: 'http://%IP%:8081/api' >> src\services\api.js
echo }); >> src\services\api.js
echo. >> src\services\api.js
echo export const getPedidos = async (page = 1, status = null, dataInicial = null, dataFinal = null) = ^> { >> src\services\api.js
echo   const formattedDataInicial = dataInicial instanceof Date ? dataInicial.toISOString() : dataInicial; >> src\services\api.js
echo   const formattedDataFinal = dataFinal instanceof Date ? dataFinal.toISOString() : dataFinal; >> src\services\api.js
echo   const params = { page, ...(Array.isArray(status) ? { status: status.join(',') } : status ? { status } : {}), >> src\services\api.js
echo     ...(formattedDataInicial ^&^& { dataInicial: formattedDataInicial }), >> src\services\api.js
echo     ...(formattedDataFinal ^&^& { dataFinal: formattedDataFinal }) }; >> src\services\api.js
echo   console.log('Enviando parâmetros para API:', params); >> src\services\api.js
echo   const response = await api.get('/pedidos', { params }); >> src\services\api.js
echo   return response.data; >> src\services\api.js
echo }; >> src\services\api.js
echo export const criarPedido = async (pedido) = ^> { >> src\services\api.js
echo   const pedidoFormatado = { ...pedido, quantidade: Number(pedido.quantidade) ^|^| 0, >> src\services\api.js
echo     fornecedor: pedido.fornecedor ^|^| '', motivo: pedido.motivo ^|^| '' }; >> src\services\api.js
echo   console.log('Enviando pedido para criação:', pedidoFormatado); >> src\services\api.js
echo   const response = await api.post('/pedidos', pedidoFormatado); >> src\services\api.js
echo   return response.data; >> src\services\api.js
echo }; >> src\services\api.js
echo export const atualizarPedido = async (id, pedido) = ^> { >> src\services\api.js
echo   const response = await api.put(`/pedidos/${id}`, pedido); >> src\services\api.js
echo   return response.data; >> src\services\api.js
echo }; >> src\services\api.js
echo export const deletarPedido = async (id) = ^> { await api.delete(`/pedidos/${id}`); }; >> src\services\api.js
echo export const getConfiguracoes = async () = ^> { >> src\services\api.js
echo   const response = await api.get('/configuracoes'); >> src\services\api.js
echo   return response.data; >> src\services\api.js
echo }; >> src\services\api.js
echo export const atualizarConfiguracoes = async (config) = ^> { >> src\services\api.js
echo   const response = await api.put('/configuracoes', config); >> src\services\api.js
echo   return response.data; >> src\services\api.js
echo }; >> src\services\api.js
echo export const arquivarPedidosAntigos = async () = ^> { >> src\services\api.js
echo   const response = await api.post('/arquivar-pedidos'); >> src\services\api.js
echo   return response.data; >> src\services\api.js
echo }; >> src\services\api.js

echo.
echo [7/7] Configurando servicos do Windows...

:: Verificar se o PM2 está instalado globalmente
where pm2 >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [Instalando PM2 globalmente...]
    call npm install -g pm2
)

:: Pergunta ao usuário qual método de inicialização deseja usar
echo.
echo Escolha o metodo de inicializacao automatica:
echo 1 - Usando PM2 e Agendador de Tarefas (recomendado)
echo 2 - Usando Servicos do Windows (NSSM)
echo 3 - Ambos os metodos
set /p OPCAO="Digite o numero da opcao (1, 2 ou 3): "

if "%OPCAO%"=="1" (
    call iniciar-startup.bat
) else if "%OPCAO%"=="2" (
    call iniciar-servico-windows.bat
) else if "%OPCAO%"=="3" (
    call iniciar-startup.bat
    call iniciar-servico-windows.bat
) else (
    echo Opcao invalida. Usando o metodo 1 (PM2 e Agendador de Tarefas)...
    call iniciar-startup.bat
)

echo.
echo ==============================================
echo  SISTEMA CONFIGURADO E INICIADO COM SUCESSO!
echo ==============================================
echo.
echo O Sistema de Pedidos foi configurado e iniciado.
echo Frontend: http://%IP%:5173
echo Backend: http://%IP%:8081
echo.
echo Informacoes de acesso:
echo - Usuario MySQL: root
echo - Senha MySQL: root
echo - Porta MySQL: 3307
echo - Banco de dados: sistema_pedidos
echo.
echo O sistema sera iniciado automaticamente quando o Windows for ligado.
echo.
pause 