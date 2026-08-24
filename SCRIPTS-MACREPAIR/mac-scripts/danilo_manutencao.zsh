#!/bin/zsh

# ==============================================================================
# Danilo's MacBook Pro - Script de Auditoria e Manutenção
# ==============================================================================

# Função para exibir o menu principal
mostrar_menu() {
    echo "\n================================================="
    echo " 💻 Ferramenta de Manutenção: Danilo's MacBook Pro"
    echo "================================================="
    echo "1) 🔍 Auditoria: Resumo de Hardware e Bateria"
    echo "2) 🌡️  Auditoria: Monitorar Temperatura (M1/M2/M3)"
    echo "3) 🧹 Limpeza: Flush de Cache de Rede (DNS)"
    echo "4) 🛠️  Manutenção: Verificar Volume do Disco"
    echo "5) 🍏 Manutenção: Procurar Atualizações do macOS"
    echo "0) 🚪 Sair"
    echo "================================================="
    read "opcao?Escolhe uma opção (0-5): "
}

# 1. Auditoria de Hardware e Bateria
audit_hw_battery() {
    echo "\n[--- Informações de Hardware ---]"
    system_profiler SPHardwareDataType | grep -E "Model Name|Chip|Memory|Serial Number"
    
    echo "\n[--- Informações de Bateria ---]"
    # Obtém o status atual (carregando/descarregando) e a percentagem
    pmset -g batt | grep -v "Now drawing"
    
    # Extrai dados profundos da bateria (Ciclos e Capacidades)
    echo "\nDetalhes Internos da Bateria:"
    ioreg -l | grep -e "CurrentCapacity" -e "MaxCapacity" -e "CycleCount" | tr -d ' ' | sed 's/=/ = /g'
}

# 2. Monitorar Temperatura (Apple Silicon)
audit_temp() {
    echo "\n[--- Monitor de Temperatura ---]"
    echo "A iniciar os sensores SMC (Pressione Ctrl+C para voltar ao menu)..."
    # O powermetrics requer sudo. Vai ler continuamente a temperatura do CPU.
    sudo powermetrics --samplers smc | grep -i "CPU die temperature"
}

# 3. Limpeza de Cache de Rede
clean_network() {
    echo "\n[--- Limpeza de Cache DNS ---]"
    echo "A fazer flush ao cache do Directory Service e a reiniciar o mDNSResponder..."
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
    echo "✅ Cache de rede limpo com sucesso!"
}

# 4. Verificação de Disco
maintain_disk() {
    echo "\n[--- Verificação de Disco Principal ---]"
    echo "A verificar o volume raiz (Isto pode demorar um pouco)..."
    diskutil verifyVolume /
    echo "\n⚠️ Nota do Parceiro: Se a verificação encontrar erros graves que exijam reparação no disco principal (/), deves reiniciar o Mac em Modo de Recuperação (pressionando e segurando o botão de energia ao ligar) e usar o Utilitário de Disco lá."
}

# 5. Atualizações de Sistema
maintain_updates() {
    echo "\n[--- Atualizações do macOS ---]"
    echo "A verificar os servidores da Apple por novas atualizações..."
    softwareupdate -l
}

# Loop do menu interativo
while true; do
    mostrar_menu
    case $opcao in
        1) audit_hw_battery ;;
        2) audit_temp ;;
        3) clean_network ;;
        4) maintain_disk ;;
        5) maintain_updates ;;
        0) echo "\nA sair. Mantém o teu Mac otimizado, Danilo! Um abraço.\n"; exit 0 ;;
        *) echo "\n❌ Opção inválida. Tenta novamente." ;;
    esac
done
