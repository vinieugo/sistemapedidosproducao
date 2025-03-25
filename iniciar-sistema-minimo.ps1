# Verifica se está rodando como administrador
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Este script precisa ser executado como Administrador." -ForegroundColor Red
    Write-Host "Por favor, clique com o botão direito no PowerShell e selecione 'Executar como administrador'." -ForegroundColor Yellow
    Read-Host "Pressione Enter para sair"
    exit
}

Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "     INICIANDO SISTEMA DE PEDIDOS - VERSÃO MÍNIMA" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan

# Define o diretório do projeto
Set-Location "C:\Users\app\Documents\Sistema-Pedidos\sistemapedidosproducao-main"
Write-Host "Diretorio atual: $((Get-Location).Path)"

# Define o IP manualmente
$IP = "192.168.5.3"
Write-Host "IP definido: $IP"

# Para processos anteriores
Write-Host "Parando servicos anteriores..." -ForegroundColor Yellow
Stop-Process -Name "node" -Force -ErrorAction SilentlyContinue
pm2 delete all

# Aguarda liberação dos recursos
Write-Host "Aguardando liberacao de recursos..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Configuração do Backend
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "     CONFIGURANDO BACKEND (SEM PRISMA)" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan

Set-Location "C:\Users\app\Documents\Sistema-Pedidos\sistemapedidosproducao-main\backend"

# Ignorando diretório node_modules
Write-Host "Pulando remoção de node_modules..." -ForegroundColor Yellow

# Cria diretórios necessários
if (-not (Test-Path "src\config")) {
    New-Item -Path "src\config" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path "src\controllers")) {
    New-Item -Path "src\controllers" -ItemType Directory -Force | Out-Null
}

# Cria o arquivo de conexão com o banco de dados
Write-Host "Criando arquivo de conexao com o banco de dados..." -ForegroundColor Yellow
@"
// Conexao direta com MySQL sem usar Prisma
const mysql = require('mysql2/promise');

const dbConfig = {
  host: '192.168.5.3',
  user: 'root',
  password: '',
  database: 'sistema_pedidos'
};

let connectionPool;

const getConnection = async () => {
  if (!connectionPool) {
    connectionPool = mysql.createPool(dbConfig);
  }
  return connectionPool;
};

module.exports = { getConnection };
"@ | Out-File -FilePath "src\config\database.js" -Encoding utf8

# Cria o controlador de pedidos
Write-Host "Criando controlador de pedidos..." -ForegroundColor Yellow
@"
const db = require('../config/database');

// Obter todos os pedidos
exports.getPedidos = async (req, res) => {
  try {
    const connection = await db.getConnection();
    const [pedidos] = await connection.execute('SELECT * FROM pedidos ORDER BY data_criacao DESC');
    res.json(pedidos);
  } catch (error) {
    console.error('Erro ao buscar pedidos:', error);
    res.status(500).json({ error: 'Erro ao buscar pedidos' });
  }
};

// Obter um pedido pelo ID
exports.getPedidoById = async (req, res) => {
  try {
    const { id } = req.params;
    const connection = await db.getConnection();
    const [pedidos] = await connection.execute('SELECT * FROM pedidos WHERE id = ?', [id]);
    if (pedidos.length === 0) {
      return res.status(404).json({ error: 'Pedido não encontrado' });
    }
    res.json(pedidos[0]);
  } catch (error) {
    console.error('Erro ao buscar pedido:', error);
    res.status(500).json({ error: 'Erro ao buscar pedido' });
  }
};

// Criar um novo pedido
exports.createPedido = async (req, res) => {
  try {
    const { cliente, produtos, status, observacoes } = req.body;
    const connection = await db.getConnection();
    const [result] = await connection.execute(
      'INSERT INTO pedidos (cliente, produtos, status, observacoes, data_criacao) VALUES (?, ?, ?, ?, NOW())',
      [cliente, JSON.stringify(produtos), status, observacoes]
    );
    res.status(201).json({ id: result.insertId, cliente, produtos, status, observacoes });
  } catch (error) {
    console.error('Erro ao criar pedido:', error);
    res.status(500).json({ error: 'Erro ao criar pedido' });
  }
};

