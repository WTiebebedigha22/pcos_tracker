import 'package:flutter/material.dart';

/// Shared color tokens. Lunora-specific Phase 1 tokens are centralized here
/// so both the current app theme and shared widgets use one palette.
class AppColors {
  static const Color pink = Color(0xFFF8E1E7);
  static const Color pinkDeep = Color(0xFFE8A9B8);
  static const Color lavender = Color(0xFFD8C7E8);
  static const Color lavenderDeep = Color(0xFF9B7FB8);
  static const Color blue = Color(0xFFA8C8E8);
  static const Color blueDeep = Color(0xFF5B84B1);
  static const Color ink = Color(0xFF2A2233);
  static const Color inkSoft = Color(0xFF6B6478);
  static const Color bg = Color(0xFFFDFBFD);
  static const Color card = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFEFE8F0);
  static const Color success = Color(0xFF7BB89A);
  static const Color warn = Color(0xFFE0A458);

  // Compatibility aliases used by legacy feature files.
  static const Color primary = lavenderDeep;
  static const Color primaryLight = lavender;
  static const Color primaryDark = blueDeep;
  static const Color softPink = pink;
  static const Color blushPink = pink;
  static const Color softBlue = blue;
  static const Color skyBlue = blue;
  static const List<Color> primaryGradient = [lavenderDeep, blueDeep];
  static const List<Color> secondaryGradient = [blue, lavender];
  static const Color white = card;
  static const Color black = ink;
  static const Color grey = inkSoft;
  static const Color lightGrey = bg;
  static const Color darkGrey = inkSoft;
  static const Color scaffoldBackground = bg;
  static const Color cardBackground = card;
  static const Color warning = warn;
  static const Color error = warn;
  static const Color info = blueDeep;
  static const Color periodColor = pinkDeep;
  static const Color ovulationColor = lavenderDeep;
  static const Color fertileWindowColor = blueDeep;
  static const Color symptomColor = pinkDeep;
  static const Color textPrimary = ink;
  static const Color textSecondary = inkSoft;
  static const Color textLight = inkSoft;
}
