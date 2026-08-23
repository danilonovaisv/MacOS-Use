#!/usr/bin/env bash

echo "🚀 Iniciando setup de desenvolvimento para macOS"
echo "-----------------------------------------------"

# 1. Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  echo "📦 Instalando Xcode Command Line Tools..."
  xcode-select --install
else
  echo "✅ Xcode Command Line Tools já instalado"
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
  echo "🍺 Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "✅ Homebrew já instalado"
fi

echo "🔄 Atualizando Homebrew..."
brew update

# 3. Ferramentas essenciais
echo "🧰 Instalando ferramentas essenciais..."
brew install \
git \
wget \
curl \
htop \
tree \
jq \
fzf \
ripgrep \
bat \
neovim \
tldr \
httpie \
watch \
openssl \
gnupg

# 4. Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "🐚 Instalando Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "✅ Oh My Zsh já instalado"
fi

# Plugins Zsh
echo "✨ Instalando plugins do Zsh..."
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions 2>/dev/null
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting 2>/dev/null

# Configuração do Zsh
if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
  sed -i '' 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf)/' ~/.zshrc
fi

# 5. NVM + Node.js
echo "🟢 Instalando NVM..."
brew install nvm
mkdir -p ~/.nvm

if ! grep -q "NVM_DIR" ~/.zshrc; then
  echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
  echo 'source "$(brew --prefix nvm)/nvm.sh"' >> ~/.zshrc
fi

export NVM_DIR="$HOME/.nvm"
source "$(brew --prefix nvm)/nvm.sh"

echo "🟢 Instalando Node.js LTS..."
nvm install --lts
nvm use --lts

npm install -g yarn pnpm eslint prettier nodemon

# 6. Python com pyenv
echo "🐍 Instalando pyenv..."
brew install pyenv

if ! grep -q "pyenv init" ~/.zshrc; then
  echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
  echo 'eval "$(pyenv init -)"' >> ~/.zshrc
fi

eval "$(pyenv init --path)"
eval "$(pyenv init -)"

echo "🐍 Instalando Python 3.12..."
pyenv install 3.12.1
pyenv global 3.12.1

pip install --upgrade pip
pip install virtualenv pipenv poetry

# 7. Docker
echo "🐳 Instalando Docker..."
brew install --cask docker

# 8. Bancos de dados
echo "🗄️ Instalando bancos de dados..."
brew install postgresql mysql redis sqlite

brew services start postgresql
brew services start redis

# 9. GitHub CLI
echo "🐙 Instalando GitHub CLI..."
brew install gh

echo "-----------------------------------------------"
echo "✅ Setup finalizado!"
echo "➡️ Reinicie o Terminal e abra o Docker Desktop manualmente uma vez."
