class QuestionModel {
  final int id;
  final String textoPregunta;
  final List<AnswerModel> respuestas;

  QuestionModel({
    required this.id,
    required this.textoPregunta,
    required this.respuestas,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    var rawRespuestas = json['respuestas'] as List<dynamic>? ?? [];
    List<AnswerModel> parsedRespuestas = rawRespuestas
        .map((r) => AnswerModel.fromJson(r as Map<String, dynamic>))
        .toList();

    return QuestionModel(
      id: json['id'] as int,
      textoPregunta: json['texto_pregunta'] as String,
      respuestas: parsedRespuestas,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'texto_pregunta': textoPregunta,
      'respuestas': respuestas.map((r) => r.toJson()).toList(),
    };
  }
}

class AnswerModel {
  final int id;
  final String textoRespuesta;
  final bool esCorrecta;

  AnswerModel({
    required this.id,
    required this.textoRespuesta,
    required this.esCorrecta,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'] as int,
      textoRespuesta: json['texto_respuesta'] as String,
      esCorrecta: json['es_correcta'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'texto_respuesta': textoRespuesta,
      'es_correcta': esCorrecta,
    };
  }
}
