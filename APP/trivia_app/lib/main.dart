import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'api_service.dart';
import 'database_helper.dart';

void main() {
  runApp(const ProviderScope(child: TriviaApp()));
}

class TriviaApp extends ConsumerWidget {
  const TriviaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authProvider);

    return MaterialApp(
      title: 'QuizGame ISUTJ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF431874),
          primary: const Color(0xFF431874),
          secondary: const Color(0xFFFFC043),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFF),
      ),
      home: isAuthenticated ? const MainNavigationScreen() : const LoginScreen(),
    );
  }
}

// --- PANTALLA DE INICIO DE SESIÓN (Login.png) ---
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
    final success = await ref.read(authProvider.notifier).login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de login o credenciales incorrectas')),
      );
    }
  }

  // --- BOTÓN INTELIGENTE: SALTAR LOGIN (BYPASS REAL-MOCK) ---
  void _skipLogin() async {
    setState(() => _isLoading = true);
    // 1. Intentar loguearse con credenciales por defecto contra el backend
    final success = await ref.read(authProvider.notifier).login('usuario@usuario.com', 'user1234');
    setState(() => _isLoading = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acceso concedido con el usuario de prueba (En línea)'),
          backgroundColor: Color(0xFF431874),
        ),
      );
      return;
    }
    
    // 2. Si falla (servidor inactivo o sin conexión), omitir e iniciar sesión localmente con datos simulados
    setState(() => _isLoading = true);
    await DatabaseHelper.instance.saveSession(
      'mock_token_isutj_bypass_12345',
      'usuario@usuario.com',
      'JUGADOR',
    );
    // Cambiar manualmente el estado del proveedor de autenticación
    await ref.read(authProvider.notifier).checkAuth();
    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Acceso en Modo Invitado / Omitido (Sin Conexión)'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // LOGOTIPO UNIVERSITARIO JAPÓN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF431874),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.school, color: Color(0xFFFFC043), size: 36),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                            children: [
                              TextSpan(text: 'U', style: TextStyle(color: Color(0xFFFFC043))),
                              TextSpan(text: 'NIVERSITARIO', style: TextStyle(color: Color(0xFF431874))),
                            ],
                          ),
                        ),
                        const Text(
                          'JAPÓN',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Color(0xFF431874),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  '¡Bienvenido, Campeón!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF431874),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Prepárate para demostrar tus conocimientos.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Formulario
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Correo Institucional',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailCtrl,
                      decoration: InputDecoration(
                        hintText: 'tu.correo@ujapon.edu.ec',
                        prefixIcon: const Icon(Icons.mail_outline, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FE),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF431874), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Contraseña de Juego',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Contacta al administrador para reestablecer tu contraseña')),
                            );
                          },
                          child: const Text(
                            '¿Olvidaste?',
                            style: TextStyle(
                              color: Color(0xFF431874),
                              fontWeight: FontWeight.bold,
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
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FE),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF431874), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _keepSession,
                          activeColor: const Color(0xFF431874),
                          onChanged: (val) => setState(() => _keepSession = val ?? true),
                        ),
                        const Text('Mantener sesión activa', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Botón Iniciar Sesión
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF431874),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0xFF431874).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Iniciar Sesión ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Icon(Icons.sports_esports, size: 24),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // --- BOTÓN: SALTAR LOGIN ---
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _skipLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF431874),
                      side: const BorderSide(color: Color(0xFF431874), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Saltar Login / Modo Demo ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.fast_forward, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Es tu primera vez aquí? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        'Activa tu cuenta',
                        style: TextStyle(
                          color: Color(0xFFFFB300),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
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
    );
  }
}

