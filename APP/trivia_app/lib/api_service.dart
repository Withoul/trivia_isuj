import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database_helper.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Emulador Android

  Future<String?> _getToken() async {
    final session = await DatabaseHelper.instance.getSession();
    return session?['token'];
  }

  Future<Map<String, dynamic>?> login(String correo, String contrasena) async {
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
        data['usuario']['tipo_perfil']
      );
      return data;
    }
    return null;
  }

  Future<bool> register(String correo, String contrasena, String nombre, String apellido, String institucion, String cedula, String telefono) async {
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
        'tipo_perfil': 'JUGADOR'
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<dynamic>> getActiveBanks() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/banks/active'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Token expirado o inválido -> Recrear SQLite
      await DatabaseHelper.instance.clearAllData();
    }
    return [];
  }

  Future<List<dynamic>> getQuestions(int bankId) async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/banks/$bankId/play'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  Future<bool> submitScore(int bankId, int finalScore) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/banks/$bankId/score'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'puntaje_neto': finalScore}),
    );

    return response.statusCode == 200;
  }

  Future<List<dynamic>> getGlobalRankings() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/ranks/global'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }
}
