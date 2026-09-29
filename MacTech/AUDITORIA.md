# Auditoria e consolidacao MacTech

Data: 14/09/2026. Estado inicial: macOS 27.0 (26A428), arm64, MacBookPro18,2,
M1 Max (10 nucleos), 32 GiB RAM. APFS, FileVault ativo, aproximadamente 63-65 GiB
disponiveis em 926 GiB. O volume Data estava 93% ocupado. O resultado de 17%
do script system_audit.sh refere-se ao volume de sistema e nao representa Data.
Shell: /bin/zsh. Swift 6.4; CLT selecionado; Xcode-beta 27.0 (25183.45.9) instalado.
Volumes: sistema, Data, VM, Preboot, Update, Recovery, /nix, BACKUP-MAC e snapshots
Time Machine montados. Inventario de volumes obtido por mount e diskutil info.

## Inventario das versoes

| Campo | App A | App B |
|---|---|---|
| Caminho | /Users/danilonovais/Otimizador MacTech.app | /Users/danilonovais/macos_maintenance.app |
| Bundle ID | com.apple.automator.Otimizador-MacTech | com.apple.automator.macos-maintenance |
| CFBundleShortVersionString | 1.3 | 1.3 |
| CFBundleVersion | 534 | 537.2 |
| Executavel | Contents/MacOS/Automator Application Stub | Contents/MacOS/Automator Application Stub |
| Arquitetura | arm64 + x86_64 | arm64 |
| Assinatura | ad-hoc; verificacao strict falha por resource fork/Finder metadata | ad-hoc; verificacao strict passou |
| Team ID | ausente | ausente |
| SHA256 manifesto | 8525bc5afc157666d8471df7b8e9197bad5f422934ee0927a5269398e176b660 | 416fc2bb90afc415d2f701a2041d1b5888b19506528a3558ad24ab9e2e5cf67f |
| SHA256 workflow | f3226d9f99d6e4ea310aec54769eba489a0648617eaa488a74b280d4bd6cf8a2 | f91807a9e172c65ebd01e9b6b5a2be1f2062bf10339f3c95f6986ab1dfa1ad90 |
| Modificacao do bundle | 26/05/2026 05:24:57 local | 29/06/2026 23:07:34 local |
| Tecnologia | Automator, AppleScript, zsh | Automator, scripts declarados bash executados por zsh |
| Startup encontrado | nenhum | Login Items, confirmado na UI e sfltool |
| Helper proprio/XPC/framework embutido | nenhum encontrado | nenhum encontrado |
| Scripts | AppleScript + shell inline | dois shells inline, apos pausa de 300s |

O hash de manifesto e SHA256 do JSON canonico (sort_keys, separators compactos)
de lista ordenada de caminho relativo, tamanho e SHA256 de cada arquivo do bundle.
Nao inclui xattrs; a validacao de assinatura e registrada separadamente.
Os hashes individuais do executavel, plist, scripts e recursos, dependencias otool,
entitlements e resultado dos comandos ficam em Audit/inventory.json.

Foram pesquisados Spotlight por nome e Bundle ID, pasta pessoal, /Applications,
~/Applications, /Library, ~/Library, projeto, LaunchAgents/Daemons, cron e perfis
de shell. Nenhuma terceira instalacao ativa identificada ate esta coleta.
A busca recursiva irrestrita foi interrompida apos localizar os dois apps, pois
incluia snapshots e arvores muito grandes; nao se afirma ausencia de copias
historicas em todos os backups ou em diretorios sem permissao. DeviceFS e um
diretorio MisterHorse tiveram erros de acesso. Nenhum TCC foi contornado.

Fontes auxiliares encontradas, nao chamadas pelos bundles atuais:

- SCRIPTS-MACREPAIR/mac-scripts/mactech_optimizer.sh e MacTech_Diag_Auto.sh.
- Copias identicas dos dois scripts em ~/COMANDOS-E-LIMPEZA-MAC/mac-scripts/.
- ~/Desktop/MacTech_Diag_Auto.command e variantes mactech_diag_optimize_FIXED_*.sh.
- Fonte v3 e analise de risco em ~/Library/Application Support/Claude/local-agent-mode-sessions/.../outputs/.
- ~/Desktop/MacTech_Report_20260813-004540 (relatorio preexistente).

