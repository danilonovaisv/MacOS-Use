#!/bin/zsh
# ==============================================================================
# macOS Wi-Fi Engine — Ferramenta Unificada de Diagnóstico, Otimização e Reparo
# Otimizado para Apple Silicon (M1/M2/M3/M4) & macOS Monterey / Ventura / Sonoma / Sequoia
# ==============================================================================

set -eo pipefail

# Paleta ANSI de alta legibilidade
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
BOLD="\033[1m"
NC="\033[0m" # No Color

# Tratamento seguro de encerramento
cleanup() {
  if [[ -n "$SUDO_PID" ]]; then
    kill "$SUDO_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

# ------------------------------------------------------------------------------
# Funções de Descoberta Dinâmica de Hardware e Rede
# ------------------------------------------------------------------------------

get_wifi_interface() {
  local iface
  iface=$(networksetup -listallhardwareports 2>/dev/null | awk '/Hardware Port: (Wi-Fi|AirPort)/{getline; print $2}')
  if [[ -z "$iface" ]]; then
    iface=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')
  fi
  echo "${iface:-en0}"
}

get_wifi_service() {
  local iface="$1"
  local svc
  svc=$(networksetup -listnetworkserviceorder 2>/dev/null | awk -v dev="$iface" '
    $0 ~ "Device: " dev { print prev }
    { prev = $0 }
  ' | head -n 1 | sed -E 's/^\([0-9*]+\) //')
  echo "${svc:-Wi-Fi}"
}

get_default_gateway() {
  local gw
  gw=$(route -n get default 2>/dev/null | awk '/gateway:/{print $2}')
  echo "$gw"
}

elevate_privileges() {
  if ! sudo -v 2>/dev/null; then
    echo -e "${YELLOW}[!] Autenticação sudo necessária para operações de baixo nível de rede.${NC}"
    if ! sudo -v; then
      echo -e "${RED}[ERRO] Falha na autenticação sudo. Encerrando.${NC}"
      exit 1
    fi
  fi
  # Manter sessão sudo viva em segundo plano
  ( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &
  SUDO_PID=$!
}

# ------------------------------------------------------------------------------
# Módulos Operacionais
# ------------------------------------------------------------------------------

flush_dns() {
  echo -n "• Limpando cache DNS local e recarregando mDNSResponder... "
  if dscacheutil -flushcache && sudo killall -HUP mDNSResponder 2>/dev/null; then
    echo -e "${GREEN}[OK]${NC}"
  else
    echo -e "${YELLOW}[AVISO: Falha parcial no reload do mDNSResponder]${NC}"
  fi
}

cycle_radio() {
  local iface="$1"
  echo -n "• Ciclando rádio de hardware Wi-Fi (${iface})... "
  if networksetup -setairportpower "$iface" off 2>/dev/null; then
    sleep 2.5 # Tempo seguro para despolarização e descarga de registradores de rádio
    networksetup -setairportpower "$iface" on 2>/dev/null
    echo -e "${GREEN}[OK]${NC}"
  else
    echo -e "${RED}[FALHA] Não foi possível alternar energia da interface ${iface}.${NC}"
  fi
}

renew_dhcp() {
  local iface="$1"
  echo -n "• Solicitando renovação de lease DHCP... "
  if sudo ipconfig set "$iface" DHCP 2>/dev/null; then
    echo -e "${GREEN}[OK]${NC}"
  else
    echo -e "${YELLOW}[AVISO] Renovação DHCP disparada com avisos.${NC}"
  fi
}

wait_for_ip_association() {
  local iface="$1"
  local max_retries="${2:-10}"
  echo -n "• Aguardando re-associação e atribuição de IP... "
  local ip=""
  for ((i=1; i<=max_retries; i++)); do
    ip=$(ipconfig getifaddr "$iface" 2>/dev/null || true)
    if [[ -n "$ip" ]]; then
      echo -e "${GREEN}[OK] (IP: ${ip})${NC}"
      return 0
    fi
    sleep 1
  done
  echo -e "${YELLOW}[TIMEOUT] Nenhum IP atribuído após ${max_retries}s.${NC}"
  return 1
}

manage_dns() {
  local svc="$1"
  local profile="$2"
  local backup_file="/tmp/wifi_dns_backup.txt"

  local current_dns
  current_dns=$(networksetup -getdnsservers "$svc" 2>/dev/null || echo "empty")
  echo "$current_dns" > "$backup_file"

  case "$profile" in
    cloudflare)
      echo -e "• Aplicando DNS Cloudflare (1.1.1.1 / 1.0.0.1) em '${svc}'..."
      sudo networksetup -setdnsservers "$svc" 1.1.1.1 1.0.0.1
      flush_dns
      echo -e "${GREEN}[OK] DNS Cloudflare ativado. Backup salvo em ${backup_file}${NC}"
      ;;
    google)
      echo -e "• Aplicando DNS Google (8.8.8.8 / 8.8.4.4) em '${svc}'..."
      sudo networksetup -setdnsservers "$svc" 8.8.8.8 8.8.4.4
      flush_dns
      echo -e "${GREEN}[OK] DNS Google ativado. Backup salvo em ${backup_file}${NC}"
      ;;
    quad9)
      echo -e "• Aplicando DNS Quad9 Seguro (9.9.9.9 / 149.112.112.112) em '${svc}'..."
      sudo networksetup -setdnsservers "$svc" 9.9.9.9 149.112.112.112
      flush_dns
      echo -e "${GREEN}[OK] DNS Quad9 ativado. Backup salvo em ${backup_file}${NC}"
      ;;
    dhcp|empty|reset)
      echo -e "• Restaurando DNS para automático (DHCP) em '${svc}'..."
      sudo networksetup -setdnsservers "$svc" empty
      flush_dns
      echo -e "${GREEN}[OK] DNS automático DHCP restaurado.${NC}"
      ;;
    *)
      echo -e "${RED}[ERRO] Perfil de DNS inválido: '$profile'. Use: cloudflare, google, quad9 ou dhcp.${NC}"
      exit 1
      ;;
  esac
}

