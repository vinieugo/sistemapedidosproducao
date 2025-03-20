@echo off
echo Instalando compression...
call npm install compression --save

echo Parando servicos...
call pm2 delete all

echo Limpando cache do PM2...
call pm2 flush

echo Iniciando servicos novamente...
call npm run start

echo Sistema reiniciado com sucesso!
echo Para monitorar a aplicacao, use: npm run monit
echo Para verificar o status, use: npm run status
echo Para ver os logs, use: npm run logs
pause 