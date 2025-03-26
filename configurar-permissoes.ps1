# Verifica se está rodando como administrador
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Este script precisa ser executado como Administrador!"
    Break
}

# Configurações
$usuario = "app"
$pastaBase = "C:\Users\app\Documents\Sistema-Pedidos"

Write-Host "Configurando permissões para o usuário $usuario..." -ForegroundColor Green

# Adiciona o usuário ao grupo de administradores
Write-Host "Adicionando usuário ao grupo de administradores..." -ForegroundColor Yellow
Add-LocalGroupMember -Group "Administrators" -Member $usuario

# Configura permissões na pasta do sistema
Write-Host "Configurando permissões na pasta do sistema..." -ForegroundColor Yellow
$acl = Get-Acl $pastaBase
$acl.SetAccessRuleProtection($false, $true)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($usuario, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.AddAccessRule($rule)
Set-Acl $pastaBase $acl

# Configura permissões no Node.js
Write-Host "Configurando permissões no Node.js..." -ForegroundColor Yellow
$nodePath = "C:\Program Files\nodejs"
if (Test-Path $nodePath) {
    $acl = Get-Acl $nodePath
    $acl.SetAccessRuleProtection($false, $true)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($usuario, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl $nodePath $acl
}

# Configura permissões no npm
Write-Host "Configurando permissões no npm..." -ForegroundColor Yellow
$npmPath = "C:\Users\app\AppData\Roaming\npm"
if (Test-Path $npmPath) {
    $acl = Get-Acl $npmPath
    $acl.SetAccessRuleProtection($false, $true)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($usuario, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl $npmPath $acl
}

Write-Host "Permissões configuradas com sucesso!" -ForegroundColor Green
Write-Host "Por favor, reinicie o computador para aplicar todas as alterações." 