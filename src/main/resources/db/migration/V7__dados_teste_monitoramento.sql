-- Dados de teste para desenvolvimento do monitoramento.
-- IDs fixos para facilitar os testes no Insomnia e o simulador.

INSERT INTO usuario (id, nome, email, senha_hash, papel)
VALUES ('00000000-0000-0000-0000-000000000001',
        'Usuário Teste', 'teste@tcc.local', 'sem-login-por-enquanto', 'ADMIN')
ON CONFLICT (id) DO NOTHING;

INSERT INTO tanque (id, usuario_id, especie_id, nome, capacidade_litros, localizacao)
VALUES ('00000000-0000-0000-0000-000000000002',
        '00000000-0000-0000-0000-000000000001',
        NULL, 'Aquário da apresentação', 60.00, 'Bancada do laboratório')
ON CONFLICT (id) DO NOTHING;

INSERT INTO sensor (id, tanque_id, tipo, modelo, unidade, ativo)
VALUES
  ('00000000-0000-0000-0000-000000000011',
   '00000000-0000-0000-0000-000000000002',
   'TEMPERATURA', 'A definir (Raspberry)', '°C', TRUE),
  ('00000000-0000-0000-0000-000000000012',
   '00000000-0000-0000-0000-000000000002',
   'PH', 'A definir (Raspberry)', 'pH', TRUE)
ON CONFLICT (id) DO NOTHING;