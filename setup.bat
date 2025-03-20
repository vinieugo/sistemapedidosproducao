@echo off
echo Instalando PM2 globalmente...
call npm install -g pm2

echo Instalando dependencias adicionais...
call npm install express compression --save

echo Instalando dependencias do projeto...
call npm install

echo Instalando dependencias do backend...
call npm run install:back

echo Construindo o frontend...
call npm run build

echo Iniciando a aplicacao com PM2...
call npm run start

echo Sistema iniciado com sucesso!
echo Para monitorar a aplicacao, use: npm run monit
echo Para verificar o status, use: npm run status
echo Para ver os logs, use: npm run logs
pause 