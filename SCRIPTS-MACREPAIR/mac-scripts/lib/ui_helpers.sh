#!/bin/zsh
# ==============================================================================
# MacTech UI Helpers & Core Runtime Utilities
# ==============================================================================

# Cores ANSI
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
MAGENTA="\033[0;35m"
BOLD="\033[1m"
NC="\033[0m"

log_info()    { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_success() { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
log_warn()    { printf "${YELLOW}[AVISO]${NC} %s\n" "$1"; }
log_error()   { printf "${RED}[ERRO]${NC} %s\n" "$1"; }

banner() {
  local title="$1"
  echo -e "\n${BOLD}${BLUE}======================================================================${NC}"
  echo -e "${BOLD}${CYAN}  $title ${NC}"
  echo -e "${BOLD}${BLUE}======================================================================${NC}\n"
}

section() {
  local title="$1"
  echo -e "\n${BOLD}${MAGENTA}--- $title ---${NC}"
}

elevate_privileges() {
  if ! sudo -v 2>/dev/null; then
    echo -e "${YELLOW}[!] Autenticação de administrador necessária.${NC}"
    if ! sudo -v; then
      log_error "Falha na autenticação sudo. Abortando."
      exit 1
    fi
  fi
  # Keep sudo alive in background
  ( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &
  SUDO_PID=$!
  trap 'kill "$SUDO_PID" 2>/dev/null || true' EXIT INT TERM
}

run_with_timeout() {
  local timeout="$1"
  shift
  local cmd=("$@")
  
  "${cmd[@]}" &
  local pid=$!
  
  ( sleep "$timeout" && kill -9 "$pid" 2>/dev/null ) &
  local timer_pid=$!
  
  wait "$pid" 2>/dev/null
  local exit_code=$?
  
  kill "$timer_pid" 2>/dev/null || true
  return "$exit_code"
}
