# AGENTS.md

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
