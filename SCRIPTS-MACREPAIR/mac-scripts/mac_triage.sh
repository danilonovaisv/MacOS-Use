#!/bin/bash

# ==============================================================================
# Script de Correção macOS Tahoe 26.5
# Baseado no PLANO-DE-CORREÇÃO.md
# ==============================================================================

# Função para exibir o menu
mostrar_menu() {
    echo "================================================="
    echo "   Ferramenta de Triagem macOS Tahoe 26.5 beta"
    echo "================================================="
    echo "1) Corrigir Google Keystone (Job missing a label)"
    echo "2) Reiniciar serviços imagent (Messages/iCloud)"
    echo "3) Reiniciar serviços photolibraryd (Photos TCC)"
    echo "4) Limpar caches do Homebrew (logd_helper)"
    echo "5) Gerar diagnóstico de memória (295k swapouts)"
    echo "6) Limpar cache do Gatekeeper (-67018)"
    echo "0) Sair"
    echo "================================================="
    read -p "Escolhe uma opção (0-6): " opcao
}

# Função 1: Corrigir Google Keystone
fix_keystone() {
    echo "A limpar ficheiros legacy do Google Keystone..."
    sudo launchctl bootout system /Library/LaunchAgents/com.google.keystone.agent.plist 2>/dev/null
    sudo launchctl bootout system /Library/LaunchAgents/com.google.keystone.xpcservice.plist 2>/dev/null
    sudo rm -f /Library/LaunchAgents/com.google.keystone.agent.plist
    sudo rm -f /Library/LaunchAgents/com.google.keystone.xpcservice.plist
    rm -f ~/Library/LaunchAgents/com.google.keystone.agent.plist
    rm -f ~/Library/LaunchAgents/com.google.keystone.xpcservice.plist
    echo "Concluído! Ficheiros legacy removidos."
}

# Função 2: Reiniciar imagent
fix_imagent() {
    echo "A fazer soft restart aos serviços de mensagens..."
    killall imagent identityservicesd messagesd 2>/dev/null
    launchctl kickstart -k gui/$(id -u)/com.apple.imagent
    launchctl kickstart -k gui/$(id -u)/com.apple.identityservicesd
    launchctl kickstart -k gui/$(id -u)/com.apple.messagesd
    echo "Serviços reiniciados. Se falhar, desliga/liga o Messages no iCloud nas tuas definições."
}

# Função 3: Reiniciar photolibraryd
fix_photolibraryd() {
    echo "A limpar TCC e a reiniciar daemons do Photos..."
    killall photolibraryd photoanalysisd mediaanalysisd mstreamd cloudphotosd iCloudNotificationAgent assetsd 2>/dev/null
    
    launchctl kickstart -k gui/$(id -u)/com.apple.photolibraryd
    launchctl kickstart -k gui/$(id -u)/com.apple.photoanalysisd
    launchctl kickstart -k gui/$(id -u)/com.apple.mediaanalysisd
    launchctl kickstart -k gui/$(id -u)/com.apple.cloudphotod
    launchctl kickstart -k gui/$(id -u)/com.apple.assetsd
    
    echo "A fazer reset às permissões TCC do Photos..."
    tccutil reset Photos
    echo "Daemons reiniciados! Lembra-te de executar a Reparação (Option+Command ao abrir o Photos) manualmente se o problema persistir."
}

# Função 4: Limpar caches do Homebrew
fix_homebrew() {
    echo "A limpar caches do bootsnap do Homebrew..."
    brew update-reset
    rm -rf "$(brew --cache)/bootsnap" ~/Library/Caches/Homebrew/bootsnap
    rm -rf /opt/homebrew/Library/Homebrew/vendor/portable-ruby/*
    brew update
    echo "Limpeza concluída."
}

# Função 5: Diagnóstico de Memória
diag_memory() {
    echo "A recolher estatísticas de memória..."
    arquivo_diag="$HOME/Desktop/diagnostico_memoria.txt"
    echo "--- Relatório de Memória ---" > "$arquivo_diag"
    date >> "$arquivo_diag"
    echo -e "\n=== Status de Pressão ===" >> "$arquivo_diag"
    memory_pressure >> "$arquivo_diag"
    echo -e "\n=== Processos que mais consomem ===" >> "$arquivo_diag"
    ps -axm -o pid,user,rss,vsz,pmem,command | sort -k3 -rn | head -25 >> "$arquivo_diag"
    echo "Diagnóstico guardado no teu ecrã em: $arquivo_diag"
}

# Função 6: Limpar Cache Gatekeeper
fix_gatekeeper() {
    echo "A fazer reset à cache do Gatekeeper..."
    sudo spctl --reset-default
    echo "Reset concluído."
}

# Loop principal do programa
while true; do
    mostrar_menu
    case $opcao in
        1) fix_keystone ;;
        2) fix_imagent ;;
        3) fix_photolibraryd ;;
        4) fix_homebrew ;;
        5) diag_memory ;;
        6) fix_gatekeeper ;;
        0) echo "A sair. Um abraço do teu Parceiro de Programação!"; exit 0 ;;
        *) echo "Opção inválida, tenta novamente." ;;
    esac
    echo ""
done
