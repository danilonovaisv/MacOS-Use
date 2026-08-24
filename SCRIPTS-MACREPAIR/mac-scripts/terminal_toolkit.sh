#!/bin/bash

# ================================
# 🧰 TERMINAL TOOLKIT - DAN EDITION
# ================================

clear
echo "🌟 Bem-vindo ao Terminal Toolkit"
echo "🔧 Comandos rápidos de manutenção e diagnóstico"
echo ""

select opt in "Atualizar sistema" "Limpar cache" "Verificar rede" "Listar apps instalados (brew)" "Ver status do Gatekeeper" "Sair"; do
  case $opt in
    "Atualizar sistema")
      echo "🔄 Atualizando pacotes..."
      brew update && brew upgrade
      sudo softwareupdate -i -a
      ;;
    "Limpar cache")
      echo "🧹 Limpando cache e executando scripts de manutenção..."
      sudo purge
      sudo periodic daily weekly monthly
      ;;
    "Verificar rede")
      echo "🌐 Testando conectividade e DNS..."
      ping -c 4 8.8.8.8
      dig google.com
      networkQuality
      ;;
    "Listar apps instalados (brew)")
      echo "📦 Lista de apps instalados via brew:"
      brew list
      ;;
    "Ver status do Gatekeeper")
      echo "🔐 Verificando status de segurança (Gatekeeper)..."
      spctl --status
      ;;
    "Sair")
      echo "👋 Saindo do script. Até logo!"
      break
      ;;
    *)
      echo "❌ Opção inválida."
      ;;
  esac
done
