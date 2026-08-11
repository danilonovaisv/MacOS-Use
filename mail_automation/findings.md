# Constatações da implantação

- O staging original movia mensagens para caixas locais e criava caixas automaticamente.
- O detector de unsubscribe lia o corpo completo e movia mensagens, contrariando o protocolo de revisão.
- A taxonomia original processava toda a Caixa de Entrada não lida quando não havia seleção.
- O plist original era XML inválido porque o placeholder `<YOUR_USERNAME>` não estava escapado.
- O AppleScript de taxonomia original não compilava.
- O launcher original executaria os três scripts em sequência a cada disparo.
- Já existe o LaunchAgent `com.danilonovais.mailaudit`, diário às 08:00 e com última saída zero.
- O piloto corrigido usa somente metadados, exige seleção no modo manual e não altera mensagens.
- O agendamento de 30 minutos foi limitado a uma verificação de integridade dos arquivos instalados.
- O backup pré-instalação foi criado em `~/Library/Application Support/MailAutomation/Backups/20260810-210356`.
- Os scripts foram instalados em formato compilado `.scpt`; o LaunchAgent concluiu a primeira execução com código 0.
- O validador preexistente de `mail_automation` espera o antigo AppleScript, mas o plist atual executa `ai_mail_summarizer.py`; essa automação paralela não foi modificada.
