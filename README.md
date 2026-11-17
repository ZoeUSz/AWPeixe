# AWPeixe

Sistemática de monitoramento e automação para aquicultura: alimentação, monitoramento
contínuo de temperatura e pH e tratamento autônomo da água, com um banco de espécies
de peixes que define a faixa ideal de cada parâmetro.

Trabalho de Conclusão de Curso em Engenharia de Computação (2026).

## Como funciona

```
ESP32 (sensores e atuadores) ──HTTP──> API Spring Boot ──> PostgreSQL
                                           │                   │
                               App Flutter (Android/Linux)   Metabase (BI)
```

1. O **ESP32** lê a temperatura (DS18B20) e o pH (PH-4502C) e envia as leituras para a API.
2. A **API** grava as leituras, compara com a faixa ideal da espécie do tanque e gera alertas.
3. O **app** mostra o estado do tanque, os alertas com a ação sugerida (ligar aquecedor,
   ligar cooler, corrigir pH) e as alimentações, com notificações no Android.
4. O **Metabase** apresenta os dados históricos em painéis de BI.

O ESP32 também aciona os atuadores pelo módulo de relés (aquecedor, cooler e bomba)
e o alimentador automático (servo), registrando cada alimentação na API.

## Tecnologias

| Camada         | Tecnologia                                        |
|----------------|---------------------------------------------------|
| Hardware       | ESP32, DS18B20, PH-4502C, módulo de relés, servo  |
| API            | Java 21, Spring Boot 4, HTTP Basic                |
| Banco de dados | PostgreSQL 16 (Docker), migrations com Flyway     |
| App            | Flutter (Android e Linux desktop)                 |
| BI             | Metabase                                          |
| Simulador      | Python 3 (requests)                               |

## Estrutura do repositório

```
├── src/                   API Spring Boot e migrations Flyway (V1 a V15)
├── app/                   App Flutter
├── scripts/
│   ├── simulador/         Simulador de sensores e do alimentador
│   └── bi/                Usuário somente leitura para o BI
├── hardware/alimentador/  Modelos 3D de alimentador sugeridos (com créditos)
├── docker-compose.yml     PostgreSQL e Metabase
└── .env.example           Modelo das variáveis de ambiente
```

## Como rodar

### Pré-requisitos

- Docker e Docker Compose
- Java 21
- Flutter (para o app)
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

A API fica em `http://localhost:8080`. Todas as rotas exigem HTTP Basic, com o usuário
e a senha definidos no `.env`.

### 4. App

```bash
cd app
flutter run -d linux
```

Para rodar no celular, informe o endereço da API:

```bash
flutter run --release -d <id-do-aparelho> --dart-define=API_URL=http://<ip-do-computador>:8080
```

### 5. Simulador (sem hardware)

Envia leituras e alimentações para a API, no lugar do ESP32:

```bash
set -a; source .env; set +a
python3 scripts/simulador/simulador.py                    # valores normais
python3 scripts/simulador/simulador.py --modo temp-baixa  # aciona o alerta do aquecedor
```

Modos disponíveis: `normal`, `temp-alta`, `temp-baixa`, `ph-baixo`, `ph-alto`, `ambos`.
Veja `python3 scripts/simulador/simulador.py --help` para todas as opções.

### 6. BI

Acesse `http://localhost:3000`. No Metabase, conecte ao banco com host `postgres` e o
usuário somente leitura criado por `scripts/bi/bi_leitura.sql`. Os painéis usam as
views `vw_leituras`, `vw_alertas`, `vw_alimentacoes` e `vw_especies`.

## Principais rotas da API

| Método | Rota                       | Descrição                                     |
|--------|----------------------------|-----------------------------------------------|
| GET    | `/especies`                | Lista as espécies cadastradas                 |
| GET    | `/especies/grupos`         | Espécies agrupadas por grupo hidroquímico     |
| PUT    | `/tanques/{id}/especie`    | Define a espécie do tanque                    |
| GET    | `/tanques/{id}/status`     | Estado atual: leituras, faixas e alertas      |
| POST   | `/leituras`                | Recebe uma leitura de sensor                  |
| POST   | `/alimentacoes`            | Registra uma alimentação                      |

## Espécies

O banco traz nove espécies, classificadas em grupos hidroquímicos pela faixa de
temperatura e pH: tilápia-do-Nilo, tambaqui, kinguio, guppy, paulistinha, betta,
neon cardeal, acará-bandeira e ciclídeo amarelo do Malawi. As faixas foram definidas a
partir de literatura científica e de dados do FishBase e do SeriouslyFish.

## Créditos

- Fotos das espécies: Wikimedia Commons, sob licenças livres (créditos no app).
- Modelos 3D de alimentador: ver `hardware/alimentador/README.md`.

## Equipe

- [Nome] — banco de dados, API e app
- [Nome] — hardware e firmware

Orientação: [Nome do orientador]
[Nome da instituição]