// Atualizar um pedido
exports.updatePedido = async (req, res) => {
  try {
    const { id } = req.params;
    const { cliente, produtos, status, observacoes } = req.body;
    const connection = await db.getConnection();
    await connection.execute(
      'UPDATE pedidos SET cliente = ?, produtos = ?, status = ?, observacoes = ? WHERE id = ?',
      [cliente, JSON.stringify(produtos), status, observacoes, id]
    );
    res.json({ id, cliente, produtos, status, observacoes });
  } catch (error) {
    console.error('Erro ao atualizar pedido:', error);
    res.status(500).json({ error: 'Erro ao atualizar pedido' });
  }
};

// Deletar um pedido
exports.deletePedido = async (req, res) => {
  try {
    const { id } = req.params;
    const connection = await db.getConnection();
    await connection.execute('DELETE FROM pedidos WHERE id = ?', [id]);
    res.json({ message: 'Pedido removido com sucesso' });
  } catch (error) {
    console.error('Erro ao deletar pedido:', error);
    res.status(500).json({ error: 'Erro ao deletar pedido' });
  }
};
"@ | Out-File -FilePath "src\controllers\pedidosController.js" -Encoding utf8

# Cria o arquivo server.js se não existir
if (-not (Test-Path "src\server.js")) {
    Write-Host "Criando arquivo server.js..." -ForegroundColor Yellow
    @"
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const pedidosController = require('./controllers/pedidosController');

// Carrega variáveis de ambiente
dotenv.config();

const app = express();
const PORT = process.env.PORT || 8081;
const HOST = process.env.HOST || '0.0.0.0';

// Middlewares
app.use(cors());
app.use(express.json());

// Rotas
app.get('/api/pedidos', pedidosController.getPedidos);
app.get('/api/pedidos/:id', pedidosController.getPedidoById);
app.post('/api/pedidos', pedidosController.createPedido);
app.put('/api/pedidos/:id', pedidosController.updatePedido);
app.delete('/api/pedidos/:id', pedidosController.deletePedido);

// Rota padrão
app.get('/', (req, res) => {
  res.json({ message: 'Sistema de Pedidos API - Running' });
});

// Inicia o servidor
app.listen(PORT, HOST, () => {
  console.log(`Servidor rodando em http://${HOST}:${PORT}`);
});
"@ | Out-File -FilePath "src\server.js" -Encoding utf8
}

# Cria o arquivo .env
Write-Host "Configurando variáveis de ambiente..." -ForegroundColor Yellow
@"
PORT=8081
HOST=0.0.0.0
"@ | Out-File -FilePath ".env" -Encoding utf8

# Verificar se já existe node_modules
if (Test-Path "node_modules") {
    Write-Host "Node modules já existente, prosseguindo..." -ForegroundColor Green
} else {
    Write-Host "AVISO: node_modules não existe, o backend pode não funcionar." -ForegroundColor Yellow
    Write-Host "Você precisa tentar copiar node_modules de outra máquina." -ForegroundColor Yellow
}

# Volta para o diretório principal
Set-Location "C:\Users\app\Documents\Sistema-Pedidos\sistemapedidosproducao-main"

# Configuração do Frontend
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "     CONFIGURANDO FRONTEND" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan

# Configura o Vite
Write-Host "Configurando Vite..." -ForegroundColor Yellow
@"
import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    host: '0.0.0.0',
    port: 5173
  },
  preview: {
    host: '0.0.0.0',
    port: 5173
  },
  define: {
    'process.env.VITE_API_URL': JSON.stringify('http://$IP:8081/api')
  }
});
"@ | Out-File -FilePath "vite.config.js" -Encoding utf8

