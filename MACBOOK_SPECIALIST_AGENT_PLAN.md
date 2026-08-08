# Plano do Agente Especialista do MacBook

## Objetivo

Transformar o MacOS-Use em um agente pessoal para este MacBook, capaz de observar,
orientar e executar tarefas no macOS com contexto persistente, limites claros e
verificacao depois de cada acao.

O alvo nao e dar autonomia irrestrita ao agente. O alvo e ter tres niveis de uso:

1. `observe`: leitura e diagnostico, sem alteracoes.
2. `assist`: alteracoes locais e reversiveis, com confirmacao para efeitos externos.
3. `execute`: tarefas aprovadas para a sessao, ainda com bloqueios para operacoes
   destrutivas, privilegiadas, financeiras ou que exponham dados.

## Leitura do projeto

O README descreve um agente Python que usa a arvore de acessibilidade do macOS
para controlar janelas, mouse, teclado, navegador, shell, AppleScript e Spaces.
Ele nao e um aplicativo Swift/AppKit e nao possui sandbox proprio.

Consequencias para a configuracao:

- Accessibility deve ser a fonte de percepcao padrao; visao por screenshot fica
  desligada e so e habilitada quando a arvore de acessibilidade for insuficiente.
- O `shell_tool` e o maior limite de seguranca, pois atualmente aceita comandos
  arbitrarios. Instrucoes de prompt nao bastam; a politica precisa ser aplicada
  em codigo antes de qualquer comando.
- A memoria deve guardar preferencias e resultados operacionais, nunca senhas,
  tokens, conteudo de clipboard ou dados de aplicativos sensiveis.
- A recomendacao do proprio projeto de usar VM ou Mac dedicado deve ser tratada
  como baseline para testes destrutivos. No Mac principal, o agente deve operar
  com permissoes minimas.

## Estado detectado neste MacBook

| Item | Estado | Decisao |
| --- | --- | --- |
| Plataforma | macOS 27.0, Apple Silicon (`arm64`) | Usar apenas pacotes nativos arm64 |
| Shell | Zsh | Scripts compativeis com Zsh/Bash, sem alterar configuracao global |
| Homebrew | Instalado em `/opt/homebrew` | Nao reinstalar |
| `uv` | Instalado | Gerenciar Python e ambiente virtual com `uv` |
| Python do sistema | 3.14.6 | Nao usar como runtime principal |
| Python local do projeto | `.python-version` pede 3.13, mas essa versao nao existe | Corrigir o pin para Python 3.12 |
| Ambiente virtual | Ausente | Criar `.venv` isolada |
| Testes | Pasta `tests/` ausente | Criar smoke tests antes de liberar execucao real |
| CLI | `pyproject.toml` aponta para `macos_use.main:main`, modulo ausente | Corrigir antes do primeiro uso |
| Entrada atual | `main.py` fixa NVIDIA e ativa log em arquivo | Tornar provedor e perfil configuraveis |
| Codex Run | `.codex` e uma pasta; `environment.toml` ainda nao existe | Criar `.codex/environments/environment.toml` |

## Principios obrigatorios

1. Detectar antes de instalar ou alterar.
2. Mostrar o plano da tarefa antes de executar.
3. Uma acao observavel por etapa, seguida de verificacao.
4. Menor permissao e menor escopo possiveis.
5. Nenhuma acao destrutiva, privilegiada ou externa sem confirmacao explicita.
6. Nenhum segredo em prompt, log, memoria, Git ou telemetria.
7. Toda execucao deve ter limite de passos, timeout e criterio de parada.
8. Falha repetida muda a estrategia ou encerra a tarefa; nao repete cliques ou
   comandos indefinidamente.

## Matriz de autorizacao

| Classe | Exemplos | Politica |
| --- | --- | --- |
| Leitura | Consultar versao, listar arquivos, ler calendario local | Automatica no perfil `observe` |
| Local reversivel | Criar rascunho, organizar janela, criar arquivo novo | Permitida em `assist`, com verificacao |
| Externa | Enviar email, publicar, aceitar convite, upload | Confirmar imediatamente antes |
| Sensivel | Ler mensagens, fotos, historico, documentos privados | Escopo explicito por app/pasta e por tarefa |
| Privilegiada | `sudo`, ajustes de seguranca, Full Disk Access | Bloqueada por padrao; sessao administrativa separada |
| Destrutiva | Excluir, sobrescrever, formatar, encerrar processo com dados | Confirmacao com alvo exato e opcao recuperavel |
| Financeira/legal | Comprar, assinar, aceitar termos, transferir valores | Nunca autonomamente |

## Plano de configuracao

### Fase 0: Baseline e recuperacao

