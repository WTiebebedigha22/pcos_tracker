import 'package:flutter/material.dart';

/// Health-state colors that are NOT just red/green — PCOS UI needs care.
/// Verify contrast manually; these are starting points, not final.
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.insight,
    required this.fertileWindow,
  });

  final Color success, warning, danger, insight, fertileWindow;

  static const light = SemanticColors(
    success: Color(0xFF2E7D32),
    warning: Color(0xFFED6C02),
    danger: Color(0xFFD32F2F),
    insight: Color(0xFF6A1B9A),
    fertileWindow: Color(0xFF90CAF9),
  );

  static const dark = SemanticColors(
    success: Color(0xFF81C784),
    warning: Color(0xFFFFB74D),
    danger: Color(0xFFE57373),
    insight: Color(0xFFCE93D8),
    fertileWindow: Color(0xFF64B5F6),
  );

  @override
  SemanticColors copyWith({
    Color? success, Color? warning, Color? danger,
    Color? insight, Color? fertileWindow,
  }) => SemanticColors(
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    insight: insight ?? this.insight,
    fertileWindow: fertileWindow ?? this.fertileWindow,
  );

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      insight: Color.lerp(insight, other.insight, t)!,
      fertileWindow: Color.lerp(fertileWindow, other.fertileWindow, t)!,
    );
  }
}
