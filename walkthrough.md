# Walkthrough: Validação Final & Evidências — Codex CLI + CC Switch & FreeLLMAPI
**Protocolo:** PREVC (Fase 4: Validação & Confirmação)  
**Data:** 29/10/2026

---

## 1. Evidência do Teste de Integridade (CC Switch)

O comando de diagnóstico de integridade (`ccs.py health`) confirmou que o provedor `FreeLLMAPI` está ativo, saudável e respondendo com baixa latência:

```text
[CODEX] FreeLLMAPI: ✓ healthy
[CLAUDE] FreeLLMAPI: ✓ healthy
[CLAUDE-DESKTOP] FreeLLMAPI: ✓ healthy
[GROKBUILD] FreeLLMAPI: ✓ healthy
```

### Provedores Ativos no Sistema:
```text
[CLAUDE] FreeLLMAPI   base=http://127.0.0.1:31415
[CODEX] FreeLLMAPI    base=http://127.0.0.1:31415/v1
[GEMINI] FreeLLMAPI   base=http://127.0.0.1:31415
```

---

## 2. Evidência da Chamada Atômica via Codex CLI

Foi disparada uma chamada não interativa sintética com o Codex CLI em modo estritamente isolado (`--ephemeral -s read-only`):

```bash
codex exec --ephemeral -s read-only "Reply with the single word: OK_FROM_CODEX"
```

### Saída Registrada do Terminal:
```text
OpenAI Codex v0.165.0
--------
workdir: /Users/danilonovais/MacOS-Use
model: auto
provider: custom
approval: never
sandbox: read-only
reasoning effort: medium
reasoning summaries: none
session id: 01a188a4-11dd-7aa0-9531-50542dab0e1d
--------
user
Reply with the single word: OK_FROM_CODEX

codex
OK_FROM_CODEX

tokens used: 20,988
```

> **Resultado:** O Codex CLI conectou-se com sucesso ao FreeLLMAPI Desktop (`127.0.0.1:31415/v1`), consumiu a wire API de completions (`responses`) e obteve a resposta sintética esperada sem falhas ou desvios de rota.

---

## 3. Integridade do Ambiente macOS

- **Binários & PATH:** Sem warnings de concorrência ou conflitos de PATH. O binário canônico `/Users/danilonovais/.local/bin/codex` é respeitado.
- **Governança de Shell:** Nenhum arquivo de inicialização de shell (`~/.zshrc` ou `~/.zprofile`) foi poluído com chaves hardcoded ou variáveis conflitantes.
- **Segurança de Arquivos:** `~/.codex/config.toml` e `~/.codex/auth.json` mantêm permissões estritas `0600` (leitura e escrita apenas pelo proprietário).

---

## 4. Backups de Segurança Registrados

Backups com timestamp foram gravados em:
1. `~/.codex/config.toml.bak.20261029_140753`
2. `~/.codex/auth.json.bak.20261029_140753`
3. Cópia arquivada em `./backup-variaveis/20261029_140753/`

---

## 5. Procedimento Operacional de Troca Rápida (Switch)

Para alternar instantaneamente entre o modo FreeLLMAPI e o provedor nativo/oficial da OpenAI no Codex:

### Para retornar ao provedor oficial da OpenAI:
```bash
python3 /Users/danilonovais/MacOS-Use/.agents/skills/cc-switch/scripts/ccs.py switch "OpenAI Official" --app codex
```

### Para reativar o FreeLLMAPI:
```bash
python3 /Users/danilonovais/MacOS-Use/.agents/skills/cc-switch/scripts/ccs.py switch FreeLLMAPI --app codex
```