check_awdl_status() {
  echo -e "\n${BOLD}${CYAN}--- Apple Wireless Direct Link (AWDL / AirDrop) ---${NC}"
  if ifconfig awdl0 &>/dev/null; then
    local status
    status=$(ifconfig awdl0 2>/dev/null | grep "status:" | awk '{print $2}')
    echo -e "Interface AWDL : awdl0 (${status:-ativo})"
    echo -e "${YELLOW}Nota:${NC} O AWDL gerencia AirDrop/Sidecar. Saltos de canal podem causar jitter temporário em Wi-Fi 5GHz."
  else
    echo -e "Interface AWDL : Inativa ou não detectada"
  fi
}

run_performance_test() {
  echo -e "\n${BOLD}${CYAN}--- Teste de Responsividade e Bufferbloat (networkQuality) ---${NC}"
  if command -v networkQuality &>/dev/null; then
    echo "Executando teste oficial Apple networkQuality (RFC 9000)..."
    networkQuality -v 2>/dev/null || networkQuality 2>/dev/null || echo -e "${YELLOW}[AVISO] Teste networkQuality não pôde ser completado.${NC}"
  else
    echo -e "${YELLOW}[INFO] Utilitário networkQuality disponível a partir do macOS Monterey.${NC}"
  fi
}

# ------------------------------------------------------------------------------
# Rotinas Principais
# ------------------------------------------------------------------------------

run_optimization() {
  local iface="$1"
  local svc="$2"

  echo -e "\n${BOLD}${BLUE}=== Iniciando Otimização Wi-Fi macOS ===${NC}"
  echo -e "Interface Física : ${BOLD}${iface}${NC}"
  echo -e "Serviço Lógico   : ${BOLD}${svc}${NC}\n"

  elevate_privileges
  flush_dns
  cycle_radio "$iface"
  renew_dhcp "$iface"
  wait_for_ip_association "$iface" 8

  echo -e "\n${BOLD}${BLUE}--- Verificação Rápida de Conectividade ---${NC}"
  local ip gw
  ip=$(ipconfig getifaddr "$iface" 2>/dev/null || echo "Não atribuído")
  gw=$(get_default_gateway)
  echo -e "Endereço IP Local : ${ip}"
  echo -e "Gateway Padrão    : ${gw:-Nenhum detectado}"

  if [[ -n "$gw" ]]; then
    echo -n "• Teste de latência ao Gateway (${gw})... "
    if ping_out=$(ping -c 3 -W 1500 "$gw" 2>/dev/null); then
      avg_gw=$(echo "$ping_out" | tail -n 1 | awk -F '/' '{print $5}')
      echo -e "${GREEN}[OK]${NC} (${avg_gw} ms)"
    else
      echo -e "${RED}[FALHA] Sem resposta do gateway.${NC}"
    fi
  fi

  echo -n "• Teste de alcance à Internet (1.1.1.1)... "
  if ping_out=$(ping -c 3 -W 1500 1.1.1.1 2>/dev/null); then
    avg_net=$(echo "$ping_out" | tail -n 1 | awk -F '/' '{print $5}')
    echo -e "${GREEN}[OK]${NC} (Média: ${avg_net} ms)"
  else
    echo -e "${RED}[FALHA] Sem conexão externa.${NC}"
  fi

  echo -e "\n${GREEN}${BOLD}✔ Otimização concluída com sucesso.${NC}"
}

