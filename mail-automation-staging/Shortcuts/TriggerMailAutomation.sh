#!/usr/bin/env bash

set -euo pipefail

readonly LOG_DIR="${HOME}/Library/Logs"
readonly LOG_FILE="${LOG_DIR}/MailAutomation.log"
readonly SCRIPT_DIR="${HOME}/Library/Application Scripts/com.apple.mail"
readonly MODE="${1:---selected}"

mkdir -p "${LOG_DIR}"
touch "${LOG_FILE}"

log() {
    printf '%s [PILOT-LAUNCHER] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "${LOG_FILE}"
}

health_check() {
    local missing=0
    local script_name
    for script_name in TaxonomyAndTagging.scpt AntiSpamUnsubscribe.scpt SmartNotifications.scpt; do
        if [[ ! -r "${SCRIPT_DIR}/${script_name}" ]]; then
            log "MISSING ${SCRIPT_DIR}/${script_name}"
            missing=1
        fi
    done
    if (( missing == 0 )); then
        log "HEALTHY deployed AppleScripts are readable"
    fi
    return "${missing}"
}

run_selected() {
    local script_name
    for script_name in TaxonomyAndTagging.scpt AntiSpamUnsubscribe.scpt SmartNotifications.scpt; do
        log "START ${script_name}"
        /usr/bin/osascript "${SCRIPT_DIR}/${script_name}" >> "${LOG_FILE}" 2>&1
        log "DONE ${script_name}"
    done
}

case "${MODE}" in
    --health-check)
        health_check
        ;;
    --selected|--dry-run)
        run_selected
        ;;
    *)
        printf 'Usage: %s [--selected|--dry-run|--health-check]\n' "$0" >&2
        exit 64
        ;;
esac
