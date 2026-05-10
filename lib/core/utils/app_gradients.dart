import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppGradients {
  static const LinearGradient primaryGradient =
      LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.primaryGradient,
  );

  static const LinearGradient secondaryGradient =
      LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: AppColors.secondaryGradient,
  );

  static const LinearGradient pinkGradient =
      LinearGradient(
    colors: [
      AppColors.pink,
      AppColors.softPink,
    ],
  );

  static const LinearGradient blueGradient =
      LinearGradient(
    colors: [
      AppColors.blue,
      AppColors.skyBlue,
    ],
  );
}