@echo off
echo Configurando permissões do sistema...
powershell.exe -ExecutionPolicy Bypass -Command "& '%~dp0configurar-permissoes.ps1'"
pause 