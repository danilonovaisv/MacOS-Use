#!/bin/bash
# setup-zoho-mail.sh
# Script de instalação da conta Zoho Mail no Apple Mail

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/zoho-config-template.json"

echo "🔧 Configurador de Conta Zoho Mail no Apple Mail"
echo "================================================"
echo ""

# Verifica se Python 3 está disponível
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 não encontrado"
    exit 1
fi

# Verifica se o Apple Mail está instalado
if ! command -v osascript &> /dev/null; then
    echo "❌ osascript não encontrado (necessário para AppleScript)"
    exit 1
fi

echo "✅ Pre-requisitos verificados"
echo ""

# Mostra pré-requisitos a serem verificados pelo usuário
echo "📋 VERIFIQUE ANTES DE PROCEDER:"
echo "   1. IMAP habilitado em: https://mail.zoho.com → Settings → Mail Accounts → IMAP Access"
echo "   2. Se 2FA está ativo, gerar App-Specific Password em: https://accounts.zoho.com"
echo ""

# Verifica se o script foi executado com --execute
if [ "$1" != "--execute" ]; then
    echo "⚠️  MODO DRY-RUN ativado (não modifica nada)"
    echo "   Execute novamente com --execute para aplicar as mudanças:"
    echo "   $0 --execute"
    echo ""
fi

# Executa o script Python
if [ "$1" = "--execute" ]; then
    python3 "${SCRIPT_DIR}/script/apple-mail-account-setup.py" "${CONFIG_FILE}" --execute
else
    python3 "${SCRIPT_DIR}/script/apple-mail-account-setup.py" "${CONFIG_FILE}"
fi

echo ""
echo "✅ Processo concluído!"