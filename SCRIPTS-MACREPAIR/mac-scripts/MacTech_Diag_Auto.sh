\
    #!/bin/bash
    # MacTech Expert Assistant — Diagnóstico + Otimização + Limpeza (Automático / Silencioso)
    # Versão: 1.0.1 (auto)
    # Compatível: macOS 12+ (Apple Silicon). Foca em M1/M2/M3.
    # Uso: duplo clique no Finder ou execução direta no Terminal.
    # Segurança: não remove documentos; limpa apenas caches/logs e itens temporários comuns.

    set -euo pipefail

    ts() { date "+%Y-%m-%d %H:%M:%S"; }
    banner() { printf "\n# -------------------------------------------------------------------\n# %s\n# -------------------------------------------------------------------\n" "$1"; }
    log() { printf "[%s] %s\n" "$(ts)" "$1" | tee -a "$REPORT"; }

    ARCH="$(uname -m || true)"
    OSVER="$(sw_vers -productVersion 2>/dev/null || echo "desconhecido")"
    if [[ "${ARCH:-}" != "arm64" ]]; then
      echo "Este utilitário é otimizado para Apple Silicon (arm64). Detectado: ${ARCH:-?}. Abortando por segurança."
      exit 1
    fi

    OUTDIR="$HOME/Desktop/MacTech_Report_$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$OUTDIR"
    REPORT="$OUTDIR/report.txt"
    TOPP="$OUTDIR/top_processes.txt"
    PSP="$OUTDIR/ps_sorted.txt"
    MEM="$OUTDIR/memory.txt"
    DISK="$OUTDIR/disk.txt"
    SPOT="$OUTDIR/spotlight.txt"
    POWER="$OUTDIR/powermetrics.txt"
    LOGS="$OUTDIR/logsample.txt"
    NET="$OUTDIR/network.txt"
    ADOBE_LOG="$OUTDIR/adobe_actions.txt"

    # Cabeçalho
    banner "MacTech — Diagnóstico Inicial" | tee -a "$REPORT"
    {
      echo "Modelo/Chip : $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Apple Silicon")"
      echo "Arquitetura : $ARCH"
      echo "macOS       : $OSVER"
      echo "Hostname    : $(scutil --get ComputerName 2>/dev/null || hostname)"
      echo "Usuário     : $USER"
    } | tee -a "$REPORT"

    # CPU / Load
    banner "CPU / Carga do Sistema" | tee -a "$REPORT"
    {
      echo "Uptime / Load averages:"
      uptime || true
      echo
      echo "Top 20 processos por CPU:"
      ps -Ao pid,comm,%cpu,%mem | sort -k3 -nr | head -n 20 | tee "$PSP"
      echo
      echo "Amostra 'top' (1 iteração ordenado por CPU):"
      top -l 1 -o cpu -n 20 | tee "$TOPP"
    } >> "$REPORT" 2>&1

    # Memória / Swap
    banner "Memória / Swap" | tee -a "$REPORT"
    {
      echo "vm_stat:"
      vm_stat || true
      echo
      echo "memory_pressure (resumo):"
      memory_pressure -Q || true
      echo
      echo "Swap usage:"
      sysctl vm.swapusage || true
    } | tee "$MEM" >> "$REPORT" 2>&1

    # Disco
    banner "Disco / SSD" | tee -a "$REPORT"
    {
      echo "df -Hl /:"
      df -Hl / || true
      echo
      echo "diskutil info /:"
      diskutil info / || true
    } | tee "$DISK" >> "$REPORT" 2>&1

    # Spotlight
    banner "Spotlight" | tee -a "$REPORT"
    {
      mdutil -s / || true
    } | tee "$SPOT" >> "$REPORT" 2>&1

    # Powermetrics (coleta automática se disponível; pedirá senha se necessário)
    banner "Powermetrics (CPU/GPU/Thermal)" | tee -a "$REPORT"
    if command -v powermetrics >/dev/null 2>&1; then
      log "Coletando 10s de métricas (pode solicitar senha de administrador)."
      (sudo powermetrics --samplers cpu_power,gpu_power,thermal --show-all --timeout 10000 2>&1 | tee "$POWER") >> "$REPORT" || true
    else
      echo "powermetrics não disponível." | tee -a "$REPORT"
    fi

    # Logs (30 min) — sumarização
    banner "Logs (últimos 30 minutos — erros/avisos agregados)" | tee -a "$REPORT"
    {
      if command -v log >/dev/null 2>&1; then
        log show --style syslog --last 30m --predicate '(eventMessage CONTAINS[c] "error") OR (eventMessage CONTAINS[c] "fail") OR (messageType == error)' 2>/dev/null \
          | awk '{print $5}' | sort | uniq -c | sort -nr | head -n 30
      else
        echo "'log' não disponível."
      fi
    } | tee "$LOGS" >> "$REPORT"

    # Rede
    banner "Rede (TCP estabelecido — amostra)" | tee -a "$REPORT"
    {
      lsof -iTCP -sTCP:ESTABLISHED -n -P 2>/dev/null | awk 'NR==1 || /ESTABLISHED/' | head -n 50
    } | tee "$NET" >> "$REPORT"

    # Otimizações automáticas (não interativas)
    banner "Otimizações Automáticas" | tee -a "$REPORT"

    # 1) Encerrar Adobe e limpar caches/logs Adobe
    ADOBE_PIDS="$(pgrep -fil 'Adobe' || true)"
    if [[ -n "$ADOBE_PIDS" ]]; then
      {
        echo "Encerrando processos Adobe e limpando caches/logs do usuário."
        sudo pkill -f "Adobe" || true
        sleep 2
        rm -rf "$HOME/Library/Logs/Adobe"* 2>/dev/null || true
        rm -rf "$HOME/Library/Application Support/Adobe/Common/Media Cache Files/"* 2>/dev/null || true
        rm -rf "$HOME/Library/Caches/Adobe"* 2>/dev/null || true
        echo "Adobe cleanup concluído."
      } | tee -a "$ADOBE_LOG" >> "$REPORT"
    else
      echo "Adobe: nenhum processo detectado." | tee -a "$REPORT"
    fi

    # 2) Limpeza segura de caches do usuário (exclui Safari/WebKit por padrão)
    {
      echo "Limpando caches temporários do usuário (excluindo Safari/WebKit)."
      find "$HOME/Library/Caches" -mindepth 1 -maxdepth 1 \
        ! -name "com.apple.Safari" \
        ! -name "com.apple.WebKit" \
        -exec rm -rf {} + 2>/dev/null
      echo "Caches gerais do usuário limpas."
    } >> "$REPORT"

    # 3) Spotlight reindex se mds/mdworker estiverem ocupados (detecção heurística)
    if grep -qiE "(mds|mdworker)" "$TOPP" 2>/dev/null; then
      {
        echo "Spotlight aparenta estar ocupado — forçando reindexação de /."
        sudo mdutil -E / || true
      } >> "$REPORT"
    else
      echo "Spotlight: reindex não necessário." >> "$REPORT"
    fi

    # 4) DNS/Directory cache flush
    {
      echo "Renovando caches de DNS/Directory."
      sudo dscacheutil -flushcache 2>/dev/null || true
      sudo killall -HUP mDNSResponder 2>/dev/null || true
      echo "DNS/Directory renovados."
    } >> "$REPORT"

    # Resumo automático
    banner "Resumo Automático" | tee -a "$REPORT"
    LA="$(uptime | awk -F'load averages?: ' '{print $2}' | awk -F', ' '{print $1}' | tr -d ',' || echo 0)"
    printf "Load Average (1min): %s\n" "${LA:-0}" | tee -a "$REPORT"
    if [[ "$(printf "%.0f" "${LA:-0}")" -ge 8 ]]; then
      echo "• Carga elevada. Verifique top_processes.txt e ps_sorted.txt para vilões (Adobe, indexadores, browsers)." | tee -a "$REPORT"
    else
      echo "• Carga sob controle." | tee -a "$REPORT"
    fi

    if command -v memory_pressure >/dev/null 2>&1; then
      MP="$(memory_pressure -Q 2>/dev/null | grep -i 'System-wide memory free percentage' | tail -n1 | awk -F': ' '{print $2}')"
      [[ -n "${MP:-}" ]] && echo "Memória livre (memory_pressure): $MP" | tee -a "$REPORT"
    fi

    echo "Relatórios auxiliares:" | tee -a "$REPORT"
    {
      echo " - $TOPP"
      echo " - $PSP"
      echo " - $MEM"
      echo " - $DISK"
      echo " - $SPOT"
      echo " - $POWER"
      echo " - $LOGS"
      echo " - $NET"
      echo " - $ADOBE_LOG"
    } >> "$REPORT"

    log "Concluído. Relatório em: $REPORT"
    # Abrir automaticamente no TextEdit
    open -a TextEdit "$REPORT" 2>/dev/null || true

    exit 0
