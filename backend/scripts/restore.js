const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

// Função para restaurar backup
const restaurarBackup = (backupFile) => {
  if (!backupFile) {
    console.error('Por favor, especifique o arquivo de backup');
    console.log('Uso: node restore.js nome_do_arquivo_backup.sql');
    return;
  }

  const backupPath = path.join(__dirname, '../backups', backupFile);
  if (!fs.existsSync(backupPath)) {
    console.error(`Arquivo de backup não encontrado: ${backupPath}`);
    return;
  }

  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    console.error('DATABASE_URL não encontrada no arquivo .env');
    return;
  }

  // Extrair informações da conexão da DATABASE_URL
  const match = databaseUrl.match(/postgres:\/\/([^:]+):([^@]+)@([^:]+):(\d+)\/(.+)/);
  if (!match) {
    console.error('Formato de DATABASE_URL inválido');
    return;
  }

  const [, user, password, host, port, database] = match;

  // Comando psql para restaurar
  const command = `psql -h ${host} -p ${port} -U ${user} -d ${database} -f "${backupPath}"`;

  // Configurar variável de ambiente com a senha
  const env = { ...process.env, PGPASSWORD: password };

  exec(command, { env }, (error, stdout, stderr) => {
    if (error) {
      console.error('Erro ao restaurar backup:', error);
      return;
    }
    console.log('Backup restaurado com sucesso!');
    if (stdout) console.log('Saída:', stdout);
    if (stderr) console.log('Avisos:', stderr);
  });
};

// Pegar nome do arquivo de backup dos argumentos
const backupFile = process.argv[2];
restaurarBackup(backupFile); 