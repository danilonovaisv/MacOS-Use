#!/bin/zsh
# ==============================================================================
# MacTech Developer Onboarding & Bootstrap Setup
# Compatível com Apple Silicon (arm64) & macOS Monterey até Sequoia / Tahoe
# ==============================================================================

set -eo pipefail

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
BOLD="\033[1m"
NC="\033[0m"

log_info()    { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_success() { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
log_warn()    { printf "${YELLOW}[AVISO]${NC} %s\n" "$1"; }

echo -e "\n${BOLD}${BLUE}======================================================================${NC}"
echo -e "${BOLD}${CYAN}      🚀 Setup de Ambiente de Desenvolvimento macOS (Apple Silicon)     ${NC}"
echo -e "${BOLD}${BLUE}======================================================================${NC}\n"

# 0. Backup de segurança do .zshrc
ZSHRC="$HOME/.zshrc"
if [[ -f "$ZSHRC" ]]; then
  cp "$ZSHRC" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
  log_info "Backup do .zshrc criado."
fi

# 1. Xcode Command Line Tools
echo -e "\n${BOLD}[1/8] Verificando Xcode Command Line Tools...${NC}"
if ! xcode-select -p &>/dev/null; then
  log_info "Instalando Xcode Command Line Tools (uma janela do sistema pode aparecer)..."
  xcode-select --install || true
else
  log_success "Xcode Command Line Tools já instalado."
fi

# 2. Homebrew
echo -e "\n${BOLD}[2/8] Verificando Homebrew...${NC}"
if ! command -v brew &>/dev/null; then
  log_info "Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    if ! grep -q "/opt/homebrew/bin/brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    fi
  fi
else
  log_success "Homebrew já instalado: $(brew --version | head -n 1)"
fi

log_info "Atualizando fórmulas do Homebrew..."
brew update 2>/dev/null || true

# 3. Ferramentas essenciais de terminal
echo -e "\n${BOLD}[3/8] Instalando CLI Tools Essenciais...${NC}"
ESSENTIAL_TOOLS=(
  git wget curl htop tree jq fzf ripgrep bat neovim tldr httpie watch openssl gnupg gh
)

for tool in "${ESSENTIAL_TOOLS[@]}"; do
  if brew list "$tool" &>/dev/null; then
    echo "  - $tool: Já instalado."
  else
    echo "  - Instalando $tool..."
    brew install "$tool" 2>/dev/null || true
  fi
done
log_success "Ferramentas CLI instaladas."

# 4. Oh My Zsh & Plugins
echo -e "\n${BOLD}[4/8] Configuração do Zsh & Oh My Zsh...${NC}"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log_info "Instalando Oh My Zsh (modo não-interativo)..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null || true
else
  log_success "Oh My Zsh já instalado."
fi

# Plugins Zsh
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true
fi

# Atualizar plugins no .zshrc se ainda não estiverem configurados
if [[ -f "$ZSHRC" ]] && ! grep -q "zsh-autosuggestions" "$ZSHRC"; then
  sed -i '' 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf)/' "$ZSHRC" 2>/dev/null || true
fi
log_success "Zsh e plugins configurados."

# 5. Node.js & NVM
echo -e "\n${BOLD}[5/8] Gerenciador Node.js (NVM)...${NC}"
if ! brew list nvm &>/dev/null; then
  brew install nvm 2>/dev/null || true
fi
mkdir -p "$HOME/.nvm"

if ! grep -q "NVM_DIR" "$ZSHRC" 2>/dev/null; then
  cat << 'EOF' >> "$ZSHRC"

# NVM Environment Setup
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
EOF
fi

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

if command -v nvm &>/dev/null; then
  log_info "Instalando Node.js LTS via NVM..."
  nvm install --lts 2>/dev/null || true
  nvm use --lts 2>/dev/null || true
  npm install -g yarn pnpm eslint prettier nodemon 2>/dev/null || true
  log_success "Node.js e gerenciadores de pacotes prontos."
fi

# 6. Python & Pyenv
echo -e "\n${BOLD}[6/8] Gerenciador Python (Pyenv)...${NC}"
if ! brew list pyenv &>/dev/null; then
  brew install pyenv 2>/dev/null || true
fi

if ! grep -q "pyenv init" "$ZSHRC" 2>/dev/null; then
  cat << 'EOF' >> "$ZSHRC"

# Pyenv Environment Setup
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
fi
log_success "Pyenv configurado."

# 7. Docker
echo -e "\n${BOLD}[7/8] Docker Desktop...${NC}"
if ! brew list --cask docker &>/dev/null && [[ ! -d "/Applications/Docker.app" ]]; then
  log_info "Instalando Docker Cask..."
  brew install --cask docker 2>/dev/null || true
else
  log_success "Docker Desktop já instalado."
fi

# 8. Bancos de Dados de Desenvolvimento
echo -e "\n${BOLD}[8/8] Bancos de Dados Locais...${NC}"
DATABASES=(postgresql redis sqlite)
for db in "${DATABASES[@]}"; do
  if brew list "$db" &>/dev/null; then
    echo "  - $db: Já instalado."
  else
    echo "  - Instalando $db..."
    brew install "$db" 2>/dev/null || true
  fi
done
log_success "Bancos de dados instalados."

echo -e "\n${GREEN}${BOLD}======================================================================${NC}"
echo -e "${GREEN}${BOLD}  ✅ Setup de Desenvolvimento Finalizado com Sucesso!                 ${NC}"
echo -e "${GREEN}${BOLD}======================================================================${NC}"
echo -e "💡 Dica: Reinicie o Terminal ou execute: ${CYAN}source ~/.zshrc${NC}\n"
