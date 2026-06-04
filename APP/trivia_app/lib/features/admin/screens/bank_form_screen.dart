import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/quiz_bank_model.dart';
import '../../../data/services/api_service.dart';

class BankFormScreen extends StatefulWidget {
  final QuizBankModel? bankToEdit;

  const BankFormScreen({super.key, this.bankToEdit});

  @override
  State<BankFormScreen> createState() => _BankFormScreenState();
}

class _BankFormScreenState extends State<BankFormScreen> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  bool _isActive = true;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.bankToEdit != null) {
      _titleCtrl.text = widget.bankToEdit!.titulo;
      _isActive = widget.bankToEdit!.isActive;
      _startDate = widget.bankToEdit!.tiempoInicio;
      _endDate = widget.bankToEdit!.tiempoFin;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryContainer,
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          (isStart ? _startDate : _endDate) ?? DateTime.now(),
        ),
      );

      if (timePicked != null) {
        setState(() {
          final fullDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
          if (isStart) {
            _startDate = fullDateTime;
          } else {
            _endDate = fullDateTime;
          }
        });
      }
    }
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    QuizBankModel? result;
    if (widget.bankToEdit != null) {
      // Update
      result = await _api.updateBank(
        widget.bankToEdit!.id,
        _titleCtrl.text.trim(),
        _isActive,
        _startDate,
        _endDate,
      );
    } else {
      // Create
      result = await _api.createBank(
        _titleCtrl.text.trim(),
        _isActive,
        _startDate,
        _endDate,
      );
    }

    setState(() => _isLoading = false);

    if (result != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.bankToEdit != null
                  ? 'Cuestionario actualizado correctamente'
                  : 'Cuestionario creado correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.bankToEdit != null) {
          // Exited from child edit screen, pop back
          Navigator.pop(context);
        } else {
          // Cleared inputs upon tab creation success
          setState(() {
            _titleCtrl.clear();
            _isActive = true;
            _startDate = null;
            _endDate = null;
          });
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error al guardar. Verifica tu conexión con el backend.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bankToEdit != null;
    final format = DateFormat('dd/MM/yyyy HH:mm');

    Widget mainContent = SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isEditing) ...[
              const Text(
                'Nuevo Banco de Preguntas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Text(
                'Llena los campos para publicar un nuevo cuestionario',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 24),
            ],

            // Title Field
            const Text(
              'Título del Cuestionario',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: 'Ej. Matemáticas Básicas - Examen 1',
              ),
              validator: (val) => (val == null || val.isEmpty)
                  ? 'El título es requerido'
                  : null,
            ),
            const SizedBox(height: 20),

            // Active Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estado del Cuestionario',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _isActive ? 'Habilitado' : 'Deshabilitado',
                        style: TextStyle(
                          color: _isActive ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _isActive,
                        activeThumbColor: AppColors.primaryContainer,
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date limits header
            const Text(
              'Rango de Disponibilidad (Opcional)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            // Start Date Picker Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fecha de Inicio',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        onPressed: () => _selectDate(context, true),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          _startDate != null
                              ? format.format(_startDate!)
                              : 'Elegir Fecha',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // End Date Picker Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fecha de Finalización',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        onPressed: () => _selectDate(context, false),
                        icon: const Icon(Icons.event_busy, size: 16),
                        label: Text(
                          _endDate != null
                              ? format.format(_endDate!)
                              : 'Elegir Fecha',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Date clear action
            if (_startDate != null || _endDate != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    _startDate = null;
                    _endDate = null;
                  }),
                  icon: const Icon(
                    Icons.clear,
                    size: 16,
                    color: AppColors.error,
                  ),
                  label: const Text(
                    'Limpiar fechas',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Save Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isEditing
                                ? 'Guardar Cambios  '
                                : 'Publicar Cuestionario  ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.save, color: Colors.white, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    if (isEditing) {
      return Scaffold(
        backgroundColor: AppColors.surfaceAdmin,
        appBar: AppBar(
          title: const Text('Editar Cuestionario'),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: mainContent,
      );
    }

    return mainContent;
  }
}
