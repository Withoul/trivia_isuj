import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/question_model.dart';
import '../../../data/services/api_service.dart';

class QuestionsScreen extends StatefulWidget {
  final int bankId;
  final String bankTitle;

  const QuestionsScreen({
    super.key,
    required this.bankId,
    required this.bankTitle,
  });

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final ApiService _api = ApiService();
  List<QuestionModel> _questions = [];
  bool _isLoading = true;

  // New question form controllers
  final _questionCtrl = TextEditingController();
  final _optACtrl = TextEditingController();
  final _optBCtrl = TextEditingController();
  final _optCCtrl = TextEditingController();
  final _optDCtrl = TextEditingController();

  int _correctOptionIndex = 0; // 0 for A, 1 for B, 2 for C, 3 for D
  bool _isSavingQuestion = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _optACtrl.dispose();
    _optBCtrl.dispose();
    _optCCtrl.dispose();
    _optDCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    final questions = await _api.getQuestions(widget.bankId);
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  void _addQuestion() async {
    final statement = _questionCtrl.text.trim();
    final a = _optACtrl.text.trim();
    final b = _optBCtrl.text.trim();
    final c = _optCCtrl.text.trim();
    final d = _optDCtrl.text.trim();

    if (statement.isEmpty || a.isEmpty || b.isEmpty || c.isEmpty || d.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa la pregunta y las 4 alternativas'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSavingQuestion = true);

    // Build the 4 answer structures required by the FastAPI schema
    final respuestas = [
      {'texto_respuesta': a, 'es_correcta': _correctOptionIndex == 0},
      {'texto_respuesta': b, 'es_correcta': _correctOptionIndex == 1},
      {'texto_respuesta': c, 'es_correcta': _correctOptionIndex == 2},
      {'texto_respuesta': d, 'es_correcta': _correctOptionIndex == 3},
    ];

    final result = await _api.createQuestion(
      widget.bankId,
      statement,
      respuestas,
    );

    setState(() => _isSavingQuestion = false);

    if (result != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pregunta agregada con éxito'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _questionCtrl.clear();
        _optACtrl.clear();
        _optBCtrl.clear();
        _optCCtrl.clear();
        _optDCtrl.clear();
        setState(() {
          _correctOptionIndex = 0;
        });

        // Reload questions list
        _loadQuestions();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la pregunta'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAdmin,
      appBar: AppBar(
        title: Text('${widget.bankTitle} - Preguntas'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryContainer,
              ),
            )
          : Column(
              children: [
                // Top section: scrollable list of existing questions
                Expanded(
                  child: _questions.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _questions.length,
                          itemBuilder: (context, index) {
                            final question = _questions[index];
                            return _buildQuestionCard(question, index + 1);
                          },
                        ),
                ),

                // Bottom section: collapsable/scrollable add question panel
                _buildAddQuestionPanel(),
              ],
            ),
    );
  }

  Widget _buildQuestionCard(QuestionModel question, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question.textoPregunta,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.5),

            // List of answer options under the question card
            ...List.generate(question.respuestas.length, (idx) {
              final ans = question.respuestas[idx];
              final letter = String.fromCharCode(65 + idx);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: ans.esCorrecta
                            ? Colors.green.shade50
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: ans.esCorrecta
                              ? Colors.green.shade700
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ans.textoRespuesta,
                        style: TextStyle(
                          color: ans.esCorrecta
                              ? Colors.green.shade700
                              : const Color(0xFF334155),
                          fontWeight: ans.esCorrecta
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (ans.esCorrecta)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAddQuestionPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ExpansionTile(
        title: const Text(
          '➕ Agregar Nueva Pregunta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.primaryContainer,
          ),
        ),
        childrenPadding: const EdgeInsets.all(16.0),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enunciado de la Pregunta',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _questionCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Ej. ¿Cuál es la capital del Ecuador?',
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Alternativas (Marca la opción correcta con el botón lateral)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 10),

                  _buildOptionInputRow(0, 'Alternativa A', _optACtrl),
                  _buildOptionInputRow(1, 'Alternativa B', _optBCtrl),
                  _buildOptionInputRow(2, 'Alternativa C', _optCCtrl),
                  _buildOptionInputRow(3, 'Alternativa D', _optDCtrl),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSavingQuestion ? null : _addQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSavingQuestion
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Guardar Pregunta',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionInputRow(
    int index,
    String label,
    TextEditingController ctrl,
  ) {
    final isSelected = _correctOptionIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Radio<int>(
            value: index,
            groupValue: _correctOptionIndex,
            activeColor: Colors.green,
            onChanged: (val) {
              if (val != null) {
                setState(() => _correctOptionIndex = val);
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                hintText: label,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                enabledBorder: isSelected
                    ? OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                focusedBorder: isSelected
                    ? OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.help_center_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'No hay preguntas creadas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const Text(
            'Crea una pregunta en el panel inferior.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