- [ ] Confirmar backup recente do Time Machine.
- [ ] Criar um usuario macOS dedicado para os primeiros testes ou usar uma VM.
- [ ] Fechar apps com dados sensiveis durante os testes.
- [ ] Registrar apps permitidos, pastas permitidas e tarefas proibidas.
- [ ] Verificar os links de skills em `.agents/skills` e `.codex/Skills`.

Criterio de aceite: existe um caminho de recuperacao e nenhum teste precisa de
acesso ao usuario administrativo principal.

### Fase 1: Rede e toolchain

- [ ] Testar GitHub, PyPI e fontes do Homebrew.
- [ ] Configurar proxy apenas se o teste falhar e somente para a sessao.
- [ ] Instalar Python 3.12 com `uv`.
- [ ] Alterar o pin local de 3.13 para 3.12.
- [ ] Criar `.venv` e sincronizar exatamente o `uv.lock`.
- [ ] Verificar importacao de PyObjC, Quartz, Cocoa e ApplicationServices.

Comandos previstos para a implementacao:

```bash
uv python install 3.12
uv python pin 3.12
uv venv --python 3.12
uv sync --frozen
```

Criterio de aceite: `uv run python --version` retorna 3.12 e os bindings do macOS
importam sem erro.

### Fase 2: Segredos e privacidade

- [ ] Criar `.env.example` apenas com nomes de variaveis.
- [ ] Manter `.env` fora do Git e com permissao de leitura somente para o usuario.
- [ ] Definir `ANONYMIZED_TELEMETRY=false` como padrao local.
- [ ] Escolher o provedor por variavel, sem modelo fixo no codigo.
- [ ] Adicionar redacao de tokens, emails, paths pessoais e conteudo digitado nos logs.
- [ ] Desligar log em arquivo no perfil padrao; ativar apenas por sessao e com rotacao.

Perfis de provedor recomendados:

- `private`: Ollama local, sem screenshots e sem shell mutavel.
- `standard`: provedor cloud com tool calling, Accessibility e politica de comandos.
- `admin`: nunca persistente; exige confirmacao por acao e encerra ao fim da tarefa.

Criterio de aceite: nenhum segredo aparece em `git status`, logs ou memoria.

### Fase 3: Configuracao do agente especialista

- [ ] Substituir o `main.py` fixo por uma CLI com `--profile`, `--provider`,
  `--browser`, `--dry-run` e `--task`.
- [ ] Corrigir o entrypoint `macos-use` para um modulo existente e testado.
- [ ] Criar uma configuracao versionada, sem segredos, para os tres perfis.
- [ ] Definir `use_accessibility=True`, `use_vision=False`,
  `use_annotation=False` e `auto_minimize=False` como defaults.
- [ ] Definir `disable_loop_detection=False`.
- [ ] Iniciar com `max_steps=12` e `max_consecutive_failures=2`.
- [ ] Adicionar instrucoes pessoais em arquivo separado, revisavel e sem dados secretos.

Configuracao inicial recomendada:

```python
Agent(
    llm=llm,
    mode="normal",
    browser=Browser.SAFARI,
    use_accessibility=True,
    use_vision=False,
    use_annotation=False,
    auto_minimize=False,
    max_steps=12,
    max_consecutive_failures=2,
    log_to_console=True,
    log_to_file=False,
    experimental=False,
    disable_loop_detection=False,
    instructions=policy_instructions,
)
```

Criterio de aceite: a CLI imprime o perfil ativo, o provedor, as permissoes
necessarias e o plano da tarefa antes de agir.

### Fase 4: Guardrails aplicados em codigo

- [ ] Introduzir um `PolicyEngine` antes do registro e da execucao de ferramentas.
- [ ] Permitir registrar ferramentas por perfil, em vez de expor todas sempre.
- [ ] Separar shell de leitura e shell mutavel.
- [ ] Bloquear por parser comandos com `sudo`, exclusao recursiva, escrita em paths
  fora da allowlist, alteracao de TCC/SIP/Gatekeeper e download seguido de execucao.
- [ ] Exigir confirmacao para AppleScript que envia mensagens, modifica apps ou
  interage com System Events fora do escopo aprovado.
- [ ] Validar paths com `Path.resolve()` e allowlists, sem confiar em texto do modelo.
- [ ] Criar um evento `APPROVAL_REQUIRED` com descricao, impacto e alvo exato.
- [ ] Desabilitar memoria, multi-edit e administracao de Spaces nos perfis em que
  essas capacidades nao forem necessarias.

Criterio de aceite: testes demonstram que prompt injection nao consegue escapar
da allowlist nem executar um comando bloqueado.

### Fase 5: Permissoes do macOS

Conceder somente ao executavel real usado para iniciar o agente, preferencialmente
Terminal ou Codex, e nao a aplicativos intermediarios desnecessarios.

