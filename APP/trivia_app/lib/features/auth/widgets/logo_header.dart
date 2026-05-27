import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LogoHeader extends StatelessWidget {
  final double iconSize;
  final double spacing;

  const LogoHeader({
    super.key,
    this.iconSize = 36,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Icon(
            Icons.school, 
            color: AppColors.secondaryContainer, 
            size: iconSize,
          ),
        ),
        SizedBox(width: spacing),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: AppTextStyles.titleMd(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                children: const [
                  TextSpan(
                    text: 'U', 
                    style: TextStyle(color: AppColors.secondaryContainer, fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: 'NIVERSITARIO', 
                    style: TextStyle(color: AppColors.primaryContainer),
                  ),
                ],
              ),
            ),
            Text(
              'JAPÓN',
              style: AppTextStyles.titleMd(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 2.0,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
