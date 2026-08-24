# Plano de Implementacao: DeepSeek CC Switch

Data de referencia: 2026-08-24
Estado: aprovado para execucao documental pelo pedido atual do usuario
Escopo: pacote PREVC para orientar agentes; nenhuma credencial ou configuracao real sera alterada

## Resumo executivo

Este pacote transforma `artifacts/DEEPSEEK_CC_SWITCH.md` em contratos operacionais para revisar, documentar e validar o uso da API cloud do DeepSeek no Claude Code por meio do CC Switch. A entrega separa tres superficies que nao devem ser confundidas:

1. CC Switch e Claude Code usam a interface Anthropic-compatible do DeepSeek.
2. O provider Python existente em `macos_use/providers/deepseek/llm.py` usa a interface OpenAI-compatible.
3. Ollama e LM Studio sao alternativas locais fora do caminho principal.

## Estado atual

- O repositorio ja possui `AGENTS.md`, `GEMINI.md`, `CLAUDE.md`, `.agents/`, `.context/`, scripts e um provider Python DeepSeek.
- Nao havia pacote PREVC dedicado ao CC Switch antes desta implementacao.
- A instalacao local do CC Switch 3.20.0 exibe um preset `DeepSeek` na area Claude Code.
- O formulario do CC Switch pode incorporar configuracao comum com dados sensiveis; evidencias visuais desse formulario devem ser evitadas ou redigidas.
- A documentacao DeepSeek consultada em 2026-08-24 informa:
  - OpenAI-compatible: `https://api.deepseek.com`.
  - Anthropic-compatible: `https://api.deepseek.com/anthropic`.
  - modelos atuais: `deepseek-v4-pro` e `deepseek-v4-flash`.
  - os aliases `deepseek-chat` e `deepseek-reasoner` foram descontinuados em 2026-07-24.
- O provider Python local ainda usa os aliases descontinuados e `https://api.deepseek.com/v1`; sua correcao fica fora desta entrega documental e esta registrada como pendencia.
- Existe uma alteracao nao relacionada em `SCRIPTS-MACREPAIR/mac-cleanup-py`; ela nao sera tocada.

## Arquitetura agentica

| Papel | Responsabilidade | Limite |
|---|---|---|
| Coordenador PREVC | Sequenciar intake, auditoria, gate, execucao e confirmacao | Nao amplia escopo nem aprovacoes |
| Revisor tecnico | Conferir DeepSeek, Claude Code, CC Switch e comandos | Marca estado externo como `⚠️ Verificar` |
| Auditor de seguranca | Revisar segredos, permissoes, logs e evidencias | Nao abre `.env`, keychain ou configuracoes pessoais |
| Revisor de documentacao | Normalizar termos e walkthrough | Nao transforma exemplos em comandos executados |
| Pos-processador | Verificar consistencia entre artefatos | Falha fechado diante de segredo ou ambiguidade |

O coordenador produz uma unica saida auditavel. Revisores podem trabalhar em paralelo somente em tarefas de leitura sem efeitos colaterais.

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

## Arquivos editados

- Nenhum arquivo global existente sera sobrescrito.
- `GEMINI.md` permanece intacto; `.agents/rules/deepseek-cc-switch.md` e o equivalente de rules com escopo explicito.
- A wiki duravel e o log de sessao serao atualizados conforme a governanca do repositorio.

## Dependencias

- Nenhuma dependencia sera instalada.
- Context7 foi usado apenas para consulta de documentacao.
- O exemplo MCP usa placeholders e nao ativa servidor algum.
- `jq` ou `python -m json.tool` pode validar o exemplo JSON se ja estiver disponivel.
- Um scanner dedicado como Gitleaks e recomendado antes de release, mas `⚠️ Verificar` disponibilidade local.

## Riscos tecnicos

- Preset do CC Switch mudar entre versoes.
- Endpoint Anthropic-compatible ou catalogo de modelos mudar.
- Claude Code alterar variaveis de gateway ou descoberta de modelos.
- O provider Python local divergir do fluxo CC Switch e induzir documentacao incorreta.
- Homebrew/cask ser citado sem confirmacao oficial.

## Riscos de seguranca

- Chave aparecer em formulario, configuracao comum, screenshot, clipboard, log ou export.
- Endpoint incorreto receber a chave e o conteudo de prompts.
- Permissoes de Accessibility, Screen Recording, Automation ou Full Disk Access serem concedidas de forma ampla.
- Comando, argumento de processo ou historico de shell conter segredo.
- Scanner imprimir o proprio segredo ao reportar um achado.

As mitigacoes detalhadas estao em `risk_assessment.md` e `.agents/policies/permissions.md`.

## Decisoes com aprovacao humana

- Instalar ou atualizar CC Switch, Claude Code ou dependencias.
- Inserir, trocar, revogar ou testar uma API key real.
- Salvar ou habilitar um provider no CC Switch.
- Executar chamadas reais ao DeepSeek.
- Alterar configuracoes do shell, Claude Code, macOS ou permissoes.
- Corrigir o provider Python local.
- Fazer commit, push, deploy, release ou limpeza de historico Git.

## Rollback

1. Documentacao: remover somente os arquivos listados em "Arquivos criados".
2. CC Switch: nenhuma alteracao real faz parte desta execucao; em uma execucao futura, exportar apenas configuracao sanitizada e reativar o provider anterior pelo app.
3. Claude Code: encerrar a sessao iniciada pelo CC Switch e restaurar o provider anterior; nao persistir chaves em arquivos versionaveis.
4. Permissoes macOS: revogar concessoes temporarias no painel Privacy & Security.
5. Credencial exposta: parar, revogar/rotacionar e tratar limpeza de logs/historico como incidente separado.

## Criterios de sucesso

- Os onze arquivos planejados existem nos caminhos definidos.
- Todo segredo e representado por placeholder.
- O JSON MCP e parseavel e inativo ate substituicao consciente dos placeholders.
- O fluxo cloud Anthropic-compatible esta separado do provider Python OpenAI-compatible e das alternativas locais.
- Todo estado externo mutavel tem data ou `⚠️ Verificar`.
- O walkthrough registra o que foi e nao foi executado.
- A validacao nao le `.env`, keychains ou configuracoes pessoais.
- O pos-processamento nao encontra duplicidades criticas, segredo real ou comando destrutivo.

## Incertezas

- ⚠️ Verificar requisito minimo de macOS da versao de CC Switch usada pelo leitor.
- ⚠️ Verificar origem oficial, assinatura/notarizacao e metodo de instalacao do CC Switch antes de instalar.
- ⚠️ Verificar o endpoint e o mapeamento de modelos preenchidos pelo preset DeepSeek antes de salvar.
- ⚠️ Verificar se o CC Switch armazena a chave no Keychain ou em arquivo e como redige exports/logs.
- ⚠️ Verificar o header de autenticacao efetivamente emitido pelo preset sem expor a chave.
- ⚠️ Verificar os modelos disponiveis na conta DeepSeek no momento da execucao.
- ⚠️ Verificar disponibilidade de um scanner dedicado de segredos no ambiente.
- ⚠️ Verificar e corrigir separadamente o provider Python legado.
