#!/bin/zsh
set -euo pipefail

LABEL="com.danilonovais.mailaudit"
USER_ID=$(/usr/bin/id -u)
SERVICE_TARGET="gui/$USER_ID/$LABEL"
DESTINATION_PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

if /bin/launchctl print "$SERVICE_TARGET" >/dev/null 2>&1; then
  /bin/launchctl bootout "$SERVICE_TARGET"
fi

if [[ -f "$DESTINATION_PLIST" ]]; then
  /bin/rm "$DESTINATION_PLIST"
fi

print "LaunchAgent removido. Código, relatórios e logs foram preservados."
