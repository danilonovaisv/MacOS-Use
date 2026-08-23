#!/bin/bash

# =================================================================
# Script de Otimização MacTech para M1 Max
# Objetivo: Liberar disco, resetar CPU e otimizar Swap
# =================================================================

echo "--- Iniciando Otimização de Ativo (S/N: V34R7RGX3Y) ---"

# 1. Limpeza de Caches do Usuário e Sistema
# Explicação: Caches podem acumular gigabytes. Vamos remover os 
# que não estão em uso imediato.
echo "[1/4] Limpando caches de biblioteca..."
sudo rm -rf ~/Library/Caches/*
sudo rm -rf /Library/Caches/*

# 2. Reset do serviço opendirectoryd e DNS
# Explicação: No seu report, o opendirectoryd estava com 28% de CPU.
# Reiniciá-lo resolve conflitos de indexação de usuários e rede.
echo "[2/4] Reiniciando serviços de diretório e rede..."
sudo killall -HUP mDNSResponder
sudo killall opendirectoryd

# 3. Manutenção do Sistema de Arquivos (Purge)
# Explicação: O comando 'purge' força o macOS a liberar memória 
# inativa e limpar caches de disco da RAM, útil para reduzir o Swap.
echo "[3/4] Forçando purga de memória inativa..."
sudo purge

# 4. Limpeza de Logs Acumulados
# Explicação: Logs de erro podem ocupar espaço precioso em disco.
echo "[4/4] Removendo logs antigos..."
sudo rm -rf /private/var/log/asl/*.asl
sudo rm -rf /Library/Logs/DiagnosticReports/*

echo "--- Otimização Concluída com Sucesso! ---"
echo "Sugestão: Reinicie o MacBook para consolidar a limpeza do Swap."