// --- PANTALLA DE REGISTRO MULTIETAPA (Paso 1 y Paso 2 con Validación) ---
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final ApiService _api = ApiService();
  int _currentStep = 1;

  // Controladores del Paso 1: Datos Personales
  final _nameCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();
  final _instCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Controladores del Paso 2: Cuenta
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isLoading = false;

  // Lógica de avance del Paso 1
  void _nextStep() {
    FocusScope.of(context).unfocus();
    final name = _nameCtrl.text.trim();
    final cedula = _cedulaCtrl.text.trim();
    final inst = _instCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty || cedula.isEmpty || inst.isEmpty || phone.isEmpty) {
      _showWarning('Todos los campos son obligatorios');
      return;
    }

    // Validación de Cédula: 10 dígitos numéricos
    final numRegExp = RegExp(r'^\d+$');
    if (cedula.length != 10 || !numRegExp.hasMatch(cedula)) {
      _showWarning('La Cédula debe contener exactamente 10 dígitos numéricos');
      return;
    }

    // Validación de Teléfono: 10 dígitos numéricos
    if (phone.length != 10 || !numRegExp.hasMatch(phone)) {
      _showWarning('El Teléfono debe contener exactamente 10 dígitos numéricos');
      return;
    }

    setState(() {
      _currentStep = 2;
    });
  }

  // Lógica de finalización e inserción en la Base de Datos
  void _register() async {
    FocusScope.of(context).unfocus();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirmPass = _confirmPassCtrl.text;

    if (email.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
      _showWarning('Todos los campos son obligatorios');
      return;
    }

    // Validación de Formato de Email
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      _showWarning('Introduce un correo electrónico válido');
      return;
    }

    // Validación de longitud de contraseña
    if (pass.length < 6) {
      _showWarning('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    // Validación de coincidencia de contraseña
    if (pass != confirmPass) {
      _showWarning('Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);

    // Dividir el nombre completo de forma básica para primer nombre y primer apellido
    final nameParts = _nameCtrl.text.trim().split(' ');
    final firstName = nameParts[0];
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Usuario';

    final success = await _api.register(
      email,
      pass,
      firstName,
      lastName,
      _instCtrl.text.trim(),
      _cedulaCtrl.text.trim(),
      _phoneCtrl.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta registrada y activada correctamente. Ya puedes iniciar sesión.'),
            backgroundColor: Color(0xFF431874),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        _showWarning('Error al registrar la cuenta. El correo o cédula podrían estar ya registrados.');
      }
    }
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar limpia SIN el indicador de gemas
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.school, color: Color(0xFF431874)),
            SizedBox(width: 8),
            Text(
              'QuizGame ISUTJ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF431874)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF431874)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Indicador de Progreso del Registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStepIndicator(1, 'Datos Personales', _currentStep >= 1),
                    Container(
                      width: 40,
                      height: 3,
                      color: _currentStep >= 2 ? const Color(0xFF431874) : Colors.grey.shade300,
                    ),
                    _buildStepIndicator(2, 'Cuenta', _currentStep >= 2),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  _currentStep == 1 ? 'Comienza tu camino al éxito' : 'Crea tus credenciales',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _currentStep == 1
                      ? 'Paso 1: Completa tu información personal y académica'
                      : 'Paso 2: Define tu usuario y contraseña de juego',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Formulario Condicional por Paso
                if (_currentStep == 1) _buildStep1Form() else _buildStep2Form(),

                const SizedBox(height: 30),

                // Botones de control de flujo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep == 2)
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              height: 54,
                              child: OutlinedButton(
                                onPressed: () => setState(() => _currentStep = 1),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF431874),
                                  side: const BorderSide(color: Color(0xFF431874)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Icon(Icons.arrow_back),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : (_currentStep == 1 ? _nextStep : _register),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF431874),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFFFC043), width: 1.5),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentStep == 1 ? 'Siguiente ' : 'Registrarse ',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Icon(
                                      _currentStep == 1 ? Icons.arrow_forward : Icons.check_circle_outline,
                                      size: 20,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes una cuenta? '),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(
                          color: Color(0xFF431874),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepNum, String label, bool isActive) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF431874) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? const Color(0xFF431874) : Colors.grey.shade300,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNum',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey.shade400,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF431874) : Colors.grey,
          ),
        )
      ],
    );
  }

  // Componente Paso 1 (Datos Personales y Escolares)
  Widget _buildStep1Form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre Completo',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameCtrl,
          keyboardType: TextInputType.name,
          decoration: _buildInputDeco('Ej. Ana Pérez', Icons.badge_outlined),
        ),
        const SizedBox(height: 20),
        const Text(
          'Número de Cédula (10 dígitos)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _cedulaCtrl,
          keyboardType: TextInputType.number,
          maxLength: 10,
          decoration: _buildInputDeco('Ej. 1712345678', Icons.credit_card_outlined).copyWith(
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Instituto de procedencia (Escuela/Colegio/Instituto)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _instCtrl,
          keyboardType: TextInputType.text,
          decoration: _buildInputDeco('Ej. Colegio Técnico Japón', Icons.account_balance_outlined),
        ),
        const SizedBox(height: 20),
        const Text(
          'Teléfono Celular (10 dígitos)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: _buildInputDeco('Ej. 0987654321', Icons.phone_android_outlined).copyWith(
            counterText: '',
          ),
        ),
      ],
    );
  }

  // Componente Paso 2 (Correo y Contraseñas)
  Widget _buildStep2Form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Correo Electrónico',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: _buildInputDeco('correo@ejemplo.com', Icons.mail_outline),
        ),
        const SizedBox(height: 20),
        const Text(
          'Contraseña',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passCtrl,
          obscureText: true,
          decoration: _buildInputDeco('••••••••', Icons.lock_outline),
        ),
        const SizedBox(height: 20),
        const Text(
          'Confirmar Contraseña',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPassCtrl,
          obscureText: true,
          decoration: _buildInputDeco('Repite tu contraseña', Icons.lock_reset),
        ),
      ],
    );
  }

  InputDecoration _buildInputDeco(String hint, IconData prefixIcon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefixIcon, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFFF8F9FE),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF431874), width: 2),
      ),
    );
  }
}

