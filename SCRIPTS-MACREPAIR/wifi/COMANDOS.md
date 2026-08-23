# Guia Operacional: Scripts de Wi-Fi macOS

Ferramentas otimizadas para diagnósticos, resolução de problemas e sintonia fina de rede Wi-Fi no macOS (Apple Silicon M1/M2/M3/M4 e Intel) compatíveis com Monterey, Ventura, Sonoma e Sequoia.

---

## 🚀 1. Motor Unificado (`wifi_engine.sh`) — Recomendado

O `wifi_engine.sh` consolida todas as funções de diagnóstico, otimização, gerenciamento de DNS e análise de AWDL em uma única interface de linha de comando.

### Tornar executável

```bash
chmod +x SCRIPTS-MACREPAIR/wifi/wifi_engine.sh
```

### Comandos Principais

#### 1.1. Otimização Rápida de Conexão

Executa flush DNS, recarregamento do `mDNSResponder`, ciclo seguro do rádio Wi-Fi e renovação do lease DHCP com polling de IP:

```bash
./SCRIPTS-MACREPAIR/wifi/wifi_engine.sh --optimize
```

#### 1.2. Diagnóstico Completo de Sinal e Desempenho

Verifica RSSI, ruído, taxa de transmissão (Tx Rate), latência de gateway dinâmico, alcance à internet e responsividade de bufferbloat (`networkQuality`):

```bash
./SCRIPTS-MACREPAIR/wifi/wifi_engine.sh --diag
```

#### 1.3. Diagnóstico e Salvamento Automático de Relatório

Executa o diagnóstico exibindo tudo em tempo real no terminal e grava o arquivo de log no Desktop:

```bash
./SCRIPTS-MACREPAIR/wifi/wifi_engine.sh --diag --report
```

#### 1.4. Gestão Segura de DNS (com Backup Automático)

Aplica servidores DNS de alto desempenho ou restaura para o padrão automático do roteador:

```bash
# Aplicar Cloudflare DNS (1.1.1.1 / 1.0.0.1)
./SCRIPTS-MACREPAIR/wifi/wifi_engine.sh --dns cloudflare

# Aplicar Google Public DNS (8.8.8.8 / 8.8.4.4)
./SCRIPTS-MACREPAIR/wifi/wifi_engine.sh --dns google

# Restaurar para DNS Automático do Roteador (DHCP)
./SCRIPTS-MACREPAIR/wifi/wifi_engine.sh --dns dhcp
```

#### 1.5. Verificação de AWDL (Apple Wireless Direct Link / AirDrop Jitter)

Analisa a interface `awdl0` para investigar variações de ping em jogos ou chamadas de vídeo:

```bash
./SCRIPTS-MACREPAIR/wifi/wifi_engine.sh --awdl
```

---

## 🛠️ 2. Scripts Modulares Especializados

Caso prefira executar scripts isolados:

### 2.1. Otimização e Diagnóstico Rápido

```bash
chmod +x SCRIPTS-MACREPAIR/wifi/optimize_wifi.sh
./SCRIPTS-MACREPAIR/wifi/optimize_wifi.sh
```

### 2.2. Limpeza Rápida de Cache DNS e Interface

```bash
chmod +x SCRIPTS-MACREPAIR/wifi/clean-cache.sh
./SCRIPTS-MACREPAIR/wifi/clean-cache.sh
```

### 2.3. Correção de Conexão com DNS Cloudflare e Relatório

```bash
chmod +x SCRIPTS-MACREPAIR/wifi/wifi_correcao_otimizacao.sh
./SCRIPTS-MACREPAIR/wifi/wifi_correcao_otimizacao.sh
```

### 2.4. Diagnóstico Completo de Rede e Exportação

```bash
chmod +x SCRIPTS-MACREPAIR/wifi/wifi_diagnostico_completo.sh
./SCRIPTS-MACREPAIR/wifi/wifi_diagnostico_completo.sh
```
