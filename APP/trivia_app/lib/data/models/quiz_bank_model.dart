class QuizBankModel {
  final int id;
  final String titulo;
  final bool isActive;
  final DateTime? tiempoInicio;
  final DateTime? tiempoFin;
  final DateTime? creadoEn;

  QuizBankModel({
    required this.id,
    required this.titulo,
    required this.isActive,
    this.tiempoInicio,
    this.tiempoFin,
    this.creadoEn,
  });

  bool get isExpired {
    if (tiempoFin == null) return false;
    return DateTime.now().isAfter(tiempoFin!);
  }

  bool get isExpiringSoon {
    if (tiempoFin == null) return false;
    final diff = tiempoFin!.difference(DateTime.now());
    return diff.inHours >= 0 && diff.inHours <= 24;
  }

  factory QuizBankModel.fromJson(Map<String, dynamic> json) {
    return QuizBankModel(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      isActive: json['is_active'] as bool? ?? true,
      tiempoInicio: json['tiempo_inicio'] != null
          ? DateTime.parse(json['tiempo_inicio'] as String)
          : null,
      tiempoFin: json['tiempo_fin'] != null
          ? DateTime.parse(json['tiempo_fin'] as String)
          : null,
      creadoEn: json['creado_en'] != null
          ? DateTime.parse(json['creado_en'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'is_active': isActive,
      'tiempo_inicio': tiempoInicio?.toIso8601String(),
      'tiempo_fin': tiempoFin?.toIso8601String(),
      'creado_en': creadoEn?.toIso8601String(),
    };
  }
}
