#!/usr/bin/env bash
set -euo pipefail

label="com.danilonovais.macbook-daily-care"
plugin_root="$(cd "$(dirname "$0")/.." && pwd)"
agent_path="$HOME/Library/LaunchAgents/${label}.plist"
log_dir="$HOME/Library/Logs/MacBookDailyCare"

mkdir -p "$(dirname "$agent_path")" "$log_dir"
system_tz="$(readlink /etc/localtime 2>/dev/null | sed 's#^.*/zoneinfo/##' || true)"
if [[ "$system_tz" != "America/Sao_Paulo" ]]; then
  echo "Aviso: timezone do sistema e '${system_tz:-desconhecido}'. A rotina exige America/Sao_Paulo."
fi

tmp_plist="$(mktemp)"
trap 'rm -f "$tmp_plist"' EXIT
sed -e "s|__PYTHON__|$(command -v python3)|g" \
    -e "s|__SCRIPT__|$plugin_root/scripts/daily_audit.py|g" \
    -e "s|__LOG_DIR__|$log_dir|g" \
    "$plugin_root/assets/com.danilonovais.macbook-daily-care.plist.template" > "$tmp_plist"
plutil -lint "$tmp_plist"
cp "$tmp_plist" "$agent_path"
launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$agent_path"
echo "Agendamento instalado: diariamente as 10:00 (America/Sao_Paulo)."
