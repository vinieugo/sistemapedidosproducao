# Sistema de Pedidos - Guia de Manutenção

Este documento contém instruções para manutenção e monitoramento do Sistema de Pedidos em ambiente de produção.

## Comandos de Manutenção

Todos os comandos devem ser executados a partir do diretório raiz do projeto.

### Monitoramento

- **Verificar status dos serviços**:
  ```
  npm run status
  ```

- **Monitorar em tempo real**:
  ```
  npm run monit
  ```

- **Visualizar logs**:
  ```
  npm run logs
  ```

- **Visualizar logs específicos do frontend**:
  ```
  pm2 logs sistema-pedidos-frontend
  ```

- **Visualizar logs específicos do backend**:
  ```
  pm2 logs sistema-pedidos-backend
  ```

### Gerenciamento de Serviços

- **Reiniciar todos os serviços**:
  ```
  npm run restart
  ```

- **Parar todos os serviços**:
  ```
  npm run stop
  ```

- **Iniciar todos os serviços**:
  ```
  npm run start
  ```

- **Remover serviços do PM2**:
  ```
  npm run delete
  ```

- **Reiniciar apenas o frontend**:
  ```
  pm2 restart sistema-pedidos-frontend
  ```

- **Reiniciar apenas o backend**:
  ```
  pm2 restart sistema-pedidos-backend
  ```

### Backup e Restauração do Banco de Dados

Os seguintes comandos estão disponíveis para gerenciamento do banco de dados:

- **Criar backup do banco de dados**:
  ```
  cd backend && npm run backup
  ```

- **Restaurar backup do banco de dados**:
  ```
  cd backend && npm run restore
  ```

- **Resetar banco de dados** (use com cuidado):
  ```
  cd backend && npm run reset
  ```

## Atualização da Aplicação

Para atualizar a aplicação quando houver mudanças no código:

1. Pare os serviços:
   ```
   npm run stop
   ```

2. Atualize o código (git pull ou outra forma)

3. Reconstrua o frontend:
   ```
   npm run build
   ```

4. Inicie os serviços novamente:
   ```
   npm run start
   ```

## Solução de Problemas

- **Verificar uso de recursos**:
  ```
  pm2 monit
  ```

- **Limpar todos os logs**:
  ```
  pm2 flush
  ```

- **Salvar configuração atual do PM2**:
  ```
  pm2 save
  ```

- **Restaurar configuração salva do PM2**:
  ```
  pm2 resurrect
  ``` 