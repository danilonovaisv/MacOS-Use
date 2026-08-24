# Criar diretório do relatório no Desktop
REPORT_DIR="$HOME/Desktop/SystemAudit_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$REPORT_DIR"

# Arquivo principal do relatório
REPORT="$REPORT_DIR/Auditoria_Sistema_Completa.txt"

echo "========================================" > "$REPORT"
echo "  AUDITORIA DO SISTEMA macOS" >> "$REPORT"
echo "  Data: $(date)" >> "$REPORT"
echo "  Usuário: $(whoami)" >> "$REPORT"
echo "  Hostname: $(hostname)" >> "$REPORT"
echo "========================================" >> "$REPORT"
echo "" >> "$REPORT"

# 1. INFORMAÇÕES DO SISTEMA
echo "📋 1. INFORMAÇÕES DO SISTEMA" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
system_profiler SPHardwareDataType >> "$REPORT"
echo "" >> "$REPORT"
sw_vers >> "$REPORT"
echo "" >> "$REPORT"

# 2. ESTADO DO DISCO
echo "💾 2. ESTADO DO DISCO E ARMAZENAMENTO" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
df -h >> "$REPORT"
echo "" >> "$REPORT"
diskutil list >> "$REPORT"
echo "" >> "$REPORT"
diskutil apfs list >> "$REPORT" 2>/dev/null
echo "" >> "$REPORT"

# 3. VERIFICAÇÃO DE PERMISSÕES DO DISCO
echo "🔐 3. VERIFICAÇÃO DE PERMISSÕES E INTEGRIDADE" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
echo "Verificando permissões do disco (pode levar alguns minutos)..." >> "$REPORT"
diskutil verifyVolume / >> "$REPORT" 2>&1
echo "" >> "$REPORT"

# 4. PERMISSÕES DE PASTAS CRÍTICAS
echo "📁 4. PERMISSÕES DE DIRETÓRIOS DO SISTEMA" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
ls -laO@ /System/Library/ >> "$REPORT" 2>/dev/null | head -20 >> "$REPORT"
echo "" >> "$REPORT"
ls -la /Users/ >> "$REPORT"
echo "" >> "$REPORT"

# 5. USUÁRIOS E GRUPOS
echo "👥 5. USUÁRIOS E GRUPOS" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
dscl . list /Users >> "$REPORT"
echo "" >> "$REPORT"
dscl . list /Groups >> "$REPORT"
echo "" >> "$REPORT"
echo "Usuários com privilégios de admin:" >> "$REPORT"
dscl . read /Groups/admin GroupMembership >> "$REPORT"
echo "" >> "$REPORT"

# 6. PROCESSOS E RECURSOS
echo "⚙️ 6. PROCESSOS E USO DE RECURSOS" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
top -l 1 -n 10 >> "$REPORT"
echo "" >> "$REPORT"
vm_stat >> "$REPORT"
echo "" >> "$REPORT"

# 7. SERVIÇOS EM EXECUÇÃO (LaunchAgents/Daemons)
echo "🚀 7. SERVIÇOS E AGENTES DO SISTEMA" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
echo "LaunchDaemons do Sistema:" >> "$REPORT"
ls -la /Library/LaunchDaemons/ >> "$REPORT"
echo "" >> "$REPORT"
echo "LaunchAgents do Sistema:" >> "$REPORT"
ls -la /Library/LaunchAgents/ >> "$REPORT"
echo "" >> "$REPORT"
echo "LaunchAgents do Usuário:" >> "$REPORT"
ls -la ~/Library/LaunchAgents/ >> "$REPORT" 2>/dev/null
echo "" >> "$REPORT"

# 8. CONFIGURAÇÕES DE REDE
echo "🌐 8. CONFIGURAÇÕES DE REDE" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
ifconfig >> "$REPORT"
echo "" >> "$REPORT"
netstat -rn >> "$REPORT"
echo "" >> "$REPORT"
scutil --dns >> "$REPORT"
echo "" >> "$REPORT"

# 9. FIREWALL E SEGURANÇA
echo "🛡️ 9. CONFIGURAÇÕES DE SEGURANÇA" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate >> "$REPORT" 2>&1
echo "" >> "$REPORT"
spctl --status >> "$REPORT"
echo "" >> "$REPORT"
csrutil status >> "$REPORT"
echo "" >> "$REPORT"

