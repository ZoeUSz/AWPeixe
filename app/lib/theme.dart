import 'package:flutter/material.dart';

abstract class AppColors {
  static const primaria = Color(0xFF0B6E8A);
  static const primariaEscura = Color(0xFF084C61);
  static const primariaClara = Color(0xFFD6EEF5);
  static const fundo = Color(0xFFF4F9FB);
  static const borda = Color(0xFFD5E3E8);
  static const texto = Color(0xFF10262E);
  static const textoSecundario = Color(0xFF4F6770);

  static const ok = Color(0xFF2E9E5B);
  static const okFundo = Color(0xFFDDF3E6);
  static const okTexto = Color(0xFF1B6B3C);

  static const alerta = Color(0xFFD64545);
  static const alertaFundo = Color(0xFFFBE3E3);
  static const alertaTexto = Color(0xFFA12A2A);

  static const aviso = Color(0xFFE0A21B);
  static const avisoFundo = Color(0xFFFFF1D0);
  static const avisoTexto = Color(0xFF8A6100);

  static const neutro = Color(0xFF8A9BA3);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primaria).copyWith(
    primary: AppColors.primaria,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.texto,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.fundo,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.texto,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

