import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../core/widgets/moneda_icon.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      data: (user) {
        if (user == null) {
          return const Center(
            child: Text('No se pudo cargar el perfil del usuario.'),
          );
        }

        final points = NumberFormat.decimalPattern().format(
          user.puntajeTotal ?? 0,
        );

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // Avatar and Level Badge Container
                Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 54,
                        backgroundColor: Color(0xFFF1F4FF),
                        child: Icon(
                          Icons.person,
                          color: AppColors.primaryContainer,
                          size: 64,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.secondaryContainer,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryContainer.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          '⭐ NIVEL 12 - MAESTRO',
                          style:
                              AppTextStyles.labelMd(
                                color: AppColors.onSecondaryContainer,
                              ).copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Name and Carrera
                Text(
                  user.fullName,
                  style: AppTextStyles.headlineLgMobile(
                    color: AppColors.onSurface,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user.institucion,
                  style: AppTextStyles.bodySm(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Statistics Cards Grid
                Row(
                  children: [
                    // Quizzes Completed Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.01),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${user.quizzesCompletados ?? 0}',
                              style: AppTextStyles.scoreDisplay(
                                color: AppColors.primaryContainer,
                              ).copyWith(fontSize: 24),
                            ),
                            Text(
                              'Quizzes Completados',
                              style: AppTextStyles.labelMd(
                                color: AppColors.outline,
                              ).copyWith(fontSize: 10, letterSpacing: 0),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Max Streak Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.01),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: AppColors.streakOrange,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${user.rachaMaxima ?? 0}',
                              style: AppTextStyles.scoreDisplay(
                                color: AppColors.primaryContainer,
                              ).copyWith(fontSize: 24),
                            ),
                            Text(
                              'Racha Máxima',
                              style: AppTextStyles.labelMd(
                                color: AppColors.outline,
                              ).copyWith(fontSize: 10, letterSpacing: 0),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Total Points Box
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.01),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MonedaIcon(size: 40),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Puntos Totales',
                            style: AppTextStyles.labelMd(
                              color: AppColors.outline,
                            ).copyWith(fontSize: 11, letterSpacing: 0),
                          ),
                          Text(
                            points,
                            style: AppTextStyles.scoreDisplay(
                              color: AppColors.primaryContainer,
                            ).copyWith(fontSize: 22),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Accomplishments/Badges Header
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '🏆 Logros Recientes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Badges Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAchievementBadge(
                      'Mente Rápida',
                      AppColors.secondaryContainer,
                      Icons.flash_on,
                      badgeCount: 3,
                    ),
                    _buildAchievementBadge(
                      'Lector Feroz',
                      Colors.purple.shade400,
                      Icons.menu_book,
                    ),
                    _buildAchievementBadge(
                      'Perfección',
                      Colors.grey.shade300,
                      Icons.lock_outline,
                      isLocked: true,
                    ),
                    _buildAchievementBadge(
                      'Inmortal',
                      Colors.grey.shade300,
                      Icons.lock_outline,
                      isLocked: true,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Función de edición de perfil no implementada en este demo',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text(
                      'Editar Perfil',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryContainer,
                      side: const BorderSide(color: AppColors.primaryContainer),
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
                    label: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF1F2),
                      foregroundColor: Colors.red,
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryContainer),
      ),
      error: (e, _) => Center(child: Text('Error al cargar datos: $e')),
    );
  }

  Widget _buildAchievementBadge(
    String title,
    Color bgColor,
    IconData icon, {
    int badgeCount = 0,
    bool isLocked = false,
  }) {
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
                      color: bgColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Icon(
                icon,
                color: isLocked ? Colors.grey : Colors.white,
                size: 28,
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    '${badgeCount}x',
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
