-- Registro das vezes em que o dispenser soltou comida no tanque.
-- O ESP32 controla o dispenser e avisa a API a cada alimentação.
CREATE TABLE alimentacao (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    tanque_id     UUID        NOT NULL REFERENCES tanque(id),
    origem        VARCHAR(20) NOT NULL DEFAULT 'AUTOMATICA', -- AUTOMATICA ou MANUAL
    porcoes       INTEGER,
    registrado_em TIMESTAMP   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_alimentacao_tanque_tempo
    ON alimentacao (tanque_id, registrado_em DESC);
