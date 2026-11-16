import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'dark_theme.dart';
import 'light_theme.dart';
import 'lunora_theme.dart';

class AppTheme {
  // Phase 1 uses the Lunora tokens while legacy screens remain available.
  static ThemeData lightTheme = LunoraColors.theme;

  static ThemeData darkTheme = darkThemeData;

  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.lavenderDeep, width: 1.5),
    ),
    hintStyle: const TextStyle(color: AppColors.inkSoft, fontSize: 14),
  );

  static ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppColors.lavenderDeep,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  static CardThemeData cardTheme = CardThemeData(
    elevation: 0,
    color: AppColors.card,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.line),
    ),
  );
}
