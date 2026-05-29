import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'u_logo_icon.dart';

/// Widget atómico que combina el ícono SVG de la "U" con el nombre
/// de la aplicación "QuizGame ISUJ". Diseñado para reutilizarse
/// en cualquier AppBar u otra sección de la interfaz.
class AppBrandTitle extends StatelessWidget {
  final double iconSize;
  final double spacing;
  final double? fontSize;

  const AppBrandTitle({
    super.key,
    this.iconSize = 40.0,
    this.spacing = 5.0,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ULogoIcon(size: iconSize),
        SizedBox(width: spacing),
        Text(
          'QuizGame ISUJ',
          style: AppTextStyles.titleMd(
            color: AppColors.primaryContainer,
          ).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
