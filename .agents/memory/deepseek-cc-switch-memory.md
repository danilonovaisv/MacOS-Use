# Memoria Local: DeepSeek CC Switch

Classificacao: `local-noncanonical`
Promocao para Mother Brain: somente com autorizacao humana e fluxo de governanca aplicavel

## Decisoes

- O pacote fica isolado em `artifacts/deepseek-cc-switch/` e `.agents/`.
- `GEMINI.md`, `.agents/rules/GEMINI.md`, `AGENTS.md` e settings globais permanecem intactos.
- A rule especifica usa trigger manual proposto; `⚠️ Verificar` suporte do Antigravity antes de ativar.
- O caminho Claude Code usa a superficie Anthropic-compatible do DeepSeek.
- O provider Python local e uma integracao OpenAI-compatible separada.
- A configuracao real nao faz parte da execucao documental atual.

## Premissas aceitas

- Placeholders sao usados para segredos.
- CC Switch alterna providers para Claude Code no macOS.
- Claude Code e cliente/ambiente de teste.
- Ollama e LM Studio nao fazem parte do caminho principal.

## Validado em 2026-08-24

- A UI local do CC Switch 3.20.0 contem preset DeepSeek para Claude Code.
- DeepSeek documenta `https://api.deepseek.com` para OpenAI-compatible.
- DeepSeek documenta `https://api.deepseek.com/anthropic` para Anthropic-compatible.
- Modelos documentados: `deepseek-v4-pro` e `deepseek-v4-flash`.
- Aliases `deepseek-chat` e `deepseek-reasoner` foram descontinuados em 2026-07-24.
- Claude Code documenta `ANTHROPIC_BASE_URL` e autenticacao de gateway por token ou API key conforme o header esperado.

## Incertezas pendentes

- ⚠️ Verificar requisito minimo de macOS e origem de instalacao.
- ⚠️ Verificar campos e mapeamento gerados pelo preset DeepSeek.
- ⚠️ Verificar armazenamento, redacao de logs e export do CC Switch.
- ⚠️ Verificar modelos habilitados na conta no dia do teste.
- ⚠️ Verificar trigger manual do Antigravity.
- ⚠️ Verificar o provider Python legado em tarefa separada.
- ⚠️ Verificar paths preexistentes com nomes de estado/autenticacao sem abrir seu conteudo.

## Restricoes de seguranca

- Nenhuma leitura de `.env*`, keychain, credential, secret ou browser state.
- Nenhuma chave em arquivo, shell, clipboard, screenshot ou log.
- Nenhuma permissao ampla, instalacao ou chamada autenticada sem gate.

## Historico de validacao

- 2026-08-24: inventario local, Context7, UI read-only e revisoes independentes.
- 2026-08-24: artefatos PREVC criados; validacao final registrada no walkthrough.

## Proximas melhorias

- Corrigir e testar o provider Python com catalogo atual, em escopo separado.
- Fazer teste real do preset com chave inserida pelo humano e prompt nao sensivel.
- Adicionar secret scanner dedicado ao CI, apos avaliacao e aprovacao.
- Promover aprendizados canonicos somente pelo fluxo autorizado.
