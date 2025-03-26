# Verifica se está rodando como administrador
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Este script precisa ser executado como Administrador!"
    Break
}

# Configurações
$usuario = "app"
$pastaBase = "C:\Users\app\Documents\Sistema-Pedidos"

Write-Host "Configurando permissões para o usuário $usuario..." -ForegroundColor Green

# Lista de pastas para configurar permissões
$pastas = @(
    $pastaBase,
    "C:\Program Files\nodejs",
    "C:\Users\app\AppData\Roaming\npm",
    "C:\Users\app\AppData\Local\npm",
    "C:\Users\app\AppData\Local\npm-cache",
    "C:\Users\app\AppData\Roaming\npm-cache",
    "C:\Users\app\AppData\Local\Programs\nodejs",
    "C:\Users\app\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\nodejs"
)

# Função para configurar permissões recursivamente
function Set-PermissionsRecursive {
    param (
        [string]$Path,
        [string]$User,
        [string]$Permission = "FullControl"
    )
    
    try {
        if (Test-Path $Path) {
            Write-Host "Configurando permissões em: $Path" -ForegroundColor Yellow
            
            # Configura permissões na pasta principal
            $acl = Get-Acl $Path
            $acl.SetAccessRuleProtection($false, $true)
            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($User, $Permission, "ContainerInherit,ObjectInherit", "None", "Allow")
            $acl.AddAccessRule($rule)
            Set-Acl $Path $acl -ErrorAction Stop
            
            # Configura permissões em todos os arquivos e subpastas
            Get-ChildItem -Path $Path -Recurse | ForEach-Object {
                $acl = Get-Acl $_.FullName
                $acl.SetAccessRuleProtection($false, $true)
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($User, $Permission, "ContainerInherit,ObjectInherit", "None", "Allow")
                $acl.AddAccessRule($rule)
                Set-Acl $_.FullName $acl -ErrorAction Stop
            }
            
            Write-Host "Permissões configuradas com sucesso em: $Path" -ForegroundColor Green
        } else {
            Write-Host "Pasta não encontrada: $Path" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Erro ao configurar permissões em $Path : $_" -ForegroundColor Red
    }
}

# Configura permissões em todas as pastas
foreach ($pasta in $pastas) {
    Set-PermissionsRecursive -Path $pasta -User $usuario
}

# Tenta instalar o PM2 globalmente
Write-Host "Instalando PM2 globalmente..." -ForegroundColor Yellow
try {
    npm install -g pm2 --force
    Write-Host "PM2 instalado com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "Erro ao instalar PM2: $_" -ForegroundColor Red
}

# Tenta limpar o cache do npm
Write-Host "Limpando cache do npm..." -ForegroundColor Yellow
try {
    npm cache clean --force
    Write-Host "Cache do npm limpo com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "Erro ao limpar cache do npm: $_" -ForegroundColor Red
}

Write-Host "`nProcesso de configuração de permissões concluído!" -ForegroundColor Green
Write-Host "Por favor, reinicie o computador para aplicar todas as alterações." 