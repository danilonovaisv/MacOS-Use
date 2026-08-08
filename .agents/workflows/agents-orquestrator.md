---
description: Workflow para auditar e alinhar a orquestração do Swarm de Agentes no NANO-VEO3-API (Next.js 15, @google/genai e Veo 3).
---

# Workflow: /agents-orquestrator — Orquestração do Swarm NANO-VEO3-API

> **Slash Command:** `/orchestrate` ou `/agents-orquestrator`  
> **Propósito:** Auditar, alinhar e validar a comunicação e responsabilidade dos agentes do ecossistema NANO-VEO3-API.  
> **Agente Responsável:** `@api-orchestrator`

---

## FASE 0: Leitura dos Contratos Globais

1. Leia `AGENTS.md` — confirme as personas e regras inegociáveis.
2. Leia `.context/project-context.md` — mapa de rotas REST e integrações do Veo 3.
3. Leia `.context/conventions.md` — convenções de TypeScript, Zod e NextResponse.

```bash
cat AGENTS.md
```

**Swarm NANO-VEO3-API:**

| Persona | Arquivo | Responsabilidade Principal |
| :--- | :--- | :--- |
| `@api-orchestrator` | `.agents/agents/api-orchestrator.md` | Roteamento REST, sanitização de inputs e tratamento de respostas HTTP |
| `@veo-integration-specialist` | `.agents/agents/veo-integration-specialist.md` | Chamadas ao SDK `@google/genai`, Veo 3 e polling de operações |
| `@frontend-specialist` | `.agents/agents/frontend-specialist.md` | Interface React 19, Tailwind CSS v4 e player de vídeo |
| `@ai-video-engineer` | `.agents/agents/ai-video-engineer.md` | Engenharia de prompt cinematográfico para Veo 3 e Imagen |
| `@prompt-engineer` | `.agents/agents/prompt-engineer.md` | Aplicação de frameworks SCALIST/SCHEMA e visual prompts |
| `@notebooklm-knowledge-sentinel` | `.agents/agents/notebooklm-knowledge-sentinel.md` | Pesquisa grounded nos cadernos de conhecimento Veo 3.1 & Nano Banana |

---

## FASE 1: Verificação de Contratos, Biblioteca & Testes

1. Executar a checagem da biblioteca de conhecimento NotebookLM:
```bash
python .agents/skills/notebooklm/scripts/run.py notebook_manager.py list
```

2. Executar a checagem determinística do payload do Veo 3:
```bash
npx tsx .agents/skills/veo3-api-integration/scripts/test_payload.ts
```

2. Executar a verificação de compilação e linter:
```bash
npm run lint
npx tsc --noEmit
```

---

## FASE 2: Fechamento

1. Se novas personas ou rotas foram adicionadas, atualize `AGENTS.md` e `.context/project-context.md`.
2. Persista aprendizados em `.agents/data/memory.json`.
