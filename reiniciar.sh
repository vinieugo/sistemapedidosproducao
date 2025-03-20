#!/bin/bash

# Instalando compression
echo "Instalando o pacote compression..."
npm install compression --save

# Parando os serviços
echo "Parando os serviços..."
pm2 delete all

# Limpando cache do PM2
echo "Limpando cache do PM2..."
pm2 flush

# Iniciando os serviços novamente
echo "Iniciando os serviços novamente..."
npm run start

echo "Sistema reiniciado com sucesso!"
echo "Para monitorar a aplicação, use: npm run monit"
echo "Para verificar o status, use: npm run status"
echo "Para ver os logs, use: npm run logs" 