-- Alinha as faixas da tilápia-do-Nilo com o Quadro 1 do relatório
-- (Lima et al., 2024; Mastelini e Mollo Neto, 2022):
-- temperatura de 26 a 30 °C e pH de 6,5 a 8,5.
--
-- Pela regra do Quadro 6, a tilápia continua Tropical (máximo acima de 25 °C),
-- mas o pH passa de Alcalino (mínimo >= 7,0) para Neutro (mínimo 6,5).
-- O grupo é copiado do paulistinha, que também é Tropical Neutro, para manter
-- exatamente o mesmo texto já usado no banco.
UPDATE especie
SET temp_min = 26,
    temp_max = 30,
    ph_min = 6.5,
    ph_max = 8.5,
    grupo_hidroquimico = (
        SELECT grupo_hidroquimico FROM especie WHERE nome_cientifico = 'Danio rerio'
    )
WHERE nome_cientifico = 'Oreochromis niloticus';
