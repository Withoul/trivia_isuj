import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_helper.dart';
import '../services/api_service.dart';

class AuthState {
  final bool isAuthenticated;
  final String? perfil; // "JUGADOR" | "ADMINISTRADOR"
  final String? email;

  AuthState({
    required this.isAuthenticated,
    this.perfil,
    this.email,
  });

  factory AuthState.unauthenticated() {
    return AuthState(isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  final ApiService _apiService = ApiService();

  @override
  AuthState build() {
    checkAuth();
    return AuthState.unauthenticated();
  }

  Future<void> checkAuth() async {
    final session = await DatabaseHelper.instance.getSession();
    if (session != null) {
      state = AuthState(
        isAuthenticated: true,
        perfil: session['perfil'] as String?,
        email: session['usuario_email'] as String?,
      );
    } else {
      state = AuthState.unauthenticated();
    }
  }

  Future<bool> login(String correo, String password) async {
    final result = await _apiService.login(correo, password);
    if (result != null) {
      state = AuthState(
        isAuthenticated: true,
        perfil: result['usuario']['tipo_perfil'] as String?,
        email: result['usuario']['correo'] as String?,
      );
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await DatabaseHelper.instance.clearAllData();
    state = AuthState.unauthenticated();
  }
}
