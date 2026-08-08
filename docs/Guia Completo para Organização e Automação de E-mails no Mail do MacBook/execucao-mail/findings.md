# Constatações e Decisões

Data de referência: 2026-08-07

## Estado inicial conhecido

- Seis contas configuradas no Apple Mail.
- Aproximadamente 18,5 mil mensagens não lidas.
- Doze regras visíveis ativas antes do piloto.
- Filtro nativo de lixo eletrônico desativado.
- Proteger Atividade no Mail desativado; ocultação de IP ativa.
- Cinco Caixas Inteligentes, incluindo projetos antigos.
- Dezenove VIPs, incluindo remetentes promocionais.
- Último backup conhecido do Time Machine: 2026-07-11.

## Regras de risco

- `Notícias da Apple`: interrompe regras sem classificar.
- `CONTAS INCLOUD`: produz cópia ampla e duplicação.
- `PORTFOLIO DANILO`: critérios incompatíveis e script incompleto.
- `Teste Spam` e `Auto-Spam Cleanup`: usam lista antiga e armazenamento local.
- `VIP Senders`: contém endereços de exemplo.
- `Archive br.nestle.com`: move mensagens para armazenamento local.

## Decisões do piloto

- Todas as regras antigas ficarão desativadas durante o piloto.
- As cinco reconstruções usarão somente sinalizador e, quando crítico, notificação nativa.
- Mapeamento proposto: Google Cobrança→Financeiro; LinkedIn→Leitura; QuintoAndar→Aguardando; All Set→Ação hoje; Claro→Financeiro.
- Somente Google Cobrança e All Set receberão notificação de regra nesta fase.
- Nenhum VIP será removido sem aprovação da lista de revisão.
- Nenhuma inscrição será cancelada automaticamente.

## Pendências de confirmação

- Ativar `Proteger Atividade no Mail` imediatamente após confirmação específica.
- Backup externo permanece pendente; o usuário autorizou prosseguir com o snapshot local do Time Machine e o snapshot dos arquivos do Mail.

## Estado implementado em 2026-08-07

- O Mail mostra sete contas no seletor do Foco: iCloud, Google, Yahoo!, duas contas Gmail e duas contas `portfoliodanilo.com`. A execução manual manteve o escopo de seis contas previsto no plano e não incluiu iCloud.
- O Foco `Work` não existia e foi criado; apenas as duas contas `portfoliodanilo.com` ficam visíveis quando o filtro está ativo.
- O filtro nativo de lixo está ativo em modo de observação, sem mover automaticamente mensagens para Lixo.
- Alertas gerais estão restritos a VIPs e os sons de ações secundárias estão desligados.
- As quatro Caixas Inteligentes GTD incluem mensagens enviadas, omitem Lixo e Apagadas e preservam as mensagens no servidor.
- A amostra manual totalizou 259 mensagens recentes. A conta `danilonovais@portfoliodanilo.com` possuía somente 9 mensagens disponíveis na Caixa de Entrada.
- A taxa de falsos positivos e a promoção das regras permanecem deliberadamente pendentes até a revisão de sete dias.
