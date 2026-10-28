double? _num(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

class PontoHistorico {
  PontoHistorico({required this.em, required this.valor});

  final DateTime em;
  final double valor;

  // Pontos com data ou valor inválidos são descartados (retorna null).
  static PontoHistorico? tentar(Map<String, dynamic> j) {
    final texto = j['em'];
    final valor = _num(j['valor']);
    if (texto is! String || valor == null) return null;
    final t = DateTime.tryParse(texto);
    if (t == null) return null;
    return PontoHistorico(em: t.isUtc ? t.toLocal() : t, valor: valor);
  }
}

class Historico {
  Historico({required this.temperatura, required this.ph});

  final List<PontoHistorico> temperatura;
  final List<PontoHistorico> ph;

  static List<PontoHistorico> _serie(dynamic lista) {
    final saida = <PontoHistorico>[];
    for (final item in (lista ?? []) as List<dynamic>) {
      final p = PontoHistorico.tentar(item as Map<String, dynamic>);
      if (p != null) saida.add(p);
    }
    return saida;
  }

  factory Historico.fromJson(Map<String, dynamic> j) => Historico(
        temperatura: _serie(j['temperatura']),
        ph: _serie(j['ph']),
      );
}
