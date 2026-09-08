---
description: # Workflow automatizado no Codex utilizando protocolos MCP (@Computer, @Context7) e Agent Skills do macOS para diagnosticar, higienizar e provisionar infraestruturas de desenvolvimento via agente @electron-pro.
---


1. Contexto e Propósito do Workflow
Este workflow estabelece uma pipeline autônoma no Codex para a configuração de ambientes macOS. Ao combinar o acesso ao host do plugin @Computer com a injeção de documentação atualizada do @Context7, o agente @electron-pro obtém a capacidade de ler a infraestrutura do MacBook, eliminar gargalos de armazenamento e provisionar ferramentas de desenvolvimento sem intervenção manual. Essa abordagem resolve o problema de configurações divergentes, entregando um sistema padronizado e otimizado.

2. Passo a Passo: Integração e Ativação
A execução deste fluxo utiliza a arquitetura de Divulgação Progressiva (Progressive Disclosure), onde o agente consome informações táticas sob demanda para evitar a explosão do contexto e garantir alta velocidade de inferência.

Fase A: Ativação dos Plugins MCP
Antes de invocar as habilidades, certifique-se de que os servidores MCP estão registrados e habilitados no Codex.

1. Inicie o servidor @Computer para liberar o acesso seguro ao terminal local (bash/zsh) e ao sistema de arquivos do macOS.

2. Inicie o servidor @Context7 para garantir que qualquer dependência instalada tenha sua documentação oficial buscada em tempo real (ex: frameworks específicos ou SDKs da Apple), evitando alucinações de versão.

Fase B: Orquestração do Agente e Skills
No input do Codex, você acionará o agente coordenador e injetará as quatro Skills em uma sequência cronológica:

1. Auditoria e Limpeza: As skills @macos-diagnostics e @macos-cleaner examinam o disco interativamente e recomendam a remoção de caches do sistema ou resíduos de ambientes de desenvolvimento antigos (como imagens Docker ou dependências npm).

2. Instalação Base: A skill @macos-setup inicia um assistente que coleta preferências e gera o plano de instalação das dependências (Homebrew, Git, linguagens).

3. Validação da Stack: A skill @macos-development revisa a arquitetura instalada, validando a integração de APIs do macOS e padrões estruturais do ambiente.

4. Comandos e Execução
Envie o prompt abaixo no terminal do Codex ou na janela do Agent Manager para executar o fluxo completo de uma só vez:
@electron-pro Assuma a execução do terminal via plugin @Computer.
5. Use as skills @macos-diagnostics e @macos-cleaner para realizar uma análise de disco profunda. Peça minha confirmação antes de apagar arquivos de cache pesados.
6. Acesse o @Context7 para buscar a documentação das últimas versões das linguagens e pacotes necessários para o projeto atual.
7. Ative a skill @macos-setup para criar o ambiente (Homebrew, Node, Git, etc). Execute a instalação de forma silenciosa sempre que possível.
8. Finalize com a skill @macos-development para auditar a configuração global.

Dica: Se quiser apenas testar a viabilidade da configuração sem instalar nada, adicione a flag --dry-run ao comando, o que fará o @macos-setup exibir apenas o plano de ação.

1. Solução de Problemas (Troubleshooting)

⚬ Permissões de Execução Bloqueadas: O plugin @Computer pode falhar com o erro Operation not permitted. ⚬ Solução: Vá em Preferências do Sistema > Privacidade e Segurança > Acesso Total ao Disco (Full Disk Access) e habilite o Codex ou o seu emulador de Terminal.

⚬ Timeouts em Shells Não-Interativos: Se o agente travar ao executar comandos do @macos-setup. ⚬ Solução: Alguns instaladores exigem prompt de usuário (como senhas do sudo). Certifique-se de usar flags como -y para pular prompts automáticos ou acompanhe os logs para inserir a senha quando o agente pausar a execução.

⚬ Conflitos de Arquitetura (M-Series vs Intel): Caminhos binários diferem (/opt/homebrew no Apple Silicon vs /usr/local no Intel). ⚬ Solução: A skill @macos-setup é responsável por detectar o ambiente, mas caso o $PATH falhe, instrua o @electron-pro a validar a variável de ambiente via @Computer usando echo $PATH.
