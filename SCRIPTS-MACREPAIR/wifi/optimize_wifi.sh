#!/bin/bash
# ==============================================================================
# macOS Wi-Fi Optimization & Diagnostics Tool
# Optimized for Apple Silicon (M1/M2/M3/M4) & macOS Monterey / Ventura / Sonoma / Sequoia
# ==============================================================================

set -eo pipefail

# ANSI color codes for readable output
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

echo -e "${BLUE}=== Starting macOS Wi-Fi Optimization ===${NC}"

# 0. Elevate privileges upfront
if ! sudo -v; then
    echo -e "${RED}[FAIL] Sudo authentication failed. Exiting.${NC}"
    exit 1
fi

# Keep sudo session alive while the script executes
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_PID=$!
trap 'kill "$SUDO_PID" 2>/dev/null || true' EXIT

# 1. Dynamically identify the Wi-Fi interface name
WIFI_DEV=$(networksetup -listallhardwareports 2>/dev/null | awk '/Hardware Port: Wi-Fi/{getline; print $2}')
WIFI_DEV="${WIFI_DEV:-en0}"
echo -e "${BLUE}[INFO] Active Wi-Fi interface: ${WIFI_DEV}${NC}"

# 2. Clear DNS Cache
# Flushes user-space cache and restarts mDNSResponder to resolve stale/failed domain lookups.
echo -n "Flushing DNS cache and reloading mDNSResponder... "
if dscacheutil -flushcache && sudo killall -HUP mDNSResponder 2>/dev/null; then
    echo -e "${GREEN}[OK]${NC}"
else
    echo -e "${YELLOW}[WARN] DNS flush had issues, continuing...${NC}"
fi

# 3. Soft-cycle the Wi-Fi Radio
# Power-cycling the hardware radio clears stuck states in the Apple Silicon wireless subsystem.
echo -n "Power cycling Wi-Fi radio (${WIFI_DEV})... "
if networksetup -setairportpower "$WIFI_DEV" off && sleep 1 && networksetup -setairportpower "$WIFI_DEV" on; then
    echo -e "${GREEN}[OK]${NC}"
else
    echo -e "${RED}[FAIL] Could not toggle Wi-Fi radio power.${NC}"
fi

# 4. Renew DHCP Lease
# Requests a new IP lease from the router to clear address conflicts.
echo -n "Renewing DHCP lease on ${WIFI_DEV}... "
if sudo ipconfig set "$WIFI_DEV" DHCP; then
    echo -e "${GREEN}[OK]${NC}"
else
    echo -e "${YELLOW}[WARN] DHCP renewal triggered with warnings.${NC}"
fi

# 5. Wait for Network Re-association (Dynamic polling up to 8s)
echo -n "Waiting for connection and IP assignment... "
CONNECTED=false
for _ in {1..8}; do
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
    echo -e "${YELLOW}[WARN] IP not yet assigned, checking connectivity anyway...${NC}"
fi

# 6. Connectivity and Latency Verification
echo -e "\n${BLUE}--- Verification & Diagnostics ---${NC}"

# Fetch current Wi-Fi network name
CURRENT_SSID=$(networksetup -getairportnetwork "$WIFI_DEV" 2>/dev/null | awk -F': ' '{print $2}')
echo "Network (SSID) : ${CURRENT_SSID:-Not connected}"
echo "Local IP       : ${IP_ADDR:-None}"

# Ping test: 3 packets to Cloudflare/Google DNS with a 2-second timeout
echo -n "Testing Internet reachability (1.1.1.1)... "
if PING_OUTPUT=$(ping -c 3 -W 2000 1.1.1.1 2>/dev/null); then
    AVG_RTT=$(echo "$PING_OUTPUT" | tail -n 1 | awk -F '/' '{print $5}')
    echo -e "${GREEN}[CONNECTED]${NC} (Avg latency: ${AVG_RTT} ms)"
else
    echo -e "${RED}[FAILED]${NC} No route to Internet. Check router or password."
fi

echo -e "\n${GREEN}=== Wi-Fi Optimization Complete ===${NC}"
