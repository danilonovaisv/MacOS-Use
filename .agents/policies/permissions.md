# Politica de Permissoes: DeepSeek CC Switch

Escopo: missoes conduzidas pela skill `deepseek-cc-switch`. Esta politica e declarativa e nao substitui controles tecnicos do sistema.

## Principios

- Menor privilegio, aprovacao pontual e raiz limitada ao workspace.
- Resolver paths e negar escape por symlink antes de escrever.
- Separar leitura, escrita, execucao, rede, GUI, captura e credenciais.
- Nenhuma aprovacao generica ou permanente.

## Sempre permitido

- Consultar Graphify e indices do projeto.
- Ler arquivos publicos do workspace listados na allowlist da tarefa.
- Analisar texto e gerar plano em memoria.
- Validar arquivos novos do pacote com comandos read-only que nao imprimam segredos.
- Consultar documentacao publica sem autenticacao e sem transmitir dados do usuario.

## Exige aprovacao no momento da acao

- Criar ou editar arquivos fora da allowlist documental aprovada.
- Executar comando shell que modifique sistema, configuracao ou dependencia.
- Instalar ou atualizar CC Switch, Claude Code, Homebrew package ou outra dependencia.
- Inserir, salvar, substituir, revogar ou testar uma API key real.
- Salvar/habilitar/desabilitar provider no CC Switch.
- Fazer chamada autenticada ao DeepSeek ou transmitir prompt real.
- Abrir browser externo com login, fazer upload ou usar automacao de browser.
- Conceder Accessibility, Screen Recording, Automation, Files/Folders ou Full Disk Access.
- Alterar shell profile, settings do Claude Code, MCP ativo, permissao, Git history, commit, push, deploy ou release.

## Sempre negado

- Expor ou reproduzir API key, token, cookie, senha, header Authorization ou credential.
- Ler `.env*`, `.ssh/`, keychains, `credentials`, `secrets`, cookies, browser state, Login Data, Local State, arquivos de autenticacao ou configuracoes pessoais fora do escopo.
- Usar reveal/copy de segredo, ler clipboard ou capturar formulario preenchido.
- Colocar segredo em argumento de processo, historico de shell, log, screenshot, Markdown, JSON ou Git.
- Executar `sudo`, comando destrutivo, `curl | shell`, deploy automatico, commit automatico ou remocao de historico.
- Acessar arquivos fora do workspace sem autorizacao especifica.

## Rede

- Antes de transmitir dados, confirmar host oficial, TLS valido e ausencia de redirect inesperado.
- Testes documentais usam placeholders; testes reais usam o menor prompt nao sensivel possivel.
- Context7 e outras fontes de documentacao sao consulta read-only e nao recebem codigo proprietario, credenciais ou dados pessoais.

## Computer Use

- Leitura de UI sem campos sensiveis e permitida.
- A entrada de chave e feita pelo humano; a automacao visual deve pausar.
- Nao aceitar permissao inesperada nem salvar configuracao real sem gate.
- Evidencia visual precisa de inspecao e redacao antes de anexar.

## Incidente

Se um segredo for observado: parar; nao repetir; identificar apenas categoria e local; revogar/rotacionar; remover de staging; avaliar logs, caches e historico em tarefa separada aprovada.

