import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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

  // New configuration fields
  int _tiempoPorPregunta = 12;
  int _puntosPorPregunta = 5;
  String _colorBanner = '#461F70';
  bool _esPermanente = false;

  // Predefined color palette for banner selection
  static const List<Map<String, dynamic>> _bannerColors = [
    {'hex': '#461F70', 'name': 'Púrpura Institucional'},
    {'hex': '#0D9488', 'name': 'Teal Vibrante'},
    {'hex': '#DC2626', 'name': 'Rojo Intenso'},
    {'hex': '#2563EB', 'name': 'Azul Eléctrico'},
    {'hex': '#D97706', 'name': 'Ámbar Dorado'},
    {'hex': '#059669', 'name': 'Verde Esmeralda'},
    {'hex': '#7C3AED', 'name': 'Violeta Brillante'},
    {'hex': '#DB2777', 'name': 'Rosa Fucsia'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bankToEdit != null) {
      _titleCtrl.text = widget.bankToEdit!.titulo;
      _isActive = widget.bankToEdit!.isActive;
      _startDate = widget.bankToEdit!.tiempoInicio;
      _endDate = widget.bankToEdit!.tiempoFin;
      _tiempoPorPregunta = widget.bankToEdit!.tiempoPorPregunta;
      _puntosPorPregunta = widget.bankToEdit!.puntosPorPregunta;
      _colorBanner = widget.bankToEdit!.colorBanner;
      _esPermanente = widget.bankToEdit!.esPermanente;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Color _parseBannerColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primaryContainer;
    }
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
        initialTime: TimeOfDay.fromDateTime((isStart ? _startDate : _endDate) ?? DateTime.now()),
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
        _esPermanente ? null : _startDate,
        _esPermanente ? null : _endDate,
        tiempoPorPregunta: _tiempoPorPregunta,
        colorBanner: _colorBanner,
        puntosPorPregunta: _puntosPorPregunta,
        esPermanente: _esPermanente,
      );
    } else {
      // Create
      result = await _api.createBank(
        _titleCtrl.text.trim(),
        _isActive,
        _esPermanente ? null : _startDate,
        _esPermanente ? null : _endDate,
        tiempoPorPregunta: _tiempoPorPregunta,
        colorBanner: _colorBanner,
        puntosPorPregunta: _puntosPorPregunta,
        esPermanente: _esPermanente,
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
                  : 'Cuestionario creado correctamente'
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Pushed from BanksListScreen in both modes, so always pop back
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar. Verifica tu conexión con el backend.'),
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
              // Header with gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_parseBannerColor(_colorBanner), const Color(0xFF1A0B2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _parseBannerColor(_colorBanner).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nuevo Cuestionario ✨',
                      style: AppTextStyles.titleMd(color: Colors.white)
                          .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configura todos los detalles de tu trivia',
                      style: AppTextStyles.bodySm(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // --- SECTION: BASIC INFO ---
            _buildSectionHeader('📝 Información Básica'),
            const SizedBox(height: 12),

            // Title Field
            _buildFieldLabel('Título del Cuestionario'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                hintText: 'Ej. Matemáticas Básicas - Examen 1',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
                ),
              ),
              validator: (val) => (val == null || val.isEmpty) ? 'El título es requerido' : null,
            ),
            const SizedBox(height: 20),

            // Active Switch
            _buildToggleCard(
              'Estado del Cuestionario',
              _isActive ? 'Habilitado' : 'Deshabilitado',
              _isActive,
              (val) => setState(() => _isActive = val),
              icon: Icons.power_settings_new,
              activeColor: Colors.green,
            ),
            const SizedBox(height: 28),

            // --- SECTION: GAME CONFIGURATION ---
            _buildSectionHeader('⚙️ Configuración del Juego'),
            const SizedBox(height: 12),

            // Time per question slider
            _buildConfigCard(
              icon: Icons.timer,
              title: 'Tiempo por Pregunta',
              subtitle: '$_tiempoPorPregunta segundos',
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryContainer,
                      inactiveTrackColor: AppColors.primaryContainer.withOpacity(0.15),
                      thumbColor: AppColors.primaryContainer,
                      overlayColor: AppColors.primaryContainer.withOpacity(0.12),
                      valueIndicatorColor: AppColors.primaryContainer,
                      valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    child: Slider(
                      value: _tiempoPorPregunta.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 11,
                      label: '$_tiempoPorPregunta s',
                      onChanged: (val) => setState(() => _tiempoPorPregunta = val.round()),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('5s', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      Text('60s', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Points per question
            _buildConfigCard(
              icon: Icons.stars,
              title: 'Puntos por Pregunta',
              subtitle: '$_puntosPorPregunta puntos base',
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.secondaryContainer,
                      inactiveTrackColor: AppColors.secondaryContainer.withOpacity(0.15),
                      thumbColor: AppColors.secondaryContainer,
                      overlayColor: AppColors.secondaryContainer.withOpacity(0.12),
                      valueIndicatorColor: AppColors.secondaryContainer,
                      valueIndicatorTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    child: Slider(
                      value: _puntosPorPregunta.toDouble(),
                      min: 1,
                      max: 100,
                      divisions: 99,
                      label: '$_puntosPorPregunta pts',
                      onChanged: (val) => setState(() => _puntosPorPregunta = val.round()),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1 pt', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      Text('100 pts', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Banner Color Picker
            _buildConfigCard(
              icon: Icons.palette,
              title: 'Color del Banner',
              subtitle: _bannerColors.firstWhere(
                (c) => c['hex'] == _colorBanner,
                orElse: () => {'name': _colorBanner},
              )['name'],
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _bannerColors.map((colorOption) {
                  final isSelected = _colorBanner == colorOption['hex'];
                  final color = _parseBannerColor(colorOption['hex']);
                  return GestureDetector(
                    onTap: () => setState(() => _colorBanner = colorOption['hex']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            // --- SECTION: AVAILABILITY ---
            _buildSectionHeader('📅 Disponibilidad'),
            const SizedBox(height: 12),

            // Permanence Toggle
            _buildToggleCard(
              'Tipo de Trivia',
              _esPermanente ? 'Permanente (sin fecha límite)' : 'Temporal (con fechas)',
              _esPermanente,
              (val) => setState(() {
                _esPermanente = val;
                if (val) {
                  _startDate = null;
                  _endDate = null;
                }
              }),
              icon: _esPermanente ? Icons.all_inclusive : Icons.date_range,
              activeColor: AppColors.primaryContainer,
            ),

            // Date pickers (only shown if temporal)
            if (!_esPermanente) ...[
              const SizedBox(height: 16),

              // Start Date
              _buildFieldLabel('Fecha de Inicio'),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: () => _selectDate(context, true),
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  _startDate != null ? format.format(_startDate!) : 'Elegir Fecha de Inicio',
                  style: const TextStyle(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 12),

              // End Date
              _buildFieldLabel('Fecha de Finalización'),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: () => _selectDate(context, false),
                icon: const Icon(Icons.event_busy, size: 16),
                label: Text(
                  _endDate != null ? format.format(_endDate!) : 'Elegir Fecha de Fin',
                  style: const TextStyle(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
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
                    icon: const Icon(Icons.clear, size: 16, color: AppColors.error),
                    label: const Text('Limpiar fechas', style: TextStyle(color: AppColors.error)),
                  ),
                ),
              ],
            ],

            const SizedBox(height: 32),

            // Save Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _parseBannerColor(_colorBanner),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                  shadowColor: _parseBannerColor(_colorBanner).withOpacity(0.3),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isEditing ? 'Guardar Cambios  ' : 'Publicar Cuestionario  ',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const Icon(Icons.save, color: Colors.white, size: 18),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Cuestionario' : 'Crear Cuestionario',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: mainContent,
    );
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: AppTextStyles.titleMd(color: AppColors.onSurface).copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 14),
    );
  }

  Widget _buildToggleCard(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    IconData icon = Icons.toggle_on,
    Color activeColor = Colors.green,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: value ? activeColor.withOpacity(0.3) : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (value ? activeColor : Colors.grey).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: value ? activeColor : Colors.grey, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: value ? activeColor : Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryContainer, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 14),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
