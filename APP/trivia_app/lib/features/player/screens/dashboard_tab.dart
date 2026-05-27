import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/quiz_bank_model.dart';
import '../../../data/services/api_service.dart';
import '../../../data/providers/profile_provider.dart';
import 'quiz_screen.dart';

class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab> {
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
    final banks = await _api.getActiveBanks();
    setState(() {
      _banks = banks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryContainer),
      );
    }

    // Dynamic extraction of the closest expiring quiz as requested in §3.5
    QuizBankModel? featuredQuiz;
    List<QuizBankModel> otherQuizzes = [];

    if (_banks.isNotEmpty) {
      // 1. Filter banks that have an upcoming end time and are not expired
      final datedBanks = _banks
          .where((b) => b.tiempoFin != null && !b.isExpired)
          .toList();

      if (datedBanks.isNotEmpty) {
        // Sort by closest end time first
        datedBanks.sort((a, b) => a.tiempoFin!.compareTo(b.tiempoFin!));
        featuredQuiz = datedBanks.first;
      } else {
        // Fallback: hierarchy by ID (lowest ID first) or random selection
        // Let's sort by ID (ascending) as hierarchy
        final sortedBanks = List<QuizBankModel>.from(_banks);
        sortedBanks.sort((a, b) => a.id.compareTo(b.id));
        featuredQuiz = sortedBanks.first;
      }

      // Rest of the quizzes represent normal ones
      otherQuizzes = _banks.where((b) => b.id != featuredQuiz!.id).toList();
    }

    final profileAsync = ref.watch(profileProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await _loadBanks();
        ref.invalidate(profileProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome banner card
              profileAsync.when(
                data: (user) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryContainer, Color(0xFF2E1052)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryContainer.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, ${user?.primerNombre ?? "Estudiante"}! 👋',
                        style: AppTextStyles.titleMd(
                          color: Colors.white,
                        ).copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Institución: ${user?.institucion ?? "Ingeniería"}',
                        style: AppTextStyles.bodySm(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.stars,
                            color: AppColors.secondaryContainer,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Puntos Acumulados: ${NumberFormat.decimalPattern().format(user?.puntajeTotal ?? 0)} PTS',
                            style: AppTextStyles.labelMd(
                              color: Colors.white,
                            ).copyWith(fontSize: 14, letterSpacing: 0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // FEATURED QUIZ (Closest to ending)
              if (featuredQuiz != null) ...[
                const Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: AppColors.streakOrange,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Trivia por Finalizar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFeaturedQuizCard(featuredQuiz),
                const SizedBox(height: 28),
              ],

              // OTHER ACTIVE QUIZZES LIST/GRID
              const Row(
                children: [
                  Icon(
                    Icons.explore_outlined,
                    color: AppColors.primaryContainer,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Explorar Cuestionarios',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (otherQuizzes.isEmpty && featuredQuiz == null)
                _buildEmptyState()
              else if (otherQuizzes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      'No hay más cuestionarios activos por ahora.',
                      style: AppTextStyles.bodySm(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: otherQuizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = otherQuizzes[index];
                    return _buildStandardQuizCard(quiz);
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedQuizCard(QuizBankModel quiz) {
    String expiryText = 'Sin límite de tiempo';
    if (quiz.tiempoFin != null) {
      final difference = quiz.tiempoFin!.difference(DateTime.now());
      if (difference.inDays > 0) {
        expiryText =
            'Termina en ${difference.inDays} d y ${difference.inHours % 24} h';
      } else if (difference.inHours > 0) {
        expiryText =
            'Termina en ${difference.inHours} h y ${difference.inMinutes % 60} m';
      } else if (difference.inMinutes > 0) {
        expiryText = '¡Finaliza en ${difference.inMinutes} minutos!';
      } else {
        expiryText = '¡Expirando ya!';
      }
    } else {
      expiryText = 'Prioridad Alta (ID: #${quiz.id})';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.streakOrange,
            Color(0xFFEA580C),
          ], // Vibrant Orange-to-Red gradient per DESIGN.md
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.streakOrange.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startQuiz(quiz),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.flash_on,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            expiryText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.star, color: Colors.white, size: 22),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  quiz.titulo,
                  style: AppTextStyles.titleMd(
                    color: Colors.white,
                  ).copyWith(fontWeight: FontWeight.w900, fontSize: 22),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Cuestionario destacado en vivo. ¡Responde rápido y mantén tu racha para multiplicar tus puntos!',
                  style: TextStyle(
                    color: Color(0xFFF1F5F9),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: Colors.white70,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '10 Preguntas',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Jugar Ahora ',
                            style: AppTextStyles.labelMd(
                              color: AppColors.streakOrange,
                            ).copyWith(fontWeight: FontWeight.w800),
                          ),
                          const Icon(
                            Icons.play_arrow,
                            color: AppColors.streakOrange,
                            size: 16,
                          ),
                        ],
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

  Widget _buildStandardQuizCard(QuizBankModel quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5A259D),
            Color(0xFF3F156B),
          ], // Deep Purple gradients per DESIGN.md
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startQuiz(quiz),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: Colors.greenAccent,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'ACTIVO',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.emoji_events,
                      color: AppColors.secondaryContainer,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  quiz.titulo,
                  style: AppTextStyles.titleMd(
                    color: Colors.white,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Demuestra lo aprendido en este cuestionario. No salgas del juego o se registrará tu puntaje acumulado actual.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: Colors.white70,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '10 Preguntas',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Jugar ',
                            style:
                                AppTextStyles.labelMd(
                                  color: AppColors.primary,
                                ).copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                          ),
                          const Icon(
                            Icons.play_arrow,
                            color: AppColors.primary,
                            size: 14,
                          ),
                        ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'No hay cuestionarios activos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Vuelve más tarde para nuevos desafíos.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadBanks,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _startQuiz(QuizBankModel quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(bankId: quiz.id, bankTitle: quiz.titulo),
      ),
    ).then((_) {
      // Reload points and quizzes on return
      _loadBanks();
      ref.invalidate(profileProvider);
    });
  }
}

// Visual color constant helper
extension ColorsExt on Colors {
  static const Color whiteCD = Color(0xFFF1F5F9);
}
