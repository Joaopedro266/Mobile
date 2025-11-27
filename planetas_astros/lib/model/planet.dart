const String idColumn = "id";

class Planet {
  String? id;
  String nome;
  double? diametro;
  double? massa;
  String tipo;
  String corPredominante;

  Planet({
    this.id,
    required this.nome,
    this.diametro,
    this.massa,
    required this.tipo,
    this.corPredominante = '#FFFFFF',
  });

  factory Planet.fromMap(Map<String, dynamic> map, String docId) {
    return Planet(
      id: docId,
      nome: map['nome'] ?? '',
      diametro: map['diametro']?.toDouble(),
      massa: map['massa']?.toDouble(),
      tipo: map['tipo'] ?? '',
      corPredominante: map['corPredominante'] ?? '#FFFFFF',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'diametro': diametro,
      'massa': massa,
      'tipo': tipo,
      'corPredominante': corPredominante,
    };
  }
}