// --- PANTALLA PRINCIPAL CON NAVEGACIÓN INFERIOR ---
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const QuizzesTab(),
    const RankingsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.school, color: Color(0xFF431874)),
                SizedBox(width: 6),
                Text(
                  'QuizGame ISUTJ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF431874)),
                ),
              ],
            ),
            // El indicador de gemas va DENTRO de las pantallas de la app
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD54F)),
              ),
              child: const Row(
                children: [
                  Text(
                    '1,250 ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB38F00)),
                  ),
                  Icon(Icons.diamond, color: Colors.cyan, size: 16),
                ],
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _screens[_currentIndex],
      // Barra de Navegación Personalizada Premium
      bottomNavigationBar: Container(
        height: 76,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.assignment_outlined, 'Quizzes'),
            _buildNavItem(1, Icons.leaderboard_outlined, 'Rankings'),
            _buildNavItem(2, Icons.person_outline, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF431874) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              isSelected && index == 1 ? Icons.emoji_events : icon, // Copa en Rankings activo
              color: isSelected
                  ? (index == 1 ? const Color(0xFFFFD54F) : Colors.white)
                  : const Color(0xFF64748B),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// --- PESTAÑA: QUIZZES DISPONIBLES (BanksScreen original rediseñada) ---
class QuizzesTab extends ConsumerStatefulWidget {
  const QuizzesTab({super.key});

  @override
  ConsumerState<QuizzesTab> createState() => _QuizzesTabState();
}

class _QuizzesTabState extends ConsumerState<QuizzesTab> {
  final ApiService _api = ApiService();
  List<dynamic> _banks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    setState(() => _isLoading = true);
    final banks = await _api.getActiveBanks();
    setState(() {
      _banks = banks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trivias Activas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Elige un banco de preguntas y pon a prueba tus habilidades.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _banks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          'No hay bancos de preguntas activos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        const Text('Regresa más tarde.', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadBanks,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Actualizar'),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _banks.length,
                    itemBuilder: (context, index) {
                      final bank = _banks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5A259D), Color(0xFF3F156B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF431874).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                                        SizedBox(width: 6),
                                        Text(
                                          'ACTIVO',
                                          style: TextStyle(
                                            color: Colors.greenAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.emoji_events, color: Color(0xFFFFD54F)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                bank['titulo'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Resuelve la mayor cantidad de preguntas posibles. No te salgas de la prueba o se registrará tu puntaje acumulado actual.',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.help_outline, color: Colors.white70, size: 18),
                                      SizedBox(width: 4),
                                      Text(
                                        '10 Preguntas',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => QuizScreen(bankId: bank['id'], bankTitle: bank['titulo']),
                                        ),
                                      ).then((_) => _loadBanks()); // Recargar al regresar
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFC043),
                                      foregroundColor: const Color(0xFF431874),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Text('Jugar Ahora ', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Icon(Icons.play_arrow),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// --- PESTAÑA: TABLA DE POSICIONES (Ranks.png) ---
class RankingsTab extends StatefulWidget {
  const RankingsTab({super.key});

  @override
  State<RankingsTab> createState() => _RankingsTabState();
}

class _RankingsTabState extends State<RankingsTab> {
  final ApiService _api = ApiService();
  List<dynamic> _rankings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    setState(() => _isLoading = true);
    final ranks = await _api.getGlobalRankings();
    setState(() {
      _rankings = ranks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Dividimos en Top 3 y la lista restante
    final top3 = _rankings.take(3).toList();
    final remaining = _rankings.skip(3).toList();

    // Asegurarse de que Andrea (1), Carlos (2), Luis (3) estén mapeados o mockeados para el podio
    dynamic first, second, third;
    if (top3.isNotEmpty) first = top3[0];
    if (top3.length > 1) second = top3[1];
    if (top3.length > 2) third = top3[2];

    return RefreshIndicator(
      onRefresh: _loadRankings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Rankings',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Top Performers Global',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 24),

              // PODIUM GRÁFICO (1er, 2do y 3er puesto)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2DO PUESTO (Izquierda)
                  if (second != null)
                    _buildPodiumItem(
                      user: second,
                      position: 2,
                      pillarColor: const Color(0xFFE3EDFF),
                      height: 100,
                      badgeColor: Colors.blueGrey.shade300,
                    )
                  else
                    const SizedBox(width: 80),

                  const SizedBox(width: 8),

                  // 1ER PUESTO (Centro - Más alto con corona)
                  if (first != null)
                    _buildPodiumItem(
                      user: first,
                      position: 1,
                      pillarColor: const Color(0xFF431874),
                      height: 135,
                      badgeColor: const Color(0xFFFFD54F),
                      hasCrown: true,
                    )
                  else
                    const SizedBox(width: 90),

                  const SizedBox(width: 8),

                  // 3ER PUESTO (Derecha)
                  if (third != null)
                    _buildPodiumItem(
                      user: third,
                      position: 3,
                      pillarColor: const Color(0xFFE3EDFF),
                      height: 90,
                      badgeColor: Colors.orange.shade300,
                    )
                  else
                    const SizedBox(width: 80),
                ],
              ),
              const SizedBox(height: 30),

              // LISTADO DE POSICIONES
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: remaining.length,
                itemBuilder: (context, index) {
                  final user = remaining[index];
                  final position = index + 4;
                  final isCurrentUser = user['correo'] == 'usuario@usuario.com';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: isCurrentUser
                          ? Border.all(color: const Color(0xFFFFD54F), width: 2)
                          : Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [
                        BoxShadow(
                          color: isCurrentUser
                              ? const Color(0xFFFFD54F).withOpacity(0.15)
                              : Colors.black.withOpacity(0.01),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Posición
                        Text(
                          '$position',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isCurrentUser ? const Color(0xFFB38F00) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Avatar
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: isCurrentUser ? const Color(0xFFFFD54F) : const Color(0xFFE2E8F0),
                          child: isCurrentUser
                              ? const Icon(Icons.person, color: Color(0xFF431874))
                              : Text(
                                  user['primer_nombre'][0],
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF431874)),
                                ),
                        ),
                        const SizedBox(width: 12),

                        // Nombre y Exactitud
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${user['primer_nombre']} ${user['primer_apellido']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isCurrentUser ? const Color(0xFF431874) : Colors.black87,
                                    ),
                                  ),
                                  if (isCurrentUser) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD54F),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Tú',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF431874)),
                                      ),
                                    )
                                  ]
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (isCurrentUser) ...[
                                    Container(
                                      width: 60,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 60 * 0.78,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFD54F),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    '${user['accuracy']}% Accuracy',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                        // Puntos
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              RegExp(r'\d{1,3}(?=(\d{3})+(?!\d))')
                                  .allMatches(user['puntaje_acumulado'].toString())
                                  .fold(user['puntaje_acumulado'].toString(), (prev, match) => prev.replaceFirst(match.group(0)!, '${match.group(0)!},')),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF431874),
                              ),
                            ),
                            const Text(
                              'PTS',
                              style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumItem({
    required dynamic user,
    required int position,
    required Color pillarColor,
    required double height,
    required Color badgeColor,
    bool hasCrown = false,
  }) {
    final name = '${user['primer_nombre']} ${user['primer_apellido']?[0] ?? ""}.';
    final points = RegExp(r'\d{1,3}(?=(\d{3})+(?!\d))')
        .allMatches(user['puntaje_acumulado'].toString())
        .fold(user['puntaje_acumulado'].toString(), (prev, match) => prev.replaceFirst(match.group(0)!, '${match.group(0)!},'));

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Círculo del Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: badgeColor, width: 3),
              ),
              child: const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFE2E8F0),
                child: Icon(Icons.person, color: Color(0xFF431874), size: 30),
              ),
            ),
            // Corona (1er Puesto)
            if (hasCrown)
              const Positioned(
                top: -24,
                child: Icon(Icons.emoji_events, color: Color(0xFFFFD54F), size: 30),
              ),
            // Medallón con Número de Puesto
            Positioned(
              bottom: -8,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  '$position',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF431874),
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
        ),
        Text(
          '$points pts',
          style: const TextStyle(color: Color(0xFFB38F00), fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // Pilar de Posición
        Container(
          width: 76,
          height: height,
          decoration: BoxDecoration(
            color: pillarColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Icon(
            Icons.emoji_events_outlined,
            color: position == 1 ? const Color(0xFFFFD54F) : const Color(0xFF431874),
            size: 28,
          ),
        )
      ],
    );
  }
}

