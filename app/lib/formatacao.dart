// Formata números no padrão brasileiro (vírgula decimal).
String formatarNumero(
  double v, {
  int? casas,
  bool semCasasSeInteiro = false,
}) {
  if (semCasasSeInteiro && v == v.roundToDouble()) return v.round().toString();
  final x = v * 10;
  final d = casas ?? ((x - x.roundToDouble()).abs() < 1e-9 ? 1 : 2);
  return v.toStringAsFixed(d).replaceAll('.', ',');
}