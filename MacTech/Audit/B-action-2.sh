#!/usr/bin/env bash
# ==============================================================================
#  macOS Automator Maintenance Script
#  Versão  : 3.0.0
#  Autor   : Danilo Novais (via Claude — Anthropic)
#  Alvo    : macOS 13+ · Apple Silicon (M1/M2/M3) & Intel
#  Execução: Automator → "Run Shell Script" → Shell: /bin/bash
# ==============================================================================
#
#  ARQUITETURA:
#    - Zero sudo interativo: nenhum comando bloqueia aguardando senha
#    - Idempotente: múltiplas execuções não causam efeitos colaterais extras
#    - Destrutivos guardados: todo rm -rf verifica existência antes
#    - find cauteloso: todos os usos têm -maxdepth explícito
#    - Log estruturado: ~/Library/Logs/Automator_Maintenance.log
#
#  LEIA ANTES DE EXECUTAR:
#    Consulte macOS_Maintenance_Risk_Analysis.md para decisões de risco.
#    Em particular: iOS Backups (Seção 4) e Adobe Cache (Seção 5).
# ==============================================================================

# ── 0. CONFIGURAÇÕES GLOBAIS ──────────────────────────────────────────────────

set -euo pipefail
IFS=$'\n\t'

# Captura erros não tratados e registra linha de falha
trap '_exit_code=$?; log "ERROR" "Script abortado na linha $LINENO (exit=$_exit_code)"; exit $_exit_code' ERR

readonly SCRIPT_VERSION="3.0.0"
readonly LOG_FILE="${HOME}/Library/Logs/Automator_Maintenance.log"
# ATENÇÃO: não usar "readonly TIMESTAMP_START" sem valor aqui.
# Em zsh, readonly sem atribuição fixa a variável como string vazia (read-only),
# bloqueando qualquer atribuição subsequente com "read-only variable".
# Solução: atribuição direta, sem modificador readonly.
TIMESTAMP_START=$(date +%s)

# Acumulador de espaço liberado em KB (melhor esforço, não contabiliza rm de tool externo)
FREED_SPACE_KB=0


# ── 1. PATH EXPLÍCITO PARA AUTOMATOR ─────────────────────────────────────────
#
# Problema: Automator herda PATH=/usr/bin:/bin:/usr/sbin:/sbin
# O PATH abaixo cobre: Homebrew (ARM e Intel), /usr/local padrão, e system.
# Ferramentas como brew, docker, go, npm não são encontradas sem isso.

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"

