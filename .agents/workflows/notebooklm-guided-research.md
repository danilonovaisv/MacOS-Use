---
description: Workflow guiado para pesquisa e implementação utilizando cadernos de conhecimento do NotebookLM. Solicita informações do usuário, realiza pesquisa grounded e implementa o código.
---

# Workflow: /notebooklm-research — Implementação Guiada com NotebookLM

> **Slash Command:** `/notebooklm-research`  
> **Propósito:** Realizar uma implementação técnica baseada exclusivamente em documentação e cadernos do NotebookLM. O agente guia o usuário passo-a-passo solicitando parâmetros iniciais.  
> **Agente Responsável:** `@notebooklm-knowledge-sentinel` (ou o agente ativo na IDE)

---

## FASE 1: Coleta de Informações (Interação com o Usuário)

Antes de iniciar qualquer pesquisa, o agente **DEVE** parar sua execução e solicitar explicitamente as seguintes informações ao usuário:

1. **Qual é o objetivo principal da implementação ou pesquisa de hoje?**
2. **Quais cadernos (projetos) do NotebookLM deverão ser consultados/incluídos?** *(Solicite que o usuário forneça URLs ou nomes dos notebooks)*
3. *(Opcional)* **Há algum arquivo no repositório atual que deve ser o foco dessa modificação?**

> **Regra do Agente:** Pare a execução e aguarde o input do usuário após fazer essas perguntas. Não inicie a pesquisa até ter essas definições.

---

## FASE 2: Verificação de Ambiente e Autenticação

Após receber as respostas do usuário, o agente deve validar a integração com o NotebookLM:

1. Cheque o status da autenticação usando a skill:

   ```bash
   python .agents/skills/notebooklm/scripts/run.py auth_manager.py status
   ```

2. **Se o login for necessário:**
   - Avise o usuário: *"Estou abrindo uma janela do navegador para você realizar o login manual na sua conta do Google."*
   - Execute a configuração (isso abrirá o navegador visivelmente):

     ```bash
     python .agents/skills/notebooklm/scripts/run.py auth_manager.py setup
     ```

3. Liste os notebooks disponíveis localmente para verificar se o caderno solicitado já existe no cache da skill:

   ```bash
   python .agents/skills/notebooklm/scripts/run.py notebook_manager.py list
   ```

4. **Se o notebook solicitado pelo usuário NÃO estiver na lista (for novo):**
   - Use o mecanismo de adição de caderno, solicitando ao usuário descrição e tópicos se necessários (ou usando a descoberta inteligente conforme o `SKILL.md`):

     ```bash
     python .agents/skills/notebooklm/scripts/run.py notebook_manager.py add --url "[URL_FORNECIDA]" --name "[NOME]" --description "[DESCRIÇÃO]" --topics "[TOPICOS]"
     ```

---

## FASE 3: Pesquisa Grounded (Diagnóstico)

Com os notebooks alvos definidos:

1. Ative o notebook principal:

   ```bash
   python .agents/skills/notebooklm/scripts/run.py notebook_manager.py activate --id <notebook_id>
   ```

2. Faça a consulta inicial sobre o objetivo da implementação:

   ```bash
   python .agents/skills/notebooklm/scripts/run.py ask_question.py --question "Como implementar [OBJETIVO DO USUÁRIO] baseado nestes documentos? Diga-me a arquitetura, regras de negócio e exemplos de código necessários."
   ```

3. **Mecanismo de Follow-Up Obrigatório:**
   - As respostas do script terminarão com um aviso de follow-up (`Is that ALL you need to know?`).
   - O agente deve analisar a resposta silenciosamente. Se houver lacunas arquiteturais ou detalhes faltando, o agente **deve fazer follow-ups automáticos** (`ask_question.py`) antes de exibir o resultado ao usuário.

---

## FASE 4: Apresentação do Plano de Implementação

Após sintetizar as respostas do NotebookLM, componha a análise de viabilidade no seguinte formato estruturado e apresente ao usuário:

- **EVIDÊNCIA:** (Fatos e regras estritas extraídas do NotebookLM)
- **ESTADO ATUAL:** (Como o código do projeto está atualmente, pós-inspeção)
- **GAP:** (Diferença entre o que a documentação exige e o que está no código)
- **PLANO DE AÇÃO:** (O que será criado/modificado, listando os arquivos e métodos)

> **Regra do Agente:** Pergunte explicitamente ao usuário se ele aprova o Plano de Ação. Pare e aguarde a confirmação.

---

## FASE 5: Execução e Implementação

Após o "De Acordo" do usuário:

1. Aplique as alterações no código da base local (usando ferramentas de edição de arquivos).
2. **Restrição Crítica:** O código produzido não deve inventar padrões que contrariem o que foi recuperado do NotebookLM.
3. Em caso de novos pacotes, edite o `package.json` ou execute a instalação.

## FASE 6: Validação Final e Fechamento

1. Teste o código implementado:

   ```bash
   npm run lint
   npx tsc --noEmit
   ```

2. Caso ocorram erros, inicie um loop de self-healing para reparar os problemas (e relate-os em `ERRORS.md` conforme as regras de Error Logging).
3. Entregue um relatório de conclusão ao usuário, detalhando o que foi alterado e como a implementação atende aos critérios do caderno do NotebookLM.
