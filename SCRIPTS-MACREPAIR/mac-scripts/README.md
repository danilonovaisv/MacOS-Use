# MacTech — Ferramentas de Manutenção e Otimização para macOS

Conjunto de utilitários avançados de diagnóstico, otimização de armazenamento, triagem de processos e configuração de ambiente de desenvolvimento para macOS (Apple Silicon M1/M2/M3/M4 e Intel).

---

## 🚀 1. Motor Unificado: `mac_engine.sh` (Recomendado)

O `mac_engine.sh` consolida todas as funções de auditoria, limpeza, triagem de falhas do sistema e ajustes de performance em uma única ferramenta com suporte a CLI e menu interativo.

### Tornar executável:
```bash
chmod +x SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh
```

### 1.1. Console Interativo (Menu de Terminal)
Abre o console visual com navegação por teclado:
```bash
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh
# ou
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --menu
```

### 1.2. Auditoria Completa do Sistema
Analisa hardware, saúde/ciclos da bateria, pressão térmica Apple Silicon, swap, armazenamento APFS e segurança:
```bash
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --audit
```

### 1.3. Otimização e Limpeza Segura de Espaço
Executa limpeza age-gated de caches (> 7 dias), higienização do ambiente Xcode (`DerivedData`, `Archives`, `Simulators`), purga de snapshots do Time Machine e liberação de memória RAM inativa:
```bash
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --optimize
```

### 1.4. Triagem e Reparação de Daemons do macOS
Resolve travamentos específicos de serviços em segundo plano:
```bash
# Corrigir LaunchAgents legados do Google Keystone (Job Missing Label)
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --triage keystone

# Reiniciar daemons de Mensagens e iCloud (imagent / identityservicesd)
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --triage messages

# Resetar serviços do Photos e permissões TCC
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --triage photos

# Redefinir cache do Gatekeeper (-67018)
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --triage gatekeeper

# Executar todas as triagens
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --triage all
```

### 1.5. Ajustes de Velocidade da Interface
Reduz o atraso de animação das janelas e do Dock para maximizar a fluidez:
```bash
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --speed-tweaks
```

### 1.6. Auditoria com Exportação de Relatório
Executa a auditoria completa e gera o arquivo de texto formatado no Desktop:
```bash
./SCRIPTS-MACREPAIR/mac-scripts/mac_engine.sh --audit --report
```

---

## 🛠️ 2. Setup de Desenvolvimento: `setup-dev-mac.sh`

Utilitário modular e idempotente para bootstrapping de uma máquina de desenvolvimento macOS:
* Xcode Command Line Tools
* Homebrew (com configuração automática de PATH no Apple Silicon `/opt/homebrew`)
* Ferramentas CLI essenciais (`git`, `ripgrep`, `bat`, `fzf`, `jq`, `gh`, etc.)
* Oh My Zsh com plugins de autosugestão e syntax-highlighting
* Node.js LTS via NVM
* Python via Pyenv
* Docker Desktop
* Bancos de dados locais (`postgresql`, `redis`, `sqlite`)

```bash
chmod +x SCRIPTS-MACREPAIR/mac-scripts/setup-dev-mac.sh
./SCRIPTS-MACREPAIR/mac-scripts/setup-dev-mac.sh
```

---

## 📂 3. Estrutura Modular da Biblioteca (`lib/`)

```
SCRIPTS-MACREPAIR/mac-scripts/
├── mac_engine.sh          <- CLI Unificado e Ponto de Entrada Principal
├── setup-dev-mac.sh       <- Script de Onboarding para Desenvolvedores
├── README.md              <- Documentação de Referência
└── lib/
    ├── ui_helpers.sh      <- Funções de banner, cores ANSI, logging e controle de sudo
    ├── system_info.sh     <- Coleta de métricas de Hardware, Bateria, Térmico e APFS
    ├── cleanup_tools.sh   <- Limpeza de caches age-gated, Xcode, Snapshots e RAM
    └── triage_fixes.sh    <- Rotinas especializadas de triagem e reparação de daemons
```
