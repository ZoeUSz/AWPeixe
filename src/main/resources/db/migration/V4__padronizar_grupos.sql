-- ================================
-- PADRONIZAÇÃO DO GRUPO HIDROQUÍMICO
-- Grupo = classe de temperatura + classe de pH
--   Temperatura: temp_max <= 25 -> 'Água Fria', senão 'Tropical'
--   pH:          ph_max <= 6.5  -> 'Ácido'
--                ph_min >= 7.0  -> 'Alcalino'
--                demais         -> 'Neutro'
-- ================================

UPDATE especie
SET grupo_hidroquimico =
    CASE WHEN temp_max <= 25 THEN 'Água Fria' ELSE 'Tropical' END
    || ' ' ||
    CASE
        WHEN ph_max <= 6.5 THEN 'Ácido'
        WHEN ph_min >= 7.0 THEN 'Alcalino'
        ELSE 'Neutro'
    END
WHERE temp_max IS NOT NULL
  AND ph_min  IS NOT NULL
  AND ph_max  IS NOT NULL;

COMMENT ON COLUMN especie.grupo_hidroquimico IS
    'Classe de temperatura (Água Fria/Tropical) + classe de pH (Ácido/Neutro/Alcalino), calculada a partir das faixas da espécie';