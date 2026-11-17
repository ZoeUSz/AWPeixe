# Alimentador automático

O alimentador do AWPeixe é acionado por um servo (SG-90) controlado pelo ESP32.
A cada acionamento, o ESP32 registra a alimentação na API (POST /alimentacoes),
e o app mostra o horário e a quantidade de porções.

## Modelo usado (incluído neste repositório)

Indicado para ração miúda (flocos e micro grânulos): betta, guppy, paulistinha,
neon cardeal, kinguio e acará-bandeira.

Os arquivos 3D da pasta `STL/` são do projeto **TurtleFeederInator**,
de **kacpi2442** (2019), disponível em https://github.com/kacpi2442/TurtleFeederInator,
distribuído sob a licença MIT (cópia em `LICENSE`).
Os arquivos foram usados sem modificação.

As instruções de montagem e as configurações de impressão estão no README
do projeto original.

## Referência (não incluído neste repositório)

Para espécies de ração em pellets maiores (tilápia, tambaqui, ciclídeo do Malawi),
o modelo de referência é o **28BYJ-48 driven Fish Feeder**, de [usuário do autor],
disponível em https://www.printables.com/model/11072-28byj-48-driven-fish-feeder.
O modelo não informa licença, por isso não foi redistribuído aqui.
