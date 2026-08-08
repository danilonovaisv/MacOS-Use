# Execução do Piloto do Apple Mail

Data: 2026-08-07

## Configuração aplicada

- Cinco regras `PILOTO - ...` ativas, limitadas a sinalizador e, em dois casos críticos, notificação.
- Doze regras antigas preservadas e inativas.
- Zero ações configuradas de exclusão, encaminhamento, cópia, transferência, AppleScript ou movimento para `No Meu Mac`.
- Filtro de lixo ativo em modo de observação, mantendo mensagens na Caixa de Entrada.
- Notificações gerais limitadas a VIPs.
- Foco `Work` limitado às duas contas `portfoliodanilo.com`.

## Amostra manual

| Conta | Mensagens | Resultado imediato |
|---|---:|---|
| Google | 50 | regras aplicadas; Caixa de Entrada permaneceu visível |
| Yahoo! | 50 | regras aplicadas; Caixa de Entrada permaneceu visível |
| dannovaisv@gmail.com | 50 | regras aplicadas; Caixa de Entrada permaneceu visível |
| dannovaisvilela@gmail.com | 50 | regras aplicadas; Caixa de Entrada permaneceu visível |
| danilo@portfoliodanilo.com | 50 | regras aplicadas; Caixa de Entrada permaneceu visível |
| danilonovais@portfoliodanilo.com | 9 | todas as mensagens disponíveis foram usadas; Caixa de Entrada permaneceu visível |

Total: 259 mensagens recentes.

## Verificações técnicas

- As regras piloto continuam sem transferência, cópia, exclusão, script ou encaminhamento.
- As Caixas Inteligentes `00`, `10`, `20` e `30` omitem Lixo e Apagadas.
- Cores verificadas no plist: vermelho `0`, laranja `1`, roxo `5` e azul `4`.
- A revisão foi agendada para 2026-08-14 às 09:00.

## Critérios ainda pendentes

- Revisar exemplos corretos de cada regra.
- Medir falsos positivos e confirmar taxa inferior a 1%.
- Confirmar ausência de duplicação ao longo dos sete dias.
- Confirmar que mensagens financeiras e profissionais críticas continuam visíveis.
- Promover cada regra somente após aprovação explícita desses critérios.
