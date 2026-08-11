# Auditoria Matinal de E-mail

Projeto de automação somente leitura para o Apple Mail. A pasta
`/Users/danilonovais/MacOS-Use/mail_automation` é a origem instalada: o
LaunchAgent aponta diretamente para o AppleScript desta pasta.

## O que a automação faz

- Inspeciona até 500 mensagens recentes para localizar no máximo 150 não lidas.
- Lê apenas remetente, assunto e estado de leitura.
- Classifica VIP + urgente como ação imediata, VIP ou urgente como atenção e
  remetentes de baixo sinal como ruído.
- Gera um relatório diário em `~/Desktop/Auditoria-Mail/` e uma notificação com
  contagens.
- Registra nos logs somente contagens e o caminho do relatório, sem duplicar
  remetentes ou assuntos.
- Não marca, move, apaga, encaminha nem responde mensagens.

## Configuração

Edite somente as propriedades no topo de `mail-morning-audit.applescript`:

- `vipSenders`: domínios ou endereços realmente críticos.
- `urgentKeywords`: palavras que representam prazo curto.
- `noiseSenders`: padrões de remetentes de baixo sinal.
- `maxMessagesToScan`: limite de não lidas analisadas.
- `maxInboxMessagesToInspect`: proteção de desempenho para caixas grandes.

Evite termos genéricos isolados como `hoje`: no teste inicial eles produziram
falsos positivos em calendários e promoções. Prefira expressões como `vence hoje`.

## Validação e primeira execução

```bash
cd /Users/danilonovais/MacOS-Use/mail_automation
./script/build_and_run.sh --verify
./script/build_and_run.sh
```

Na primeira execução, autorize o aplicativo que iniciou o comando em
`Ajustes do Sistema > Privacidade e Segurança > Automação > Mail`. Não é
necessário conceder Acesso Total ao Disco.

Confirme o relatório em `~/Desktop/Auditoria-Mail/`. A execução manual antes da
instalação garante que a permissão do Mail seja solicitada em uma sessão visível.

## Instalação

```bash
./mail_automation/script/build_and_run.sh --install
```

O instalador:

1. valida o plist e compila o AppleScript;
2. cria `~/Library/Logs/MailAudit/`;
3. instala somente o plist em `~/Library/LaunchAgents/`;
4. registra o agente com `launchctl bootstrap` no domínio da sessão atual.

O agente roda ao ser carregado e todos os dias às 08:00. Se o Mac estiver
desligado nesse horário, não há execução retroativa; a próxima execução acontece
no próximo carregamento ou no horário seguinte.

## Operação

```bash
./mail_automation/script/build_and_run.sh --verify
./mail_automation/script/build_and_run.sh --logs
./mail_automation/script/build_and_run.sh --run-agent
```

`--run-agent` dispara o serviço já instalado. O comando sem argumentos executa o
AppleScript no Terminal, útil para testes e para solicitar permissão.

## Desinstalação

```bash
./script/build_and_run.sh --uninstall
```

A desinstalação descarrega o agente e remove apenas o plist instalado. O código,
os relatórios e os logs permanecem para auditoria e recuperação.

## Revisão após sete dias

- Revisar falsos positivos e negativos nas listas de configuração.
- Manter nas listas VIP somente pessoas, clientes e serviços críticos.
- Se 500 mensagens recentes não forem suficientes para alcançar 150 não lidas,
  ajustar os limites gradualmente e observar a duração pelos logs.
- Revalidar após qualquer mudança com `./script/build_and_run.sh --verify`.

## iOS

O Atalhos não replica a consulta e a lógica do AppleScript com a mesma precisão.
Uma automação iOS pode servir como complemento, mas a execução canônica deste
projeto permanece no macOS.
