#!/usr/bin/env python3
"""Extrai dados biométricos do FishBase (snapshot v25.04) para as espécies do TCC.

Uso:
    python3 fish_import.py              # saída compacta + SVG para documentação
    python3 fish_import.py --colunas    # lista todas as colunas de cada tabela
    python3 fish_import.py --largura 90 # largura do SVG exportado (padrão: 100)
"""
import argparse
import io
import pathlib
import re
import urllib.request

import pandas as pd
from rich import box
from rich.console import Console
from rich.panel import Panel
from rich.table import Table

VERSAO = "v25.04"
BASE = f"https://huggingface.co/datasets/cboettig/fishbase/resolve/main/data/fb/{VERSAO}/parquet"
TABELAS = ["species", "ecology", "spawning", "aquarium", "aquamaint", "oxygen", "comnames"]

# Confira se batem com a coluna nome_cientifico do banco
ESPECIES = [
    "Danio rerio", "Poecilia reticulata", "Carassius auratus",
    "Betta splendens", "Oreochromis niloticus", "Paracheirodon axelrodi",
    "Colossoma macropomum", "Pterophyllum scalare", "Labidochromis caeruleus",
]

cache = pathlib.Path("cache_fishbase")
saida = pathlib.Path("saida_fishbase")
cache.mkdir(exist_ok=True)
saida.mkdir(exist_ok=True)

console = Console()
registro = []  # tudo que foi mostrado, para exportar o SVG depois


def mostrar(obj):
    registro.append(obj)
    console.print(obj)


def fmt(valor, casas=0):
    return "—" if pd.isna(valor) else f"{valor:.{casas}f}"


def relevante(coluna: str) -> bool:
    """Colunas de pH/dH (ph, phmin, dhmax...), temperatura, tanque ou aquário."""
    c = coluna.lower()
    return bool(re.match(r"^(ph|dh)(min|max|low|high)?$", c)) or any(
        k in c for k in ("temp", "tank", "aquar")
    )


def baixar(nome: str) -> pd.DataFrame:
    destino = cache / f"{nome}.parquet"
    if not destino.exists():
        mostrar(f"[cyan]Baixando[/cyan] {nome}...")
        urllib.request.urlretrieve(f"{BASE}/{nome}.parquet", destino)
    return pd.read_parquet(destino)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--colunas", action="store_true", help="lista todas as colunas")
    parser.add_argument("--largura", type=int, default=100, help="largura do SVG")
    args = parser.parse_args()

    mostrar(Panel.fit(
        f"[bold]FishBase {VERSAO}[/bold]\nvia cboettig/fishbase (Hugging Face) · CC-BY-NC 4.0",
        title="fish_import.py",
    ))

    sp = baixar("species")
    sp["nome_cientifico"] = sp["Genus"].str.strip() + " " + sp["Species"].str.strip()
    alvo = sp[sp["nome_cientifico"].isin(ESPECIES)].copy()

    faltando = sorted(set(ESPECIES) - set(alvo["nome_cientifico"]))
    if faltando:
        mostrar(f"[yellow]Não encontradas (grafia ou sinônimo):[/yellow] {', '.join(faltando)}")

    codigos = set(alvo["SpecCode"])
    mapa = alvo[["SpecCode", "nome_cientifico"]]
    tabelas = {}

    for nome in TABELAS:
        df = alvo if nome == "species" else baixar(nome)
        if "SpecCode" not in df.columns:
            continue
        sub = df[df["SpecCode"].isin(codigos)].copy()
        if nome != "species":
            sub = sub.merge(mapa, on="SpecCode", how="left")
        sub.to_csv(saida / f"{nome}.csv", index=False, encoding="utf-8")
        tabelas[nome] = sub

    # --- Tabelas carregadas ---
    t1 = Table(title="Tabelas filtradas para as espécies do TCC", box=box.SIMPLE_HEAD)
    t1.add_column("Tabela")
    t1.add_column("Linhas", justify="right")
    t1.add_column("Colunas", justify="right")
    for nome, df in tabelas.items():
        t1.add_row(nome, str(len(df)), str(len(df.columns)))
    mostrar(t1)

    # --- Colunas ---
    if args.colunas:
        for nome, df in tabelas.items():
            mostrar(f"[bold]{nome}[/bold]: {', '.join(df.columns)}")
    else:
        t2 = Table(title="Colunas que mencionam pH, dH, temperatura, tanque ou aquário",
                   box=box.SIMPLE_HEAD)
        t2.add_column("Tabela")
        t2.add_column("Colunas")
        for nome, df in tabelas.items():
            achadas = [c for c in df.columns if relevante(c)]
            if achadas:
                t2.add_row(nome, ", ".join(achadas))
        mostrar(t2)

    # --- Resumo biométrico ---
    t3 = Table(title="Dados biométricos (FishBase)", box=box.SIMPLE_HEAD)
    t3.add_column("Espécie", style="italic")
    t3.add_column("Nome (FishBase)")
    t3.add_column("Comp. máx. (cm)", justify="right")
    t3.add_column("Peso máx. (g)", justify="right")
    t3.add_column("Longevidade (anos)", justify="right")
    ordem = {n: i for i, n in enumerate(ESPECIES)}
    for _, r in alvo.sort_values("nome_cientifico", key=lambda s: s.map(ordem)).iterrows():
        t3.add_row(
            r["nome_cientifico"], str(r.get("FBname", "—")),
            fmt(r.get("Length"), 1), fmt(r.get("Weight"), 0), fmt(r.get("LongevityWild"), 0),
        )
    mostrar(t3)

    # --- Nomes populares em português ---
    if "comnames" in tabelas and "Language" in tabelas["comnames"].columns:
        pt = tabelas["comnames"]
        pt = pt[pt["Language"].astype(str).str.contains("Portu", case=False)]
        t4 = Table(title="Nomes populares em português", box=box.SIMPLE_HEAD)
        t4.add_column("Espécie", style="italic")
        t4.add_column("Nomes")
        for nome_cient in ESPECIES:
            nomes = list(dict.fromkeys(
                pt.loc[pt["nome_cientifico"] == nome_cient, "ComName"].astype(str).str.strip()
            ))
            if nomes:
                extra = f" (+{len(nomes) - 4})" if len(nomes) > 4 else ""
                t4.add_row(nome_cient, ", ".join(nomes[:4]) + extra)
        mostrar(t4)

    # --- Exporta o mesmo conteúdo como SVG de largura fixa (para o artigo) ---
    svg_console = Console(record=True, width=args.largura, file=io.StringIO(),
                          force_terminal=True, color_system="truecolor")
    for obj in registro:
        svg_console.print(obj)
    destino_svg = saida / "terminal.svg"
    svg_console.save_svg(str(destino_svg), title="fish_import.py")
    console.print(f"\n[green]SVG para documentação:[/green] {destino_svg}")


if __name__ == "__main__":
    main()