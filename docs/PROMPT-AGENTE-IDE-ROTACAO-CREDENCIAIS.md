# Prompt para o agente IDE do projeto MacOS-Use

Copie o bloco abaixo para o agente IDE responsável pela configuração.

```text
Voce e o agente responsavel por preparar e executar, com controle humano, a etapa do tutorial "Rotacao segura das credenciais locais" no projeto MacOS-Use.

Objetivo

Configurar este Mac para armazenar novas credenciais no 1Password ou, como fallback, no Keychain do macOS; atualizar os consumidores sem valores literais; validar cada integracao; e somente depois solicitar autorizacao para revogar individualmente as credenciais antigas.

Ambiente confirmado

- Projeto: /Users/danilonovais/MacOS-Use
- Sistema operacional: macOS 27.0, build 26A5425a
- Hardware: MacBookPro18,2, Apple M1 Max, arquitetura arm64
- 1Password CLI: 2.39.0 instalado em /opt/homebrew/bin/op
- Estado do 1Password CLI: nenhuma conta conectada em `op whoami`
- Aplicativo 1Password: nao localizado em /Applications na verificacao inicial; confirme por bundle ID e em ~/Applications antes de propor instalacao
- Ferramentas presentes: Keychain `security`, age 1.3.1, jq 1.8.2, Node 26.8.1, Bun 1.3.14, Docker 29.7.2 e GitHub CLI 2.98.0
- Docker Kubernetes deve permanecer desativado
- Chrome Remote Desktop deve permanecer ativo
- Listener do Antigravity IDE na porta 40001 deve permanecer ativo
- Porta 8811 deve permanecer fechada
- Nao reinicie o macOS sem nova confirmacao explicita

Fontes obrigatorias

1. Antes de agir, execute `graphify query "rotacao segura credenciais 1Password Keychain consumidores"` no projeto.
2. Leia integralmente `/Users/danilonovais/MacOS-Use/docs/TUTORIAL-ROTACAO-CREDENCIAIS.md`.
3. Consulte Context7 quando precisar confirmar comportamento atual do 1Password CLI, `op run`, referencias `op://` ou integracoes dos consumidores. Nunca envie valores secretos ao Context7.
4. Para interfaces graficas, use o plugin `computer-use` compartilhado pelo usuario. Priorize terminal e APIs estruturadas para inventario e verificacao; use a GUI apenas para login, Touch ID, paineis de provedores e dialogs que nao tenham interface segura equivalente.

Regras absolutas

- Fluxo: INVENTARIAR -> FAZER BACKUP -> CRIAR SUBSTITUTA -> ARMAZENAR -> ATUALIZAR UM CONSUMIDOR -> VALIDAR -> SOLICITAR APROVACAO -> REVOGAR ANTIGA -> VALIDAR NOVAMENTE.
- Nunca revele, transcreva, registre, fotografe, copie para o chat ou inclua em logs o valor de uma chave.
- Nunca coloque segredo em argumento CLI, URL, historico do shell, arquivo versionado, prompt, relatorio ou saida de ferramenta.
- Se uma chave aparecer na tela, nao repita o valor. Mova-a diretamente para um campo oculto do 1Password e limpe a area de transferencia quando a transferencia terminar.
- Nao use `op item get --reveal` em uma sessao gravada.
- Nao use `security ... -w VALOR`; quando usar Keychain, deixe `-w` como ultimo argumento para abrir o prompt seguro.
- Nao use `security -A`.
- Nao revogue credenciais em massa.
- Nao edite configuracoes com substituicao textual ampla; use parser estruturado, backup criptografado e escrita atomica.
- Pare e solicite aprovacao imediatamente antes de cada revogacao irreversivel.
- Nao instale software, conceda permissoes, altere Keychain ACL, reinicie apps ou encerre processos sem explicar impacto. Instalacao do 1Password Desktop exige aprovacao se ele realmente estiver ausente.

Credenciais no escopo

1. Anthropic/Claude: `ANTHROPIC_AUTH_TOKEN`.
2. Context7: `CONTEXT7_API_KEY`.
3. GitHub MCP: `GITHUB_PERSONAL_ACCESS_TOKEN`.
4. Firecrawl: `FIRECRAWL_API_KEY`.
5. Netlify: `NETLIFY_PERSONAL_ACCESS_TOKEN`.
6. KIE: `KIE_API_KEY`.
7. Perplexity: `PERPLEXITY_API_KEY`.
8. Condicional: `21st-dev-magic` usa um campo generico `API_KEY`; confirme se e credencial ativa ou placeholder antes de inclui-la.

Fase 1 - Pre-flight somente leitura

1. Confirme data, usuario ativo, versao/build do macOS e arquitetura.
2. Localize o 1Password Desktop por bundle ID e confirme a versao sem abrir vaults.
3. Execute `op --version` e `op whoami`, registrando apenas conectado/nao conectado.
4. Verifique se Touch ID esta disponivel, sem alterar a configuracao.
5. Inventarie apenas nomes de variaveis, caminhos dos consumidores e processos; redija valores.
6. Confirme que o backup criptografado anterior existe e e legivel, sem extrair conteudo para disco.
7. Produza uma tabela: provedor, nome da variavel, consumidor, local atual, mecanismo alvo e teste planejado.

Gate 1

Apresente o inventario e pare. Solicite aprovacao para localizar/instalar o 1Password Desktop, vincular o CLI e criar o vault/itens. Ausencia de resposta nao e aprovacao.

