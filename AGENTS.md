# AGENTS.md

## Integração Mother Brain (Canônica)
- **Mother Brain Root:** `/Users/danilonovais/OBSIDIAN`
- **Canonical Entrypoint:** `02-projects/macos-use/project.md`
- **Adapter Configuration:** `.agents/mother-brain/project.yaml`
- **Hierarquia:** Mother Brain = conhecimento durável; Repositório Local = código, testes e instruções locais.
- **Fluxo de Promoção:** `OBSERVED -> CANDIDATE -> VALIDATED -> HUMAN_AUTHORIZED -> CANONICAL`.

## Regras de Engajamento para Automação macOS

Este repositório gerencia o estado e a governança de um ambiente macOS (Apple Silicon - M1 Max).

1. **Análise de Arquivos Existentes:** Nunca crie novos scripts de automação sem antes analisar o diretório `.agents/skills/macos-diagnostics/scripts/`. O código já existe; sua função é analisá-lo e documentar a execução.
2. **Execução Segura:** Comandos destrutivos ou modificações profundas (`defaults write`, `sudo`, manipulação de APFS) devem SEMPRE ser executados via `--dry-run` primeiro e necessitam de aprovação explícita.
3. **Sincronização de Estado:** Após a execução de qualquer rotina de atualização (Homebrew, Mac App Store, macOS), o status da máquina deve ser sincronizado com o banco de dados do projeto.
4. **Isolamento de Contexto:** Regras operacionais ficam em `.agents/`. Documentação de infraestrutura em `.context/`.
5. **Governança de Dados & Segredos:** Nunca expor chaves de API (`SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`) ou credenciais nos scripts shell ou commits. Injete-as estritamente via variáveis de ambiente do SO.

---

## Mapeamento de Slash Commands & Workflows (.agents/workflows/)

| Slash Command | Workflow File | Propósito & Descrição |
| :--- | :--- | :--- |
| `/macos-sync-db` | `.agents/workflows/macos-sync-db.md` | Audita o sistema local (M1 Max), verifica preferências de defaults e sincroniza métricas no banco de dados. |
| `/notebooklm-guided-research` | `.agents/workflows/notebooklm-guided-research.md` | Realiza pesquisas grounded e implementações orientadas a cadernos de conhecimento do NotebookLM. |
| `/agents-orquestrator` | `.agents/workflows/agents-orquestrator.md` | Alinha e coordena o Swarm de Agentes no ecossistema NANO-VEO3-API. |
| `/workflow-orchestrator` | `.agents/workflows/workflow-orchestrator.md` | Orquestração avançada de workflows complexos, agendamentos e dependências de tarefas. |
| `/workflows-refresh` | `.agents/workflows/workflows-refresh.md` | Auditoria, sincronização e alinhamento de todos os workflows do diretório `.agents/workflows/`. |

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

When the user types `/graphify`, invoke the `skill` tool with `skill: "graphify"` before doing anything else.

Rules:

- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- Dirty graphify-out/ files are expected after hooks or incremental updates; dirty graph files are not a reason to skip graphify. Only skip graphify if the task is about stale or incorrect graph output, or the user explicitly says not to use it.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).

## Context Navigation (Wiki-Brain)

You have access to a personal wiki at `/Users/danilonovais/OBSIDIAN/DevMemory`. This is the user's
compounding knowledge base. Use it as your primary context source.

When you need to understand the codebase, docs, past work, or any stored
knowledge:

1. **ALWAYS query the knowledge graph first:** `graphify query "your question"`
   (run from `/Users/danilonovais/OBSIDIAN/DevMemory`).
2. **Use `/Users/danilonovais/OBSIDIAN/DevMemory/wiki/index.md`** as your navigation entrypoint for
   browsing the wiki structure.
3. **Use `/Users/danilonovais/OBSIDIAN/DevMemory/graphify-out/wiki/index.md`** if it exists — it's
   the auto-generated Graphify wiki index.
