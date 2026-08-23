#!/bin/zsh
# ==============================================================================
# DIAGNÓSTICO COMPLETO DE WI-FI (MACOS / APPLE SILICON)
# Compatível com macOS Monterey, Ventura, Sonoma e Sequoia
# ==============================================================================

set -eo pipefail

REPORT="$HOME/Desktop/wifi_diagnostico_completo_$(date +%Y%m%d_%H%M%S).txt"

# 1. Identificação dinâmica de interface e serviço
WIFI_DEVICE=$(networksetup -listallhardwareports 2>/dev/null | awk '/Hardware Port: (Wi-Fi|AirPort)/{getline; print $2}')
WIFI_DEVICE="${WIFI_DEVICE:-en0}"

WIFI_SERVICE=$(networksetup -listnetworkserviceorder 2>/dev/null | awk -v dev="$WIFI_DEVICE" '
  $0 ~ "Device: " dev { print prev }
  { prev = $0 }
' | head -n 1 | sed -E 's/^\([0-9*]+\) //')
WIFI_SERVICE="${WIFI_SERVICE:-Wi-Fi}"

DEFAULT_GW=$(route -n get default 2>/dev/null | awk '/gateway:/{print $2}')

echo "=== Iniciando Diagnóstico Completo Wi-Fi macOS ==="
echo "Interface : $WIFI_DEVICE"
echo "Serviço   : $WIFI_SERVICE"
echo "Gateway   : ${DEFAULT_GW:-Não detectado}"
echo "Relatório : $REPORT"
echo

{
  echo "=============================================================================="
  echo "                     RELATÓRIO DE DIAGNÓSTICO WI-FI macOS                     "
  echo "=============================================================================="
  echo "Data/Hora       : $(date)"
  echo "Computador      : $(scutil --get ComputerName 2>/dev/null || hostname)"
  echo "Versão macOS    : $(sw_vers -productVersion) (Build $(sw_vers -buildVersion))"
  echo "Interface Wi-Fi : $WIFI_DEVICE"
  echo "Serviço Ativo   : $WIFI_SERVICE"
  echo

  echo "=== 1. STATUS E CONFIGURAÇÃO DA INTERFACE FÍSICA ==="
  ifconfig "$WIFI_DEVICE" 2>&1
  echo

  echo "=== 2. TELEMETRIA DE SINAL E RÁDIO (wdutil / CoreWLAN) ==="
  if command -v wdutil &>/dev/null; then
    sudo wdutil info 2>/dev/null | grep -E "SSID|RSSI|Noise|Tx Rate|Channel|Security|PHY Mode|BSSID|Channel Width|WLAN" || true
  else
    echo "wdutil não disponível. Usando system_profiler:"
    system_profiler SPAirPortDataType 2>/dev/null | grep -E "Current Network Information|Channel|Signal / Noise|Transmit Rate|PHY Mode" || true
  fi
  echo

  echo "=== 3. REDE CONECTADA (SSID) ==="
  networksetup -getairportnetwork "$WIFI_DEVICE" 2>&1
  echo

  echo "=== 4. SERVIDORES DNS CONFIGURADOS ==="
  networksetup -getdnsservers "$WIFI_SERVICE" 2>&1
  echo

  echo "=== 5. TABELA DE ROTEAMENTO (IPv4 / IPv6) ==="
  netstat -rn -f inet
  echo

  echo "=== 6. ENDEREÇAMENTO IP E PACOTE DHCP ==="
  echo "IP Local: $(ipconfig getifaddr "$WIFI_DEVICE" 2>&1)"
  echo "--- Detalhes DHCP ---"
  ipconfig getpacket "$WIFI_DEVICE" 2>&1
  echo

  echo "=== 7. TESTE DE LATÊNCIA: GATEWAY LOCAL (${DEFAULT_GW:-Nenhum}) ==="
  if [[ -n "$DEFAULT_GW" ]]; then
    ping -c 10 -W 1500 "$DEFAULT_GW" 2>&1 || echo "Sem resposta do Gateway."
  else
    echo "Gateway padrão não detectado na rota ativa."
  fi
  echo

  echo "=== 8. TESTE DE LATÊNCIA: DNS CLOUDFLARE (1.1.1.1) ==="
  ping -c 10 -W 1500 1.1.1.1 2>&1 || echo "Sem resposta do DNS Cloudflare."
  echo

  echo "=== 9. TESTE DE LATÊNCIA: APPLE (apple.com) ==="
  ping -c 10 -W 1500 apple.com 2>&1 || echo "Sem resposta de apple.com."
  echo

  echo "=== 10. TESTE DE RESPONSIVIDADE E BUFFERBLOAT (networkQuality) ==="
  if command -v networkQuality &>/dev/null; then
    networkQuality -v 2>&1 || networkQuality 2>&1 || echo "Falha ao executar networkQuality."
  else
    echo "networkQuality não suportado nesta versão do macOS."
  fi
  echo

  echo "=== 11. STATUS AWDL (Apple Wireless Direct Link / AirDrop) ==="
  if ifconfig awdl0 &>/dev/null; then
    ifconfig awdl0 2>&1 | grep -E "flags|status|inet6" || true
  else
    echo "awdl0 não disponível."
  fi
  echo

  echo "=== 12. STATUS DE PROXY ==="
  scutil --proxy 2>&1
  echo

  echo "=== 13. PRIORIDADE DOS SERVIÇOS DE REDE ==="
  networksetup -listnetworkserviceorder 2>&1
  echo

  echo "=============================================================================="
  echo "                             FIM DO RELATÓRIO                                 "
  echo "=============================================================================="
} | tee "$REPORT"

echo
echo "✅ Diagnóstico concluído com sucesso."
echo "Relatório gerado em: $REPORT"
