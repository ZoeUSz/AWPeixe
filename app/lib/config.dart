// Endereço da API. Muda conforme a rede (localhost, Tailscale etc.),
// então é passado na hora de rodar:
//   flutter run --dart-define=API_URL=http://100.77.39.52:8080
// O usuário e a senha NÃO ficam mais aqui: são digitados na tela de login.
const apiBaseUrl =
    String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');

// Tanque criado na migration V7.
const tanqueId = '00000000-0000-0000-0000-000000000002';