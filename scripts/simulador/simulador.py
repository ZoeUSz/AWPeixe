#!/usr/bin/env python3
"""Simulador de sensores do aquário.

Envia leituras de temperatura e pH para a API (POST /leituras) a cada poucos
segundos, no lugar do Raspberry Pi. As faixas vêm da espécie escolhida no tanque.

Uso:
    python3 simulador.py                      # valores dentro da faixa
    python3 simulador.py --modo temp-alta     # temperatura acima do máximo
    python3 simulador.py --modo ph-baixo      # pH abaixo do mínimo
    python3 simulador.py --modo ambos         # os dois fora da faixa
    python3 simulador.py --intervalo 2        # uma leitura a cada 2 s
    python3 simulador.py --quantidade 10      # envia 10 rodadas e para

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
    if modo in ("ph-baixo", "ambos"):
        ph = faixas["PH"][0] - random.uniform(0.5, 1.5)
    return round(temperatura, 1), round(ph, 2)


def enviar(base, auth, sensor_id, valor):
    resp = requests.post(
        f"{base}/leituras",
        json={"sensorId": sensor_id, "valor": valor},
        auth=auth,
        timeout=5,
    )
    return resp.status_code


def main():
    parser = argparse.ArgumentParser(description="Simulador de sensores do aquário")
    parser.add_argument("--url", default="http://localhost:8080", help="endereço da API")
    parser.add_argument("--tanque", default=TANQUE_ID, help="id do tanque")
    parser.add_argument("--modo", default="normal",
                        choices=["normal", "temp-alta", "ph-baixo", "ambos"])
    parser.add_argument("--intervalo", type=float, default=5.0, help="segundos entre rodadas")
    parser.add_argument("--quantidade", type=int, default=0,
                        help="número de rodadas (0 = até apertar Ctrl+C)")
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
    print(f"Modo: {args.modo}  |  intervalo: {args.intervalo}s  (Ctrl+C para parar)\n")

    rodada = 0
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
            time.sleep(args.intervalo)
    except KeyboardInterrupt:
        print("\nSimulador encerrado.")


if __name__ == "__main__":
    main()