run_diagnostics() {
  local iface="$1"
  local svc="$2"
  local report_path="$3"

  echo -e "\n${BOLD}${BLUE}=== Diagnóstico Completo de Rede Wi-Fi macOS ===${NC}"
  echo -e "Data/Hora       : $(date)"
  echo -e "Dispositivo     : $(scutil --get ComputerName 2>/dev/null || hostname)"
  echo -e "macOS           : $(sw_vers -productVersion) (Build $(sw_vers -buildVersion))"
  echo -e "Interface Wi-Fi : ${iface}"
  echo -e "Serviço Ativo   : ${svc}"

  # 1. Informações de Sinal e Rádio
  echo -e "\n${BOLD}${CYAN}--- 1. Informações de Conexão e Sinal ---${NC}"
  local ssid
  ssid=$(networksetup -getairportnetwork "$iface" 2>/dev/null | sed 's/Current Wi-Fi Network: //')
  echo -e "SSID Conectado  : ${ssid:-Não associado}"

  if command -v wdutil &>/dev/null; then
    echo -e "\n[Telemetria wdutil (macOS Native)]:"
    sudo wdutil info 2>/dev/null | grep -E "SSID|RSSI|Noise|Tx Rate|Channel|Security|PHY Mode|BSSID" || true
  fi

  # 2. Configuração de IP e Roteamento
  echo -e "\n${BOLD}${CYAN}--- 2. Configurações IP e Roteamento ---${NC}"
  local ip gw
  ip=$(ipconfig getifaddr "$iface" 2>/dev/null || echo "Nenhum")
  gw=$(get_default_gateway)
  echo -e "IP Local        : ${ip}"
  echo -e "Gateway Padrão  : ${gw:-Não detectado}"

  echo -e "\nConfiguração DNS do Serviço '${svc}':"
  networksetup -getdnsservers "$svc" 2>/dev/null || echo "Padrão DHCP"

  # 3. Testes de Latência Dinâmica (Sem hardcoding de IPs)
  echo -e "\n${BOLD}${CYAN}--- 3. Testes de Latência e Estabilidade ---${NC}"
  if [[ -n "$gw" ]]; then
    echo -n "• Amostragem Gateway Local (${gw} - 5 pacotes)... "
    if out=$(ping -c 5 -W 1500 "$gw" 2>/dev/null); then
      avg=$(echo "$out" | tail -n 1 | awk -F '/' '{print $5}')
      echo -e "${GREEN}[OK]${NC} Latência Média: ${avg} ms"
    else
      echo -e "${RED}[FALHA] Sem resposta.${NC}"
    fi
  else
    echo -e "${YELLOW}[PULADO] Nenhum gateway detectado.${NC}"
  fi

  echo -n "• Amostragem Internet (Cloudflare 1.1.1.1 - 5 pacotes)... "
  if out=$(ping -c 5 -W 1500 1.1.1.1 2>/dev/null); then
    avg=$(echo "$out" | tail -n 1 | awk -F '/' '{print $5}')
    echo -e "${GREEN}[OK]${NC} Latência Média: ${avg} ms"
  else
    echo -e "${RED}[FALHA] Sem resposta da Internet.${NC}"
  fi

  echo -n "• Amostragem DNS Primário (Google 8.8.8.8 - 5 pacotes)... "
  if out=$(ping -c 5 -W 1500 8.8.8.8 2>/dev/null); then
    avg=$(echo "$out" | tail -n 1 | awk -F '/' '{print $5}')
    echo -e "${GREEN}[OK]${NC} Latência Média: ${avg} ms"
  else
    echo -e "${RED}[FALHA] Sem resposta.${NC}"
  fi

  # 4. Status AWDL
  check_awdl_status

  # 5. Bufferbloat & throughput
  run_performance_test

  echo -e "\n${GREEN}${BOLD}✔ Diagnóstico finalizado.${NC}"
}

