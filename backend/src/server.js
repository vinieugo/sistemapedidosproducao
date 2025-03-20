const express = require('express');
const cors = require('cors');
const { PrismaClient } = require('@prisma/client');
const compression = require('compression');
require('dotenv').config();

const app = express();
const prisma = new PrismaClient({
  log: ['error'],
  // Aumentando conexões com o banco de dados
  connection: {
    pool: {
      min: 3,
      max: 10
    }
  }
});

// Compressão para reduzir tamanho das respostas
app.use(compression());

// Configuração do CORS
app.use(cors({
  origin: process.env.CORS_ORIGIN || "*",
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// Cache para resposta estáticas
const cacheTime = 60 * 5; // 5 minutos

// Rota para favicon.ico
app.get('/favicon.ico', (req, res) => {
  res.status(204).end(); // No Content
});

// Rota raiz
app.get('/', (req, res) => {
  res.json({ message: 'API do Sistema de Pedidos' });
});

// Rotas para pedidos
app.get('/api/pedidos', async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      status, 
      dataInicial, 
      dataFinal,
      arquivado = false 
    } = req.query;

    const skip = (page - 1) * limit;
    
    // Converter o valor de arquivado para booleano
    const isArquivado = arquivado === 'true' || arquivado === true;
    
    const where = {
      arquivado: isArquivado,
      ...(status && {
        status: status.includes(',') ? { in: status.split(',') } : status
      }),
      ...(dataInicial && dataFinal && {
        dataPreenchimento: {
          gte: new Date(dataInicial),
          lte: new Date(dataFinal)
        }
      })
    };

    // Quando o status for "Baixado", filtre também pela dataBaixa se dataInicial e dataFinal estiverem presentes
    if (status === 'Baixado' && dataInicial && dataFinal) {
      where.dataBaixa = {
        gte: new Date(dataInicial),
        lte: new Date(dataFinal)
      };
      // Remova o filtro dataPreenchimento para evitar conflito
      delete where.dataPreenchimento;
    }

    const [pedidos, total] = await Promise.all([
      prisma.pedido.findMany({
        where,
        skip,
        take: Number(limit),
        orderBy: { dataPreenchimento: 'desc' }
      }),
      prisma.pedido.count({ where })
    ]);

    res.set('Cache-Control', `public, max-age=${cacheTime}`);
    res.json({
      pedidos,
      total,
      pages: Math.ceil(total / limit)
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erro ao buscar pedidos' });
  }
});

app.post('/api/pedidos', async (req, res) => {
  try {
    // Verificar se todos os campos obrigatórios estão presentes
    const { nomeItem, quantidade, solicitante } = req.body;
    if (!nomeItem || quantidade === undefined || !solicitante) {
      return res.status(400).json({ error: 'Campos obrigatórios faltando' });
    }
    
    // Remover campos undefined ou null para evitar erros no MySQL
    const dadosFiltrados = Object.fromEntries(
      Object.entries(req.body).filter(([_, value]) => value !== undefined && value !== null)
    );
    
    // Realizar a conversão de tipos para garantir compatibilidade
    const dadosFormatados = {
      ...dadosFiltrados,
      nomeItem: String(dadosFiltrados.nomeItem || ''),
      quantidade: Number(dadosFiltrados.quantidade) || 0,
      solicitante: String(dadosFiltrados.solicitante || ''),
      fornecedor: String(dadosFiltrados.fornecedor || ''),
      motivo: dadosFiltrados.motivo ? String(dadosFiltrados.motivo) : null,
      status: 'A Solicitar',
      dataPreenchimento: new Date(),
      ativo: true,
      arquivado: false,
      updatedAt: new Date()
    };
    
    const pedido = await prisma.pedido.create({
      data: dadosFormatados
    });
    
    res.status(201).json(pedido);
  } catch (error) {
    console.error('Erro ao criar pedido:', error);
    res.status(500).json({ error: `Erro ao criar pedido: ${error.message}` });
  }
});

app.put('/api/pedidos/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const pedido = await prisma.pedido.update({
      where: { id: Number(id) },
      data: req.body
    });
    res.json(pedido);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erro ao atualizar pedido' });
  }
});

app.delete('/api/pedidos/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await prisma.pedido.delete({
      where: { id: Number(id) }
    });
    res.status(204).send();
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erro ao deletar pedido' });
  }
});

// Rota para arquivamento automático
app.post('/api/arquivar-pedidos', async (req, res) => {
  try {
    const config = await prisma.configuracao.findFirst();
    const diasParaArquivar = config?.diasParaArquivar || 30;

    const dataLimite = new Date();
    dataLimite.setDate(dataLimite.getDate() - diasParaArquivar);

    const result = await prisma.pedido.updateMany({
      where: {
        dataBaixa: {
          lt: dataLimite
        },
        arquivado: false
      },
      data: {
        arquivado: true
      }
    });

    res.json({ arquivados: result.count });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erro ao arquivar pedidos' });
  }
});

// Configurações
app.get('/api/configuracoes', async (req, res) => {
  try {
    let config = await prisma.configuracao.findFirst();
    if (!config) {
      config = await prisma.configuracao.create({
        data: {
          diasParaArquivar: 30,
          itensPorPagina: 10
        }
      });
    }
    res.set('Cache-Control', `public, max-age=${cacheTime}`);
    res.json(config);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erro ao buscar configurações' });
  }
});

app.put('/api/configuracoes', async (req, res) => {
  try {
    const config = await prisma.configuracao.upsert({
      where: { id: 1 },
      update: req.body,
      create: req.body
    });
    res.json(config);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erro ao atualizar configurações' });
  }
});

// Middleware para rotas não encontradas (404) - DEVE VIR DEPOIS DE TODAS AS ROTAS
app.use((req, res) => {
  res.status(404).json({ error: 'Rota não encontrada' });
});

// Middleware para tratamento de erros - DEVE SER O ÚLTIMO
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Erro interno do servidor' });
});

const PORT = process.env.PORT || 8081;
const HOST = process.env.HOST || 'localhost';

app.listen(PORT, HOST, () => {
  console.log(`Servidor rodando em http://${HOST}:${PORT}`);
}); 