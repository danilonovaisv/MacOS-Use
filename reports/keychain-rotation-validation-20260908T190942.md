# Keychain Rotation Validation Report

## Executive Summary

Status geral: **BLOCKED**. Auditoria iniciada em 2026-09-08, America/Sao_Paulo. Este e um checkpoint de validacao, nao uma aprovacao da automacao.

A busca encontrou um procedimento documentado, mas nenhum launcher implementado de recuperacao/injecao Keychain nem testes especificos no escopo pesquisado. O teste negativo de item inexistente passou no macOS real. O cadastro descartavel esta preparado na GUI, aguardando entrada protegida e submissao pelo usuario. Nenhuma credencial foi criada pelo agente, recuperada para exibicao, alterada ou revogada.

## Environment

- macOS 27.0, build 26A5425a; arm64; MacBookPro18,2.
- Usuario: [REDACTED]. Usuario da sessao grafica coincide com o usuario de execucao.
- Default Keychain: login.keychain-db, existente em Library/Keychains do usuario.
- Consulta de configuracao: no-timeout. Nao significa tela desbloqueada nem comprova leitura de segredos.
- Biometria para desbloqueio habilitada e efetiva segundo bioutil; nao foi realizado desafio Touch ID.
- FileVault: On.
- Disponiveis: security, shortcuts, age, jq, node, bun, git e rg.
- gitleaks e secretlint nao localizados. Nenhuma ferramenta instalada.
- Skills: Apple Shortcuts Integration lida integralmente, aplicada a privacidade e validacao de entradas; nenhum atalho foi executado ou recebeu segredo. macos-setup usada apenas para deteccao. Persona macos-sysadmin lida e aplicada ao inventario existente.
- test-engineer e SKILL-security-reviewer nao encontrados com esses nomes no inventario do repositorio. Nenhum subagente iniciado.

## Repository State

- Checkout: /Users/danilonovais/MacOS-Use.
- Origin corresponde ao repositorio solicitado: https://github.com/danilonovaisv/MacOS-Use.git.
- Branch: main.
- HEAD: c34f5c3b92a6d25b25bc217f270265b9f375cf7d.
- main remoto consultado com ls-remote: mesmo commit. Nao houve fetch, pull, checkout ou commit.
- Working tree inicial: alteracao preexistente indicada por `? SCRIPTS-MACREPAIR/mac-cleanup-py` dentro do submodulo. Preservada.
- AGENTS.md, SECURITY.md, tutorial nativo e prompt IDE lidos integralmente.
- Script existente system_audit.sh inspecionado: coleta metricas gerais, nao implementa a rotacao.
- Nenhum codigo foi alterado. Este relatorio e o registro de sessao sao as escritas de auditoria.
- Busca de referencias: 193 arquivos, indice sanitizado no apendice. Foram excluidos .git, node_modules, graphify-out e lockfiles indicados. Arquivos ignorados pelo rg e conteudo historico do Git nao constituem cobertura completa.
- Busca de APIs SecItemAdd/SecItemCopyMatching/SecKeychainFindGenericPassword e comandos add/find-generic-password retornou apenas os tres documentos de rotacao.
- Nenhuma referencia de rotacao/Keychain encontrada em src, tests, scripts, plugins e scripts de diagnostico pesquisados.
- Testes gerais e testes da skill Context7 existem, mas nao demonstram injecao via Keychain. Nao foram executados como substitutos de um teste E2E ausente.

## Keychain Setup

O chaveiro login foi selecionado na GUI e confirmado como padrao pelo CLI. A consulta de item ausente usou explicitamente esse arquivo, sem -w ou -g. stdout/stderr foram retidos no processo local; a evidencia retornou apenas codigo e classificacao.

Consulta Context7 efetuada para /apple-oss-distributions/security, comparada com a ajuda do binario instalado:
- add-generic-password com -w final sem valor usa prompt de terminal getpass; nao aceita simplesmente um pipe de stdin como equivalente.
- -T vazio remove a confianca automatica do criador.
- sem -U, a criacao nao deve atualizar um item existente.
- find-generic-password -w imprime o segredo em stdout, exigindo captura/descarte seguro.