# Verifica se já existe a build do frontend
if (Test-Path "dist") {
    Write-Host "Build do frontend já existente, prosseguindo..." -ForegroundColor Green
} else {
    Write-Host "AVISO: Não foi encontrada a pasta dist. O frontend pode não funcionar." -ForegroundColor Yellow
    Write-Host "Você precisa compilar o frontend em outra máquina e trazer a pasta dist." -ForegroundColor Yellow
}

# Configuração do PM2
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "     CONFIGURANDO PM2" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan

# Cria diretórios de logs
if (-not (Test-Path "logs")) {
    New-Item -Path "logs" -ItemType Directory -Force | Out-Null
}
if (-not (Test-Path "backend\logs")) {
    New-Item -Path "backend\logs" -ItemType Directory -Force | Out-Null
}

# Configura o PM2
Write-Host "Configurando PM2..." -ForegroundColor Yellow
@"
module.exports = {
  apps: [
    {
      name: 'sistema-pedidos-frontend',
      script: 'node',
      args: 'node_modules/vite/bin/vite.js preview',
      cwd: './',
      env: {
        NODE_ENV: 'production',
        HOST: '0.0.0.0',
        PORT: 5173,
        VITE_API_URL: 'http://$IP:8081/api'
      },
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,
      log_type: 'json',
      error_file: './logs/frontend-error.log',
      out_file: './logs/frontend-out.log',
      max_restarts: 10,
      min_uptime: '10s',
      watch: false,
      autorestart: true
    },
    {
      name: 'sistema-pedidos-backend',
      script: 'node',
      args: 'src/server.js',
      cwd: './backend',
      env: {
        NODE_ENV: 'production',
        HOST: '0.0.0.0',
        PORT: 8081,
        DB_HOST: '192.168.5.3',
        DB_USER: 'root',
        DB_PASSWORD: '',
        DB_DATABASE: 'sistema_pedidos'
      },
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,
      log_type: 'json',
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      max_restarts: 10,
      min_uptime: '10s',
      watch: false,
      autorestart: true
    }
  ]
};
"@ | Out-File -FilePath "ecosystem.config.cjs" -Encoding utf8

# Verifica PM2
$pm2Installed = $null
try {
    $pm2Installed = Get-Command pm2 -ErrorAction SilentlyContinue
}
catch {
    $pm2Installed = $null
}

if (-not $pm2Installed) {
    Write-Host "AVISO: PM2 não encontrado. Você deve instalá-lo manualmente." -ForegroundColor Yellow
    Write-Host "Execute: npm install -g pm2" -ForegroundColor Yellow
} else {
    # Inicia os serviços
    Write-Host "=============================================================" -ForegroundColor Cyan
    Write-Host "     INICIANDO SERVIÇOS" -ForegroundColor Cyan
    Write-Host "=============================================================" -ForegroundColor Cyan

    & pm2 start ecosystem.config.cjs
    & pm2 save

    # Resumo
    Write-Host ""
    Write-Host "=============================================================" -ForegroundColor Green
    Write-Host "     SISTEMA INICIADO COM SUCESSO!" -ForegroundColor Green
    Write-Host "=============================================================" -ForegroundColor Green
    Write-Host ""

    Write-Host "Status dos serviços:" -ForegroundColor Yellow
    & pm2 status

    Write-Host ""
    Write-Host "Frontend: http://$IP:5173" -ForegroundColor Cyan
    Write-Host "Backend:  http://$IP:8081" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Logs do Frontend: logs/frontend-out.log" -ForegroundColor Yellow
    Write-Host "Logs do Backend:  backend/logs/backend-out.log" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "Comandos úteis:" -ForegroundColor Yellow
    Write-Host "- Ver status:     pm2 status" -ForegroundColor Gray
    Write-Host "- Ver logs:       pm2 logs" -ForegroundColor Gray
    Write-Host "- Reiniciar:      pm2 restart all" -ForegroundColor Gray
    Write-Host "- Parar:          pm2 stop all" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "=============================================================" -ForegroundColor Green
Write-Host ""

Read-Host "Pressione Enter para sair" 