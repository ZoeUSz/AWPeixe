-- Guarda a espécie do tanque na hora da alimentação (como já é feito no alerta),
-- para o histórico continuar correto mesmo se a espécie for trocada depois.
ALTER TABLE alimentacao ADD COLUMN IF NOT EXISTS especie_nome VARCHAR(100);
