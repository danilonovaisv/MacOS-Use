# Implantação do piloto de automação do Apple Mail

## Estado de segurança

Este diretório contém um piloto somente leitura para o Mail 16.0 no macOS 27.0.

- `TaxonomyAndTagging.applescript` lê remetente e assunto e registra uma categoria sugerida.
- `AntiSpamUnsubscribe.applescript` verifica apenas a presença de `List-Unsubscribe` nos cabeçalhos e registra o ID da mensagem para revisão.
- `SmartNotifications.applescript` exibe banner somente quando uma regra já validada o aciona ou quando uma mensagem crítica é selecionada manualmente.
- Nenhum script move, apaga, arquiva, encaminha, marca como lida, sinaliza ou cria caixas de correio.
- A execução manual exige seleção explícita no Mail e é limitada a 50 mensagens (20 para notificações).

## Componentes instalados

Os AppleScripts são compilados como `.scpt`, e os scripts compilados e o launcher são instalados em:

```text
~/Library/Application Scripts/com.apple.mail/
```

O LaunchAgent de saúde é instalado em:

```text
~/Library/LaunchAgents/com.user.mailautomation.plist
```

O LaunchAgent não lê mensagens. A cada 30 minutos ele confirma apenas que os quatro arquivos implantados continuam legíveis. A auditoria diária existente `com.danilonovais.mailaudit` permanece independente.

## Permissões TCC

Não conceda Acesso Total ao Disco para este piloto. A permissão de Automação pode ser solicitada pelo macOS na primeira execução manual de `osascript` ou do Atalhos ao controlar o Mail. Aceite somente para o aplicativo que você escolheu usar. Notificações podem ser habilitadas para o processo que executa `SmartNotifications.applescript`.

## Teste manual controlado

1. Selecione de uma a cinco mensagens de teste no Mail.
2. Execute:

   ```bash
   "$HOME/Library/Application Scripts/com.apple.mail/TriggerMailAutomation.sh" --dry-run
   ```

3. Verifique `~/Library/Logs/MailAutomation.log`.
4. Confirme que as mensagens continuam na mesma caixa e sem alteração de leitura/sinalizador.

Sem seleção, o launcher registra `SKIP` e não percorre a Caixa de Entrada.

## Regras do Mail para o piloto

As regras devem ser criadas manualmente na interface do Mail para que a ordem existente permaneça visível e auditável. Não use `Every Message` no piloto.

| Regra | Condição inicial | Script | Efeito |
|---|---|---|---|
| `PILOTO - Classificação` | uma conta de teste ou remetentes aprovados | `TaxonomyAndTagging.scpt` | somente log de sugestão |
| `PILOTO - Unsubscribe` | cabeçalho `List-Unsubscribe` contém `http` ou `mailto` | `AntiSpamUnsubscribe.scpt` | somente lista de revisão |
| `PILOTO - Prioridade` | VIP ou assunto contém `URGENTE`, `CRÍTICO` ou `CONTRATO` | `SmartNotifications.scpt` | banner sem som |

Não aplique as regras ao histórico durante a criação. Primeiro valide mensagens novas por sete dias e uma amostra manual de até 50 mensagens por conta.

## Verificação

```bash
plutil -lint ./mail-automation-staging/LaunchDaemons/com.user.mailautomation.plist
bash -n ./mail-automation-staging/Shortcuts/TriggerMailAutomation.sh
launchctl print "gui/$(id -u)/com.user.mailautomation"
tail -n 50 "$HOME/Library/Logs/MailAutomation.log"
```

## Rollback recuperável

Antes da instalação, os arquivos substituídos são copiados para uma pasta datada em:

```text
~/Library/Application Support/MailAutomation/Backups/
```

Para interromper o agendamento, use `launchctl bootout` apontando para o plist instalado. Mova somente os três `.scpt` e o launcher deste piloto para uma pasta de quarentena; não use curingas em `~/Library/Application Scripts/com.apple.mail/`, pois esse diretório contém scripts anteriores do usuário.

## Limites desta implantação

- A criação e a ordenação das regras na interface do Mail continuam pendentes de validação visual do usuário.
- Renomear sinalizadores, ajustar Caixas Inteligentes, VIPs, filtro de lixo, privacidade e Foco Trabalho não é feito por estes scripts.
- Cancelamento de inscrição, encaminhamento, exclusão e movimento de mensagens permanecem proibidos sem autorização específica posterior.
