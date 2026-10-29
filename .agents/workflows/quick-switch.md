---
description: Troca rápida e automatizada de provedores entre FreeLLMAPI e APIs oficiais para Codex CLI, Claude Code e Gemini CLI via CC Switch.
---

# Workflow: /quick-switch (Procedimento de Troca Rápida de Provedores)

> **Slash Command:** `/quick-switch` ou `/switch-provider`  
> **Propósito:** Alternar instantaneamente o roteamento dos agentes locais entre o proxy agregador gratuito (**FreeLLMAPI**) e os provedores oficiais de produção (**OpenAI, Anthropic e Google**).  
> **Agente Responsável:** `@api-orchestrator` / `@macos-sysadmin`  
> **Script Automatizado:** `./scripts/switch-provider.sh`

---

## 1. Verificação de Estado Atual

Antes de qualquer troca, consulte os provedores atualmente ativos no sistema:

```bash
./scripts/switch-provider.sh status
```

Ou diretamente via Python:
```bash
python3 .agents/skills/cc-switch/scripts/ccs.py current
```

---

## 2. Alternar para Modo Prototipagem Gratuita (FreeLLMAPI)

Redireciona as requisições para o proxy local agregador de modelos gratuitos (`http://127.0.0.1:31415`), preservando cotas de produção.

### Alternar todos os agentes de uma vez:
```bash
./scripts/switch-provider.sh freellmapi all
```

### Alternar agente específico:
```bash
./scripts/switch-provider.sh freellmapi codex    # Apenas Codex CLI
./scripts/switch-provider.sh freellmapi claude   # Apenas Claude Code
./scripts/switch-provider.sh freellmapi gemini   # Apenas Gemini CLI
```

---

## 3. Retornar para Modo Produção (APIs Oficiais Pagas)

Restaura o roteamento para as chaves e endpoints oficiais de produção (`api.openai.com`, `api.anthropic.com` e `generativelanguage.googleapis.com`).

### Alternar todos os agentes de volta:
```bash
./scripts/switch-provider.sh official all
```

### Alternar agente específico:
```bash
./scripts/switch-provider.sh official codex     # Restaura OpenAI Official
./scripts/switch-provider.sh official claude    # Restaura ClaudeAPI
./scripts/switch-provider.sh official gemini    # Restaura Google Official
```

---

## 4. Validação Pós-Troca & Health Check

Execute a checagem de saúde e latência dos provedores ativos:

```bash
python3 .agents/skills/cc-switch/scripts/ccs.py health
```

> **Nota:** Se o terminal com o agente já estiver aberto durante a troca, reinicie a sessão do CLI para que as novas variáveis de ambiente e arquivos de configuração sejam recarregados.

