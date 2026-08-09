---
name: macos-diagnostics
description: Ferramentas de terminal e scripts para auditoria de hardware, sistema operacional e métricas de desempenho no macOS Apple Silicon.
---

# Skill: macos-diagnostics

## Visão Geral
Esta skill fornece ferramentas estruturadas para inspecionar e auditar a infraestrutura local em ambiente macOS (Apple Silicon M1/M2/M3).

## Ferramentas & Scripts Disponíveis
- `scripts/system_audit.sh`: Script Bash responsável por coletar informações de CPU, memória, estado da bateria, versão do macOS, arquitetura e armazenamento em formato JSON.

## Diretrizes de Execução
1. Executar `system_audit.sh` via terminal utilizando `bash .agents/skills/macos-diagnostics/scripts/system_audit.sh`.
2. Validar se ferramentas utilitárias (`jq`, `sw_vers`, `system_profiler`, `df`, `pmset`) estão disponíveis.
3. Repassar a saída JSON sanitizada para os pipelines de sincronização no banco de dados.
