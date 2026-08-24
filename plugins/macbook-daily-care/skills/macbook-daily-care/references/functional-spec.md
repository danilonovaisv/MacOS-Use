# Especificacao funcional

## Objetivo e usuario

O plugin executa auditoria preventiva diaria de um MacBook Apple Silicon, voltada a uma pessoa com conhecimento tecnico basico. Toda explicacao deve responder: o que foi observado, por que importa e qual e o proximo passo mais seguro.

## Arquitetura modular

| Modulo | Responsabilidade | Efeito padrao |
|---|---|---|
| Scheduler | LaunchAgent diario, 10:00, `America/Sao_Paulo` | Instalar somente sob pedido |
| System Auditor | Hardware, macOS, uptime, CPU, memoria, processos, login e servicos | Leitura |
| Storage Analyzer | Capacidade, caches, logs e candidatos a revisao | Leitura |
| Network and DNS Checker | Interface, conectividade, resolucao, DNS e latencia | Leitura |
| Update Checker | macOS, seguranca, App Store e Homebrew | Leitura |
| Security Checker | FileVault, firewall, Gatekeeper, perfis e itens de login | Leitura |
| NotebookLM Connector | Pesquisa fundamentada e registro de fontes sanitizadas | Rede, degradacao graciosa |
| Report Generator | Relatorio Markdown simples e completo | Escrita em diretorio proprio |
| Approval Manager | Bloqueio e registro de decisoes sensiveis | Negar por padrao |
| Audit Logger | Eventos JSONL, snapshots e diferencas diarias | Escrita em diretorio proprio |

## Fluxo

`preflight -> memoria -> coleta -> normalizacao -> analise -> classificacao -> NotebookLM -> relatorio -> historico`

Falha critica de identidade do host, integridade da configuracao ou escrita do log interrompe manutencao. Falhas de um coletor de leitura geram resultado parcial; os demais coletores podem continuar. Falha do NotebookLM nunca impede o relatorio local.

## Permissoes minimas

- Leitura: comandos nativos de informacao do sistema, processos, volumes, configuracao de rede e status de seguranca.
- Escrita: somente `~/Library/Application Support/MacBookDailyCare/` e `~/Library/Logs/MacBookDailyCare/`.
- Rede: testes de conectividade e NotebookLM quando habilitado.
- Automacao: `~/Library/LaunchAgents/com.danilonovais.macbook-daily-care.plist`, instalada por comando explicito.
- Administrador: nunca no modo auditoria; solicitar somente para uma acao aprovada que realmente exija privilegio.

Full Disk Access nao e requisito padrao. Quando um dado protegido nao puder ser lido, marque `nao verificado` e explique como o usuario pode revisar manualmente.

## Dados e historico

Cada execucao possui:

```json
{
  "schema_version": "1.0",
  "run_id": "UUID",
  "started_at": "ISO-8601",
  "finished_at": "ISO-8601",
  "timezone": "America/Sao_Paulo",
  "mode": "audit|safe-maintenance|manual-approval",
  "host": {"model": "string", "chip": "string", "memory_bytes": 0, "os_version": "string"},
  "checks": [{"id": "string", "status": "ok|warning|critical|unknown", "summary": "string", "evidence": {}}],
  "actions": [{"id": "string", "status": "executed|recommended|blocked|failed", "benefit": "string", "risk": "string", "rollback": "string|null"}],
  "approvals": [{"action_id": "string", "decision": "approved|rejected|expired", "decided_at": "ISO-8601"}],
  "notebooklm": [{"problem": "string", "solution": "string", "disposition": "applied|recommended", "confidence": "low|medium|high", "risks": [], "next_steps": []}],
  "changes_since_previous": [],
  "errors": []
}
```

O JSON detalhado fica local. Fontes enviadas ao NotebookLM devem conter apenas IDs opacos, categorias, versoes e sintomas sanitizados.

## Integracao NotebookLM

NotebookLM e uma base de conhecimento fundamentada, nao o armazenamento transacional primario. O conector usa a CLI nao oficial `notebooklm-py` quando ja instalada e autenticada.

1. Localize ou selecione o notebook cujo titulo exato seja `notebookLM`; nunca crie sem autorizacao.
2. Para pesquisa, use `notebooklm ask` com sintoma sanitizado, contexto de versao e pedido por causa, risco e verificacao.
3. Classifique confianca: alta quando fontes e evidencias locais convergem; media quando ha suporte parcial; baixa quando a resposta e generica ou sem corroboracao.
4. Para registrar historico, gere um resumo diario sanitizado como fonte Markdown. Adicionar a fonte e uma escrita externa e requer que a integracao tenha sido habilitada pelo usuario.
5. Salve no log a pergunta, resumo da resposta, confianca e IDs; nunca copie cookies ou autenticacao.
6. Em autenticacao expirada, marque indisponivel, recomende `notebooklm login` e continue localmente.

## Criterios de sucesso

Execucao diaria pontual, relatorio completo e legivel, nenhuma mutacao sensivel sem aprovacao, historico comparavel, consulta de memoria para problemas e comportamento deny-by-default em qualquer duvida.
