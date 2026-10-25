class Tanque {
  Tanque({
    required this.id,
    required this.nome,
    this.especieId,
    this.especieNome,
  });

  final String id;
  final String nome;
  final String? especieId;
  final String? especieNome;

  factory Tanque.fromJson(Map<String, dynamic> j) => Tanque(
        id: j['id'] as String,
        nome: (j['nome'] ?? '') as String,
        especieId: j['especieId'] as String?,
        especieNome: j['especieNome'] as String?,
      );
}