4. **Only read raw files in `/Users/danilonovais/OBSIDIAN/DevMemory/raw/`** if the user explicitly
   says "read the raw file" or the graph query doesn't have the answer.

## Wiki-Brain Session Rules

**Ingesting sources.** When the user drops a file into `/Users/danilonovais/OBSIDIAN/DevMemory/raw/`
and asks you to ingest it, follow `/wiki-brain ingest` — read the source,
summarize, create/update wiki pages, cross-link aggressively, update
`wiki/index.md`, append to `log.md`.

**Every session must end with a log entry.** Before ending a session, append
one line to `/Users/danilonovais/OBSIDIAN/DevMemory/log.md` in this exact format:

```
## [YYYY-MM-DD HH:MM] session | <3-8 word session title>
Touched: <comma-separated wiki pages, or "none">
```

**If the session produced durable knowledge** (decisions made, things learned,
project state changed, problems solved) — update or create relevant wiki
pages with that knowledge before ending. Cross-link with `[[Page Name]]`.
Update `wiki/index.md`.

**If the session was trivial** (one-off fix, routine task, exploratory
chatter) — skip the wiki update. Just append the log line.

**Never modify files in `raw/`.** Sources are immutable.
**Claude owns `wiki/` entirely.** Update it, don't ask permission for each
page — just report what changed.
**Always update `wiki/index.md`** when you create or rename a wiki page.
**Cross-link aggressively.** `[[Page Name]]` Obsidian syntax. A page with
no inbound links is a dead-end.

## Wiki-Brain Commands Available

- `/wiki-brain` — status menu
- `/wiki-brain ingest <file>` — ingest a source
- `/wiki-brain query "<q>"` — query the graph + wiki
- `/wiki-brain lint` — health-check the wiki
- `/wiki-brain rebuild` — force a Graphify rebuild
- `/wiki-brain doctor` — verify install
- `/recall` — show last 5 activities + read linked pages

# Mac Performance Diagnostics

## Your Role

You run diagnostic commands on Mac systems, analyze the results, explain findings in plain English, and provide clear resolution steps for common performance issues.

## Quick Health Check

```markdown
## System Health Report

### Overview
| Metric | Status | Details |
|--------|--------|---------|
| Disk Space | 🟢 Good | 45% used (234GB free) |
| Memory | 🟡 Warning | 87% used, swap active |
| CPU | 🟢 Good | 15% average load |
| Battery | 🟢 Good | 94% health, 234 cycles |

### Immediate Actions Needed
1. [Action 1 if any]
2. [Action 2 if any]

### Detailed Analysis Below
```

## Diagnostic Commands

### Disk Space

```bash
## What's Using Space

# Quick overview
df -h /

# Large files (>100MB)
find ~ -size +100M -type f 2>/dev/null

# Directory sizes
du -sh ~/Library/Caches/*
du -sh ~/Library/Application\ Support/*
du -sh ~/.Trash

# Docker (if installed)
docker system df
```

**What to Look For:**

- /System/Volumes/Data at >80% = needs attention
- Large cache folders = safe to clean
- Old iOS backups = often forgotten

### Memory Usage

```bash
## Memory Analysis

# Overview
vm_stat

# Top memory consumers
top -l 1 -o mem -n 10

# Memory pressure
memory_pressure

# Swap usage
sysctl vm.swapusage
```

**What to Look For:**

- Pages active + wired > 80% of total = heavy usage
- High swap used = need more RAM or close apps
- Memory pressure "critical" = immediate action needed

### CPU/Process

```bash
## CPU Analysis

# Top CPU consumers
top -l 1 -o cpu -n 10

# Background processes
ps aux | head -20

# System load average
uptime
```

**What to Look For:**

- Load average > number of cores = overloaded
- Single process at 100%+ = runaway process
- kernel_task high = thermal throttling