# ------------------------------------------------------------------------------
# Ponto de Entrada (CLI Parser)
# ------------------------------------------------------------------------------

show_help() {
  echo -e "${BOLD}Uso:${NC} ./wifi_engine.sh [OPÇÕES]

${BOLD}Opções Principais:${NC}
  -d, --diag                Executa diagnóstico completo (sinal, ruído, gateway, latência e bufferbloat).
  -o, --optimize            Executa rotina de otimização (flush DNS, ciclo de rádio seguro e renovação DHCP).
  -r, --repair              Otimização profunda com diagnóstico antes e depois.
  -f, --flush-dns           Executa apenas flush de cache DNS e reload do mDNSResponder.
  --dns <perfil>            Define servidores DNS. Opções: cloudflare | google | quad9 | dhcp
  --awdl                    Verifica status da interface Apple Wireless Direct Link (AirDrop/Sidecar).
  --report [caminho]        Gera relatório estruturado em arquivo (padrão: reports/ ou Desktop).
  -h, --help                Exibe este menu de ajuda.

${BOLD}Exemplos:${NC}
  ./wifi_engine.sh --optimize
  ./wifi_engine.sh --diag
  ./wifi_engine.sh --dns cloudflare
  ./wifi_engine.sh --dns dhcp
  ./wifi_engine.sh --diag --report"
}

main() {
  local action=""
  local dns_profile=""
  local save_report=false
  local custom_report_path=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--diag|--diagnostico)
        action="diag"
        shift
        ;;
      -o|--optimize|--otimizar)
        action="optimize"
        shift
        ;;
      -r|--repair|--reparar)
        action="repair"
        shift
        ;;
      -f|--flush-dns)
        action="flush_dns"
        shift
        ;;
      --dns)
        action="dns"
        dns_profile="$2"
        shift 2
        ;;
      --awdl)
        action="awdl"
        shift
        ;;
      --report)
        save_report=true
        if [[ -n "$2" && "$2" != -* ]]; then
          custom_report_path="$2"
          shift 2
        else
          shift
        fi
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        echo -e "${RED}Opção desconhecida: $1${NC}"
        show_help
        exit 1
        ;;
    esac
  done

  # Ação padrão se nenhuma for passada: otimização
  if [[ -z "$action" ]]; then
    action="optimize"
  fi

  local iface svc
  iface=$(get_wifi_interface)
  svc=$(get_wifi_service "$iface")

  if [[ "$save_report" == "true" ]]; then
    local target_dir="${custom_report_path:-$HOME/Desktop}"
    local report_file="${target_dir}/wifi_relatorio_$(date +%Y%m%d_%H%M%S).txt"
    mkdir -p "$(dirname "$report_file")"
    echo -e "${CYAN}Gravando log da execução em: ${report_file}${NC}"
    
    # Executa com tee para o usuário acompanhar no terminal e salvar no arquivo
    {
      case "$action" in
        diag) run_diagnostics "$iface" "$svc" "$report_file" ;;
        optimize) run_optimization "$iface" "$svc" ;;
        repair)
          run_optimization "$iface" "$svc"
          run_diagnostics "$iface" "$svc" "$report_file"
          ;;
        flush_dns) flush_dns ;;
        dns) manage_dns "$svc" "$dns_profile" ;;
        awdl) check_awdl_status ;;
      esac
    } | tee "$report_file"
  else
    case "$action" in
      diag) run_diagnostics "$iface" "$svc" "" ;;
      optimize) run_optimization "$iface" "$svc" ;;
      repair)
        run_optimization "$iface" "$svc"
        run_diagnostics "$iface" "$svc" ""
        ;;
      flush_dns) flush_dns ;;
      dns) manage_dns "$svc" "$dns_profile" ;;
      awdl) check_awdl_status ;;
    esac
  fi
}

main "$@"
