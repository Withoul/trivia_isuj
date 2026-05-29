import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/api_service.dart';
import '../../../core/widgets/app_brand_title.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final ApiService _api = ApiService();
  int _currentStep = 1;

  // Step 1 controllers
  final _nameCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();
  final _instCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Step 2 controllers
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isLoading = false;

  // Ecuadorean Cédula validation algorithm (Module 10) per open question 8.5
  bool _isValidCedulaEcuador(String cedula) {
    if (cedula.length != 10) return false;
    final numRegExp = RegExp(r'^\d+$');
    if (!numRegExp.hasMatch(cedula)) return false;

    // Province check (first 2 digits must be between 01 and 24, or 30)
    int prov = int.tryParse(cedula.substring(0, 2)) ?? 0;
    if (prov < 1 || (prov > 24 && prov != 30)) return false;

    // Third digit check (must be < 6)
    int thirdDigit = int.tryParse(cedula.substring(2, 3)) ?? 9;
    if (thirdDigit >= 6) return false;

    // Sum coefficients
    List<int> coef = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      int val = (int.tryParse(cedula.substring(i, i + 1)) ?? 0) * coef[i];
      if (val >= 10) val -= 9;
      sum += val;
    }

    int checkDigit = int.tryParse(cedula.substring(9, 10)) ?? -1;
    int calculated = (sum % 10 == 0) ? 0 : 10 - (sum % 10);

    return checkDigit == calculated;
  }

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

    if (!_isValidCedulaEcuador(cedula)) {
      _showWarning('La Cédula no es una cédula ecuatoriana válida');
      return;
    }

    final numRegExp = RegExp(r'^\d+$');
    if (phone.length != 10 || !numRegExp.hasMatch(phone)) {
      _showWarning(
        'El Teléfono debe contener exactamente 10 dígitos numéricos',
      );
      return;
    }

    setState(() {
      _currentStep = 2;
    });
  }

  void _register() async {
    FocusScope.of(context).unfocus();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirmPass = _confirmPassCtrl.text;

    if (email.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
      _showWarning('Todos los campos son obligatorios');
      return;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      _showWarning('Introduce un correo electrónico válido');
      return;
    }

    if (pass.length < 6) {
      _showWarning('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    if (pass != confirmPass) {
      _showWarning('Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);

    final nameParts = _nameCtrl.text.trim().split(' ');
    final firstName = nameParts[0];
    final lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : 'Usuario';

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
            content: Text(
              'Cuenta registrada y activada correctamente. Ya puedes iniciar sesión.',
            ),
            backgroundColor: AppColors.primaryContainer,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        _showWarning(
          'Error al registrar la cuenta. El correo o cédula podrían estar ya registrados.',
        );
      }
    }
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AppBrandTitle(),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryContainer),
      ),
      body: Stack(
        children: [
          // Radial glow accents
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryContainer.withOpacity(0.06),
                    AppColors.primaryContainer.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondaryContainer.withOpacity(0.06),
                    AppColors.secondaryContainer.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    // Step Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStepIndicator(
                          1,
                          'Datos Personales',
                          _currentStep >= 1,
                        ),
                        Container(
                          width: 40,
                          height: 3,
                          color: _currentStep >= 2
                              ? AppColors.primaryContainer
                              : Colors.grey.shade300,
                        ),
                        _buildStepIndicator(2, 'Cuenta', _currentStep >= 2),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      _currentStep == 1
                          ? 'Comienza tu camino al éxito'
                          : 'Crea tus credenciales',
                      style: AppTextStyles.headlineLgMobile(
                        color: AppColors.onSurface,
                      ).copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentStep == 1
                          ? 'Paso 1: Completa tu información personal y académica'
                          : 'Paso 2: Define tu usuario y contraseña de juego',
                      style: AppTextStyles.bodySm(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Card Container
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
                      child: _currentStep == 1
                          ? _buildStep1Form()
                          : _buildStep2Form(),
                    ),
                    const SizedBox(height: 30),

                    // Controls row
                    Row(
                      children: [
                        if (_currentStep == 2) ...[
                          SizedBox(
                            height: 54,
                            width: 64,
                            child: OutlinedButton(
                              onPressed: () => setState(() => _currentStep = 1),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.primaryContainer,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: AppColors.primaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : (_currentStep == 1 ? _nextStep : _register),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryContainer,
                                foregroundColor: Colors.white,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _currentStep == 1
                                              ? 'Siguiente '
                                              : 'Registrarse ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Icon(
                                          _currentStep == 1
                                              ? Icons.arrow_forward
                                              : Icons.check_circle_outline,
                                          size: 18,
                                          color: Colors.white,
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
                              color: AppColors.primaryContainer,
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
        ],
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
            color: isActive ? AppColors.primaryContainer : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? AppColors.primaryContainer
                  : Colors.grey.shade300,
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
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primary : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1Form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre Completo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameCtrl,
          keyboardType: TextInputType.name,
          decoration: const InputDecoration(
            hintText: 'Ej. Ana Pérez',
            prefixIcon: Icon(Icons.badge_outlined, color: AppColors.outline),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Número de Cédula (10 dígitos)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _cedulaCtrl,
          keyboardType: TextInputType.number,
          maxLength: 10,
          decoration: const InputDecoration(
            hintText: 'Ej. 1712345678',
            prefixIcon: Icon(
              Icons.credit_card_outlined,
              color: AppColors.outline,
            ),
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Instituto de procedencia (Escuela/Colegio)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _instCtrl,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            hintText: 'Ej. Colegio Técnico Japón',
            prefixIcon: Icon(
              Icons.account_balance_outlined,
              color: AppColors.outline,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Teléfono Celular (10 dígitos)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: const InputDecoration(
            hintText: 'Ej. 0987654321',
            prefixIcon: Icon(
              Icons.phone_android_outlined,
              color: AppColors.outline,
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Correo Electrónico',
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
            hintText: 'correo@ejemplo.com',
            prefixIcon: Icon(Icons.mail_outline, color: AppColors.outline),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Contraseña de Juego',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock_outline, color: AppColors.outline),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Confirmar Contraseña',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPassCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Repite tu contraseña',
            prefixIcon: Icon(Icons.lock_reset, color: AppColors.outline),
          ),
        ),
      ],
    );
  }
}
