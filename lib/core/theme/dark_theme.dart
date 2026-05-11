import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_theme.dart';

final ThemeData darkThemeData = ThemeData(
  useMaterial3: true,

  brightness: Brightness.dark,

  scaffoldBackgroundColor:
      const Color(0xFF121212),

  primaryColor: AppColors.primary,

  colorScheme: ColorScheme.dark(
    primary: AppColors.primaryLight,
    secondary: AppColors.pink,
    tertiary: AppColors.blue,
    surface: const Color(0xFF1E1E1E),
    error: AppColors.error,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Colors.white70,
    ),
  ),

  inputDecorationTheme:
      AppTheme.inputDecorationTheme.copyWith(
    fillColor: const Color(0xFF1E1E1E),
  ),

  elevatedButtonTheme:
      AppTheme.elevatedButtonTheme,

  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
  ),

  dividerColor: Colors.white12,

  bottomNavigationBarTheme:
      const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    selectedItemColor: AppColors.pink,
    unselectedItemColor: Colors.white54,
    elevation: 10,
    type: BottomNavigationBarType.fixed,
  ),

  floatingActionButtonTheme:
      const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),

  progressIndicatorTheme:
      const ProgressIndicatorThemeData(
    color: AppColors.pink,
  ),
);