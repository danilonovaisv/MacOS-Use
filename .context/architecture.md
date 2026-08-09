# Arquitetura do Sistema: macOS (Apple Silicon M1 Max) Agentic Framework

## Visão Geral

Este ecossistema opera sob o modelo **Local-First Agentic Governance**, no qual agentes autônomos gerenciam, auditam e registram as configurações de um ambiente macOS (M1 Max, Apple Silicon).

## Componentes Arquiteturais

```
+-----------------------------------------------------------------------+
|                             AGENT SQUAD                               |
|                         (@macos-sysadmin)                             |
+-----------------------------------+-----------------------------------+
                                    |
                                    v
+-----------------------------------+-----------------------------------+
|                        LOCAL EXECUTION ENGINE                         |
|   - .agents/skills/macos-diagnostics/scripts/system_audit.sh         |
|   - defaults read / defaults write                                    |
+-----------------------------------+-----------------------------------+
                                    |
                                    v
+-----------------------------------+-----------------------------------+
|                         CMDB & PERSISTENCE                            |
|   - src/db/schema.ts (Type definitions & schemas)                    |
|   - src/db/sync.ts (Supabase / Local DB Payload Ingestion)            |
+-----------------------------------------------------------------------+
```

## Segregação de Responsabilidades

- **`.agents/`**: Contém regras operacionais, personas, skills e workflows. Nenhuma documentação de negócio deve ficar neste diretório.
- **`.context/`**: Contém a documentação técnica do sistema, esquemas de defaults desejados (`macos-defaults.json`) e diagramas de arquitetura.
- **`src/db/`**: Lógica de integração e persistência com o banco de dados (CMDB).
