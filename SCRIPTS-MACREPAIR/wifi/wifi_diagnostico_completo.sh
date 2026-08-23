#!/bin/zsh

REPORT="$HOME/Desktop/wifi_diagnostico_completo_$(date +%Y%m%d_%H%M%S).txt"
AIRPORT="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
WIFI_DEVICE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2}')
WIFI_SERVICE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{print $3; exit}')

{
echo "=== DIAGNÓSTICO COMPLETO WI-FI macOS ==="
echo "Data: $(date)"
echo "Mac: $(scutil --get ComputerName 2>/dev/null)"
echo "macOS: $(sw_vers -productVersion) build $(sw_vers -buildVersion)"
echo "Interface Wi-Fi: $WIFI_DEVICE"
echo

echo "=== 1. STATUS DA INTERFACE ==="
ifconfig "$WIFI_DEVICE"
echo

echo "=== 2. STATUS WI-FI DETALHADO ==="
if [ -x "$AIRPORT" ]; then
  "$AIRPORT" -I
else
  echo "airport não encontrado em $AIRPORT"
fi
echo

echo "=== 3. REDE ATUAL ==="
networksetup -getairportnetwork "$WIFI_DEVICE" 2>&1
echo

echo "=== 4. DNS CONFIGURADO ==="
networksetup -getdnsservers Wi-Fi 2>&1
echo

echo "=== 5. ROTEAMENTO IPv4/IPv6 ==="
netstat -rn
echo

echo "=== 6. ENDEREÇOS IP ==="
ipconfig getifaddr "$WIFI_DEVICE" 2>&1
ipconfig getpacket "$WIFI_DEVICE" 2>&1
echo

echo "=== 7. TESTE RÁPIDO PARA O ROTEADOR ==="
ping -c 20 192.168.15.1
echo

echo "=== 8. TESTE RÁPIDO PARA DNS CLOUDFLARE ==="
ping -c 20 1.1.1.1
echo

echo "=== 9. TESTE RÁPIDO PARA APPLE ==="
ping -c 20 apple.com
echo

echo "=== 10. TESTE DE LATÊNCIA CONTÍNUA PARA O ROTEADOR ==="
ping -i 0.2 -c 100 192.168.15.1
echo

echo "=== 11. TESTE DE LATÊNCIA CONTÍNUA PARA INTERNET ==="
ping -i 0.2 -c 100 1.1.1.1
echo

echo "=== 12. TRACEROUTE APPLE ==="
traceroute apple.com
echo

echo "=== 13. SCAN DE REDES VIZINHAS ==="
if [ -x "$AIRPORT" ]; then
  "$AIRPORT" -s
else
  echo "airport não disponível"
fi
echo

echo "=== 14. QUALIDADE VIA WDUTIL ==="
sudo wdutil info 2>&1
echo

echo "=== 15. LOGS RECENTES DE WI-FI ==="
log show --last 30m --style compact --predicate 'subsystem == "com.apple.wifi" OR process == "airportd" OR process == "WiFiAgent"' 2>/dev/null | tail -300
echo

echo "=== 16. PROCESSOS DE VPN / TÚNEIS ==="
ifconfig | grep -E "^utun|^ppp|^ipsec|^bridge|^awdl|^llw" -A 3
echo

echo "=== 17. CONFIGURAÇÕES DE PROXY ==="
scutil --proxy
echo

echo "=== 18. SERVIÇOS DE REDE ==="
networksetup -listallnetworkservices
echo

echo "=== 19. ORDEM DOS SERVIÇOS ==="
networksetup -listnetworkserviceorder
echo

echo "=== 20. ECONOMIA DE ENERGIA ==="
pmset -g
echo

echo "=== FIM DO RELATÓRIO ==="
} > "$REPORT"

echo
echo "Relatório criado em:"
echo "$REPORT"
echo
echo "Envie esse arquivo aqui para análise."
