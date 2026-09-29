# Otimizador MacTech 4

Aplicativo macOS nativo para diagnostico conservador. A manutencao automatica
coleta apenas metricas de leitura e grava um relatorio privado. Nenhum cache,
backup, log, volume Docker, snapshot ou dado de aplicativo e removido.

## Uso

- Aplicativo oficial: `/Applications/Otimizador MacTech.app`
- Analisar: botao `Analisar` ou `MacTech --analyze`
- Dry-run: botao `Dry Run` ou `MacTech --dry-run`
- Estado do startup: `MacTech --startup-status`

O agente registrado por SMAppService aguarda 120 segundos apos o login e executa
no maximo uma vez por boot. Relatorios ficam em
`~/Library/Application Support/MacTech/Reports` com permissoes privadas.

## Desenvolvimento

```bash
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test
CODE_SIGN_IDENTITY=<identity-hash> bash build.sh
```

Consulte `AUDITORIA.md` para inventario, riscos, matriz de funcionalidades,
performance e evidencia de migracao. Consulte `ROLLBACK.md` antes de restaurar
qualquer bundle legado.
