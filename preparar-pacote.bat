@echo off
echo Preparando pacote completo do sistema...
powershell.exe -ExecutionPolicy Bypass -Command "& '%~dp0preparar-pacote.ps1'"
pause 