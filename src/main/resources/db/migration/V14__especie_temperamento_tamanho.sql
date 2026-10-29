-- V14: temperamento, tamanho mínimo/máximo (com tipo de comprimento) e peso mínimo por espécie.
-- Fontes: FishBase e SeriouslyFish (ver planilha de espécies do TCC).
-- Comprimento mínimo = comprimento na primeira maturidade (FishBase), quando a fonte informa.
-- peso_max_g não é alterado (já veio do FishBase na V5).

ALTER TABLE especie
    ADD COLUMN IF NOT EXISTS temperamento       VARCHAR(300),
    ADD COLUMN IF NOT EXISTS comprimento_min_cm NUMERIC(6,2),
    ADD COLUMN IF NOT EXISTS tipo_comprimento   VARCHAR(10),
    ADD COLUMN IF NOT EXISTS peso_min_g         NUMERIC(8,2);

UPDATE especie SET
    temperamento       = 'Pacífico e muito ativo; conviver de preferência com outros kinguios (evitar peixes rápidos, agressivos ou que mordem nadadeiras)',
    comprimento_min_cm = NULL,
    comprimento_max_cm = 48,
    tipo_comprimento   = 'total'
WHERE nome_cientifico ILIKE 'Carassius auratus%';

UPDATE especie SET
    temperamento       = 'Pacífico; ideal para aquário comunitário, vive em cardume (grupo de pelo menos 8–10)',
    comprimento_min_cm = NULL,
    comprimento_max_cm = 3.5,
    tipo_comprimento   = 'padrão'
WHERE nome_cientifico ILIKE 'Paracheirodon axelrodi%';

UPDATE especie SET
    temperamento       = 'Muito pacífico, ativo, vive em cardume (grupo de pelo menos 8–10)',
    comprimento_min_cm = NULL,
    comprimento_max_cm = 5,
    tipo_comprimento   = 'padrão'
WHERE nome_cientifico ILIKE 'Danio rerio%';

UPDATE especie SET
    temperamento       = 'Agressivo e territorial; melhor mantido sozinho (um macho por aquário), não indicado para aquário comunitário',
    comprimento_min_cm = NULL,
    comprimento_max_cm = 7,
    tipo_comprimento   = 'padrão'
WHERE nome_cientifico ILIKE 'Betta splendens%';

UPDATE especie SET
    temperamento       = 'Em geral pacífico, mas pode brigar com a própria espécie (manter em grupos pequenos); bom em aquário comunitário, mas pode comer peixes pequenos como tetras',
    comprimento_min_cm = NULL,
    comprimento_max_cm = 15,
    tipo_comprimento   = 'padrão'
WHERE nome_cientifico ILIKE 'Pterophyllum scalare%';

UPDATE especie SET
    temperamento       = 'Pacífico com peixes grandes, mas come peixes pequenos; muito ativo; juvenil vive em cardume e adulto fica mais solitário; em espaço pequeno pode perseguir e morder nadadeiras',
    comprimento_min_cm = 24,
    comprimento_max_cm = 108,
    tipo_comprimento   = 'total'
WHERE nome_cientifico ILIKE 'Colossoma macropomum%';

UPDATE especie SET
    temperamento       = 'Muito pacífico; convive bem em aquário comunitário tranquilo (evitar espécies que mordem nadadeiras)',
    comprimento_min_cm = NULL,
    comprimento_max_cm = 6,
    tipo_comprimento   = 'padrão'
WHERE nome_cientifico ILIKE 'Poecilia reticulata%';

UPDATE especie SET
    temperamento       = 'Robusto; territorial na reprodução e, fora dela, bastante pacífico; briga com a própria espécie sem causar dano sério; come peixes pequenos',
    comprimento_min_cm = 18.6,
    comprimento_max_cm = 60,
    tipo_comprimento   = 'padrão'
WHERE nome_cientifico ILIKE 'Oreochromis niloticus%';

UPDATE especie SET
    temperamento       = 'Relativamente pacífico para um mbuna; fica territorial na reprodução; machos persistentes na perseguição das fêmeas (manter várias fêmeas por macho)',
    comprimento_min_cm = NULL,
    comprimento_max_cm = 10,
    tipo_comprimento   = 'padrão'
WHERE nome_cientifico ILIKE 'Labidochromis caeruleus%';
