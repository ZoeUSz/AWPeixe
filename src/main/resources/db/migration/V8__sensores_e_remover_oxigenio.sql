-- O oxigênio não será medido no protótipo: remove as faixas de oxigênio da espécie.
ALTER TABLE especie DROP COLUMN IF EXISTS oxigenio_min;
ALTER TABLE especie DROP COLUMN IF EXISTS oxigenio_max;

-- Modelos reais dos sensores (relatório, Quadro 5).
UPDATE sensor SET modelo = 'DS18B20'  WHERE id = '00000000-0000-0000-0000-000000000011';
UPDATE sensor SET modelo = 'PH-4502C' WHERE id = '00000000-0000-0000-0000-000000000012';