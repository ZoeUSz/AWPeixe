double? _num(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

class Parametro {
  Parametro({
    required this.tipo,
    required this.situacao,
    this.unidade,
    this.valor,
    this.min,
    this.max,
    this.registradoEm,
  });

  final String tipo; // TEMPERATURA ou PH
  final String situacao; // OK, ABAIXO, ACIMA, SEM_FAIXA, SEM_LEITURA, SEM_SENSOR
  final String? unidade;
  final double? valor;
  final double? min;
  final double? max;
  final DateTime? registradoEm;

  bool get foraDaFaixa => situacao == 'ACIMA' || situacao == 'ABAIXO';

  factory Parametro.fromJson(Map<String, dynamic> j) => Parametro(
        tipo: (j['tipo'] ?? '') as String,
        situacao: (j['situacao'] ?? '') as String,
        unidade: j['unidade'] as String?,
        valor: _num(j['valor']),
        min: _num(j['min']),
        max: _num(j['max']),
        registradoEm: j['registradoEm'] == null
            ? null
            : DateTime.tryParse(j['registradoEm'] as String),
      );
}

class StatusTanque {
  StatusTanque({
    required this.tanque,
    required this.statusGeral,
    required this.parametros,
    this.especie,
  });

  final String tanque;
  final String? especie;
  final String statusGeral; // OK, ALERTA, SEM_ESPECIE, SEM_DADOS
  final List<Parametro> parametros;

  factory StatusTanque.fromJson(Map<String, dynamic> j) => StatusTanque(
        tanque: (j['tanque'] ?? '') as String,
        especie: j['especie'] as String?,
        statusGeral: (j['statusGeral'] ?? '') as String,
        parametros: ((j['parametros'] ?? []) as List<dynamic>)
            .map((p) => Parametro.fromJson(p as Map<String, dynamic>))
            .toList(),
      );

  Parametro? parametro(String tipo) {
    for (final p in parametros) {
      if (p.tipo == tipo) return p;
    }
    return null;
  }
}