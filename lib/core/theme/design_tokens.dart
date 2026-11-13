import 'package:flutter/material.dart';

/// Single source of truth for spacing, radii, and semantic colors.
/// Extend; do not hardcode values in widgets.
class DesignTokens {
  static const space = _Space();
  static const radius = _Radius();
}

class _Space {
  const _Space();
  final double xs = 4, sm = 8, md = 16, lg = 24, xl = 32;
}

class _Radius {
  const _Radius();
  final double sm = 8, md = 12, lg = 20, pill = 999;
}
