#!/bin/zsh
set -euo pipefail

PROJECT_ROOT=${0:A:h:h}
LABEL="com.danilonovais.mailaudit"
USER_ID=$(/usr/bin/id -u)
DOMAIN="gui/$USER_ID"
SERVICE_TARGET="$DOMAIN/$LABEL"
SOURCE_PLIST="$PROJECT_ROOT/$LABEL.plist"
DESTINATION_DIRECTORY="$HOME/Library/LaunchAgents"
DESTINATION_PLIST="$DESTINATION_DIRECTORY/$LABEL.plist"
LOG_DIRECTORY="$HOME/Library/Logs/MailAudit"

"$PROJECT_ROOT/script/validate.sh"

/bin/mkdir -p "$DESTINATION_DIRECTORY" "$LOG_DIRECTORY"
/usr/bin/install -m 0644 "$SOURCE_PLIST" "$DESTINATION_PLIST"

if /bin/launchctl print "$SERVICE_TARGET" >/dev/null 2>&1; then
  /bin/launchctl bootout "$SERVICE_TARGET"
fi

/bin/launchctl bootstrap "$DOMAIN" "$DESTINATION_PLIST"
/bin/launchctl enable "$SERVICE_TARGET"
/bin/launchctl print "$SERVICE_TARGET" >/dev/null

print "LaunchAgent instalado e carregado: $SERVICE_TARGET"
print "Logs: $LOG_DIRECTORY"