Fase 2 - Preparar o 1Password

1. Se o app estiver instalado, abra-o com `computer-use`; o usuario deve desbloquear e concluir qualquer autenticacao.
2. Em Settings > Developer, habilite a integracao com 1Password CLI e Touch ID conforme a documentacao atual. Nunca capture a tela enquanto um valor secreto estiver visivel.
3. Valide com `op whoami`, reportando somente sucesso e identificadores nao sensiveis redigidos.
4. Crie ou selecione um vault privado chamado `Developer`.
5. Crie um item por provedor, usando nomes sem espacos, por exemplo `macbook-context7-mcp-YYYY-MM`, e um campo oculto `credential`.
6. Registre somente metadados nao secretos: provedor, consumidor, escopos, expiracao, data e identificador parcial fornecido pelo portal.

Fallback Keychain

Use Keychain apenas quando o 1Password nao puder atender um consumidor. Exemplo interativo:

`security add-generic-password -U -a "$USER" -s "macbook.CONTEXT7_API_KEY" -T "" -w`

O usuario deve inserir o valor no prompt protegido. Restrinja o acesso ao helper/consumidor correto e nunca permita acesso global.

Fase 3 - Criar substitutas

Execute um provedor por vez, usando somente o dominio oficial. Crie a nova chave com privilegios minimos, nome descritivo, expiracao e limites quando disponiveis. Armazene-a imediatamente no item correspondente. Nao revogue a antiga nesta fase.

- Anthropic: confirme primeiro se o token pertence diretamente ao Claude Console ou a um gateway.
- Context7: crie a chave no dashboard e registre que ela e exibida uma unica vez.
- GitHub: prefira PAT fine-grained, repositorios especificos, escopos minimos e expiracao.
- Firecrawl: use o painel oficial de API keys.
- Netlify: use Applications > Personal access tokens, com nome e expiracao.
- KIE: use API Key Management e configure limites/whitelist quando aplicavel.
- Perplexity: use um nome identificavel; a chave e exibida uma unica vez.
- 21st Dev Magic: so execute se a entrada for confirmada como real e ativa.

Gate 2

Mostre apenas quais itens foram criados e armazenados, nunca os valores. Pare se qualquer provedor nao permitir coexistencia temporaria de duas chaves.

Fase 4 - Atualizar consumidores

1. Crie backup criptografado das configuracoes afetadas usando a chave publica SSH existente e `age`; proteja o arquivo com modo 600.
2. Crie um template local ignorado pelo Git contendo somente referencias `op://Developer/<item>/credential`.
3. Prefira iniciar processos com `op run --env-file <template> -- <comando>`.
4. Para Claude Code, avalie `apiKeyHelper` ou injecao com `op run`, respeitando a precedencia de `ANTHROPIC_AUTH_TOKEN`.
5. Para cada MCP, remova valores literais e argumentos como `--api-key VALOR`; o processo deve receber a credencial pelo ambiente em tempo de execucao.
6. Atualize um consumidor por vez, reinicie somente esse consumidor e execute um teste pequeno, de leitura e baixo custo.
7. Preserve Chrome Remote Desktop, Antigravity 40001, Docker/Kubernetes e os demais servicos fora do escopo.

Gate 3 - Revogacao

Para cada provedor, apresente:

- Nova chave armazenada: sim/nao.
- Consumidores atualizados: lista sem valores.
- Teste funcional: passou/falhou.
- Valor antigo ausente de argumentos e configuracoes: sim/nao.
- Backup: valido/invalido.
- Identificador parcial da chave antiga: redigido.

Solicite confirmacao individual: `Confirmo revogar a chave antiga de <provedor>`. Revogue somente aquela chave e repita o teste. Se falhar, pare e nao prossiga para o proximo provedor.

Validacao final

1. `op whoami` deve indicar conexao sem revelar dados pessoais.
2. `op item list --vault Developer` deve listar os itens esperados sem valores.
3. Procure valores antigos por correspondencia exata usando fonte protegida; reporte somente contagens.
4. Inspecione processos e confirme que valores nao aparecem em argumentos.
5. Teste os sete consumidores individualmente.
6. Confirme que Chrome Remote Desktop e Antigravity 40001 continuam ativos, a porta 8811 fechada e Kubernetes desativado.
7. Confirme que nenhuma reinicializacao do macOS ocorreu.

Relatorio obrigatorio

Produza um relatorio em portugues com:

- Estado inicial e ferramentas disponiveis.
- Itens criados no 1Password/Keychain, sem valores.
- Consumidores atualizados e testes executados.
- Chaves antigas revogadas ou pendentes.
- Falhas, bloqueios e rollback aplicado.
- Evidencia sanitizada das validacoes.
- Caminho do backup criptografado.
- Proximos passos que ainda exigem aprovacao.

Nao declare sucesso global se uma unica integracao continuar usando valor literal, se algum teste falhar ou se uma chave antiga permanecer ativa sem justificativa.
```

## Referencias verificadas

- [1Password CLI: primeiros passos](https://www.1password.dev/cli/get-started)
- [1Password CLI: op run](https://www.1password.dev/cli/reference/commands/run)
- [1Password: arquivos com referencias secretas](https://www.1password.dev/cli/secrets-config-files)
- [Tutorial local de rotacao](./TUTORIAL-ROTACAO-CREDENCIAIS.md)
- [Plugin computer-use](https://chatgpt.com/plugins/share/computer-use@openai-bundled)