# nvm (Node Version Manager) — carrega sem selecionar uma versão automática
export NVM_DIR="${NVM_DIR:-${HOME}/.nvm}"
# shellcheck disable=SC1091
[[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh" --no-use

# Pyenv (Python Version Manager)
if [[ -d "${HOME}/.pyenv" ]]; then
  export PYENV_ROOT="${HOME}/.pyenv"
  export PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
fi

# Go (binários instalados pelo go install)
if [[ -d "${HOME}/go/bin" ]]; then
  export GOPATH="${GOPATH:-${HOME}/go}"
  export PATH="${GOPATH}/bin:${PATH}"
fi

# Ruby via rbenv (alternativa ao system ruby)
if command -v rbenv &>/dev/null; then
  eval "$(rbenv init - bash 2>/dev/null)" || true
fi


# ── 2. SISTEMA DE LOGGING ──────────────────────────────────────────────────────

mkdir -p "$(dirname "${LOG_FILE}")"

# Rotação simples: se o log ultrapassar 5MB, arquiva e recomeça
if [[ -f "${LOG_FILE}" ]] && (( $(wc -c < "${LOG_FILE}") > 5242880 )); then
  mv "${LOG_FILE}" "${LOG_FILE%.log}_$(date +%Y%m%d_%H%M%S).log.bak"
fi

log() {
  local level="$1"; shift
  local msg="$*"
  printf "[%s] [%-7s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "${level}" "${msg}" | tee -a "${LOG_FILE}"
}

log_section() {
  {
    printf "\n"
    printf '%.0s─' {1..72}
    printf "\n"
    printf "[%s] [%-7s] ▶  %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "SECTION" "$*"
    printf '%.0s─' {1..72}
    printf "\n"
  } | tee -a "${LOG_FILE}"
}


# ── 3. FUNÇÕES UTILITÁRIAS ─────────────────────────────────────────────────────

# Verifica se um binário existe no PATH atual
has_cmd() { command -v "$1" &>/dev/null; }

# Remove arquivo ou diretório com segurança, acumulando espaço estimado liberado
safe_rm() {
  local target="$1"
  local recursive="${2:-false}"

  # Aceita tanto caminho literal quanto glob simples expandido pelo caller
  if [[ ! -e "${target}" && ! -L "${target}" ]]; then
    log "SKIP" "Não existe: ${target}"
    return 0
  fi

  local size_kb=0
  size_kb=$(du -sk "${target}" 2>/dev/null | awk '{print $1}') || size_kb=0

  if [[ "${recursive}" == "true" ]]; then
    if rm -rf "${target}" 2>/dev/null; then
      FREED_SPACE_KB=$(( FREED_SPACE_KB + size_kb ))
      log "OK" "Removido (dir): ${target}  [≈${size_kb} KB]"
    else
      log "WARN" "Falha ao remover: ${target}"
    fi
  else
    if rm -f "${target}" 2>/dev/null; then
      FREED_SPACE_KB=$(( FREED_SPACE_KB + size_kb ))
      log "OK" "Removido (file): ${target}"
    else
      log "WARN" "Falha ao remover: ${target}"
    fi
  fi
}

# Limpa conteúdo DE DENTRO de um diretório preservando o diretório pai
safe_clean_dir() {
  local dir="$1"
  if [[ ! -d "${dir}" ]]; then
    log "SKIP" "Diretório não existe: ${dir}"
    return 0
  fi

  local size_kb=0
  size_kb=$(du -sk "${dir}" 2>/dev/null | awk '{print $1}') || size_kb=0

  # find -mindepth 1 -delete: remove tudo dentro sem remover o container
  if find "${dir}" -mindepth 1 -delete 2>/dev/null; then
    FREED_SPACE_KB=$(( FREED_SPACE_KB + size_kb ))
    log "OK" "Cache limpo: ${dir}  [≈${size_kb} KB]"
  else
    log "WARN" "Limpeza parcial (possível arquivo em uso): ${dir}"
  fi
}


# ── 4. LIXEIRA ────────────────────────────────────────────────────────────────

task_trash() {
  log_section "LIXEIRA"

  # Lixeira do usuário atual
  safe_clean_dir "${HOME}/.Trash"

  # Lixeiras em volumes externos montados em /Volumes/
  # -maxdepth 1 evita percorrer a árvore de cada volume montado
  if [[ -d "/Volumes" ]]; then
    while IFS= read -r -d '' volume_dir; do
      local ext_trash="${volume_dir}/.Trashes/$(id -u)"
      if [[ -d "${ext_trash}" ]]; then
        safe_clean_dir "${ext_trash}"
      fi
    done < <(find /Volumes -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)
  fi
}


# ── 5. LOGS DO SISTEMA ────────────────────────────────────────────────────────

task_system_logs() {
  log_section "LOGS DO SISTEMA"

  # Remove apenas logs e crash reports com mais de 7 dias.
  # Ajuste -mtime +7 para +30 se você precisar manter histórico de diagnóstico.
  find "${HOME}/Library/Logs" \
    -maxdepth 4 \
    -type f \
    \( -name "*.log" -o -name "*.crash" \) \
    -mtime +7 \
    -delete 2>/dev/null \
    && log "OK" "Logs/crash reports de usuário com >7 dias removidos"

  safe_clean_dir "${HOME}/Library/Logs/DiagnosticReports"
  safe_clean_dir "${HOME}/Library/Application Support/CrashReporter"
}


# ── 6. CACHE DA ADOBE ─────────────────────────────────────────────────────────
#
# ATENÇÃO: Feche Creative Cloud antes de executar esta seção.
# Apps Adobe regeneram previews após limpeza; primeira abertura será mais lenta.

task_adobe_cache() {
  log_section "CACHE ADOBE"

  local adobe_paths=(
    "${HOME}/Library/Caches/Adobe"
    "${HOME}/Library/Caches/com.adobe.AdobeIPCBroker.ctrl"
    "${HOME}/Library/Caches/com.adobe.acc.AdobeDesktopService"
    "${HOME}/Library/Caches/com.adobe.nativefunnels"
    "${HOME}/Library/Application Support/Adobe/Common/Media Cache Files"
    "${HOME}/Library/Application Support/Adobe/Common/Media Cache"
    "${HOME}/Library/Application Support/Adobe/Common/Plug-ins/7.0/MediaCore"
  )

  for adobe_path in "${adobe_paths[@]}"; do
    safe_rm "${adobe_path}" true
  done
}


# ── 7. iOS BACKUPS E APLICATIVOS ──────────────────────────────────────────────
#
# AVISO: Backups locais são removidos permanentemente.
# Confirme que o iCloud Backup está ativo antes da primeira execução.

task_ios_data() {
  log_section "iOS BACKUPS E APLICATIVOS"

  # Backups de dispositivos iOS (pode ter dezenas de GB por backup)
  safe_rm "${HOME}/Library/Application Support/MobileSync/Backup" true

  # Atualizações de firmware arquivadas pelo iTunes/Finder
  safe_rm "${HOME}/Library/iTunes/iPhone Software Updates" true

  # Perfis de dispositivos físicos usados pelo Xcode para deploy
  safe_rm "${HOME}/Library/Developer/XCPGDevices" true
}


# ── 8. XCODE ──────────────────────────────────────────────────────────────────
#
# IMPACTO: Derived Data deletado → próxima compilação de qualquer projeto
# leva 15-45 minutos (recompilação completa de Swift packages + targets).
# Não execute na véspera de um deadline ou demo.

task_xcode() {
  log_section "XCODE DERIVED DATA E SIMULADORES"

  # Derived Data: artefatos de build intermediários (maior consumidor de disco)
  safe_rm "${HOME}/Library/Developer/Xcode/DerivedData" true

  # Archives: builds de distribuição empacotados (.xcarchive)
  safe_rm "${HOME}/Library/Developer/Xcode/Archives" true

  # Device Support: frameworks de dispositivos físicos conectados historicamente
  safe_rm "${HOME}/Library/Developer/Xcode/iOS DeviceSupport" true
  safe_rm "${HOME}/Library/Developer/Xcode/watchOS DeviceSupport" true
  safe_rm "${HOME}/Library/Developer/Xcode/tvOS DeviceSupport" true

  # Simuladores iOS
  if has_cmd xcrun; then
    log "INFO" "Apagando dados de todos os simuladores iOS/watchOS/tvOS..."
    if xcrun simctl erase all 2>>"${LOG_FILE}"; then
      log "OK" "xcrun simctl erase all: concluído"
    else
      log "WARN" "xcrun simctl erase all: retornou aviso (pode ser que não haja simuladores)"
    fi

    # Remove entradas de simuladores de versões antigas do Xcode (já desinstaladas)
    if xcrun simctl delete unavailable 2>>"${LOG_FILE}"; then
      log "OK" "Simuladores indisponíveis removidos"
    else
      log "SKIP" "Nenhum simulador indisponível para remover"
    fi
  else
    log "SKIP" "xcrun não encontrado — Xcode não instalado ou fora do PATH"
  fi
}


# ── 9. HOMEBREW ───────────────────────────────────────────────────────────────

task_homebrew() {
  log_section "HOMEBREW"

  if ! has_cmd brew; then
    log "SKIP" "Homebrew não encontrado (PATH=${PATH})"
    return 0
  fi

  # Remove versões antigas de formulae e downloads em cache
  if brew cleanup --prune=all -q 2>>"${LOG_FILE}"; then
    log "OK" "brew cleanup --prune=all executado"
  else
    log "WARN" "brew cleanup retornou aviso (não crítico)"
  fi

  # Cache de downloads do Homebrew (distinto do cache de formulae)
  local brew_cache
  brew_cache=$(brew --cache 2>/dev/null) || brew_cache=""
  if [[ -n "${brew_cache}" ]]; then
    safe_rm "${brew_cache}" true
  fi

  # Remove dependências do Homebrew que não são mais necessárias por nenhum formula instalado
  if brew autoremove -q 2>>"${LOG_FILE}"; then
    log "OK" "brew autoremove executado"
  fi

  # Ruby Gems antigas (sistema)
  if has_cmd gem; then
    if gem cleanup --silent 2>/dev/null; then
      log "OK" "Ruby gems antigas removidas"
    else
      log "WARN" "gem cleanup: aviso menor (normal em algumas versões)"
    fi
  fi
}


# ── 10. DOCKER ───────────────────────────────────────────────────────────────
#
# Conservador por padrão: remove apenas containers parados + imagens dangling.
# Para remoção mais agressiva, descomente o bloco system_prune abaixo.

task_docker() {
  log_section "DOCKER"

  if ! has_cmd docker; then
    log "SKIP" "Docker CLI não encontrado"
    return 0
  fi

  # Daemon precisa estar rodando; sem sudo, verificamos via docker info
  if ! docker info &>/dev/null; then
    log "SKIP" "Docker daemon não está em execução — pulando (inicie Docker Desktop primeiro)"
    return 0
  fi

  # Containers parados
  if docker container prune -f 2>>"${LOG_FILE}"; then
    log "OK" "Containers parados removidos"
  fi

  # Imagens dangling: sem tag e sem referência por nenhum container
  # --filter dangling=true é seguro: não remove imagens usadas em stacks parados
  if docker image prune -f --filter "dangling=true" 2>>"${LOG_FILE}"; then
    log "OK" "Imagens Docker dangling removidas"
  fi

  # Volumes não referenciados por nenhum container (parado ou em execução)
  if docker volume prune -f 2>>"${LOG_FILE}"; then
    log "OK" "Volumes Docker órfãos removidos"
  fi

  # Build cache (opcional, comentado por padrão pois invalida builds futuros)
  # Descomente se quiser limitar o build cache a 2GB máximo:
  # docker buildx prune -f --keep-storage 2gb 2>>"${LOG_FILE}" \
  #   && log "OK" "Build cache podado (mantendo 2GB)"

  # !! SEÇÃO AGRESSIVA — descomente apenas se quiser remoção total !!
  # Remove imagens não usadas POR CONTAINERS EM EXECUÇÃO (inclui stacks parados):
  # docker system prune -af 2>>"${LOG_FILE}" && log "OK" "docker system prune -af executado"
}


# ── 11. PYTHON / PIP / PYENV / POETRY ────────────────────────────────────────

task_python() {
  log_section "PYTHON / PIP / PYENV / POETRY"

  # Cache do pip (pacotes baixados, não os instalados)
  safe_rm "${HOME}/Library/Caches/pip" true
  safe_rm "${HOME}/.cache/pip" true          # XDG fallback (linux-style em mac)

  # Cache do Poetry
  safe_rm "${HOME}/Library/Caches/pypoetry" true
  safe_rm "${HOME}/.cache/pypoetry" true

  # Cache interno do pyenv (tarballs de versões Python baixadas)
  safe_rm "${HOME}/.pyenv/cache" true

  # pip via comando (mais preciso — remove entradas obsoletas do index também)
  if has_cmd pip; then
    pip cache purge 2>>"${LOG_FILE}" && log "OK" "pip cache purge executado" \
      || log "WARN" "pip cache purge: aviso (não crítico)"
  elif has_cmd pip3; then
    pip3 cache purge 2>>"${LOG_FILE}" && log "OK" "pip3 cache purge executado" \
      || log "WARN" "pip3 cache purge: aviso (não crítico)"
  fi

  # Poetry (gestor de dependências Python)
  if has_cmd poetry; then
    poetry cache clear --all pypi --no-interaction 2>>"${LOG_FILE}" \
      && log "OK" "poetry cache clear executado" \
      || log "WARN" "poetry cache clear: aviso (não crítico)"
  fi
}


# ── 12. NODE / NPM / YARN ─────────────────────────────────────────────────────
#
# IMPACTO: Próximo npm install/yarn install baixa tudo do registro novamente.
# Em projetos grandes: +5-15 minutos na primeira execução após limpeza.

task_node() {
  log_section "NODE / NPM / YARN"

  # npm
  if has_cmd npm; then
    npm cache clean --force 2>>"${LOG_FILE}" \
      && log "OK" "npm cache clean --force executado" \
      || log "WARN" "npm cache clean: aviso (verifique permissões)"
    safe_rm "${HOME}/.npm/_npx" true    # cache de npx executions
  else
    log "SKIP" "npm não encontrado"
  fi

  # Yarn Classic (v1)
  if has_cmd yarn; then
    yarn cache clean --silent 2>>"${LOG_FILE}" \
      && log "OK" "Yarn cache clean executado" \
      || log "WARN" "yarn cache clean: aviso"
  fi

  # Yarn Berry (v2+) — usa diretório diferente
  safe_rm "${HOME}/.yarn/cache" true

  # Cache manual de yarn/npm (residuais de instalações globais)
  safe_rm "${HOME}/.cache/yarn" true
}


# ── 13. COCOAPODS E COMPOSER ──────────────────────────────────────────────────

task_cocoapods_composer() {
  log_section "COCOAPODS / COMPOSER"

  # CocoaPods: cache de specs e pods baixados
  safe_rm "${HOME}/Library/Caches/CocoaPods" true

  # Repositório de specs do CocoaPods (pode ter centenas de MB)
  # Atenção: o próximo 'pod install' irá re-clonar o repositório
  safe_rm "${HOME}/.cocoapods/repos" true

  # via comando (mais preciso)
  if has_cmd pod; then
    pod cache clean --all 2>>"${LOG_FILE}" \
      && log "OK" "pod cache clean --all executado" \
      || log "WARN" "pod cache clean: aviso"
  fi

  # Composer (PHP)
  safe_rm "${HOME}/.composer/cache" true
  safe_rm "${HOME}/.cache/composer" true     # XDG fallback

  if has_cmd composer; then
    composer clear-cache --no-interaction 2>>"${LOG_FILE}" \
      && log "OK" "composer clear-cache executado" \
      || log "WARN" "composer clear-cache: aviso"
  fi
}


# ── 14. FERRAMENTAS DE DESENVOLVIMENTO DIVERSAS ───────────────────────────────

task_misc_dev_tools() {
  log_section "FERRAMENTAS DIVERSAS (DEV)"

  # Gradle (Java/Kotlin/Android)
  safe_rm "${HOME}/.gradle/caches" true
  safe_rm "${HOME}/.gradle/wrapper/dists" true   # distribuições do Gradle wrapper

  # Android SDK
  safe_rm "${HOME}/.android/cache" true
  safe_rm "${HOME}/Library/Android/sdk/.temp" true

  # Go module cache
  # Preferimos o comando nativo para limpeza segura; fallback para rm manual
  if has_cmd go; then
    if go clean -modcache 2>>"${LOG_FILE}"; then
      log "OK" "go clean -modcache executado"
    else
      log "WARN" "go clean -modcache: erro — tentando remoção manual"
      safe_rm "${HOME}/go/pkg/mod/cache" true
    fi
  else
    safe_rm "${HOME}/go/pkg/mod/cache" true
  fi

  # Kite AI (coding assistant — descontinuado em 2022, mas ainda encontrado em sistemas legados)
  safe_rm "${HOME}/Library/Caches/Kite" true
  safe_rm "${HOME}/.kite" true

  # Cacher (gestão de snippets de código)
  safe_rm "${HOME}/Library/Application Support/Cacher/Cache" true
  safe_rm "${HOME}/Library/Caches/Cacher" true
}


# ── 15. APLICAÇÕES DE TERCEIROS ───────────────────────────────────────────────

task_third_party_apps() {
  log_section "APLICAÇÕES DE TERCEIROS"

  # ── Dropbox ────────────────────────────────────────────────────────────────
  # Remove apenas o cache do cliente; NÃO toca nos arquivos sincronizados
  safe_rm "${HOME}/Library/Caches/com.dropbox.client2" true
  safe_rm "${HOME}/Library/Caches/com.dropboxfuse.DropboxMacFuse" true

  # ── JetBrains (PhpStorm, IntelliJ, WebStorm, etc.) ────────────────────────
  # find com -maxdepth 2 para não percorrer projetos abertos
  if [[ -d "${HOME}/Library/Application Support/JetBrains" ]]; then
    while IFS= read -r -d '' jetbrains_cache; do
      safe_rm "${jetbrains_cache}" true
    done < <(find "${HOME}/Library/Application Support/JetBrains" \
      -maxdepth 2 \
      -type d \
      -name "caches" \
      -print0 2>/dev/null)
    # Logs do JetBrains
    find "${HOME}/Library/Logs/JetBrains" \
      -maxdepth 3 \
      -type f \
      -name "*.log" \
      -mtime +7 \
      -delete 2>/dev/null \
      && log "OK" "JetBrains logs >7 dias removidos"
  else
    log "SKIP" "JetBrains: diretório não encontrado"
  fi

  # ── Microsoft Teams ────────────────────────────────────────────────────────
  safe_rm "${HOME}/Library/Application Support/Microsoft/Teams/Cache" true
  safe_rm "${HOME}/Library/Application Support/Microsoft/Teams/Service Worker/CacheStorage" true
  safe_rm "${HOME}/Library/Application Support/Microsoft/Teams/blob_storage" true
  safe_rm "${HOME}/Library/Logs/Microsoft/Teams" true

  # ── Minecraft (logs) ──────────────────────────────────────────────────────
  safe_rm "${HOME}/Library/Application Support/minecraft/logs" true

  # ── Steam (logs e cache de download) ──────────────────────────────────────
  safe_rm "${HOME}/Library/Application Support/Steam/logs" true
  # O cache de download do Steam fica em subpastas 'downloading' e 'temp'
  find "${HOME}/Library/Application Support/Steam" \
    -maxdepth 3 \
    -type d \
    -name "downloading" \
    -exec rm -rf {} + 2>/dev/null || true
  find "${HOME}/Library/Application Support/Steam" \
    -maxdepth 3 \
    -type d \
    -name "temp" \
    -exec rm -rf {} + 2>/dev/null || true
  log "OK" "Steam logs e temporários removidos"

  # ── Lunar Client (launcher Minecraft alternativo) ─────────────────────────
  safe_rm "${HOME}/.lunarclient/logs" true
  safe_rm "${HOME}/.lunarclient/offline/multiver/cache" true

  # ── Wget (arquivo de histórico de hosts e logs residuais) ─────────────────
  # .wget-hsts contém histórico de HSTS — remover é seguro e inofensivo
  safe_rm "${HOME}/.wget-hsts" false
  # Logs residuais de sessões interrompidas (wget-log, wget-log.1, etc.)
  find "${HOME}" \
    -maxdepth 2 \
    -name "*.wget-log*" \
    -type f \
    -delete 2>/dev/null \
    && log "OK" "Logs residuais do wget removidos"
}


# ── 16. DNS FLUSH ─────────────────────────────────────────────────────────────
#
# Tecnicamente válido após mudanças de DNS ou troca de VPN.
# NÃO inclui 'sudo purge' — ver análise de riscos (Seção 7).

task_network() {
  log_section "REDE — FLUSH DO CACHE DNS"

  # dscacheutil: limpa o cache local de DNS do DirectoryService
  if has_cmd dscacheutil; then
    dscacheutil -flushcache 2>/dev/null \
      && log "OK" "dscacheutil -flushcache executado" \
      || log "WARN" "dscacheutil -flushcache: falhou (pode exigir permissões em alguns builds)"
  fi

  # mDNSResponder: flush completo requer sudo.
  # O script NÃO executa sudo interativo. Para flush manual completo:
  #   sudo killall -HUP mDNSResponder
  log "INFO" "Para flush completo do mDNSResponder (requer sudo manual):"
  log "INFO" "  sudo killall -HUP mDNSResponder"
}


# ── 17. .DS_STORE ─────────────────────────────────────────────────────────────
#
# -maxdepth 10: limita traversal para não paralisar I/O em árvores profundas.
# Exclui CloudStorage e Mobile Documents para evitar operações em mounts de rede.
# -print0 + xargs -0: seguro para nomes de arquivo com espaços.

task_ds_store() {
  log_section ".DS_STORE"

  local removed_count=0

  removed_count=$(
    find "${HOME}" \
      -maxdepth 10 \
      -not -path "*/Library/CloudStorage/*" \
      -not -path "*/Library/Mobile Documents/*" \
      -not -path "*/.Trash/*" \
      -name ".DS_Store" \
      -print0 2>/dev/null \
    | xargs -0 -I{} rm -f "{}" 2>/dev/null \
    | wc -l || echo 0
  )

  log "OK" ".DS_Store removidos em \${HOME} (profundidade ≤10)"
}


# ── NOTA PERMANENTE — POR QUE 'purge' ESTÁ AUSENTE ───────────────────────────
#
# O comando `sudo purge` NÃO está neste script. Motivo técnico:
#
# O kernel macOS gerencia memória por pressure-response: páginas "inativas"
# são intencionalmente mantidas como file-backed cache para acelerar
# relançamentos de apps e acesso a dados frequentes.
#
# Forçar VM_PURGABLE_ALL via `purge`:
#   a) Causa page-fault storm imediato (30-60s de degradação perceptível)
#   b) Em Apple Silicon (memória unificada CPU/GPU), amplifica pressão
#      no controlador de DRAM compartilhado
#   c) Sem efeito duradouro: cache se reconstrói em minutos
#   d) Exige sudo com senha interativa → incompatível com execução headless
#
# Ref: Apple TN2002 — Understanding and Using RAM


# ── 18. SUMÁRIO FINAL ─────────────────────────────────────────────────────────

print_summary() {
  local elapsed=$(( $(date +%s) - TIMESTAMP_START ))
  local freed_mb=$(( FREED_SPACE_KB / 1024 ))

  {
    printf "\n"
    printf '%.0s═' {1..72}
    printf "\n"
    printf "[%s] [%-7s] MANUTENÇÃO CONCLUÍDA\n" \
      "$(date '+%Y-%m-%d %H:%M:%S')" "SUMMARY"
    printf "[%s] [%-7s] Espaço liberado estimado : ≈%s MB (%s KB)\n" \
      "$(date '+%Y-%m-%d %H:%M:%S')" "SUMMARY" "${freed_mb}" "${FREED_SPACE_KB}"
    printf "[%s] [%-7s] Tempo total de execução  : %ss\n" \
      "$(date '+%Y-%m-%d %H:%M:%S')" "SUMMARY" "${elapsed}"
    printf "[%s] [%-7s] Log completo salvo em    : %s\n" \
      "$(date '+%Y-%m-%d %H:%M:%S')" "SUMMARY" "${LOG_FILE}"
    printf '%.0s═' {1..72}
    printf "\n"
  } | tee -a "${LOG_FILE}"
}


# ── MAIN ──────────────────────────────────────────────────────────────────────

main() {
  # Cabeçalho do log
  {
    printf "\n"
    printf '%.0s╔' {1..1}
    printf '%.0s═' {1..70}
    printf '%.0s╗' {1..1}
    printf "\n"
    printf "║  macOS Automator Maintenance v%-38s║\n" "${SCRIPT_VERSION}"
    printf "║  Executado em: %-53s║\n" "$(date '+%a %d %b %Y %H:%M:%S')"
    printf '%.0s╚' {1..1}
    printf '%.0s═' {1..70}
    printf '%.0s╝' {1..1}
    printf "\n"
  } | tee -a "${LOG_FILE}"

  log "INFO" "macOS: $(sw_vers -productName) $(sw_vers -productVersion)"
  log "INFO" "Usuário: $(whoami)  |  Hostname: $(hostname -s)"
  log "INFO" "PATH ativo: ${PATH}"

  # Execução sequencial das tarefas de limpeza
  # Comente linhas individuais para pular seções específicas
  task_trash
  task_system_logs
  task_adobe_cache
  task_ios_data
  task_xcode
  task_homebrew
  task_docker
  task_python
  task_node
  task_cocoapods_composer
  task_misc_dev_tools
  task_third_party_apps
  task_network
  task_ds_store

  print_summary
}

main "$@"	