- [ ] Accessibility: necessario para ler e controlar elementos da interface.
- [ ] Automation/System Events: conceder por aplicativo, quando AppleScript pedir.
- [ ] Screen Recording: somente se `use_vision=True` for realmente utilizado.
- [ ] Microphone/Speech Recognition: somente quando STT estiver habilitado.
- [ ] Full Disk Access: nao conceder por padrao.
- [ ] Mission Control shortcuts: configurar apenas se gerenciamento de Spaces for usado.

Criterio de aceite: o smoke test de Accessibility passa, e toda permissao adicional
tem uma funcionalidade documentada que a justifica.

### Fase 6: Entrada unica de execucao

Aplicar ao projeto Python o principio do plugin Build macOS Apps: uma unica entrada
local deve preparar, executar, diagnosticar e verificar o processo.

- [ ] Criar `scripts/run_agent.sh` como entrada canonica.
- [ ] Suportar `--check`, `--dry-run`, `--logs` e `--verify`.
- [ ] `--check`: valida Python, dependencias, variaveis e permissoes sem agir.
- [ ] `--dry-run`: gera o plano e as aprovacoes esperadas sem usar ferramentas.
- [ ] `--verify`: executa uma tarefa inofensiva e confirma o resultado.
- [ ] Criar a acao Run em `.codex/environments/environment.toml`, apontando para
  `./scripts/run_agent.sh`.

Fluxo diario previsto:

```bash
./scripts/run_agent.sh --check
./scripts/run_agent.sh --profile observe --task "Resuma o estado do meu Mac"
./scripts/run_agent.sh --profile assist
```

Criterio de aceite: nao existem sequencias manuais diferentes para instalar,
iniciar, verificar e diagnosticar o agente.

### Fase 7: Memoria do especialista

- [ ] Criar schema para preferencias, apps, pastas, atalhos e workflows aprovados.
- [ ] Separar fatos da maquina, preferencias do usuario e historico de tarefas.
- [ ] Definir expiracao e revisao para fatos que podem ficar desatualizados.
- [ ] Nunca armazenar credenciais, conteudo integral de mensagens ou dados de saude,
  financeiros e legais.
- [ ] Toda escrita, atualizacao e exclusao de memoria deve aparecer no log de auditoria.

Criterio de aceite: o usuario consegue listar, revisar, corrigir e apagar toda a
memoria sem iniciar uma tarefa automatizada.

### Fase 8: Testes de seguranca e qualidade

Ordem dos testes:

1. Importacao e configuracao, sem LLM.
2. Percepcao da janela ativa, sem cliques.
3. Abrir e fechar um app descartavel.
4. Criar um rascunho em Notes, sem salvar dados sensiveis.
5. Ler um arquivo dentro de uma pasta de teste.
6. Tentar acessar path fora da allowlist e confirmar bloqueio.
7. Tentar um comando destrutivo simulado e confirmar bloqueio.
8. Injetar instrucoes maliciosas em uma pagina e confirmar que nao viram comandos.
9. Interromper rede/LLM e confirmar encerramento limpo.
10. Atingir o limite de passos e confirmar que nenhuma acao extra ocorre.

Criterio de aceite: todos os testes produzem eventos auditaveis, e nenhum teste
negativo causa efeito real no sistema.

## Ordem de implementacao

1. Corrigir runtime Python e entrypoint da CLI.
2. Desativar telemetria e ajustar logs por padrao.
3. Criar configuracao de perfis e a entrada unica.
4. Implementar PolicyEngine, allowlists e aprovacao humana.
5. Criar smoke tests e testes negativos.
6. Conceder Accessibility e validar o perfil `observe`.
7. Validar o perfil `assist` em usuario dedicado ou VM.
8. Habilitar memoria com schema e auditoria.
9. Considerar o perfil `execute` somente depois de uma semana de uso assistido.

## Definicao de pronto

O agente so deve ser considerado especialista e pronto para uso diario quando:

- a instalacao e reproduzivel pelo lockfile;
- a CLI e o script de execucao funcionam em ambiente limpo;
- a politica de ferramentas e aplicada em codigo;
- telemetria, logs e memoria respeitam a configuracao de privacidade;
- as permissoes do macOS sao minimas e documentadas;
- tarefas externas e destrutivas exigem confirmacao no ultimo instante;
- os testes de prompt injection, path traversal, comandos bloqueados e limite de
  passos passam;
- existe um procedimento simples de interrupcao, auditoria e rollback.

## Itens fora do escopo inicial

- Operacao autonoma sem supervisao.
- Full Disk Access permanente.
- Compras, pagamentos ou aceitacao de contratos.
- Alteracoes de SIP, Gatekeeper, TCC ou FileVault.
- Exclusao definitiva de arquivos.
- Envio autonomo de emails, mensagens, posts ou convites.
- Captura continua de tela, microfone ou clipboard.
