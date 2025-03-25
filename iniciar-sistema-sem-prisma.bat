@echo off
setlocal enabledelayedexpansion

echo =============================================================
echo      INICIANDO SISTEMA DE PEDIDOS - PRODUCAO
echo      (VERSAO SEM PRISMA)
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

REM Limpa cache do npm
echo Limpando cache do npm...
call npm cache clean --force

REM Configuração do Backend (SEM PRISMA)
echo =============================================================
echo      CONFIGURANDO BACKEND (SEM PRISMA)
echo =============================================================
cd backend

REM Limpa instalações anteriores
echo Limpando instalacoes anteriores...
if exist "node_modules" (
    echo Tentando remover node_modules...
    rmdir /s /q node_modules
)
if exist "package-lock.json" del package-lock.json

REM Cria o arquivo database.js para conexão direta com MySQL (sem Prisma)
echo Criando arquivo de conexao direta com MySQL...
if not exist "src\config" mkdir src\config
echo // Conexao direta com MySQL sem usar Prisma> src\config\database.js
echo const mysql = require('mysql2/promise');>> src\config\database.js
echo.>> src\config\database.js
echo const dbConfig = {>> src\config\database.js
echo   host: '192.168.5.3',>> src\config\database.js
echo   user: 'root',>> src\config\database.js
echo   password: '',>> src\config\database.js
echo   database: 'sistema_pedidos'>> src\config\database.js
echo };>> src\config\database.js
echo.>> src\config\database.js
echo let connectionPool;>> src\config\database.js
echo.>> src\config\database.js
echo const getConnection = async () =^> {>> src\config\database.js
echo   if (!connectionPool) {>> src\config\database.js
echo     connectionPool = mysql.createPool(dbConfig);>> src\config\database.js
echo   }>> src\config\database.js
echo   return connectionPool;>> src\config\database.js
echo };>> src\config\database.js
echo.>> src\config\database.js
echo module.exports = { getConnection };>> src\config\database.js

REM Modifica o arquivo pedidosController.js para usar MySQL direto
echo Adaptando controlador de pedidos para usar MySQL direto...
echo const db = require('../config/database');> src\controllers\pedidosController.js
echo.>> src\controllers\pedidosController.js
echo // Obter todos os pedidos>> src\controllers\pedidosController.js
echo exports.getPedidos = async (req, res) =^> {>> src\controllers\pedidosController.js
echo   try {>> src\controllers\pedidosController.js
echo     const connection = await db.getConnection();>> src\controllers\pedidosController.js
echo     const [pedidos] = await connection.execute('SELECT * FROM pedidos ORDER BY data_criacao DESC');>> src\controllers\pedidosController.js
echo     res.json(pedidos);>> src\controllers\pedidosController.js
echo   } catch (error) {>> src\controllers\pedidosController.js
echo     console.error('Erro ao buscar pedidos:', error);>> src\controllers\pedidosController.js
echo     res.status(500).json({ error: 'Erro ao buscar pedidos' });>> src\controllers\pedidosController.js
echo   }>> src\controllers\pedidosController.js
echo };>> src\controllers\pedidosController.js
echo.>> src\controllers\pedidosController.js
echo // Obter um pedido pelo ID>> src\controllers\pedidosController.js
echo exports.getPedidoById = async (req, res) =^> {>> src\controllers\pedidosController.js
echo   try {>> src\controllers\pedidosController.js
echo     const { id } = req.params;>> src\controllers\pedidosController.js
echo     const connection = await db.getConnection();>> src\controllers\pedidosController.js
echo     const [pedidos] = await connection.execute('SELECT * FROM pedidos WHERE id = ?', [id]);>> src\controllers\pedidosController.js
echo     if (pedidos.length === 0) {>> src\controllers\pedidosController.js
echo       return res.status(404).json({ error: 'Pedido não encontrado' });>> src\controllers\pedidosController.js
echo     }>> src\controllers\pedidosController.js
echo     res.json(pedidos[0]);>> src\controllers\pedidosController.js
echo   } catch (error) {>> src\controllers\pedidosController.js
echo     console.error('Erro ao buscar pedido:', error);>> src\controllers\pedidosController.js
echo     res.status(500).json({ error: 'Erro ao buscar pedido' });>> src\controllers\pedidosController.js
echo   }>> src\controllers\pedidosController.js
echo };>> src\controllers\pedidosController.js
echo.>> src\controllers\pedidosController.js
echo // Criar um novo pedido>> src\controllers\pedidosController.js
echo exports.createPedido = async (req, res) =^> {>> src\controllers\pedidosController.js
echo   try {>> src\controllers\pedidosController.js
echo     const { cliente, produtos, status, observacoes } = req.body;>> src\controllers\pedidosController.js
echo     const connection = await db.getConnection();>> src\controllers\pedidosController.js
echo     const [result] = await connection.execute(>> src\controllers\pedidosController.js
echo       'INSERT INTO pedidos (cliente, produtos, status, observacoes, data_criacao) VALUES (?, ?, ?, ?, NOW())',>> src\controllers\pedidosController.js
echo       [cliente, JSON.stringify(produtos), status, observacoes]>> src\controllers\pedidosController.js
echo     );>> src\controllers\pedidosController.js
echo     res.status(201).json({ id: result.insertId, cliente, produtos, status, observacoes });>> src\controllers\pedidosController.js
echo   } catch (error) {>> src\controllers\pedidosController.js
echo     console.error('Erro ao criar pedido:', error);>> src\controllers\pedidosController.js
echo     res.status(500).json({ error: 'Erro ao criar pedido' });>> src\controllers\pedidosController.js
echo   }>> src\controllers\pedidosController.js
echo };>> src\controllers\pedidosController.js
echo.>> src\controllers\pedidosController.js
echo // Atualizar um pedido>> src\controllers\pedidosController.js
echo exports.updatePedido = async (req, res) =^> {>> src\controllers\pedidosController.js
echo   try {>> src\controllers\pedidosController.js
echo     const { id } = req.params;>> src\controllers\pedidosController.js
echo     const { cliente, produtos, status, observacoes } = req.body;>> src\controllers\pedidosController.js
echo     const connection = await db.getConnection();>> src\controllers\pedidosController.js
echo     await connection.execute(>> src\controllers\pedidosController.js
echo       'UPDATE pedidos SET cliente = ?, produtos = ?, status = ?, observacoes = ? WHERE id = ?',>> src\controllers\pedidosController.js
echo       [cliente, JSON.stringify(produtos), status, observacoes, id]>> src\controllers\pedidosController.js
echo     );>> src\controllers\pedidosController.js
echo     res.json({ id, cliente, produtos, status, observacoes });>> src\controllers\pedidosController.js
echo   } catch (error) {>> src\controllers\pedidosController.js
echo     console.error('Erro ao atualizar pedido:', error);>> src\controllers\pedidosController.js
echo     res.status(500).json({ error: 'Erro ao atualizar pedido' });>> src\controllers\pedidosController.js
echo   }>> src\controllers\pedidosController.js
echo };>> src\controllers\pedidosController.js
echo.>> src\controllers\pedidosController.js
echo // Deletar um pedido>> src\controllers\pedidosController.js
echo exports.deletePedido = async (req, res) =^> {>> src\controllers\pedidosController.js
echo   try {>> src\controllers\pedidosController.js
echo     const { id } = req.params;>> src\controllers\pedidosController.js
echo     const connection = await db.getConnection();>> src\controllers\pedidosController.js
echo     await connection.execute('DELETE FROM pedidos WHERE id = ?', [id]);>> src\controllers\pedidosController.js
echo     res.json({ message: 'Pedido removido com sucesso' });>> src\controllers\pedidosController.js
echo   } catch (error) {>> src\controllers\pedidosController.js
echo     console.error('Erro ao deletar pedido:', error);>> src\controllers\pedidosController.js
echo     res.status(500).json({ error: 'Erro ao deletar pedido' });>> src\controllers\pedidosController.js
echo   }>> src\controllers\pedidosController.js
echo };>> src\controllers\pedidosController.js

