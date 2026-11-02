import 'package:flutter/material.dart';

import '../api.dart';
import '../config.dart';
import '../sessao.dart';
import 'monitor_page.dart';

// Encerra a sessão e volta para o login, fechando todas as telas abertas.
// Use no botão "Sair" (ex.: nas actions da AppBar do monitoramento).
void sairDaSessao(BuildContext context) {
  Sessao.encerrar();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (_) => false,
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _senha = TextEditingController();
  final _api = ApiClient();

  bool _carregando = false;
  bool _mostrarSenha = false;
  String? _erro;

  @override
  void dispose() {
    _usuario.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_carregando) return;
    if (!_form.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await _api.entrar(_usuario.text.trim(), _senha.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MonitorPage()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        if (e.naoAutorizado) _senha.clear();
      });
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Form(
                key: _form,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/icone/icone_awpeixe_simbolo.png',
                            width: 112,
                            height: 112,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.set_meal,
                              size: 72,
                              color: cores.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'AWPeixe',
                        textAlign: TextAlign.center,
                        style: tema.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monitoramento do aquário',
                        textAlign: TextAlign.center,
                        style: tema.textTheme.bodyMedium
                            ?.copyWith(color: cores.onSurfaceVariant),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _usuario,
                        enabled: !_carregando,
                        autofillHints: const [AutofillHints.username],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Usuário',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Informe o usuário'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _senha,
                        enabled: !_carregando,
                        obscureText: !_mostrarSenha,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _entrar(),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip:
                                _mostrarSenha ? 'Ocultar senha' : 'Mostrar senha',
                            icon: Icon(_mostrarSenha
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () =>
                                setState(() => _mostrarSenha = !_mostrarSenha),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Informe a senha' : null,
                      ),
                      if (_erro != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cores.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: cores.onErrorContainer),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _erro!,
                                  style:
                                      TextStyle(color: cores.onErrorContainer),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: _carregando ? null : _entrar,
                          child: _carregando
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2.5),
                                )
                              : const Text('Entrar'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'API: $apiBaseUrl',
                        textAlign: TextAlign.center,
                        style: tema.textTheme.bodySmall
                            ?.copyWith(color: cores.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}