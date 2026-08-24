# Comandos e acoes suportadas

## Somente leitura

- Hardware e OS: `system_profiler`, `sysctl`, `sw_vers`, `uname`, `uptime`.
- Recursos: `top -l 1`, `vm_stat`, `ps`, `df`.
- Inicializacao: `sfltool dumpbtm`, `launchctl print-disabled`, leitura de LaunchAgents.
- Rede: `scutil`, `networksetup -getdnsservers`, `dscacheutil -q host`, `ping` com limite.
- Atualizacoes: `softwareupdate -l`, `mas outdated` e `brew outdated` somente quando ja instalados.
- Seguranca: `fdesetup status`, `socketfilterfw --getglobalstate`, `spctl --status`, `profiles status -type enrollment`.
- Armazenamento: metadados de caches/logs e candidatos grandes; Downloads, Lixeira e duplicatas apenas como recomendacao sanitizada.

## Automaticas opt-in

- `dscacheutil -flushcache`; o sinal HUP a `mDNSResponder` pode exigir administrador e deve ser solicitado separadamente se necessario.
- Remocao apenas de temporarios criados pelo proprio plugin e expirados.
- Consulta e registro sanitizado no NotebookLM quando a integracao estiver habilitada.

## Confirmacao obrigatoria

Qualquer exclusao fora do diretorio proprio, `mo clean`, limpeza de Downloads/Lixeira, remocao de apps ou login items, mudanca de permissao/perfil/rede/seguranca, instalacao, atualizacao aplicada, upgrade, reboot, `sudo`, `defaults write` ou script avancado.

## Agendamento

O LaunchAgent e preferido ao cron no macOS. `StartCalendarInterval` executa diariamente as 10:00 no horario local; `EnvironmentVariables.TZ` fixa `America/Sao_Paulo` para timestamps e logica interna. O instalador verifica o timezone do sistema e alerta se ele divergir.
