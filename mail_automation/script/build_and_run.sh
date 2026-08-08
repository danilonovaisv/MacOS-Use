#!/bin/zsh
set -euo pipefail

PROJECT_ROOT=${0:A:h:h}
LABEL="com.danilonovais.mailaudit"
USER_ID=$(/usr/bin/id -u)
SERVICE_TARGET="gui/$USER_ID/$LABEL"
LOG_DIRECTORY="$HOME/Library/Logs/MailAudit"
STDOUT_LOG="$LOG_DIRECTORY/mailaudit.log"
STDERR_LOG="$LOG_DIRECTORY/mailaudit-error.log"

show_usage() {
  print "Uso: ./script/build_and_run.sh [opção]"
  print ""
  print "Sem opção       Valida e executa a auditoria no Terminal"
  print "--verify        Valida código, configuração e estado instalado"
  print "--install       Instala e carrega o LaunchAgent"
  print "--run-agent     Dispara o LaunchAgent já instalado"
  print "--logs          Exibe os logs recentes"
  print "--uninstall     Descarrega e remove o plist instalado"
  print "--help          Exibe esta ajuda"
}

verify_installation() {
  "$PROJECT_ROOT/script/validate.sh"

  if /bin/launchctl print "$SERVICE_TARGET" >/dev/null 2>&1; then
    print "Estado instalado: carregado ($SERVICE_TARGET)."
  else
    print "Estado instalado: ainda não carregado."
  fi
}

show_logs() {
  if [[ -f "$STDOUT_LOG" ]]; then
    print "== Saída =="
    /usr/bin/tail -n 100 "$STDOUT_LOG"
  else
    print "Log de saída ainda não existe: $STDOUT_LOG"
  fi

  if [[ -f "$STDERR_LOG" ]]; then
    print "== Erros =="
    /usr/bin/tail -n 100 "$STDERR_LOG"
  else
    print "Log de erros ainda não existe: $STDERR_LOG"
  fi
}

case "${1:-}" in
  "")
    "$PROJECT_ROOT/script/validate.sh"
    exec /usr/bin/osascript "$PROJECT_ROOT/mail-morning-audit.applescript"
    ;;
  --verify)
    verify_installation
    ;;
  --install)
    "$PROJECT_ROOT/script/install_launch_agent.sh"
    ;;
  --run-agent)
    if ! /bin/launchctl print "$SERVICE_TARGET" >/dev/null 2>&1; then
      print -u2 "LaunchAgent não está carregado. Execute --install primeiro."
      exit 1
    fi
    /bin/launchctl kickstart -k "$SERVICE_TARGET"
    print "LaunchAgent iniciado: $SERVICE_TARGET"
    ;;
  --logs)
    show_logs
    ;;
  --uninstall)
    "$PROJECT_ROOT/script/uninstall_launch_agent.sh"
    ;;
  --help|-h)
    show_usage
    ;;
  *)
    print -u2 "Opção desconhecida: $1"
    show_usage
    exit 2
    ;;
esac
