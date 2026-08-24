#!/bin/zsh
# ==============================================================================
# macOS Wi-Fi Cache Cleanup & Quick Refresh
# Compatível com Apple Silicon (M1-M4) & macOS Monterey até Sequoia
# ==============================================================================

set -eo pipefail

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

echo -e "${BLUE}=== Iniciando Limpeza de Cache e Otimização Wi-Fi ===${NC}"

# 1. Identifica a interface Wi-Fi dinamicamente
WIFI_DEV=$(networksetup -listallhardwareports 2>/dev/null | awk '/Hardware Port: (Wi-Fi|AirPort)/{getline; print $2}')
WIFI_DEV="${WIFI_DEV:-en0}"
echo -e "${BLUE}[INFO] Interface detectada: ${WIFI_DEV}${NC}"

# 2. Limpeza de Cache DNS e recarregamento do mDNSResponder
echo -n "Limpando cache DNS (dscacheutil + mDNSResponder)... "
if dscacheutil -flushcache && sudo killall -HUP mDNSResponder 2>/dev/null; then
  echo -e "${GREEN}[OK]${NC}"
else
  echo -e "${YELLOW}[AVISO: Falha ao reiniciar mDNSResponder]${NC}"
fi

# 3. Soft-cycle na interface Wi-Fi com timing seguro para Apple Silicon
echo -n "Reinicializando rádio Wi-Fi (${WIFI_DEV})... "
if networksetup -setairportpower "$WIFI_DEV" off && sleep 2.5 && networksetup -setairportpower "$WIFI_DEV" on; then
  echo -e "${GREEN}[OK]${NC}"
else
  echo -e "${YELLOW}[AVISO: Não foi possível alternar energia]${NC}"
fi

# 4. Renovação de concessão DHCP
echo -n "Renovando concessão DHCP... "
sudo ipconfig set "$WIFI_DEV" DHCP
sleep 2
echo -e "${GREEN}[OK]${NC}"

# 5. Verificação de Conectividade
echo -e "\n${BLUE}--- Status da Conexão ---${NC}"
IP_ADDR=$(ipconfig getifaddr "$WIFI_DEV" 2>/dev/null || echo "Aguardando IP...")
echo "Endereço IP Local : $IP_ADDR"

echo -n "Testando conectividade de internet (1.1.1.1)... "
if ping -c 3 -W 1500 1.1.1.1 &>/dev/null; then
  echo -e "${GREEN}[CONECTADO]${NC}"
else
  echo -e "${YELLOW}[AVISO: Sem resposta externa imediata]${NC}"
fi

echo -e "${GREEN}=== Limpeza e otimização concluídas ===${NC}"