# 10. GATEKEEPER E PERMISSÕES DE APP
echo "🔒 10. GATEKEEPER E QUARENTENA" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
spctl --assess --type exec /System/Applications/Safari.app >> "$REPORT" 2>&1
echo "" >> "$REPORT"
xattr -l /Applications/* 2>/dev/null | grep -A2 "com.apple.quarantine" >> "$REPORT"
echo "" >> "$REPORT"

# 11. LOGS DE ERRO RECENTES
echo "📜 11. LOGS DE ERRO RECENTES (últimas 24h)" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
log show --predicate 'eventType == logEvent AND messageType == error' --last 24h --style compact >> "$REPORT" 2>&1 | head -50 >> "$REPORT"
echo "" >> "$REPORT"

# 12. ERROS DO SISTEMA (system.log)
echo "⚠️ 12. ERROS DO SYSTEM.LOG" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
log show --predicate 'messageType == error' --last 1h --style compact >> "$REPORT" 2>&1 | tail -30 >> "$REPORT"
echo "" >> "$REPORT"

# 13. EXTENSÕES DO KERNEL (KEXTs)
echo "🔌 13. EXTENSÕES DO KERNEL" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
kextstat >> "$REPORT"
echo "" >> "$REPORT"

# 14. APLICATIVOS INSTALADOS
echo "📦 14. APLICATIVOS INSTALADOS" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
ls -1 /Applications/ >> "$REPORT"
echo "" >> "$REPORT"
ls -1 ~/Applications/ >> "$REPORT" 2>/dev/null
echo "" >> "$REPORT"

# 15. ATUALIZAÇÕES PENDENTES
echo "🔄 15. ATUALIZAÇÕES DE SOFTWARE" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
softwareupdate --list >> "$REPORT" 2>&1
echo "" >> "$REPORT"

# 16. CONFIGURAÇÕES DE ENERGIA
echo "🔋 16. CONFIGURAÇÕES DE ENERGIA" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
pmset -g >> "$REPORT"
echo "" >> "$REPORT"

# 17. DISPOSITIVOS USB E BLUETOOTH
echo "🔌 17. DISPOSITIVOS CONECTADOS" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
system_profiler SPUSBDataType >> "$REPORT"
echo "" >> "$REPORT"
system_profiler SPBluetoothDataType >> "$REPORT"
echo "" >> "$REPORT"

# 18. PERMISSÕES DO TERMINAL (TCC)
echo "🔏 18. PERMISSÕES DE PRIVACIDADE (TCC)" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "SELECT * FROM access" 2>/dev/null >> "$REPORT"
echo "" >> "$REPORT"

# 19. CERTIFICADOS DE SEGURANÇA
echo "📜 19. CERTIFICADOS DO SISTEMA" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain 2>/dev/null | head -50 >> "$REPORT"
echo "" >> "$REPORT"

# 20. RELATÓRIO DE SAÚDE DO SISTEMA (SMC e temperatura se disponível)
echo "🌡️ 20. SENSORES E SAÚDE DO HARDWARE" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
ioreg -l | grep -i "cycle count" >> "$REPORT" 2>/dev/null
echo "" >> "$REPORT"
ioreg -l | grep -i "temperature" >> "$REPORT" 2>/dev/null
echo "" >> "$REPORT"

# 21. VERIFICAÇÃO DE ARQUIVOS DE SISTEMA MODIFICADOS
echo "🔍 21. INTEGRIDADE DOS ARQUIVOS DO SISTEMA" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
pkgutil --verify com.apple.pkg.BaseSystemBinaries >> "$REPORT" 2>&1
echo "" >> "$REPORT"

# 22. CONFIGURAÇÕES DO NVRAM
echo "💾 22. CONFIGURAÇÕES DO NVRAM" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
nvram -p >> "$REPORT" 2>/dev/null
echo "" >> "$REPORT"

# 23. DISCO DE RECUPERAÇÃO E PARTIÇÕES
echo "🛠️ 23. PARTIÇÕES DE RECUPERAÇÃO" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
diskutil apfs listUsers / >> "$REPORT" 2>/dev/null
echo "" >> "$REPORT"

# 24. CONFIGURAÇÕES DO FINDER E DOCK
echo "🖥️ 24. CONFIGURAÇÕES DA INTERFACE" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
defaults read com.apple.finder >> "$REPORT" 2>/dev/null
echo "" >> "$REPORT"
defaults read com.apple.dock >> "$REPORT" 2>/dev/null
echo "" >> "$REPORT"

# 25. VERIFICAÇÃO FINAL
echo "✅ AUDITORIA CONCLUÍDA" >> "$REPORT"
echo "------------------------------" >> "$REPORT"
echo "Relatório salvo em: $REPORT" >> "$REPORT"
echo "Data de conclusão: $(date)" >> "$REPORT"

# Abrir pasta do relatório
open "$REPORT_DIR"

echo "✅ Auditoria concluída! Relatório salvo em: $REPORT_DIR"
