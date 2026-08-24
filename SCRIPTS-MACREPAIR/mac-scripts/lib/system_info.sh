#!/bin/zsh
# ==============================================================================
# MacTech System Information & Hardware Diagnostics Module
# ==============================================================================

collect_hardware_profile() {
  section "Perfil do Sistema e Hardware"
  local chip arch os_ver computer_name ram_gb
  chip=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Apple Silicon")
  arch=$(uname -m)
  os_ver="$(sw_vers -productVersion) (Build $(sw_vers -buildVersion))"
  computer_name=$(scutil --get ComputerName 2>/dev/null || hostname)
  ram_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($0/1024/1024/1024) " GB"}')

  echo "Computador : $computer_name"
  echo "Usuário    : $USER"
  echo "Chip       : $chip ($arch)"
  echo "Memória    : $ram_gb"
  echo "macOS      : $os_ver"
  echo "Uptime     : $(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')"
}

collect_battery_health() {
  section "Saúde da Bateria (MacBook)"
  if ioreg -r -c AppleSmartBattery &>/dev/null; then
    local cycles max_cap cur_cap state
    cycles=$(ioreg -r -c AppleSmartBattery | awk '/"CycleCount" =/{print $3}')
    max_cap=$(ioreg -r -c AppleSmartBattery | awk '/"MaxCapacity" =/{print $3}')
    cur_cap=$(ioreg -r -c AppleSmartBattery | awk '/"CurrentCapacity" =/{print $3}')
    state=$(pmset -g batt | grep -v "Now drawing" | sed 's/^[ \t]*//')

    echo "Status Atual    : $state"
    echo "Ciclos          : ${cycles:-N/D}"
    echo "Capacidade Max  : ${max_cap:-N/D} mAh"
    echo "Capacidade Atual: ${cur_cap:-N/D} mAh"
  else
    echo "Nenhuma bateria interna detectada (Dispositivo Desktop)."
  fi
}

collect_thermal_pressure() {
  section "Pressão Térmica (Apple Silicon)"
  if command -v powermetrics &>/dev/null; then
    echo -n "Nível Térmico : "
    sudo powermetrics -n 1 --samplers smc 2>/dev/null | grep -i "thermal" | sed 's/^[ \t]*//' || echo "Nominal"
  else
    pmset -g thermlog 2>/dev/null || echo "Sensores não disponíveis."
  fi
}

collect_memory_swap() {
  section "Uso de Memória e Swap"
  if command -v memory_pressure &>/dev/null; then
    memory_pressure -Q 2>/dev/null || memory_pressure 2>/dev/null | head -n 5
  else
    vm_stat | head -n 8
  fi
  echo -n "Swap em Uso   : "
  sysctl vm.swapusage 2>/dev/null | awk '{print $3 " (Total: " $6 ")"}' || echo "N/D"
}

collect_disk_storage() {
  section "Armazenamento APFS"
  df -Hl /System/Volumes/Data 2>/dev/null || df -Hl /
  echo
  diskutil info / 2>/dev/null | grep -E "Volume Name|File System|APFS Container|Volume Free Space" || true
}

collect_top_processes() {
  section "Top 5 Processos por Consumo"
  echo "⚡ Top CPU:"
  ps aux | sort -rk 3,3 | head -n 6 | awk '{printf "  %-25s %6s%% CPU  (PID: %s)\n", $11, $3, $2}'
  echo
  echo "💭 Top Memória RAM:"
  ps aux | sort -rk 4,4 | head -n 6 | awk '{printf "  %-25s %6s%% RAM  (PID: %s)\n", $11, $4, $2}'
}

collect_security_posture() {
  section "Postura de Segurança"
  echo -n "Firewall Global : "
  /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null || echo "N/D"
  echo -n "Modo Stealth    : "
  /usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode 2>/dev/null || echo "N/D"
  echo -n "Gatekeeper      : "
  spctl --status 2>/dev/null || echo "N/D"
  echo -n "SIP (Integridade): "
  csrutil status 2>/dev/null || echo "N/D"
}

run_full_system_audit() {
  banner "MacTech — Auditoria Completa do Sistema"
  collect_hardware_profile
  collect_battery_health
  collect_thermal_pressure
  collect_memory_swap
  collect_disk_storage
  collect_top_processes
  collect_security_posture
  echo -e "\n${GREEN}${BOLD}✔ Auditoria de sistema concluída.${NC}\n"
}
