ALTER TABLE alerta ADD COLUMN IF NOT EXISTS resolvido_em TIMESTAMP;
CREATE INDEX IF NOT EXISTS idx_alerta_tanque_resolvido ON alerta (tanque_id, resolvido);