@echo off
echo ======================================================
echo  CONFIGURANDO SISTEMA PARA REDE EXTERNA
echo ======================================================

:: Definir o IP da máquina manualmente para garantir configuração correta
set IP=192.168.5.3

echo IP configurado: %IP%

:: Atualizando as configurações do backend
echo.
echo [1/3] Atualizando configuracoes do banco de dados...
echo DATABASE_URL="mysql://root:root@localhost:3307/sistema-pedidos2" > backend\.env
echo CORS_ORIGIN="*" >> backend\.env
echo PORT=8081 >> backend\.env
echo HOST="0.0.0.0" >> backend\.env

echo.
echo [2/3] Atualizando arquivo de configuracao do PM2...
:: Criar ou atualizar o arquivo de configuração do PM2
echo module.exports = { > ecosystem.config.cjs
echo   apps: [ >> ecosystem.config.cjs
echo     { >> ecosystem.config.cjs
echo       name: 'sistema-pedidos-frontend', >> ecosystem.config.cjs
echo       script: 'npm', >> ecosystem.config.cjs
echo       args: 'run preview -- --host 0.0.0.0', >> ecosystem.config.cjs
echo       cwd: './', >> ecosystem.config.cjs
echo       instances: 1, >> ecosystem.config.cjs
echo       autorestart: true, >> ecosystem.config.cjs
echo       watch: false, >> ecosystem.config.cjs
echo       max_memory_restart: '1G', >> ecosystem.config.cjs
echo       env: { >> ecosystem.config.cjs
echo         NODE_ENV: 'production', >> ecosystem.config.cjs
echo       } >> ecosystem.config.cjs
echo     }, >> ecosystem.config.cjs
echo     { >> ecosystem.config.cjs
echo       name: 'sistema-pedidos-backend', >> ecosystem.config.cjs
echo       script: 'npm', >> ecosystem.config.cjs
echo       args: 'run start', >> ecosystem.config.cjs
echo       cwd: './backend', >> ecosystem.config.cjs
echo       instances: 1, >> ecosystem.config.cjs
echo       autorestart: true, >> ecosystem.config.cjs
echo       watch: false, >> ecosystem.config.cjs
echo       max_memory_restart: '1G', >> ecosystem.config.cjs
echo       env: { >> ecosystem.config.cjs
echo         NODE_ENV: 'production', >> ecosystem.config.cjs
echo         PORT: 8081, >> ecosystem.config.cjs
echo         HOST: '0.0.0.0' >> ecosystem.config.cjs
echo       } >> ecosystem.config.cjs
echo     } >> ecosystem.config.cjs
echo   ] >> ecosystem.config.cjs
echo }; >> ecosystem.config.cjs

