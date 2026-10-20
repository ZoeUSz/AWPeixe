-- ================================
-- INSERÇÃO DAS ESPÉCIES DO TCC
-- Grupo hidroquímico = classe de temperatura + classe de pH
-- tamanho_minimo_tanque_litros marcado CONFERIR: validar no SeriouslyFish
-- ================================

-- 1. Danio rerio (Paulistinha)
INSERT INTO especie (
    nome_cientifico, nome_comum, habitat, ph_min, ph_max, temp_min, temp_max,
    tipo_agua, grupo_hidroquimico, habito_alimentar, tamanho_minimo_tanque_litros, fonte
) VALUES (
    'Danio rerio', 'Paulistinha', 'Águas correntes e arrozais', 6.80, 7.50, 24.00, 30.00,
    'DOCE', 'Tropical Neutro', 'ONIVORO', 40.00, 'JoVE / Literatura Científica' -- CONFERIR tanque
);

-- 2. Poecilia reticulata (Guppy)
INSERT INTO especie (
    nome_cientifico, nome_comum, habitat, ph_min, ph_max, temp_min, temp_max,
    tipo_agua, grupo_hidroquimico, habito_alimentar, tamanho_minimo_tanque_litros, fonte
) VALUES (
    'Poecilia reticulata', 'Guppy', 'Riachos e fossas tropicais', 7.00, 8.00, 24.00, 28.00,
    'DOCE', 'Tropical Alcalino', 'ONIVORO', 40.00, 'UGM / BRIN' -- CONFERIR tanque
);

-- 3. Carassius auratus (Kinguio)
INSERT INTO especie (
    nome_cientifico, nome_comum, habitat, ph_min, ph_max, temp_min, temp_max,
    tipo_agua, grupo_hidroquimico, habito_alimentar, tamanho_minimo_tanque_litros, fonte
) VALUES (
    'Carassius auratus', 'Kinguio', 'Águas doces temperadas e lagos', 6.50, 7.50, 20.00, 24.00,
    'DOCE', 'Água Fria Neutro', 'ONIVORO', 100.00, 'RSPCA / OATA' -- CONFERIR tanque
);

-- 4. Betta splendens (Betta)
INSERT INTO especie (
    nome_cientifico, nome_comum, habitat, ph_min, ph_max, temp_min, temp_max,
    tipo_agua, grupo_hidroquimico, habito_alimentar, tamanho_minimo_tanque_litros, fonte
) VALUES (
    'Betta splendens', 'Betta', 'Águas rasas, campos inundados e pântanos', 6.30, 7.85, 27.00, 30.00,
    'DOCE', 'Tropical Ácido/Neutro', 'CARNIVORO', 20.00, 'UF/IFAS / Unram' -- CONFERIR tanque
);

-- 5. Oreochromis niloticus (Tilápia-do-Nilo)
INSERT INTO especie (
    nome_cientifico, nome_comum, habitat, ph_min, ph_max, temp_min, temp_max,
    tipo_agua, grupo_hidroquimico, habito_alimentar, tamanho_minimo_tanque_litros, fonte
) VALUES (
    'Oreochromis niloticus', 'Tilápia-do-Nilo', 'Lagos e rios tropicais (Piscicultura)', 7.00, 8.00, 25.00, 30.00,
    'DOCE', 'Tropical Alcalino', 'ONIVORO', 500.00, 'UFG / Literatura Brasileira' -- CONFERIR tanque
);
-- ================================================================
-- INSERÇÃO DE NOVAS ESPÉCIES COM EMBASAMENTO CIENTÍFICO E LITERATURA
-- ================================================================

-- 6. Paracheirodon axelrodi (Cardeal)
INSERT INTO especie (
    nome_cientifico, nome_comum, habitat, ph_min, ph_max, temp_min, temp_max,
    dh_min, dh_max, tipo_agua, grupo_hidroquimico, habito_alimentar,
    tamanho_minimo_tanque_litros, fonte
) VALUES (
    'Paracheirodon axelrodi', 'Neon Cardeal', 'Igarapés e matas de igapó da Bacia Amazônica',
    4.00, 6.00, 26.00, 29.00, 1.00, 4.00,
    'DOCE', 'Tropical Ácido Estreito (Amazônico)', 'Carnívoro', 60.00, 'INPA / UFAM / SeriouslyFish'
);

-- 7. Colossoma macropomum (Tambaqui)
INSERT INTO especie (
    nome_cientifico, nome_comum, habitat, ph_min, ph_max, temp_min, temp_max, oxigenio_min,
    tipo_agua, grupo_hidroquimico, habito_alimentar, tamanho_minimo_tanque_litros, fonte
) VALUES (
    'Colossoma macropomum', 'Tambaqui', 'Bacias do Amazonas e Orinoco (Lagos de várzea e rios)',
    6.50, 8.00, 28.00, 30.00, 4.00,
    'DOCE', 'Piscicultura Neotropical', 'Onívoro', 2000.00, 'Embrapa / UNESP / FishBase'
);

-- 8. Pterophyllum scalare (Acará-Bandeira)
INSERT INTO especie (
    nome_cientifico, nome_comum, habitat, ph_min, ph_max, temp_min, temp_max,
    dh_min, dh_max, tipo_agua, grupo_hidroquimico, habito_alimentar,
    tamanho_minimo_tanque_litros, fonte
) VALUES (
    'Pterophyllum scalare', 'Acará-Bandeira', 'Rios de águas lentas e vegetadas da Bacia Amazônica',
    6.00, 7.20, 26.00, 29.00, 2.00, 10.00,
    'DOCE', 'Tropical Neutro/Ácido', 'Onívoro', 100.00, 'Revista Brasileira de Zootecnia / FishBase'
);

-- 9. Labidochromis caeruleus (Ciclídeo Amarelo)
INSERT INTO especie (
    nome_cientifico, nome_comum, habitat, ph_min, ph_max, temp_min, temp_max,
    dh_min, dh_max, tipo_agua, grupo_hidroquimico, habito_alimentar,
    tamanho_minimo_tanque_litros, fonte
) VALUES (
    'Labidochromis caeruleus', 'Ciclídeo Amarelo do Malawi', 'Zonas rochosas do Lago Malawi',
    7.80, 8.60, 24.00, 28.00, 10.00, 20.00,
    'DOCE', 'Tropical Alcalino/Duro (Lagos Africanos)', 'Onívoro', 120.00, 'Literatura de Limnologia / SeriouslyFish'
);