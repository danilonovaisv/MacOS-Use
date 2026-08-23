#!/usr/bin/env bash
# Mac Doctor — Pro Optimizer for Apple Silicon (M1/M1 Pro/M1 Max/M2/M3)
# Version: 2025-12-04 (Modificado para evitar travamentos)
# Run: sudo bash mac_doctor_m1_pro_optimize.sh
# Este script foi modificado para evitar travamentos em sistemas com muitos arquivos
set -euo pipefail
LOG="/var/log/mac_doctor_optim.log"
START_TS=$(date +"%Y-%m-%d %H:%M:%S")
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

# --- Configurações modificadas para evitar travamentos --------------------------------------------
# Aumentei os limites de tempo para operações lentas
TIMEOUT_DERIVEDDATA=180    # Timeout de 3 minutos para limpeza do DerivedData
TIMEOUT_SPOTLIGHT=600      # Timeout de 10 minutos para reindexação do Spotlight
TIMEOUT_DISKUTIL=300       # Timeout de 5 minutos para verificação de disco

# --- Config toggles (modificadas para maior segurança) --------------------------------------------
CHANGE_DNS="false"         # false por padrão (não altera DNS)
PRUNE_ARCHIVES_DAYS=14     # Mantido em 14 dias
CACHE_MTIME_DAYS=7         # Mantido em 7 dias
RUN_HOMEBREW_MAINT="true"  # Mantido verdadeiro
REINDEX_SPOTLIGHT="false"  # ALTERADO PARA false (causa mais comum de travamento)
SPEED_TWEAKS="true"        # Mantido verdadeiro
RUN_PERIODIC="true"        # Mantido verdadeiro
SAFE_MODE="true"           # NOVO: modo seguro com operações sequenciais

# --- Helpers modificados --------------------------------------------------------------------------
log()   { printf "%b[%s] %s%b\n" "$BLUE" "$(date +'%F %T')" "$1" "$NC" | tee -a "$LOG"; }
warn()  { printf "%b[%s] %s%b\n" "$YELLOW" "$(date +'%F %T')" "$1" "$NC" | tee -a "$LOG"; }
good()  { printf "%b[%s] %s%b\n" "$GREEN" "$(date +'%F %T')" "$1" "$NC" | tee -a "$LOG"; }
bad()   { printf "%b[%s] %s%b\n" "$RED" "$(date +'%F %T')" "$1" "$NC" | tee -a "$LOG"; }

human_gb() {
  df -g "$1" 2>/dev/null | tail -1 | awk '{print $4}' || echo "0"
}

exists() { command -v "$1" >/dev/null 2>&1; }

# NOVO: Função para executar com timeout
run_with_timeout() {
  local timeout=$1
  shift
  local cmd=("$@")
  
  log "Iniciando: ${cmd[*]} (timeout: ${timeout}s)"
  
  # Executar em background
  "${cmd[@]}" &
  local pid=$!
  
  # Aguardar com timeout
  ( sleep "$timeout" && kill -9 "$pid" 2>/dev/null ) &
  local timer_pid=$!
  
  wait "$pid" 2>/dev/null
  local exit_code=$?
  
  # Cancelar o timer se ainda estiver rodando
  kill "$timer_pid" 2>/dev/null || true
  
  if [ "$exit_code" -eq 137 ]; then
    warn "Comando terminado por timeout (${timeout}s): ${cmd[*]}"
    return 1
  fi
  
  return "$exit_code"
}

# --- Preflight ------------------------------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
  bad "Por favor, execute com sudo:  sudo bash $(basename "$0")"
  exit 1
fi

touch "$LOG" && chmod 640 "$LOG"
log "Mac Doctor Pro Optimizer — iniciado em $START_TS"
SW_VER=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
HW_CHIP=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Apple Silicon")
log "Detectado macOS $SW_VER em $HW_CHIP"

# Baseline free space (GiB) on Data volume
BEFORE_FREE_GB=$(human_gb /System/Volumes/Data)
log "Espaço livre antes: ${BEFORE_FREE_GB} GiB"

# --- Section A: DNS flush & network sanity --------------------------------------------------------
log "Limpando caches DNS e atualizando mDNSResponder…"
/usr/bin/dscacheutil -flushcache 2>/dev/null || true
/usr/bin/killall -HUP mDNSResponder 2>/dev/null || true
/usr/bin/killall mDNSResponderHelper 2>/dev/null || true
good "DNS/mDNS atualizado."

