#!/bin/zsh
set -euo pipefail

PROJECT_ROOT=${0:A:h:h}
APPLESCRIPT_PATH="$PROJECT_ROOT/mail-morning-audit.applescript"
PLIST_PATH="$PROJECT_ROOT/com.danilonovais.mailaudit.plist"
EXPECTED_SCRIPT_PATH="$PROJECT_ROOT/mail-morning-audit.applescript"
EXPECTED_WORKING_DIRECTORY="$PROJECT_ROOT"

for required_file in "$APPLESCRIPT_PATH" "$PLIST_PATH"; do
  if [[ ! -f "$required_file" ]]; then
    print -u2 "Arquivo obrigatório ausente: $required_file"
    exit 1
  fi
done

TEMP_DIRECTORY=$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/mailaudit-validate.XXXXXX")
trap '/bin/rm -rf "$TEMP_DIRECTORY"' EXIT

/usr/bin/plutil -lint "$PLIST_PATH"
/usr/bin/osacompile -o "$TEMP_DIRECTORY/mail-morning-audit.scpt" "$APPLESCRIPT_PATH"

CONFIGURED_SCRIPT_PATH=$(/usr/libexec/PlistBuddy -c 'Print :ProgramArguments:1' "$PLIST_PATH")
CONFIGURED_WORKING_DIRECTORY=$(/usr/libexec/PlistBuddy -c 'Print :WorkingDirectory' "$PLIST_PATH")

if [[ "$CONFIGURED_SCRIPT_PATH" != "$EXPECTED_SCRIPT_PATH" ]]; then
  print -u2 "ProgramArguments aponta para: $CONFIGURED_SCRIPT_PATH"
  print -u2 "Esperado: $EXPECTED_SCRIPT_PATH"
  exit 1
fi

if [[ "$CONFIGURED_WORKING_DIRECTORY" != "$EXPECTED_WORKING_DIRECTORY" ]]; then
  print -u2 "WorkingDirectory aponta para: $CONFIGURED_WORKING_DIRECTORY"
  print -u2 "Esperado: $EXPECTED_WORKING_DIRECTORY"
  exit 1
fi

if /usr/bin/grep -En '^[[:space:]]*(delete|move|duplicate)[[:space:]]|set[[:space:]]+(read status|junk mail status)|^[[:space:]]*send([[:space:]]|$)' "$APPLESCRIPT_PATH" >/dev/null; then
  print -u2 "Falha de segurança: o AppleScript contém uma operação mutável do Mail."
  exit 1
fi

print "Validação concluída: plist válido, AppleScript compilável e modo somente leitura confirmado."
