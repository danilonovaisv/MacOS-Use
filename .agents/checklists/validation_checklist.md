# Checklist de Validacao: DeepSeek CC Switch

Use `[x]` somente com evidencia fresca registrada no walkthrough.

## Estrutura

- [x] Os onze arquivos do pacote existem.
- [x] Todo Markdown possui titulo H1.
- [x] A skill possui frontmatter com `name` e `description`.
- [x] O JSON MCP e parseavel.
- [x] Nenhum arquivo global foi sobrescrito.

## Clareza tecnica

- [x] O caminho principal e DeepSeek cloud via CC Switch/Claude Code.
- [x] Anthropic-compatible e OpenAI-compatible estao separados.
- [x] Claude Code e descrito como cliente/ambiente de teste, nao backend.
- [x] Ollama e LM Studio aparecem somente como alternativas locais.
- [x] Endpoints, modelos e versoes possuem data ou `⚠️ Verificar`.
- [x] Comandos estao marcados como exemplo, verificado ou `⚠️ Verificar`.
- [x] Fluxo de instalacao nao inventa cask ou origem.
- [x] Fluxo de teste e rollback sao claros.
- [x] Troubleshooting esta presente no walkthrough.

## Seguranca

- [x] Placeholders substituem todos os segredos.
- [x] Nenhum `.env*`, keychain, credential ou browser state foi lido.
- [x] Nenhum segredo aparece em arquivo, terminal, screenshot ou log.
- [x] Evidencias visuais foram evitadas ou redigidas.
- [x] Nenhuma permissao macOS foi concedida.
- [x] Nenhuma configuracao real do CC Switch/Claude Code foi alterada.
- [x] O secret scan ficou restrito a allowlist e nao imprimiu matches.
- [x] Host/TLS/redirect constam como gate do teste real.

## Pos-processamento

- [x] Terminologia padronizada.
- [x] Duplicidades criticas removidas.
- [x] Links internos existentes validados.
- [x] Divergencias e pendencias aparecem como `⚠️ Verificar`.
- [x] Relatorio de pos-processamento anexado ao walkthrough.

## Evidencia final

- [x] Comandos e exit codes de validacao registrados.
- [x] Lista de arquivos criados registrada.
- [x] O que nao foi executado esta explicito.
- [x] Status final corresponde aos resultados, sem extrapolacao.
