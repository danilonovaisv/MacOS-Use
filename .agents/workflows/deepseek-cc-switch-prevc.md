---
description: Executar PREVC para documentacao e configuracao controlada do DeepSeek no Claude Code via CC Switch.
---

# Workflow: DeepSeek CC Switch PREVC

Argumentos: escopo, objetivo, arquivos aprovados e se existe autorizacao para mutacao.

## Estados

`INTAKE -> SCANNED -> PLANNED -> AWAITING_APPROVAL -> EXECUTING -> POST_PROCESSED -> VALIDATED -> CONFIRMED`

Qualquer violacao de seguranca leva a `BLOCKED`.

## 1. Intake

- Registrar publico, resultado esperado, versao local observada e limites.
- Separar documentacao, configuracao real e alteracao de codigo.
- Tratar o pedido atual como autorizacao apenas para o escopo explicitamente escrito pelo usuario.

## 2. Repository scan

- Consultar Graphify primeiro.
- Inventariar `AGENTS.md`, `.agents/`, `.context/`, `artifacts/`, scripts e provider DeepSeek.
- Nao ler `.env*`, keychain, SSH, credentials, secrets, browser state ou configuracoes pessoais.
- Preservar mudancas nao relacionadas.

## 3. Documentation audit

- Validar DeepSeek e Claude Code em fontes atuais.
- Inspecionar CC Switch somente em telas sem dados sensiveis.
- Classificar cada afirmacao: `verificado em <data>` ou `⚠️ Verificar`.
- Separar Anthropic-compatible, OpenAI-compatible e execucao local.

## 4. Planning artifacts

- Atualizar `implementation_plan.md`, `task.md` e `risk_assessment.md`.
- Definir allowlist, rollback, evidencia e criterios de sucesso.
- Planejar scanner que nao imprima matches.

## 5. Human approval gate

Antes de instalacao, escrita em configuracao pessoal, chave real, shell mutavel, rede autenticada ou permissao macOS, apresentar:

- acao exata;
- destino e dados envolvidos;
- risco;
- rollback;
- evidencia esperada.

Prosseguir somente com aprovacao pontual aplicavel a essa acao. Aprovacao documental nao autoriza configuracao real.

## 6. Controlled execution

- Seguir `task.md` em ordem.
- Manter secrets fora de arquivos, argumentos e logs.
- Pausar Computer Use durante entrada humana da chave.
- Confirmar endpoint antes de salvar ou testar.
- Parar na primeira divergencia critica.

## 7. Post-processing

- Padronizar `DeepSeek`, `CC Switch`, `Claude Code`, `Anthropic-compatible` e `OpenAI-compatible`.
- Remover duplicidades e comandos sem classificacao.
- Confirmar que Ollama/LM Studio estao fora do caminho principal.
- Executar secret scan na allowlist.
- Registrar `Post-processing Report` em `walkthrough.md`.

## 8. Validation

- Confirmar arquivos, titulos, frontmatter, JSON, links e placeholders.
- Verificar que nenhuma permissao/configuracao real foi alterada sem gate.
- Validar troubleshooting, rollback e checklist.
- Anexar somente evidencia sanitizada.

## 9. Final confirmation

- `STATUS FINAL: APROVADO PARA REVISAO HUMANA` quando todos os criterios documentais passam.
- `STATUS FINAL: BLOQUEADO POR PENDENCIAS` diante de qualquer falha obrigatoria.
- Nunca declarar que a integracao real funciona sem chamada autorizada e evidencia fresca.

