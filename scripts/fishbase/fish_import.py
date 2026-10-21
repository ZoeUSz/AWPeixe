#!/usr/bin/env python3
import pathlib
import urllib.request

import pandas as pd

VERSAO = "v25.04"
BASE = f"https://huggingface.co/datasets/cboettig/fishbase/resolve/main/data/fb/{VERSAO}/parquet"
TABELAS = ["species", "ecology", "spawning", "aquarium", "aquamaint", "oxygen", "comnames"]

# Confira se batem com a coluna nome_cientifico do seu banco
ESPECIES = [
    "Danio rerio", "Poecilia reticulata", "Carassius auratus",
    "Betta splendens", "Oreochromis niloticus", "Paracheirodon axelrodi",
    "Colossoma macropomum", "Pterophyllum scalare", "Labidochromis caeruleus",
]

cache = pathlib.Path("cache_fishbase")
saida = pathlib.Path("saida_fishbase")
cache.mkdir(exist_ok=True)
saida.mkdir(exist_ok=True)


def baixar(nome: str) -> pd.DataFrame:
    destino = cache / f"{nome}.parquet"
    if not destino.exists():
        print(f"Baixando {nome}...")
        urllib.request.urlretrieve(f"{BASE}/{nome}.parquet", destino)
    return pd.read_parquet(destino)


print(f"FishBase versão {VERSAO} (via cboettig/fishbase, Hugging Face)\n")

sp = baixar("species")
sp["nome_cientifico"] = sp["Genus"].str.strip() + " " + sp["Species"].str.strip()
alvo = sp[sp["nome_cientifico"].isin(ESPECIES)].copy()

faltando = set(ESPECIES) - set(alvo["nome_cientifico"])
if faltando:
    print("NÃO ENCONTRADAS (grafia ou sinônimo):", sorted(faltando), "\n")

codigos = set(alvo["SpecCode"])
mapa = alvo[["SpecCode", "nome_cientifico"]]
tabelas = {}

for nome in TABELAS:
    df = alvo if nome == "species" else baixar(nome)
    if "SpecCode" not in df.columns:
        print(f"[{nome}] sem coluna SpecCode, ignorada")
        continue
    sub = df[df["SpecCode"].isin(codigos)].copy()
    if nome != "species":
        sub = sub.merge(mapa, on="SpecCode", how="left")
    sub.to_csv(saida / f"{nome}.csv", index=False, encoding="utf-8")
    tabelas[nome] = sub
    print(f"[{nome}] {len(sub)} linhas, {len(sub.columns)} colunas -> saida_fishbase/{nome}.csv")

print("\n=== COLUNAS DE CADA TABELA ===")
for nome, df in tabelas.items():
    print(f"\n[{nome}]\n{list(df.columns)}")

print("\n=== COLUNAS QUE MENCIONAM pH, dH, temperatura, tanque ou aquário ===")
for nome, df in tabelas.items():
    achadas = [c for c in df.columns if any(k in c.lower() for k in ("ph", "dh", "temp", "tank", "aquar"))]
    if achadas:
        print(f"[{nome}] {achadas}")

campos = [c for c in ["nome_cientifico", "FBname", "Length", "Weight", "LongevityWild", "DemersPelag"] if c in alvo.columns]
print("\n=== RESUMO (species) ===")
print(alvo[campos].to_string(index=False))

if "comnames" in tabelas and "Language" in tabelas["comnames"].columns:
    pt = tabelas["comnames"]
    pt = pt[pt["Language"].astype(str).str.contains("Portu", case=False)]
    print("\n=== NOMES POPULARES EM PORTUGUÊS ===")
    print(pt[["nome_cientifico", "ComName"]].to_string(index=False))