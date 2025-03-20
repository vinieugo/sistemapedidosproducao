# Sistema de Backup - Sistema de Pedidos

Este documento explica como realizar backup e restauração do banco de dados do sistema.

## Pré-requisitos

1. PostgreSQL instalado na máquina (com comandos `pg_dump` e `psql` disponíveis)
2. Node.js instalado
3. Arquivo `.env` configurado com a URL do banco de dados

## Realizando Backup

Para fazer backup do banco de dados:

1. Navegue até a pasta backend:
```bash
cd backend
```

2. Execute o comando de backup:
```bash
npm run backup
```

O backup será salvo na pasta `backend/backups` com o nome no formato:
`backup_AAAAMMDD_HHMM.sql`

## Restaurando Backup

Para restaurar um backup em outra máquina:

1. Primeiro, copie o arquivo de backup da pasta `backend/backups` para a mesma pasta na nova máquina

2. Configure o arquivo `.env` na nova máquina com as credenciais do novo banco de dados:
```
DATABASE_URL="postgresql://usuario:senha@localhost:5432/nome_do_banco"
```

3. Navegue até a pasta backend:
```bash
cd backend
```

4. Execute o comando de restauração informando o nome do arquivo:
```bash
npm run restore nome_do_arquivo_backup.sql
```

## Backup Automático

Para configurar backup automático:

### Windows (Agendador de Tarefas)

1. Abra o Agendador de Tarefas
2. Crie uma nova tarefa
3. Configure para executar diariamente
4. Adicione a ação:
   - Programa: `npm`
   - Argumentos: `run backup`
   - Iniciar em: `caminho_completo_para_pasta_backend`

### Linux/Mac (Cron)

1. Abra o crontab:
```bash
crontab -e
```

2. Adicione a linha para backup diário às 23h:
```
0 23 * * * cd /caminho_completo_para_pasta_backend && npm run backup
```

## Observações Importantes

1. Mantenha backups em local seguro
2. Faça backup antes de atualizações do sistema
3. Teste periodicamente a restauração dos backups
4. Mantenha um histórico de pelo menos 7 dias de backups

## Solução de Problemas

Se encontrar erros:

1. Verifique se o PostgreSQL está instalado e acessível
2. Confirme se as credenciais no `.env` estão corretas
3. Verifique permissões de acesso às pastas
4. Confira se há espaço em disco suficiente 