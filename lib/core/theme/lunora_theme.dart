import 'package:flutter/material.dart';

/// Lunora Phase 1 palette. Keep text colors high-contrast on pastel surfaces.
abstract final class LunoraColors {
  static const pink = Color(0xFFF8E1E7);
  static const pinkDeep = Color(0xFFE8A9B8);
  static const lavender = Color(0xFFD8C7E8);
  static const lavenderDeep = Color(0xFF9B7FB8);
  static const blue = Color(0xFFA8C8E8);
  static const blueDeep = Color(0xFF5B84B1);
  static const ink = Color(0xFF2A2233);
  static const inkSoft = Color(0xFF6B6478);
  static const bg = Color(0xFFFDFBFD);
  static const card = Color(0xFFFFFFFF);
  static const line = Color(0xFFEFE8F0);
  static const success = Color(0xFF7BB89A);
  static const warn = Color(0xFFE0A458);

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
      );
}
