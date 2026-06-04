import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_brand_title.dart';
import '../../../core/widgets/moneda_icon.dart';
import '../../../data/providers/profile_provider.dart';
import 'dashboard_tab.dart';
import 'rankings_tab.dart';
import 'profile_tab.dart';

class PlayerNavigation extends ConsumerStatefulWidget {
  const PlayerNavigation({super.key});

  @override
  ConsumerState<PlayerNavigation> createState() => _PlayerNavigationState();
}

class _PlayerNavigationState extends ConsumerState<PlayerNavigation> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const DashboardTab(),
    const RankingsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppBrandTitle(),

            // Dynamic Gem/Points Pill based on actual User Profile
            profileAsync.when(
              data: (user) {
                final score = user?.puntajeTotal ?? 0;
                final formattedScore = NumberFormat.decimalPattern().format(
                  score,
                );
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
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
                          alpha: 0.15,
                        ),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$formattedScore ',
                        style: AppTextStyles.scoreDisplay(
                          color: AppColors.onSecondaryContainer,
                        ).copyWith(fontSize: 15),
                      ),
                      const MonedaIcon(size: 26),
                    ],
                  ),
                );
              },
              loading: () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              error: (_, _) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '!',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Background Gradient decoration as required for Player Persona
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    AppColors.primaryContainer.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Current Active Tab
          _tabs[_currentIndex],
        ],
      ),

      // Frosted Glass Bottom Navigation Bar matching DESIGN.md
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              border: const Border(
                top: BorderSide(color: Color(0x1F000000), width: 0.5),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.assignment_outlined, 'Quizzes'),
                _buildNavItem(1, Icons.leaderboard_outlined, 'Rankings'),
                _buildNavItem(2, Icons.person_outline, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected && index == 2 ? Icons.emoji_events : icon,
              color: isSelected
                  ? (index == 2 ? AppColors.secondaryContainer : Colors.white)
                  : AppColors.onSurfaceVariant.withValues(alpha: 0.7),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.labelMd(color: Colors.white).copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
