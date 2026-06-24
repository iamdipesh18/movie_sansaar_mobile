import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryLight = Color(0xFF8973B3);
  static const Color primaryDark = Colors.redAccent;

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF121212);
  static const Color appBarDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF1C1C1E);

  static const Color textLight = Colors.black;
  static const Color textDark = Colors.white;
  static const Color textMutedLight = Colors.black87;
  static const Color textMutedDark = Colors.white70;

  static const Color scaffoldLight = Colors.white;
  static const Color scaffoldDark = Color(0xFF121212);

  static const Color gradientStartLight = Color(0xFFEEE5FF);
  static const Color gradientEndLight = Color(0xFF8973B3);
  static const Color gradientStartDark = Color(0xFF0F0F0F);
  static const Color gradientEndDark = Color(0xFF1C1C1E);

  static const Color glassLight = Color(0xFFF5F0FF);
  static const Color glassDark = Color(0x1AFFFFFF);
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark = Color(0x1AFFFFFF);

  static const Color snackbarError = Color(0xFFD32F2F);
  static const Color snackbarInfo = Color(0xFF1976D2);
  static const Color snackbarSuccess = Color(0xFF388E3C);
  static const Color snackbarText = Colors.white;

  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2C2C2C);
  static const Color shimmerHighlightDark = Color(0xFF3C3C3C);

  static Color withBlur(Color c, double opacity) => c.withValues(alpha: opacity);
}
