#!/bin/bash

# Instalando PM2 globalmente
echo "Instalando PM2 globalmente..."
npm install -g pm2

# Instalando Express e compressão
echo "Instalando dependências adicionais..."
npm install express compression --save

# Instalando dependências do projeto
echo "Instalando dependências do projeto..."
npm install

# Instalando dependências do backend
echo "Instalando dependências do backend..."
npm run install:back

# Construindo o frontend
echo "Construindo o frontend..."
npm run build

# Iniciando a aplicação com PM2
echo "Iniciando a aplicação com PM2..."
pm2 delete all
npm run start

echo "Sistema iniciado com sucesso!"
echo "Para monitorar a aplicação, use: npm run monit"
echo "Para verificar o status, use: npm run status"
echo "Para ver os logs, use: npm run logs" 