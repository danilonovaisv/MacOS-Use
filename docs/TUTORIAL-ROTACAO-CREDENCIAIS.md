# Tutorial de rotacao segura das credenciais locais

Atualizado em: 2026-09-08

Este runbook aplica a ordem obrigatoria:

`CRIAR SUBSTITUTA -> ARMAZENAR -> ATUALIZAR CONSUMIDORES -> VALIDAR -> REVOGAR ANTIGA -> VALIDAR NOVAMENTE`

Nunca revogue a chave antiga antes de testar a substituta. Nunca cole valores em comandos, argumentos de processo, historico do shell, commits, tickets ou relatorios.

## Inventario

As sete categorias solicitadas sao:

| Provedor | Variavel usada | Consumidor conhecido | Portal oficial |
| --- | --- | --- | --- |
| Anthropic/Claude | `ANTHROPIC_AUTH_TOKEN` | Claude Code ou gateway configurado | [Claude Console](https://console.anthropic.com/settings/keys) |
| Context7 | `CONTEXT7_API_KEY` | MCP Context7 | [Context7 Dashboard](https://context7.com/dashboard) |
| GitHub | `GITHUB_PERSONAL_ACCESS_TOKEN` | GitHub MCP | [GitHub tokens](https://github.com/settings/tokens) |
| Firecrawl | `FIRECRAWL_API_KEY` | Firecrawl MCP | [Firecrawl](https://www.firecrawl.dev/app/api-keys) |
| Netlify | `NETLIFY_PERSONAL_ACCESS_TOKEN` | Netlify MCP/CLI | [Netlify applications](https://app.netlify.com/user/applications) |
| KIE | `KIE_API_KEY` | geracao de midia/IA | [KIE API keys](https://kie.ai/api-key) |
| Perplexity | `PERPLEXITY_API_KEY` | pesquisa/API | [Perplexity API keys](https://www.perplexity.ai/settings/api) |

Foi detectada ainda uma oitava categoria condicional, `API_KEY` no consumidor `21st-dev-magic`. Confirme se ela e real e ativa no painel correspondente antes de rotacionar; nao trate um placeholder como credencial.

Fontes operacionais: [Context7 - gerenciamento de chaves](https://github.com/upstash/context7/blob/master/docs/howto/api-keys.mdx), [GitHub - gerenciamento de PATs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens), [Netlify CLI - tokens](https://docs.netlify.com/api-and-cli-guides/cli-guides/get-started-with-cli/), [KIE quickstart](https://docs.kie.ai/common-api/quickstart) e [Perplexity - rotacao de chaves](https://docs.perplexity.ai/docs/admin/api-key-management).

## Preparacao

1. Feche tarefas que dependam dos MCPs afetados, mas mantenha este tutorial aberto.
2. Entre no 1Password Desktop e confirme que o CLI esta conectado. Atualmente `op whoami` nao encontra uma conta, portanto a vinculacao ainda precisa ser feita pelo usuario.
3. Crie um vault dedicado, por exemplo `Developer`, ou escolha um vault privado existente.
4. Para cada item, use um nome descritivo sem espacos como `macbook-context7-mcp-2026-09` e um campo oculto chamado `credential`.
5. Registre metadados nao secretos: provedor, data, consumidor, escopos, expiracao e identificador parcial fornecido pelo portal.

## Opcao A: 1Password

Crie os itens pela interface do 1Password. Isso evita que os valores passem pelo historico do shell. O formato de referencia sera:

```text
op://Developer/macbook-context7-mcp-2026-09/credential
```

Crie um arquivo local ignorado pelo Git, por exemplo `.env.op`, contendo apenas referencias:

```dotenv
ANTHROPIC_AUTH_TOKEN=op://Developer/macbook-anthropic-2026-09/credential
CONTEXT7_API_KEY=op://Developer/macbook-context7-mcp-2026-09/credential
GITHUB_PERSONAL_ACCESS_TOKEN=op://Developer/macbook-github-mcp-2026-09/credential
FIRECRAWL_API_KEY=op://Developer/macbook-firecrawl-mcp-2026-09/credential
NETLIFY_PERSONAL_ACCESS_TOKEN=op://Developer/macbook-netlify-mcp-2026-09/credential
KIE_API_KEY=op://Developer/macbook-kie-2026-09/credential
PERPLEXITY_API_KEY=op://Developer/macbook-perplexity-2026-09/credential
```

Inicie consumidores por injecao temporaria:

```bash
op run --env-file .env.op -- <comando-do-consumidor>
```

Para Claude Code, prefira `apiKeyHelper` quando aplicavel ou inicie o processo com `op run`. Para MCPs, remova valores literais da configuracao e faca o processo receber somente o nome da variavel no ambiente. Nao use `--api-key VALOR` em `args`.

## Opcao B: Keychain do macOS

Para o fluxo nativo detalhado, siga [Rotacao segura com o Keychain](TUTORIAL-ROTACAO-KEYCHAIN.md), incluindo itens novos com sufixo de rotacao, controle de acesso e testes sem exibir segredos. Durante a rotacao, prefira esse procedimento ao cadastro com `-U` abaixo, que atualiza um item existente.

Use um item por variavel. O `-w` deve ser o ultimo argumento para abrir o prompt seguro:

```bash
security add-generic-password -U -a "$USER" -s "macbook.CONTEXT7_API_KEY" -T "" -w
```

Repita alterando apenas o nome do servico:

```text
macbook.ANTHROPIC_AUTH_TOKEN
macbook.CONTEXT7_API_KEY
macbook.GITHUB_PERSONAL_ACCESS_TOKEN
macbook.FIRECRAWL_API_KEY
macbook.NETLIFY_PERSONAL_ACCESS_TOKEN
macbook.KIE_API_KEY
macbook.PERPLEXITY_API_KEY
```

Nao use `-A`. Essa opcao permite acesso sem confirmacao por qualquer aplicativo. Restrinja o acesso ao helper/consumidor correto depois de validar o fluxo.

## Rotacao por provedor

Execute um provedor por vez.

1. Anthropic: crie a nova credencial no Claude Console. Se `ANTHROPIC_AUTH_TOKEN` representar um gateway e nao uma chave Anthropic, gere a substituta no administrador desse gateway. Armazene, atualize o Claude Code e valide uma chamada curta.
2. Context7: no dashboard, crie uma chave com nome descritivo. Ela aparece apenas uma vez. Atualize o MCP e valide uma consulta de documentacao. Somente depois exclua a chave antiga; a revogacao e imediata e irreversivel.
3. GitHub: prefira PAT fine-grained, com repositorios e permissoes minimas e expiracao. Para Git no terminal, prefira `gh`/plugin do 1Password em vez de PAT literal. Valide o GitHub MCP e acesso apenas aos repositorios esperados; depois exclua o PAT antigo.
4. Firecrawl: gere uma nova chave no painel, armazene e valide uma operacao pequena do MCP. Exclua a chave anterior somente quando o consumidor novo estiver saudavel.
5. Netlify: crie um PAT com nome e expiracao. Atualize MCP/CLI, execute uma consulta somente leitura como listar sites e entao apague o token anterior em Applications > Personal access tokens.
6. KIE: crie ou redefina a chave no painel de API keys, configure limites por chave e whitelist de IP quando aplicavel. Valide saldo ou outra chamada somente leitura antes de desativar a antiga.
7. Perplexity: crie a substituta com nome descritivo, pois o valor e mostrado uma unica vez. Valide uma consulta pequena e use o painel ou o endpoint de revogacao para invalidar a chave anterior.
8. 21st Dev Magic, condicional: confirme o portal e o consumidor. Se a credencial estiver ativa, aplique a mesma sequencia. Se for placeholder ou integracao removida, retire a entrada da configuracao sem criar uma chave nova.

## Atualizar consumidores

Antes de editar, crie backup criptografado da configuracao. Edite JSON com parser estruturado; nao use substituicao textual ampla.

Para cada consumidor:

1. Pare apenas o processo correspondente.
2. Remova o valor literal e a passagem por argumento CLI.
3. Configure a injecao pelo 1Password ou helper do Keychain.
4. Reinicie somente esse consumidor.
5. Confirme autenticacao e uma operacao de leitura.
6. Verifique que `ps` mostra apenas o nome da variavel, nunca o valor.

Exemplo de verificacao que lista apenas nomes, sem imprimir valores:

```bash
ps axww -o args= | rg -o '[A-Z][A-Z0-9_]*(API_KEY|TOKEN|SECRET)=' | sort -u
```

## Revogar as antigas

Para cada provedor, marque estas condicoes antes de revogar:

- A substituta esta armazenada no 1Password ou Keychain.
- Todos os consumidores conhecidos foram atualizados.
- O teste funcional passou.
- Nao ha argumentos de processo contendo o valor antigo.
- Configuracoes e historicos foram saneados.
- O identificador da chave antiga foi conferido no portal.

Revogue a chave antiga no painel do provedor. Em seguida, repita o teste funcional. A revogacao e irreversivel; nao use uma acao de revogacao em massa quando for possivel selecionar a chave exata.

## Validacao final

```bash
op whoami
op item list --vault "Developer"
```

Nao use `op item get --reveal` em relatorios ou sessoes gravadas. Registre somente status, nome do item, data de rotacao e resultado do teste.

Resultado esperado:

- Credenciais literais ausentes das configuracoes e argumentos.
- Sete consumidores funcionando com as novas chaves.
- Chaves antigas revogadas individualmente.
- Historicos saneados e backup criptografado preservado.
- Nenhum valor secreto presente em logs, commits ou relatorios.
