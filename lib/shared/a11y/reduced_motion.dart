import 'package:flutter/material.dart';

/// Respects OS "reduce motion" — use for non-essential transitions.
class ReducedMotion {
  static bool enabled(BuildContext c) =>
      MediaQuery.maybeOf(c)?.disableAnimations ?? false;

  static Duration duration(BuildContext c, Duration normal) =>
      enabled(c) ? Duration.zero : normal;
}
