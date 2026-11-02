-- Usuário somente leitura para o Metabase.
-- Rodar UMA vez, depois que a API subir com a V15 aplicada:
--   docker exec -i piscicultura-db psql -U admin -d piscicultura -v senha='SUA_SENHA' < bi_leitura.sql
-- A senha fica fora do Git (não salve este comando em arquivo versionado).

CREATE ROLE bi_leitura LOGIN PASSWORD :'senha';

GRANT CONNECT ON DATABASE piscicultura TO bi_leitura;
GRANT USAGE ON SCHEMA public TO bi_leitura;

-- Só as views: o BI não enxerga as tabelas diretamente.
GRANT SELECT ON vw_leituras, vw_alertas, vw_alimentacoes, vw_especies TO bi_leitura;
