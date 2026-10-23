# Simulador de sensores

Envia leituras de temperatura e pH para a API (`POST /leituras`) no lugar do
Raspberry Pi. Serve para testar a API e o aplicativo antes de os sensores
reais estarem prontos, e como plano B na apresentação.

As faixas dos valores vêm da espécie escolhida no tanque (`GET /tanques/{id}/status`),
então o simulador acompanha a espécie, seja qual for.

## Requisitos

- Python 3.9 ou superior
- API rodando (`./run-local.sh`) e banco com as migrations V1 a V7 aplicadas
- Uma espécie escolhida no tanque (`PUT /tanques/{id}/especie`). Sem ela, o
  simulador usa uma faixa padrão

## Instalação

```bash
cd scripts/simulador
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Credenciais

O simulador usa o mesmo usuário e senha da API, lidos das variáveis de ambiente
`SECURITY_USERNAME` e `SECURITY_PASSWORD`. Para carregá-las do `.env` da raiz:

```bash
set -a; source ../../.env; set +a
```

## Uso

```bash
python3 simulador.py                    # valores dentro da faixa da espécie
python3 simulador.py --modo temp-alta   # temperatura acima do máximo
python3 simulador.py --modo ph-baixo    # pH abaixo do mínimo
python3 simulador.py --modo ambos       # temperatura e pH fora da faixa
python3 simulador.py --intervalo 2      # uma rodada a cada 2 segundos
python3 simulador.py --quantidade 10    # envia 10 rodadas e para
```

| Opção | Padrão | Descrição |
| --- | --- | --- |
| `--url` | `http://localhost:8080` | Endereço da API |
| `--tanque` | tanque da V7 | Id do tanque consultado |
| `--modo` | `normal` | `normal`, `temp-alta`, `ph-baixo` ou `ambos` |
| `--intervalo` | `5` | Segundos entre as rodadas |
| `--quantidade` | `0` | Número de rodadas (0 = até apertar Ctrl+C) |

Cada rodada envia uma leitura de temperatura e uma de pH. A saída mostra o valor
enviado e o código HTTP (`201` quer dizer que a API gravou).

## Como verificar

Com o simulador rodando, consulte `GET /tanques/{id}/status`:

- modo `normal`: `statusGeral` deve ser `OK`;
- modo `temp-alta`, `ph-baixo` ou `ambos`: deve virar `ALERTA`, com o parâmetro
  correspondente como `ACIMA` ou `ABAIXO`.

## Ids usados (V7)

| Item | Id |
| --- | --- |
| Tanque | `00000000-0000-0000-0000-000000000002` |
| Sensor de temperatura | `00000000-0000-0000-0000-000000000011` |
| Sensor de pH | `00000000-0000-0000-0000-000000000012` |

## Integração com o Raspberry Pi

O Raspberry deve enviar a mesma requisição que o simulador, com autenticação Basic:

```http
POST /leituras
Content-Type: application/json

{"sensorId": "00000000-0000-0000-0000-000000000012", "valor": 7.2}
```

Quando os sensores reais estiverem prontos, nada muda na API nem no aplicativo.
