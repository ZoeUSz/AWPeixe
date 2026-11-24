# Firmware do AWPeixe

Dois programas rodam no hardware do protótipo:

| Pasta | Placa | Função |
|---|---|---|
| `awpeixe_esp32/` | ESP32 (ESP32 Dev Module) | Lê a temperatura, recebe o pH do Mega, envia as leituras para a API, controla aquecedor e fan pela faixa da espécie e aciona o alimentador |
| `awpeixe_mega/` | Arduino Mega 2560 | Lê o módulo de pH e envia o valor para o ESP32 pela serial |

O ESP32 é o núcleo do sistema. O Mega entrou só para ler o pH, porque a saída do módulo PH-4502C vai até 5 V e o conversor analógico do ESP32 aceita no máximo 3,3 V.

## Ligações

### ESP32

| Componente | Pino do ESP32 | Observação |
|---|---|---|
| DS18B20 (dados) | GPIO 4 | Resistor de 4,7 kΩ entre o fio de dados e o 3V3 |
| pH vindo do Mega | GPIO 16 (RX2) | Pelo divisor de tensão abaixo |
| Relé do aquecedor | GPIO 26 (IN2) | Relé ativo em LOW |
| Relé da fan | GPIO 27 (IN1) | Relé ativo em LOW |
| Motor do alimentador (ULN2003) | GPIO 19, 18, 5 e 17 (IN1 a IN4) | Motor de passo 28BYJ-48 |
| Módulo de relés (VCC / GND) | VIN / GND | Jumper JD-VCC ligado |

### Arduino Mega

| Componente | Pino do Mega |
|---|---|
| Módulo PH-4502C: V+ | 5V |
| Módulo PH-4502C: G | GND |
| Módulo PH-4502C: Po | A0 |
| Saída para o ESP32 | TX1 (pino 18), pelo divisor de tensão |

Os pinos Do e To do módulo de pH ficam sem ligar.

### Divisor de tensão Mega → ESP32

O Mega envia 5 V e o ESP32 aceita 3,3 V. Com três resistores de 4,7 kΩ:

```
Pino 18 (Mega) ── 4,7k ──┬── GPIO 16 (ESP32)
                         │
                        4,7k
                         │
                        4,7k
                         │
                        GND
```

O GND do Mega precisa estar ligado ao GND do ESP32.

## Como gravar

### Bibliotecas (Arduino IDE → Gerenciar Bibliotecas)

- OneWire
- DallasTemperature
- ArduinoJson (versão 7, de Benoit Blanchon)

O suporte ao ESP32 vem do pacote de placas "esp32" da Espressif.

### Configurar o ESP32

1. Copie `awpeixe_esp32/segredos.exemplo.h` para `awpeixe_esp32/segredos.h`.
2. Preencha a rede Wi-Fi (2,4 GHz), o endereço da API e o usuário e a senha do `.env`.
3. O endereço da API é o IP do computador que roda a API **na mesma rede do ESP32**, por exemplo `http://192.168.0.10:8080`. No Linux, veja com `ip a`; no Windows, com `ipconfig`.

O `segredos.h` está no `.gitignore` e não deve ir para o repositório.

### Gravar

| Placa | Placa na IDE | Monitor Serial |
|---|---|---|
| ESP32 | ESP32 Dev Module | 115200 |
| Mega | Arduino Mega or Mega 2560 | 115200 |

Se o ESP32 travar em `Connecting...`, segure o botão BOOT até começar a gravação. No Linux, `ls -l /dev/serial/by-id/` mostra qual porta é de cada placa.

## Funcionamento

- A cada 5 s, o ESP32 lê a temperatura e envia temperatura e pH para a API (`POST /leituras`).
- A cada 10 s, consulta a espécie do tanque e a faixa ideal (`GET /tanques/{id}/status`).
- **Controle de temperatura:** liga o aquecedor abaixo do mínimo e a fan acima do máximo, com folga de 0,5 °C para não ficar ligando e desligando. Os dois nunca ficam ligados ao mesmo tempo.
- **Alimentador:** com uma espécie escolhida, dá uma volta do motor a cada 15 s e registra a alimentação na API (`POST /alimentacoes`). O intervalo está curto para demonstração; para uso real, aumente `INTERVALO_ALIMENTACAO`.
- **Tanque sem espécie:** aquecedor, fan e alimentador ficam desligados.
- **Falhas:** leituras inválidas do DS18B20 (-127 °C ou 85 °C) não são enviadas e desligam o aquecedor e a fan. Sem Wi-Fi, o ESP32 continua controlando os relés e tenta reconectar a cada 10 s.

### Comando pelo Monitor Serial do ESP32

| Comando | Ação |
|---|---|
| `a` | Alimenta na hora |

## Calibração e limitação do pH

O código do Mega converte tensão em pH com dois pontos de calibração (`V_PH7` e `V_PH4`):

1. Coloque a sonda na solução de pH 7 e anote a tensão mostrada no Monitor Serial.
2. Lave a sonda, coloque na solução de pH 4 e anote a tensão.
3. Preencha os dois valores no começo de `awpeixe_mega.ino` e grave de novo.

No protótipo, a sonda de baixo custo apresentou deriva e não manteve a calibração. O valor de pH deve ser tratado como indicativo. Uma sonda de grau industrial com calibração periódica é um dos trabalhos futuros.

A constante `MODO_SIMULACAO_AQUARIO` no código do Mega gera um pH simulado, só para testar a comunicação. Em uso normal ela fica `false`.