# Verifica se está rodando como administrador
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Este script precisa ser executado como Administrador!"
    Break
}

# Configurações
$pastaBase = "C:\Users\app\Documents\Sistema-Pedidos"
$pastaPacote = "C:\Users\app\Documents\Sistema-Pedidos\pacote-completo"
$pastaBackend = "$pastaPacote\backend"
$pastaFrontend = "$pastaPacote\frontend"

Write-Host "Preparando pacote completo do sistema..." -ForegroundColor Green

# Limpa pasta de pacote se existir
if (Test-Path $pastaPacote) {
    Remove-Item -Path $pastaPacote -Recurse -Force
}

# Cria estrutura de pastas
New-Item -ItemType Directory -Path $pastaPacote -Force
New-Item -ItemType Directory -Path $pastaBackend -Force
New-Item -ItemType Directory -Path $pastaFrontend -Force
New-Item -ItemType Directory -Path "$pastaPacote\logs" -Force

# Copia arquivos do backend
Write-Host "Configurando backend..." -ForegroundColor Yellow
Copy-Item -Path "$pastaBase\sistemapedidosproducao-main\backend\*" -Destination $pastaBackend -Recurse -Force

# Instala dependências do backend
Set-Location $pastaBackend
npm install express cors dotenv mysql2
npm install -g pm2

# Copia arquivos do frontend
Write-Host "Configurando frontend..." -ForegroundColor Yellow
Copy-Item -Path "$pastaBase\sistemapedidosproducao-main\frontend\*" -Destination $pastaFrontend -Recurse -Force

# Compila o frontend
Set-Location $pastaFrontend
npm install
npm run build

# Cria arquivo .env para o backend
$envContent = @"
DATABASE_URL="mysql://root:@192.168.5.3:3306/sistema_pedidos"
PORT=8081
"@
$envContent | Out-File -FilePath "$pastaBackend\.env" -Encoding UTF8

# Cria script de inicialização
$scriptInicializacao = @"
@echo off
echo Iniciando sistema de pedidos...
cd /d "%~dp0"
pm2 delete all
pm2 start backend/src/server.js --name "backend" --time
pm2 start "npm run preview" --name "frontend" --cwd frontend --time
pm2 save
echo Sistema iniciado com sucesso!
pause
"@
$scriptInicializacao | Out-File -FilePath "$pastaPacote\iniciar-sistema.bat" -Encoding UTF8

# Cria arquivo README
$readmeContent = @"
# Sistema de Pedidos - Pacote Completo

## Instruções de Instalação

1. Extraia todos os arquivos para C:\Users\app\Documents\Sistema-Pedidos
2. Execute iniciar-sistema.bat como administrador
3. O sistema estará disponível em:
   - Frontend: http://192.168.5.3:5173
   - Backend: http://192.168.5.3:8081

## Requisitos
- Windows 10 ou superior
- MySQL instalado e configurado
- Node.js instalado
- PM2 instalado globalmente

## Configurações
- IP: 192.168.5.3
- Porta Backend: 8081
- Porta Frontend: 5173
- Banco de Dados: sistema_pedidos
- Usuário: root
- Senha: (vazia)
"@
$readmeContent | Out-File -FilePath "$pastaPacote\README.md" -Encoding UTF8

# Compacta o pacote
Write-Host "Compactando pacote..." -ForegroundColor Yellow
Compress-Archive -Path "$pastaPacote\*" -DestinationPath "$pastaPacote\sistema-pedidos-completo.zip" -Force

Write-Host "Pacote preparado com sucesso!" -ForegroundColor Green
Write-Host "Local do pacote: $pastaPacote\sistema-pedidos-completo.zip" 