if [[ "${CHANGE_DNS}" == "true" ]]; then
  warn "CHANGE_DNS=true → configurando servidores DNS (1.1.1.1, 9.9.9.9, 8.8.8.8) para Wi‑Fi/Ethernet."
  while IFS= read -r svc; do
    [[ -z "$svc" ]] && continue
    [[ "$svc" == "*"* ]] && continue  # skip disabled services
    if [[ "$svc" =~ Wi-?Fi|Ethernet|Thunderbolt ]]; then
      /usr/sbin/networksetup -setdnsservers "$svc" 1.1.1.1 9.9.9.9 8.8.8.8 2>/dev/null || true
      log "DNS configurado em: $svc"
    fi
  done < <(/usr/sbin/networksetup -listallnetworkservices 2>/dev/null | tail -n +2)
fi

# --- Section B: Xcode & Simulator cleanup ---------------------------------------------------------
if [[ -d "$HOME/Library/Developer" ]]; then
  log "Limpeza do Xcode/Simulator…"
  
  if exists xcrun; then
    # Remover simuladores indisponíveis (restos de SDKs antigos)
    log "Removendo simuladores indisponíveis…"
    /usr/bin/xcrun simctl delete unavailable 2>/dev/null || true
    
    # Limpar caches do Simulador (seguro)
    log "Limpando caches do Simulador…"
    rm -rf "$HOME/Library/Developer/CoreSimulator/Caches"/* 2>/dev/null || true
  fi
  
  # DerivedData (intermediários de build) — seguro remover totalmente
  if [[ -d "$HOME/Library/Developer/Xcode/DerivedData" ]]; then
    log "Limpando Xcode DerivedData…"
    
    # NOVO: Usar find com -delete para maior eficiência
    if [[ "${SAFE_MODE}" == "true" ]]; then
      log "Modo seguro ativado: usando método mais lento mas seguro para DerivedData"
      find "$HOME/Library/Developer/Xcode/DerivedData" -mindepth 1 -print -exec rm -rf {} + 2>/dev/null || true
    else
      # Tentar usar timeout para evitar travamento
      run_with_timeout "$TIMEOUT_DERIVEDDATA" \
        find "$HOME/Library/Developer/Xcode/DerivedData" -mindepth 1 -exec rm -rf {} + 2>/dev/null
    fi
  fi
  
  # Archives — manter recentes, remover antigos
  if [[ -d "$HOME/Library/Developer/Xcode/Archives" ]]; then
    log "Removendo Archives do Xcode mais antigos que ${PRUNE_ARCHIVES_DAYS} dias…"
    find "$HOME/Library/Developer/Xcode/Archives" -type d -mtime +$PRUNE_ARCHIVES_DAYS -maxdepth 2 -print -exec rm -rf {} + 2>/dev/null || true
  fi
  
  # DeviceSupport — remover entradas muito antigas do SDK para economizar espaço
  if [[ -d "$HOME/Library/Developer/Xcode/iOS DeviceSupport" ]]; then
    log "Removendo entradas antigas do iOS DeviceSupport (mantendo as 2 mais recentes)…"
    # Listar diretórios ordenados por versão/data, manter duas mais novas
    mapfile -t dsu < <(ls -1dt "$HOME/Library/Developer/Xcode/iOS DeviceSupport"/* 2>/dev/null || true)
    if (( ${#dsu[@]} > 2 )); then
      for ((i=2; i<${#dsu[@]}; i++)); do
        log "Removendo ${dsu[$i]}"
        rm -rf "${dsu[$i]}" 2>/dev/null || true
      done
    fi
  fi
  good "Limpeza do Xcode concluída."
fi

# --- Section C: User/System caches (age-gated) ----------------------------------------------------
log "Limpando caches de usuário mais antigos que ${CACHE_MTIME_DAYS} dias…"
find "$HOME/Library/Caches" -mindepth 1 -mtime +$CACHE_MTIME_DAYS -print -exec rm -rf {} + 2>/dev/null || true

log "Limpando caches do sistema mais antigos que ${CACHE_MTIME_DAYS} dias…"
find /Library/Caches -mindepth 1 -mtime +$CACHE_MTIME_DAYS -print -exec rm -rf {} + 2>/dev/null || true

# QuickLook & LaunchServices databases
log "Resetando cache do Quick Look…"
/usr/bin/qlmanage -r cache 2>/dev/null || true

log "Reconstruindo banco de dados do LaunchServices 'Open With'…"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user 2>/dev/null || true

# --- Section D: Spotlight tuning & reindex --------------------------------------------------------
if exists mdutil; then
  log "Ajustando Spotlight: excluindo caches pesados de desenvolvimento (DerivedData, CoreSimulator)…"
  mdutil -i off "$HOME/Library/Developer/Xcode/DerivedData" 2>/dev/null || true
  mdutil -i off "$HOME/Library/Developer/CoreSimulator" 2>/dev/null || true
  
  if [[ "${REINDEX_SPOTLIGHT}" == "true" ]]; then
    warn "ATENÇÃO: A reindexação do Spotlight pode travar sistemas com muitos arquivos"
    warn "REINDEX_SPOTLIGHT está definido como 'true' - procedendo com reindexação (timeout: ${TIMEOUT_SPOTLIGHT}s)…"
    
    # NOVO: Executar com timeout para evitar travamento
    run_with_timeout "$TIMEOUT_SPOTLIGHT" \
      mdutil -E / 2>/dev/null
    
    mdutil -as 2>/dev/null || true
  else
    log "REINDEX_SPOTLIGHT=false - pulando reindexação completa do Spotlight"
    log "Para reindexar manualmente posteriormente: sudo mdutil -E /"
  fi
fi

# --- Section E: Finder/Dock/UI speed tweaks -------------------------------------------------------
if [[ "${SPEED_TWEAKS}" == "true" ]]; then
  log "Aplicando ajustes de velocidade do Finder/Dock/UI…"
  defaults write -g NSWindowResizeTime -float 0.001 2>/dev/null || true
  defaults write com.apple.dock autohide-time-modifier -float 0.20 2>/dev/null || true
  defaults write com.apple.dock autohide-delay -float 0 2>/dev/null || true
  defaults write com.apple.dock expose-animation-duration -float 0.1 2>/dev/null || true
  defaults write com.apple.finder DisableAllAnimations -bool true 2>/dev/null || true
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE 2>/dev/null || true
  
  killall Dock 2>/dev/null || true
  killall Finder 2>/dev/null || true
  good "Ajustes de UI aplicados."
fi

# --- Section F: Time Machine local snapshots cleanup ---------------------------------------------
if exists tmutil; then
  log "Limpando snapshots locais do Time Machine (se houver)…"
  SNAPLIST=$(tmutil listlocalsnapshots / 2>/dev/null | sed 's/com.apple.TimeMachine.//g' || true)
  if [[ -n "${SNAPLIST}" ]]; then
    while IFS= read -r s; do
      [[ -z "$s" ]] && continue
      tmutil deletelocalsnapshots "$s" 2>/dev/null || true
      log "Snapshot excluído: $s"
    done <<< "$SNAPLIST"
  else
    log "Nenhum snapshot local encontrado."
  fi
fi

# --- Section G: System maintenance scripts --------------------------------------------------------
if [[ "${RUN_PERIODIC}" == "true" ]]; then
  log "Executando scripts de manutenção periódica (diária/semanal/mensal)…"
  periodic daily weekly monthly 2>/dev/null || true
fi

# --- Section H: Homebrew maintenance --------------------------------------------------------------
if [[ "${RUN_HOMEBREW_MAINT}" == "true" ]] && exists brew; then
  log "Manutenção do Homebrew (atualização/limpeza)…"
  brew update 2>/dev/null || true
  brew upgrade 2>/dev/null || true
  brew cleanup -s 2>/dev/null || true
  
  # Limpar cache do Homebrew para recuperar espaço extra
  if brew --cache >/dev/null 2>&1; then
    rm -rf "$(brew --cache)"/* 2>/dev/null || true
  fi
  
  brew autoremove 2>/dev/null || true
fi

# --- Section I: Disk verification ----------------------------------------------------------------
log "Verificando volumes APFS (verificações não destrutivas)…"
if [[ "${SAFE_MODE}" == "true" ]]; then
  log "Modo seguro ativado: usando verificações mais rápidas do diskutil"
  # Verificação mais rápida com timeout
  run_with_timeout "$TIMEOUT_DISKUTIL" \
    diskutil verifyVolume /System/Volumes/Data 2>/dev/null || true
  
  # Volume raiz está selado; verificação pode ser limitada mas inofensiva
  run_with_timeout "$TIMEOUT_DISKUTIL" \
    diskutil verifyVolume / 2>/dev/null || true
else
  diskutil verifyVolume /System/Volumes/Data 2>/dev/null || true
  diskutil verifyVolume / 2>/dev/null || true
fi

# --- Summary --------------------------------------------------------------------------------------
AFTER_FREE_GB=$(human_gb /System/Volumes/Data)
FREED=$(( AFTER_FREE_GB - BEFORE_FREE_GB ))
log "Espaço livre após: ${AFTER_FREE_GB} GiB"
if (( FREED >= 0 )); then
  good "Espaço estimado liberado: ${FREED} GiB (aprox)"
else
  warn "Espaço livre relatado diminuiu em $(( -FREED )) GiB (normal se estiver reindexando Spotlight ou aquecendo caches)."
fi

END_TS=$(date +"%Y-%m-%d %H:%M:%S")
good "Mac Doctor Pro Optimizer concluído em $END_TS"
echo
echo "Log salvo em: $LOG"
echo "Você pode reiniciar para aplicar todos os ajustes de UI."
echo "Sugestão: Execute novamente com REINDEX_SPOTLIGHT=true após alguns dias quando o sistema estiver mais leve."