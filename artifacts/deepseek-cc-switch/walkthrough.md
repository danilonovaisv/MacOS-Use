# Walkthrough: DeepSeek via CC Switch no Claude Code

Data: 2026-08-24
Estado documental: validado e pronto para revisao humana
Estado da integracao real: nao configurada nem testada nesta execucao

## Escopo aprovado

O pedido atual autorizou criar e validar o pacote PREVC. Nao autorizou inserir credencial, salvar provider, instalar software, alterar settings, conceder permissoes macOS ou fazer chamada autenticada ao DeepSeek.

## Arquitetura correta

```text
Claude Code -> CC Switch -> DeepSeek Anthropic-compatible
                          -> https://api.deepseek.com/anthropic

Provider Python -> cliente OpenAI-compatible
                -> https://api.deepseek.com

Ollama / LM Studio -> execucao local separada
```

Fontes consultadas em 2026-08-24:

- DeepSeek API: `https://api-docs.deepseek.com`
- DeepSeek Anthropic API: `https://api-docs.deepseek.com/guides/anthropic_api`
- DeepSeek updates: `https://api-docs.deepseek.com/updates`
- Claude Code gateway connect: `https://code.claude.com/docs/en/llm-gateway-connect`
- Claude Code gateway rollout: `https://code.claude.com/docs/en/llm-gateway-rollout`

## Guia de execucao controlada

Estes passos sao para uma futura execucao com aprovacao pontual.

1. Confirmar origem oficial, assinatura/notarizacao, versao do CC Switch e requisito de macOS. Nao inventar cask ou comando de instalacao.
2. Abrir CC Switch e selecionar a area `Claude Code`.
3. Usar o botao de adicionar provider e escolher o preset `DeepSeek`.
4. Antes de inserir a chave, confirmar que o endpoint preenchido pelo preset corresponde a `https://api.deepseek.com/anthropic`. Se divergir, parar e marcar `⚠️ Verificar`.
5. Confirmar que o mapeamento usa um modelo disponivel na conta, atualmente documentado como `deepseek-v4-pro` ou `deepseek-v4-flash`.
6. Desativar capturas e pausar automacao visual. O humano insere a chave diretamente no campo mascarado; o agente nao usa reveal, copy ou clipboard.
7. Revisar a opcao de configuracao comum sem abrir, exportar ou registrar conteudo sensivel. Garantir que o provider nao herda settings fora do escopo.
8. Apresentar o gate com acao, endpoint, dados transmitidos, risco e rollback. Somente apos aprovacao, salvar/habilitar o provider.
9. Executar o connectivity check com prompt sintetico nao sensivel. Nao anexar headers, body ou screenshot do formulario.
10. Abrir uma nova sessao do Claude Code pelo CC Switch e testar uma pergunta minima. Confirmar provider, modelo e resposta; nao concluir compatibilidade de tools apenas com uma resposta textual.
11. Se falhar, reativar o provider anterior e encerrar a sessao de teste.

## Troubleshooting

| Sintoma | Verificacao segura | Acao |
|---|---|---|
| `401` ou autenticacao negada | Confirmar que a chave foi inserida no campo correto, sem revelar; conferir mecanismo de auth do preset | Repetir gate para substituir chave; rotacionar se houve exposicao |
| `404` ou rota inexistente | Conferir somente hostname e path | Usar a superficie Anthropic-compatible no Claude Code; nao usar `/chat/completions` |
| Modelo inexistente | Consultar catalogo atual e modelos habilitados na conta | Trocar apenas apos aprovacao; nao usar aliases descontinuados |
| Provider nao aparece no Claude Code | Confirmar que foi habilitado e que a sessao foi aberta apos a troca | Reiniciar apenas a sessao do Claude Code; preservar provider anterior |
| Resposta textual funciona, tools falham | Verificar suporte Anthropic-compatible a tool use e payloads do Claude Code | Marcar bloqueio tecnico; nao declarar integracao completa |
| CC Switch mostra config comum inesperada | Nao capturar nem expandir dados sensiveis | Cancelar sem salvar e revisar settings em sessao humana separada |
| Rate limit ou saldo insuficiente | Consultar status/conta sem registrar dados pessoais | Reduzir teste e resolver conta fora dos artefatos |
| TLS, proxy ou redirect inesperado | Confirmar host final e certificado | Parar; nunca transmitir a chave |

## Rollback operacional

1. Cancelar o formulario sem salvar se a divergencia for detectada antes do gate.
2. Se o provider ja foi habilitado, reativar o provider anterior no CC Switch.
3. Encerrar sessoes Claude Code abertas com a configuracao de teste.
4. Revogar permissoes macOS temporarias concedidas exclusivamente ao teste.
5. Se uma chave foi exposta, revoga-la/rotaciona-la e tratar limpeza de logs, screenshots, caches ou Git em incidente separado.

## O que foi executado

- Consulta do grafo do repositorio e da wiki.
- Inventario sanitizado de `.agents/`, `.context/`, artifacts e provider DeepSeek.
- Consulta Context7 da documentacao DeepSeek e Claude Code.
- Inspecao read-only do CC Switch 3.20.0 e confirmacao do preset DeepSeek.
- Criacao dos onze arquivos documentais/configuracao de exemplo listados abaixo.
- Revisoes independentes de seguranca, arquitetura e consistencia tecnica.

