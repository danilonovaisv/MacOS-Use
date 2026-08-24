#!/bin/bash

# Script de Manutenção para MacBook Pro M1 Max
# macOS 26.1 Beta

echo "═══════════════════════════════════════════════════"
echo "  Script de Manutenção - MacBook Pro M1 Max"
echo "  Serial: V34R7RGX3Y"
echo "═══════════════════════════════════════════════════"
echo ""

# Verificar se está rodando como root para certas operações
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  Algumas operações podem solicitar senha de administrador"
    echo ""
fi

# 1. VERIFICAÇÃO DO SISTEMA
echo "📊 [1/10] Verificando informações do sistema..."
echo "Chip: $(sysctl -n machdep.cpu.brand_string)"
echo "Memória: $(sysctl -n hw.memsize | awk '{print $0/1024/1024/1024 " GB"}')"
echo "macOS: $(sw_vers -productVersion)"
echo ""

# 2. VERIFICAÇÃO DE ATUALIZAÇÕES
echo "🔄 [2/10] Verificando atualizações disponíveis..."
softwareupdate --list
echo ""

# 3. LIMPEZA DE CACHE DO SISTEMA
echo "🧹 [3/10] Limpando caches do sistema..."
sudo rm -rf /Library/Caches/*
rm -rf ~/Library/Caches/*
echo "✓ Caches limpos"
echo ""

# 4. LIMPEZA DE LOGS ANTIGOS
echo "📝 [4/10] Limpando logs antigos (mais de 30 dias)..."
sudo rm -rf /private/var/log/*.log.*
sudo rm -rf /Library/Logs/*.log.*
find ~/Library/Logs -name "*.log" -mtime +30 -delete 2>/dev/null
echo "✓ Logs antigos removidos"
echo ""

# 5. LIMPEZA DE DOWNLOADS ANTIGOS
echo "⬇️ [5/10] Verificando pasta Downloads..."
DOWNLOADS_SIZE=$(du -sh ~/Downloads | awk '{print $1}')
echo "Tamanho atual da pasta Downloads: $DOWNLOADS_SIZE"
echo "💡 Dica: Revise manualmente arquivos antigos em Downloads"
echo ""

# 6. ESVAZIAR LIXEIRA
echo "🗑️ [6/10] Esvaziando lixeira..."
rm -rf ~/.Trash/*
echo "✓ Lixeira esvaziada"
echo ""

# 7. VERIFICAÇÃO DO DISCO
echo "💾 [7/10] Verificando status do disco..."
diskutil info / | grep -E "Volume Name|File System|APFS|Space"
echo ""
echo "Executando verificação de erros (pode demorar)..."
sudo diskutil verifyVolume /
echo ""

# 8. OTIMIZAÇÃO DE BANCO DE DADOS SPOTLIGHT
echo "🔍 [8/10] Reindexando Spotlight..."
echo "⚠️  Esta operação pode demorar. Deseja continuar? (s/n)"
read -r resposta
if [ "$resposta" = "s" ]; then
    sudo mdutil -E /
    echo "✓ Spotlight reindexado (continuará em background)"
else
    echo "⊘ Reindexação do Spotlight pulada"
fi
echo ""

# 9. LIMPEZA DE ARQUIVOS TEMPORÁRIOS
echo "🔧 [9/10] Removendo arquivos temporários..."
sudo rm -rf /private/var/tmp/*
sudo rm -rf /private/tmp/*
rm -rf ~/Library/Application\ Support/CrashReporter/*
echo "✓ Arquivos temporários removidos"
echo ""

# 10. VERIFICAÇÃO DE MALWARE (XProtect)
echo "🛡️ [10/10] Verificando status de segurança..."
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
echo ""

# RELATÓRIO FINAL
echo "═══════════════════════════════════════════════════"
echo "  RELATÓRIO DE MANUTENÇÃO"
echo "═══════════════════════════════════════════════════"

# Uso de disco
echo ""
echo "💾 USO DE DISCO:"
df -h / | awk 'NR==1 {print $0} NR==2 {print $0}'
echo ""

# Uso de memória
echo "🧠 USO DE MEMÓRIA:"
vm_stat | head -n 10
echo ""

# Processos que mais consomem CPU
echo "⚡ TOP 5 PROCESSOS (CPU):"
ps aux | sort -rk 3,3 | head -n 6 | awk '{printf "%-20s %5s%%\n", $11, $3}'
echo ""

# Processos que mais consomem RAM
echo "💭 TOP 5 PROCESSOS (RAM):"
ps aux | sort -rk 4,4 | head -n 6 | awk '{printf "%-20s %5s%%\n", $11, $4}'
echo ""

echo "═══════════════════════════════════════════════════"
echo "✅ MANUTENÇÃO CONCLUÍDA!"
echo "═══════════════════════════════════════════════════"
echo ""
echo "📌 RECOMENDAÇÕES ADICIONAIS:"
echo "  • Reinicie o Mac para aplicar todas as mudanças"
echo "  • Execute este script mensalmente"
echo "  • Mantenha pelo menos 20GB livres no disco"
echo "  • Reporte bugs do Beta via Feedback Assistant"
echo ""

