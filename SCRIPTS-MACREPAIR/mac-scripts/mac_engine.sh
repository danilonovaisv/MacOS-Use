#!/bin/zsh
# ==============================================================================
# MacTech Engine — CLI Unificado de Diagnóstico, Otimização e Triagem macOS
# Otimizado para Apple Silicon (M1/M2/M3/M4) & macOS Monterey até Sequoia / Tahoe
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

# Carregamento dos módulos auxiliares
if [[ -d "$LIB_DIR" ]]; then
  source "${LIB_DIR}/ui_helpers.sh"
  source "${LIB_DIR}/system_info.sh"
  source "${LIB_DIR}/cleanup_tools.sh"
  source "${LIB_DIR}/triage_fixes.sh"
else
  echo "Erro crítico: Diretório de bibliotecas '${LIB_DIR}' não encontrado."
  exit 1
fi

# ------------------------------------------------------------------------------
# Menu Interativo
# ------------------------------------------------------------------------------

show_interactive_menu() {
  while true; do
    clear
    echo -e "${BOLD}${BLUE}======================================================================${NC}"
    echo -e "${BOLD}${CYAN}            MacTech Unified Engine — Console de Manutenção            ${NC}"
    echo -e "${BOLD}${BLUE}======================================================================${NC}"
    echo -e " Host: ${BOLD}$(scutil --get ComputerName 2>/dev/null || hostname)${NC} | Usuário: ${BOLD}${USER}${NC} | macOS: ${BOLD}$(sw_vers -productVersion)${NC}"
    echo -e "----------------------------------------------------------------------"
    echo -e " ${BOLD}1)${NC} 🔍 Auditoria Completa do Sistema (Hardware, Bateria, Térmico e APFS)"
    echo -e " ${BOLD}2)${NC} 🧹 Otimização e Limpeza Segura de Armazenamento (Caches, Xcode, TM)"
    echo -e " ${BOLD}3)${NC} 🛠️  Triagem de Daemons do Sistema (Keystone, Messages, Photos, TCC)"
    echo -e " ${BOLD}4)${NC} ⚡ Ajustes de Velocidade da Interface (Finder / Dock Tweaks)"
    echo -e " ${BOLD}5)${NC} 🔐 Reparação Segura de Permissões da Pasta Home"
    echo -e " ${BOLD}6)${NC} 🌐 Flush e Reset de Caches de Rede / DNS"
    echo -e " ${BOLD}7)${NC} 🧠 Purga de Memória Inativa (RAM Flush)"
    echo -e " ${BOLD}8)${NC} 📄 Gerar Relatório Completo de Diagnóstico no Desktop"
    echo -e " ${BOLD}0)${NC} 🚪 Sair"
    echo -e "======================================================================"
    echo -n " Escolha uma opção (0-8): "
    read opcao

    case "$opcao" in
      1)
        run_full_system_audit
        echo -n "Pressione ENTER para continuar..."; read
        ;;
      2)
        run_full_system_optimization
        echo -n "Pressione ENTER para continuar..."; read
        ;;
      3)
        echo -e "\n${CYAN}Selecione a rotina de triagem:${NC}"
        echo " 1) Google Keystone (Job Missing Label)"
        echo " 2) Messages / iCloud Daemons"
        echo " 3) Photos / TCC Permissions Reset"
        echo " 4) Gatekeeper Cache Reset"
        echo " 5) Todas as triagens acima"
        echo -n "Opção (1-5): "
        read topc
        case "$topc" in
          1) fix_google_keystone ;;
          2) fix_messages_daemons ;;
          3) fix_photos_tcc_daemons ;;
          4) fix_gatekeeper_cache ;;
          5)
            fix_google_keystone
            fix_messages_daemons
            fix_photos_tcc_daemons
            fix_gatekeeper_cache
            ;;
        esac
        echo -n "Pressione ENTER para continuar..."; read
        ;;
      4)
        apply_ui_speed_tweaks
        echo -n "Pressione ENTER para continuar..."; read
        ;;
      5)
        elevate_privileges
        fix_home_permissions_safe
        echo -n "Pressione ENTER para continuar..."; read
        ;;
      6)
        clean_network_dns_directory
        echo -n "Pressione ENTER para continuar..."; read
        ;;
      7)
        purge_inactive_memory
        echo -n "Pressione ENTER para continuar..."; read
        ;;
      8)
        local report_file="$HOME/Desktop/MacTech_System_Report_$(date +%Y%m%d_%H%M%S).txt"
        echo -e "\n${CYAN}Gerando relatório em: ${report_file}...${NC}"
        {
          run_full_system_audit
        } | tee "$report_file"
        log_success "Relatório salvo em: ${report_file}"
        echo -n "Pressione ENTER para continuar..."; read
        ;;
      0)
        echo -e "\n${GREEN}Sessão finalizada. Sistema otimizado!${NC}\n"
        exit 0
        ;;
      *)
        echo -e "${RED}Opção inválida.${NC}"
        sleep 1
        ;;
    esac
  done
}