## O que nao foi executado

- Nenhuma chave foi inserida, copiada, salva, testada ou transmitida.
- Nenhum provider foi criado, habilitado, desabilitado ou excluido.
- Nenhum software/dependencia foi instalado ou atualizado.
- Nenhuma configuracao de Claude Code, shell, MCP ativo ou macOS foi alterada.
- Nenhuma chamada autenticada ao DeepSeek foi feita.
- Nenhum commit, push, deploy, release ou limpeza de historico foi feito.
- `.env*`, keychains, credentials, secrets e browser state nao foram lidos.

## Arquivos criados

- `artifacts/deepseek-cc-switch/implementation_plan.md`
- `artifacts/deepseek-cc-switch/task.md`
- `artifacts/deepseek-cc-switch/risk_assessment.md`
- `artifacts/deepseek-cc-switch/walkthrough.md`
- `.agents/rules/deepseek-cc-switch.md`
- `.agents/skills/deepseek-cc-switch/SKILL.md`
- `.agents/workflows/deepseek-cc-switch-prevc.md`
- `.agents/policies/permissions.md`
- `.agents/mcp/mcp.config.example.json`
- `.agents/checklists/validation_checklist.md`
- `.agents/memory/deepseek-cc-switch-memory.md`

## Arquivos modificados

- Nenhum arquivo global de regras, settings ou codigo foi modificado pelo pacote.
- `graphify-out/` foi reconstruido com sucesso; o Graphify 0.8.47 gerou relatorio, manifest, graph e cache AST atualizados. A skill local ainda declara 0.8.30, portanto a sincronizacao da versao fica como `⚠️ Verificar`.
- A Wiki-Brain recebeu `wiki/deepseek-cc-switch-prevc.md`, uma entrada em `wiki/index.md` e o registro obrigatorio em `log.md`.

## Evidencias

- UI local: preset `DeepSeek` visivel na lista de providers Claude Code do CC Switch 3.20.0.
- Context7: endpoints OpenAI-compatible e Anthropic-compatible, modelos atuais e descontinuacao dos aliases legados.
- Codigo local: `macos_use/providers/deepseek/llm.py` usa o cliente OpenAI-compatible e ainda referencia aliases legados.
- Validacao local: todos os comandos obrigatorios abaixo retornaram exit code `0`.
- Graphify do repositorio: exit `0`, `19836` nodes e `25614` edges.
- Graphify da Wiki-Brain: exit `0`, `32276` nodes e `75322` edges.

## Post-processing Report

Executado em 2026-08-24:

- Termos padronizados: `DeepSeek`, `CC Switch`, `Claude Code`, `Anthropic-compatible` e `OpenAI-compatible`.
- Duplicidades criticas: nenhuma encontrada.
- Segredos: zero arquivos com padroes heurísticos de chave real na allowlist.
- Placeholders inseguros genericos: zero; o guia usa `<DEEPSEEK_API_KEY>` e referencias de ambiente no JSON.
- Cloud versus local: separacao encontrada em oito arquivos do pacote.
- Interface Anthropic-compatible: documentada em nove arquivos do pacote.
- Evidencias visuais: nenhuma screenshot do formulario preenchido foi anexada.
- Scanner dedicado: `⚠️ Verificar`; Gitleaks nao esta instalado. A verificacao atual usou padroes heurísticos sem imprimir matches.

Comandos de evidencia:

- `python3 -m json.tool .agents/mcp/mcp.config.example.json`: exit `0`.
- `.venv/bin/python .../skill-creator/scripts/quick_validate.py .agents/skills/deepseek-cc-switch`: exit `0`, `Skill is valid!`.
- Validador allowlisted de arquivos, titulos, cercas, whitespace, terminologia e segredos: exit `0`.
- Resumo: `files=11`, `missing=0`, `bad_titles=0`, `bad_fences=0`, `suspicious_files=0`, `term_variant_files=0`.

## Checklist final

Resultado: todos os itens documentais foram confirmados. Itens que dependem da integracao real permanecem descritos como `⚠️ Verificar` e nao foram usados para afirmar conectividade.

## Pendencias

- ⚠️ Verificar trigger `manual` no Google Antigravity antes de ativar a rule.
- ⚠️ Verificar atualizacao da skill Graphify local de 0.8.30 para o pacote 0.8.47.
- ⚠️ Verificar requisitos de instalacao e macOS do CC Switch.
- ⚠️ Verificar endpoint e model mapping efetivamente gerados pelo preset.
- ⚠️ Verificar armazenamento/redacao de chave e logs pelo CC Switch.
- ⚠️ Verificar tool use e demais capacidades com teste real autorizado.
- ⚠️ Verificar e corrigir o provider Python legado em tarefa separada.
- ⚠️ Verificar possiveis estados de autenticacao preexistentes do repositorio em auditoria separada, sem abrir conteudo nesta missao.

STATUS FINAL: APROVADO PARA REVISAO HUMANA
