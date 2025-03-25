@echo off
echo Iniciando sistema com PowerShell (versao minima)...
powershell.exe -ExecutionPolicy Bypass -Command "& '%~dp0iniciar-sistema-minimo.ps1'"
pause 