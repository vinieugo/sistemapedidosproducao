// Script para inicializar o banco de dados
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  try {
    console.log('Iniciando criação da estrutura do banco de dados...');

    // Criar a tabela de configurações caso não exista
    const configCount = await prisma.configuracao.count();
    if (configCount === 0) {
      console.log('Criando configuração padrão...');
      await prisma.configuracao.create({
        data: {
          diasParaArquivar: 30,
          itensPorPagina: 10
        }
      });
    }

    // Criar usuários iniciais se não existirem
    const userCount = await prisma.usuario.count();
    if (userCount === 0) {
      console.log('Criando usuário administrador padrão...');
      await prisma.usuario.create({
        data: {
          nome: 'Administrador',
          email: 'admin@sistema.com',
          senha: 'admin123',
          perfil: 'ADMIN'
        }
      });
    }

    console.log('Banco de dados inicializado com sucesso!');
  } catch (error) {
    console.error('Erro ao inicializar banco de dados:', error);
  } finally {
    await prisma.$disconnect();
  }
}

main(); 