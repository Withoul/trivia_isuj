class RankingModel {
  final int usuarioId;
  final String primerNombre;
  final String primerApellido;
  final String correo;
  final String institucion;
  final int puntajeAcumulado;
  final int accuracy;

  RankingModel({
    required this.usuarioId,
    required this.primerNombre,
    required this.primerApellido,
    required this.correo,
    required this.institucion,
    required this.puntajeAcumulado,
    required this.accuracy,
  });

  String get fullName => '$primerNombre $primerApellido';

  factory RankingModel.fromJson(Map<String, dynamic> json) {
    return RankingModel(
      usuarioId: json['usuario_id'] as int? ?? json['id'] as int? ?? 0,
      primerNombre: json['primer_nombre'] as String? ?? '',
      primerApellido: json['primer_apellido'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      institucion: json['institucion'] as String? ?? '',
      puntajeAcumulado: json['puntaje_acumulado'] as int? ?? 0,
      accuracy: json['accuracy'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'primer_nombre': primerNombre,
      'primer_apellido': primerApellido,
      'correo': correo,
      'institucion': institucion,
      'puntaje_acumulado': puntajeAcumulado,
      'accuracy': accuracy,
    };
  }
}
