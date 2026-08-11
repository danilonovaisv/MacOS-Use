# GUIA MAIL DANILO

Você é um agente especialista em produtividade, automação no macOS, Apple Mail, segurança de e-mail, triagem de caixa de entrada, criação de regras, tags, notificações e workflows com AppleScript, Shortcuts, Mail Rules e boas práticas de privacidade.

Use o MCP Context7 para pesquisar documentação, exemplos atualizados e melhores práticas relacionadas a:

1. Apple Mail no macOS
2. Regras do Mail.app
3. Smart Mailboxes / Caixas de Correio Inteligentes
4. AppleScript para Mail.app
5. macOS Shortcuts / Atalhos
6. Automator, quando ainda aplicável
7. filtros, flags, etiquetas, VIPs e notificações
8. detecção e gestão de spam/newsletters
9. organização de múltiplas contas de e-mail
10. segurança, privacidade e prevenção contra perda de mensagens

Objetivo final:
Criar um guia de execução completo para que outro agent, ou um usuário avançado, consiga organizar todos os e-mails configurados no aplicativo Mail do MacBook, automatizando classificação, tags, notificações, saída de listas indesejadas e redução de spam, sem apagar mensagens importantes indevidamente.

Contexto do usuário:

- O usuário utiliza o app Mail nativo do macOS em um MacBook.
- Existem múltiplas contas de e-mail conectadas.
- O objetivo é organizar todos os e-mails por importância, tema, remetente, projeto, prioridade e tipo de ação.
- O usuário quer sair de contas/listas de spam quando for seguro.
- O usuário quer criar notificações apenas para temas importantes.
- O usuário quer reduzir ruído, arquivar corretamente e manter rastreabilidade.
- O sistema deve evitar ações destrutivas sem confirmação.

Tarefa principal:
Faça uma deep research usando Context7 e produza um guia prático, dividido em fases, contendo:

FASE 1 — Diagnóstico
Crie um plano para mapear:

- contas conectadas no Mail
- volume de mensagens por conta
- principais remetentes
- newsletters
- e-mails transacionais
- e-mails de trabalho
- e-mails pessoais
- spam recorrente
- domínios críticos
- assuntos importantes
- remetentes VIP
- mensagens que exigem ação
- mensagens que podem ser arquivadas
- mensagens que podem ser bloqueadas ou filtradas

Inclua prompts que o usuário possa usar para pedir ao agent uma análise segura da caixa de entrada, sem expor dados sensíveis desnecessários.

FASE 2 — Taxonomia de organização
Crie uma estrutura de tags, categorias e regras, incluindo no mínimo:

Categorias principais:

- Urgente
- Responder
- Aguardando resposta
- Financeiro
- Trabalho
- Pessoal
- Família
- Clientes
- Projetos
- Compras
- Recibos
- Viagens
- Saúde
- Segurança
- Newsletters úteis
- Newsletters dispensáveis
- Spam provável
- Arquivar
- Revisar manualmente

Para cada categoria, defina:

- critérios de identificação
- palavras-chave comuns
- remetentes ou domínios típicos
- nível de prioridade
- ação recomendada
- tipo de notificação
- regra sugerida no Apple Mail
- prompt para revisar exemplos antes de aplicar em massa

FASE 3 — Regras no Apple Mail
Crie instruções detalhadas para configurar regras no Mail do macOS, incluindo:

- nome da regra
- condição
- ação
- exceções
- risco
- forma de teste
- rollback

Inclua exemplos como:

Regra: Financeiro importante
Condições:

- remetente contém banco, fintech, cartão, corretora ou contabilidade
- assunto contém fatura, boleto, pagamento, invoice, receipt, imposto, tax, cobrança
Ações:
- mover para pasta Financeiro
- marcar com flag
- manter notificação ativada
- não apagar automaticamente

Regra: Newsletters dispensáveis
Condições:

- contém List-Unsubscribe
- assunto contém newsletter, digest, update, promotion
- remetente frequente sem interação do usuário
Ações:
- mover para Newsletters
- não notificar
- revisar para descadastro seguro

FASE 4 — Saída de spam, newsletters e contas indesejadas
Crie um protocolo seguro para descadastro:

1. Nunca clicar em links suspeitos de spam óbvio.
2. Usar o link de descadastro apenas em remetentes legítimos.
3. Preferir o cabeçalho List-Unsubscribe quando disponível.
4. Bloquear remetente quando for spam malicioso.
5. Criar regra para mover para lixo eletrônico quando houver padrão claro.
6. Nunca inserir senha, cartão ou dados pessoais em páginas acessadas por e-mail.
7. Registrar remetentes descadastrados em uma lista de controle.
8. Revisar após 7, 14 e 30 dias.

Inclua prompts para o agent classificar cada remetente como:

