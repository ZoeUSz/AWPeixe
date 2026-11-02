// Guarda o usuário e a senha digitados na tela de login enquanto o app
// está aberto. Nada é salvo em disco: ao fechar o app, é preciso entrar
// de novo.
class Sessao {
  Sessao._();

  static String? _usuario;
  static String? _senha;

  static bool get ativa => _usuario != null;
  static String get usuario => _usuario ?? '';
  static String get senha => _senha ?? '';

  static void iniciar(String usuario, String senha) {
    _usuario = usuario;
    _senha = senha;
  }

  static void encerrar() {
    _usuario = null;
    _senha = null;
  }
}
