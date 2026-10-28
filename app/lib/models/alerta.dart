class Alerta {
  Alerta({
    required this.id,
    required this.tipo,
    required this.mensagem,
    required this.resolvido,
    required this.geradoEm,
    this.resolvidoEm,
  });

  final String id;
  final String tipo; // TEMPERATURA_ACIMA, TEMPERATURA_ABAIXO, PH_ACIMA, PH_ABAIXO
  final String mensagem;
  final bool resolvido;
  final DateTime geradoEm;
  final DateTime? resolvidoEm;

  bool get temperatura => tipo.startsWith('TEMPERATURA');

  static DateTime? _data(dynamic v) {
    if (v is! String) return null;
    final t = DateTime.tryParse(v);
    if (t == null) return null;
    return t.isUtc ? t.toLocal() : t;
  }

  // Retorna null se o item vier sem data de início (item descartado).
  static Alerta? tentar(Map<String, dynamic> j) {
    final inicio = _data(j['geradoEm']);
    if (inicio == null) return null;
    return Alerta(
      id: (j['id'] ?? '') as String,
      tipo: (j['tipo'] ?? '') as String,
      mensagem: (j['mensagem'] ?? '') as String,
      resolvido: (j['resolvido'] ?? false) as bool,
      geradoEm: inicio,
      resolvidoEm: _data(j['resolvidoEm']),
    );
  }
}
