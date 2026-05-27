import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/auth_provider.dart';

class AdminProfileTab extends ConsumerWidget {
  const AdminProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Professional Shield Icon instead of gamified avatars
            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFFF1F5F9),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                color: AppColors.primaryContainer,
                size: 54,
              ),
            ),
            const SizedBox(height: 24),

            // Profile info card (Corporate Modern)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información de la Cuenta',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Divider(height: 24, thickness: 1),

                  // Email row
                  _buildCredentialRow(
                    'Usuario / Correo',
                    authState.email ?? 'admin@admin.com',
                  ),
                  const SizedBox(height: 16),

                  // Role row with prominent badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rol Asignado',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.primaryContainer.withOpacity(0.2),
                          ),
                        ),
                        child: const Text(
                          'ADMINISTRADOR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryContainer,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Institution row
                  _buildCredentialRow(
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
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Cerrar Sesión Administrativa',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF1F2),
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
