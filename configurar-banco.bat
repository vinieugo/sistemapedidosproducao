@echo off
echo ======================================================
echo  CONFIGURANDO BANCO DE DADOS DO SISTEMA DE PEDIDOS
echo ======================================================

echo [1/3] Verificando MySQL...
set MYSQL_CMD=mysql -u root -proot --port=3307

echo.
echo [2/3] Verificando banco de dados...
echo USE sistema_pedidos; > verificar_db.sql

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
echo O banco de dados 'sistema_pedidos' ja existe e esta pronto para uso.
echo.
pause 