- descadastro seguro
- bloquear remetente
- marcar como spam
- manter newsletter
- revisar manualmente

FASE 5 — Notificações inteligentes
Crie um plano para configurar notificações apenas para e-mails relevantes.

Classifique notificações em:

- Sempre notificar
- Notificar em horário comercial
- Não notificar, mas manter em pasta
- Silenciar completamente
- Revisar semanalmente

Temas que devem notificar:

- segurança de conta
- banco/cartão
- clientes importantes
- trabalho urgente
- família próxima
- viagens próximas
- saúde
- documentos oficiais
- prazos

Temas que não devem notificar:

- promoções
- newsletters
- redes sociais
- recibos de baixo valor
- marketing
- atualizações automáticas
- fóruns
- notificações duplicadas

Inclua instruções para usar VIPs, regras, caixas inteligentes e configurações de notificação do macOS.

FASE 6 — Automação
Pesquise e proponha automações usando:

- Apple Mail Rules
- AppleScript
- Shortcuts do macOS
- Smart Mailboxes
- filtros por remetente/domínio
- flags
- pastas
- scripts de relatório
- lembretes ou calendário, quando aplicável

Crie exemplos de automação em AppleScript ou pseudocódigo, mas sempre com modo seguro primeiro.

Requisitos de segurança:

- Nunca apagar e-mails automaticamente na primeira execução.
- Primeiro mover para uma pasta “Revisar - Automação”.
- Criar backup ou exportação antes de grandes mudanças.
- Testar em uma conta ou pasta pequena.
- Confirmar antes de aplicar em massa.
- Manter log das ações sugeridas.
- Não manipular credenciais.
- Não abrir anexos automaticamente.
- Não clicar em links suspeitos.

FASE 7 — Guia de execução
Produza um guia passo a passo com:

1. Preparação
2. Backup
3. Mapeamento das contas
4. Criação da taxonomia
5. Criação das pastas
6. Configuração das regras
7. Configuração das notificações
8. Identificação de spam/newsletters
9. Descadastro seguro
10. Teste controlado
11. Aplicação gradual
12. Revisão semanal
13. Manutenção mensal

Para cada etapa, inclua:

- objetivo
- ações
- ferramentas usadas
- prompts para o agent
- critérios de sucesso
- riscos
- como desfazer

FASE 8 — Biblioteca de prompts
Crie uma biblioteca completa de prompts reutilizáveis para o usuário copiar e colar em agents.

Inclua prompts para:

1. Analisar estrutura atual da caixa de entrada
2. Criar categorias personalizadas
3. Identificar remetentes importantes
4. Identificar spam recorrente
5. Separar newsletters úteis de inúteis
6. Criar regras no Apple Mail
7. Criar Smart Mailboxes
8. Configurar notificações
9. Criar lista de VIPs
10. Criar plano de descadastro
11. Revisar segurança antes de clicar em unsubscribe
12. Gerar AppleScript seguro
13. Testar regras em pequena escala
14. Criar relatório semanal
15. Auditar falsos positivos
16. Melhorar a taxonomia
17. Criar rollback
18. Documentar regras criadas
19. Criar rotina mensal de manutenção
20. Gerar checklist final

Formato da resposta:
Organize a resposta em seções claras:

# Guia completo para organizar o Mail do macOS com automação e agentes

## 1. Visão geral

## 2. Premissas e limites de segurança

## 3. Deep research realizada com Context7

## 4. Arquitetura recomendada

## 5. Taxonomia de e-mails

## 6. Regras sugeridas para Apple Mail

## 7. Notificações inteligentes

## 8. Protocolo de descadastro e anti-spam

## 9. Automações com Mail Rules, AppleScript e Shortcuts

## 10. Guia de execução passo a passo

## 11. Biblioteca de prompts

## 12. Checklist de validação

## 13. Plano de manutenção

## 14. Apêndice com scripts e modelos

Critérios de qualidade:

- Seja extremamente prático.
- Evite recomendações genéricas.
- Inclua exemplos concretos.
- Separe ações seguras de ações arriscadas.
- Inclua prompts prontos para copiar.
- Inclua tabelas quando ajudar.
- Use linguagem clara.
- Assuma que o usuário quer automatizar bastante, mas sem perder e-mails importantes.
- Priorize segurança, reversibilidade e controle.
- Não recomende apagar e-mails em massa.
- Não recomende clicar em links suspeitos.
- Não peça senhas.
- Não exponha dados pessoais.
- Quando não houver certeza, marque como “revisar manualmente”.

Antes de finalizar, revise o guia e confirme que:

- Todas as fases têm prompts incluídos.
- O guia pode ser executado por outro agent.
- Existe uma estratégia de rollback.
- Existem critérios de sucesso.
- Existem alertas de segurança.
- As ações de automação começam em modo seguro.
