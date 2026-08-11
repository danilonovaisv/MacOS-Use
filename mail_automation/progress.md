# Progresso

## 2026-08-10

- Instruções das skills `apple-mail`, `macos-setup` e `macos-diagnostics` revisadas.
- Script de auditoria do sistema executado com saída sanitizada.
- macOS 27.0, arquitetura arm64 e Mail 16.0 confirmados.
- Staging e LaunchAgents existentes auditados.
- Falhas de segurança e de compilação registradas.
- Artefatos convertidos para piloto somente leitura.

- Três AppleScripts compilados e instalados em `~/Library/Application Scripts/com.apple.mail/`.
- Launcher instalado com modos `--selected`, `--dry-run` e `--health-check`.
- LaunchAgent `com.user.mailautomation` instalado e carregado para health check a cada 30 minutos.
- Primeira execução concluída com código 0 e registro `HEALTHY` no log.
- Backup pré-instalação criado em `~/Library/Application Support/MailAutomation/Backups/20260810-210356`.

Próximo passo: concluir a configuração visual e iniciar o piloto somente leitura, sem aplicar regras ao histórico.

## 2026-08-10 - configuração visual e piloto

- Backup, scripts instalados e estado saudável do LaunchAgent confirmados.
- Painel de visualização fechado antes de selecionar mensagens.
- Estado inicial de regras, sinalizadores, Caixas Inteligentes, lixo, privacidade e notificações registrado por capturas sanitizadas.
- `PILOTO - Prioridade` criada com `SmartNotifications.scpt`.
- `PILOTO - Unsubscribe` criada com `AntiSpamUnsubscribe.scpt`.
- `PILOTO - Classificação` criada com `TaxonomyAndTagging.scpt` e limitada à conta profissional explicitamente aprovada.
- Regras ordenadas como Prioridade, Unsubscribe e Classificação, sem alterar regras preexistentes.
- Aplicação ao histórico recusada em todas as criações e edições finais.
- Estrutura GTD existente validada sem mudanças desnecessárias.
- Filtro de lixo conservador e notificações para VIPs confirmados.
- Proteção de Atividade no Mail ativada; ocultação do IP preservada.
- VIPs e contas inventariados sem abrir mensagens; nenhuma remoção ou mudança no Foco Trabalho.
- Dry-run final de 5 mensagens concluído nos três scripts.
- Dry-run final de 20 mensagens concluído nos três scripts.
- Estado de leitura e sinalizadores permaneceu inalterado nas duas amostras.
- Nenhuma mensagem foi movida, apagada, arquivada, encaminhada, respondida ou duplicada.
- Nenhuma permissão TCC, senha, Touch ID ou Acesso Total ao Disco foi solicitada.
- Capturas armazenadas fora do Git em `~/Library/Application Support/MailAutomation/Captures/20260810-computer-pilot`; estado final das regras em `13-rules-final.jpg`.

Próximo passo: observar por sete dias, revisar apenas logs sanitizados e manter o Foco Trabalho inalterado até nova aprovação explícita.
