---
name: deepseek-cc-switch
description: Revisar e produzir guias seguros para configurar a API cloud do DeepSeek no Claude Code por meio do CC Switch no macOS; use quando a tarefa envolver esse fluxo, e nao para execucao local via Ollama ou LM Studio.
---

# DeepSeek CC Switch

Produza um walkthrough verificavel sem inventar estado externo e sem manipular credenciais.

## Contratos relacionados

- Leia `../../rules/deepseek-cc-switch.md` para limites e criterios de parada.
- Leia `../../policies/permissions.md` antes de qualquer acao que escreva, execute, acesse rede ou opere GUI.
- Use `../../workflows/deepseek-cc-switch-prevc.md` para missoes completas.
- Preencha `../../checklists/validation_checklist.md` no fechamento.

## Workflow

1. Consulte o grafo do repositorio e inventarie somente o escopo relevante.
2. Identifique a superficie:
   - Claude Code/CC Switch: DeepSeek Anthropic-compatible.
   - SDK OpenAI ou provider Python local: DeepSeek OpenAI-compatible.
   - Ollama/LM Studio: execucao local, fora do caminho principal.
3. Valide documentacao atual de DeepSeek, Claude Code e CC Switch. Date o resultado.
4. Trate endpoint, modelo, cask, requisito de macOS, preset e armazenamento da chave sem fonte como `⚠️ Verificar`.
5. Escreva o guia com pre-requisitos, passos de UI, teste minimo, troubleshooting, rollback e evidencia sanitizada.
6. Exija aprovacao imediatamente antes de instalar, inserir chave, salvar provider, testar API, alterar permissao ou configurar shell.
7. Execute o pos-processamento e a validacao completa.

## Regras tecnicas

- Nunca transplante `DEEPSEEK_API_KEY` do provider Python para o CC Switch sem validar o mecanismo do preset.
- Nunca use aliases de modelo historicos sem confirmar que ainda existem.
- Nao apresente Claude Code como backend; ele e o cliente/ambiente de teste.
- Nao apresente OpenAI compatibility como prova de compatibilidade direta com Claude Code.

## Segredos e evidencias

- Use `<DEEPSEEK_API_KEY>` em exemplos.
- A entrada de chave real deve ser feita pelo humano, com automacao visual pausada.
- Nao capture formulario preenchido, clipboard, header, body, arquivo de configuracao ou log completo.
- Relate scanners por status, regra e caminho; nunca imprima o valor encontrado.

## Saida minima

- Fatos verificados com fonte/data.
- Passos principais e rollback.
- Troubleshooting por sintoma.
- Lista `⚠️ Verificar`.
- Evidencias e resultado de validacao.

