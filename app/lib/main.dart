import 'package:flutter/material.dart';

import 'pages/monitor_page.dart';
import 'theme.dart';

void main() => runApp(const AWPeixeApp());

class AWPeixeApp extends StatelessWidget {
  const AWPeixeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWPeixe',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const MonitorPage(),
    );
  }
}