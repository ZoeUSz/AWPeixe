-- ================================
-- EXTENSÃO UUID
-- ================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ================================
-- USUARIO
-- ================================
CREATE TABLE usuario (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    nome          VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    senha_hash    VARCHAR(255) NOT NULL,
    papel         VARCHAR(20)  NOT NULL DEFAULT 'OPERADOR',
    criado_em     TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- ================================
-- ESPECIE
-- ================================
CREATE TABLE especie (
    id                  UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    nome_cientifico     VARCHAR(150) NOT NULL,
    nome_comum          VARCHAR(100),
    habitat             VARCHAR(100),
    ph_min              DECIMAL(4,2),
    ph_max              DECIMAL(4,2),
    dh_min              DECIMAL(5,2),
    dh_max              DECIMAL(5,2),
    temp_min            DECIMAL(4,2),
    temp_max            DECIMAL(4,2),
    oxigenio_min        DECIMAL(4,2),
    oxigenio_max        DECIMAL(4,2),
    clima               VARCHAR(50),
    distribuicao        TEXT,
    comprimento_max_cm  DECIMAL(6,2),
    peso_max_g          DECIMAL(8,2),
    idade_max_anos      INTEGER,
    comportamento       VARCHAR(100),
    fonte               VARCHAR(100) DEFAULT 'FishBase'
);

-- ================================
-- TANQUE
-- ================================
CREATE TABLE tanque (
    id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id        UUID         NOT NULL REFERENCES usuario(id),
    especie_id        UUID         REFERENCES especie(id),
    nome              VARCHAR(100) NOT NULL,
    capacidade_litros DECIMAL(10,2),
    localizacao       VARCHAR(150),
    criado_em         TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- ================================
-- SENSOR
-- ================================
CREATE TABLE sensor (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    tanque_id   UUID        NOT NULL REFERENCES tanque(id),
    tipo        VARCHAR(50) NOT NULL,   -- 'TEMPERATURA', 'PH', 'OXIGENIO'
    modelo      VARCHAR(100),
    unidade     VARCHAR(20),            -- '°C', 'mg/L', etc.
    ativo       BOOLEAN     NOT NULL DEFAULT TRUE
);

-- ================================
-- LEITURA
-- ================================
CREATE TABLE leitura (
    id              UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
    sensor_id       UUID      NOT NULL REFERENCES sensor(id),
    valor           DECIMAL(8,4) NOT NULL,
    registrado_em   TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Índice para consultas por período (dashboard em tempo real)
CREATE INDEX idx_leitura_sensor_tempo ON leitura (sensor_id, registrado_em DESC);

-- ================================
-- ALERTA
-- ================================
CREATE TABLE alerta (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    leitura_id  UUID        REFERENCES leitura(id),
    tanque_id   UUID        NOT NULL REFERENCES tanque(id),
    tipo        VARCHAR(50) NOT NULL,   -- 'PH_ALTO', 'TEMP_BAIXA', etc.
    mensagem    TEXT        NOT NULL,
    resolvido   BOOLEAN     NOT NULL DEFAULT FALSE,
    gerado_em   TIMESTAMP   NOT NULL DEFAULT NOW()
);