# ------------------------------------------------------------------------------
# Menu de Ajuda CLI
# ------------------------------------------------------------------------------

show_help() {
  echo -e "${BOLD}Uso:${NC} ./mac_engine.sh [OPÇÕES]

${BOLD}Opções Principais:${NC}
  -a, --audit               Executa diagnóstico completo (Hardware, Bateria, Térmico, Memória, APFS).
  -o, --optimize            Executa otimização e limpeza de armazenamento segura (Xcode, caches, TM).
  -t, --triage <alvo>       Executa triagem direcionada. Alvos: keystone | messages | photos | gatekeeper | all
  --speed-tweaks            Aplica ajustes de velocidade de animação em Finder e Dock.
  --repair-home             Corrige permissões do diretório \$HOME do usuário ativo.
  --purge                   Executa purge de memória inativa e flush de DNS.
  --menu                    Abre o console de menu interativo de manutenção.
  --report [caminho]        Gera relatório estruturado salvando no Desktop ou caminho especificado.
  -h, --help                Exibe esta tela de ajuda.

${BOLD}Exemplos:${NC}
  ./mac_engine.sh --audit
  ./mac_engine.sh --optimize
  ./mac_engine.sh --triage keystone
  ./mac_engine.sh --audit --report"
}

# ------------------------------------------------------------------------------
# Entrypoint Principal
# ------------------------------------------------------------------------------

main() {
  local action=""
  local triage_target=""
  local save_report=false
  local custom_report_path=""

  if [[ $# -eq 0 ]]; then
    show_interactive_menu
    exit 0
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -a|--audit|--auditoria)
        action="audit"
        shift
        ;;
      -o|--optimize|--otimizar)
        action="optimize"
        shift
        ;;
      -t|--triage)
        action="triage"
        triage_target="$2"
        shift 2
        ;;
      --speed-tweaks)
        action="speed_tweaks"
        shift
        ;;
      --repair-home)
        action="repair_home"
        shift
        ;;
      --purge)
        action="purge"
        shift
        ;;
      -m|--menu)
        show_interactive_menu
        exit 0
        ;;
      --report)
        save_report=true
        if [[ -n "$2" && "$2" != -* ]]; then
          custom_report_path="$2"
          shift 2
        else
          shift
        fi
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        echo -e "${RED}Opção não reconhecida: $1${NC}"
        show_help
        exit 1
        ;;
    esac
  done

  execute_action() {
    case "$action" in
      audit) run_full_system_audit ;;
      optimize) run_full_system_optimization ;;
      triage)
        case "$triage_target" in
          keystone) fix_google_keystone ;;
          messages) fix_messages_daemons ;;
          photos) fix_photos_tcc_daemons ;;
          gatekeeper) fix_gatekeeper_cache ;;
          all|"")
            fix_google_keystone
            fix_messages_daemons
            fix_photos_tcc_daemons
            fix_gatekeeper_cache
            ;;
          *)
            log_error "Alvo de triagem desconhecido: '$triage_target'. Use: keystone, messages, photos, gatekeeper ou all."
            exit 1
            ;;
        esac
        ;;
      speed_tweaks) apply_ui_speed_tweaks ;;
      repair_home)
        elevate_privileges
        fix_home_permissions_safe
        ;;
      purge)
        elevate_privileges
        clean_network_dns_directory
        purge_inactive_memory
        ;;
    esac
  }

  if [[ "$save_report" == "true" ]]; then
    local target_file="${custom_report_path:-$HOME/Desktop/MacTech_Report_$(date +%Y%m%d_%H%M%S).txt}"
    mkdir -p "$(dirname "$target_file")"
    echo -e "${CYAN}Gravando log de execução em: ${target_file}${NC}"
    execute_action | tee "$target_file"
  else
    execute_action
  fi
}

main "$@"
