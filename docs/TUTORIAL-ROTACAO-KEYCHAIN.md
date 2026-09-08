# Rotacao segura com o Keychain nativo

Preparado em 2026-09-08 para complementar o [tutorial de rotacao](TUTORIAL-ROTACAO-CREDENCIAIS.md).

Este documento e um procedimento, nao um registro de rotacao concluida. Nenhuma chave foi criada, revelada ou revogada durante sua preparacao.

## 1. Escolher o aplicativo correto

Use **Acesso as Chaves (Keychain Access)** para os itens de senha generica consumidos por CLIs e MCPs. Use **Senhas (Passwords)** para os logins dos portais, passkeys e codigos de verificacao. Salvar um login em Senhas nao configura automaticamente uma variavel de ambiente do MCP. [Apple: finalidade dos aplicativos](https://support.apple.com/en-gb/guide/keychain-access/kyca1083/mac).

Nao e necessario instalar software nem ativar sincronizacao iCloud para este fluxo local. Os exemplos usam o chaveiro `login`, nao `Sistema` nem `Raizes do Sistema`.

Estado observado nesta sessao: macOS 27.0 build 26A5425a, Apple Silicon; chaveiro padrao `login.keychain-db`; configuracao biometrica habilitada para desbloqueio. Isso nao comprova que cada acesso via CLI usara Touch ID. O aplicativo Acesso as Chaves foi aberto via computer-use sem exibir valores secretos.

O 1Password Desktop 8.12.34 foi instalado sob a autorizacao anterior e teve assinatura e notarizacao verificadas. A vinculacao da conta nao foi concluida. Ele nao e requisito deste caminho nativo e nao foi desinstalado.

## 2. Conferir os ajustes do Mac

1. Abra Ajustes do Sistema > Tela Bloqueada. Confira o prazo de exigencia de senha depois de apagar a tela/iniciar o protetor. Recomendo **Imediatamente** para este ambiente de desenvolvimento. Isso afeta o desbloqueio da sessao, nao as permissoes de cada item. [Apple: configurar exigencia de senha](https://support.apple.com/en-au/guide/mac-help/mchlp2270/mac).
2. Em Touch ID e Senha, confira se o desbloqueio do Mac esta habilitado. Nao cadastre biometria por automacao. Mantenha a senha de login disponivel: ela pode ser solicitada pelo Keychain mesmo com Touch ID ativo.
3. Em Privacidade e Seguranca > FileVault, confira o estado. Se estiver desativado, planeje a ativacao e a custodia da recuperacao separadamente; nao altere nesta etapa por conta propria.
4. Nao conceda Acesso Total ao Disco, acesso global ao Keychain ou novas permissoes a todos os terminais para resolver um pedido de senha. Essas permissoes nao sao requisito geral para cadastrar um item no chaveiro do usuario.
5. Nao redefina o chaveiro padrao, nao mude a senha de login e nao altere o bloqueio global do chaveiro para eliminar dialogs. A leitura local `no-timeout` descreve o timeout do chaveiro, nao o bloqueio da tela; nao e por si so um diagnostico de inseguranca.

Os nomes dos menus podem variar no macOS 27: a documentacao publica consultada descreve versoes anteriores. Estes ajustes sao orientacoes; nao foram modificados nesta sessao.

## 3. Preparar a rotacao

1. Inventarie todos os consumidores da chave, inclusive configuracoes duplicadas. Registre caminhos, nomes de variaveis, escopos e resultados; nunca valores.
2. Antes de editar consumidores, crie e valide um backup criptografado das configuracoes afetadas. Um backup antigo parcial nao substitui essa etapa. Use a rotina existente do projeto; preserve permissao 600 e a chave de recuperacao separada. Nao extraia segredos para arquivos temporarios.
3. Crie a substituta no portal oficial, com privilegios minimos. O usuario realiza login e insere a credencial; o agente deve pausar leituras de tela enquanto houver segredos visiveis. Evite clipboard quando possivel. Se usar, remova o valor do clipboard e do historico do gerenciador apos a transferencia, sem registrar seu conteudo.
4. Mantenha a antiga ativa. Se o provedor so oferecer redefinicao que invalida imediatamente a antiga, pare e planeje uma janela de interrupcao antes de continuar.

## 4. Cadastrar um item novo

### Pela interface

1. Abra Spotlight, procure **Acesso as Chaves**. Se aparecer o aviso sobre o novo app Senhas, escolha **Abrir Acesso as Chaves**.
2. Exiba a barra lateral pelo menu Visualizar, se necessario, e selecione `login`.
3. Use Arquivo > Novo Item de Senha (Command-N).
4. Nome do item: `macbook.CONTEXT7_API_KEY.2026-09`. Conta: seu nome curto de usuario do macOS, o mesmo retornado por `id -un`.
5. Digite a nova credencial apenas no campo de senha oculto. Nao marque Mostrar Senha. Adicione o item.
6. Abra as propriedades somente desse item e a aba Controle de Acesso. Mantenha confirmacao antes do acesso; nao permita todos os aplicativos. Durante os testes, escolha **Permitir uma vez** nos pedidos esperados. [Apple: controle de acesso por item](https://support.apple.com/en-lamr/guide/mac-help/kychn002/mac).

### Alternativa pelo Terminal local

Execute pessoalmente em um terminal interativo, sem gravacao da entrada. Primeiro confirme que o chaveiro padrao continua sendo `login`:

```bash
/usr/bin/security default-keychain -d user
/usr/bin/security add-generic-password -a "$USER" -s "macbook.CONTEXT7_API_KEY.2026-09" -T "" -w
```

O `-w` deve ser o ultimo argumento, sem valor depois: o comando pede a senha sem eco. Nao use `-U` nesta criacao, pois uma colisao deve falhar em vez de sobrescrever um item anterior. `-T ""` remove a confianca automatica no aplicativo criador; nao use `-A`. Comportamento conferido na ajuda local e no [codigo oficial da Apple consultado via Context7](https://github.com/apple-oss-distributions/security/blob/main/SecurityTool/macOS/keychain_add.c).

Se o item ja existir, pare e confira sua finalidade. Escolha outro sufixo de rotacao, por exemplo `.2026-09-08-r2`, sem apagar o anterior. Use o mesmo identificador nos testes e no consumidor.

### Nomes para os provedores

| Escopo | Servico novo no Keychain |
| --- | --- |
| Claude/gateway | `macbook.ANTHROPIC_AUTH_TOKEN.2026-09` |
| Context7 | `macbook.CONTEXT7_API_KEY.2026-09` |
| GitHub MCP | `macbook.GITHUB_PERSONAL_ACCESS_TOKEN.2026-09` |
| Firecrawl | `macbook.FIRECRAWL_API_KEY.2026-09` |
| Netlify | `macbook.NETLIFY_PERSONAL_ACCESS_TOKEN.2026-09` |
| KIE | `macbook.KIE_API_KEY.2026-09` |
| Perplexity | `macbook.PERPLEXITY_API_KEY.2026-09` |

Estes sao nomes de itens, nao chaves substitutas reais. O nome `ANTHROPIC_AUTH_TOKEN` nao comprova a origem: o inventario encontrou endereco de proxy local, portanto confirme o emissor antes de gerar uma chave Anthropic. Inclua `21st-dev-magic` somente depois de confirmar uma credencial real e ativa; use nome exclusivo, nao apenas `API_KEY`.

## 5. Verificar sem revelar o segredo

Existencia do item, sem mostrar atributos:

```bash
if /usr/bin/security find-generic-password -a "$USER" -s "macbook.CONTEXT7_API_KEY.2026-09" >/dev/null 2>&1; then
  printf 'Item encontrado\n'
else
  printf 'Item ausente ou consulta falhou\n'
fi
```

Leitura autorizada, descartando o valor em vez de exibi-lo:

```bash
if /usr/bin/security find-generic-password -a "$USER" -s "macbook.CONTEXT7_API_KEY.2026-09" -w >/dev/null 2>&1; then
  printf 'Leitura autorizada\n'
else
  printf 'Leitura negada ou indisponivel\n'
fi
```

Autorize somente o pedido esperado. Nunca execute a segunda consulta sem o redirecionamento. O primeiro teste nao verifica acesso ao segredo; o segundo nao verifica autenticacao no provedor.

## 6. Integrar um consumidor por vez

O nome do item nao e uma referencia automaticamente interpretada pelos aplicativos. E necessario um launcher ou helper por consumidor. Nao coloque comandos de shell em campos JSON esperando que sejam executados. MCPs remotos via HTTP exigem verificar como o cliente injeta headers; nao presuma que aceitam o mesmo mecanismo de servidores stdio.

Exemplo conceitual para um consumidor que documentadamente aceite `CONTEXT7_API_KEY` pelo ambiente. Substitua o caminho pelo executavel real antes de usar; este launcher ainda nao foi instalado nem testado:

```bash
(
  set +x
  CONTEXT7_API_KEY="$(/usr/bin/security find-generic-password -a "$USER" -s "macbook.CONTEXT7_API_KEY.2026-09" -w)" || exit 1
  test -n "$CONTEXT7_API_KEY" || exit 1
  export CONTEXT7_API_KEY
  exec /caminho/absoluto/do/consumidor
)
```

O segredo fica no ambiente desse processo e seus descendentes, nao no argumento de execucao. Isso reduz exposicao acidental, mas nao o protege de um processo comprometido, ferramentas privilegiadas, dumps ou logging indevido. Nao execute `env`, `printenv`, `set -x` ou dumps de ambiente nessa sessao. Nao use a chave expandida em `curl -H`, URLs ou `--api-key`.

Injete somente a chave necessaria, nao as sete em todo terminal. Nao grave segredos em `.zshrc`, `.env` ou configuracoes versionadas. Aplicativos iniciados pelo Finder nao herdam automaticamente o ambiente deste terminal. Configure o launcher no consumidor correto e reinicie somente esse componente, com impacto explicado e autorizado.

Para remover literais, use parser estruturado, backup criptografado e escrita atomica. Verifique a precedencia de `ANTHROPIC_AUTH_TOKEN` antes de adotar `apiKeyHelper` no Claude. Para cada MCP, confirme suporte na documentacao e no cliente instalado.

### Limite da automacao sem intervencao

Permitir uma vez pode exigir confirmacao a cada leitura. Isso e esperado. Nao resolva concedendo **Sempre Permitir** a `security`, Terminal, shells, Node ou Bun de forma indiscriminada: sao executaveis reutilizaveis por outros programas. Um acesso automatico restrito exige avaliar um helper dedicado e assinado e a politica do item. Touch ID habilitado no Mac nao cria essa politica automaticamente. Sessao bloqueada ou ausente pode impedir o acesso.

## 7. Validar e concluir a rotacao

1. Verifique existencia, leitura autorizada e valor nao vazio.
2. Execute uma consulta pequena e de leitura pelo consumidor. Testes que geram texto ou midia podem ter custo e precisam de escopo aprovado.
3. Registre sucesso/falha, escopos e expiracao, sem corpo contendo informacao privada. Repita para todos os consumidores daquela chave.
4. Procure valores antigos em configuracoes e argumentos usando fonte protegida e reporte apenas contagens. A ausencia de nomes de variaveis em `ps` nao prova ausencia de segredos. Nao imprima argumentos brutos nem procure copiando o segredo para um comando.
5. Confirme backup recuperavel, novos consumidores funcionando e identificacao correta da chave antiga. Solicite: `Confirmo revogar a chave antiga de <provedor>`.
6. Somente com essa confirmacao, revogue aquela chave e repita o teste. Apagar um item do Keychain nao revoga a credencial no provedor. Se falhar, pare. Uma chave revogada nao e recuperada restaurando backup.
7. Preserve Chrome Remote Desktop e Antigravity na porta 40001; mantenha Kubernetes desativado e porta 8811 sem listener. Nao reinicie o Mac nesta rotina.

## 8. Resolver problemas sem reduzir a seguranca

| Sintoma | Verificacao segura |
| --- | --- |
| Item nao encontrado | Confira servico, conta e chaveiro selecionado; nao recrie sobrescrevendo. |
| Acesso negado ou interacao proibida | Execute na sessao grafica do usuario, confira o dialog esperado; nao desbloqueie passando senha em argumentos. |
| Senha do chaveiro recusada | Pode diferir da senha atual de login; investigue a alteracao anterior. Nao redefina o chaveiro. |
| Consumidor nao recebe variavel | Confira launcher, tipo stdio/HTTP e precedencia; salvar no Keychain nao injeta automaticamente. |
| Autenticacao falhou | Confira emissor, escopo, expiracao e consumidor, sem imprimir credencial. Preserve a antiga enquanto diagnostica. |

Pronto para uso significa: item novo armazenado, leitura autorizada, consumidor autenticado com a substituta e ausencia verificada de literais no escopo. A rotacao so termina apos revogacao individual autorizada e novo teste.
