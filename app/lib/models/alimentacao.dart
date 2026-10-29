class Alimentacao {
  Alimentacao({
    required this.id,
    required this.registradoEm,
    required this.origem,
    this.porcoes,
    this.especie,
  });

  final String id;
  final DateTime registradoEm;
  final String origem; // AUTOMATICA ou MANUAL
  final int? porcoes;
  final String? especie; // espécie do tanque na hora da alimentação

  static Alimentacao? tentar(Map<String, dynamic> j) {
    final t = DateTime.tryParse((j['registradoEm'] ?? '') as String);
    if (t == null) return null;
    return Alimentacao(
      id: (j['id'] ?? '') as String,
      registradoEm: t.isUtc ? t.toLocal() : t,
      origem: (j['origem'] ?? 'AUTOMATICA') as String,
      porcoes: (j['porcoes'] as num?)?.toInt(),
      especie: j['especie'] as String?,
    );
  }

  String get origemTexto => origem == 'MANUAL' ? 'manual' : 'automática';

  String get porcoesTexto => porcoes == null
      ? 'quantidade não informada'
      : (porcoes == 1 ? '1 porção' : '$porcoes porções');

  // "Guppy · 2 porções · automática"
  String get detalhe => [
        if (especie != null && especie!.isNotEmpty) especie!,
        porcoesTexto,
        origemTexto,
      ].join(' · ');

  String get hora => '${_dois(registradoEm.hour)}:${_dois(registradoEm.minute)}';

  // "hoje", "ontem" ou "dd/MM".
  String get dia {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final d = DateTime(registradoEm.year, registradoEm.month, registradoEm.day);
    final diff = hoje.difference(d).inDays;
    if (diff == 0) return 'hoje';
    if (diff == 1) return 'ontem';
    return '${_dois(d.day)}/${_dois(d.month)}';
  }

  String get quando => '$dia, $hora';

  static String _dois(int n) => n.toString().padLeft(2, '0');
}