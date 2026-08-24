#!/bin/zsh
# ==============================================================================
# OTIMIZAÇÃO E CORREÇÃO DE WI-FI (MACOS / APPLE SILICON)
# ==============================================================================

set -eo pipefail

echo "=== Correção e Otimização Wi-Fi macOS ==="
echo "Data: $(date)"
echo

# 1. Identifica a interface física dinamicamente
WIFI_DEVICE=$(networksetup -listallhardwareports 2>/dev/null | awk '/Hardware Port: (Wi-Fi|AirPort)/{getline; print $2}')
WIFI_DEVICE="${WIFI_DEVICE:-en0}"

# 2. Identifica o serviço lógico atrelado ao hardware
WIFI_SERVICE=$(networksetup -listnetworkserviceorder 2>/dev/null | awk -v dev="$WIFI_DEVICE" '
  $0 ~ "Device: " dev { print prev }
  { prev = $0 }
' | head -n 1 | sed -E 's/^\([0-9*]+\) //')
WIFI_SERVICE="${WIFI_SERVICE:-Wi-Fi}"

REPORTS_DIR="${HOME}/Desktop"
REPORT="${REPORTS_DIR}/wifi_pos_correcao_$(date +%Y%m%d_%H%M%S).txt"

echo "Interface física detectada: $WIFI_DEVICE"
echo "Serviço lógico detectado:  $WIFI_SERVICE"
echo

# 3. Ciclo de rádio seguro
echo "[1/4] Reiniciando interface de hardware..."
networksetup -setairportpower "$WIFI_DEVICE" off 2>/dev/null || true
sleep 2.5
networksetup -setairportpower "$WIFI_DEVICE" on 2>/dev/null || true
sleep 4

# 4. Renovação de concessão DHCP
echo "[2/4] Renovando concessão DHCP (IPv4)..."
sudo ipconfig set "$WIFI_DEVICE" DHCP
sleep 2

# 5. Configuração DNS com backup
echo "[3/4] Validando / Aplicando DNS Cloudflare..."
CURRENT_DNS=$(networksetup -getdnsservers "$WIFI_SERVICE" 2>/dev/null || echo "empty")
echo "$CURRENT_DNS" > "/tmp/wifi_dns_backup.txt"
sudo networksetup -setdnsservers "$WIFI_SERVICE" 1.1.1.1 1.0.0.1 2>/dev/null || true

# 6. Flush do cache DNS e recarregamento do mDNSResponder
echo "[4/4] Limpando cache DNS e recarregando o mDNSResponder..."
dscacheutil -flushcache
sudo killall -HUP mDNSResponder 2>/dev/null || true

echo
echo "Gerando relatório pós-correção em $REPORT..."

# 7. Geração de Relatório com saída em tempo real (tee)
{
  echo "=== RELATÓRIO PÓS-CORREÇÃO WI-FI ==="
  date
  echo
  echo "Interface Física : $WIFI_DEVICE"
  echo "Serviço Lógico   : $WIFI_SERVICE"
  echo
  echo "=== DNS ATIVO ==="
  networksetup -getdnsservers "$WIFI_SERVICE" 2>/dev/null || echo "Padrão DHCP"
  echo
  echo "=== ENDEREÇOS IP ==="
  ifconfig "$WIFI_DEVICE" | grep -E 'inet |inet6' || true
  echo
  echo "=== DHCP PACKET INFO ==="
  ipconfig getpacket "$WIFI_DEVICE" 2>/dev/null || echo "Nenhum pacote DHCP capturado"
  echo
  echo "=== PING ROUTER (Gateway Dinâmico) ==="
  ROUTER_IP=$(route -n get default 2>/dev/null | awk '/gateway:/{print $2}')
  if [[ -n "$ROUTER_IP" ]]; then
    echo "Gateway detectado: $ROUTER_IP"
    ping -c 4 -W 1500 "$ROUTER_IP" 2>/dev/null || echo "Sem resposta do gateway."
  else
    echo "Nenhum gateway detectado."
  fi
  echo
  echo "=== PING CLOUDFLARE (1.1.1.1) ==="
  ping -c 4 -W 1500 1.1.1.1 2>/dev/null || echo "Sem conexão com Cloudflare DNS."
} | tee "$REPORT"

echo
echo "✅ Processo concluído com sucesso."
echo "Relatório salvo em: $REPORT"
