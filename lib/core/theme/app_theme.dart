import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

class AppTheme {
  static ThemeData lightTheme = lightThemeData;

  static ThemeData darkTheme = darkThemeData;

  // Shared Input Decoration
  static InputDecorationTheme inputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 18,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1.5,
      ),
    ),
    hintStyle: const TextStyle(
      color: AppColors.textLight,
      fontSize: 14,
    ),
  );

  // Shared Elevated Button Theme
  static ElevatedButtonThemeData elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      minimumSize: const Size(
        double.infinity,
        56,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // Shared Card Theme
  static CardTheme cardTheme = CardTheme(
    elevation: 2,
    color: AppColors.cardBackground,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  );
}