// --- PESTAÑA: PERFIL DEL ESTUDIANTE (profile.png) ---
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            // Avatar y Nivel
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF431874),
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 54,
                    backgroundColor: Color(0xFFF1F4FF),
                    child: Icon(Icons.person, color: Color(0xFF431874), size: 64),
                  ),
                ),
                Positioned(
                  bottom: -12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD54F)),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          '⭐ NIVEL 12 - MAESTRO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB38F00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nombre y Carrera
            const Text(
              'Alex Estudiante',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ingeniería en Sistemas',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Tarjetas de Estadísticas
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 28),
                        SizedBox(height: 8),
                        Text(
                          '45',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF431874)),
                        ),
                        Text(
                          'Quizzes Completados',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                        SizedBox(height: 8),
                        Text(
                          '12',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF431874)),
                        ),
                        Text(
                          'Racha Máxima',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tarjeta de Puntos Totales
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFFFFF9E6),
                    child: Icon(Icons.diamond, color: Color(0xFFFFB300)),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Puntos Totales',
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '15,400',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF431874)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logros Recientes
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '🏆 Logros Recientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAchievementBadge('Mente Rápida', const Color(0xFFFFD54F), Icons.flash_on, badgeCount: 3),
                _buildAchievementBadge('Lector Feroz', const Color(0xFF9C27B0), Icons.menu_book),
                _buildAchievementBadge('Perfección', Colors.grey.shade300, Icons.lock_outline, isLocked: true),
                _buildAchievementBadge('Inmortal', Colors.grey.shade300, Icons.lock_outline, isLocked: true),
              ],
            ),
            const SizedBox(height: 30),

            // Botones de Acción
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de edición de perfil no implementada en este demo')),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF431874),
                  side: const BorderSide(color: Color(0xFF431874)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF1F2),
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(String title, Color bgColor, IconData icon, {int badgeCount = 0, bool isLocked = false}) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  if (!isLocked)
                    BoxShadow(
                      color: bgColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                ],
              ),
              child: Icon(icon, color: isLocked ? Colors.grey : Colors.white, size: 28),
            ),
            if (badgeCount > 0)
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    '${badgeCount}x',
                    style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              )
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isLocked ? Colors.grey : Colors.black87,
          ),
        ),
      ],
    );
  }
}