O workflow Automator e fonte executavel recuperavel, nao exige engenharia reversa
do stub Apple. A reimplementacao parte desse comportamento e das rotinas de
diagnostico existentes; nao edita bundles legados.

## Achados por severidade

CRITICO B: exclui MobileSync/Backup, Xcode/Archives e dados de todos os simuladores.
Backups, simbolos e estado de testes sao dados, nao lixo regeneravel.

CRITICO B: inclui Adobe/Common/Plug-ins/7.0/MediaCore na lista de caches.
Esse caminho contem plugins; remocao pode quebrar aplicativos e projetos.

CRITICO B: docker container prune -f seguido de docker volume prune -f pode
tornar dados de stacks parados elegiveis para remocao. A primeira etapa tambem
usa docker system prune -af. Nao executar no host para medir ganhos.

ALTO A: rm -rf ~/Library/Caches/* aparece tanto na etapa privilegiada quanto
na etapa de usuario, sem verificar aplicativos em uso. Usa purge e reinicia
opendirectoryd e mDNSResponder sem evidencia de falha atual.

ALTO A: o cancelamento do dialogo e capturado por try/on error e retorna input;
o workflow continua para pausa de 60s e para o shell destrutivo. Cancelar o
dialogo inicial nao e garantia de interrupcao do pipeline.

ALTO B: esvazia lixeiras locais/externas; exclui logs por idade; altera dados
Teams; remove caches de pacotes e de desenvolvimento indiscriminadamente.
safe_rm valida apenas existencia, nao confinamento ou symlinks ancestrais.

ALTO B: a primeira etapa solicita sudo em contexto Automator e mantem um loop
de renovacao. O shell configurado e zsh apesar do script usar bash/shopt.
A shebang nao sobrepoe a escolha do shell do Automator. A analise sintatica
zsh -n passou, mas isso nao valida shopt ou semantica em runtime.

ALTO B: dry-run da primeira etapa nao protege o workflow completo: a segunda
etapa nao oferece dry-run; a primeira pode reiniciar em modo destrutivo apos Enter.

MEDIO A: execucao continua depois de falhas e anuncia sucesso sem conferir
resultados; sobrescreve o log Desktop a cada execucao. brew update/upgrade/
cleanup cria mudancas de versao e I/O imprevisiveis. APFS verifyVolume no login
e caro e nao equivale a otimizacao.

MEDIO B: estimativas acumuladas por du nao medem espaco fisico recuperado APFS.
Logs de sucesso podem nao refletir falhas ignoradas. Sem bloqueio de concorrencia.

MEDIO: ambas sao ad-hoc, sem Team ID; A falha strict. Descricoes genericas de
camera, contatos etc. nos plists sao declaracoes, nao prova de permissao TCC
concedida ou de uso efetivo desses recursos.

ALTO nos scripts externos: pkill -f Adobe pode perder trabalho nao salvo;
reindexar Spotlight por aparecer em top pode agravar a carga existente.

## Fluxos e startup

A: dialogo -> shell root (snapshots/DNS/daemon/purge/caches) -> pausa 60s ->
diagnostico termico/bateria -> snapshots + verifyVolume -> DNS/daemon -> caches
+ purge -> Homebrew update/upgrade/cleanup -> log final incondicional.

B: pausa 300s -> mac-cleanup legado (sudo e limpeza ampla) -> v3 (limpeza
ampla adicional e log). Duas implementacoes redundantes no mesmo app.

Somente B foi confirmado como Login Item habilitado. sfltool mostra URL historica
/Users/501/macos_maintenance.app; UI apresenta macos_maintenance.app.
Nenhum LaunchAgent/Daemon referente aos bundles, helper privilegiado proprio ou
entrada cron foi encontrado. Cron encontrado e de lume-update, fora do escopo.
Nenhum processo dos bundles estava ativo. Nao ha prova de dois startups ativos;
ha duplicacao interna em B e possibilidade de concorrencia por abertura manual.

## Matriz de funcionalidades

| Funcao | A | B | Manter | Melhorar | Remover | Motivo |
|---|---|---|---|---|---|---|
| Disco/espaco | snapshots + verifyVolume | df parcial | sim | volume Data e APFS | thinning automatico | preservar recuperacao |
| Armazenamento | caches | exclusao ampla | diagnostico | categorias e revisao | metas de GB apagados | evitar falsa economia |
| Temporarios | amplo | amplo | revisao | origem/impacto | limpeza por idade | origem nao prova inutilidade |
| Caches | rm geral | multiplas arvores | revisao | medir categoria | exclusao automatica | evitar downloads/rebuilds |
| Logs | log Desktop | exclui logs | OSLog + JSON | erros e duracao | exclusao de logs alheios | preservar evidencia |
| Inicializacao | nao encontrada | Login Item | um servico | SMAppService e lock | workflow legado | reduzir concorrencia |
| Memoria | purge | purge na primeira etapa | diagnostico | vm_stat/swap/pressao | purge | sem beneficio demonstrado |
| CPU/processos | reinicia servicos | indireto | diagnostico | duas amostras top | killall automatico | preservar trabalho |
| Saude geral | bateria/termica | limitada | sim | resultado parcial explicito | score inventado | observacoes verificaveis |
| Diretorios grandes | nao | du antes de apagar | sim | medida manual limitada | varredura pesada no login | baixo impacto |
| Obsoletos | brew cleanup | por idade | revisao | por projeto | idade como autorizacao | evitar perda |
| Desenvolvimento | Homebrew | muitos gerenciadores | revisao | impacto de regeneracao | purge global | caches valiosos |
| Xcode | nao | Archives/DerivedData/simuladores | revisao | proteger Archives | erase all | dados de usuario |
| Homebrew | update/upgrade/cleanup | cleanup/cache/autoremove | revisao | deixar gerenciador decidir | update silencioso | previsibilidade |
| Limpeza | destrutiva | destrutiva | plano | abertura no Finder | executor generico | nenhuma exclusao aprovada |
| Otimizacao | purge/DNS/daemons | cache/DNS | recomendacoes | evidencia antes de acao | placebo | evitar regressao |
| Relatorio | texto sobrescrito | estimativa cumulativa | sim | JSON privado por execucao | sucesso incondicional | auditabilidade |
| Notificacao | sucesso com som | console | estado na UI | sem notificacoes vazias | som automatico | reduzir interrupcoes |

## Classificacao operacional

SAFE: sw_vers, sysctl de leitura, df Data, vm_stat, top limitado, pmset de leitura,
relatorio privado e lock. Sao as unicas acoes automaticas.

REVIEW: tamanho de caches, logs, npx, DerivedData, arquivos grandes, pacotes
obsoletos. Relatar caminho, tamanho quando medido, origem e impacto; sem exclusao.

ADMIN: reparo APFS, reset de servicos ou rede so em investigacao especifica com
evidencia e autorizacao. Nenhum helper root no novo app.

REMOVE: exclusao de backups/Archives/plugins/volumes Docker, erase all, limpeza
indiscriminada, purge, reindexacao automatica, esvaziar lixeira em login, remover
HSTS, encerrar Adobe, updates nao solicitados e sucesso nao verificado.

## Plano aprovado pelo escopo

1. Preservar fontes, manifests, configuracao de startup e hashes.
2. Criar implementacao Swift/SwiftUI independente, OSLog e JSON privado.
3. Migrar diagnostico; converter limpeza em revisao. Nao ha remocao de dados
   de terceiros aprovada por categoria, portanto nao existe executor destrutivo.
4. Usar SMAppService.agent com o mesmo binario --automatic, sem helper root.
5. Adiar 120s, prioridade background/Nice 10/LowPriorityIO, lock entre CLI/UI/login;
   concluir no maximo uma vez por usuario/boot. Falha nao marca ciclo concluido.
6. Testar antes da instalacao; guardar originais e desabilitar somente Login Item B.
7. Registrar apenas novo servico e validar configuracao real sem reiniciar a sessao.

Nao foi executado um fluxo destrutivo legado real: isso violaria os requisitos
de seguranca do pedido. Auditoria estatica e parse sem execucao nao equivalem
a comparativo dinamico integral. Logout/reboot sao testes pendentes, pois
interromperiam os aplicativos e a sessao de trabalho ativos.

## Referencias consultadas

Context7: /websites/developer_apple_servicemanagement (registro, status, agentes,
BundleProgram); /websites/developer_apple_foundation (Process, FileManager).
OSLog nao teve correspondencia oficial adequada no resolvedor; fallback Apple:

- https://developer.apple.com/documentation/servicemanagement/updating-helper-executables-from-earlier-versions-of-macos
- https://developer.apple.com/documentation/servicemanagement/smappservice/agent(plistname:)
- https://developer.apple.com/documentation/os/generating-log-messages-from-your-code
- https://developer.apple.com/documentation/swiftui/nsapplicationdelegateadaptor

Build local ad-hoc nao equivale a distribuicao notarizada. A distribuicao externa
necessita identidade Developer ID e notarizacao; nao foi enfraquecido Gatekeeper.

## Migracao e validacao final

- Oficial: /Applications/Otimizador MacTech.app, bundle
  com.danilonovais.mactech, versao 4.0.0, build 400, arm64.
- Startup: com.danilonovais.mactech.login, SMAppService.agent, habilitado e
  confirmado no banco BTM, na interface do app e nos Ajustes do Sistema.
- Item macos_maintenance removido de Abrir ao Iniciar; nenhum mecanismo antigo
  correspondente permaneceu ativo. Os dois bundles antigos foram movidos para
  /Users/danilonovais/MacTech-Rollback/2026-09-15-pre-v4/quarantine.
- Backup previo em apps/ e quarentena possuem manifests SHA256 independentes em
  evidence/. Os bundles legados nao foram apagados.
- Swift/XCTest: 8 testes passaram, cobrindo traversal, volume externo, symlink,
  lock concorrente, permissoes 0700/0600, ciclo de boot, dry-run e erro de Process.
- Dry-run CLI e UI: oito categorias, zero exclusoes. Busca estatica no codigo v4
  nao encontrou rm, sudo, killall, pkill, defaults, erase, prune ou thinning.
- Analise manual inicial: 2,69 s, user 0,17 s, system 1,39 s, max RSS
  10.371.072 bytes, zero block input/output reportado por /usr/bin/time.
- Concorrencia real: primeira analise status 0; segunda status 1 com bloqueio.
- UI instalada abriu e exibiu diagnostico, dry-run, configuracao e startup ativo.
- codesign --verify --deep --strict passou. spctl recusou a build ad-hoc, esperado
  sem Developer ID/notarizacao; esta build foi validada apenas nesta maquina.
- Logout/login ou reboot completo nao foi forcado para nao interromper a sessao.
  O registro imediato do agente foi observado; a primeira execucao automatica
  real iniciou com atraso de 120 s e revelou que `top` era encerrado pelo timeout
  no contexto headless. A implementacao foi corrigida para `ps` de execucao unica
  e revalidada antes da entrega.

A segunda execucao automatica, com a correcao, concluiu em 0,093 s: oito de oito
comandos retornaram status 0, `recoveredBytes=0` e `changes=[]`. O marcador de
boot foi salvo com modo 0600. Uma invocacao subsequente retornou imediatamente
`already_completed_this_boot`. O OSLog registra inicio, fim e skip por ciclo.

A assinatura final usa Apple Development, Team ID C6HAWJJAX5, hardened runtime.
`codesign --verify --deep --strict` passou. `spctl` continua recusando por nao se
tratar de assinatura Developer ID notarizada; nenhuma excecao do Gatekeeper ou
remocao de quarentena foi aplicada.
