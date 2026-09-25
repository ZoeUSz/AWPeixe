-- ================================
-- ATUALIZAÇÃO DA TABELA ESPECIE
-- Campos complementares (SeriouslyFish + refinamentos)
-- ================================

ALTER TABLE especie
    ADD COLUMN tamanho_minimo_tanque_litros DECIMAL(10,2),
    ADD COLUMN tipo_agua VARCHAR(20),              -- 'DOCE', 'SALGADA', 'SALOBRA'
    ADD COLUMN grupo_hidroquimico VARCHAR(100),    -- ramificação definida com o orientador (ex: 'Tropical Acido')
    ADD COLUMN imagem_url VARCHAR(255),
    ADD COLUMN habito_alimentar VARCHAR(100);      -- 'ONIVORO', 'CARNIVORO', 'HERBIVORO', 'DETRITIVORO', etc.

ALTER TABLE especie
    ALTER COLUMN comportamento TYPE TEXT;

COMMENT ON COLUMN especie.tamanho_minimo_tanque_litros IS 'Tamanho mínimo de tanque recomendado, em litros (fonte: SeriouslyFish)';
COMMENT ON COLUMN especie.grupo_hidroquimico IS 'Grupo definido manualmente com base em pH/temperatura, para ramificação por espécies';
COMMENT ON COLUMN especie.habito_alimentar IS 'Hábito alimentar da espécie (onívoro, carnívoro, herbívoro, etc.)';