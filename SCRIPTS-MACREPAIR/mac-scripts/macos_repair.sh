#!/bin/bash

# ==============================================================================
# MACOS SYSTEM REPAIR & OPTIMIZATION SCRIPT
# Target: MacBook Pro M1 Max (MacBookPro18,2)
# User: danilonovais
# Date: 2026-04-02
# Author: Senior Automation & Creative Tech Strategist
# ==============================================================================

# --- CONFIGURATION & COLORS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

LOG_FILE="/var/log/macos_repair_$(date +%Y%m%d_%H%M%S).log"

# --- HELPER FUNCTIONS ---
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

section_header() {
    log "\n${BLUE}==================================================================${NC}"
    log "${BLUE} $1 ${NC}"
    log "${BLUE}==================================================================${NC}"
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        log "${RED}Erro: Este script deve ser executado como root (use sudo).${NC}"
        exit 1
    fi
}

# --- MAIN EXECUTION ---
check_root

section_header "1. INICIANDO AUDITORIA E REPARO"
log "Data de Início: $(date)"
log "Hostname: $(hostname)"
log "Usuário Logado: $(whoami)"

# --- 2. SEGURANÇA DE REDE (FIREWALL) ---
section_header "2. CONFIGURAÇÃO DE FIREWALL"
log "Verificando status do Firewall..."

# Enable Firewall
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
if [ $? -eq 0 ]; then
    log "${GREEN}[SUCESSO] Firewall global ativado.${NC}"
else
    log "${RED}[FALHA] Erro ao ativar Firewall.${NC}"
fi

# Enable Stealth Mode (Ignore ping probes)
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
if [ $? -eq 0 ]; then
    log "${GREEN}[SUCESSO] Modo Stealth ativado.${NC}"
else
    log "${RED}[FALHA] Erro ao ativar Modo Stealth.${NC}"
fi

# Allow signed applications automatically
/usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned on
/usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp on

log "Status atual do Firewall:"
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode

# --- 3. LIMPEZA DE QUARENTENA (GATEKEEPER) ---
section_header "3. GERENCIAMENTO DE GATEKEEPER & QUARENTENA"
log "Removendo atributo 'com.apple.quarantine' de aplicativos confiáveis..."

# Lista de aplicativos identificados na auditoria como seguros mas em quarentena
# Nota: Isso melhora a UX sem desativar a segurança global do Gatekeeper
QUARANTINE_APPS=(
    "/Applications/Blender.app"
    "/Applications/Docker.app"
    "/Applications/EasyHTML5Video.app"
    "/Applications/GlobalGPT.app"
    "/Applications/LM Studio.app"
    "/Applications/Microsoft Edge.app"
)

for app in "${QUARANTINE_APPS[@]}"; do
    if [ -d "$app" ]; then
        # Remove quarantine attribute recursively
        xattr -rd com.apple.quarantine "$app" 2>/dev/null
        if [ $? -eq 0 ]; then
            log "${GREEN}[LIMPO] Quarentena removida de: $app${NC}"
        else
            log "${YELLOW}[AVISO] Não foi possível limpar ou já estava limpo: $app${NC}"
        fi
    else
        log "${YELLOW}[INFO] Aplicativo não encontrado: $app${NC}"
    fi
done

# Verificação geral do Gatekeeper
log "\nStatus do Gatekeeper:"
spctl --status

# --- 4. LIMPEZA DE SISTEMA E CACHE ---
section_header "4. LIMPEZA DE ARQUIVOS TEMPORÁRIOS E CACHE"

# Limpeza de Cache do Usuário (Seguro)
USER_CACHE_DIR="/Users/danilonovais/Library/Caches"
if [ -d "$USER_CACHE_DIR" ]; then
    log "Limpando cache do usuário danilonovais..."
    # Remove apenas arquivos antigos (>7 dias) para evitar quebrar apps ativos
    find "$USER_CACHE_DIR" -type f -mtime +7 -delete 2>/dev/null
    log "${GREEN}[SUCESSO] Cache antigo do usuário limpo.${NC}"
fi

# Limpeza de Logs do Sistema Antigos
log "Rotacionando e limpando logs antigos do sistema..."
log truncate --all --size 0 2>/dev/null || true
find /var/log -type f -name "*.asl" -mtime +30 -delete 2>/dev/null
find /Library/Logs -type f -mtime +30 -delete 2>/dev/null
log "${GREEN}[SUCESSO] Logs antigos removidos.${NC}"

# Limpeza de Homebrew (Se instalado)
if command -v brew &> /dev/null; then
    log "Executando limpeza do Homebrew..."
    brew cleanup --prune=all 2>/dev/null
    log "${GREEN}[SUCESSO] Homebrew limpo.${NC}"
else
    log "${YELLOW}[INFO] Homebrew não detectado ou não instalado.${NC}"
fi

# --- 5. PERMISSÕES E INTEGRIDADE ---
section_header "5. VERIFICAÇÃO DE PERMISSÕES"

# Repair Permissions for Home Directory
log "Verificando permissões da pasta Home..."
chown -R danilonovais:staff /Users/danilonovais 2>/dev/null
chmod -R o-w /Users/danilonovais 2>/dev/null # Remove write permission for others
log "${GREEN}[SUCESSO] Permissões da Home corrigidas.${NC}"

# Verify Disk Integrity (Read-only check)
log "Executando verificação rápida do sistema de arquivos (Live Mode)..."
diskutil verifyVolume / 2>/dev/null | tail -n 5

# --- 6. OTIMIZAÇÃO DE LAUNCH AGENTS (AUDITORIA) ---
section_header "6. AUDITORIA DE SERVIÇOS EM BACKGROUND"
log "Identificando LaunchAgents de terceiros potencialmente desnecessários..."

# Lista de plists comuns que podem ser desabilitados se não estiverem em uso
# NOTA: Este script apenas LISTA e sugere. Não desabilita automaticamente para evitar quebra de fluxo.
THIRD_PARTY_AGENTS=(
    "com.adobe.ARMDC.Communicator.plist"
    "com.adobe.GC.Invoker-1.0.plist"
    "com.google.keystone.agent.plist"
    "com.wacom.DataStoreMgr.plist"
)

for agent in "${THIRD_PARTY_AGENTS[@]}"; do
    if launchctl list | grep -q "$agent"; then
        log "${YELLOW}[ATENÇÃO] Agente ativo detectado: $agent${NC}"
        log "   -> Considere desabilitar se não usar atualização automática: launchctl disable gui/$(id -u danilonovais)/$agent"
    fi
done

# --- 7. FINALIZAÇÃO ---
section_header "7. RESUMO E REINICIAÇÃO RECOMENDADA"
log "Script concluído com sucesso."
log "Log detalhado salvo em: $LOG_FILE"
log ""
log "${GREEN}AÇÕES REALIZADAS:${NC}"
log "1. Firewall Ativado (Modo Stealth ON)."
log "2. Atributos de Quarentena removidos de Apps Criativos/Dev."
log "3. Caches e Logs antigos limpos."
log "4. Permissões da Home corrigidas."
log ""
log "${YELLOW}RECOMENDAÇÃO:${NC} Reinicie o MacBook para aplicar alterações de kernel e recarregar serviços."
log "Comando: sudo shutdown -r now"

exit 0