# Guia de Instalação e Configuração do Sistema de Pedidos

Este guia apresenta os passos necessários para instalar e configurar o Sistema de Pedidos em um novo ambiente.

## Requisitos

- Node.js 14+ 
- MySQL 5.7+ (configurado na porta 3307)
- Usuário MySQL: `root` / Senha: `root`
- PM2 (gerenciador de processos para Node.js)
- Máquina na faixa de IP 192.168.5.x

## Passos para Instalação

### 1. Preparação do Ambiente

1. Clone ou extraia os arquivos do sistema para uma pasta de sua preferência
2. Certifique-se de que o MySQL está instalado e configurado na porta 3307
3. Verifique se sua máquina está na faixa de IP 192.168.5.x
4. Certifique-se de que o banco de dados `sistema_pedidos` existe no MySQL

### 2. Configuração do Sistema

Você tem duas opções para configurar e iniciar o sistema:

#### Opção 1: Inicialização Completa (Recomendada)

Execute o script de inicialização completa como administrador:
```
iniciar-completo.bat
```

Este script fará todo o processo de configuração, incluindo:
- Instalação de dependências
- Build do frontend
- Configuração do banco de dados
- Configuração de inicialização automática
- Inicialização do sistema

#### Opção 2: Configuração Passo a Passo

Se preferir fazer a configuração passo a passo, execute os scripts nesta ordem:

1. **configurar-rede.bat** - Configura as definições de rede
   ```
   configurar-rede.bat
   ```

2. **configurar-banco.bat** - Configura o banco de dados
   ```
   configurar-banco.bat
   ```

3. **iniciar-startup.bat** OU **iniciar-servico-windows.bat** - Configura a inicialização automática
   ```
   iniciar-startup.bat
   ```
   ou
   ```
   iniciar-servico-windows.bat
   ```

### 3. Opções de Inicialização do Sistema

Você tem três opções para iniciar o sistema:

1. **iniciar-producao.bat** - Inicia o sistema em janelas de terminal separadas (fácil visualização de logs)
   ```
   iniciar-producao.bat
   ```

2. **iniciar-pm2.bat** - Inicia o sistema usando PM2 com comandos diretos
   ```
   iniciar-pm2.bat
   ```

3. **iniciar-pm2-config.bat** - Inicia o sistema usando PM2 com arquivo de configuração
   ```
   iniciar-pm2-config.bat
   ```

## Inicialização Automática

O sistema pode ser configurado para iniciar automaticamente de duas formas:

### Método 1: PM2 e Agendador de Tarefas

Este método usa PM2 em conjunto com o Agendador de Tarefas do Windows:
```
iniciar-startup.bat
```

### Método 2: Serviços do Windows

Este método configura o frontend e backend como serviços do Windows usando NSSM:
```
iniciar-servico-windows.bat
```

### Método 3: Inicialização Completa

Para configurar tudo de uma vez, incluindo a inicialização automática:
```
iniciar-completo.bat
```

## Acessando o Sistema

- **Frontend**: http://192.168.5.3:5173
- **Backend**: http://192.168.5.3:8081

Para acessar o sistema de outras máquinas na mesma rede, use estes mesmos endereços.

## Configuração de Rede

Este sistema está configurado para funcionar na faixa de IP 192.168.5.x. Para acessar de qualquer máquina na rede:

1. Todas as máquinas devem estar na mesma faixa de IP (192.168.5.x)
2. A máquina que executa o sistema deve ter o IP 192.168.5.3
3. O firewall deve permitir conexões nas portas 5173 (frontend) e 8081 (backend)

## Resolução de Problemas

### Firewall

Certifique-se de que as seguintes portas estão liberadas no firewall:
- 5173 (Frontend)
- 8081 (Backend)
- 3307 (MySQL)

### Banco de Dados

Se encontrar problemas com o banco de dados, verifique:
1. Se o MySQL está rodando na porta 3307
2. Se o usuário `root` com senha `root` tem permissões adequadas
3. Se o banco de dados `sistema_pedidos` já existe e está acessível

### Problemas de Acesso na Rede

Se outras máquinas não conseguirem acessar o sistema:
1. Verifique se a máquina que executa o sistema tem o IP 192.168.5.3
2. Teste se o servidor está acessível fazendo ping para 192.168.5.3
3. Verifique as configurações de firewall da máquina e da rede

### Problemas com Inicialização Automática

Se o sistema não iniciar automaticamente:

1. **Método PM2:**
   - Verifique se o PM2 está instalado globalmente: `npm list -g | findstr pm2`
   - Execute `pm2 startup` e `pm2 save` manualmente
   - Verifique se a tarefa "SistemaPedidos" existe no Agendador de Tarefas do Windows

2. **Método Serviços:**
   - Verifique no Gerenciador de Serviços do Windows (services.msc) se os serviços "SistemaPedidos-Frontend" e "SistemaPedidos-Backend" estão presentes
   - Verifique os logs em `logs/frontend-stdout.log` e `logs/backend-stderr.log`

### Monitoramento com PM2

Para monitorar os serviços iniciados com PM2:
```
pm2 monit
```

Para ver os logs dos serviços:
```
pm2 logs
```

Para parar todos os serviços:
```
pm2 stop all
```

## Suporte

Em caso de dúvidas ou problemas, consulte a documentação do projeto ou entre em contato com o suporte técnico. 