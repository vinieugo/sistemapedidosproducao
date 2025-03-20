# Sistema de Pedidos - Guia de Implantação em Produção

Este guia explica como implantar o Sistema de Pedidos em um ambiente de produção utilizando PM2.

## Requisitos

- Node.js (v14 ou superior)
- NPM (v6 ou superior)
- MySQL (v8 ou superior)

## Passos para Implantação

### 1. Clone o Repositório

```bash
git clone [URL_DO_REPOSITÓRIO]
cd [NOME_DO_DIRETÓRIO]
```

### 2. Configure o Banco de Dados

1. Crie um banco de dados MySQL:
   ```sql
   CREATE DATABASE `sistema-pedidos2`;
   ```

2. Edite o arquivo `backend/.env` com as configurações do seu banco de dados:
   ```
   DATABASE_URL="mysql://[USUARIO]:[SENHA]@[HOST]:[PORTA]/sistema-pedidos2"
   CORS_ORIGIN="*"
   PORT=8081
   HOST="localhost"
   ```

### 3. Implantação Automática

#### No Windows:
Execute o script de configuração:
```
setup.bat
```

#### No Linux/Mac:
Execute o script de configuração:
```bash
chmod +x setup.sh
./setup.sh
```

### 4. Implantação Manual

Se preferir configurar manualmente, siga estes passos:

1. Instale o PM2 globalmente:
   ```bash
   npm install -g pm2
   ```

2. Instale as dependências do projeto:
   ```bash
   npm install
   ```

3. Instale as dependências do backend:
   ```bash
   npm run install:back
   ```

4. Construa o frontend:
   ```bash
   npm run build
   ```

5. Inicie a aplicação com PM2:
   ```bash
   npm run start
   ```

## Verificação da Implantação

1. Verifique se os serviços estão em execução:
   ```bash
   npm run status
   ```

2. Acesse o frontend em:
   ```
   http://[SEU_SERVIDOR]:3000
   ```

3. O backend estará disponível em:
   ```
   http://[SEU_SERVIDOR]:8081
   ```

## Gerenciamento e Manutenção

Para informações sobre monitoramento, manutenção e solução de problemas, consulte o arquivo [MAINTENANCE.md](./MAINTENANCE.md).

## Estrutura da Implantação

- `package.json`: Contém os scripts de produção
- `ecosystem.config.cjs`: Configuração do PM2
- `setup.sh` e `setup.bat`: Scripts de configuração
- `MAINTENANCE.md`: Guia de manutenção 