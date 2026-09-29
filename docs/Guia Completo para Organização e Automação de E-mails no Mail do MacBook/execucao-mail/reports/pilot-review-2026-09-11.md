# Revisão do piloto do Apple Mail - 2026-09-11

## Decisão

Nenhuma das cinco regras deve ser promovida nesta revisão. A segurança
operacional foi confirmada, mas ainda não há amostra semanticamente revisada
que permita demonstrar taxa de falsos positivos inferior a 1%.

## Escopo e método

- Revisão somente leitura pela interface do Mail e AppleScript.
- Limite de 500 mensagens recentes por conta.
- Sete contas encontradas; 2.295 mensagens foram verificadas.
- Metadados usados: remetente e estado/cor do sinalizador.
- Assunto, corpo, anexos e destinatários não foram usados no cálculo.

## Segurança operacional

- As cinco regras `PILOTO` estão ativas e as versões antigas estão inativas.
- As ações observadas são somente sinalização e, nas regras críticas previstas,
  notificação nativa.
- Não existe ação de apagar, encaminhar, copiar ou mover para `No Meu Mac`.
- Portanto, as regras não possuem um caminho configurado para exclusão,
  encaminhamento, armazenamento local ou duplicação.
- Esta conclusão é estrutural; não é uma deduplicação exaustiva do servidor.

## Cobertura da amostra

| Regra | Correspondências | Sinalizador esperado | Cobertura | Decisão |
| --- | ---: | ---: | ---: | --- |
| `PILOTO - LINKEDIN JOB ALERTS` | 43 | 34 | 79,1% | Manter em piloto |
| `PILOTO - QUINTO ANDAR` | 4 | 4 | 100% | Manter em piloto |
| `PILOTO - ALL SET IMPORTANTE` | 0 | 0 | Sem amostra | Manter em piloto |
| `PILOTO - Claro` | 2 | 1 | 50% | Manter em piloto |
| `PILOTO - COBRANÇA GOOGLE` | 0 | 0 | Sem amostra de remetente | Manter em piloto |

Cobertura mede aplicação do sinalizador, não correção semântica. Em particular,
`COBRANÇA GOOGLE` inclui critérios de conteúdo que ficaram fora do diagnóstico
autorizado. `QUINTO ANDAR` e `Claro` também possuem critérios alternativos mais
amplos que exigem conferência visual.

## Visibilidade e saúde

- As Caixas Inteligentes GTD continuam visíveis: `00 · Ação hoje`,
  `10 · Aguardando`, `20 · Financeiro`, `30 · Leitura` e `90 · Hoje`.
- No momento da revisão, havia mensagens visíveis nas filas de ação,
  financeiro e leitura; a fila financeira mantinha mensagens não lidas.
- O LaunchAgent encerrou a última execução com código 0.
- O log está atualizado até 2026-09-11, com 841 verificações saudáveis e
  3.260 candidatos de cancelamento registrados para revisão, sem cancelamento.
- Houve 24 timeouts históricos de AppleEvent; as 300 linhas mais recentes não
  continham erro.

## Gate humano pendente

Revisar visualmente até 50 mensagens por regra e classificar cada uma como
correta ou falso positivo. Para promoção, cada regra precisa de exemplos
corretos, menos de 1% de falsos positivos e confirmação de que mensagens
financeiras e profissionais críticas continuam visíveis.

O filtro de lixo e os nomes/ações das regras não foram alterados. A automação de
revisão permanece ativa e só deve ser convertida para trimestral depois da
decisão do usuário.
