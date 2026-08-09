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
