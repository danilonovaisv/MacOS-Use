# Plano de Execução — Organização Segura do Apple Mail

Data de início: 2026-08-07
Estado: em execução

## Objetivo

Implantar o piloto GTD + Inbox Zero nas seis contas do Apple Mail, mantendo as mensagens no servidor e impedindo encaminhamentos, exclusões, cancelamentos de inscrição, iMessage e movimentos para “No Meu Mac”.

## Guardrails

- Alterações no Mail somente pela interface gráfica.
- AppleScript limitado ao diagnóstico somente leitura de metadados.
- Nenhum corpo, anexo ou destinatário será lido pelo diagnóstico.
- Nenhuma mensagem será apagada, encaminhada ou movida para armazenamento local.
- O passivo de não lidas não será processado nesta primeira execução.
- A proteção de atividade do Mail exige confirmação imediatamente antes da alteração.

## Fases

- [x] 1. Validar recuperação antes das alterações: backup externo falhou; usuário autorizou prosseguir com snapshot local e snapshot dos plists.
- [x] 2. Criar snapshot datado dos arquivos de regras, estados, VIPs, sinalizadores e Caixas Inteligentes.
- [x] 3. Registrar a ordem e a configuração atuais das regras.
- [x] 4. Executar diagnóstico de até 500 mensagens recentes por conta, somente com metadados permitidos.
- [x] 5. Gerar relatório de volume, remetentes, domínios, não lidas e candidatos a regras/cancelamento.
- [x] 6. Desativar regras existentes durante o piloto.
- [x] 7. Criar cinco regras `PILOTO - ...` com ações seguras.
- [x] 8. Renomear sinalizadores e criar/ajustar Caixas Inteligentes GTD.
- [x] 9. Configurar lixo eletrônico, notificações e sons.
- [ ] 10. Solicitar confirmação e, se aprovada, ativar Proteger Atividade no Mail.
- [x] 11. Aplicar regras a uma amostra controlada de até 50 mensagens recentes por conta.
- [ ] 12. Verificar o estado final e agendar a revisão do piloto após sete dias.

## Critérios de aprovação

- Zero exclusões, encaminhamentos e movimentos para “No Meu Mac”.
- Zero duplicação observada.
- Cada regra possui exemplos corretos na amostra.
- Falsos positivos abaixo de 1%.
- Mensagens financeiras e profissionais críticas continuam visíveis.

## Gate de segurança atual

O backup externo de 2026-08-07 falhou por falta de espaço no volume `BACKUP-MAC`. Um snapshot local do Time Machine foi criado às 19:26:39 e os arquivos de configuração do Mail foram copiados e verificados por SHA-256. Em 2026-08-07, o usuário autorizou explicitamente prosseguir com esses dois pontos de recuperação locais.

## Arquivos de saída

- `findings.md`: fatos, riscos, contagens e decisões.
- `progress.md`: diário de execução, validações e erros.
- `backups/<data>-pre-pilot/`: snapshot de recuperação.
- `reports/mail-metadata-<data>.tsv`: diagnóstico permitido.
- `reports/metadata-summary-<data>.md`: resumo agregado.
- `reports/vip-review-<data>.md`: VIPs para aprovação.
- `reports/unsubscribe-candidates-<data>.md`: candidatos, sem cancelamento automático.
- `reports/pilot-execution-<data>.md`: amostras, configurações e critérios pendentes do piloto.
