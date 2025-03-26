@echo off
echo Iniciando sistema de pedidos...
cd /d "%~dp0"
pm2 delete all
pm2 start backend/src/server.js --name "backend" --time
pm2 start "npm run preview" --name "frontend" --cwd frontend --time
pm2 save
echo Sistema iniciado com sucesso!
pause 