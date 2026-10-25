import 'package:flutter/material.dart';

import 'pages/especies_page.dart';
import 'theme.dart';

void main() => runApp(const AquaMonitorApp());

class AquaMonitorApp extends StatelessWidget {
  const AquaMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaMonitor',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const EspeciesPage(),
    );
  }
}