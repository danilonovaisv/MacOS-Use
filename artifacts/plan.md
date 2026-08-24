# Plano de correção Wi-Fi - Big e Danilo

Data: 2026-08-23
Estado: executado e verificado

## Diagnóstico

- O Mac está conectado a `Big e Danilo Quarto`, não a `Big e Danilo`.
- A conexão atual usa 802.11n, canal 1 em 2,4 GHz, com sinal de -34 dBm e taxa de transmissão de 104 Mbps.
- O teste `networkQuality` mediu 4,532 Mbps de download, 26,152 Mbps de upload e responsividade baixa de 3,004 s sob carga.
- `Big e Danilo` está salva, disponível com sinal de -43 dBm e anuncia suporte a 802.11ax.
- O DNS resolve corretamente; os valores 8.8.8.8 e 1.1.1.1 estão configurados como domínios de busca, mas não explicam a baixa taxa de enlace observada.

## Hipótese confirmada

A seleção automática do AP `Big e Danilo Quarto`, limitado a 802.11n/2,4 GHz, mantém o Mac em uma conexão mais lenta apesar da disponibilidade da rede principal.

## Mudança proposta

1. Conectar à rede já salva `Big e Danilo`.
2. Confirmar SSID, modo PHY, canal, RSSI, SNR e taxa negociada.
3. Repetir ping ao gateway e `networkQuality -v`.
4. Só considerar correção dos domínios de busca DNS se persistirem sintomas de resolução.

## Rollback

Reconectar a `Big e Danilo Quarto` pelo painel Wi-Fi caso a rede principal apresente perda de estabilidade ou cobertura.

## Resultado da execução

- Conectado com sucesso a `Big e Danilo`.
- Enlace estável em 802.11ax, canal 149, 5 GHz/80 MHz.
- Sinal observado entre -57 e -59 dBm; ruído entre -88 e -89 dBm.
- Taxa PHY observada entre 137 e 576 Mbps, terminando em 567 Mbps.
- Ping final ao roteador: 0% de perda, média de 5,245 ms.
- Ping final à Internet: 0% de perda, média de 14,674 ms.
- O Fast.com caiu de 820 Kbps para 310 Kbps, apesar do enlace Wi-Fi permanecer forte.
- Low Data Mode e Limit IP Address Tracking estavam desligados; proxies também estavam desligados.

## Conclusão

A troca corrigiu a associação lenta ao AP `Big e Danilo Quarto`, mas a degradação de Internet persiste sem degradação correspondente no rádio Wi-Fi. A causa provável está no roteador, na fila de tráfego (bufferbloat/QoS) ou no enlace da operadora. Próxima ação recomendada: reiniciar e auditar o roteador, comparar outro dispositivo no mesmo SSID e testar Ethernet antes de alterar novamente o Mac.

## Diagnóstico após reinício do roteador

- O problema persistiu após o reinício.
- Enlace Wi-Fi: 802.11ax, 5 GHz/80 MHz, 576 Mbps, sinal de -55 dBm.
- Durante 60 segundos sob carga, gateway e Internet tiveram 0% de perda e médias de 7,975 ms e 9,957 ms.
- `networkQuality`: 40,345 Mbps de upload, 575,115 Kbps de download, responsividade de 8,073 s.
- HTTP/1.1, HTTP/2 e HTTP/3 apresentaram download degradado; HTTP/3 terminou com erro de protocolo.
- Não houve retransmissões TCP relevantes nem processo local saturando a banda.
- Não há VPN configurada ou conectada.
- Screen Time mantém `Limit Adult Websites`, instalando o filtro `com.apple.familycontrols.contentfilter`.

Próxima hipótese mínima: desativar temporariamente o filtro web do Screen Time, repetir os testes e restaurar a proteção se não houver melhora. Aguardando aprovação humana.