Fontes: [Apple keychain_add.c](https://github.com/apple-oss-distributions/security/blob/main/SecurityTool/macOS/keychain_add.c) e [Apple keychain_find.c](https://github.com/apple-oss-distributions/security/blob/main/SecurityTool/macOS/keychain_find.c), consultadas via Context7. A fonte publica nao substitui testes de execucao no build instalado.

## Test Cases

BLOCKED significa nao executado ou evidencia insuficiente; nao significa PASS.

| ID | Cenario | Expected | Observed / evidencia sanitizada | Status |
| --- | --- | --- | --- | --- |
| PRE-01 | Repositorio correto | Origin/branch/commit identificados | main local e remoto no commit acima | PASS |
| PRE-02 | Chaveiro esperado | login existente e padrao | Confirmado por CLI e selecao GUI | PASS |
| PRE-03 | Biometria e FileVault | Estado somente leitura | Biometria configurada; FileVault On; sem alteracoes | PASS |
| DOC-01 | Fontes obrigatorias | Leitura completa | Quatro arquivos e skill/persona examinados | PASS |
| IMPL-01 | Launcher real | Executavel e consumidor concreto | Tutorial linha 100 diz nao instalado/testado; linha 108 usa caminho placeholder | FAIL |
| C-01 | Cadastro protegido | Usuario entra dado descartavel; item no login | Formulario preenchido somente com metadados; campo secreto vazio e focado no ultimo estado observado | BLOCKED |
| C-02 | Service/account e armazenamento | Item criado com identificadores corretos | Somente campos pre-cadastro conferidos; persistencia ainda nao comprovada | BLOCKED |
| C-03 | ACL nao global | Propriedades do item sem acesso irrestrito | Item ainda nao criado; nao houve alteracao de ACL | BLOCKED |
| C-04 | Ausencia do segredo em history/argv/logs | Correspondencia exata sem expor valor | Nenhum segredo de teste fornecido; verificacao exata ainda impossivel | BLOCKED |
| NEG-01 | Item inexistente | Erro de item nao encontrado | security exit 44 e classificacao local correspondente; saidas descartadas | PASS |
| NEG-02 | Colisao sem -U | Falhar e preservar item original | Depende de item criado e entrada humana no teste de duplicacao | BLOCKED |
| NEG-03 | Leitura sem autorizacao | Negacao impede recuperacao | Depende de item/ACL e interacao humana com dialog | BLOCKED |
| NEG-04 | Chaveiro bloqueado | Falha controlada sem enfraquecer configuracao | Nao bloqueado: login compartilhado com servicos ativos, risco de interrupcao; requer ambiente isolado | BLOCKED |
| NEG-05 | Consumidor sem variavel | Falhar sem chamada autenticada | Launcher/consumidor concreto ausente; nao criado fluxo paralelo | BLOCKED |
| NEG-06 | Valor vazio | Rejeitar antes de executar consumidor | Apenas guarda test -n documentada; nenhum teste real executado | BLOCKED |
| NEG-07 | Encerramento sem imprimir segredo | Exit controlado e logs sem valor | Consumidor nao executado | BLOCKED |
| BKP-01 | Backup historico recuperavel | Descriptografar e listar sem extrair | 14.626.756 bytes, modo 600, decrypt OK, tar legivel, 11 membros | PASS |
| BKP-02 | Backup atual dos consumidores | Cobertura integral do escopo a modificar | Backup historico parcial; cobertura atual nao demonstrada | BLOCKED |
| E-01 | Credencial real | Somente depois dos testes descartaveis | Gate fechado; nenhuma inserida ou solicitada no chat | BLOCKED |
| F-01 | Autenticacao real | Nova chave injetada e chamada minima funciona | Nao executada | BLOCKED |
| G-01 | Revogacao e reteste | Confirmacao individual apos validacao | Nao solicitada nem executada; preservadas as credenciais antigas | BLOCKED |
| SEC-01 | Segredos ausentes no Git | Inspecao de conteudo/historico no escopo | Somente inventario de nomes: .env.example versionado; nenhum parecer sobre conteudo/historico | BLOCKED |

## Computer Use Validation

1. Keychain Access aberto pelo bundle ID com.apple.keychainaccess.
2. Chaveiro login selecionado.
3. Busca limitada a macbook.KEYCHAIN_ROTATION_TEST.20260908T190624: sem resultados antes do cadastro.
4. Settings inspecionado. Opcao de pesquisa de certificados em diretorio marcada; botao Reset Default Keychains acompanhado de aviso de perda de itens. Nenhuma opcao alterada, nenhum reset.
5. Tentativa de abrir com.apple.Terminal recusada pelo computer-use: aplicativo proibido por politica de seguranca. Nenhum comando foi enviado por esse caminho.
6. Apos pedido humano para continuar, usado o formulario nativo Add Item. Foi capturada somente a imagem do formulario totalmente vazio para identificar os campos, sem credenciais.
7. Nome do item de teste e conta local preenchidos. Conta em evidencias: [REDACTED]. Show Password permaneceu desmarcado. Campo secure text field recebeu foco.
8. Nenhuma captura ou leitura de interface sera feita durante a entrada do segredo. Usuario deve digitar e submeter pessoalmente.
9. Item persistido e sua aba Access Control ainda nao foram inspecionados, pois dependem da criacao.

A criacao GUI nao e evidencia de execucao do comando CLI com -T vazio. A confianca inicial do criador pode diferir; sera necessario inspecionar a ACL resultante, sem modifica-la para forcar aprovacao.

## Credential Creation

- Service planejado: macbook.KEYCHAIN_ROTATION_TEST.20260908T190624.
- Account: [REDACTED], correspondente ao usuario local.
- Chaveiro pretendido: login.
- Valor: [REDACTED], ainda nao fornecido ao agente nem cadastrado pelo agente.
- Producao: fora desta etapa.
- Estado no checkpoint: aguardando entrada protegida e Add pelo usuario.
- Nenhum -A, -U ou -w com valor executado.

## Consumer Validation

Nenhum launcher especifico encontrado. O bloco da linha 100 do tutorial e explicitamente conceitual. Nao foi transformado em uma implementacao paralela para produzir um PASS artificial. Ainda faltam consumidor concreto, mecanismo de injecao, teste de autenticacao, captura sanitizada de logs e tratamento de erros comprovados.

## Rotation Validation

Nao iniciada. Credenciais antigas preservadas. Nao ha evidencias suficientes para solicitar revogacao:
nova credencial armazenada NAO; consumidor atualizado NAO; teste funcional NAO EXECUTADO; backup atual com cobertura comprovada NAO; referencias antigas restantes NAO MEDIDAS.

## Security Findings

| ID | Severity | Descricao / evidencia | Impacto | Recomendacao |
| --- | --- | --- | --- | --- |
| S-01 | HIGH | Ausencia de launcher/testes E2E no escopo; docs/TUTORIAL-ROTACAO-KEYCHAIN.md:100 e :108 | Nao permite demonstrar autenticacao, guardrails ou rollback como automacao | Implementar em tarefa de mudanca autorizada, ou apontar implementacao existente fora do escopo pesquisado |
| S-02 | MEDIUM | docs/PROMPT-AGENTE-IDE-ROTACAO-CREDENCIAIS.md:86 ainda cadastra com -U e service fixo | Se executado com item existente, pode substituir credencial antes de validar consumidor | Alinhar o prompt ao tutorial nativo e adicionar teste de colisao; nao executado nesta auditoria |
| S-03 | MEDIUM | Backup validado e historico/parcial; cobertura de configuracao atual nao comprovada | Rollback de alteracoes futuras nao demonstrado | Inventariar consumidor real e validar backup atual antes de edita-lo |
| S-04 | INFO | SECURITY.md:97-101 declara ausencia de sandbox, rollback e guardrails integrados | Documentacao e aprovacoes humanas nao equivalem a controles implementados | Manter testes com dados descartaveis; nao aprovar uso de producao sem evidencias |
| S-05 | INFO | Auditoria completa de conteudo Git/history/logs e correspondencia exata nao executada | Nao e possivel certificar ausencia global de segredos | Realizar verificacao restrita em memoria, sem publicar valores, apos definir escopo e item de teste |

Nenhum vazamento de valor secreto foi observado nos testes executados. Isto nao constitui prova de ausencia de segredos no repositorio ou na maquina. Nenhuma vulnerabilidade CRITICAL foi confirmada; cobertura insuficiente impede concluir que nao existam.

## Errors and Anomalies

- Graphify: skill 0.8.30 versus pacote 0.8.47; atualizacao nao realizada.
- Primeira consulta do grafo priorizou referencias genericas de seguranca, sem localizar implementacao; complementada por rg.
- rg retornou exit 1 na busca de referencias em diretorios de implementacao/testes, significando nenhuma correspondencia, nao falha de runtime da automacao.
- Computer-use recusou Terminal por politica. Nao houve tentativa por outro terminal, AppleScript ou mecanismo equivalente para contornar essa restricao.
- CLI -T vazio e cadastro GUI tem politicas iniciais potencialmente diferentes, ainda nao comparadas.
- Informacoes historicas dos documentos nao foram tratadas como estado atual sem verificacao.

## Rollback

Nenhum consumidor, item de Keychain, ACL, senha, default Keychain ou configuracao critica foi modificado pelo agente. Nao houve rollback de consumidor a executar.

O formulario pendente pode ser cancelado sem gravacao. Se o usuario cadastrar o item, sua remocao fica pendente de alvo confirmado e autorizacao; nao sera confundida com revogacao em provedor. O backup historico validado nao e declarado rollback completo. Restaurar arquivos nao reativa credencial ja revogada.

## Final Verdict

**BLOCKED**. A automacao nao esta aprovada. Existe um teste negativo real aprovado e pre-flight parcial comprovado; faltam criacao/ACL/leitura controlada, consumidor implementado, autenticacao, testes negativos restantes, cobertura de backup e rotacao autorizada.

## Pending Human Actions

1. No formulario preparado, digitar um valor descartavel e exclusivo de teste no campo protegido, manter Show Password desmarcado e concluir Add. Nao usar credencial real e nao enviar o valor pelo chat.
2. Informar somente que o item foi criado. Qualquer autenticacao macOS deve ser concluida pessoalmente.
3. Apontar o launcher/consumidor real, se existir fora do escopo, ou autorizar separadamente sua implementacao. Esta missao de QA nao modificou codigo.
4. Antes de producao, concluir testes descartaveis, confirmar backup atual e selecionar provedor/consumidor.
5. Revogacao permanece condicionada a confirmacao individual posterior; nenhuma aprovacao antiga foi reutilizada.

## Reference Inventory

Somente caminhos, numeros de linha e termos pesquisados; nenhuma linha de codigo/configuracao com valores e reproduzida. Inventario anterior a criacao deste relatorio. A palavra security gera referencias genericas e nao caracteriza achado por si so.

| Arquivo | Linhas | Termos |
| --- | --- | --- |
| `.agents/agents/cli-developer.md` | 101 | security |
| `.agents/agents/electron-pro.md` | 3, 13, 15, 20, 27, 110, 117, 127, 145, 155, 182, 187, 226, 232, 239 | security |
| `.agents/checklists/validation_checklist.md` | 28 | keychain |
| `.agents/mcp/mcp.config.example.json` | 31 | context7_api_key |
| `.agents/memory/deepseek-cc-switch-memory.md` | 43 | keychain |
| `.agents/policies/permissions.md` | 35 | keychain |
| `.agents/rules/deepseek-cc-switch.md` | 34 | keychain |
| `.agents/skills/graphify/references/query.md` | 52 | security |
| `.agents/skills/macos-development/app-planner/existing-app-analysis.md` | 46, 49, 56 | security |
| `.agents/skills/macos-development/coding-best-practices/SKILL.md` | 61 | security |
| `.agents/skills/macos-development/macos-capabilities/extensions.md` | 18, 249 | security |
| `.agents/skills/macos-development/macos-capabilities/sandboxing.md` | 3, 57, 59, 62, 117, 119, 131, 196, 206, 230 | security |
| `.agents/skills/macos-development/macos-capabilities/SKILL.md` | 15, 19, 36, 62, 70, 71, 74, 75, 78, 79, 82, 84, 85, 95 | security, keychain |
| `.agents/skills/macos-development/SKILL.md` | 32 | keychain |
| `.agents/skills/notebooklm/README.md` | 272 | security |
| `.agents/skills/notebooklm/references/api_reference.md` | 195 | security |
| `.agents/skills/notebooklm/references/troubleshooting.md` | 321 | security |
| `.agents/skills/notebooklm/references/usage_patterns.md` | 254 | security |
| `.agents/skills/notebooklm/SKILL.md` | 198 | security |
| `.agents/skills/verification-loop/agents/openai.yaml` | 5 | security |
| `.agents/skills/verification-loop/SKILL.md` | 66, 100 | security |
| `.agents/workflows/deepseek-cc-switch-prevc.md` | 25 | keychain |
| `.claude/agents/cli-developer.md` | 101 | security |
| `.claude/agents/electron-pro.md` | 3, 13, 15, 20, 27, 110, 117, 127, 145, 155, 182, 187, 226, 232, 239 | security |
| `.claude/agents/mail-security-reviewer.md` | 1 | security |
| `.claude/commands/init-project.md` | 67, 68, 70, 71 | security |
| `.claude/commands/update-dependencies.md` | 3, 15, 22, 25, 32, 34 | security |
| `.claude/README.md` | 66 | security |
| `.claude/skills/alz-accelerator/references/accelerator-interactive-flow.md` | 16, 56, 79, 103 | security |
| `.claude/skills/alz-accelerator/SKILL.md` | 57, 109, 139, 182 | security |
| `.claude/skills/argocd-advanced/References/application-install.md` | 82 | security |
| `.claude/skills/argocd-advanced/References/applicationset.md` | 668, 690 | security |
| `.claude/skills/argocd-advanced/References/applicationset/generators/cluster-generator.yaml` | 58, 65, 70 | security |
| `.claude/skills/argocd-advanced/References/applicationset/patterns/multi-cluster-pattern.yaml` | 276 | security |
| `.claude/skills/argocd-advanced/References/cluster-bootstrapping.md` | 86, 126 | security |
| `.claude/skills/argocd-advanced/References/cluster-bootstrapping/architecture.md` | 76 | security |
| `.claude/skills/argocd-advanced/References/cluster-bootstrapping/guidance.md` | 3, 179, 181 | security |
| `.claude/skills/argocd-advanced/References/cluster-bootstrapping/templates/values-prd.yaml` | 225, 226 | security |
| `.claude/skills/argocd-advanced/References/image-updater/installation.md` | 91 | security |
| `.claude/skills/argocd-advanced/Samples/image-updater/authentication-secrets.yaml` | 5 | security |
| `.claude/skills/argocd-advanced/Workflows/application-install/CreateApplicationSet.md` | 22, 49 | security |
| `.claude/skills/argocd/References/review-workflows/ReviewResources.md` | 106 | security |
| `.claude/skills/atuin/references/sync-setup.md` | 469 | security |
| `.claude/skills/atuin/references/tips-and-tricks.md` | 67 | security |
| `.claude/skills/atuin/references/workflows.md` | 349 | security |
| `.claude/skills/atuin/SKILL.md` | 484 | security |
| `.claude/skills/az-aks-agent/references/examples.md` | 229, 247, 250, 254, 256, 520, 522 | security |
| `.claude/skills/az-aks-agent/SKILL.md` | 3, 64, 206, 212, 213, 302 | security |
| `.claude/skills/aztfexport/references/RESOURCE-DISCOVERY.md` | 62 | security |
| `.claude/skills/azure-ad-sso/references/app-configs.md` | 26, 172, 254, 327, 392, 434, 478, 534 | security |
| `.claude/skills/azure-ad-sso/references/azure-ad-sso-guide.md` | 11, 459 | security |
| `.claude/skills/azure-ad-sso/SKILL.md` | 77, 324 | security |
| `.claude/skills/azure-devops-wiki/references/best-practices.md` | 338, 439 | security |
| `.claude/skills/azure-devops/references/wiki-search-reference.md` | 211 | security |
| `.claude/skills/azure-devops/SKILL.md` | 399, 404 | security |
| `.claude/skills/azure-landing-zone-checklist/references/alz-best-practices.md` | 8, 86, 108, 129, 137, 151, 153, 155, 158, 159, 161, 204, 226 | security |
| `.claude/skills/azure-landing-zone-checklist/SKILL.md` | 22, 48, 52, 67, 69, 145, 177, 228, 250 | security |
| `.claude/skills/bmad-orchestrate/DependencyPatterns.md` | 15, 50, 52 | security |
| `.claude/skills/cloudflare-dns/references/azure-integration.md` | 139, 323, 324, 325 | security |
| `.claude/skills/cloudflare-dns/SKILL.md` | 3, 14, 39, 187, 390, 392 | security |
| `.claude/skills/container-security/evals/evals.json` | 2, 12, 18 | security |
| `.claude/skills/container-security/SKILL.md` | 2, 3, 7, 196 | security |
| `.claude/skills/context7/SKILL.md` | 30, 53, 118, 128, 130, 182, 234 | context7_api_key |
| `.claude/skills/context7/Tools/src/cli/lookup.ts` | 46, 51 | context7_api_key |
| `.claude/skills/context7/Tools/src/cli/query.ts` | 35 | context7_api_key |
| `.claude/skills/context7/Tools/src/cli/resolve.ts` | 46 | context7_api_key |
| `.claude/skills/context7/Tools/src/lib/context7.ts` | 133, 232, 268 | context7_api_key |
| `.claude/skills/context7/Tools/src/lib/errors.ts` | 34, 47, 48 | context7_api_key |
| `.claude/skills/context7/Tools/tests/errors.test.ts` | 11 | context7_api_key |
| `.claude/skills/context7/Workflows/FullLookup.md` | 106, 108 | context7_api_key |
| `.claude/skills/context7/Workflows/QueryDocs.md` | 119 | context7_api_key |
| `.claude/skills/context7/Workflows/ResolveLibrary.md` | 116 | context7_api_key |
| `.claude/skills/defectdojo/references/api-v2-reference.md` | 148, 406, 407 | security |
| `.claude/skills/defectdojo/references/azure-ad-sso.md` | 83 | security |
| `.claude/skills/defectdojo/references/cicd-integration.md` | 5, 9, 60, 67, 69, 79, 158, 171, 223, 228, 270, 316, 565 | security |
| `.claude/skills/defectdojo/references/helm-values.md` | 83, 254 | security |
| `.claude/skills/defectdojo/SKILL.md` | 3, 23, 27, 107, 144, 157, 161, 179, 299, 303, 337, 359, 363, 491, 518, 521 | security |
| `.claude/skills/dependency-track/references/api/bash-scripts/security-gate.sh` | 3, 6, 7, 236, 255 | security |
| `.claude/skills/dependency-track/references/api/python-client.py` | 618, 619, 684 | security |
| `.claude/skills/dependency-track/references/azure-ad-validation.md` | 79, 80, 83 | security |
| `.claude/skills/dependency-track/references/cicd/azure-pipeline.yaml` | 2, 68, 70, 71, 162, 215, 225, 262 | security |
| `.claude/skills/dependency-track/references/cicd/github-action.yaml` | 5, 129, 130, 131 | security |
| `.claude/skills/dependency-track/references/cicd/gitlab-ci.yaml` | 2, 7, 106, 109, 137, 138, 186, 190, 223 | security |
| `.claude/skills/dependency-track/references/cicd/jenkinsfile` | 96, 148 | security |
| `.claude/skills/dependency-track/references/deployment/helm-values.yaml` | 55, 59 | security |
| `.claude/skills/dependency-track/references/policies/security-policies.json` | 2 | security |
| `.claude/skills/dependency-track/references/troubleshooting.md` | 396, 488 | security |
| `.claude/skills/dependency-track/SKILL.md` | 17, 36, 570, 618, 630, 762, 768, 881, 933, 1023, 1036 | security |
| `.claude/skills/devops-network-calculator-for-azure/references/aks-networking-guide.md` | 309, 321 | security |
| `.claude/skills/devops-network-calculator-for-azure/references/segmentation-patterns.md` | 25 | security |
| `.claude/skills/direnv/references/troubleshooting.md` | 161 | security |
| `.claude/skills/direnv/SKILL.md` | 27, 28 | security |
| `.claude/skills/external-dns/references/azure-dns.md` | 9, 147, 156 | security |
| `.claude/skills/external-dns/references/cloudflare.md` | 7, 431 | security |
| `.claude/skills/external-dns/references/troubleshooting.md` | 433, 436, 585 | security |
| `.claude/skills/external-dns/SKILL.md` | 64, 413, 421 | security |
| `.claude/skills/git-worktree/SKILL.md` | 424 | security |
| `.claude/skills/git/git/SKILL.md` | 166 | security |
| `.claude/skills/git/references/GitBestPractices.md` | 57 | security |
| `.claude/skills/git/references/SecurityChecklist.md` | 1, 3, 137, 185, 309, 315 | security |
| `.claude/skills/git/SKILL.md` | 166 | security |
| `.claude/skills/git/workflows/Branch.md` | 161 | security |
| `.claude/skills/git/workflows/Commit.md` | 12 | security |
| `.claude/skills/git/workflows/CommitPush.md` | 14, 202 | security |
| `.claude/skills/git/workflows/Worktree.md` | 189 | security |
| `.claude/skills/github-pages/references/BestPractices.md` | 50, 52, 55, 59, 436 | security |
| `.claude/skills/github-pages/references/DnsConfiguration.md` | 344, 349 | security |
| `.claude/skills/github-pages/SKILL.md` | 268, 271 | security |
| `.claude/skills/github-pages/workflows/CustomDomain.md` | 184, 187 | security |
| `.claude/skills/gitops-principles/references/anti-patterns.md` | 365, 557, 562 | security |
| `.claude/skills/gitops-principles/references/core-principles.md` | 223 | security |
| `.claude/skills/gitops-principles/references/patterns-and-practices.md` | 204 | security |
| `.claude/skills/gitops-principles/SKILL.md` | 74, 113, 329, 452 | security |
| `.claude/skills/graphify/references/query.md` | 52 | security |
| `.claude/skills/holmesgpt/references/configuration.md` | 272, 278 | security |
| `.claude/skills/holmesgpt/references/data-sources.md` | 285, 287, 548 | security |
| `.claude/skills/holmesgpt/references/integrations.md` | 251 | security |
| `.claude/skills/holmesgpt/SKILL.md` | 205 | security |
| `.claude/skills/justfile/References/Patterns.md` | 56 | security |
| `.claude/skills/knative/SKILL.md` | 284 | security |
| `.claude/skills/kql/references/patterns.md` | 6, 159 | security |
| `.claude/skills/kql/references/service-tables.md` | 69, 86, 89, 122 | security |
| `.claude/skills/kql/SKILL.md` | 3 | security |
| `.claude/skills/macos-cleaner/.security-scan-passed` | 1 | security |
| `.claude/skills/macos-cleaner/references/cleanup_targets.md` | 375, 378 | security, keychain |
| `.claude/skills/macos-cleaner/references/safety_rules.md` | 78, 83, 84 | security, keychain |
| `.claude/skills/macos-cleaner/SKILL.md` | 960, 1045 | security |
| `.claude/skills/managing-infra/DOCKERFILE.md` | 53 | security |
| `.claude/skills/managing-infra/GITHUB-ACTIONS.md` | 11, 188 | security |
| `.claude/skills/managing-infra/SKILL.md` | 3, 26 | security |
| `.claude/skills/notebooklm/SKILL.md` | 164 | security |
| `.claude/skills/opentelemetry/examples/values-daemonset.yaml` | 109 | security |
| `.claude/skills/opentelemetry/examples/values-deployment.yaml` | 110 | security |
| `.claude/skills/opentelemetry/references/KUBERNETES.md` | 159 | security |
| `.claude/skills/power-bi-diagnostics/SKILL.md` | 145, 146 | security |
| `.claude/skills/power-bi-docs/SKILL.md` | 47, 48, 95, 96 | security |
| `.claude/skills/power-bi-pages/SKILL.md` | 177 | security |
| `.claude/skills/power-bi-security/SKILL.md` | 2, 3, 7, 9, 19, 22, 23, 26, 29, 33, 55, 56, 59, 79, 84, 90, 93, 100, 112, 119, 120, 123 | security |
| `.claude/skills/pre-commit/HooksReference.md` | 99, 185, 231, 297, 509 | security |
| `.claude/skills/pre-commit/SecurityHooks.md` | 1, 3, 90, 92, 184, 186, 229, 247, 266, 269, 288, 295, 303, 378, 381, 396 | security |
| `.claude/skills/pre-commit/SKILL.md` | 3, 8, 24, 36, 64, 86 | security |
| `.claude/skills/pre-commit/Tools/HookGenerator.ts` | 14, 209, 297, 298, 299, 300, 302, 303, 304, 305, 306, 431, 444, 448 | security |
| `.claude/skills/pre-commit/Workflows/AddHooks.md` | 10, 38, 120 | security |
| `.claude/skills/pre-commit/Workflows/CIIntegration.md` | 394, 396, 407 | security |
| `.claude/skills/premortem/SKILL.md` | 3 | security |
| `.claude/skills/progressive-delivery/References/argo-rollouts/analysis-metrics.md` | 223 | security |
| `.claude/skills/progressive-delivery/References/kargo.md` | 3, 630, 920 | security |
| `.claude/skills/progressive-delivery/References/kargo/security.md` | 1, 3, 7, 517, 523 | security, credential rotation |
| `.claude/skills/pyroscope/references/helm-deployment.md` | 73, 79 | security |
| `.claude/skills/repomix/SKILL.md` | 296, 372, 384, 400, 405, 408, 409, 424, 443 | security |
| `.claude/skills/reviewing-code/SKILL.md` | 3, 16, 22, 29 | security |
| `.claude/skills/senhasegura/References/DsmConfigExample.yaml` | 56 | secret injection |
| `.claude/skills/senhasegura/References/McpIntegration.md` | 84 | security |
| `.claude/skills/senhasegura/References/OAuth1Legacy.md` | 48 | security |
| `.claude/skills/senhasegura/Workflows/RotatePasswords.md` | 37 | security |
| `.claude/skills/shell-prompt/references/performance-tuning.md` | 373 | security |
| `.claude/skills/ship/references/azure-devops.md` | 139 | security |
| `.claude/skills/using-cloud-cli/AWS.md` | 42 | security |
| `.claude/skills/using-git-worktrees/references/bmad-orchestration.md` | 148 | security |
| `.claude/skills/vault-setup/RoleTemplates.md` | 62 | security |
| `.claude/skills/verification-loop/agents/openai.yaml` | 5 | security |
| `.claude/skills/verification-loop/SKILL.md` | 66, 100 | security |
| `.claude/skills/youtube-search/SKILL.md` | 48 | security |
| `.codex/Skills/graphify/references/query.md` | 52 | security |
| `.codex/Skills/verification-loop/agents/openai.yaml` | 5 | security |
| `.codex/Skills/verification-loop/SKILL.md` | 66, 100 | security |
| `artifacts/DEEPSEEK_CC_SWITCH.md` | 19, 240 | security, keychain |
| `artifacts/deepseek-cc-switch/implementation_plan.md` | 35, 102, 113, 121 | keychain, security |
| `artifacts/deepseek-cc-switch/risk_assessment.md` | 28 | keychain |
| `artifacts/deepseek-cc-switch/task.md` | 10 | keychain |
| `artifacts/deepseek-cc-switch/walkthrough.md` | 85 | keychain |
| `CLAUDE.md` | 22 | security |
| `context/REPOSITORY_CONTEXT.md` | 8 | security |
| `docs/Guia Completo para Organização e Automação de E-mails no Mail do MacBook/execucao-mail/reports/mail-metadata-2026-08-07.tsv` | 921, 922, 1043, 1221, 1229, 1447, 1718, 1721 | security |
| `docs/PROMPT-AGENTE-IDE-ROTACAO-CREDENCIAIS.md` | 10, 20, 29, 41, 42, 46, 51, 82, 84, 86, 145 | keychain, security, context7_api_key, add-generic-password |
| `docs/references.md` | 181 | security |
| `docs/TUTORIAL-ROTACAO-CREDENCIAIS.md` | 18, 49, 65, 67, 72, 79, 110, 125 | context7_api_key, keychain, security, add-generic-password |
| `docs/TUTORIAL-ROTACAO-KEYCHAIN.md` | 1, 9, 13, 20, 22, 41, 50, 51, 54, 60, 63, 77, 87, 100, 105, 106, 107, 120, 129, 139 | keychain, context7_api_key, security, add-generic-password, find-generic-password |
| `macos_use/agent/desktop/service.py` | 476 | security |
| `macos_use/ax/core.py` | 203, 245 | security |
| `macos_use/main.py` | 60, 217 | security |
| `Plans/skills-context7-we-need-your-compiled-blum.md` | 33, 97, 99 | context7_api_key |
| `plugins/macbook-daily-care/skills/macbook-daily-care/references/functional-spec.md` | 16 | security |
| `plugins/macbook-daily-care/skills/macbook-daily-care/SKILL.md` | 12 | security |
| `README.md` | 262, 278 | security |
| `SCRIPTS-MACREPAIR/mac-cleanup-py/.github/workflows/codeql.yml` | 21 | security |
| `SCRIPTS-MACREPAIR/mac-cleanup-py/CODE_OF_CONDUCT.md` | 70 | security |
| `SCRIPTS-MACREPAIR/mac-cleanup-py/SECURITY.md` | 1, 14 | security |
| `SCRIPTS-MACREPAIR/mac-scripts/audit_mac.sh` | 164 | security, keychain |
| `SCRIPTS-MACREPAIR/wifi/wifi_diagnostico_completo.sh` | 47 | security |
| `SCRIPTS-MACREPAIR/wifi/wifi_engine.sh` | 249 | security |
| `SECURITY.md` | 1, 3, 69, 93, 103, 105, 111, 113, 115, 119, 142, 147, 149, 161, 175 | security |
| `tools/azure-pim/pyproject.toml` | 24 | security |

