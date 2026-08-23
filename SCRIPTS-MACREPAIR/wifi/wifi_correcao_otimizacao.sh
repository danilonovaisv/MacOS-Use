#!/bin/zsh

# ==============================================================================
# OTIMIZAÇÃO E CORREÇÃO DE WI-FI (MACOS / APPLE SILICON)
# ==============================================================================

echo "=== Correção e Otimização Wi-Fi macOS ==="
echo "Data: $(date)"
echo

# 1. Identifica a interface física (ex: en0) dinamicamente
WIFI_DEVICE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2}')

if [ -z "$WIFI_DEVICE" ]; then
  echo "Erro: Interface física de Wi-Fi não encontrada."
  exit 1
fi

# 2. Identifica o serviço lógico atrelado ao hardware dinamicamente (ex: "Wi-Fi" ou "Wi-Fi 2")
WIFI_SERVICE=$(networksetup -listnetworkserviceorder | grep -B 1 "Device: $WIFI_DEVICE" | head -n 1 | sed -E 's/^\([0-9\*]+\) //')

if [ -z "$WIFI_SERVICE" ]; then
  echo "Erro: Serviço lógico de rede não encontrado para a interface $WIFI_DEVICE."
  exit 1
fi

REPORT="$HOME/Desktop/wifi_pos_correcao_$(date +%Y%m%d_%H%M%S).txt"

echo "Interface física detectada: $WIFI_DEVICE"
echo "Serviço lógico detectado:  $WIFI_SERVICE"
echo

# 3. Hard Reset da interface (desce e sobe a placa)
echo "[1/4] Reiniciando interface de hardware..."
networksetup -setairportpower "$WIFI_DEVICE" off
sleep 2
networksetup -setairportpower "$WIFI_DEVICE" on
sleep 6 # Tempo de folga para o handshake WPA2/WPA3

# 4. Forçar a renovação do lease DHCP
echo "[2/4] Renovando lease DHCP (IPv4)..."
sudo ipconfig set "$WIFI_DEVICE" DHCP
sleep 3

# 5. Aplicar DNS Cloudflare
echo "[3/4] Aplicando DNS Cloudflare..."
networksetup -setdnsservers "$WIFI_SERVICE" 1.1.1.1 1.0.0.1

# 6. Flush do cache DNS e mDNSResponder
echo "[4/4] Limpando cache DNS e recarregando o mDNSResponder..."
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder 2>/dev/null

echo "Gerando relatório pós-correção em $REPORT..."

# 7. Geração de Relatório
{
  echo "=== RELATÓRIO PÓS-CORREÇÃO WI-FI ==="
  date
  echo
  echo "Interface Física: $WIFI_DEVICE"
  echo "Serviço Lógico:   $WIFI_SERVICE"
  echo
  echo "=== DNS ==="
  networksetup -getdnsservers "$WIFI_SERVICE"
  echo
  echo "=== IP ==="
  ifconfig "$WIFI_DEVICE" | grep -E 'inet |inet6'
  echo
  echo "=== DHCP ==="
  ipconfig getpacket "$WIFI_DEVICE"
  echo
  echo "=== PING ROUTER (Gateway) ==="
  # Pega o IP do gateway atual dinamicamente
  ROUTER_IP=$(route -n get default | awk '/gateway/ {print $2}')
  if [ -n "$ROUTER_IP" ]; then
    ping -c 4 "$ROUTER_IP"
  else
    echo "Nenhum gateway detectado."
  fi
  echo
  echo "=== PING CLOUDFLARE ==="
  ping -c 4 1.1.1.1
} > "$REPORT"

echo "✅ Processo concluído com sucesso."
