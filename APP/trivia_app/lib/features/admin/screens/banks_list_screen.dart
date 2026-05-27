import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/quiz_bank_model.dart';
import '../../../data/services/api_service.dart';
import 'bank_form_screen.dart';
import 'questions_screen.dart';

class BanksListScreen extends StatefulWidget {
  const BanksListScreen({super.key});

  @override
  State<BanksListScreen> createState() => _BanksListScreenState();
}

class _BanksListScreenState extends State<BanksListScreen> {
  final ApiService _api = ApiService();
  List<QuizBankModel> _banks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    setState(() => _isLoading = true);
    final banks = await _api.getAdminBanks();
    setState(() {
      _banks = banks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer));
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceAdmin,
      body: RefreshIndicator(
        onRefresh: _loadRankings,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bancos de Preguntas',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'Administra y edita los cuestionarios disponibles',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.primaryContainer),
                    onPressed: _loadBanks,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: _banks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _banks.length,
                        itemBuilder: (context, index) {
                          final bank = _banks[index];
                          return _buildBankCard(bank);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadRankings() async {
    await _loadBanks();
  }

  Widget _buildBankCard(QuizBankModel bank) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final startStr = bank.tiempoInicio != null ? dateFormat.format(bank.tiempoInicio!) : 'No definida';
    final finStr = bank.tiempoFin != null ? dateFormat.format(bank.tiempoFin!) : 'No definida';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    bank.titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: bank.isActive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: bank.isActive ? Colors.green.shade200 : Colors.red.shade200,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    bank.isActive ? 'ACTIVO' : 'INACTIVO',
                    style: TextStyle(
                      color: bank.isActive ? Colors.green.shade700 : AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Validity Date Range display
            Row(
              children: [
                const Icon(Icons.date_range, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  'Inicio: $startStr',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.event_busy, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  'Fin: $finStr',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            
            // Actions toolbar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BankFormScreen(bankToEdit: bank),
                      ),
                    ).then((_) => _loadBanks());
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar Cuestionario', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuestionsScreen(bankId: bank.id, bankTitle: bank.titulo),
                      ),
                    );
                  },
                  icon: const Icon(Icons.quiz, size: 16),
                  label: const Text('Preguntas', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: AppColors.primaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'No hay cuestionarios registrados',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          const Text('Crea uno nuevo usando la pestaña de creación.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadBanks,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}
