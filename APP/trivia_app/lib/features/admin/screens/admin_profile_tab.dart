import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/api_service.dart';

class AdminProfileTab extends ConsumerWidget {
  const AdminProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Admin Avatar with gradient border
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primaryContainer, Color(0xFF7C3AED), AppColors.secondaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withOpacity(0.25),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFFF1F5F9),
              child: Icon(
                Icons.admin_panel_settings,
                color: AppColors.primaryContainer,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Admin badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryContainer.withOpacity(0.12),
                  AppColors.primaryContainer.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryContainer.withOpacity(0.2),
              ),
            ),
            child: const Text(
              '🛡️ ADMINISTRADOR',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryContainer,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Stats Cards Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.quiz,
                  title: 'Cuestionarios',
                  value: '3',
                  gradient: [AppColors.primaryContainer, const Color(0xFF5A259D)],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.help_outline,
                  title: 'Preguntas',
                  value: '7',
                  gradient: [const Color(0xFF0D9488), const Color(0xFF065F46)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Profile info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
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
                      child: const Icon(Icons.person, color: AppColors.primaryContainer, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Información de la Cuenta',
                      style: AppTextStyles.titleMd(color: AppColors.onSurface)
                          .copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 0.5),

                // Email row
                _buildCredentialRow(
                  Icons.email_outlined,
                  'Correo Electrónico',
                  authState.email ?? 'admin@admin.com',
                ),
                const SizedBox(height: 16),

                // Role row with prominent badge
                _buildCredentialRow(
                  Icons.shield_outlined,
                  'Rol Asignado',
                  'ADMINISTRADOR',
                  badgeColor: AppColors.primaryContainer,
                ),
                const SizedBox(height: 16),

                // Institution row
                _buildCredentialRow(
                  Icons.school_outlined,
                  'Organización',
                  'Instituto Superior Tecnológico Universitario Japón',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Action button to end administrative session
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              icon: const Icon(Icons.logout),
              label: const Text(
                'Cerrar Sesión Administrativa',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF1F2),
                foregroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.scoreDisplay(color: Colors.white)
                .copyWith(fontSize: 28),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(IconData icon, String label, String value, {Color? badgeColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(height: 2),
              if (badgeColor != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: badgeColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
