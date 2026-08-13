# MacBook Daily Care

Plugin pessoal do Codex para auditoria diaria, diagnostico e manutencao preventiva segura de MacBooks Apple Silicon.

## Uso

- Auditoria manual: `python3 scripts/daily_audit.py --mode audit`
- Instalar agenda diaria: `bash scripts/install_schedule.sh`
- Remover agenda: `bash scripts/uninstall_schedule.sh`

O agendamento nao e instalado automaticamente pelo scaffold. A instalacao altera o estado do `launchd` e deve ser solicitada conscientemente.

## Exemplos

### Execucao bem-sucedida

O coletor valida macOS, registra um snapshot sanitizado, gera as 12 secoes do relatorio e retorna os caminhos. Nenhum arquivo pessoal e alterado.

### Execucao com erro

Se `softwareupdate` expirar ou uma verificacao exigir permissao, o erro e registrado como verificacao incompleta, o relatorio continua e nenhuma manutencao sensivel e iniciada. Se o NotebookLM estiver sem autenticacao, o historico local permanece funcional e o relatorio recomenda autenticar novamente.

## Testes

O plano cobre: validacao do manifest, redacao de dados privados, presenca das 12 secoes, lint do plist, dry-run/auditoria em macOS, falhas de comandos, timeout, NotebookLM indisponivel, aprovacao expirada, rollback do LaunchAgent e garantia de que comandos proibidos nao aparecem em caminhos automaticos.
