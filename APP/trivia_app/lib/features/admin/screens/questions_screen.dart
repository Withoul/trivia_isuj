import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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

    final result = await _api.createQuestion(widget.bankId, statement, respuestas);

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

  void _deleteQuestion(QuestionModel question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            SizedBox(width: 10),
            Text('Eliminar Pregunta'),
          ],
        ),
        content: Text(
          '¿Estás seguro que deseas eliminar esta pregunta?\n\n"${question.textoPregunta}"',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _api.deleteQuestion(widget.bankId, question.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pregunta eliminada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadQuestions();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar la pregunta'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _editQuestion(QuestionModel question) {
    final editQuestionCtrl = TextEditingController(text: question.textoPregunta);
    final editOptCtrls = <TextEditingController>[];
    int editCorrectIndex = 0;

    for (int i = 0; i < question.respuestas.length; i++) {
      editOptCtrls.add(TextEditingController(text: question.respuestas[i].textoRespuesta));
      if (question.respuestas[i].esCorrecta) {
        editCorrectIndex = i;
      }
    }

    // Pad to 4 options if needed
    while (editOptCtrls.length < 4) {
      editOptCtrls.add(TextEditingController());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Editar Pregunta ✏️',
                      style: AppTextStyles.titleMd(color: AppColors.onSurface)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    const Text('Enunciado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: editQuestionCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Escribe la pregunta...',
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Alternativas (marca la correcta)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),

                    ...List.generate(4, (i) {
                      final letter = String.fromCharCode(65 + i);
                      final isSelected = editCorrectIndex == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: i,
                              groupValue: editCorrectIndex,
                              activeColor: Colors.green,
                              onChanged: (val) {
                                if (val != null) {
                                  setSheetState(() => editCorrectIndex = val);
                                }
                              },
                            ),
                            Expanded(
                              child: TextField(
                                controller: editOptCtrls[i],
                                decoration: InputDecoration(
                                  hintText: 'Alternativa $letter',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: isSelected ? Colors.green : Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: isSelected ? Colors.green : Colors.grey.shade300,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: isSelected ? Colors.green : AppColors.primaryContainer,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final text = editQuestionCtrl.text.trim();
                          final opts = editOptCtrls.map((c) => c.text.trim()).toList();
                          if (text.isEmpty || opts.any((o) => o.isEmpty)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Completa todos los campos'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          final respuestas = List.generate(4, (i) => {
                            'texto_respuesta': opts[i],
                            'es_correcta': editCorrectIndex == i,
                          });

                          final result = await _api.updateQuestion(
                            widget.bankId,
                            question.id,
                            text,
                            respuestas,
                          );

                          if (result != null && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pregunta actualizada'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _loadQuestions();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.bankTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
          : Column(
              children: [
                // Question count header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryContainer.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.quiz, size: 18, color: AppColors.primaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        '${_questions.length} pregunta${_questions.length == 1 ? '' : 's'} registrada${_questions.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryContainer,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with question number and action buttons
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryContainer, Color(0xFF5A259D)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$index',
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    question.textoPregunta,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                // Edit button
                IconButton(
                  onPressed: () => _editQuestion(question),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: AppColors.primaryContainer,
                  tooltip: 'Editar pregunta',
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
                // Delete button
                IconButton(
                  onPressed: () => _deleteQuestion(question),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppColors.error,
                  tooltip: 'Eliminar pregunta',
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const Divider(height: 20, thickness: 0.5),
            
            // List of answer options under the question card
            ...List.generate(question.respuestas.length, (idx) {
              final ans = question.respuestas[idx];
              final letter = String.fromCharCode(65 + idx);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: ans.esCorrecta ? Colors.green.shade50 : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: ans.esCorrecta ? Colors.green.shade300 : Colors.grey.shade300,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: ans.esCorrecta ? Colors.green.shade700 : const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ans.textoRespuesta,
                        style: TextStyle(
                          color: ans.esCorrecta ? Colors.green.shade700 : const Color(0xFF334155),
                          fontWeight: ans.esCorrecta ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (ans.esCorrecta)
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
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
          )
        ],
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: AppColors.primaryContainer, size: 16),
            ),
            const SizedBox(width: 10),
            const Text(
              'Agregar Nueva Pregunta',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryContainer),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.all(16.0),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enunciado de la Pregunta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _questionCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Ej. ¿Cuál es la capital del Ecuador?',
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text('Alternativas (Marca la opción correcta con el botón lateral)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSavingQuestion
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Guardar Pregunta', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOptionInputRow(int index, String label, TextEditingController ctrl) {
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isSelected ? Colors.green : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isSelected ? Colors.green : AppColors.primaryContainer,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const Text('Crea una pregunta en el panel inferior.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
