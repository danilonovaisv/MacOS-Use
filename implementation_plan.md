# Plano de Implementação: Codex CLI com CC Switch & FreeLLMAPI
**Protocolo Operacional:** PREVC (Planning, Review, Execution, Validation, Confirmation)  
**Ambiente:** macOS Darwin (Apple Silicon - M1 Max) | Google Antigravity Supervised Autonomous Mode  
**Data:** 29/10/2026

---

## 1. Mapeamento do Estado Atual

### 1.1. Binários e Precedência do Codex CLI
- **Binário Ativo:** `/Users/danilonovais/.local/bin/codex`
- **Precedência de Resolução (`which -a` / `type -a`):**
  1. `/Users/danilonovais/.local/bin/codex` (Link prioritário no PATH)
  2. Versão detectada: `codex-cli 0.165.0`
- **Árvore de Configuração e Estado:**
  - Diretório raiz: `/Users/danilonovais/.codex/`
  - Arquivo de configuração principal: `/Users/danilonovais/.codex/config.toml` (Permissões: 0600)
  - Arquivo de credenciais: `/Users/danilonovais/.codex/auth.json` (Permissões: 0600)
  - Estado global e histórico: `/Users/danilonovais/.codex/.codex-global-state.json`

### 1.2. Mapeamento de Portas e Proxies em Execução
| Serviço | PID | Porta / Interface | Status / Função |
| :--- | :--- | :--- | :--- |
| **FreeLLMAPI App** | `5798` | `127.0.0.1:31415` | Proxy desktop agregador de provedores gratuitos (284 modelos) |
| **CC Switch Daemon** | `1723` | `127.0.0.1:15721` | Gerenciador de providers e roteador central de agentes |
| **Docker (Internal)** | `1048` | `127.0.0.1:8000` | Serviço conteinerizado local |
| **Node.js (Server)** | `80847` | `*:3001` | Instância legada em porta 3001 |

### 1.3. Estado das Configurações no Codex (`config.toml`)
- Configuração ativa no topo de `config.toml`:
  ```toml
  model = "auto"
  model_provider = "custom"
  model_context_window = 1048576
  model_auto_compact_token_limit = 943718
  tool_output_token_limit = 20000
  disable_response_storage = true
  ```
- Provedores definidos em `[model_providers]`:
  - `[model_providers.custom]`: Aponta para `http://127.0.0.1:15721/v1` (Proxy CC Switch) com `experimental_bearer_token = "PROXY_MANAGED"`, `wire_api = "responses"`.
  - `[model_providers.freellmapi]`: Aponta diretamente para `http://127.0.0.1:31415/v1` com `wire_api = "responses"`, lendo `FREELLMAPI_API_KEY`.

### 1.4. Estado no CC Switch
- O provider `FreeLLMAPI` já está catalogado e ativo (`★`) no CC Switch para a aplicação `codex`:
  - ID: `aac4685e-3362-4bd4-8715-2cbf52dbf671`
  - URL mapeada: `http://127.0.0.1:31415/v1`
  - Auth mapeada: Chave Bearer `freellmapi-...` injetada em `auth.json`
  - Health check: `✓ healthy`

---

## 2. Arquitetura Alvo

```
┌────────────────────────┐
│       Codex CLI        │ (codex-cli v0.165.0)
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│       CC Switch        │ (Daemon em 127.0.0.1:15721)
│   (Provider Manager)   │ Configura dinamicamente ~/.codex/config.toml
└───────────┬────────────┘ e ~/.codex/auth.json
            │
            ▼
┌────────────────────────┐
│     FreeLLMAPI App     │ (App Desktop em 127.0.0.1:31415/v1)
│  (Multi-Tier Gateway)  │ Wire API: 'responses' / OpenAI-compatible
└───────────┬────────────┘
            │
    ┌───────┴────────────────────────┐
    ▼                                ▼
┌──────────────────────┐   ┌──────────────────────┐
│  Tier 1: Google      │   │  Tier 2: Groq /      │
│  (Gemini 2.5/3.6)    │   │  Cerebras / Mistral  │
└──────────────────────┘   └──────────────────────┘
```

### Topologia de Roteamento Padronizada:
1. **Canônica (via CC Switch):** O Codex CLI conecta-se ao endpoint `http://127.0.0.1:31415/v1` configurado como provider ativo pelo CC Switch.
2. **Wire API:** `wire_api = "responses"` (compatível com a API nativa de comandos e streaming do Codex CLI).
3. **Autenticação:** Utilização da chave unificada do FreeLLMAPI gravada com segurança em `auth.json` (modo não exposto no shell).

---

## 3. Análise de Impacto e Riscos

| Risco Identificado | Severidade | Probabilidade | Mitigação Técnica Planejada |
| :--- | :--- | :--- | :--- |
| **Colisão de Portas** (3001 vs 31415) | Média | Baixa | O FreeLLMAPI desktop roda exclusivamente na porta dedicada `31415`. Todas as URLs serão explicitamente travadas em `31415`. |
| **Sobrescrita de Chaves Oficiais** | Alta | Baixa | Backups atômicos com timestamp de `~/.codex/config.toml` e `auth.json` antes de qualquer mutação. Preservação dos profiles oficiais no CC Switch. |
| **Proxy FreeLLMAPI Offline** | Média | Média | Documentação de comando de reversão imediata (1 linha) para `OpenAI Official` via CC Switch. |
| **Incompatibilidade de Wire API** | Média | Baixa | Validado que o FreeLLMAPI suporta `/v1/responses` e streaming SSE nativo para o Codex. |
| **Poluição de Shell RC** | Alta | Baixa | Proibição de inserção de chaves ou aliases permanentes em `~/.zshrc` ou `~/.zprofile`. Governança estrita via CC Switch. |

---

## 4. Estratégia de Configuração

1. **Governança via CC Switch:**
   - Padronizar o payload do provider `FreeLLMAPI` no banco de dados do CC Switch para garantir sincronia perfeita entre `config.toml` e `auth.json`.
2. **Ajuste de Parâmetros do Codex:**
   - `model = "auto"`
   - `model_provider = "custom"` (ou alias canônico)
   - `base_url = "http://127.0.0.1:31415/v1"`
   - `wire_api = "responses"`
   - `requires_openai_auth = true`
   - `model_reasoning_effort = "medium"`
3. **Isolamento de Credenciais:**
   - A chave do FreeLLMAPI será mantida em `~/.codex/auth.json` sem exportação global no terminal.

---

## 5. Procedimento de Rollback

Caso ocorra qualquer erro de comunicação, timeout ou recusa de resposta:
1. **Restauração via CC Switch:**
   ```bash
   python3 /Users/danilonovais/MacOS-Use/.agents/skills/cc-switch/scripts/ccs.py switch "OpenAI Official" --app codex
   ```
2. **Restauração Manual via Backup Snapshot:**
   ```bash
   cp -f ~/.codex/config.toml.bak.<TIMESTAMP> ~/.codex/config.toml
   cp -f ~/.codex/auth.json.bak.<TIMESTAMP> ~/.codex/auth.json
   ```
