# Plano de execução

- [x] Auditar o staging e a automação já instalada.
- [x] Identificar ações destrutivas, conflitos e erros de sintaxe.
- [x] Converter os scripts para piloto somente leitura.
- [x] Compilar e validar todos os artefatos corrigidos.
- [x] Criar backup datado dos destinos existentes.
- [x] Instalar AppleScripts, launcher e LaunchAgent de saúde.
- [x] Verificar execução, logs e ausência de operações mutáveis no código instalado.
- [x] Ocultar completamente o painel de visualização antes do piloto.
- [x] Registrar a ordem e o estado das regras existentes sem alterá-las.
- [x] Criar `PILOTO - Prioridade` com correspondência por VIP ou termos críticos e executar `SmartNotifications.scpt`.
- [x] Criar `PILOTO - Unsubscribe` com cabeçalho `List-Unsubscribe` e executar `AntiSpamUnsubscribe.scpt`.
- [x] Criar `PILOTO - Classificação` limitada à conta profissional explicitamente aprovada e executar `TaxonomyAndTagging.scpt`.
- [x] Recusar a aplicação das novas regras ao histórico.
- [x] Confirmar sinalizadores e Caixas Inteligentes GTD existentes, preservando cores e critérios.
- [x] Confirmar filtro de lixo conservador, notificações para VIPs e sons secundários desativados.
- [x] Ativar Proteção de Atividade no Mail, preservando ocultação do endereço IP.
- [x] Inventariar VIPs e contas sem abrir mensagens; nenhuma entrada foi removida.
- [x] Executar e validar amostras somente leitura de 5 e 20 mensagens.
- [x] Ordenar as três regras finais como Prioridade, Unsubscribe e Classificação.

Critério de promoção: sete dias sem movimento, exclusão, encaminhamento, duplicação ou falso positivo crítico. A configuração visual está concluída e permanece em observação.
