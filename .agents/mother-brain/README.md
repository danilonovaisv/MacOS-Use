# Mother Brain Adapter: macOS-Use

Este diretório contém a ponte de integração determinística entre o repositório local e o Mother Brain (`/Users/danilonovais/OBSIDIAN`).

## Regras Canônicas de Autoridade
- **Mother Brain (`/Users/danilonovais/OBSIDIAN`):** Autoridade canônica para conhecimento durável, decisões, arquitetura e governança.
- **Repositório Local (`/Users/danilonovais/MacOS-Use`):** Autoridade para código executável, testes, runtime e instruções locais dos agentes.
- **Memória de Sessão:** Efêmera por padrão (`ephemeral`), descartada no fechamento da sessão (`SESSION_CLOSE`).
- **Conhecimento Durável:** Segue o fluxo estrito `OBSERVED -> CANDIDATE -> VALIDATED -> HUMAN_AUTHORIZED -> CANONICAL`.
- **Graphify / Wiki-Brain:** Desativados por padrão (`disabled`). Graphify é `DERIVED_ONLY` e Wiki-Brain é `SUGGESTIONS_ONLY_FOR_V1`.
