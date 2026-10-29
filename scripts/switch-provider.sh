#!/usr/bin/env bash
# ==============================================================================
# Script: switch-provider.sh
# Propósito: Procedimento de Troca Rápida de Provedores para Agentes de Código
# Suporte: Codex CLI, Claude Code, Gemini CLI via CC Switch & FreeLLMAPI
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CCS_PY="$REPO_ROOT/.agents/skills/cc-switch/scripts/ccs.py"

if [[ ! -f "$CCS_PY" ]]; then
  echo "❌ Erro: script do CC Switch não encontrado em: $CCS_PY" >&2
  exit 1
fi

show_help() {
  cat << 'EOF'
Uso: ./scripts/switch-provider.sh <provedor> [app]

Provedores disponíveis:
  freellmapi | free     Ativa o proxy local FreeLLMAPI (http://127.0.0.1:31415)
  official   | prod     Retorna para as APIs oficiais de produção (OpenAI, Anthropic, Google)
  status     | current  Exibe o provedor ativo atual para cada agente

Aplicações suportadas (opcional, padrão: all):
  all                   Aplica a alteração para todos os agentes (codex, claude, gemini)
  codex                 Aplica apenas ao Codex CLI
  claude                Aplica apenas ao Claude Code
  gemini                Aplica apenas ao Gemini CLI

Exemplos:
  ./scripts/switch-provider.sh freellmapi          # Alterna todos para FreeLLMAPI
  ./scripts/switch-provider.sh official codex     # Alterna apenas Codex para OpenAI Oficial
  ./scripts/switch-provider.sh status             # Verifica o status atual
EOF
}

TARGET_PROVIDER="${1:-}"
TARGET_APP="${2:-all}"

if [[ -z "$TARGET_PROVIDER" || "$TARGET_PROVIDER" == "--help" || "$TARGET_PROVIDER" == "-h" ]]; then
  show_help
  exit 0
fi

case "$TARGET_PROVIDER" in
  status|current|ls)
    echo "📊 Status dos Provedores Ativos (CC Switch):"
    python3 "$CCS_PY" current
    exit 0
    ;;
  freellmapi|free)
    CODEX_PROV="FreeLLMAPI"
    CLAUDE_PROV="FreeLLMAPI"
    GEMINI_PROV="FreeLLMAPI"
    ;;
  official|prod|default)
    CODEX_PROV="OpenAI Official"
    CLAUDE_PROV="ClaudeAPI"
    GEMINI_PROV="default"
    ;;
  *)
    echo "❌ Provedor inválido: '$TARGET_PROVIDER'. Use 'freellmapi', 'official' ou 'status'." >&2
    echo "" >&2
    show_help
    exit 1
    ;;
esac

switch_app() {
  local app="$1"
  local provider="$2"
  echo "🔄 Alternando $app -> '$provider'..."
  python3 "$CCS_PY" switch "$provider" --app "$app"
}

case "$TARGET_APP" in
  codex)
    switch_app "codex" "$CODEX_PROV"
    ;;
  claude)
    switch_app "claude" "$CLAUDE_PROV"
    ;;
  gemini)
    switch_app "gemini" "$GEMINI_PROV"
    ;;
  all)
    switch_app "codex" "$CODEX_PROV"
    switch_app "claude" "$CLAUDE_PROV"
    switch_app "gemini" "$GEMINI_PROV"
    ;;
  *)
    echo "❌ Aplicação inválida: '$TARGET_APP'. Escolha entre: codex, claude, gemini, all." >&2
    exit 1
    ;;
esac

echo ""
echo "✅ Troca concluída com sucesso! Estado atualizado:"
python3 "$CCS_PY" current