### Battery (MacBooks)

```bash
## Battery Health

# Full battery info
system_profiler SPPowerDataType

# Battery health percentage
ioreg -l -w0 | grep -i capacity

# Power-hungry apps
pmset -g thermlog
```

## Common Issues & Fixes

### Slow Performance

```markdown
## Diagnosis: Slow Mac

### Quick Checks
1. **Restart** - When was last restart?
2. **Disk space** - Is disk >90% full?
3. **Memory** - What's consuming RAM?
4. **Startup items** - Too many launch apps?

### Fixes by Cause

**Low disk space:**
- Empty Trash
- Clear Downloads folder
- Remove old iOS backups: `~/Library/Application Support/MobileSync/Backup`
- Clear caches: `~/Library/Caches`

**High memory usage:**
- Close unused apps
- Restart browser (clears memory)
- Check for memory leaks: `top -o mem`

**High CPU:**
- Identify process: `top -o cpu`
- Check Activity Monitor for runaway processes
- Consider force-quitting stuck apps

**Startup bloat:**
- System Preferences → Users → Login Items
- Remove unnecessary startup apps
```

### Storage Full

```markdown
## Diagnosis: Disk Full

### Top Space Consumers (Typical)
| Location | Common Size | Safe to Clear |
|----------|-------------|---------------|
| ~/Library/Caches | 5-50GB | Yes |
| ~/Library/Application Support | 10-100GB | Check first |
| .Trash | 0-50GB | Yes |
| iOS Backups | 10-100GB | Old ones yes |
| Xcode (if installed) | 20-100GB | DeviceSupport |

### Safe Cleanup Commands
```bash
# Empty Trash
rm -rf ~/.Trash/*

# Clear user caches (regenerate on use)
rm -rf ~/Library/Caches/*

# Clear system logs (old ones)
sudo rm -rf /private/var/log/*

# Clear Xcode device support (old versions)
rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*
```

### Use Built-in Tools

1. Apple Menu → About This Mac → Storage → Manage
2. Review Recommendations
3. Optimize storage settings

```

### Overheating
```markdown
## Diagnosis: Overheating/Fan Noise

### Common Causes
1. **Runaway process** - Check Activity Monitor CPU tab
2. **Poor ventilation** - Physical obstruction
3. **Old thermal paste** - Older Macs (5+ years)
4. **Chrome/browser** - Often the culprit

### Diagnostic
```bash
# Check thermal status
pmset -g thermlog

# CPU-intensive processes
top -l 1 -o cpu -n 5
```

### Fixes

- Kill runaway process
- Close Chrome tabs (or switch to Safari)
- Reset SMC (Intel Macs)
- Clean vents with compressed air
- Use on hard surface, not fabric

```

## Health Report Template

```markdown
## Mac Health Report: [Date]

### System Info
- Model: [Mac model]
- macOS: [Version]
- Storage: [Total] / [Used] / [Free]
- RAM: [Total] / [Used]
- Uptime: [Days since restart]

### Performance Score: [X/10]

### Issues Found
1. **[Issue]** - [Severity]
   - Finding: [What's wrong]
   - Impact: [How it affects you]
   - Fix: [What to do]

### Recommendations
- [Priority 1 action]
- [Priority 2 action]

### All Clear
- ✅ [Area that's healthy]
- ✅ [Area that's healthy]
```

## Instructions

1. Describe the performance issue
2. I'll suggest diagnostic commands
3. Run commands and share output
4. Get plain-English explanation
5. Follow resolution steps

## Commands

```
"Run a quick health check"
"Why is my Mac slow?"
"What's using all my disk space?"
"Diagnose overheating issue"
"Check memory usage"
"Help me free up space"
```

## When to Seek Help

- Hardware diagnostics fail
- Kernel panics / random shutdowns
- Physical damage suspected
- Under AppleCare - use it!
- Data recovery needed
