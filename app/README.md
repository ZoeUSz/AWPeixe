# AquaMonitor (aplicativo Flutter)

Aplicativo do TCC de monitoramento de aquário. Ele consulta a API Spring Boot
e mostra se a temperatura e o pH da água estão dentro da faixa ideal da espécie
escolhida. Roda como aplicativo de desktop (Linux); o mesmo código pode gerar a
versão Android.

## Telas

- **Escolher espécie:** cards com foto, classificação (Água Fria ou Tropical;
  pH Ácido, Neutro ou Alcalino), faixas ideais e tanque mínimo. Busca por nome
  e filtros do Quadro 6 do relatório.
- **Monitoramento:** estado geral do tanque, cards de temperatura e pH com a
  faixa ideal, atualização a cada 3 segundos e selo vermelho com o número de
  alertas em andamento.
- **Histórico:** gráficos de temperatura e pH com a faixa ideal sombreada, para
  as últimas 30, 60 ou 120 leituras.
- **Alertas:** alertas em andamento e resolvidos, com a espécie, a ação
  indicada (cooler, aquecedor ou correção do pH), início, fim e duração.

## Requisitos

- Flutter SDK com suporte a desktop Linux (`flutter doctor` sem erros em
  "Linux toolchain").
- Banco e API no ar (veja o README da raiz do repositório).

## Como rodar

Na raiz do repositório, suba o banco e a API:

```bash
docker compose up -d
./run-local.sh
```

Em outro terminal, dentro de `app/`:

```bash
flutter pub get

set -a; source ../.env; set +a
flutter run -d linux \
  --dart-define=API_USER="$SECURITY_USERNAME" \
  --dart-define=API_PASS="$SECURITY_PASSWORD"
```

O usuário e a senha da API vêm do `.env` da raiz e são passados na hora de
executar. Eles não ficam escritos no código.

Para ver o app reagir a leituras, rode também o simulador de sensores
(`scripts/simulador/simulador.py`, modos `normal`, `temp-alta`, `ph-baixo` e
`ambos`).

Depois de mudar arquivos em `assets/` ou no `pubspec.yaml`, pare o app e rode
`flutter run` de novo. O hot reload não carrega assets novos.

## Estrutura

```
app/
├── assets/especies/     fotos das espécies (JPG)
├── pubspec.yaml         dependências (http, fl_chart) e declaração dos assets
└── lib/
    ├── main.dart
    ├── config.dart      endereço da API, tanque usado e credenciais
    ├── theme.dart       cores e tema (AppColors)
    ├── api.dart         chamadas à API (ApiClient)
    ├── fotos.dart       liga cada espécie à sua foto
    ├── models/          espécie, tanque, status, histórico, alerta
    └── pages/           espécies, monitoramento, histórico, alertas
```

## Fotos das espécies

As fotos ficam em `assets/especies/`, com estes nomes: `Acarabandeira.jpg`,
`Betta.jpg`, `CiclideodoMalawi.jpg`, `Guppy.jpg`, `Kinguio.jpg`,
`NeonCardeal.jpg`, `Paulistinha.jpg`, `Tambaqui.jpg` e `TilapiadoNilo.jpg`.
Use nomes sem acento e sem espaço.

Para incluir uma espécie nova: coloque o arquivo na pasta e acrescente uma
linha em `lib/fotos.dart`, com o nome científico e o nome comum (a busca ignora
acentos, espaços, hífens e maiúsculas). Sem foto, o card mostra um ícone.

As fotos vêm do Wikimedia Commons, com licença livre, e precisam de crédito ao
autor. Os créditos ficam em `assets/especies/CREDITOS.md`.

## Alertas e ação indicada

O app só mostra a ação indicada pela API (ligar o cooler, ligar o aquecedor ou
corrigir o pH). O acionamento físico dos atuadores é feito pelo ESP32, fora
deste aplicativo.