class UserModel {
  final int id;
  final String correo;
  final String primerNombre;
  final String? segundoNombre;
  final String primerApellido;
  final String? segundoApellido;
  final String institucion;
  final String tipoPerfil; // "ADMINISTRADOR" | "JUGADOR"
  final String? cedula;
  final String? telefono;
  final DateTime? creadoEn;
  
  // Dynamic stats parsed from profile endpoint
  final int? puntajeTotal;
  final int? puntosDisponibles;
  final int? quizzesCompletados;
  final int? rachaMaxima;

  UserModel({
    required this.id,
    required this.correo,
    required this.primerNombre,
    this.segundoNombre,
    required this.primerApellido,
    this.segundoApellido,
    required this.institucion,
    required this.tipoPerfil,
    this.cedula,
    this.telefono,
    this.creadoEn,
    this.puntajeTotal = 0,
    this.puntosDisponibles = 0,
    this.quizzesCompletados = 0,
    this.rachaMaxima = 0,
  });

  String get fullName => '$primerNombre $primerApellido';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      correo: json['correo'] as String,
      primerNombre: json['primer_nombre'] as String,
      segundoNombre: json['segundo_nombre'] as String?,
      primerApellido: json['primer_apellido'] as String,
      segundoApellido: json['segundo_apellido'] as String?,
      institucion: json['institucion'] as String,
      tipoPerfil: json['tipo_perfil'] as String,
      cedula: json['cedula'] as String?,
      telefono: json['telefono'] as String?,
      creadoEn: json['creado_en'] != null 
          ? DateTime.parse(json['creado_en'] as String) 
          : null,
      puntajeTotal: json['puntaje_total'] as int? ?? 0,
      puntosDisponibles: json['puntos_disponibles'] as int? ?? (json['puntaje_total'] as int? ?? 0),
      quizzesCompletados: json['quizzes_completados'] as int? ?? 0,
      rachaMaxima: json['racha_maxima'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correo': correo,
      'primer_nombre': primerNombre,
      'segundo_nombre': segundoNombre,
      'primer_apellido': primerApellido,
      'segundo_apellido': segundoApellido,
      'institucion': institucion,
      'tipo_perfil': tipoPerfil,
      'cedula': cedula,
      'telefono': telefono,
      'creado_en': creadoEn?.toIso8601String(),
      'puntaje_total': puntajeTotal,
      'puntos_disponibles': puntosDisponibles,
      'quizzes_completados': quizzesCompletados,
      'racha_maxima': rachaMaxima,
    };
  }
}
