class QuizBankModel {
  final int id;
  final String titulo;
  final bool isActive;
  final DateTime? tiempoInicio;
  final DateTime? tiempoFin;
  final DateTime? creadoEn;

  // New configuration fields
  final int tiempoPorPregunta;   // seconds per question (default 12)
  final String colorBanner;      // hex color for quiz banner (default '#461F70')
  final int puntosPorPregunta;   // base points per correct answer (default 5)
  final bool esPermanente;       // permanent (no end date) vs temporal

  QuizBankModel({
    required this.id,
    required this.titulo,
    required this.isActive,
    this.tiempoInicio,
    this.tiempoFin,
    this.creadoEn,
    this.tiempoPorPregunta = 12,
    this.colorBanner = '#461F70',
    this.puntosPorPregunta = 5,
    this.esPermanente = false,
  });

  bool get isExpired {
    if (esPermanente) return false;
    if (tiempoFin == null) return false;
    return DateTime.now().isAfter(tiempoFin!);
  }

  bool get isExpiringSoon {
    if (esPermanente) return false;
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
      tiempoPorPregunta: json['tiempo_por_pregunta'] as int? ?? 12,
      colorBanner: json['color_banner'] as String? ?? '#461F70',
      puntosPorPregunta: json['puntos_por_pregunta'] as int? ?? 5,
      esPermanente: json['es_permanente'] as bool? ?? false,
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
      'tiempo_por_pregunta': tiempoPorPregunta,
      'color_banner': colorBanner,
      'puntos_por_pregunta': puntosPorPregunta,
      'es_permanente': esPermanente,
    };
  }
}
