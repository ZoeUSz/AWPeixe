-- ================================
-- DADOS BIOMÉTRICOS DO FISHBASE (v25.04)
-- Fonte: FishBase, snapshot v25.04 via cboettig/fishbase (CC-BY-NC 4.0)
-- Preenche só campos ainda nulos (COALESCE), sem sobrescrever dados já validados.
-- idade_max_anos = campo LongevityWild do FishBase (anos, em vida livre).
-- ================================

UPDATE especie e
SET comprimento_max_cm = COALESCE(e.comprimento_max_cm, v.comp),
    peso_max_g         = COALESCE(e.peso_max_g, v.peso),
    idade_max_anos     = COALESCE(e.idade_max_anos, v.idade),
    fonte = CASE
        WHEN e.fonte IS NULL THEN 'FishBase v25.04'
        WHEN e.fonte LIKE '%FishBase%' THEN e.fonte
        ELSE e.fonte || ' | FishBase v25.04'
    END
FROM (VALUES
    ('Betta splendens',         6.50,    NULL,      2),
    ('Carassius auratus',       48.00,   1598.60,   41),
    ('Colossoma macropomum',    108.00,  40000.00,  NULL),
    ('Danio rerio',             3.80,    NULL,      NULL),
    ('Labidochromis caeruleus', 8.10,    NULL,      NULL),
    ('Oreochromis niloticus',   60.00,   4324.00,   9),
    ('Paracheirodon axelrodi',  2.51,    NULL,      NULL),
    ('Poecilia reticulata',     5.00,    NULL,      NULL),
    ('Pterophyllum scalare',    10.50,   25.00,     NULL)
) AS v(nome, comp, peso, idade)
WHERE e.nome_cientifico = v.nome;