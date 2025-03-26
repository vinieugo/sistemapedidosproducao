# Verifica se está rodando como administrador
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Este script precisa ser executado como Administrador!"
    Break
}

# Configurações
$usuario = "app"
$pastaBase = "C:\Users\app\Documents\Sistema-Pedidos"

Write-Host "Configurando permissões para o usuário $usuario..." -ForegroundColor Green

# Adiciona o usuário ao grupo de administradores usando net localgroup
Write-Host "Adicionando usuário ao grupo de administradores..." -ForegroundColor Yellow
try {
    $result = net localgroup "Administrators" $usuario /add
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Usuário adicionado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Usuário já está no grupo de administradores." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Erro ao adicionar usuário ao grupo: $_" -ForegroundColor Red
}

# Configura permissões na pasta do sistema
Write-Host "Configurando permissões na pasta do sistema..." -ForegroundColor Yellow
try {
    if (Test-Path $pastaBase) {
        $acl = Get-Acl $pastaBase
        $acl.SetAccessRuleProtection($false, $true)
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($usuario, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule)
        Set-Acl $pastaBase $acl -ErrorAction Stop
        Write-Host "Permissões configuradas com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Pasta do sistema não encontrada: $pastaBase" -ForegroundColor Red
    }
} catch {
    Write-Host "Erro ao configurar permissões na pasta do sistema: $_" -ForegroundColor Red
}

# Configura permissões no Node.js
Write-Host "Configurando permissões no Node.js..." -ForegroundColor Yellow
try {
    $nodePath = "C:\Program Files\nodejs"
    if (Test-Path $nodePath) {
        $acl = Get-Acl $nodePath
        $acl.SetAccessRuleProtection($false, $true)
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($usuario, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule)
        Set-Acl $nodePath $acl -ErrorAction Stop
        Write-Host "Permissões do Node.js configuradas com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Node.js não encontrado em: $nodePath" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Erro ao configurar permissões do Node.js: $_" -ForegroundColor Red
}

# Configura permissões no npm
Write-Host "Configurando permissões no npm..." -ForegroundColor Yellow
try {
    $npmPath = "C:\Users\app\AppData\Roaming\npm"
    if (Test-Path $npmPath) {
        $acl = Get-Acl $npmPath
        $acl.SetAccessRuleProtection($false, $true)
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($usuario, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule)
        Set-Acl $npmPath $acl -ErrorAction Stop
        Write-Host "Permissões do npm configuradas com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Pasta npm não encontrada: $npmPath" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Erro ao configurar permissões do npm: $_" -ForegroundColor Red
}

Write-Host "`nProcesso de configuração de permissões concluído!" -ForegroundColor Green
Write-Host "Por favor, reinicie o computador para aplicar todas as alterações." 