REM Cria um novo package.json limpo sem Prisma
echo Criando package.json...
echo {> package.json
echo   "name": "sistema-pedidos-backend",>> package.json
echo   "version": "1.0.0",>> package.json
echo   "main": "src/server.js",>> package.json
echo   "scripts": {>> package.json
echo     "dev": "nodemon src/server.js",>> package.json
echo     "start": "node src/server.js">> package.json
echo   },>> package.json
echo   "dependencies": {>> package.json
echo     "express": "^4.18.2",>> package.json
echo     "cors": "^2.8.5",>> package.json
echo     "dotenv": "^16.4.5",>> package.json
echo     "mysql2": "^3.9.2">> package.json
echo   },>> package.json
echo   "devDependencies": {>> package.json
echo     "nodemon": "^3.1.0">> package.json
echo   }>> package.json
echo }>> package.json

REM Instala o nodemon globalmente
echo Instalando nodemon e pm2 globalmente...
call npm install -g nodemon --force

REM Instala as dependências uma por uma
echo Instalando dependencias do backend...
call npm install express --save --force
call npm install cors --save --force
call npm install dotenv --save --force
call npm install mysql2 --save --force

REM Configura o arquivo .env
echo Configurando banco de dados...
echo DATABASE_URL="mysql://root:@192.168.5.3:3306/sistema_pedidos" > .env
echo PORT=8081 >> .env
echo HOST=0.0.0.0 >> .env

cd ..

REM Configuração do Frontend
echo =============================================================
echo      CONFIGURANDO FRONTEND
echo =============================================================

REM Limpa instalações anteriores
echo Limpando instalacoes anteriores...
if exist "node_modules" (
    echo Tentando remover node_modules...
    rmdir /s /q node_modules
)
if exist "package-lock.json" del package-lock.json

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
echo         DB_HOST: '192.168.5.3',>> ecosystem.config.cjs
echo         DB_USER: 'root',>> ecosystem.config.cjs
echo         DB_PASSWORD: '',>> ecosystem.config.cjs
echo         DB_DATABASE: 'sistema_pedidos'>> ecosystem.config.cjs
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

REM Cria script SQL para criar o banco de dados se necessário
echo Criando script SQL para banco de dados...
echo -- Criando banco de dados se não existir> backend\database.sql
echo CREATE DATABASE IF NOT EXISTS sistema_pedidos;>> backend\database.sql
echo USE sistema_pedidos;>> backend\database.sql
echo.>> backend\database.sql
echo -- Criando tabela de pedidos se não existir>> backend\database.sql
echo CREATE TABLE IF NOT EXISTS pedidos (>> backend\database.sql
echo   id INT AUTO_INCREMENT PRIMARY KEY,>> backend\database.sql
echo   cliente VARCHAR(255) NOT NULL,>> backend\database.sql
echo   produtos JSON NOT NULL,>> backend\database.sql
echo   status VARCHAR(50) NOT NULL,>> backend\database.sql
echo   observacoes TEXT,>> backend\database.sql
echo   data_criacao DATETIME NOT NULL>> backend\database.sql
echo );>> backend\database.sql

echo Você pode criar o banco de dados importando o arquivo database.sql
echo no MySQL com o comando:
echo mysql -u root < backend\database.sql

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