const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

// Criar diretório de backup se não existir
const backupDir = path.join(__dirname, '../backups');
if (!fs.existsSync(backupDir)) {
  fs.mkdirSync(backupDir);
}

// Nome do arquivo de backup com data
const getBackupFileName = () => {
  const date = new Date();
  return `backup_${date.getFullYear()}${(date.getMonth() + 1).toString().padStart(2, '0')}${date.getDate().toString().padStart(2, '0')}_${date.getHours().toString().padStart(2, '0')}${date.getMinutes().toString().padStart(2, '0')}.sql`;
};

// Função para fazer backup
const fazerBackup = () => {
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
  const backupFile = path.join(backupDir, getBackupFileName());

  // Comando pg_dump para backup
  const command = `pg_dump -h ${host} -p ${port} -U ${user} -F p ${database} > "${backupFile}"`;

  // Configurar variável de ambiente com a senha
  const env = { ...process.env, PGPASSWORD: password };

  exec(command, { env }, (error, stdout, stderr) => {
    if (error) {
      console.error('Erro ao fazer backup:', error);
      return;
    }
    console.log(`Backup criado com sucesso em: ${backupFile}`);
  });
};

// Executar backup
fazerBackup(); 