import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'api_service.dart';

void main() {
  runApp(const ProviderScope(child: TriviaApp()));
}

class TriviaApp extends ConsumerWidget {
  const TriviaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authProvider);

    return MaterialApp(
      title: 'Trivia ISUJ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isAuthenticated ? const BanksScreen() : const LoginScreen(),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).login(_emailCtrl.text, _passCtrl.text);
    setState(() => _isLoading = false);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de login o credenciales incorrectas')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Trivia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Correo')),
            TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
            const SizedBox(height: 20),
            _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _login, child: const Text('Ingresar')),
          ],
        ),
      ),
    );
  }
}

class BanksScreen extends ConsumerStatefulWidget {
  const BanksScreen({super.key});
  @override
  ConsumerState<BanksScreen> createState() => _BanksScreenState();
}

class _BanksScreenState extends ConsumerState<BanksScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _banks = [];

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    final banks = await _api.getActiveBanks();
    setState(() {
      _banks = banks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bancos Activos'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => ref.read(authProvider.notifier).logout()),
        ],
      ),
      body: _banks.isEmpty
          ? const Center(child: Text('No hay bancos de preguntas activos en este momento.'))
          : ListView.builder(
              itemCount: _banks.length,
              itemBuilder: (context, index) {
                final bank = _banks[index];
                return ListTile(
                  title: Text(bank['titulo']),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(bankId: bank['id'])));
                  },
                );
              },
            ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final int bankId;
  const QuizScreen({super.key, required this.bankId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await _api.getQuestions(widget.bankId);
    setState(() {
      _questions = questions;
    });
  }

  void _answerQuestion(bool isCorrect) async {
    if (isCorrect) _score += 10; // Ejemplo: 10 pts por correcta
    
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      // Finished
      await _api.submitScore(widget.bankId, _score);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Prueba finalizada. Puntaje: $_score')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Previene salir usando el botón de atrás
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Si el usuario intenta salir, guardar puntaje actual y salir
          await _api.submitScore(widget.bankId, _score);
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Prueba interrumpida. Puntaje guardado: $_score')));
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Jugando'), automaticallyImplyLeading: false),
        body: _questions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Pregunta ${_currentIndex + 1} de ${_questions.length}', style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 20),
                    Text(_questions[_currentIndex]['texto_pregunta'], style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 40),
                    ...(_questions[_currentIndex]['respuestas'] as List).map((resp) {
                      return ElevatedButton(
                        onPressed: () => _answerQuestion(resp['es_correcta']),
                        child: Text(resp['texto_respuesta']),
                      );
                    }).toList(),
                  ],
                ),
              ),
      ),
    );
  }
}
