# Alimentador automático

O protótipo do AWPeixe usa um alimentador próprio, reaproveitado de um projeto
anterior da equipe, acionado por um servo controlado pelo ESP32. A cada
acionamento, o ESP32 registra a alimentação na API (POST /alimentacoes), e o
app mostra o horário e a quantidade de porções.

Os modelos abaixo **não fazem parte do protótipo**. Ficam aqui como sugestão
para quem quiser imprimir um alimentador em 3D e integrar ao sistema.

## Sugestão 1: ração miúda (incluído neste repositório)

Indicado para flocos e micro grânulos: betta, guppy, paulistinha, neon cardeal,
kinguio e acará-bandeira.

Os arquivos 3D da pasta `STL/` são do projeto **TurtleFeederInator**,
de **kacpi2442** (2019), disponível em https://github.com/kacpi2442/TurtleFeederInator,
distribuído sob a licença MIT (cópia em `LICENSE`).
Os arquivos não foram modificados.

As instruções de montagem, a lista de peças (servo SG-90) e as configurações de
impressão estão no README do projeto original.

## Sugestão 2: ração em pellets (não incluído neste repositório)

Indicado para pellets maiores: tilápia-do-Nilo, tambaqui e ciclídeo do Malawi.

O modelo sugerido é o **28BYJ-48 driven Fish Feeder**, de [usuário do autor],
disponível em https://www.printables.com/model/11072-28byj-48-driven-fish-feeder.
Usa uma rosca sem fim movida por motor de passo 28BYJ-48 com driver ULN2003.
O modelo não informa licença, por isso não foi redistribuído aqui.