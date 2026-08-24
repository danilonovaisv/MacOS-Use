---
description: Workflow de Auditoria Interativa e Correção no macOS
---

---

description: Workflow de Auditoria Interativa e Correção no macOS
---

1. **Contexto**: Consultar o MCP `context7` para obter padrões vigentes de diagnósticos do macOS.
2. **Auditoria Integrada**:
   - Invoke `@macos-sysadmin`, `@electron-pro` e `@agent-skills-spec` com a skill `macos-diagnostics`, `macos-development` e `macos-setup` para coletar métricas de disco, RAM e energia.
   - Invoke `@swift-expert` com a skill `systematic-debugging` para analisar falhas via Unified Logging System (`log show`).
3. **Sintetizar Artefato**:
   - Gerar `artifacts/plan.md` combinando relatórios com as skills `macos-cleaner` e `macos-setup`.
4. **Aprovação Humana**: Pausar e solicitar confirmação explícita do usuário sobre as ações propostas.
5. **Execução Condicional**:
   - Executar alterações somente após resposta positiva do usuário.
   - Invoke `@electron-pro` para exibir o status final no IDE.
