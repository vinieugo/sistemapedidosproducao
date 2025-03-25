@echo off
echo Iniciando sistema com PowerShell...
powershell.exe -ExecutionPolicy Bypass -Command "& '%~dp0iniciar-sistema.ps1'"
pause 