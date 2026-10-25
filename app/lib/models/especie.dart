double? _num(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

// Formata no padrão brasileiro: 7,5 / 7,85
String _fmt(double v) {
  final x = v * 10;
  final casas = (x - x.roundToDouble()).abs() < 1e-9 ? 1 : 2;
  return v.toStringAsFixed(casas).replaceAll('.', ',');
}

class Especie {
  Especie({
    required this.id,
    required this.nomeCientifico,
    required this.nomeComum,
    this.grupoHidroquimico,
    this.phMin,
    this.phMax,
    this.tempMin,
    this.tempMax,
    this.tanqueMinimoLitros,
  });

  final String id;
  final String nomeCientifico;
  final String nomeComum;
  final String? grupoHidroquimico;
  final double? phMin;
  final double? phMax;
  final double? tempMin;
  final double? tempMax;
  final double? tanqueMinimoLitros;

  factory Especie.fromJson(Map<String, dynamic> j) => Especie(
        id: j['id'] as String,
        nomeCientifico: (j['nomeCientifico'] ?? '') as String,
        nomeComum: (j['nomeComum'] ?? j['nomeCientifico'] ?? '') as String,
        grupoHidroquimico: j['grupoHidroquimico'] as String?,
        phMin: _num(j['phMin']),
        phMax: _num(j['phMax']),
        tempMin: _num(j['tempMin']),
        tempMax: _num(j['tempMax']),
        tanqueMinimoLitros: _num(j['tamanhoMinimoTanqueLitros']),
      );

  String get faixaPh => (phMin == null || phMax == null)
      ? '—'
      : '${_fmt(phMin!)} a ${_fmt(phMax!)}';

  String get faixaTemp => (tempMin == null || tempMax == null)
      ? '—'
      : '${tempMin!.round()} a ${tempMax!.round()} °C';

  String get tanqueMinimo => tanqueMinimoLitros == null
      ? '—'
      : '${tanqueMinimoLitros!.round()} L';
}