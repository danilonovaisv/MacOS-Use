# Guia Operacional Central: SCRIPTS-MACREPAIR

Comandos e utilitários consolidados para manutenção, diagnóstico de hardware, otimização de armazenamento e reparo de rede no macOS (Apple Silicon M1/M2/M3/M4 e Intel).

---

## 💻 1. Manutenção do Sistema & Diagnósticos de Hardware (`mac-scripts/`)

### 1.1. Motor Unificado MacTech (`mac_engine.sh`) — Recomendado
```bash
# Dar permissão de execução
chmod +x SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh

# Abrir Menu Interativo de Manutenção
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --menu

# Executar Auditoria Completa (Hardware, Bateria, Térmico, APFS)
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --audit

# Executar Otimização e Limpeza Segura (Xcode, Caches, Snapshots APFS, RAM)
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --optimize

# Triagem de Processos e Daemons (Keystone, Messages, Photos, Gatekeeper)
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --triage all

# Ajustes de Velocidade de Interface (Finder/Dock)
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --speed-tweaks

# Gerar Relatório Completo no Desktop
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --audit --report
```

### 1.2. Setup de Ambiente de Desenvolvimento
```bash
chmod +x SCRIPTS-MACREPAIR/mac-scripts/setup-dev-mac.sh
./SCRIPTS-MACREPAIR/mac-scripts/setup-dev-mac.sh
```

---

## 📡 2. Diagnóstico & Otimização de Wi-Fi / Rede (`wifi/`)

### 2.1. Motor Unificado de Wi-Fi (`wifi_engine.sh`) — Recomendado
```bash
# Dar permissão de execução
chmod +x SCRIPTS-MACREPAIR/wifi/wifi_engine.sh

# Otimização Rápida de Wi-Fi (Flush DNS, Ciclo de Rádio 2.5s, Renovação DHCP)
./SCRIPTS-MACREPAIR/wifi/wifi_engine.sh --optimize

# Diagnóstico Completo de Sinal, Latência ao Gateway e Bufferbloat (networkQuality)
./SCRIPTS-MACREPAIR/wifi/wifi_engine.sh --diag

# Diagnóstico Completo com Exportação de Relatório
./SCRIPTS-MACREPAIR/wifi/wifi_engine.sh --diag --report

# Gerenciamento Seguro de DNS (com Backup Automático)
./SCRIPTS-MACREPAIR/wifi/wifi_engine.sh --dns cloudflare
./SCRIPTS-MACREPAIR/wifi/wifi_engine.sh --dns google
./SCRIPTS-MACREPAIR/wifi/wifi_engine.sh --dns dhcp

# Verificação de AWDL (AirDrop / Sidecar Jitter)
./SCRIPTS-MACREPAIR/wifi/wifi_engine.sh --awdl
```

---

## 🧹 3. Limpeza Geral Python (`mac-cleanup-py/`)
```bash
chmod +x SCRIPTS-MACREPAIR/mac-cleanup-py/mac-cleanup.sh
./SCRIPTS-MACREPAIR/mac-cleanup-py/mac-cleanup.sh
```
