const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function resetarBancoDados() {
  try {
    // Deletar todos os registros da tabela Pedido
    await prisma.pedido.deleteMany({});
    console.log('✓ Todos os pedidos foram deletados com sucesso');

    // Resetar a sequência do ID para começar do 1 novamente
    await prisma.$executeRaw`ALTER SEQUENCE "Pedido_id_seq" RESTART WITH 1;`;
    console.log('✓ Sequência de IDs resetada');

    // Deletar configurações (opcional)
    await prisma.configuracao.deleteMany({});
    console.log('✓ Configurações resetadas');
    
    console.log('\nBanco de dados resetado com sucesso!');
  } catch (error) {
    console.error('Erro ao resetar banco de dados:', error);
  } finally {
    await prisma.$disconnect();
  }
}

resetarBancoDados(); 