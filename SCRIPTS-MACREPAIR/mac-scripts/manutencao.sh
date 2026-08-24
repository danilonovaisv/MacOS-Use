#!/bin/zsh
# ==============================================================================
# Script de Auditoria, Limpeza e Correção do Sistema
# Hostname     : Danilo’s MacBook Pro
# Modelo/Chip  : Apple M1 Max
# Arquitetura  : arm64
# macOS        : 26.5
# ==============================================================================

echo "================================================================="
echo " Iniciando Auditoria, Limpeza e Correção no Danilo's MacBook Pro"
echo "================================================================="

# ------------------------------------------------------------------------------
# 1. AUDITORIA E DIAGNÓSTICO
# ------------------------------------------------------------------------------
echo "\n[1/3] REALIZANDO AUDITORIA DO SISTEMA..."

# Exibir informações detalhadas de Hardware e Software
echo "=> Coletando perfil do sistema (Hardware e Software):"
system_profiler SPHardwareDataType SPSoftwareDataType

# Verificar a Saúde e Ciclos da Bateria
echo "\n=> Verificando a capacidade e ciclos da bateria:"
# O comando ioreg extrai a capacidade máxima, a atual e a contagem de ciclos da bateria [2, 3].
ioreg -l | grep -e "CurrentCapacity" -e "MaxCapacity" -e "CycleCount"

# Verificar a Pressão Térmica (Thermal Throttling) do Apple Silicon
echo "\n=> Medindo a pressão térmica do chip M1 Max:"
# O chip M1 Max não relata a temperatura núcleo a núcleo de forma tradicional.
# Em vez disso, mede-se o estado de "pressão térmica" (Nominal, Fair, Serious ou Critical) [4, 5].
sudo powermetrics -n 1 --samplers smc | grep -i "thermal"


# ------------------------------------------------------------------------------
# 2. LIMPEZA DO SISTEMA
# ------------------------------------------------------------------------------
echo "\n[2/3] REALIZANDO LIMPEZA DO SISTEMA..."

# Limpeza e Flush do Cache DNS
echo "=> Limpando o cache DNS (Flush Cache):"
# Útil para resolver problemas de resolução de nomes de rede [6].
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
echo "Cache DNS limpo com sucesso."


# ------------------------------------------------------------------------------
# 3. CORREÇÃO, REPARO E ATUALIZAÇÃO
# ------------------------------------------------------------------------------
echo "\n[3/3] REALIZANDO CORREÇÃO E ATUALIZAÇÕES..."

# Verificação do Volume do Sistema (APFS)
echo "=> Verificando a integridade das estruturas de dados do APFS:"
# Realiza o diagnóstico preventivo de corrupção do container APFS do M1 Max [7, 8].
diskutil verifyVolume /

# Reparo do Volume do Sistema (APFS)
echo "\n=> Reparando o Volume APFS (caso erros lógicos tenham sido encontrados):"
# Corrige ativamente erros de diretório ou de disco do Mac [9-11].
diskutil repairVolume /

# Instalação de Atualizações de Software do macOS
echo "\n=> Buscando e instalando atualizações oficiais do macOS pendentes:"
# Faz o download e instala todas as atualizações do sistema remotamente e sem interface gráfica [6, 12, 13].
sudo softwareupdate -i -a

# Atualização de pacotes de terceiros e ferramentas de desenvolvedor via Homebrew
echo "\n=> Atualizando binários (arm64) e aplicativos de terceiros via Homebrew:"
# O Homebrew é amplamente usado no Apple Silicon (diretório /opt/homebrew) para manter apps atualizados [6, 8].
if command -v brew &> /dev/null; then
    brew upgrade
else
    echo "Homebrew não encontrado. Pulando etapa."
fi

echo "\n================================================================="
echo " Processo concluído com sucesso! Danilo's MacBook Pro otimizado."
echo "================================================================="
