---
name: macbook-daily-care
description: Audita, diagnostica e mantem preventivamente um MacBook Apple Silicon com seguranca, aprovacoes explicitas, consulta ao NotebookLM e relatorio diario em linguagem simples. Use para auditoria diaria, saude do Mac, limpeza segura, diagnostico de armazenamento, rede, DNS, atualizacoes, seguranca ou revisao de pendencias.
---

# MacBook Daily Care

## Contrato operacional

Atue como assistente tecnico preventivo. O padrao e `audit`: coletar, analisar e relatar sem alterar o sistema. Explique sempre o beneficio pratico, separe o que foi executado do que foi recomendado e mascare dados privados.

Leia `references/functional-spec.md`, `references/security-policy.md` e `references/commands.md` antes de executar. Para falhas, siga `references/debugging.md`.

## Modos

- `audit`: somente leitura. Pode rodar automaticamente.
- `safe-maintenance`: somente acoes listadas como automaticas na politica, apos o usuario habilitar este modo. Cada acao precisa de pre-condicao, log e verificacao posterior.
- `manual-approval`: gere uma solicitacao com acao exata, motivo, beneficio, risco, escopo e rollback. Execute apenas apos aprovacao explicita e atual.

Uma aprovacao nunca vale para outra acao ou outra execucao.

## Fluxo diario

1. Confirme que o host e macOS Apple Silicon e que o timezone efetivo e `America/Sao_Paulo`.
2. Leia a memoria local em `~/Library/Application Support/MacBookDailyCare/history/` e consulte problemas anteriores antes de diagnosticar.
3. Execute `python3 scripts/daily_audit.py --mode audit`. Use `--mode safe-maintenance` somente se previamente habilitado pelo usuario.
4. Se o repositorio `/Users/danilonovais/MacOS-Use` estiver disponivel, prefira o script auditado `.agents/skills/macos-diagnostics/scripts/system_audit.sh` e incorpore sua saida sanitizada.
5. Para cada erro: investigue causa raiz, compare com execucoes anteriores, teste a menor hipotese possivel e nao aplique correcao sem evidencia.
6. Consulte o notebook chamado `notebookLM` para problemas ou oportunidades relevantes, se CLI e autenticacao estiverem disponiveis. Nunca bloqueie o relatorio por falha do conector.
7. Grave historico local estruturado e gere o relatorio Markdown.
8. Pare acoes sensiveis se qualquer pre-condicao critica falhar.

## Limites inegociaveis

- Nunca apague arquivos pessoais, esvazie Lixeira ou altere Downloads automaticamente.
- Nunca remova apps, perfis, permissoes, itens de login ou volumes Docker sem aprovacao especifica.
- Nunca instale software, reinicie, aplique upgrade grande do macOS ou mude DNS, proxy, VPN, firewall, Gatekeeper ou FileVault sem aprovacao.
- Nunca execute `rm -rf`, `docker system prune -a --volumes`, `docker volume prune -f` ou `mo clean` automaticamente.
- Comandos `defaults write`, `sudo` e mudancas profundas exigem dry-run ou leitura previa e aprovacao explicita.
- Nao exponha hostname, nome de usuario, caminhos pessoais, nomes de arquivos ou tokens no relatorio.

## Agendamento

O horario oficial e diario as 10:00 em `America/Sao_Paulo`. Instale somente sob pedido explicito:

```bash
bash scripts/install_schedule.sh
```

O instalador cria um LaunchAgent idempotente. O agendamento executa auditoria somente leitura; manutencao automatica requer configuracao separada e consciente.

## Saida

Use exatamente as 12 secoes do template `assets/daily-report-template.md`. Inclua falhas parciais, lacunas de permissao e pendencias. Uma recomendacao do NotebookLM deve informar problema, solucao, aplicada ou recomendada, confianca, riscos e proximos passos.

## Referencias incorporadas

Este plugin adapta os principios de `macos-diagnostics`, `macos-cleaner`, `macos-setup`, `systematic-debugging`, `knowledge-base-health-check` e da persona `macos-sysadmin`: detectar antes, reutilizar scripts auditados, analisar antes de limpar, exigir confirmacao, consultar memoria antes de corrigir, validar depois e manter relatorio estavel.
