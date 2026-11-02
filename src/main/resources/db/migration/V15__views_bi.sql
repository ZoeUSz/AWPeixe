-- V15: views somente para o BI (Metabase).
-- Não alteram nenhuma tabela; o ddl-auto: validate da API ignora views.

-- Cada leitura com tanque, espécie atual do tanque, faixa ideal e situação.
-- Atenção: a faixa usada é a da espécie que está no tanque HOJE.
CREATE OR REPLACE VIEW vw_leituras AS
SELECT
    l.id                         AS leitura_id,
    l.registrado_em,
    t.id                         AS tanque_id,
    t.nome                       AS tanque,
    e.nome_comum                 AS especie,
    s.tipo                       AS parametro,
    s.unidade,
    l.valor,
    CASE s.tipo WHEN 'PH' THEN e.ph_min WHEN 'TEMPERATURA' THEN e.temp_min END AS faixa_min,
    CASE s.tipo WHEN 'PH' THEN e.ph_max WHEN 'TEMPERATURA' THEN e.temp_max END AS faixa_max,
    CASE
        WHEN (CASE s.tipo WHEN 'PH' THEN e.ph_min WHEN 'TEMPERATURA' THEN e.temp_min END) IS NULL
          OR (CASE s.tipo WHEN 'PH' THEN e.ph_max WHEN 'TEMPERATURA' THEN e.temp_max END) IS NULL
            THEN 'SEM_FAIXA'
        WHEN l.valor < (CASE s.tipo WHEN 'PH' THEN e.ph_min WHEN 'TEMPERATURA' THEN e.temp_min END)
            THEN 'ABAIXO'
        WHEN l.valor > (CASE s.tipo WHEN 'PH' THEN e.ph_max WHEN 'TEMPERATURA' THEN e.temp_max END)
            THEN 'ACIMA'
        ELSE 'DENTRO'
    END                          AS situacao
FROM leitura l
JOIN sensor s       ON s.id = l.sensor_id
JOIN tanque t       ON t.id = s.tanque_id
LEFT JOIN especie e ON e.id = t.especie_id;

-- Alertas com parâmetro, valor que disparou e duração em minutos
-- (alerta aberto conta até agora).
CREATE OR REPLACE VIEW vw_alertas AS
SELECT
    a.id                         AS alerta_id,
    a.gerado_em,
    a.resolvido_em,
    a.resolvido,
    a.tipo,
    CASE WHEN a.tipo LIKE 'PH%' THEN 'pH' ELSE 'Temperatura' END AS parametro,
    a.especie_nome               AS especie,
    a.acao,
    a.mensagem,
    t.nome                       AS tanque,
    l.valor                      AS valor_leitura,
    ROUND(EXTRACT(EPOCH FROM (COALESCE(a.resolvido_em, LOCALTIMESTAMP) - a.gerado_em)) / 60.0, 1)
                                 AS duracao_min
FROM alerta a
JOIN tanque t        ON t.id = a.tanque_id
LEFT JOIN leitura l  ON l.id = a.leitura_id;

-- Alimentações com o dia separado para agrupar.
CREATE OR REPLACE VIEW vw_alimentacoes AS
SELECT
    al.id                        AS alimentacao_id,
    al.registrado_em,
    CAST(al.registrado_em AS date) AS dia,
    al.origem,
    al.porcoes,
    al.especie_nome              AS especie,
    t.nome                       AS tanque
FROM alimentacao al
JOIN tanque t ON t.id = al.tanque_id;

-- Catálogo de espécies para comparação.
CREATE OR REPLACE VIEW vw_especies AS
SELECT
    nome_comum,
    nome_cientifico,
    grupo_hidroquimico,
    ph_min,
    ph_max,
    temp_min,
    temp_max,
    tamanho_minimo_tanque_litros,
    comprimento_min_cm,
    comprimento_max_cm,
    tipo_comprimento,
    peso_min_g,
    peso_max_g,
    temperamento,
    habito_alimentar,
    fonte
FROM especie;
