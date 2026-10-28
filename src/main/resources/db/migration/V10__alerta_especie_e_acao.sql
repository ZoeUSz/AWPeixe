-- Guarda no alerta a espécie avaliada (nome na hora do alerta) e a ação indicada.
ALTER TABLE alerta ADD COLUMN IF NOT EXISTS especie_nome VARCHAR(100);
ALTER TABLE alerta ADD COLUMN IF NOT EXISTS acao VARCHAR(200);
