import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/database_helper.dart';
import '../../../core/widgets/institution_logo.dart';
import 'signup_screen.dart';

class PressableScaleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  const PressableScaleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  });

  @override
  State<PressableScaleButton> createState() => _PressableScaleButtonState();
}

class _PressableScaleButtonState extends State<PressableScaleButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) =>
          widget.onPressed != null ? setState(() => _scale = 0.96) : null,
      onTapUp: (_) =>
          widget.onPressed != null ? setState(() => _scale = 1.0) : null,
      onTapCancel: () =>
          widget.onPressed != null ? setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: widget.style,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'usuario@usuario.com');
  final _passCtrl = TextEditingController(text: 'user1234');
  bool _isLoading = false;
  bool _obscureText = true;
  bool _keepSession = true;

  void _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text);
    setState(() => _isLoading = false);

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error de login o credenciales incorrectas'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _enterDemoMode(String role) async {
    setState(() => _isLoading = true);

    final email = role == 'ADMINISTRADOR'
        ? 'demo.admin@itsjapon.edu.ec'
        : 'demo.jugador@itsjapon.edu.ec';

    final token = role == 'ADMINISTRADOR'
        ? 'mock_token_demo_admin'
        : 'mock_token_demo_player';

    await DatabaseHelper.instance.saveSession(token, email, role);
    await ref.read(authProvider.notifier).checkAuth();
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Acceso en Modo Demo Offline ($role)'),
          backgroundColor: role == 'ADMINISTRADOR'
              ? AppColors.primaryContainer
              : AppColors.streakOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Radial Glowing Accent: Top Left
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryContainer.withOpacity(0.08),
                    AppColors.primaryContainer.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Radial Glowing Accent: Bottom Right
          Positioned(
            bottom: -150,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondaryContainer.withOpacity(0.09),
                    AppColors.secondaryContainer.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Main Body Scroll
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const InstitutionLogo(),
                      const SizedBox(height: 32),

                      // Form Card Container
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.outlineVariant.withOpacity(0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Bienvenido, Campeón!',
                              style:
                                  AppTextStyles.titleMd(
                                    color: AppColors.primary,
                                  ).copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Prepárate para demostrar tus conocimientos.',
                              style: AppTextStyles.bodySm(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Email input
                            const Text(
                              'Correo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'tu.correo@ujapon.edu.ec',
                                prefixIcon: Icon(
                                  Icons.mail_outline,
                                  color: AppColors.outline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Password input header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Contraseña de Juego',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Contacta al administrador para reestablecer tu contraseña',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    '¿Olvidaste?',
                                    style: TextStyle(
                                      color: AppColors.primaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      fontFamily:
                                          AppTextStyles.labelMd().fontFamily,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passCtrl,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: AppColors.outline,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.outline,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureText = !_obscureText,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Keep session active
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _keepSession,
                                    activeColor: AppColors.primaryContainer,
                                    onChanged: (val) => setState(
                                      () => _keepSession = val ?? true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Mantener sesión activa',
                                  style: AppTextStyles.bodySm(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Iniciar Sesión Action Button
                      PressableScaleButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: Colors.white,
                          shadowColor: AppColors.primaryContainer.withOpacity(
                            0.3,
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Iniciar Sesión  ',
                                    style: AppTextStyles.labelMd().copyWith(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Icon(Icons.sports_esports, size: 22),
                                ],
                              ),
                      ),
                      const SizedBox(height: 24),

                      // Divider with "O ingresa al MODO DEMO OFFLINE"
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.outlineVariant.withOpacity(0.5),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Text(
                              'O INGRESA AL MODO DEMO OFFLINE',
                              style:
                                  AppTextStyles.labelMd(
                                    color: AppColors.outline,
                                  ).copyWith(
                                    fontSize: 10,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.outlineVariant.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Two Interactive Demo Cards Side-By-Side
                      Row(
                        children: [
                          // 1. Estudiante Demo Card
                          Expanded(
                            child: Card(
                              elevation: 0,
                              color: const Color(
                                0xFFFFFBEB,
                              ), // Soft gold tint per DESIGN.md
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: AppColors.secondaryContainer
                                      .withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: InkWell(
                                onTap: _isLoading
                                    ? null
                                    : () => _enterDemoMode('JUGADOR'),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 12.0,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: AppColors.secondaryContainer,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.sports_esports,
                                          color: AppColors.onSecondaryContainer,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Demo Estudiante',
                                        style:
                                            AppTextStyles.labelMd(
                                              color: AppColors.onSurface,
                                            ).copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              letterSpacing: 0,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Jugar mini-quiz, ganar racha y podio.',
                                        style: AppTextStyles.bodySm(
                                          color: AppColors.onSurfaceVariant,
                                        ).copyWith(fontSize: 10),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 2. Administrador Demo Card
                          Expanded(
                            child: Card(
                              elevation: 0,
                              color: const Color(
                                0xFFFBF8FF,
                              ), // Soft purple tint per DESIGN.md
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: AppColors.primaryContainer.withOpacity(
                                    0.2,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                              child: InkWell(
                                onTap: _isLoading
                                    ? null
                                    : () => _enterDemoMode('ADMINISTRADOR'),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 12.0,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryContainer,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.admin_panel_settings,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Demo Admin',
                                        style:
                                            AppTextStyles.labelMd(
                                              color: AppColors.onSurface,
                                            ).copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              letterSpacing: 0,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Crear cuestionarios y gestionar preguntas.',
                                        style: AppTextStyles.bodySm(
                                          color: AppColors.onSurfaceVariant,
                                        ).copyWith(fontSize: 10),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Account Activation Underline Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿Es tu primera vez aquí? '),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Activa tu cuenta',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
