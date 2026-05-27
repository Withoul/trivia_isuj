import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/player/screens/player_navigation.dart';
import 'features/admin/screens/admin_navigation.dart';

class TriviaApp extends ConsumerWidget {
  const TriviaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Dynamic theme assignment based on user role
    final isLogged = authState.isAuthenticated;
    final isAdmin = isLogged && authState.perfil == 'ADMINISTRADOR';
    final activeTheme = isAdmin ? AppTheme.adminTheme() : AppTheme.lightTheme();

    return MaterialApp(
      title: 'QuizGame ISUTJ',
      debugShowCheckedModeBanner: false,
      theme: activeTheme,
      home: _getHomeScreen(authState),
    );
  }

  Widget _getHomeScreen(AuthState authState) {
    if (!authState.isAuthenticated) {
      return const LoginScreen();
    }
    
    if (authState.perfil == 'ADMINISTRADOR') {
      return const AdminNavigation();
    } else {
      return const PlayerNavigation();
    }
  }
}
