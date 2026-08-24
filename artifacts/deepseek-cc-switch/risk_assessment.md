# Avaliacao de Riscos: DeepSeek CC Switch

Data: 2026-08-24
Metodo: analise documental, Context7 e inspecao somente leitura da UI local

| ID | Ativo e ameaca | Vetor / precondicao | Prob. | Impacto | Severidade | Controles e evidencia | Risco residual / gate |
|---|---|---|---|---|---|---|---|
| R01 | API key exposta | Campo revelado, config comum, export, clipboard ou screenshot | Media | Critico | Alto | Entrada humana, campo mascarado, sem captura, sem copy/reveal | Medio; gate antes de inserir |
| R02 | Credencial enviada ao host errado | Endpoint digitado ou preenchido incorretamente, redirect/proxy | Baixa | Critico | Alto | Confirmar hostname e TLS; bloquear redirect inesperado | Baixo; gate antes do teste |
| R03 | Segredo em shell ou Git | `export`, argumento de processo, `.env*`, log, backup | Media | Alto | Alto | Placeholder, nenhum segredo em shell, scanner fail-closed | Baixo; rotacao se confirmado |
| R04 | Evidencia vaza dados | Screenshot, toast, erro ou log inclui chave/conta/prompt | Media | Alto | Alto | Nao capturar formulario preenchido; revisao e redacao humana | Baixo; bloquear anexo inseguro |
| R05 | Permissao macOS ampla | Accessibility, Screen Recording, Automation ou Full Disk Access | Media | Alto | Alto | Negar por padrao; concessao minima, temporaria e pontual | Medio; aprovacao no momento |
| R06 | Software nao confiavel | Instalador, cask, origem ou assinatura nao verificados | Baixa | Alto | Alto | Origem oficial, assinatura/notarizacao e hash quando publicado | Baixo; `⚠️ Verificar` antes de instalar |
| R07 | Documentacao alucinada | Versao, endpoint, modelo, cask ou comportamento inventado | Media | Alto | Alto | Fonte/data ou `⚠️ Verificar`; revisao Context7/oficial | Baixo |
| R08 | Formatos confundidos | Endpoint OpenAI usado no Claude Code ou Anthropic usado no provider Python | Media | Medio | Medio | Diagrama conceitual e nomes de superficie em todo artefato | Baixo |
| R09 | Cloud confundida com local | Ollama/LM Studio apresentados como caminho CC Switch | Media | Medio | Medio | Secao explicita: alternativas locais fora do fluxo principal | Baixo |
| R10 | Modelo descontinuado | `deepseek-chat`/`deepseek-reasoner` copiados do codigo local | Alta | Medio | Alto | Usar catalogo atual datado; registrar provider legado | Medio; `⚠️ Verificar` antes do teste |
| R11 | Permissao do agente excessiva | Modo auto interpretado como autorizacao geral | Media | Alto | Alto | Autonomia limitada a leitura e edicao documental allowlisted | Baixo |
| R12 | Mudanca fora do escopo | Agente edita `GEMINI.md`, settings, shell ou provider Python | Baixa | Alto | Medio | Lista fechada de arquivos e diff final | Baixo |
| R13 | MCP amplia acesso | Filesystem, browser ou GitHub ativado com escrita/token | Media | Alto | Alto | Exemplo inativo, workspace restrito, token por ambiente, read-only | Baixo; ativacao exige gate |
| R14 | Estado sensivel preexistente | Perfis de browser ou arquivo com nome de autenticacao ja rastreado | Desconhecida | Alto | Alto | Nao ler conteudo; auditoria/rotacao separada | `⚠️ Verificar` fora desta missao |

## Riscos por categoria

### Credenciais

- Nunca colocar valor real em Markdown, JSON, terminal, argumento de processo, screenshot ou issue.
- O agente nao deve abrir keychain, `.env*`, stores de navegador ou configuracao pessoal para provar ausencia de segredo.
- Em caso de exposicao: parar, nao repetir o valor, revogar/rotacionar, remover de staging e avaliar caches/historico em tarefa separada.

### Instalacao e terminal

- Nao documentar cask ou comando de instalacao como verificado sem fonte oficial e teste controlado.
- Proibir `sudo`, `curl | shell`, comandos destrutivos e comandos que imprimam ambiente completo.
- Read-only allowlisted e validadores locais podem rodar; toda mutacao de sistema exige aprovacao pontual.

### Evidencias e GUI

- Pausar automacao visual durante entrada de chave.
- Nunca usar reveal, copy ou leitura do clipboard.
- Capturar apenas telas sem campos preenchidos; fazer redacao antes de anexar.
- Logs devem conter status, codigo de erro e caminho, nunca headers ou body sensivel.

### Estado externo mutavel

- Endpoints e modelos deste pacote foram verificados em 2026-08-24.
- ⚠️ Verificar na execucao real: versao do CC Switch, requisito de macOS, preset, armazenamento da chave e modelos habilitados na conta.

## Criterios de bloqueio

- Segredo real ou dado pessoal aparece em qualquer artefato/evidencia.
- Endpoint final ou TLS nao pode ser confirmado.
- Permissao ampla permanece ativa sem necessidade.
- Scanner dedicado e revisao manual nao estao disponiveis antes de release.
- Preset do CC Switch diverge do endpoint Anthropic-compatible e a divergencia nao e explicada.

