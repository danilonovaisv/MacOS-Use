#!/bin/bash

# ==============================================================================
# Script de Otimização e Correção para macOS (MacBook Pro M1 Max)
# ==============================================================================

echo "Iniciando a manutenção do sistema..."

# Passo 1: Limpeza de Snapshots Locais (Recuperação de espaço em disco)
# O comando tmutil thinlocalsnapshots tenta excluir snapshots locais do Time Machine.
# Os números indicam a quantidade de bytes a recuperar e o nível de urgência (4 é o máximo).
echo "Liberando espaço em disco (apagando APFS Snapshots)..."
sudo tmutil thinlocalsnapshots / 10000000000 4

# Passo 2: Limpeza de Caches do Sistema
# Limpa os caches da biblioteca do sistema, o que pode corrigir processos travados.
echo "Limpando caches do sistema..."
sudo rm -rf /Library/Caches/*
sudo rm -rf /System/Library/Caches/*

# Passo 3: Limpeza de Memória Inativa
# Força o sistema a liberar memória RAM que não está sendo ativamente usada.
echo "Purgando memória inativa..."
sudo purge

# Passo 4: Reinicialização do Serviço de DNS
# O comando killall -HUP envia um sinal para reiniciar o serviço mDNSResponder,
# limpando o cache de DNS e melhorando problemas de conexão de rede.
echo "Renovando cache de DNS e rede..."
sudo killall -HUP mDNSResponder

# Passo 5: Verificação do Disco pós-limpeza
# Mostra o espaço em disco atualizado no formato legível (Human-readable -h).
echo "Manutenção concluída! Veja como está o espaço do seu disco agora:"
df -h /

echo "Recomendação: Se o Docker estiver lento, reinicie-o manualmente através do aplicativo."
