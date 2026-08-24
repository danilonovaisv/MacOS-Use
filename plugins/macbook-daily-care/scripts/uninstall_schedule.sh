#!/usr/bin/env bash
set -euo pipefail
label="com.danilonovais.macbook-daily-care"
agent_path="$HOME/Library/LaunchAgents/${label}.plist"
launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
if [[ -f "$agent_path" ]]; then
  mv "$agent_path" "$HOME/.Trash/${label}.plist.$(date +%Y%m%d%H%M%S)"
fi
echo "Agendamento removido. Historico e relatorios foram preservados."