// --- PANTALLA DE JUEGO (quizzgame.png) ---
class QuizScreen extends StatefulWidget {
  final int bankId;
  final String bankTitle;
  const QuizScreen({super.key, required this.bankId, required this.bankTitle});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;

  // Temporizador circular
  Timer? _timer;
  int _timeLeft = 12;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final questions = await _api.getQuestions(widget.bankId);
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
    _startTimer();
  }

  void _startTimer() {
    _timeLeft = 12;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _answerQuestion(false); // Incorrecto por expiración de tiempo
        }
      });
    });
  }

  void _answerQuestion(bool isCorrect) async {
    _timer?.cancel();
    if (isCorrect) _score += 10;

    setState(() {
      _isAnswered = true;
    });

    // Pequeño delay para mostrar el feedback antes de pasar
    await Future.delayed(const Duration(milliseconds: 800));

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
      _startTimer();
    } else {
      // Finalizado
      await _api.submitScore(widget.bankId, _score);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Prueba finalizada exitosamente. Puntaje acumulado: $_score'),
            backgroundColor: const Color(0xFF431874),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.bankTitle)),
        body: const Center(child: Text('No hay preguntas en este banco.')),
      );
    }

    final question = _questions[_currentIndex];
    final answers = question['respuestas'] as List<dynamic>;
    final double progress = (_currentIndex + 1) / _questions.length;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          _timer?.cancel();
          // Flujo de interrupción exigido: Guardar puntaje actual al salirse
          await _api.submitScore(widget.bankId, _score);
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Prueba interrumpida. Puntaje acumulado guardado: $_score'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.school, color: Color(0xFF431874)),
                  SizedBox(width: 6),
                  Text(
                    'QuizGame ISUTJ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF431874)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD54F)),
                ),
                child: const Row(
                  children: [
                    Text(
                      '1,250 ',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB38F00)),
                    ),
                    Icon(Icons.diamond, color: Colors.cyan, size: 16),
                  ],
                ),
              )
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de Racha y Temporizador Circular
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEBFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Racha x5',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF431874),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Temporizador Circular
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 46,
                        height: 46,
                        child: CircularProgressIndicator(
                          value: _timeLeft / 12,
                          strokeWidth: 4,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC043)),
                        ),
                      ),
                      Text(
                        '$_timeLeft',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF431874),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contador de Preguntas Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Pregunta ${_currentIndex + 1} / ${_questions.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF431874),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Pregunta
              Text(
                question['texto_pregunta'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),

              // Barra de progreso interactiva (con gradiente)
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: constraints.maxWidth * progress,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFC043), Color(0xFF4CAF50)],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Alternativas A, B, C, D dispuestas verticalmente
              Expanded(
                child: ListView.builder(
                  itemCount: answers.length,
                  itemBuilder: (context, index) {
                    final ans = answers[index];
                    final optionLetter = String.fromCharCode(65 + index); // A, B, C, D
                    final isSelected = _selectedAnswerIndex == index;

                    Color cardBgColor = Colors.white;
                    Color borderColor = const Color(0xFFE2E8F0);
                    Color letterBgColor = Colors.white;
                    Color letterTextColor = Colors.black87;

                    if (isSelected) {
                      cardBgColor = const Color(0xFFF1EEFC);
                      borderColor = const Color(0xFF431874);
                      letterBgColor = const Color(0xFF431874);
                      letterTextColor = Colors.white;
                    }

                    return GestureDetector(
                      onTap: _isAnswered
                          ? null
                          : () {
                              setState(() {
                                _selectedAnswerIndex = index;
                              });
                              _answerQuestion(ans['es_correcta']);
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ans['texto_respuesta'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? const Color(0xFF431874) : Colors.black87,
                                ),
                              ),
                            ),
                            // Letra indicativa A, B, C, D
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: letterBgColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                optionLetter,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: letterTextColor,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
