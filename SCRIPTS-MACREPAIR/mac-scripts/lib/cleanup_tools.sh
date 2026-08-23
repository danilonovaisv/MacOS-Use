#!/bin/zsh
# ==============================================================================
# MacTech Safe Cleanup & Storage Optimization Module
# ==============================================================================

clean_user_caches_safe() {
  local days="${1:-7}"
  section "Limpeza Segura de Caches do Usuário (> ${days} dias)"
  
  if [[ -d "$HOME/Library/Caches" ]]; then
    echo "• Removendo arquivos de cache antigos (preservando navegadores e sessões ativas)..."
    find "$HOME/Library/Caches" -mindepth 1 -type f -mtime +"$days" \
      ! -path "*/com.apple.Safari/*" \
      ! -path "*/com.apple.WebKit/*" \
      ! -path "*/com.google.Chrome/*" \
      ! -path "*/com.microsoft.VSCode/*" \
      ! -path "*/com.docker.docker/*" \
      -delete 2>/dev/null || true
    log_success "Caches obsoletos do usuário higienizados."
  fi
}

clean_xcode_developer_safe() {
  section "Limpeza Profunda do Ambiente Xcode / Developer"
  
  if [[ -d "$HOME/Library/Developer" ]]; then
    # 1. DerivedData
    if [[ -d "$HOME/Library/Developer/Xcode/DerivedData" ]]; then
      echo -n "• Limpando Xcode DerivedData... "
      rm -rf "$HOME/Library/Developer/Xcode/DerivedData"/* 2>/dev/null || true
      log_success "Concluído."
    fi
    
    # 2. Simuladores indisponíveis e caches do simulador
    if command -v xcrun &>/dev/null; then
      echo -n "• Excluindo simuladores indisponíveis... "
      xcrun simctl delete unavailable 2>/dev/null || true
      rm -rf "$HOME/Library/Developer/CoreSimulator/Caches"/* 2>/dev/null || true
      log_success "Concluído."
    fi
    
    # 3. Archives antigos (> 14 dias)
    if [[ -d "$HOME/Library/Developer/Xcode/Archives" ]]; then
      echo -n "• Limpando Archives antigos (> 14 dias)... "
      find "$HOME/Library/Developer/Xcode/Archives" -type d -mtime +14 -maxdepth 2 -exec rm -rf {} + 2>/dev/null || true
      log_success "Concluído."
    fi

    # 4. iOS DeviceSupport antigo (mantém as 2 versões mais recentes)
    if [[ -d "$HOME/Library/Developer/Xcode/iOS DeviceSupport" ]]; then
      echo -n "• Otimizando iOS DeviceSupport... "
      local dsu=($(ls -1dt "$HOME/Library/Developer/Xcode/iOS DeviceSupport"/* 2>/dev/null || true))
      if (( ${#dsu[@]} > 2 )); then
        for ((i=3; i<=${#dsu[@]}; i++)); do
          rm -rf "${dsu[$i]}" 2>/dev/null || true
        done
      fi
      log_success "Concluído."
    fi
  else
    echo "Ambiente Xcode não detectado. Pulando."
  fi
}

clean_timemachine_snapshots() {
  section "Purga de Snapshots Locais do Time Machine (APFS)"
  if command -v tmutil &>/dev/null; then
    local snapshots
    snapshots=$(tmutil listlocalsnapshots / 2>/dev/null | sed 's/com.apple.TimeMachine.//g' | grep -E '^[0-9-]+' || true)
    if [[ -n "$snapshots" ]]; then
      echo "• Excluindo snapshots locais órfãos..."
      while IFS= read -r snap; do
        [[ -z "$snap" ]] && continue
        sudo tmutil deletelocalsnapshots "$snap" 2>/dev/null || true
        echo "  - Snapshot excluído: $snap"
      done <<< "$snapshots"
      log_success "Snapshots limpos."
    else
      echo "Nenhum snapshot local pendente de exclusão."
    fi
  fi
}

clean_logs_and_crashreports() {
  section "Higienização de Logs e Relatórios de Falha (> 30 dias)"
  echo "• Removendo logs antigos do usuário e sistema..."
  find "$HOME/Library/Logs" -type f -name "*.log" -mtime +30 -delete 2>/dev/null || true
  find "$HOME/Library/Logs" -type f -name "*.crash" -mtime +14 -delete 2>/dev/null || true
  sudo rm -rf /Library/Logs/DiagnosticReports/* 2>/dev/null || true
  rm -rf "$HOME/Library/Application Support/CrashReporter"/* 2>/dev/null || true
  log_success "Logs e CrashReports obsoletos removidos."
}

clean_homebrew_cache() {
  section "Limpeza e Otimização do Homebrew"
  if command -v brew &>/dev/null; then
    echo "• Executando brew cleanup e autoremove..."
    brew cleanup -s 2>/dev/null || true
    brew autoremove 2>/dev/null || true
    local brew_cache
    brew_cache=$(brew --cache 2>/dev/null || echo "")
    if [[ -n "$brew_cache" && -d "$brew_cache" ]]; then
      rm -rf "$brew_cache"/* 2>/dev/null || true
    fi
    log_success "Homebrew otimizado."
  else
    echo "Homebrew não instalado. Pulando."
  fi
}

clean_network_dns_directory() {
  section "Flush de Cache DNS e Directory Services"
  echo -n "• Limpando caches de rede... "
  sudo dscacheutil -flushcache 2>/dev/null || true
  sudo killall -HUP mDNSResponder 2>/dev/null || true
  log_success "DNS e Directory Services renovados."
}

purge_inactive_memory() {
  section "Purga de Memória Inativa (RAM Flush)"
  echo -n "• Forçando purga de memória inativa e buffers de disco... "
  sudo purge 2>/dev/null || true
  log_success "Memória liberada."
}

empty_trash_safe() {
  section "Esvaziamento Seguro da Lixeira"
  if [[ -d "$HOME/.Trash" ]]; then
    local trash_items
    trash_items=$(ls -A "$HOME/.Trash" 2>/dev/null || true)
    if [[ -n "$trash_items" ]]; then
      rm -rf "$HOME/.Trash"/* 2>/dev/null || true
      log_success "Lixeira esvaziada."
    else
      echo "Lixeira já está vazia."
    fi
  fi
}

run_full_system_optimization() {
  banner "MacTech — Otimização e Limpeza de Armazenamento"
  elevate_privileges
  
  local before_gb after_gb
  before_gb=$(df -g /System/Volumes/Data 2>/dev/null | tail -1 | awk '{print $4}' || echo 0)
  echo "Espaço livre inicial: ${before_gb} GiB"

  clean_user_caches_safe 7
  clean_xcode_developer_safe
  clean_timemachine_snapshots
  clean_logs_and_crashreports
  clean_homebrew_cache
  clean_network_dns_directory
  purge_inactive_memory
  empty_trash_safe

  after_gb=$(df -g /System/Volumes/Data 2>/dev/null | tail -1 | awk '{print $4}' || echo 0)
  local freed=$(( after_gb - before_gb ))
  echo
  log_success "Espaço livre final: ${after_gb} GiB (Recuperado aprox: ${freed} GiB)"
  echo -e "\n${GREEN}${BOLD}✔ Otimização e limpeza concluídas.${NC}\n"
}