echo.
echo [3/3] Atualizando API do frontend...
echo import axios from 'axios'; > src\services\api.js
echo. >> src\services\api.js
echo const api = axios.create({ >> src\services\api.js
echo   baseURL: 'http://%IP%:8081/api' >> src\services\api.js
echo }); >> src\services\api.js
echo. >> src\services\api.js
echo export const getPedidos = async (page = 1, status = null, dataInicial = null, dataFinal = null) = ^> { >> src\services\api.js
echo   // Garantir que as datas sejam enviadas no formato ISO para preservar o fuso horário >> src\services\api.js
echo   const formattedDataInicial = dataInicial instanceof Date ? dataInicial.toISOString() : dataInicial; >> src\services\api.js
echo   const formattedDataFinal = dataFinal instanceof Date ? dataFinal.toISOString() : dataFinal; >> src\services\api.js
echo   >> src\services\api.js
echo   const params = { >> src\services\api.js
echo     page, >> src\services\api.js
echo     ...(Array.isArray(status) ? { status: status.join(',') } : status ? { status } : {}), >> src\services\api.js
echo     ...(formattedDataInicial ^&^& { dataInicial: formattedDataInicial }), >> src\services\api.js
echo     ...(formattedDataFinal ^&^& { dataFinal: formattedDataFinal }) >> src\services\api.js
echo   }; >> src\services\api.js
echo   >> src\services\api.js
echo   console.log('Enviando parâmetros para API:', params); >> src\services\api.js
echo   const response = await api.get('/pedidos', { params }); >> src\services\api.js
echo   return response.data; >> src\services\api.js
echo }; >> src\services\api.js
echo. >> src\services\api.js
echo export const criarPedido = async (pedido) = ^> { >> src\services\api.js
echo   // Validar e formatar os dados antes de enviar >> src\services\api.js
echo   const pedidoFormatado = { >> src\services\api.js
echo     ...pedido, >> src\services\api.js
echo     quantidade: Number(pedido.quantidade) ^|^| 0, >> src\services\api.js
echo     // Garantir que o fornecedor não seja undefined >> src\services\api.js
echo     fornecedor: pedido.fornecedor ^|^| '', >> src\services\api.js
echo     // Garantir que o motivo não seja undefined >> src\services\api.js
echo     motivo: pedido.motivo ^|^| '' >> src\services\api.js
echo   }; >> src\services\api.js
echo   >> src\services\api.js
echo   console.log('Enviando pedido para criação:', pedidoFormatado); >> src\services\api.js
echo   const response = await api.post('/pedidos', pedidoFormatado); >> src\services\api.js
echo   return response.data; >> src\services\api.js
echo }; >> src\services\api.js
echo. >> src\services\api.js
echo export const atualizarPedido = async (id, pedido) = ^> { >> src\services\api.js
echo   const response = await api.put(`/pedidos/${id}`, pedido); >> src\services\api.js
echo   return response.data; >> src\services\api.js
echo }; >> src\services\api.js
echo. >> src\services\api.js
echo export const deletarPedido = async (id) = ^> { >> src\services\api.js
echo   await api.delete(`/pedidos/${id}`); >> src\services\api.js
echo }; >> src\services\api.js
echo. >> src\services\api.js
echo export const getConfiguracoes = async () = ^> { >> src\services\api.js
echo   const response = await api.get('/configuracoes'); >> src\services\api.js
echo   return response.data; >> src\services\api.js
echo }; >> src\services\api.js
echo. >> src\services\api.js
echo export const atualizarConfiguracoes = async (config) = ^> { >> src\services\api.js
echo   const response = await api.put('/configuracoes', config); >> src\services\api.js
echo   return response.data; >> src\services\api.js
echo }; >> src\services\api.js
echo. >> src\services\api.js
echo export const arquivarPedidosAntigos = async () = ^> { >> src\services\api.js
echo   const response = await api.post('/arquivar-pedidos'); >> src\services\api.js
echo   return response.data; >> src\services\api.js
echo }; >> src\services\api.js

echo.
echo [4/3] Gerando informacoes de acesso...
echo // Informacoes de acesso para o sistema > informacoes-acesso.txt
echo ================================================== >> informacoes-acesso.txt
echo Data de configuracao: %date% %time% >> informacoes-acesso.txt
echo ================================================== >> informacoes-acesso.txt
echo. >> informacoes-acesso.txt
echo Frontend: http://%IP%:5173 >> informacoes-acesso.txt
echo Backend: http://%IP%:8081 >> informacoes-acesso.txt
echo. >> informacoes-acesso.txt
echo Configuracoes do MySQL: >> informacoes-acesso.txt
echo - Usuario: root >> informacoes-acesso.txt
echo - Senha: root >> informacoes-acesso.txt
echo - Porta: 3307 >> informacoes-acesso.txt
echo - Banco de dados: sistema-pedidos2 >> informacoes-acesso.txt
echo. >> informacoes-acesso.txt
echo IMPORTANTE: Para acessar o sistema de outras maquinas da rede: >> informacoes-acesso.txt
echo - Verifique se o firewall esta configurado para permitir >> informacoes-acesso.txt
echo   conexoes nas portas 5173, 8081 e 3307. >> informacoes-acesso.txt
echo - Todas as maquinas devem estar na mesma faixa de rede (192.168.5.x) >> informacoes-acesso.txt

echo.
echo ==============================================
echo        SISTEMA CONFIGURADO COM SUCESSO!
echo ==============================================
echo Frontend: http://%IP%:5173
echo Backend: http://%IP%:8081
echo.
echo Para acessar o sistema a partir de outras maquinas,
echo use os enderecos acima.
echo.
echo As informacoes de acesso foram salvas no arquivo:
echo "informacoes-acesso.txt"
echo.
pause 