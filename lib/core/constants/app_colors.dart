import 'package:flutter/material.dart';

class AppColors {
  // Primary Feminine Palette
  static const Color primary = Color(0xFF7C4DFF); // DeepPurpleAccent
  static const Color primaryLight = Color(0xFFB39DFF);
  static const Color primaryDark = Color(0xFF5E35B1);

  // Pink Shades
  static const Color pink = Color(0xFFFF4FA3);
  static const Color softPink = Color(0xFFFFD1E8);
  static const Color blushPink = Color(0xFFFFE4F1);

  // Blue Shades
  static const Color blue = Color(0xFF5DA9FF);
  static const Color softBlue = Color(0xFFDCEEFF);
  static const Color skyBlue = Color(0xFFB8DFFF);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF7C4DFF),
    Color(0xFFFF4FA3),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF5DA9FF),
    Color(0xFFFFD1E8),
  ];

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Color(0xFF1E1E1E);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF616161);

  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFFFFBFF);
  static const Color cardBackground = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // PCOS Tracking Colors
  static const Color periodColor = Color(0xFFFF4FA3);
  static const Color ovulationColor = Color(0xFF7C4DFF);
  static const Color fertileWindowColor = Color(0xFF5DA9FF);
  static const Color symptomColor = Color(0xFFFFB6D9);

  // Text Colors
  static const Color textPrimary = Color(0xFF2B2B2B);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
}