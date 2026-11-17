#!/usr/bin/env python3
"""Simulador de sensores e do alimentador do aquário.

Envia leituras de temperatura e pH para a API (POST /leituras) a cada poucos
segundos, no lugar do ESP32. As faixas vêm da espécie escolhida no tanque.
Também registra alimentações (POST /alimentacoes), como o alimentador automático.

Uso:
    python3 simulador.py                      # valores dentro da faixa
    python3 simulador.py --modo temp-alta     # temperatura acima do máximo (cooler)
    python3 simulador.py --modo temp-baixa    # temperatura abaixo do mínimo (aquecedor)
    python3 simulador.py --modo ph-baixo      # pH abaixo do mínimo
    python3 simulador.py --modo ph-alto       # pH acima do máximo
    python3 simulador.py --modo ambos         # temperatura alta e pH baixo
    python3 simulador.py --intervalo 2        # uma leitura a cada 2 s
    python3 simulador.py --quantidade 10      # envia 10 rodadas e para
    python3 simulador.py --alimentar 30       # alimenta a cada 30 s
    python3 simulador.py --alimentar 0        # sem alimentador
    python3 simulador.py --porcoes 3          # porções fixas (padrão: 1 a 3 sorteadas)
    python3 simulador.py --so-tanque-principal # alimenta só o tanque das leituras

O alimentador sorteia, a cada vez, um dos tanques cadastrados (GET /tanques)
e a quantidade de porções. Se não conseguir listar os tanques, usa o principal.

Credenciais (as mesmas da API), pelas variáveis de ambiente:
    SECURITY_USERNAME e SECURITY_PASSWORD
"""
import argparse
import os
import random
import sys
import time

import requests

TANQUE_ID = "00000000-0000-0000-0000-000000000002"
SENSOR_TEMPERATURA = "00000000-0000-0000-0000-000000000011"
SENSOR_PH = "00000000-0000-0000-0000-000000000012"

MODOS = ["normal", "temp-alta", "temp-baixa", "ph-baixo", "ph-alto", "ambos"]

# Usadas só se o tanque ainda não tiver espécie escolhida
FAIXA_PADRAO = {"TEMPERATURA": (24.0, 28.0), "PH": (6.8, 7.5)}


def ler_faixas(base, auth, tanque_id):
    """Pergunta à API qual é a faixa ideal da espécie atual do tanque."""
    faixas = dict(FAIXA_PADRAO)
    resp = requests.get(f"{base}/tanques/{tanque_id}/status", auth=auth, timeout=5)
    resp.raise_for_status()
    dados = resp.json()
    for p in dados["parametros"]:
        if p["min"] is not None and p["max"] is not None:
            faixas[p["tipo"]] = (float(p["min"]), float(p["max"]))
    return dados.get("especie"), faixas


def dentro(faixa):
    """Valor sorteado na parte central da faixa (evita ficar colado no limite)."""
    minimo, maximo = faixa
    folga = (maximo - minimo) * 0.2
    return random.uniform(minimo + folga, maximo - folga)


def gerar_valores(modo, faixas):
    temperatura = dentro(faixas["TEMPERATURA"])
    ph = dentro(faixas["PH"])
    if modo in ("temp-alta", "ambos"):
        temperatura = faixas["TEMPERATURA"][1] + random.uniform(1.0, 3.0)
    if modo == "temp-baixa":
        temperatura = faixas["TEMPERATURA"][0] - random.uniform(1.0, 3.0)
    if modo in ("ph-baixo", "ambos"):
        ph = faixas["PH"][0] - random.uniform(0.5, 1.5)
    if modo == "ph-alto":
        ph = faixas["PH"][1] + random.uniform(0.5, 1.5)
    return round(temperatura, 1), round(ph, 2)


def enviar(base, auth, sensor_id, valor):
    resp = requests.post(
        f"{base}/leituras",
        json={"sensorId": sensor_id, "valor": valor},
        auth=auth,
        timeout=5,
    )
    return resp.status_code


def listar_tanques(base, auth, principal):
    """Busca os tanques cadastrados na API. Devolve [(id, nome), ...]."""
    try:
        resp = requests.get(f"{base}/tanques", auth=auth, timeout=5)
        resp.raise_for_status()
        dados = resp.json()
        if isinstance(dados, dict):  # caso a API devolva paginado
            dados = dados.get("content") or dados.get("tanques") or []
        tanques = []
        for t in dados:
            if not isinstance(t, dict) or not t.get("id"):
                continue
            especie = t.get("especie")
            if isinstance(especie, dict):
                especie = especie.get("nomeComum") or especie.get("nome")
            nome = t.get("nome") or especie or t["id"][:8]
            tanques.append((t["id"], str(nome)))
        if tanques:
            return tanques
    except (requests.RequestException, ValueError):
        pass
    return [(principal, "tanque principal")]


