---
description: Workflow para auditoria e refatoração de todos os workflows em .agents/workflows/ garantindo alinhamento com a stack NANO-VEO3-API (Next.js 15, TypeScript, @google/genai, Veo 3 API).
---

# Workflow: /workflows-refresh — Atualização e Sincronização de Workflows

> **Slash Command:** `/workflows-refresh`  
> **Propósito:** Auditar e manter todos os workflows do diretório `.agents/workflows/` alinhados com a stack NANO-VEO3-API.

---

## Passo 1: Inspecionar Todos os Workflows em `.agents/workflows/`

1. Listar os arquivos `.md` presentes no diretório.
2. Confirmar se as instruções utilizam `npm` (não bun ou yarn), Next.js 15, Zod Schemas e o SDK `@google/genai`.

## Passo 2: Executar Verificação de Qualidade & Biblioteca

```bash
python .agents/skills/notebooklm/scripts/notebook_manager.py list
npm run lint
npx tsc --noEmit
npx tsx .agents/skills/veo3-api-integration/scripts/test_payload.ts
```

## Passo 3: Atualizar Referências & Grounding

1. Garantir que todas as slash commands estejam mapeadas em `AGENTS.md`.
2. Confirmar que workflows de mídia (`generate-media.md`, `storyboard.md`, `write-script.md`) incluem etapas de pesquisa no banco de conhecimento do NotebookLM via `@notebooklm-knowledge-sentinel`.
