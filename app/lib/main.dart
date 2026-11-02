import 'package:flutter/material.dart';

import 'notificacoes.dart';
import 'pages/login_page.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notificacoes.iniciar();
  runApp(const AWPeixeApp());
}

class AWPeixeApp extends StatelessWidget {
  const AWPeixeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWPeixe',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const LoginPage(),
    );
  }
}