import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/quiz_bank_model.dart';
import '../models/question_model.dart';
import '../models/ranking_model.dart';
import 'database_helper.dart';

class ApiService {
  // baseUrl points to the FastAPI server.
  // In Android Emulator, 10.0.2.2 maps to the host's localhost.
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<String?> _getToken() async {
    final session = await DatabaseHelper.instance.getSession();
    return session?['token'];
  }

  // --- OFFLINE DEMO MOCK DATA STORE ---
  static UserModel _mockUserProfile = UserModel(
    id: 999,
    correo: 'demo.jugador@ujapon.edu.ec',
    primerNombre: 'Carlos',
    primerApellido: 'Mendoza',
    institucion: 'Abdon Calderón',
    tipoPerfil: 'JUGADOR',
    puntajeTotal: 1250,
    quizzesCompletados: 4,
    rachaMaxima: 6,
  );

  static final UserModel _mockAdminProfile = UserModel(
    id: 888,
    correo: 'demo.admin@itsjapon.edu.ec',
    primerNombre: 'Dra. María',
    primerApellido: 'Espinoza',
    institucion: 'Dirección Académica',
    tipoPerfil: 'ADMINISTRADOR',
    puntajeTotal: 0,
    quizzesCompletados: 0,
    rachaMaxima: 0,
  );

