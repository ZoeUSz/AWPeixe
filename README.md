# AWPeixe

Sistemática de monitoramento e automação para aquicultura: alimentação automática, monitoramento contínuo de temperatura e pH e controle da temperatura da água, com um banco de espécies de peixes que define a faixa ideal de cada parâmetro.

Trabalho de Conclusão de Curso em Engenharia de Computação, Centro Universitário Salesiano de São Paulo (UNISAL), 2026.

## Como funciona

```
Arduino Mega (pH) ──serial──> ESP32 ──HTTP──> API Spring Boot ──> PostgreSQL
                              │                    │                  │
              aquecedor, fan, alimentador    App Flutter         Metabase (BI)
```

1. O **Arduino Mega** lê o pH (PH-4502C) e envia o valor ao ESP32 pela serial.
2. O **ESP32** lê a temperatura (DS18B20) e envia temperatura e pH para a API.
3. A **API** grava as leituras, compara com a faixa ideal da espécie do tanque e gera alertas.
4. O **ESP32** consulta a faixa da espécie na API e controla os atuadores pelos relés: liga o aquecedor quando a água está abaixo do mínimo e a fan quando está acima do máximo. Também aciona o alimentador e registra cada alimentação na API.
5. O **app** mostra o estado do tanque, os alertas com a ação sugerida e as alimentações, com notificações no Android.
6. O **Metabase** apresenta o histórico em painéis de BI.

## Tecnologias

| Camada | Tecnologia |
|---|---|
| Hardware | ESP32, Arduino Mega 2560, DS18B20, PH-4502C, módulo de relés, motor de passo 28BYJ-48 |
| Firmware | C++ (Arduino IDE): OneWire, DallasTemperature, ArduinoJson |
| API | Java 21, Spring Boot 4, autenticação HTTP Basic |
| Banco de dados | PostgreSQL 16 (Docker), migrations com Flyway |
| App | Flutter (Android e Linux desktop) |
| BI | Metabase |
| Simulador | Python 3 (requests) |

## Estrutura do repositório

```
├── src/                       API Spring Boot e migrations Flyway (V1 a V15)
├── app/                       App Flutter
├── hardware/
│   ├── firmware/              Código do ESP32 e do Arduino Mega (ver README da pasta)
│   └── alimentador/           Modelos 3D de alimentador sugeridos (com créditos)
├── scripts/
│   ├── simulador/             Simulador de sensores e do alimentador
│   └── bi/                    Usuário somente leitura para o BI
├── docker-compose.yml         PostgreSQL e Metabase
└── .env.example               Modelo das variáveis de ambiente
```

## Como rodar

### Pré-requisitos

- Docker e Docker Compose
- Java 21
- Flutter (para o app)
- Arduino IDE com o pacote de placas ESP32 (para o hardware)
- Python 3 com `requests` (para o simulador)

### 1. Variáveis de ambiente

```bash
cp .env.example .env
```

Edite o `.env` e defina as senhas. O arquivo `.env` não vai para o repositório.

### 2. Banco de dados e Metabase

```bash
docker compose up -d
```

Na primeira execução da API, o Flyway cria as tabelas e carrega as espécies.

### 3. API

```bash
set -a; source .env; set +a
./mvnw spring-boot:run
```

A API fica em `http://localhost:8080`. Todas as rotas exigem HTTP Basic, com o usuário e a senha definidos no `.env`.

Para o ESP32 e o celular acessarem a API, o computador, o ESP32 e o celular precisam estar na mesma rede Wi-Fi, e a porta 8080 precisa estar liberada no firewall (no Linux com ufw: `sudo ufw allow 8080/tcp`).

### 4. Hardware

As ligações, a configuração do Wi-Fi e da API no `segredos.h` e a gravação do ESP32 e do Mega estão em [`hardware/firmware/README.md`](hardware/firmware/README.md).

### 5. App

```bash
cd app
flutter run -d linux
```

Para rodar no celular, informe o endereço da API na rede:

```bash
flutter run --release -d <id-do-aparelho> --dart-define=API_URL=http://<ip-do-computador>:8080
```

Depois do login, o app abre a escolha da espécie do tanque. Ao escolher uma espécie, o ESP32 passa a usar a faixa dela no controle da temperatura e o alimentador começa a funcionar.

### 6. Simulador (sem hardware)

Envia leituras e alimentações para a API no lugar do ESP32:

```bash
set -a; source .env; set +a
python3 scripts/simulador/simulador.py                    # valores normais
python3 scripts/simulador/simulador.py --modo temp-baixa  # aciona o alerta do aquecedor
```

Modos disponíveis: `normal`, `temp-alta`, `temp-baixa`, `ph-baixo`, `ph-alto`, `ambos`. Veja `python3 scripts/simulador/simulador.py --help` para todas as opções.

### 7. BI

Acesse `http://localhost:3000`. No Metabase, conecte ao banco com host `postgres` e o usuário somente leitura criado por `scripts/bi/bi_leitura.sql`. Os painéis usam as views `vw_leituras`, `vw_alertas`, `vw_alimentacoes` e `vw_especies`.

## Principais rotas da API

| Método | Rota | Descrição |
|---|---|---|
| GET | `/especies` | Lista as espécies cadastradas |
| GET | `/especies/grupos` | Espécies agrupadas por grupo hidroquímico |
| PUT | `/tanques/{id}/especie` | Define a espécie do tanque |
| GET | `/tanques/{id}/status` | Estado atual: espécie, leituras, faixas e alertas |
| POST | `/leituras` | Recebe uma leitura de sensor |
| POST | `/alimentacoes` | Registra uma alimentação |

## Espécies

O banco traz nove espécies, classificadas em grupos hidroquímicos pela faixa de temperatura e pH: tilápia-do-Nilo, tambaqui, kinguio, guppy, paulistinha, betta, neon cardeal, acará-bandeira e ciclídeo amarelo do Malawi. As faixas foram definidas a partir de literatura científica e de dados do FishBase e do SeriouslyFish.

## Créditos

- Fotos das espécies: Wikimedia Commons, sob licenças livres (créditos no app).
- Modelos 3D de alimentador: ver [`hardware/alimentador/README.md`](hardware/alimentador/README.md).

## Equipe

- Guilherme Tibúrcio Silva: banco de dados, API e app
- Theo Alves Amaral de Almeida: hardware e firmware

