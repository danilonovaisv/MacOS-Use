---
description: Workflow para auditar scripts existentes, aplicar configurações macOS e registrar no banco de dados.
---

# Workflow: /macos-sync-db

> **Propósito:** Executar tarefas de manutenção constantes e atualizar o CMDB.  
> **Agente Responsável:** `@macos-sysadmin`  
> **Ferramentas Permitidas:** Bash, Read, Write, Fetch

## Passo 1: Auditoria do Sistema

1. Leia o script existente em `.agents/skills/macos-diagnostics/scripts/system_audit.sh`. Não crie um novo. Analise seu conteúdo para extrair métricas de hardware (Bateria, CPU, OS Version).
2. Execute o script e capture o JSON de saída (`stdout`).

## Passo 2: Aplicação de Defaults

1. Verifique o arquivo de configurações desejadas em `.context/macos-defaults.json`.
2. Compare com as configurações atuais do sistema utilizando o comando `defaults read`.
3. Aplique as modificações necessárias com `defaults write`. Se a mudança exigir reinicialização do Finder ou Dock, adicione à fila de pós-execução.

## Passo 3: Persistência no Banco de Dados

1. Formate os dados coletados nos Passos 1 e 2.
2. Utilize o script de inserção existente em `src/db/sync.ts` para enviar o payload ao banco de dados Supabase/Local.
3. Confirme o retorno HTTP 200/201.
