import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Lunora Phase 1 theme built from the shared app color tokens.
abstract final class LunoraColors {
  static const pink = AppColors.pink;
  static const pinkDeep = AppColors.pinkDeep;
  static const lavender = AppColors.lavender;
  static const lavenderDeep = AppColors.lavenderDeep;
  static const blue = AppColors.blue;
  static const blueDeep = AppColors.blueDeep;
  static const ink = AppColors.ink;
  static const inkSoft = AppColors.inkSoft;
  static const bg = AppColors.bg;
  static const card = AppColors.card;
  static const line = AppColors.line;
  static const success = AppColors.success;
  static const warn = AppColors.warn;

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.light(
          primary: lavenderDeep,
          onPrimary: Colors.white,
          secondary: blueDeep,
          surface: card,
          onSurface: ink,
          error: warn,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: ink),
          bodyMedium: TextStyle(color: ink),
          bodySmall: TextStyle(color: inkSoft),
          titleLarge: TextStyle(color: ink, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: card,
          labelStyle: const TextStyle(color: inkSoft),
          hintStyle: const TextStyle(color: inkSoft),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: lavenderDeep, width: 1.5),
          ),
        ),
      );
}
