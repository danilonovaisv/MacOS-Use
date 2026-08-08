# Resumo do Diagnóstico de Metadados

Data: 2026-08-07
Escopo: até 500 mensagens recentes da Caixa de Entrada por conta
Campos: `account`, `sender`, `domain`, `date`, `read`, `flagged`

## Validação

- 2.173 mensagens analisadas.
- 7 entradas de conta/identidade retornadas pelo Mail, correspondentes às seis contas configuradas e às identidades exibidas pelo aplicativo.
- Zero erros por conta ou por mensagem.
- Nenhum corpo, anexo, cabeçalho completo ou destinatário foi consultado.
- Nenhuma mensagem foi modificada.

## Volume por conta

| Conta | Amostra | Não lidas | Sinalizadas |
|---|---:|---:|---:|
| Google | 500 | 472 | 0 |
| Yahoo! | 500 | 251 | 1 |
| dannovaisv@gmail.com | 500 | 390 | 6 |
| danilo@portfoliodanilo.com | 394 | 210 | 3 |
| dannovaisvilela@gmail.com | 268 | 247 | 0 |
| danilonovais@portfoliodanilo.com | 10 | 10 | 0 |
| iCloud | 1 | 0 | 0 |

## Principais domínios

| Domínio | Mensagens |
|---|---:|
| google.com | 379 |
| linkedin.com | 110 |
| br.email.samsung.com | 95 |
| accounts.google.com | 68 |
| email.heygen.com | 62 |
| meucreditoagora.com | 50 |
| github.com | 46 |
| runpod.io | 44 |
| medium.com | 40 |
| discover.pinterest.com | 36 |
| newsletter.artlist.io | 32 |
| muapi.ai | 31 |
| vercel.com | 23 |
| news.railway.app | 23 |
| insideapple.apple.com | 19 |

## Remetentes mais frequentes

| Remetente | Mensagens |
|---|---:|
| calendar-notification@google.com | 119 |
| samsunglatam@br.email.samsung.com | 95 |
| no-reply@accounts.google.com | 68 |
| no_reply@email.heygen.com | 62 |
| contato@meucreditoagora.com | 50 |
| noreply@github.com | 45 |
| noreply@medium.com | 40 |
| recommendations@discover.pinterest.com | 36 |
| cloudplatform-noreply@google.com | 35 |
| team@newsletter.artlist.io | 32 |

## Candidatos a regras

- Google: manter condições específicas por remetente/assunto; não criar regra ampla para `google.com`.
- LinkedIn: o volume de alertas e notificações justifica a regra piloto existente, mas sem mover ou notificar.
- GitHub, Runpod, Vercel e Railway: candidatos a uma futura categoria de trabalho após revisão de exemplos.
- Samsung, HeyGen, Medium, Pinterest e Artlist: candidatos a `Leitura` ou a cancelamento individual, nunca a ação crítica.
- Meu Crédito Agora e outros serviços de crédito: candidatos a baixa prioridade/cancelamento, sujeitos a confirmação.

## Limitações

- A amostra usa a ordem atual da Caixa de Entrada fornecida pelo Mail.
- Contas com menos de 500 mensagens disponíveis retornaram o total existente.
- O diagnóstico não avaliou conteúdo; por isso, nenhuma promoção automática de regra deve ser baseada apenas neste relatório.

