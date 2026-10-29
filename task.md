# Checklist Operacional: Codex CLI + CC Switch & FreeLLMAPI
**Protocolo:** PREVC  
**Status:** CONCLUÍDO COM SUCESSO

---

## Checklist Granular de Execução

- [x] **1. Backups com Timestamp (Pré-execução)**
  - [x] Criar snapshot atômico de `~/.codex/config.toml` -> `~/.codex/config.toml.bak.20261029_140753`
  - [x] Criar snapshot atômico de `~/.codex/auth.json` -> `~/.codex/auth.json.bak.20261029_140753`
  - [x] Salvar cópia redundante no diretório do projeto `./backup-variaveis/20261029_140753/`

- [x] **2. Validação de Saúde do Proxy FreeLLMAPI**
  - [x] Testar liveness probe em `http://127.0.0.1:31415/api/ping` (200 OK)
  - [x] Confirmar catálogo `/v1/models` responsivo na porta 31415 (284 modelos)

- [x] **3. Governança & Padronização via CC Switch**
  - [x] Auditar schema do provider `FreeLLMAPI` no SQLite do CC Switch para a app `codex`
  - [x] Garantir que os parâmetros `base_url = "http://127.0.0.1:31415/v1"` e `wire_api = "responses"` estejam cravados no profile
  - [x] Executar comando canônico `ccs.py switch FreeLLMAPI --app codex`

- [x] **4. Aplicação das Diretivas de Roteamento no Codex**
  - [x] Verificar se `config.toml` reflete o bloco `[model_providers.custom]` com endpoint `31415/v1`
  - [x] Validar integridade sintática do arquivo TOML
  - [x] Confirmar permissões restritas `0600` em `config.toml` e `auth.json`

- [x] **5. Teste de Chamada Atômica via Terminal (Pós-aprovação)**
  - [x] Executar comando sintético não interativo com Codex CLI (`codex exec --ephemeral ...`)
  - [x] Inspecionar retorno e validar resposta (`OK_FROM_CODEX`)

- [x] **6. Validação de Consumo e Auditoria de Logs**
  - [x] Verificar logs e health check confirmando status saudável (`FreeLLMAPI: ✓ healthy`)
  - [x] Gerar artefato final `walkthrough.md` com as evidências de teste