def alimentar(base, auth, tanque_id, porcoes):
    resp = requests.post(
        f"{base}/alimentacoes",
        json={"tanqueId": tanque_id, "porcoes": porcoes},
        auth=auth,
        timeout=5,
    )
    return resp.status_code


def main():
    parser = argparse.ArgumentParser(description="Simulador de sensores do aquário")
    parser.add_argument("--url", default="http://localhost:8080", help="endereço da API")
    parser.add_argument("--tanque", default=TANQUE_ID, help="id do tanque")
    parser.add_argument("--modo", default="normal", choices=MODOS)
    parser.add_argument("--intervalo", type=float, default=5.0, help="segundos entre rodadas")
    parser.add_argument("--quantidade", type=int, default=0,
                        help="número de rodadas (0 = até apertar Ctrl+C)")
    parser.add_argument("--alimentar", type=float, default=60.0,
                        help="segundos entre alimentações (0 = desligado)")
    parser.add_argument("--porcoes", type=int, default=0,
                        help="porções por alimentação (0 = sorteia de 1 a 3)")
    parser.add_argument("--so-tanque-principal", action="store_true",
                        help="alimenta só o tanque das leituras, sem sortear")
    args = parser.parse_args()

    usuario = os.environ.get("SECURITY_USERNAME")
    senha = os.environ.get("SECURITY_PASSWORD")
    if not usuario or not senha:
        sys.exit("Defina SECURITY_USERNAME e SECURITY_PASSWORD (veja o .env).")
    auth = (usuario, senha)

    try:
        especie, faixas = ler_faixas(args.url, auth, args.tanque)
    except requests.RequestException as erro:
        sys.exit(f"Não consegui falar com a API em {args.url}: {erro}")

    print(f"Espécie do tanque: {especie or '(nenhuma, usando faixa padrão)'}")
    print(f"Faixa temperatura: {faixas['TEMPERATURA']}  |  Faixa pH: {faixas['PH']}")
    print(f"Modo: {args.modo}  |  intervalo: {args.intervalo}s  (Ctrl+C para parar)")
    if args.so_tanque_principal:
        tanques = [(args.tanque, "tanque principal")]
    else:
        tanques = listar_tanques(args.url, auth, args.tanque)
    if args.alimentar > 0:
        qtd = f"{args.porcoes}" if args.porcoes > 0 else "1 a 3"
        nomes = ", ".join(n for _, n in tanques)
        print(f"Alimentador: {qtd} porção(ões) a cada {args.alimentar:g}s  |  tanques: {nomes}\n")
    else:
        print("Alimentador: desligado\n")

    rodada = 0
    proxima_alimentacao = time.monotonic()  # primeira alimentação logo no início
    try:
        while args.quantidade == 0 or rodada < args.quantidade:
            rodada += 1
            temperatura, ph = gerar_valores(args.modo, faixas)
            try:
                s1 = enviar(args.url, auth, SENSOR_TEMPERATURA, temperatura)
                s2 = enviar(args.url, auth, SENSOR_PH, ph)
                print(f"[{rodada}] temperatura={temperatura} °C (HTTP {s1})  "
                      f"pH={ph} (HTTP {s2})")
            except requests.RequestException as erro:
                print(f"[{rodada}] falha ao enviar: {erro}")

            if args.alimentar > 0 and time.monotonic() >= proxima_alimentacao:
                tanque_id, nome = random.choice(tanques)
                porcoes = args.porcoes if args.porcoes > 0 else random.randint(1, 3)
                try:
                    s3 = alimentar(args.url, auth, tanque_id, porcoes)
                    print(f"[{rodada}] alimentação: {nome} - {porcoes} porção(ões) (HTTP {s3})")
                except requests.RequestException as erro:
                    print(f"[{rodada}] falha ao alimentar: {erro}")
                # próximo intervalo varia 30% para cima ou para baixo
                proxima_alimentacao = time.monotonic() + args.alimentar * random.uniform(0.7, 1.3)

            time.sleep(args.intervalo)
    except KeyboardInterrupt:
        print("\nSimulador encerrado.")


if __name__ == "__main__":
    main()