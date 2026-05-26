import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_helper.dart';
import 'api_service.dart';

final authProvider = NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends Notifier<bool> {
  final ApiService _apiService = ApiService();

  @override
  bool build() {
    checkAuth();
    return false;
  }

  Future<void> checkAuth() async {
    final session = await DatabaseHelper.instance.getSession();
    if (session != null) {
      state = true;
    } else {
      state = false;
    }
  }

  Future<bool> login(String correo, String password) async {
    final result = await _apiService.login(correo, password);
    if (result != null) {
      state = true;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await DatabaseHelper.instance.clearAllData();
    state = false;
  }
}
