# 1. Definir o arquivo de perfil (Geralmente .zshrc no Mac moderno)
PROFILE_FILE="$HOME/.zshrc"

# 2. Backup de Segurança do seu perfil atual
cp "$PROFILE_FILE" "$HOME/.zshrc.backup.antigravity"

# 3. Inserir a regra de Early Exit no TOPO do arquivo (.zshrc)
# Isso aborta o carregamento de temas e NVM se o shell não for interativo
sed -i '' '1i\
# --- Antigravity IDE Fix (Start) ---\
[[ $- != *i* ]] && return\
# --- Antigravity IDE Fix (End) ---\
' "$PROFILE_FILE"

echo "✅ Reparo do Antigravity aplicado com sucesso!"