  static final List<QuizBankModel> _mockBanks = [
    QuizBankModel(
      id: 101,
      titulo: 'Fundamentos de Programación (Demo)',
      isActive: true,
      tiempoInicio: DateTime.now().subtract(const Duration(days: 1)),
      tiempoFin: DateTime.now().add(const Duration(hours: 3, minutes: 45)),
      creadoEn: DateTime.now().subtract(const Duration(days: 2)),
    ),
    QuizBankModel(
      id: 102,
      titulo: 'Estructuras de Datos I (Demo)',
      isActive: true,
      tiempoInicio: DateTime.now().subtract(const Duration(days: 2)),
      tiempoFin: DateTime.now().add(const Duration(days: 2)),
      creadoEn: DateTime.now().subtract(const Duration(days: 3)),
    ),
    QuizBankModel(
      id: 103,
      titulo: 'Base de Datos Relacionales (Demo)',
      isActive: true,
      tiempoInicio: DateTime.now().subtract(const Duration(days: 5)),
      tiempoFin: DateTime.now().add(const Duration(days: 5)),
      creadoEn: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

  static final Map<int, List<QuestionModel>> _mockQuestions = {
    101: [
      QuestionModel(
        id: 1,
        textoPregunta: '¿Cuál de los siguientes es un lenguaje compilado?',
        respuestas: [
          AnswerModel(id: 11, textoRespuesta: 'Python', esCorrecta: false),
          AnswerModel(id: 12, textoRespuesta: 'C++', esCorrecta: true),
          AnswerModel(id: 13, textoRespuesta: 'JavaScript', esCorrecta: false),
          AnswerModel(id: 14, textoRespuesta: 'HTML', esCorrecta: false),
        ],
      ),
      QuestionModel(
        id: 2,
        textoPregunta:
            '¿Qué estructura sigue el principio FIFO (First In, First Out)?',
        respuestas: [
          AnswerModel(
            id: 21,
            textoRespuesta: 'Pila (Stack)',
            esCorrecta: false,
          ),
          AnswerModel(id: 22, textoRespuesta: 'Cola (Queue)', esCorrecta: true),
          AnswerModel(
            id: 23,
            textoRespuesta: 'Árbol (Tree)',
            esCorrecta: false,
          ),
          AnswerModel(
            id: 24,
            textoRespuesta: 'Grafo (Graph)',
            esCorrecta: false,
          ),
        ],
      ),
      QuestionModel(
        id: 3,
        textoPregunta:
            '¿Qué palabra clave se usa para definir una función en Dart?',
        respuestas: [
          AnswerModel(id: 31, textoRespuesta: 'function', esCorrecta: false),
          AnswerModel(id: 32, textoRespuesta: 'def', esCorrecta: false),
          AnswerModel(
            id: 33,
            textoRespuesta: 'void o tipo de dato de retorno',
            esCorrecta: true,
          ),
          AnswerModel(id: 34, textoRespuesta: 'func', esCorrecta: false),
        ],
      ),
    ],
    102: [
      QuestionModel(
        id: 4,
        textoPregunta:
            '¿Cuál es la complejidad temporal promedio de búsqueda en un árbol binario balanceado?',
        respuestas: [
          AnswerModel(id: 41, textoRespuesta: 'O(1)', esCorrecta: false),
          AnswerModel(id: 42, textoRespuesta: 'O(n)', esCorrecta: false),
          AnswerModel(id: 43, textoRespuesta: 'O(log n)', esCorrecta: true),
          AnswerModel(id: 44, textoRespuesta: 'O(n log n)', esCorrecta: false),
        ],
      ),
      QuestionModel(
        id: 5,
        textoPregunta:
            '¿Qué estructura de datos permite el acceso aleatorio O(1) a sus elementos?',
        respuestas: [
          AnswerModel(
            id: 51,
            textoRespuesta: 'Lista Enlazada',
            esCorrecta: false,
          ),
          AnswerModel(
            id: 52,
            textoRespuesta: 'Arreglo / Vector',
            esCorrecta: true,
          ),
          AnswerModel(
            id: 53,
            textoRespuesta: 'Árbol Binario',
            esCorrecta: false,
          ),
          AnswerModel(id: 54, textoRespuesta: 'Grafo', esCorrecta: false),
        ],
      ),
    ],
    103: [
      QuestionModel(
        id: 6,
        textoPregunta:
            '¿Qué comando SQL se utiliza para recuperar datos de una tabla?',
        respuestas: [
          AnswerModel(id: 61, textoRespuesta: 'GET', esCorrecta: false),
          AnswerModel(id: 62, textoRespuesta: 'SELECT', esCorrecta: true),
          AnswerModel(id: 63, textoRespuesta: 'EXTRACT', esCorrecta: false),
          AnswerModel(id: 64, textoRespuesta: 'RETRIEVE', esCorrecta: false),
        ],
      ),
      QuestionModel(
        id: 7,
        textoPregunta:
            '¿Cuál de las siguientes es una clave que identifica de forma única a una fila?',
        respuestas: [
          AnswerModel(
            id: 71,
            textoRespuesta: 'Clave Foránea',
            esCorrecta: false,
          ),
          AnswerModel(
            id: 72,
            textoRespuesta: 'Clave Primaria',
            esCorrecta: true,
          ),
          AnswerModel(
            id: 73,
            textoRespuesta: 'Clave Única Opcional',
            esCorrecta: false,
          ),
          AnswerModel(
            id: 74,
            textoRespuesta: 'Ninguna de las anteriores',
            esCorrecta: false,
          ),
        ],
      ),
    ],
  };

  static final List<RankingModel> _mockRankings = [
    RankingModel(
      usuarioId: 1,
      primerNombre: 'Sofía',
      primerApellido: 'Altamirano',
      correo: 'sofia.alta@ujapon.edu.ec',
      institucion: 'Juan Montalvo',
      puntajeAcumulado: 1580,
      accuracy: 96,
    ),
    RankingModel(
      usuarioId: 2,
      primerNombre: 'Mateo',
      primerApellido: 'Guanotuña',
      correo: 'mateo.guano@ujapon.edu.ec',
      institucion: 'Manuela Cañizares',
      puntajeAcumulado: 1410,
      accuracy: 92,
    ),
    RankingModel(
      usuarioId: 3,
      primerNombre: 'Alejandra',
      primerApellido: 'Velasco',
      correo: 'ale.velasco@ujapon.edu.ec',
      institucion: 'Juan Montalvo',
      puntajeAcumulado: 1100,
      accuracy: 85,
    ),
    RankingModel(
      usuarioId: 4,
      primerNombre: 'Luis',
      primerApellido: 'Ortega',
      correo: 'luis.ortega@ujapon.edu.ec',
      institucion: 'Juan Montalvo',
      puntajeAcumulado: 980,
      accuracy: 80,
    ),
  ];

  Future<bool> _isDemo() async {
    final token = await _getToken();
    return token != null && token.startsWith('mock_token_demo');
  }

  Future<bool> _isDemoAdmin() async {
    final token = await _getToken();
    return token == 'mock_token_demo_admin';
  }

  // --- AUTHENTICATION ---

  Future<Map<String, dynamic>?> login(String correo, String contrasena) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await DatabaseHelper.instance.saveSession(
          data['access_token'],
          data['usuario']['correo'],
          data['usuario']['tipo_perfil'],
        );
        return data;
      }
    } catch (e) {
      // Local development logging
      print('Login error: $e');
    }
    return null;
  }

  Future<bool> register(
    String correo,
    String contrasena,
    String nombre,
    String apellido,
    String institucion,
    String cedula,
    String telefono,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': correo,
          'contrasena': contrasena,
          'primer_nombre': nombre,
          'segundo_nombre': '',
          'primer_apellido': apellido,
          'segundo_apellido': '',
          'institucion': institucion,
          'cedula': cedula,
          'telefono': telefono,
          'tipo_perfil': 'JUGADOR',
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  // --- PLAYER ENDPOINTS ---

  Future<UserModel?> getUserProfile() async {
    if (await _isDemo()) {
      if (await _isDemoAdmin()) {
        return _mockAdminProfile;
      } else {
        return _mockUserProfile;
      }
    }

    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/users/me/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else if (response.statusCode == 401) {
        await DatabaseHelper.instance.clearAllData();
      }
    } catch (e) {
      print('Get user profile error: $e');
    }
    return null;
  }

  Future<List<QuizBankModel>> getActiveBanks() async {
    if (await _isDemo()) {
      return _mockBanks.where((b) => b.isActive).toList();
    }

    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/banks/active'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> raw = jsonDecode(response.body);
        return raw.map((b) => QuizBankModel.fromJson(b)).toList();
      } else if (response.statusCode == 401) {
        await DatabaseHelper.instance.clearAllData();
      }
    } catch (e) {
      print('Get active banks error: $e');
    }
    return [];
  }

  Future<List<QuestionModel>> getQuestions(int bankId) async {
    if (await _isDemo()) {
      return _mockQuestions[bankId] ?? [];
    }

    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/banks/$bankId/play'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> raw = jsonDecode(response.body);
        return raw.map((q) => QuestionModel.fromJson(q)).toList();
      }
    } catch (e) {
      print('Get questions error: $e');
    }
    return [];
  }

  Future<bool> submitScore(int bankId, int finalScore) async {
    if (await _isDemo()) {
      final oldScore = _mockUserProfile.puntajeTotal ?? 0;
      final oldQuizzes = _mockUserProfile.quizzesCompletados ?? 0;
      final oldRacha = _mockUserProfile.rachaMaxima ?? 0;

      _mockUserProfile = UserModel(
        id: _mockUserProfile.id,
        correo: _mockUserProfile.correo,
        primerNombre: _mockUserProfile.primerNombre,
        primerApellido: _mockUserProfile.primerApellido,
        institucion: _mockUserProfile.institucion,
        tipoPerfil: _mockUserProfile.tipoPerfil,
        puntajeTotal: oldScore + finalScore,
        quizzesCompletados: oldQuizzes + 1,
        rachaMaxima: finalScore > 0 ? oldRacha + 1 : oldRacha,
      );
      return true;
    }

    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/banks/$bankId/score'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'puntaje_neto': finalScore}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Submit score error: $e');
      return false;
    }
  }

  Future<List<RankingModel>> getGlobalRankings() async {
    if (await _isDemo()) {
      final List<RankingModel> allRanks = List.from(_mockRankings);
      allRanks.removeWhere((r) => r.usuarioId == 999);
      allRanks.add(
        RankingModel(
          usuarioId: 999,
          primerNombre: _mockUserProfile.primerNombre,
          primerApellido: _mockUserProfile.primerApellido,
          correo: _mockUserProfile.correo,
          institucion: _mockUserProfile.institucion,
          puntajeAcumulado: _mockUserProfile.puntajeTotal ?? 0,
          accuracy: 88,
        ),
      );
      allRanks.sort((a, b) => b.puntajeAcumulado.compareTo(a.puntajeAcumulado));
      return allRanks;
    }

    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/ranks/global'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> raw = jsonDecode(response.body);
        return raw.map((r) => RankingModel.fromJson(r)).toList();
      }
    } catch (e) {
      print('Get global rankings error: $e');
    }
    return [];
  }

  // --- ADMIN ENDPOINTS ---

  Future<List<QuizBankModel>> getAdminBanks() async {
    if (await _isDemo()) {
      return _mockBanks;
    }

    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/admin/banks'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> raw = jsonDecode(response.body);
        return raw.map((b) => QuizBankModel.fromJson(b)).toList();
      }
    } catch (e) {
      print('Admin get banks error: $e');
    }
    return [];
  }

  Future<QuizBankModel?> createBank(
    String titulo,
    bool isActive,
    DateTime? tiempoInicio,
    DateTime? tiempoFin,
  ) async {
    if (await _isDemo()) {
      final newBank = QuizBankModel(
        id: _mockBanks.length + 101,
        titulo: titulo,
        isActive: isActive,
        tiempoInicio: tiempoInicio ?? DateTime.now(),
        tiempoFin: tiempoFin ?? DateTime.now().add(const Duration(days: 7)),
        creadoEn: DateTime.now(),
      );
      _mockBanks.add(newBank);
      _mockQuestions[newBank.id] = [];
      return newBank;
    }

    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/admin/banks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'titulo': titulo,
          'is_active': isActive,
          'tiempo_inicio': tiempoInicio?.toIso8601String(),
          'tiempo_fin': tiempoFin?.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return QuizBankModel.fromJson(data);
      }
    } catch (e) {
      print('Admin create bank error: $e');
    }
    return null;
  }

  Future<QuizBankModel?> updateBank(
    int bankId,
    String titulo,
    bool isActive,
    DateTime? tiempoInicio,
    DateTime? tiempoFin,
  ) async {
    if (await _isDemo()) {
      final index = _mockBanks.indexWhere((b) => b.id == bankId);
      if (index != -1) {
        final updated = QuizBankModel(
          id: bankId,
          titulo: titulo,
          isActive: isActive,
          tiempoInicio: tiempoInicio ?? _mockBanks[index].tiempoInicio,
          tiempoFin: tiempoFin ?? _mockBanks[index].tiempoFin,
          creadoEn: _mockBanks[index].creadoEn,
        );
        _mockBanks[index] = updated;
        return updated;
      }
      return null;
    }

    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.put(
        Uri.parse('$baseUrl/admin/banks/$bankId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'titulo': titulo,
          'is_active': isActive,
          'tiempo_inicio': tiempoInicio?.toIso8601String(),
          'tiempo_fin': tiempoFin?.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return QuizBankModel.fromJson(data);
      }
    } catch (e) {
      print('Admin update bank error: $e');
    }
    return null;
  }

  Future<QuestionModel?> createQuestion(
    int bankId,
    String textoPregunta,
    List<Map<String, dynamic>> respuestas,
  ) async {
    if (await _isDemo()) {
      final List<AnswerModel> parsedAnswers = [];
      for (int i = 0; i < respuestas.length; i++) {
        parsedAnswers.add(
          AnswerModel(
            id: i + 1,
            textoRespuesta:
                respuestas[i]['texto_respuesta'] ??
                respuestas[i]['text_respuesta'] ??
                '',
            esCorrecta: respuestas[i]['es_correcta'] ?? false,
          ),
        );
      }
      final newQuestion = QuestionModel(
        id: (_mockQuestions[bankId]?.length ?? 0) + 1,
        textoPregunta: textoPregunta,
        respuestas: parsedAnswers,
      );
      if (!_mockQuestions.containsKey(bankId)) {
        _mockQuestions[bankId] = [];
      }
      _mockQuestions[bankId]!.add(newQuestion);
      return newQuestion;
    }

    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/admin/banks/$bankId/questions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'texto_pregunta': textoPregunta,
          'respuestas':
              respuestas, // each maps to text_respuesta and es_correcta
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return QuestionModel.fromJson(data);
      }
    } catch (e) {
      print('Admin create question error: $e');
    }
    return null;
  }
}
