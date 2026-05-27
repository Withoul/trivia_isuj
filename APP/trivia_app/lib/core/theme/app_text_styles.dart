import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts will be resolved when packages are fetched

class AppTextStyles {
  // Plus Jakarta Sans for Headers/Display
  static TextStyle displayLg({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 56 / 48,
        letterSpacing: -0.02 * 48,
        color: color,
      );

  static TextStyle headlineLg({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 40 / 32,
        color: color,
      );

  static TextStyle headlineLgMobile({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 36 / 28,
        color: color,
      );

  static TextStyle titleMd({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: color,
      );

  static TextStyle labelMd({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.05 * 14,
        color: color,
      );

  static TextStyle scoreDisplay({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 32 / 24,
        fontFeatures: const [
          FontFeature.tabularFigures(), // tabular-nums as requested
        ],
        color: color,
      );

  // Inter for Body copy
  static TextStyle bodyLg({Color? color}) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        height: 28 / 18,
        color: color,
      );

  static TextStyle bodyMd({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 24 / 16,
        color: color,
      );

  static TextStyle bodySm({Color? color}) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: color,
      );
}
