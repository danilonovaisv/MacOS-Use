#!/bin/zsh
# ==============================================================================
# macOS Wi-Fi Optimization & Diagnostics Tool
# Otimizado para Apple Silicon (M1/M2/M3/M4) & macOS Monterey / Ventura / Sonoma / Sequoia
# ==============================================================================

set -eo pipefail

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m"

echo -e "${BLUE}=== Starting macOS Wi-Fi Optimization ===${NC}"

# 0. Elevação e gerenciamento seguro de sessão sudo
if ! sudo -v; then
  echo -e "${RED}[FAIL] Sudo authentication failed. Exiting.${NC}"
  exit 1
fi

( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &
SUDO_PID=$!
trap 'kill "$SUDO_PID" 2>/dev/null || true' EXIT INT TERM

# 1. Identificação dinâmica de interface física e serviço
WIFI_DEV=$(networksetup -listallhardwareports 2>/dev/null | awk '/Hardware Port: (Wi-Fi|AirPort)/{getline; print $2}')
WIFI_DEV="${WIFI_DEV:-en0}"
echo -e "${BLUE}[INFO] Active Wi-Fi interface: ${WIFI_DEV}${NC}"

# 2. Limpeza de Cache DNS
echo -n "Flushing DNS cache and reloading mDNSResponder... "
if dscacheutil -flushcache && sudo killall -HUP mDNSResponder 2>/dev/null; then
  echo -e "${GREEN}[OK]${NC}"
else
  echo -e "${YELLOW}[WARN] DNS flush had minor issues, continuing...${NC}"
fi

# 3. Soft-cycle do rádio Wi-Fi com timing adequado para Apple Silicon
echo -n "Power cycling Wi-Fi radio (${WIFI_DEV})... "
if networksetup -setairportpower "$WIFI_DEV" off && sleep 2.5 && networksetup -setairportpower "$WIFI_DEV" on; then
  echo -e "${GREEN}[OK]${NC}"
else
  echo -e "${RED}[FAIL] Could not toggle Wi-Fi radio power.${NC}"
fi

# 4. Renovação do DHCP Lease
echo -n "Renewing DHCP lease on ${WIFI_DEV}... "
if sudo ipconfig set "$WIFI_DEV" DHCP; then
  echo -e "${GREEN}[OK]${NC}"
else
  echo -e "${YELLOW}[WARN] DHCP renewal triggered with warnings.${NC}"
fi

# 5. Polling dinâmico para atribuição de IP
echo -n "Waiting for connection and IP assignment... "
CONNECTED=false
for _ in {1..10}; do
  IP_ADDR=$(ipconfig getifaddr "$WIFI_DEV" 2>/dev/null || true)
  if [[ -n "$IP_ADDR" ]]; then
    CONNECTED=true
    break
  fi
  sleep 1
done

if [[ "$CONNECTED" == "true" ]]; then
  echo -e "${GREEN}[OK] (Assigned IP: ${IP_ADDR})${NC}"
else
  echo -e "${YELLOW}[WARN] IP not yet assigned, verifying routing...${NC}"
fi

# 6. Verificação de Conectividade e Latência
echo -e "\n${BLUE}--- Verification & Diagnostics ---${NC}"

CURRENT_SSID=$(networksetup -getairportnetwork "$WIFI_DEV" 2>/dev/null | sed 's/Current Wi-Fi Network: //')
DEFAULT_GW=$(route -n get default 2>/dev/null | awk '/gateway:/{print $2}')

echo "Network (SSID) : ${CURRENT_SSID:-Not connected}"
echo "Local IP       : ${IP_ADDR:-None}"
echo "Gateway Router : ${DEFAULT_GW:-Not detected}"

if [[ -n "$DEFAULT_GW" ]]; then
  echo -n "Testing Local Gateway reachability (${DEFAULT_GW})... "
  if PING_GW=$(ping -c 3 -W 1500 "$DEFAULT_GW" 2>/dev/null); then
    AVG_GW=$(echo "$PING_GW" | tail -n 1 | awk -F '/' '{print $5}')
    echo -e "${GREEN}[OK]${NC} (Avg latency: ${AVG_GW} ms)"
  else
    echo -e "${RED}[FAILED]${NC} No response from gateway router."
  fi
fi

echo -n "Testing Internet reachability (1.1.1.1)... "
if PING_OUTPUT=$(ping -c 3 -W 1500 1.1.1.1 2>/dev/null); then
  AVG_RTT=$(echo "$PING_OUTPUT" | tail -n 1 | awk -F '/' '{print $5}')
  echo -e "${GREEN}[CONNECTED]${NC} (Avg latency: ${AVG_RTT} ms)"
else
  echo -e "${RED}[FAILED]${NC} No route to Internet. Check router credentials or upstream line."
fi

echo -e "\n${GREEN}=== Wi-Fi Optimization Complete ===${NC}"
