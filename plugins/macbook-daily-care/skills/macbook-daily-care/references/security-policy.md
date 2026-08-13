# Politica de seguranca e aprovacoes

## Matriz de decisao

| Classe | Exemplos | Regra |
|---|---|---|
| R0 leitura | inventario, uso, status, updates | Automatico |
| R1 escrita propria | logs, snapshots, relatorios | Automatico |
| R2 reversivel opt-in | flush DNS, cache temporario explicitamente allowlisted | Apenas `safe-maintenance`, com log e verificacao |
| R3 sensivel | apagar arquivo, app, login item, permissao, rede permanente | Aprovacao explicita por acao |
| R4 critica | FileVault, Gatekeeper, firewall, perfil, upgrade, reboot, APFS | Dry-run/leitura previa, risco e aprovacao explicita |
| Proibida | destruicao ampla, bypass de seguranca, segredo em log | Nunca |

O modo agendado inicia em R0/R1. R2 somente quando o usuario habilitou manutencao segura de forma persistente e a acao continua na allowlist. R3/R4 nunca herdam aprovacao antiga.

## Envelope de aprovacao

Uma solicitacao deve mostrar: ID unico, comando/operacao exata, alvos resolvidos sem glob amplo, motivo, beneficio, risco, efeito colateral, privilegio, rollback, verificacao e validade. A resposta deve citar o ID. Alteracao de escopo invalida a aprovacao.

## Rollback

- Flush DNS: nao ha estado a restaurar; caches sao reconstruidos automaticamente.
- Arquivo temporario allowlisted: mover para quarentena propria antes de excluir; restaurar ao caminho original enquanto retido.
- Preferencia: exportar valor atual, aplicar somente apos aprovacao, restaurar valor anterior e reiniciar apenas o processo informado.
- LaunchAgent: `bash scripts/uninstall_schedule.sh`; preserva historico e relatorios.
- Atualizacao: registrar versao anterior; rollback depende do fornecedor e nunca deve ser prometido quando nao suportado.

## Privacidade

Redija username, hostname, endereco IP, SSID, email e caminhos sob o home. Nomes de arquivos pessoais viram categoria e tamanho. Nunca capture conteudo de documentos, historico de navegador, tokens, cookies ou valores de variaveis de segredo.

## Falha segura

Quando houver duvida: nao executar, marcar `revisar manualmente`, explicar o risco e oferecer o menor proximo passo de leitura. Se preflight, integridade ou logging falhar, bloqueie toda manutencao.
