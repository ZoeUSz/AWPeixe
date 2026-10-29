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

// 7 -> "7", 3.5 -> "3,5", 18.6 -> "18,6"
String _fmtNum(double v) => v == v.roundToDouble()
    ? v.round().toString()
    : v.toStringAsFixed(1).replaceAll('.', ',');

// Pesos a partir de 1000 g aparecem em kg: 1598.6 -> "1,6 kg".
String _fmtPeso(double g) =>
    g >= 1000 ? '${_fmtNum(g / 1000)} kg' : '${_fmtNum(g)} g';

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
    this.temperamento,
    this.comprimentoMinCm,
    this.comprimentoMaxCm,
    this.tipoComprimento,
    this.pesoMinG,
    this.pesoMaxG,
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
  final String? temperamento;
  final double? comprimentoMinCm;
  final double? comprimentoMaxCm;
  final String? tipoComprimento; // 'padrão' ou 'total'
  final double? pesoMinG;
  final double? pesoMaxG;

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
        temperamento: j['temperamento'] as String?,
        comprimentoMinCm: _num(j['comprimentoMinCm']),
        comprimentoMaxCm: _num(j['comprimentoMaxCm']),
        tipoComprimento: j['tipoComprimento'] as String?,
        pesoMinG: _num(j['pesoMinG']),
        pesoMaxG: _num(j['pesoMaxG']),
      );

  String get faixaPh => (phMin == null || phMax == null)
      ? '—'
      : '${_fmt(phMin!)} a ${_fmt(phMax!)}';

  String get faixaTemp => (tempMin == null || tempMax == null)
      ? '—'
      : '${tempMin!.round()} a ${tempMax!.round()} °C';

  // Classificação do Quadro 6 do relatório (mesmas regras da migration V4).
  // Critério térmico: Água Fria se a temperatura máxima for até 25 °C.
  String? get classeTermica {
    if (tempMax == null) return null;
    return tempMax! <= 25 ? 'Água Fria' : 'Água Tropical';
  }

  // Critério de pH: Ácido se o limite superior for até 6,50; Alcalino se o
  // valor mínimo for 7,00 ou mais; Neutro nos casos intermediários.
  String? get classePh {
    if (phMin == null || phMax == null) return null;
    if (phMax! <= 6.5) return 'Ácido';
    if (phMin! >= 7.0) return 'Alcalino';
    return 'Neutro';
  }

  String get tanqueMinimo => tanqueMinimoLitros == null
      ? '—'
      : '${tanqueMinimoLitros!.round()} L';

  String get tamanhoAdulto {
    final tipo = tipoComprimento == null ? '' : ' ($tipoComprimento)';
    if (comprimentoMaxCm == null) return 'não informado';
    if (comprimentoMinCm != null) {
      return '${_fmtNum(comprimentoMinCm!)} a ${_fmtNum(comprimentoMaxCm!)} cm$tipo';
    }
    return 'até ${_fmtNum(comprimentoMaxCm!)} cm$tipo';
  }

  String get pesoAdulto {
    if (pesoMaxG == null) return 'não informado';
    if (pesoMinG != null) {
      return '${_fmtPeso(pesoMinG!)} a ${_fmtPeso(pesoMaxG!)}';
    }
    return 'até ${_fmtPeso(pesoMaxG!)}';
  }

  String get temperamentoTexto =>
      (temperamento == null || temperamento!.trim().isEmpty)
          ? 'não informado'
          : temperamento!;
}