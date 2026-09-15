# Rollback do Otimizador MacTech 4.0.0

Backup validado: `/Users/danilonovais/MacTech-Rollback/2026-09-15-pre-v4`.

O rollback deve ser feito com os aplicativos fechados:

1. Desregistrar o agente moderno:
   `/Applications/Otimizador MacTech.app/Contents/MacOS/MacTech --disable-startup`
2. Mover `/Applications/Otimizador MacTech.app` para a Lixeira pelo Finder.
3. Restaurar o bundle desejado da pasta `quarantine/` para a pasta pessoal.
4. Para restaurar o comportamento anterior, abra Ajustes do Sistema > Geral >
   Itens de Inicio, clique em `+` e selecione `macos_maintenance.app`.
5. Conferir o hash contra `evidence/backup-files.sha256` e executar primeiro
   somente em um ambiente descartavel. Os fluxos legados sao destrutivos.

O estado e os relatorios da v4 ficam em
`~/Library/Application Support/MacTech`. Eles nao precisam ser apagados para
restaurar o app anterior e podem servir de evidencia da migracao.

Nao reative as duas versoes ao mesmo tempo.
