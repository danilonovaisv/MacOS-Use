# Tarefas de Execucao PREVC

Estado da missao documental: em execucao autorizada
Estado da configuracao real: nao executada; exige gate especifico

## T01 - Inventario do repositorio

- Objetivo: mapear documentos, regras, skills, workflows, scripts e artefatos existentes.
- Arquivos envolvidos: `AGENTS.md`, `GEMINI.md`, `CLAUDE.md`, `.agents/`, `.context/`, `artifacts/`.
- Entrada esperada: workspace local, sem leitura de `.env*`, keychains ou credentials.
- Saida esperada: inventario sanitizado no plano.
- Criterio de conclusao: caminhos relevantes e conflitos preexistentes registrados.
- Risco: leitura acidental de arquivo sensivel.
- Aprovacao adicional: nao, para leitura allowlisted.

## T02 - Validacao factual

- Objetivo: confirmar endpoint, modelos, compatibilidade e superficie Claude Code.
- Arquivos envolvidos: nenhum arquivo de configuracao pessoal.
- Entrada esperada: documentacao publica e UI do CC Switch sem campos preenchidos.
- Saida esperada: fatos datados e incertezas marcadas.
- Criterio de conclusao: OpenAI-compatible e Anthropic-compatible separados.
- Risco: documentacao externa desatualizada.
- Aprovacao adicional: nao, para consulta somente leitura.

## T03 - Plano de implementacao

- Objetivo: definir escopo, arquitetura, riscos, rollback e sucesso.
- Arquivos envolvidos: `artifacts/deepseek-cc-switch/implementation_plan.md`.
- Entrada esperada: inventario e validacao factual.
- Saida esperada: plano auditavel.
- Criterio de conclusao: todas as secoes obrigatorias presentes.
- Risco: ampliar escopo implicitamente.
- Aprovacao adicional: nao; coberta pelo pedido atual.

## T04 - Contrato de regras

- Objetivo: definir papel, PREVC, seguranca, comandos e parada.
- Arquivos envolvidos: `.agents/rules/deepseek-cc-switch.md`.
- Entrada esperada: plano aprovado para documentacao.
- Saida esperada: regra isolada, sem substituir `GEMINI.md`.
- Criterio de conclusao: regra limita a propria aplicacao ao dominio DeepSeek/CC Switch.
- Risco: trigger global afetar tarefas alheias.
- Aprovacao adicional: nao para criar; `⚠️ Verificar` trigger antes de ativar.

## T05 - Skill especializada

- Objetivo: tornar revisoes futuras consistentes e seguras.
- Arquivos envolvidos: `.agents/skills/deepseek-cc-switch/SKILL.md`.
- Entrada esperada: regras e fatos validados.
- Saida esperada: skill com frontmatter valido e workflow conciso.
- Criterio de conclusao: validacao de skill sem erros.
- Risco: skill generica demais ou com autorizacao implicita.
- Aprovacao adicional: nao.

## T06 - Workflow PREVC

- Objetivo: codificar intake, scan, gate, execucao, pos-processamento e confirmacao.
- Arquivos envolvidos: `.agents/workflows/deepseek-cc-switch-prevc.md`.
- Entrada esperada: plano, regras e politica.
- Saida esperada: fluxo com estados e handoffs explicitos.
- Criterio de conclusao: nenhuma mutacao atravessa o gate implicitamente.
- Risco: gate apenas documental ser tratado como enforcement tecnico.
- Aprovacao adicional: nao para documentar; sim para executar fases mutaveis.

## T07 - Politica de permissoes

- Objetivo: separar leitura, escrita, shell, rede, GUI e evidencias.
- Arquivos envolvidos: `.agents/policies/permissions.md`.
- Entrada esperada: matriz de riscos.
- Saida esperada: allowlist, approval list e denylist.
- Criterio de conclusao: segredos e arquivos fora do escopo ficam negados.
- Risco: aprovacao ampla ou persistente.
- Aprovacao adicional: nao para documentar.

## T08 - Exemplo MCP

- Objetivo: fornecer configuracao opcional, parseavel e inativa.
- Arquivos envolvidos: `.agents/mcp/mcp.config.example.json`.
- Entrada esperada: placeholders de command, token e workspace.
- Saida esperada: JSON sem servidor real obrigatorio.
- Criterio de conclusao: parser JSON retorna sucesso e nenhum segredo e encontrado.
- Risco: exemplo ser copiado e ativado sem revisao.
- Aprovacao adicional: nao para criar; sim para instalar/ativar.

## T09 - Checklist e memoria local

- Objetivo: definir evidencia objetiva e registrar decisoes locais.
- Arquivos envolvidos: `.agents/checklists/validation_checklist.md`, `.agents/memory/deepseek-cc-switch-memory.md`.
- Entrada esperada: todos os contratos anteriores.
- Saida esperada: checklist verificavel e ledger local nao canonico.
- Criterio de conclusao: cada criterio final tem estado e evidencia.
- Risco: memoria local ser confundida com conhecimento canonico.
- Aprovacao adicional: nao.

## T10 - Pos-processamento

- Objetivo: normalizar termos, remover duplicidades e bloquear segredos.
- Arquivos envolvidos: somente os onze arquivos deste pacote.
- Entrada esperada: primeira versao completa.
- Saida esperada: relatorio no walkthrough.
- Criterio de conclusao: nenhuma ocorrencia critica ou inconsistencia sem marcacao.
- Risco: scanner imprimir valor sensivel preexistente.
- Aprovacao adicional: nao, desde que a varredura fique na allowlist do pacote.

## T11 - Validacao

- Objetivo: validar JSON, Markdown, links, placeholders e skill.
- Arquivos envolvidos: somente o pacote e utilitarios de validacao ja instalados.
- Entrada esperada: artefatos pos-processados.
- Saida esperada: comandos, exit codes e contagens sanitizadas.
- Criterio de conclusao: zero falhas obrigatorias.
- Risco: falso positivo/negativo de secret scanning.
- Aprovacao adicional: nao para testes locais somente leitura.

## T12 - Configuracao real futura

- Objetivo: configurar e testar DeepSeek no CC Switch/Claude Code.
- Arquivos envolvidos: configuracao pessoal do CC Switch e sessao Claude Code.
- Entrada esperada: aprovacao pontual, chave inserida pelo humano e endpoint confirmado.
- Saida esperada: teste minimo redigido e rollback confirmado.
- Criterio de conclusao: conectividade sem exposicao de segredo.
- Risco: transmissao de chave/prompts e alteracao persistente de provider.
- Aprovacao adicional: sim, obrigatoria no momento da acao.

