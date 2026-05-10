import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_theme.dart';

final ThemeData lightThemeData = ThemeData(
  useMaterial3: true,

  brightness: Brightness.light,

  scaffoldBackgroundColor:
      AppColors.scaffoldBackground,

  primaryColor: AppColors.primary,

  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.pink,
    tertiary: AppColors.blue,
    surface: AppColors.white,
    error: AppColors.error,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(
      color: AppColors.textPrimary,
    ),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
    ),
  ),

  inputDecorationTheme:
      AppTheme.inputDecorationTheme,

  elevatedButtonTheme:
      AppTheme.elevatedButtonTheme,

  cardTheme: AppTheme.cardTheme,

  dividerColor: AppColors.lightGrey,

  bottomNavigationBarTheme:
      const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.grey,
    elevation: 10,
    type: BottomNavigationBarType.fixed,
  ),

  floatingActionButtonTheme:
      const FloatingActionButtonThemeData(
    backgroundColor: AppColors.pink,
    foregroundColor: Colors.white,
  ),

  progressIndicatorTheme:
      const ProgressIndicatorThemeData(
    color: AppColors.primary,
  ),
);