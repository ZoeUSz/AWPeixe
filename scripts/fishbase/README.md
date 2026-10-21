# Importação de dados do FishBase

Script usado para extrair dados biométricos (comprimento, peso, longevidade)
das espécies do banco. Os valores obtidos foram inseridos manualmente na
migration `V5__fishbase_biometria.sql`.

- Fonte: FishBase, snapshot v25.04, via dataset `cboettig/fishbase` (Hugging Face)
- Licença dos dados: CC-BY-NC 4.0 (uso não comercial, com atribuição)
- Motivo do script: a API REST antiga do FishBase foi substituída por arquivos
  de dados versionados (Parquet)

## Como rodar
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python3 fish_import.py

Gera `cache_fishbase/` (arquivos baixados) e `saida_fishbase/` (CSVs filtrados).
Esses dois diretórios não são versionados.
