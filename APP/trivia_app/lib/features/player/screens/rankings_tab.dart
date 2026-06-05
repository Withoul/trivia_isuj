import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/ranking_model.dart';
import '../../../data/services/api_service.dart';

class RankingsTab extends StatefulWidget {
  const RankingsTab({super.key});

  @override
  State<RankingsTab> createState() => _RankingsTabState();
}

class _RankingsTabState extends State<RankingsTab>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  List<RankingModel> _rankings = [];
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadRankings();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryContainer),
      );
    }

    final top3 = _rankings.take(3).toList();
    final remaining = _rankings.skip(3).toList();

    RankingModel? first, second, third;
    if (top3.isNotEmpty) first = top3[0];
    if (top3.length > 1) second = top3[1];
    if (top3.length > 2) third = top3[2];

    return RefreshIndicator(
      onRefresh: _loadRankings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            children: [
              Text(
                'Tabla de Posiciones',
                style: AppTextStyles.headlineLgMobile(
                  color: AppColors.onSurface,
                ).copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Top Performers Globales',
                style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 32),

              // 3D PODIUM DISPLAY
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2ND PLACE (Left)
                  if (second != null)
                    _buildPodiumItem(
                      user: second,
                      position: 2,
                      pillarColor: const Color(0xFFE2E8F0),
                      height: 100,
                      badgeColor: Colors.blueGrey.shade300,
                    )
                  else
                    const SizedBox(width: 80),

                  const SizedBox(width: 12),

                  // 1ST PLACE (Center - tallest with crown)
                  if (first != null)
                    _buildPodiumItem(
                      user: first,
                      position: 1,
                      pillarColor: AppColors.primaryContainer,
                      height: 140,
                      badgeColor: AppColors.secondaryContainer,
                      hasCrown: true,
                    )
                  else
                    const SizedBox(width: 90),

                  const SizedBox(width: 12),

                  // 3RD PLACE (Right)
                  if (third != null)
                    _buildPodiumItem(
                      user: third,
                      position: 3,
                      pillarColor: const Color(0xFFEFF3F8),
                      height: 80,
                      badgeColor: Colors.orange.shade300,
                    )
                  else
                    const SizedBox(width: 80),
                ],
              ),
              const SizedBox(height: 32),

              // SCROLLABLE LIST OF REMAINING USERS
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: remaining.length,
                itemBuilder: (context, index) {
                  final user = remaining[index];
                  final position = index + 4;
                  final isCurrentUser = user.correo == 'usuario@usuario.com';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrentUser
                            ? AppColors.secondaryContainer
                            : AppColors.outlineVariant.withValues(alpha: 0.4),
                        width: isCurrentUser ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isCurrentUser
                              ? AppColors.secondaryContainer.withValues(
                                  alpha: 0.12,
                                )
                              : Colors.black.withValues(alpha: 0.01),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Position Number
                        SizedBox(
                          width: 24,
                          child: Text(
                            '$position',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isCurrentUser
                                  ? AppColors.secondary
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // User Avatar
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: isCurrentUser
                              ? AppColors.secondaryContainer
                              : const Color(0xFFF1F5F9),
                          child: isCurrentUser
                              ? const Icon(
                                  Icons.person,
                                  color: AppColors.primaryContainer,
                                  size: 20,
                                )
                              : Text(
                                  user.primerNombre.isNotEmpty
                                      ? user.primerNombre[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),

                        // Username and Accuracy Detail
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user.fullName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isCurrentUser
                                          ? AppColors.primaryContainer
                                          : Colors.black87,
                                    ),
                                  ),
                                  if (isCurrentUser) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Tú',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onSecondaryContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (isCurrentUser) ...[
                                    Container(
                                      width: 50,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 50 * (user.accuracy / 100),
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColors.secondaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    '${user.accuracy}% Precisión',
                                    style: AppTextStyles.bodySm(
                                      color: AppColors.onSurfaceVariant,
                                    ).copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Accumulated Points
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              NumberFormat.decimalPattern().format(
                                user.puntajeAcumulado,
                              ),
                              style: AppTextStyles.scoreDisplay(
                                color: AppColors.primaryContainer,
                              ).copyWith(fontSize: 16),
                            ),
                            Text(
                              'PTS',
                              style: AppTextStyles.labelMd(
                                color: AppColors.outline,
                              ).copyWith(fontSize: 9, letterSpacing: 0.5),
                            ),
                          ],
                        ),
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
    required RankingModel user,
    required int position,
    required Color pillarColor,
    required double height,
    required Color badgeColor,
    bool hasCrown = false,
  }) {
    final initials = user.primerNombre.isNotEmpty
        ? user.primerNombre[0].toUpperCase()
        : '?';
    final points = NumberFormat.decimalPattern().format(user.puntajeAcumulado);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Avatar frame
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: badgeColor,
                  width: position == 1 ? 3.5 : 2,
                ),
                boxShadow: [
                  if (position == 1)
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: CircleAvatar(
                radius: position == 1 ? 30 : 25,
                backgroundColor: position == 1
                    ? AppColors.primaryContainer
                    : const Color(0xFFF1F5F9),
                child: Text(
                  initials,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: position == 1 ? 22 : 18,
                    color: position == 1
                        ? Colors.white
                        : AppColors.primaryContainer,
                  ),
                ),
              ),
            ),

            // Floating Crown for 1st Place
            if (hasCrown)
              Positioned(
                top: -24,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 4 * _animationController.value),
                      child: const Icon(
                        Icons.emoji_events,
                        color: AppColors.secondaryContainer,
                        size: 28,
                      ),
                    );
                  },
                ),
              ),

          ],
        ),
        const SizedBox(height: 12),

        // Compact name
        Text(
          '${user.primerNombre} ${user.primerApellido.isNotEmpty ? user.primerApellido[0] : ""}.',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.onSurface,
          ),
        ),

        // Points
        Text(
          '$points pts',
          style: TextStyle(
            color: position == 1
                ? AppColors.secondary
                : AppColors.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // 3D Podium Block
        Container(
          width: 78,
          height: height,
          decoration: BoxDecoration(
            color: pillarColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                position == 1
                    ? 'assets/logotipos/puma_primer_puesto.png'
                    : position == 2
                        ? 'assets/logotipos/puma_segundo_puesto.png'
                        : 'assets/logotipos/puma_tercer_puesto.png',
                width: position == 1 ? 38 : 32,
                height: position == 1 ? 38 : 32,
              ),
              const SizedBox(height: 4),
              Text(
                position == 1
                    ? '1ST'
                    : position == 2
                    ? '2ND'
                    : '3RD',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: position == 1
                      ? const Color(0xFFD4A017)
                      : position == 2
                          ? const Color(0xFFA8A9AD)
                          : const Color(0xFFB87333),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
