@echo off
echo ======================================================
echo  CONFIGURANDO BANCO DE DADOS DO SISTEMA DE PEDIDOS
echo ======================================================

echo [1/3] Verificando MySQL...
set MYSQL_CMD=mysql -u root -proot --port=3307

echo.
echo [2/3] Criando banco de dados...
echo CREATE DATABASE IF NOT EXISTS `sistema-pedidos2` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; > create_db.sql

echo.
echo [3/3] Executando migracao do Prisma...
cd backend
call npx prisma db push --accept-data-loss
cd ..

echo.
echo ==============================================
echo        BANCO DE DADOS CONFIGURADO!
echo ==============================================
echo.
echo Para verificar se o banco foi criado corretamente, execute:
echo  "mysql -u root -proot --port=3307 -e 'SHOW DATABASES;'"
echo.
pause 