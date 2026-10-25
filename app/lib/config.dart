// Endereço e credenciais da API. O usuário e a senha NÃO ficam no código:
// são passados na hora de rodar, com --dart-define (veja o comando abaixo).
const apiBaseUrl =
    String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');
const apiUser = String.fromEnvironment('API_USER');
const apiPass = String.fromEnvironment('API_PASS');

// Tanque criado na migration V7.
const tanqueId = '00000000-0000-0000-0000-000000000002';