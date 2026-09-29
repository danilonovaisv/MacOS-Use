#!/bin/zsh
# ==============================================================================
# SCRIPT CONSOLIDADO MACTECH MASTER MAINTENANCE (ARM64 NATIVO)
# Arquitetura Alvo: Apple Silicon (M1/M2/M3/M4/M5 Series)
# Sistemas Homologados: macOS Sequoia & macOS Tahoe
# ==============================================================================

# Injeção explícita de PATH para evitar falhas de escopo no ambiente Automator
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin"

LOG_FILE="$HOME/Desktop/MacTech_Maintenance_Log.txt"
echo "=================================================================" > "$LOG_FILE"
echo " INICIANDO PIPELINE DE MANUTENÇÃO AVANÇADA NO MAC " >> "$LOG_FILE"
echo " Data: $(date) | Arquitetura: $(uname -m)" >> "$LOG_FILE"
echo "=================================================================" >> "$LOG_FILE"

# --- 1. DIAGNÓSTICO TÉRMICO E ENERGIA ---
echo "\n[1/5] Executando Auditoria Térmica e de Bateria..." >> "$LOG_FILE"
echo "-> Pressão Térmica do SoC:" >> "$LOG_FILE"
pmset -g therm | grep -E "Thermal_Level|Speed_Limit" >> "$LOG_FILE" 2>&1
echo "-> Integridade e Ciclos da Bateria:" >> "$LOG_FILE"
ioreg -l | grep -E "MaxCapacity|CurrentCapacity|CycleCount" >> "$LOG_FILE" 2>&1

# --- 2. MANUTENÇÃO SANITIZADA APFS ---
echo "\n[2/5] Otimizando Armazenamento APFS..." >> "$LOG_FILE"
echo "-> Expurgando Snapshots Locais antigos do Time Machine (Liberando Espaço)..." >> "$LOG_FILE"
tmutil thinlocalsnapshots / 5000000000 4 >> "$LOG_FILE" 2>&1
echo "-> Validando consistência lógica da árvore APFS (Live Mode Data Volume)..." >> "$LOG_FILE"
diskutil verifyVolume /System/Volumes/Data >> "$LOG_FILE" 2>&1

# --- 3. REDE, DNS E RESET DE COMPORTAMENTO DE DAEMONS ---
echo "\n[3/5] Corrigindo Barramentos de Subsistemas e Rede..." >> "$LOG_FILE"
echo "-> Limpando cache de DNS lógicos e reiniciando mDNSResponder..." >> "$LOG_FILE"
dscacheutil -flushcache
killall -HUP mDNSResponder
echo "-> Reiniciando serviços de diretório travados (opendirectoryd CPU lock fix)..." >> "$LOG_FILE"
killall opendirectoryd >> "$LOG_FILE" 2>/dev/null

# --- 4. EXPURGO DE CACHES E PURGA DA ARQUITETURA UMA ---
echo "\n[4/5] Higienização de Arquivos Temporários e RAM..." >> "$LOG_FILE"
echo "-> Removendo caches lógicos do Usuário..." >> "$LOG_FILE"
rm -rf ~/Library/Caches/* >> "$LOG_FILE" 2>/dev/null
echo "-> Removendo caches lógicos do Homebrew bootsnap..." >> "$LOG_FILE"
rm -rf "$(brew --cache 2>/dev/null)/bootsnap" ~/Library/Caches/Homebrew/bootsnap 2>/dev/null
echo "-> Forçando purga de páginas inativas de memória na RAM..." >> "$LOG_FILE"
purge

# --- 5. SINCRO DE GERENCIADORES DE PACOTE ---
echo "\n[5/5] Sincronização de Repositórios e Binários..." >> "$LOG_FILE"
if command -v brew &> /dev/null; then
    echo "-> Atualizando fórmulas e pacotes instalados via Homebrew..." >> "$LOG_FILE"
    brew update && brew upgrade && brew cleanup -s >> "$LOG_FILE" 2>&1
else
    echo "-> Gerenciador Homebrew não localizado em /opt/homebrew. Ignorando." >> "$LOG_FILE"
fi

echo "\n=================================================================" >> "$LOG_FILE"
echo " MANUTENÇÃO CONCLUÍDA COM SUCESSO! RELATÓRIO SALVO NA MESA. " >> "$LOG_FILE"
echo "=================================================================" >> "$LOG_FILE"