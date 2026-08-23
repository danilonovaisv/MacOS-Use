#!/bin/bash
echo "=== DIAGNÓSTICO WiFi MacBook M1 ==="
echo ""

echo "--- Informações da Interface ---"
airport -I | grep -E "(AirPort|agrCtlRSSI|agrCtlNoise|lastTxRate|maxRate|channel|link|SSID|BSSID)"

echo ""
echo "--- Redes Disponíveis (Top 10 por sinal) ---"
airport -s | head -15

echo ""
echo "--- Teste de Performance ---"
networkQuality -v

echo ""
echo "--- DNS Atual ---"
networksetup -getdnsservers Wi-Fi

echo ""
echo "--- Tabela ARP (dispositivos na rede local) ---"
arp -a
