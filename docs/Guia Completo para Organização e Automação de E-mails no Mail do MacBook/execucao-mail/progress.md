# Diário de Execução

## 2026-08-07

- [x] Skills `planning-with-files`, `apple-mail`, `computer-use` e `verification-before-completion` carregadas.
- [x] Plano operacional criado antes das alterações no Mail.
- [x] Worktree inspecionada; alterações existentes serão preservadas.
- [ ] Backup externo novo do Time Machine iniciado, mas não validado: destino sem espaço mínimo.
- [x] Snapshot local do Time Machine criado: `com.apple.TimeMachine.2026-08-07-192639.local`.
- [x] Snapshot dos arquivos do Mail criado e verificado por SHA-256.
- [x] Ordem e configuração das 12 regras registradas em 13 capturas e no snapshot dos plists.
- [x] Diagnóstico de metadados concluído: 2.173 mensagens, zero erros.
- [x] Resumo agregado, revisão de VIPs e candidatos a cancelamento gerados.
- [x] Usuário autorizou prosseguir sem backup externo novo, usando os dois pontos de recuperação locais.
- [x] As 12 regras antigas foram desativadas e preservadas.
- [x] Cinco regras `PILOTO - ...` criadas e ativas somente para mensagens novas.
- [x] Plists verificados: zero transferência, cópia, script, encaminhamento ou exclusão nas regras piloto.
- [x] Notificações de regra restritas a `PILOTO - COBRANÇA GOOGLE` e `PILOTO - ALL SET IMPORTANTE`.
- [x] Sinalizadores renomeados: `Ação hoje`, `Aguardando`, `Financeiro` e `Leitura`.
- [x] Caixas Inteligentes globais criadas: `00 · Ação hoje`, `10 · Aguardando`, `20 · Financeiro` e `30 · Leitura`; `Hoje` renomeada para `90 · Hoje`.
- [x] Plist verificado: as quatro Caixas Inteligentes omitem Lixo e Apagadas e usam as cores 0, 1, 5 e 4.
- [x] Filtro de lixo ativado em modo conservador: marcar como lixo e manter na Caixa de Entrada.
- [x] Exceções preservadas para Contatos, Destinatários Anteriores, nome completo e cabeçalhos confiáveis; execução antes das regras continua desligada.
- [x] Notificações gerais alteradas para VIPs e sons de ações secundárias desativados.
- [x] Foco `Work` criado com filtro do Mail limitado a `danilo@portfoliodanilo.com` e `danilonovais@portfoliodanilo.com`.
- [ ] Proteção de atividade confirmada e configurada.
- [x] Amostra do piloto aplicada: Google 50, Yahoo! 50, dannovaisv@gmail.com 50, dannovaisvilela@gmail.com 50, danilo@portfoliodanilo.com 50 e danilonovais@portfoliodanilo.com 9; total 259.
- [x] Após cada amostra, a conta permaneceu selecionada e as mensagens continuaram visíveis na Caixa de Entrada.
- [x] Revisão de sete dias agendada para 2026-08-14 às 09:00; o lembrete deverá ser convertido em revisão trimestral após a validação.
- [x] Verificação independente concluída: snapshot local presente, nove hashes válidos, 2.173 registros de metadados, zero erros de diagnóstico e lembrete ativo.

## Registro de erros

- `tmutil startbackup --auto --block` terminou sem criar um novo backup.
- Logs confirmaram `BACKUP_FAILED_TARGETVOL_DISK_FULL (56)`: 99,94 GB livres para mínimo de 99,97 GB.
- A tentativa de excluir `2026-07-30-152949.interrupted` com `tmutil` foi recusada por exigir privilégios administrativos; nenhum arquivo foi removido.
- A busca recursiva de tamanho no backup foi interrompida após 30 segundos para evitar uma operação longa e sem benefício.
- A segunda tentativa com `tmutil startbackup --auto --rotation --block` também falhou com `BACKUP_FAILED_TARGETVOL_DISK_FULL (56)`.
- Uma chamada longa de seleção do piloto foi interrompida após ficar lenta; a interface foi reinspecionada e retomada exatamente na amostra do Yahoo!, sem repetir a aplicação no Google.

## Verificação inicial

- Os oito plists atuais do Mail correspondem byte a byte ao snapshot pré-piloto.
- As 12 regras continuam ativas e nenhuma preferência do Mail foi alterada.
- Foram salvas 12 capturas individuais de configuração e uma captura da ordem das regras.
- O relatório possui 2.173 linhas de dados e o log de erros possui somente o cabeçalho.

## Verificação do piloto

- As 12 regras antigas permanecem inativas.
- Somente as cinco regras `PILOTO - ...` presentes em `SyncedRules.plist` estão ativas; existe um UUID ativo residual sem regra correspondente, sem efeito executável.
- As cinco regras piloto continuam com `ShouldTransfer=false`, `ShouldCopy=false`, `Deletes=false`, sem AppleScript e sem encaminhamento.
- Notificação de regra permanece ativa apenas em Google Cobrança e All Set.
- As Caixas Inteligentes criadas incluem Enviadas e excluem Lixo e Apagadas.
- A interface confirmou novamente: filtro de lixo ativo e conservador, alertas em VIPs, sons secundários desligados e Foco `Work` restrito às duas contas profissionais.
- Falta somente a confirmação específica para `Proteger Atividade no Mail` e a verificação final após esse ajuste.
